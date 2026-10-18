import { execFileSync } from 'node:child_process';
import { chmodSync, mkdirSync, mkdtempSync, readFileSync, readlinkSync, realpathSync } from 'node:fs';
import { createServer } from 'node:net';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { ENV, FILES, LIBRARIES, LIMIT, PIN, demand, digestFile, manifest, sandboxArgs, verifyPins } from './policy.mjs';
import { alive, boundedSpawn, finalResult, gone, ownedTree } from './processes.mjs';
import { savePrivate as save, readEvidence } from './safe-output.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const GIT_ENV = { PATH: '/usr/bin:/bin', HOME: '/nonexistent', GIT_CONFIG_GLOBAL: '/dev/null', GIT_CONFIG_SYSTEM: '/dev/null', GIT_OPTIONAL_LOCKS: '0' };
export function sourceCheckout(location = HERE) {
  let root;
  try { root = execFileSync('/usr/bin/git', ['-C', location, 'rev-parse', '--show-toplevel'], { env: GIT_ENV, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], timeout: 2000 }).trim(); }
  catch { throw new Error('experiment-requires-source-checkout'); }
  demand(realpathSync(location) === realpathSync(join(root, 'tools/hindsight-memory/experiments/pi-launch')), 'experiment-requires-source-checkout');
  const dirty = execFileSync('/usr/bin/git', ['-C', root, 'status', '--porcelain', '--untracked-files=all', '--', 'tools/hindsight-memory/experiments/pi-launch'], { env: GIT_ENV, encoding: 'utf8', timeout: 2000 }).trim();
  return { root, experimentDirty: Boolean(dirty), commit: execFileSync('/usr/bin/git', ['-C', root, 'rev-parse', 'HEAD'], { env: GIT_ENV, encoding: 'utf8', timeout: 2000 }).trim() };
}
function privateDirectory(path) { mkdirSync(path, { recursive: true, mode: 0o700 }); chmodSync(path, 0o700); }
async function ready(child, name, timeout = 5000) {
  return new Promise((resolveReady, reject) => {
    let data = ''; const timer = setTimeout(() => finish(new Error('helper-readiness-timeout')), timeout);
    const onClose = () => finish(new Error('helper-closed-before-ready'));
    const onData = bytes => {
      data += bytes.toString('utf8');
      if (Buffer.byteLength(data) > LIMIT.frame) return finish(new Error('helper-readiness-overflow'));
      if (!data.includes('\n')) return;
      try { const value = JSON.parse(data.trim()); demand(value.type === name, 'unexpected-helper-readiness'); finish(null, value); }
      catch (error) { finish(error); }
    };
    function finish(error, value) { clearTimeout(timer); child.stdout.off('data', onData); child.off('close', onClose); if (error) reject(error); else resolveReady(value); }
    child.stdout.on('data', onData); child.once('close', onClose);
  });
}

