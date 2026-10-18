import { spawn } from 'node:child_process';
import { chmodSync, existsSync, readFileSync, readlinkSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { connect } from 'node:net';
import { networkInterfaces } from 'node:os';
import { paths, privateDir, writePrivate, validateConfig } from '/component/src/config.mjs';
import { Store } from '/component/src/state.mjs';
import { ENV, FILES, SHARED, COMPONENT, PYTHON_FILES, PYTHON, LIMIT, PI_ARGS, TEXT, demand } from './policy.mjs';
import { runningArtifact } from '../pi-launch/identity.mjs';
import { runQualification } from './qualification.mjs';
import { fixtureServices } from './services.mjs';
const input = JSON.parse(readFileSync('/input/config.json', 'utf8'));
const mode = process.argv[2];
process.umask(0o077);
let driver, services, store;
const output = { schema: 1, complete: false, phase: mode, nativeExecuted: false, nativeLaunchAttempted: false, nativeExecutionEvidence: ['native', 'qualification'].includes(mode) ? 'not-observed' : 'not-requested', driverStarted: false };
function tty() {
  if (['native', 'qualification'].includes(mode)) output.nativeLaunchAttempted = true;
  const child = spawn(PYTHON, ['-I', '-S', '-B', '/pi-turn/pty.py', mode], { shell: false, env: { ...ENV }, stdio: ['pipe', 'pipe', 'pipe'] });
  child.once('spawn', () => { output.driverStarted = true; });
  const frames = []; let pending = ''; let bytes = 0; let failure = null; let text = ''; let stderr = '';
  child.stdout.on('data', data => {
    bytes += data.length;
    if (bytes > LIMIT.output) { failure ??= 'driver-output-overflow'; child.kill('SIGKILL'); return; }
    pending += data.toString('utf8');
    while (pending.includes('\n')) {
      const index = pending.indexOf('\n'); const line = pending.slice(0, index); pending = pending.slice(index + 1);
      try { const frame = JSON.parse(line); frames.push(frame); if (frame.type === 'output') text += Buffer.from(frame.data, 'base64').toString('utf8'); }
      catch { failure ??= 'invalid-driver-frame'; child.kill('SIGKILL'); }
    }
  });
  child.stderr.on('data', data => { stderr += data; if (stderr.length > 8192) { failure ??= 'driver-stderr-overflow'; child.kill('SIGKILL'); } });
  child.stdin.on('error', () => { failure ??= 'driver-input-error'; });
  const result = new Promise((resolve, reject) => { child.once('error', reject); child.once('close', (code, signal) => resolve({ code, signal })); });
  const write = text => child.stdin.write(`${JSON.stringify({ type: 'write', text })}\n`);
  return { child, frames, result, write, get text() { return text; }, check: () => demand(!failure, failure),
    stop: () => { if (!child.stdin.destroyed) child.stdin.end('{"type":"stop"}\n'); },
    diagnostics: () => ({ frames, stderr }) };
}
async function waitFor(predicate, reason, timeout = 12000) {
  const end = performance.now() + timeout;
  do { services?.check(); driver?.check(); if (predicate()) return; if (driver?.frames.some(frame => frame.type === 'exit')) throw new Error('pty-child-exited-before-condition'); await new Promise(resolve => setTimeout(resolve, 25)); } while (performance.now() < end);
  throw new Error(reason);
}
function events() {
  if (!existsSync('/work/private/events.jsonl')) return [];
  const raw = readFileSync('/work/private/events.jsonl', 'utf8'); demand(Buffer.byteLength(raw) <= 64 * 1024, 'event-output-limit');
  return raw.trim().split('\n').filter(Boolean).map(line => JSON.parse(line));
}
async function confinement() {
  const namespaces = {};
  for (const key of ['mnt', 'pid', 'net', 'ipc', 'uts', 'user']) {
    namespaces[key] = readlinkSync(`/proc/self/ns/${key}`); demand(namespaces[key] !== input.hostNamespaces[key], 'namespace-not-separated');
  }
  demand(Object.keys(process.env).sort().join() === Object.keys(ENV).sort().join(), 'unexpected-environment');
  for (const [key, value] of Object.entries(ENV)) demand(process.env[key] === value, 'unexpected-environment-value');
  // A prepared runtime alias creates empty ancestors under /home/fodurrr.
  // No host HOME directory is bound; only that exact runtime file is available.
  for (const path of [...input.hidden, '/run', ...(input.prepared ? ['/home/fodurrr/.ssh', '/home/fodurrr/.config'] : ['/home/fodurrr']), '/root/.ssh']) demand(!existsSync(path), 'host-path-exposed');
  const descriptors = readdirSync('/proc/self/fd').flatMap(fd => { try { return [{ fd: Number(fd), target: readlinkSync(`/proc/self/fd/${fd}`) }]; } catch { return []; } });
  demand(descriptors.find(fd => fd.fd === 0)?.target === '/dev/null', 'stdin-not-null');
  for (const fd of descriptors) demand(!input.hidden.some(path => fd.target.includes(path)), 'host-fd-exposed');
  let readonly = false;
  try { writeFileSync('/input/readonly-sentinel', 'bad'); } catch (error) { readonly = ['EROFS', 'EACCES'].includes(error.code); }
  demand(readonly, 'readonly-bind-writable');
  const mounts = readFileSync('/proc/self/mountinfo', 'utf8').trim().split('\n').map(line => line.split(' '));
  for (const path of ['/pi', '/runtime/node', '/input/config.json', PYTHON, ...PYTHON_FILES, ...FILES.map(file => `/pi-turn/${file}`), ...SHARED.map(file => `/pi-launch/${file}`), ...COMPONENT.map(file => `/component/${file}`)]) {
    demand(mounts.some(fields => fields[4] === path && fields[5].split(',').includes('ro')), 'mounted-resource-not-readonly');
  }
  demand(Object.entries(networkInterfaces()).flatMap(([name, values]) => name === 'lo' ? [] : values).length === 0, 'external-interface');
  await new Promise((resolve, reject) => {
    const socket = connect({ host: '127.0.0.1', port: input.hostPort });
    socket.setTimeout(500, () => { socket.destroy(); reject(new Error('host-probe-timeout')); });
    socket.once('connect', () => { socket.destroy(); reject(new Error('host-network-reachable')); });
    socket.once('error', error => ['ECONNREFUSED', 'ENETUNREACH', 'EHOSTUNREACH'].includes(error.code) ? resolve() : reject(error));
  });
  services = await fixtureServices({ qualification: mode === 'qualification' });
  for (const endpoint of [services.provider, services.memory]) {
    const response = await fetch(`${endpoint}/health`, { signal: AbortSignal.timeout(500) }); demand(response.ok, 'same-netns-service-unreachable');
  }
  return { namespaces, descriptors, hidden: true, readonly: true, sameNetnsEndpoints: true, hostLoopback: 'unreachable' };
}
function wrapper() {
  return `import {appendFileSync,statSync} from 'node:fs';
import {piFromDescriptor} from '/component/adapters/pi.mjs';
const record=(type,event,ctx)=>{const file='/work/private/events.jsonl';if(statSync(file).size>65536)throw new Error('event-limit');appendFileSync(file,JSON.stringify({type,session:ctx.sessionManager.getSessionId(),...event})+'\\n');};
export default function(pi){
pi.on('session_start',(e,c)=>record('session_start',{reason:e.reason},c));
pi.on('ui_prompt_start',(e,c)=>record('ui_prompt_start',{kind:e.kind,title:e.title},c));
piFromDescriptor('/work/private/descriptor.json',import.meta.url)(pi);
pi.on('input',(e,c)=>record('input',{source:e.source,text:e.text},c));
pi.on('before_agent_start',(e,c)=>record('before_agent_start',{messageType:e.messageType,prompt:e.prompt},c));
pi.on('turn_end',(e,c)=>record('turn_end',{id:e.messageEntryId,stopReason:e.message.stopReason,text:e.message.content.filter(x=>x.type==='text').map(x=>x.text).join('\\n')},c));
pi.on('agent_settled',(e,c)=>record('agent_settled',{aborted:e.aborted,entries:c.sessionManager.getBranch().filter(x=>x.type==='message'&&['user','assistant'].includes(x.message.role)).map(x=>({id:x.id,role:x.message.role,text:typeof x.message.content==='string'?x.message.content:x.message.content.filter(p=>p.type==='text').map(p=>p.text).join('\\n'),stopReason:x.message.stopReason}))},c));
}`;
}
function prepareNative() {
  chmodSync('/work', 0o700); privateDir('/work/private'); writePrivate('/work/private/events.jsonl', '');
  const p = paths(); privateDir(p.config); writePrivate(`${p.config}/secret`, 'synthetic-secret');
  const config = validateConfig({ schema_version: 1, endpoint: services.memory, bank: 'synthetic', secret_file: `${p.config}/secret`, adapters: ['pi'], capture: true });
  writePrivate(`${p.config}/config.json`, JSON.stringify(config)); store = new Store(p); store.activate(config); // Existing isolated test seam only.
  const identity = path => { const s = statSync(path); return { path, requested: path, dev: s.dev, ino: s.ino, size: s.size, mtimeMs: s.mtimeMs }; };
  writePrivate('/work/private/descriptor.json', JSON.stringify({ schema_version: 1, runtime: '/runtime/node', cli: '/component/src/cli.mjs', owner: 'isolated-pi-turn', agentVersion: '1.3.0',
    bridge_path: '/work/sole-bridge.mjs',
    agent_identity: identity('/pi/pi'), runtime_identity: identity('/runtime/node') }));
  writePrivate('/work/sole-bridge.mjs', wrapper());
  // Exact provider/settings configuration is pinned to inspected source; never activate a provider extension.
  writePrivate('/agent/models.json', JSON.stringify({ providers: { loopback: { baseUrl: `${services.provider}/v1`, api: 'openai-completions', apiKey: 'fixture-only', models: [{ id: 'fixture', maxTokens: 64 }] } } }));
  writePrivate('/agent/settings.json', JSON.stringify(input.piSettings));
  output.nativePreparation = Object.fromEntries(['/agent', '/agent/models.json', '/agent/settings.json']
    .map(path => [path, statSync(path).mode & 0o777]));
}
async function native() {
  prepareNative();
  driver = tty();
  await waitFor(() => {
    const frame = driver.frames.find(frame => frame.type === 'pty-child');
    if (!frame) return false;
    try {
      const live = runningArtifact(frame.pid); const selected = statSync('/pi/pi');
      if (live.artifact.sha256 !== input.piArtifact || live.artifact.dev !== selected.dev || live.artifact.ino !== selected.ino || live.ppid !== driver.child.pid) return false;
      output.nativeExecuted = true; output.nativeExecutionEvidence = 'exact-elf-observed'; output.nativeProcess = live; return true;
    } catch { return false; }
  }, 'native-executable-not-observed');
  await waitFor(() => events().some(e => e.type === 'session_start' && e.reason === 'startup'), 'native-startup-not-observed');
  driver.write(`${TEXT.history}\r`);
  await waitFor(() => events().some(e => e.type === 'agent_settled'), 'history-turn-not-settled');
  demand(store.db.prepare('SELECT count(*) n FROM jobs').get().n === 0 && store.db.prepare('SELECT count(*) n FROM sessions').get().n === 0 && services.evidence.recalls.length === 0, 'preconsent-memory-activity');
  driver.write('/new\r');
  await waitFor(() => events().some(e => e.type === 'ui_prompt_start' && e.kind === 'confirm' && e.title === 'Personal Hindsight memory') && driver.text.includes(services.memory), 'actual-consent-ui-not-observed');
  driver.write(input.consentKeys);
  await waitFor(() => store.db.prepare('SELECT count(*) n FROM sessions').get().n === 1, 'consent-registration-not-observed');
  driver.write(`${TEXT.prompt}\r`);
  await waitFor(() => events().filter(e => e.type === 'agent_settled').length === 2, 'native-target-not-settled');
  await waitFor(() => store.db.prepare("SELECT count(*) n FROM jobs WHERE state='completed'").get().n === 2, 'durable-delivery-not-completed', 15000);
  const observed = events(); const final = observed.filter(e => e.type === 'agent_settled').at(-1);
  const end = observed.filter(e => e.type === 'turn_end').at(-1);
  demand(final.aborted === false && final.entries.length === 2 && final.entries[0].role === 'user' && final.entries[0].text === TEXT.prompt &&
    final.entries[1].role === 'assistant' && final.entries[1].text === TEXT.final && final.entries[1].id === end.id && end.stopReason === 'stop', 'native-persisted-pair-mismatch');
  demand(services.evidence.provider.length === 2 && services.evidence.recalls.length === 1 && services.evidence.retains.length === 2 && services.evidence.completed.length === 2 && services.evidence.profile === 2, 'native-service-count-mismatch');
  demand(store.db.prepare('SELECT count(*) n FROM staged').get().n === 0, 'native-stage-left-pending');
  output.nativeEvents = observed; output.services = services.evidence; output.argv = PI_ARGS;
}
try {
  output.confinement = await confinement();
  if (mode === 'qualification') {
    const value = await runQualification({ input, output, services, tty: () => (driver = tty()), waitFor, setStore: value => (store = value) }); store = value.store; driver = value.driver;
  } else if (mode === 'native') await native();
  else {
    // Exercise the real native setup without importing or starting a native client.
    if (mode === 'preflight') prepareNative();
    driver = tty();
    await waitFor(() => driver.text.includes('SURROGATE_TTY_READY'), 'surrogate-not-ready');
    if (mode === 'linger') {
      process.stdout.write('{"type":"helper-ready"}\n'); await new Promise(resolve => setTimeout(resolve, 60000)); throw new Error('death-preflight-not-killed');
    }
    if (mode === 'preflight') { driver.write('harmless-script\r'); await waitFor(() => driver.text.includes('SURROGATE_SCRIPT_OK'), 'surrogate-script-failed'); }
    else {
      const result = await driver.result; const expected = mode === 'deadline' ? 'pty-deadline' : 'pty-output-overflow';
      demand(result.code === 1 && driver.frames.some(frame => frame.type === 'exit' && frame.failure === expected && frame.reaped), 'expected-pty-failure-not-observed');
      output.expectedFailure = expected;
    }
  }
  services.check(); output.complete = true; output.status = 'passed';
} catch (error) { output.reason = error.message; output.status = 'failed'; process.exitCode = 1; }
finally {
  if (driver) {
    driver.stop(); const result = await driver.result;
    writeFileSync('/output/terminal.json', JSON.stringify(driver.diagnostics()), { mode: 0o600 });
    output.driverExit = result; output.ptyExit = driver.frames.findLast(frame => frame.type === 'exit') ?? null;
    if (!driver.frames.some(frame => frame.type === 'exit' && frame.reaped)) { output.complete = false; output.status = 'failed'; output.reason ??= 'pty-child-not-reaped'; process.exitCode = 1; }
  }
  store?.close(); if (services) await services.close();
}
process.stdout.write(`${JSON.stringify(output)}\n`);
