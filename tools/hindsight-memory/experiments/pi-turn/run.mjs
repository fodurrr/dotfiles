import { execFileSync } from 'node:child_process';
import { chmodSync, mkdirSync, mkdtempSync, readFileSync, readlinkSync, realpathSync } from 'node:fs';
import { createServer } from 'node:net';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { LIBRARIES, digestFile, manifest, verifyPins } from '../pi-launch/policy.mjs';
import { alive, boundedSpawn, finalResult, gone, ownedTree } from '../pi-launch/processes.mjs';
import { savePrivate as save, readEvidence } from '../pi-launch/safe-output.mjs';
import { ENV, FILES, SHARED, COMPONENT, PYTHON, PYTHON_FILES, PYTHON_LIBRARIES, LIMIT, PIN, demand, sandboxArgs } from './policy.mjs';
const HERE = dirname(fileURLToPath(import.meta.url));
const GIT_ENV = { PATH: '/usr/bin:/bin', HOME: '/nonexistent', GIT_CONFIG_GLOBAL: '/dev/null', GIT_CONFIG_SYSTEM: '/dev/null', GIT_OPTIONAL_LOCKS: '0' };
export function sourceCheckout(location = HERE) {
  const git = args => execFileSync('/usr/bin/git', ['-C', location, ...args], { env: GIT_ENV, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], timeout: 2000 }).trim();
  let root; try { root = git(['rev-parse', '--show-toplevel']); } catch { throw new Error('source-checkout-required'); }
  demand(realpathSync(location) === realpathSync(join(root, 'tools/hindsight-memory/experiments/pi-turn')), 'source-checkout-required');
  return { root, commit: git(['rev-parse', 'HEAD']), dirty: Boolean(git(['status', '--porcelain', '--untracked-files=all', '--', 'tools/hindsight-memory'])) };
}
function privateDirectory(path) { mkdirSync(path, { mode: 0o700 }); chmodSync(path, 0o700); }
async function ready(child) {
  return new Promise((resolve, reject) => {
    let text = ''; const timer = setTimeout(() => finish(new Error('death-readiness-timeout')), 10000);
    const onData = data => { text += data; if (text.length > 4096) return finish(new Error('death-readiness-overflow')); if (text.includes('\n')) { try { const value = JSON.parse(text.trim()); demand(['helper-ready', 'death-parent-ready'].includes(value.type), 'wrong-death-readiness'); finish(); } catch (error) { finish(error); } } };
    const onClose = () => finish(new Error('death-helper-closed'));
    function finish(error) { clearTimeout(timer); child.stdout.off('data', onData); child.off('close', onClose); error ? reject(error) : resolve(); }
    child.stdout.on('data', onData); child.once('close', onClose);
  });
}
export async function runExperiment({ native = false } = {}) {
  demand(!native || (process.argv.length === 3 && process.argv[2] === '--native'), 'explicit-native-flag-required');
  demand(process.platform === 'linux' && process.arch === 'x64' && process.version === 'v24.22.0' && realpathSync(process.execPath) === realpathSync(PIN.runtime), 'exact-node-runtime-required');
  const checkout = sourceCheckout(); demand(!native || !checkout.dirty, 'native-requires-clean-committed-source');
  process.umask(0o077); const root = mkdtempSync('/var/tmp/hindsight-pi-turn-'); chmodSync(root, 0o700);
  const reportPath = join(root, 'report.json');
  const report = { schema: 1, status: 'running', root, commit: checkout.commit, sourceDirty: checkout.dirty, nativeRequested: native, nativeExecuted: false, nativeLaunchAttempted: false, nativeExecutionEvidence: native ? 'not-observed' : 'not-requested',
    productionActivation: 'unchanged-and-blocked', started: new Date().toISOString(), limits: LIMIT, phases: [], diagnostics: [] };
  let server, sockets, interrupted = null; const active = new Set();
  const stop = reason => { interrupted ??= reason; for (const task of active) task.stop(reason); };
  const signal = () => stop('runner-interrupted'); process.once('SIGINT', signal); process.once('SIGTERM', signal);
  const timer = setTimeout(() => stop('overall-timeout'), LIMIT.overall);
  try {
    const pins = verifyPins();
    demand(execFileSync('/usr/bin/bwrap', ['--version'], { env: {}, encoding: 'utf8', timeout: 2000 }).trim() === 'bubblewrap 0.11.1', 'bwrap-version-mismatch');
    const files = [...FILES.map(file => join(HERE, file)), join(HERE, 'run.mjs'), join(HERE, 'test.mjs'), join(HERE, 'death-parent.mjs'),
      ...SHARED.map(file => join(HERE, '../pi-launch', file)), ...COMPONENT.map(file => join(HERE, '../..', file)), PIN.runtime, PYTHON, ...PYTHON_FILES,
      ...[...LIBRARIES, ...PYTHON_LIBRARIES].map(file => realpathSync(`/lib/x86_64-linux-gnu/${file}`))];
    const fingerprints = files.map(path => ({ path, identity: digestFile(path) }));
    const packageManifest = manifest(PIN.package); const experimentManifest = manifest(HERE);
    const unchanged = () => {
      demand(manifest(PIN.package).digest === packageManifest.digest, 'pi-package-drift');
      demand(manifest(HERE).digest === experimentManifest.digest, 'experiment-drift');
      for (const item of fingerprints) demand(JSON.stringify(digestFile(item.path)) === JSON.stringify(item.identity), 'mounted-file-drift');
    };
    save(join(root, 'manifest.json'), { fingerprints, packageManifest, experimentManifest, pins });
    let contacts = 0;
    server = createServer(socket => { contacts++; socket.destroy(); });
    await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
    const sentinel = join(root, 'host-only-sentinel'); save(sentinel, 'host-only');
    const socketPath = join(root, 'host-only.sock'); sockets = createServer(socket => socket.destroy());
    await new Promise((resolve, reject) => { sockets.once('error', reject); sockets.listen(socketPath, resolve); });
    // Pinned extension-selector.ts accepts literal LF; initial Yes is selected.
    const config = { piArtifact: PIN.artifact, hostPort: server.address().port, hidden: [sentinel, socketPath, checkout.root],
      hostNamespaces: Object.fromEntries(['mnt', 'pid', 'net', 'ipc', 'uts', 'user'].map(key => [key, readlinkSync(`/proc/self/ns/${key}`)])),
      piSettings: { defaultProvider: 'loopback', defaultModel: 'fixture', enabledModels: ['loopback/fixture'], defaultTools: [], enableInstallTelemetry: false, cacheWarming: 'off',
        retry: { enabled: false, maxRetries: 0, provider: { timeoutMs: 5000, maxRetries: 0 } } }, consentKeys: '\n' };
    async function launch(name, { mode = name, death = null } = {}) {
      demand(!interrupted, interrupted); unchanged();
      const output = join(root, name); privateDirectory(output); save(join(output, 'readonly-sentinel'), 'read-only');
      const input = join(root, `${name}-input.json`); save(input, config);
      const options = { experiment: HERE, output, input, mode }; const args = sandboxArgs(options);
      let command = '/usr/bin/bwrap', argv = args;
      if (death === 'outer') { const parent = join(root, 'death-parent.json'); save(parent, options); command = PIN.runtime; argv = [join(HERE, 'death-parent.mjs'), parent]; }
      if (mode === 'native') { report.nativeLaunchAttempted = true; save(reportPath, report); }
      const task = boundedSpawn(command, argv, { timeout: LIMIT.process }); active.add(task);
      const tracked = new Map(); const collect = () => { if (task.child.pid) for (const identity of ownedTree(task.child.pid)) tracked.set(`${identity.pid}:${identity.start}`, identity); };
      const observer = setInterval(collect, 10); collect(); let result, supervisorValue;
      try {
        let value;
        if (death) {
          await ready(task.child); await new Promise(resolve => setTimeout(resolve, 50)); collect();
          const ids = [...tracked.values()]; demand(ids.length >= (death === 'outer' ? 5 : 4), 'death-descendants-not-observed');
          const target = death === 'outer' ? ids.find(id => id.pid === task.child.pid) : ids.find(id => { try { return readFileSync(`/proc/${id.pid}/cmdline`, 'utf8').includes('/pi-turn/supervisor.mjs\0linger'); } catch { return false; } });
          demand(target && alive(target), 'death-supervisor-not-observed'); process.kill(target.pid, 'SIGKILL'); result = await task.result;
          demand(!result.failure, result.failure); demand(await gone(ids), 'death-left-descendants');
          value = { schema: 1, complete: true, phase: name, status: 'passed', nativeExecuted: false, descendantsObserved: ids.length, reaped: true };
        } else {
          result = await task.result;
          try { supervisorValue = JSON.parse(result.stdout.trim()); } catch {}
          if (mode === 'native') { report.nativeExecuted = supervisorValue?.nativeExecuted === true; report.nativeExecutionEvidence = report.nativeExecuted ? 'exact-elf-observed' : 'not-observed'; }
          if (supervisorValue?.schema === 1 && supervisorValue.complete === false && typeof supervisorValue.reason === 'string') throw new Error(supervisorValue.reason);
          value = finalResult(result); demand(value.phase === mode && value.status === 'passed', 'unexpected-phase-result');
          demand(value.nativeExecuted === (mode === 'native'), 'unexpected-native-execution-state');
        }
        demand(await gone([...tracked.values()]), 'residual-descendants'); unchanged(); demand(contacts === 0, 'host-network-contact');
        if (mode === 'native') demand(report.nativeExecuted, 'native-execution-not-observed');
        report.phases.push({ ...value, cleanup: 'reaped', sandboxArgv: args }); save(reportPath, report);
      } catch (error) { report.phases.push({ phase: name, status: 'failed', reason: error.message, supervisor: supervisorValue ?? null }); throw error; }
      finally {
        clearInterval(observer);
        if (task.child.exitCode === null && task.child.signalCode === null) { task.stop('phase-cleanup'); await task.result.catch(() => {}); }
        const residual = [...tracked.values()].filter(alive);
        if (residual.length) { report.cleanupFailure = residual; for (const id of residual.reverse()) if (alive(id)) { try { process.kill(id.pid, 'SIGKILL'); } catch {} } report.fallbackCleanupReaped = await gone(residual); }
        active.delete(task);
        demand(!residual.length || report.fallbackCleanupReaped, 'cleanup-incomplete');
        if (result) {
          save(join(output, 'supervisor.stdout'), result.stdout); save(join(output, 'supervisor.stderr'), result.stderr);
          for (const file of ['supervisor.stdout', 'supervisor.stderr', ...(supervisorValue?.driverStarted ? ['terminal.json'] : [])]) {
            const checked = readEvidence(join(output, file)); report.diagnostics.push({ phase: name, file, bytes: checked.bytes, safe: true });
          }
        }
      }
    }
    await launch('preflight'); await launch('deadline'); await launch('overflow');
    await launch('inner-supervisor-death', { mode: 'linger', death: 'inner' });
    await launch('outer-parent-death', { mode: 'linger', death: 'outer' });
    demand(!report.cleanupFailure && !interrupted, interrupted ?? 'cleanup-failed');
    if (native) await launch('native');
    demand(!report.cleanupFailure && !interrupted, interrupted ?? 'cleanup-failed'); report.status = 'passed';
  } catch (error) { report.status = 'failed'; report.reason = error.message; }
  finally {
    clearTimeout(timer); process.off('SIGINT', signal); process.off('SIGTERM', signal);
    if (server) await new Promise(resolve => server.close(resolve)); if (sockets) await new Promise(resolve => sockets.close(resolve));
    report.finished = new Date().toISOString(); save(reportPath, report);
  }
  return { status: report.status, reason: report.reason, report: reportPath, nativeExecuted: report.nativeExecuted, phases: report.phases.map(({ phase, status }) => ({ phase, status })) };
}
if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  try {
    demand(process.argv.length === 2 || (process.argv.length === 3 && ['--preflight-only', '--native'].includes(process.argv[2])), 'fixed-arguments-only');
    const result = await runExperiment({ native: process.argv[2] === '--native' }); process.stdout.write(`${JSON.stringify(result)}\n`); if (result.status !== 'passed') process.exitCode = 1;
  } catch (error) { process.stderr.write(`${JSON.stringify({ status: 'failed', reason: error.message })}\n`); process.exitCode = 1; }
}
