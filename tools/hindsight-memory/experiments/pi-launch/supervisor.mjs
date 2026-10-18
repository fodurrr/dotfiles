import { randomBytes } from 'node:crypto';
import { spawn } from 'node:child_process';
import { existsSync, readFileSync, readlinkSync, readdirSync, writeFileSync } from 'node:fs';
import { connect } from 'node:net';
import { networkInterfaces } from 'node:os';
import { channel, claimProtocol } from './channel.mjs';
import { processIdentity, runningArtifact } from './identity.mjs';
import { ENV, FILES, LIMIT, PIN, PI_ARGS, demand, digestFile, manifest } from './policy.mjs';

const config = JSON.parse(readFileSync('/input/config.json', 'utf8'));
const mode = process.argv[2];
process.umask(0o077);
let observationRecord = { hello: false, ack: false, done: false };
let claimRecord = null;

function packageCheck() {
  demand(digestFile('/pi/pi').sha256 === PIN.artifact && digestFile('/pi/package.json').sha256 === PIN.sidecar, 'mounted-pin-mismatch');
  demand(manifest('/pi').digest === config.packageManifest, 'package-resource-drift');
  for (const file of FILES) demand(digestFile(`/experiment/${file}`).sha256 === config.sources[file], 'experiment-resource-drift');
  demand(JSON.stringify(digestFile('/runtime/node')) === JSON.stringify(config.runtime), 'supervisor-runtime-drift');
}
async function preflight() {
  const namespaces = {};
  for (const key of ['mnt', 'pid', 'net']) {
    namespaces[key] = readlinkSync(`/proc/self/ns/${key}`); demand(namespaces[key] !== config.hostNamespaces[key], 'namespace-not-separated');
  }
  demand(process.cwd() === '/work' && process.env.HOME === ENV.HOME, 'wrong-sandbox-environment');
  demand(Object.keys(process.env).sort().join() === Object.keys(ENV).sort().join(), `unexpected-environment-key:${Object.keys(process.env).filter(key => !(key in ENV)).join(',')}`);
  for (const [key, value] of Object.entries(ENV)) demand(process.env[key] === value, 'unexpected-environment-value');
  for (const path of [...config.hidden, '/run', '/home/fodurrr', '/root/.ssh']) demand(!existsSync(path), 'host-path-exposed');
  const descriptors = [];
  for (const fd of readdirSync('/proc/self/fd')) {
    let target;
    try { target = readlinkSync(`/proc/self/fd/${fd}`); } catch (error) { if (error.code === 'ENOENT') continue; throw error; }
    demand(!config.hidden.some(path => target.includes(path)), 'host-descriptor-inherited');
    descriptors.push({ fd: Number(fd), target });
  }
  demand(descriptors.find(item => item.fd === 0)?.target === '/dev/null', 'stdin-not-dev-null');
  let readonly = false;
  try { writeFileSync('/input/readonly-sentinel', 'modified'); } catch (error) { readonly = ['EROFS', 'EACCES'].includes(error.code); }
  demand(readonly, 'readonly-bind-writable');
  const mounts = readFileSync('/proc/self/mountinfo', 'utf8').trim().split('\n').map(line => line.split(' '));
  for (const path of ['/pi', '/runtime/node', '/input/config.json', ...FILES.map(file => `/experiment/${file}`)]) {
    demand(mounts.some(fields => fields[4] === path && fields[5].split(',').includes('ro')), 'mount-not-readonly');
  }
  const external = Object.entries(networkInterfaces()).flatMap(([name, values]) => name === 'lo' ? [] : values);
  demand(external.length === 0, 'unexpected-network-interface');
  await new Promise((resolve, reject) => {
    const socket = connect({ host: '127.0.0.1', port: config.hostPort });
    socket.setTimeout(500, () => { socket.destroy(); reject(new Error('network-probe-timeout')); });
    socket.once('connect', () => { socket.destroy(); reject(new Error('host-network-reachable')); });
    socket.once('error', error => { if (['ECONNREFUSED', 'ENETUNREACH', 'EHOSTUNREACH'].includes(error.code)) resolve(); else reject(error); });
  });
  packageCheck();
  writeFileSync('/agent/settings.json', JSON.stringify({ enableInstallTelemetry: false }), { mode: 0o600 });
  return { schema: 1, complete: true, phase: mode, status: 'passed', namespaces, descriptors, environmentKeys: Object.keys(ENV), hidden: true, readonly: true, network: 'host-fixture-unreachable' };
}