export async function runExperiment({ preflightOnly = false } = {}) {
  demand(process.platform === 'linux' && process.arch === 'x64' && process.version === 'v24.22.0' && realpathSync(process.execPath) === realpathSync(PIN.runtime), 'exact-node-runtime-required');
  const checkout = sourceCheckout(); demand(preflightOnly || !checkout.experimentDirty, 'native-requires-committed-clean-experiment'); process.umask(0o077);
  const root = mkdtempSync('/var/tmp/hindsight-pi-launch-'); chmodSync(root, 0o700);
  const report = { schema: 1, status: 'running', candidate: checkout.commit, experimentDirty: checkout.experimentDirty, root, preflightOnly, started: new Date().toISOString(), phases: [],
    limits: LIMIT, environmentKeys: Object.keys(ENV), nativeSessionAttachment: false, productionActivation: 'unchanged-and-blocked' };
  const reportPath = join(root, 'report.json'); const active = new Set(); let interrupted = null;
  const stop = reason => { interrupted ??= reason; for (const task of active) task.stop(reason); };
  const onSignal = () => stop('runner-interrupted');
  const deadline = setTimeout(() => stop('overall-timeout'), LIMIT.overall);
  process.once('SIGTERM', onSignal); process.once('SIGINT', onSignal);
  let server, socketServer;
  try {
    const pins = verifyPins();
    const packageManifest = manifest(PIN.package);
    const experimentManifest = manifest(HERE);
    const sources = Object.fromEntries(FILES.map(file => [file, digestFile(join(HERE, file)).sha256]));
    const runtime = digestFile(PIN.runtime);
    const libraries = LIBRARIES.map(name => ({ name, source: realpathSync(`/lib/x86_64-linux-gnu/${name}`), ...digestFile(realpathSync(`/lib/x86_64-linux-gnu/${name}`)) }));
    demand(execFileSync('/usr/bin/bwrap', ['--version'], { env: {}, encoding: 'utf8', timeout: 2000 }).trim() === 'bubblewrap 0.11.1', 'bwrap-version-mismatch');
    let connections = 0;
    server = createServer(socket => { connections++; socket.destroy(); });
    await new Promise((yes, no) => { server.once('error', no); server.listen(0, '127.0.0.1', yes); });
    const sentinel = join(root, 'host-only-sentinel'); save(sentinel, 'not-visible-inside');
    const socketPath = join(root, 'host-only.sock'); socketServer = createServer(socket => socket.destroy());
    await new Promise((yes, no) => { socketServer.once('error', no); socketServer.listen(socketPath, yes); });
    const config = { ...pins, packageManifest: packageManifest.digest, sources, runtime, hostPort: server.address().port,
      hostNamespaces: Object.fromEntries(['mnt', 'pid', 'net'].map(key => [key, readlinkSync(`/proc/self/ns/${key}`)])),
      hidden: [sentinel, socketPath, checkout.root] };
    save(join(root, 'manifest.json'), { package: packageManifest, experiment: experimentManifest, sources, runtime, libraries, binary: pins.binary, sidecar: pins.sidecar });
    report.manifest = packageManifest.digest; report.binary = pins.binary; report.sidecar = pins.sidecar;
    function unchanged() {
      demand(manifest(PIN.package).digest === packageManifest.digest, 'host-package-drift');
      demand(manifest(HERE).digest === experimentManifest.digest, 'host-harness-drift');
      for (const file of FILES) demand(digestFile(join(HERE, file)).sha256 === sources[file], 'host-experiment-drift');
      demand(JSON.stringify(digestFile(PIN.runtime)) === JSON.stringify(runtime), 'host-runtime-drift');
      for (const lib of libraries) {
        const { name, source, ...identity } = lib;
        demand(JSON.stringify(digestFile(source)) === JSON.stringify(identity), 'host-library-drift');
      }
    }
    function phaseInput(name) {
      const output = join(root, name); privateDirectory(output); save(join(output, 'readonly-sentinel'), 'read-only');
      const input = join(root, `${name}-input.json`); save(input, config);
      return { experiment: HERE, output, input };
    }
    async function launch(name, { mode = name, death = null } = {}) {
      demand(!interrupted, interrupted); unchanged();
      const options = phaseInput(name); const args = sandboxArgs({ ...options, mode });
      let command = '/usr/bin/bwrap', commandArgs = args;
      if (death === 'outer') {
        const parentConfig = join(root, 'death-parent.json'); save(parentConfig, options);
        command = PIN.runtime; commandArgs = [join(HERE, 'death-parent.mjs'), parentConfig];
      }
      const task = boundedSpawn(command, commandArgs, { timeout: LIMIT.process }); active.add(task);
      const tracked = new Map();
      const collect = () => { if (task.child.pid) for (const identity of ownedTree(task.child.pid)) tracked.set(`${identity.pid}:${identity.start}`, identity); };
      const observer = setInterval(collect, 20); collect();
      let result, value;
      try {
        if (death) {
          await ready(task.child, death === 'outer' ? 'death-parent-ready' : 'helper-ready'); collect();
          // Allow the harmless grandchild to appear in the host's owned descendant tree.
          await new Promise(resolveDelay => setTimeout(resolveDelay, 50)); collect();
          const identities = [...tracked.values()]; demand(identities.length >= (death === 'outer' ? 4 : 3), 'owned-descendants-not-observed');
          const target = death === 'outer' ? identities.find(item => item.pid === task.child.pid) : identities.find(item => {
            try { return readFileSync(`/proc/${item.pid}/cmdline`, 'utf8').includes('/experiment/supervisor.mjs\0linger'); } catch { return false; }
          });
          demand(target && alive(target), 'supervisor-not-observed'); process.kill(target.pid, 'SIGKILL');
          result = await task.result;
          demand(!result.failure, result.failure); demand(await gone(identities), 'parent-death-left-descendants');
          value = { schema: 1, complete: true, phase: name, status: 'passed', evidence: 'harmless-parent-death', descendantsObserved: identities.length, reaped: true };
        } else {
          result = await task.result; value = finalResult(result); demand(value.phase === mode, 'wrong-supervisor-phase');
          demand(value.status === (mode === 'preflight' ? 'passed' : mode === 'positive' ? 'observed-load-only' : 'expected-refusal'), 'unexpected-supervisor-status');
          if (mode !== 'preflight') demand(value.nativeSessionAttachment === false && value.memoryOperationsEnabled === false && value.childExit.code === 0 && value.childExit.signal === null, 'invalid-native-result');
        }
        demand(await gone([...tracked.values()]), 'residual-processes');
        unchanged(); demand(connections === 0, 'host-network-contact');
        report.phases.push({ ...value, cleanup: 'reaped', sandboxArgv: args }); save(reportPath, report);
        return value;
      } catch (error) {
        let observations = null;
        try { const failure = JSON.parse(result?.stderr.trim()); if (failure.schema === 1 && failure.complete === false) observations = failure.observations; } catch {}
        report.phases.push({ phase: name, status: 'failed', reason: error.message, observations });
        throw error;
      } finally {
        clearInterval(observer);
        if (task.child.exitCode === null && task.child.signalCode === null) { task.stop('phase-cleanup'); await task.result.catch(() => {}); }
        const residual = [...tracked.values()].filter(alive);
        if (residual.length) {
          report.cleanupFailure = residual.map(item => ({ pid: item.pid, start: item.start }));
          for (const identity of residual.reverse()) if (alive(identity)) { try { process.kill(identity.pid, 'SIGKILL'); } catch {} }
          report.fallbackCleanupReaped = await gone(residual);
        }
        active.delete(task);
        if (result) {
          try {
            demand(!residual.length || report.fallbackCleanupReaped, 'evidence-requires-reaped-processes');
            save(join(options.output, 'supervisor.stdout'), result.stdout); save(join(options.output, 'supervisor.stderr'), result.stderr);
            const names = ['supervisor.stdout', 'supervisor.stderr', ...(['positive', 'missing-channel', 'nested'].includes(mode) ? [`${mode}.stdout`, `${mode}.stderr`] : [])];
            const files = []; let unsafe = false;
            for (const name of names) {
              try { const checked = readEvidence(join(options.output, name)); files.push({ name, safe: true, bytes: checked.bytes }); }
              catch (error) {
                files.push({ name, safe: false, reason: error.code === 'ENOENT' ? 'not-produced' : error.message });
                if (value || error.code !== 'ENOENT') unsafe = true;
              }
            }
            (report.diagnostics ??= []).push({ phase: name, files });
            demand(!unsafe, 'unsafe-or-missing-diagnostic');
          }
          catch (error) { report.phases.push({ phase: name, status: 'failed', reason: error.message, evidence: 'host-output-save-refused' }); throw error; }
        }
      }
    }
    await launch('preflight');
    await launch('inner-supervisor-death', { mode: 'linger', death: 'inner' });
    await launch('outer-parent-death', { mode: 'linger', death: 'outer' });
    demand(!report.cleanupFailure, 'preflight-cleanup-failed');
    if (!preflightOnly) for (const phase of ['positive', 'missing-channel', 'nested']) await launch(phase);
    demand(!interrupted && !report.cleanupFailure, interrupted ?? 'cleanup-failed'); report.status = 'passed';
  } catch (error) { report.status = 'failed'; report.reason = error.message; }
  finally {
    clearTimeout(deadline); process.off('SIGTERM', onSignal); process.off('SIGINT', onSignal);
    if (server) await new Promise(resolveClose => server.close(resolveClose));
    if (socketServer) await new Promise(resolveClose => socketServer.close(resolveClose));
    report.finished = new Date().toISOString(); save(reportPath, report);
  }
  return { status: report.status, reason: report.reason, report: reportPath, phases: report.phases.map(({ phase, status }) => ({ phase, status })) };
}
if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  try {
    demand(process.argv.length === 2 || (process.argv.length === 3 && process.argv[2] === '--preflight-only'), 'fixed-arguments-only');
    const result = await runExperiment({ preflightOnly: process.argv[2] === '--preflight-only' });
    process.stdout.write(`${JSON.stringify(result)}\n`); if (result.status !== 'passed') process.exitCode = 1;
  } catch (error) { process.stderr.write(`${JSON.stringify({ status: 'failed', reason: error.message })}\n`); process.exitCode = 1; }
}