async function native() {
  demand(['positive', 'missing-channel', 'nested'].includes(mode), 'unknown-native-phase');
  packageCheck();
  writeFileSync('/agent/settings.json', JSON.stringify({ enableInstallTelemetry: false }), { mode: 0o600 });
  const args = [...PI_ARGS]; if (mode === 'nested') args[args.indexOf('/experiment/probe.mjs')] = '/experiment/probe-nested.mjs';
  const child = spawn('/pi/pi', args, { shell: false, env: { ...ENV }, stdio: ['ignore', 'pipe', 'pipe', ...(mode === 'missing-channel' ? [] : ['pipe'])] });
  let failed = null, wire, protocol; const outputs = { stdout: [], stderr: [] }; let bytes = 0;
  const timer = setTimeout(() => { failed ??= 'process-timeout'; child.kill('SIGKILL'); }, LIMIT.process);
  for (const key of ['stdout', 'stderr']) {
    child[key].on('data', data => {
      bytes += data.length;
      if (bytes > LIMIT.output) { failed ??= 'output-overflow'; child.kill('SIGKILL'); }
      else outputs[key].push(data);
    });
    child[key].on('error', () => { failed ??= 'output-error'; child.kill('SIGKILL'); });
  }
  const exit = new Promise((resolve, reject) => { child.once('error', reject); child.once('close', (code, signal) => resolve({ code, signal })); });
  child.once('spawn', () => {
    try {
      if (mode === 'missing-channel') return;
      const childID = processIdentity(child.pid); const own = processIdentity(process.pid);
      const expected = { pid: child.pid, start: childID.start, version: PIN.version, artifact: PIN.artifact, invocation: randomBytes(32).toString('hex') };
      claimRecord = { ...expected, supervisor: { pid: own.pid, start: own.start } };
      protocol = claimProtocol({ expected, supervisor: { pid: own.pid, start: own.start },
        verify: async () => {
          const live = runningArtifact(child.pid);
          demand(live.start === expected.start && live.ppid === process.pid && live.artifact.sha256 === PIN.artifact && live.artifact.size === PIN.size
            && live.artifact.dev === config.binary.dev && live.artifact.ino === config.binary.ino, 'running-artifact-mismatch');
          packageCheck();
          demand(processIdentity(child.pid).start === expected.start, 'process-changed');
        }, send: value => wire.send(value), end: () => wire.end() });
      observationRecord = protocol.observations;
      wire = channel(child.stdio[3], value => protocol.receive(value), { onFailure: error => { failed ??= error.message; } });
    } catch (error) { failed ??= error.message; child.kill('SIGKILL'); }
  });
  let outcome;
  try {
    outcome = await exit;
    if (wire) { try { await wire.closed; protocol.finish(); } catch (error) { failed ??= error.message; } }
    packageCheck();
  } finally { clearTimeout(timer); if (child.exitCode === null && child.signalCode === null) child.kill('SIGKILL'); }
  for (const key of ['stdout', 'stderr']) writeFileSync(`/output/${mode}.${key}`, Buffer.concat(outputs[key]), { mode: 0o600 });
  const observations = protocol?.observations ?? { hello: false, ack: false, done: false };
  const stderr = Buffer.concat(outputs.stderr).toString('utf8');
  const clean = outcome.code === 0 && outcome.signal === null;
  let status;
  if (mode === 'positive') { demand(clean && !failed && observations.done, failed ?? 'native-positive-failed'); status = 'observed-load-only'; }
  if (mode === 'missing-channel') {
    demand(clean && !failed && !observations.ack && stderr.includes('"status":"probe-refused"'), 'missing-channel-not-proven'); status = 'expected-refusal';
  }
  if (mode === 'nested') {
    demand(clean && failed === 'caller-mismatch' && !observations.ack && stderr.includes('nested-child-refused'), 'nested-refusal-not-proven'); status = 'expected-refusal';
  }
  return { schema: 1, complete: true, phase: mode, status, observations, claim: claimRecord, reason: failed, childExit: outcome, argv: args, bytes,
    evidence: 'actual-isolated-native-factory-only', memoryOperationsEnabled: false,
    memoryEvidence: 'probe-imports-no-core;no-service-state-mounted;separate-network-namespace', nativeSessionAttachment: false };
}

try {
  let result;
  if (mode === 'preflight') result = await preflight();
  else if (mode === 'linger') {
    const child = spawn('/runtime/node', ['/experiment/child.mjs', 'linger'], { env: {}, stdio: 'ignore', shell: false });
    await new Promise((resolve, reject) => { child.once('spawn', resolve); child.once('error', reject); });
    process.stdout.write(`${JSON.stringify({ type: 'helper-ready', pid: process.pid, child: child.pid })}\n`);
    await new Promise(resolve => setTimeout(resolve, 60000)); throw new Error('helper-not-killed');
  } else result = await native();
  process.stdout.write(`${JSON.stringify(result)}\n`);
} catch (error) {
  process.stderr.write(`${JSON.stringify({ schema: 1, complete: false, phase: mode, reason: error.message, observations: observationRecord, claim: claimRecord })}\n`); process.exitCode = 1;
}
