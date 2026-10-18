import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { duplexPair } from 'node:stream';
import { mkdtempSync, mkdirSync, chmodSync, writeFileSync, readFileSync, rmSync, symlinkSync, unlinkSync, linkSync } from 'node:fs';
import { createServer } from 'node:http';
import { once } from 'node:events';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { channel, claimProtocol } from './channel.mjs';
import { ENV, FILES, LIMIT, PIN, PI_ARGS, digestFile, manifest, sandboxArgs } from './policy.mjs';
import { processIdentity, runningArtifact } from './identity.mjs';
import { boundedSpawn, finalResult } from './processes.mjs';
import { probeChannel } from './transport.mjs';
import { sessionGate } from './gate.mjs';
import { sourceCheckout, runExperiment } from './run.mjs';
import { createPiAdapter } from '../../adapters/pi.mjs';
import { savePrivate, readEvidence } from './safe-output.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const expected = { pid: 101, start: '123', version: '1.3.0', invocation: 'a'.repeat(64), artifact: PIN.artifact };
const supervisor = { pid: 99, start: '122' };
const hello = () => ({ type: 'HELLO', v: 1, pid: expected.pid, start: expected.start, version: expected.version });
const done = () => ({ type: 'DONE', v: 1, pid: expected.pid, start: expected.start, invocation: expected.invocation, artifact: expected.artifact });
function protocol(verify = async () => {}) {
  const sent = []; let ended = false;
  return { sent, get ended() { return ended; }, protocol: claimProtocol({ expected, supervisor, verify, send: value => sent.push(value), end: () => { ended = true; } }) };
}

test('synthetic protocol: one HELLO/ACK/DONE succeeds, with no lasting capability', async () => {
  const p = protocol(); await p.protocol.receive(hello()); await p.protocol.receive(done()); p.protocol.finish();
  assert.equal(p.sent.length, 1); assert.equal(p.sent[0].type, 'ACK'); assert.equal(p.ended, true);
});
test('synthetic protocol: duplicate claim while identity verification waits cannot get ACK', async () => {
  let release; const p = protocol(() => new Promise(resolve => { release = resolve; }));
  const pending = p.protocol.receive(hello()); await assert.rejects(p.protocol.receive(hello()), /duplicate-claim/);
  release(); await assert.rejects(pending, /duplicate-claim/); assert.equal(p.sent.length, 0); assert.throws(() => p.protocol.finish());
});
test('synthetic protocol: post-DONE replay invalidates the final result, retaining earlier observations', async () => {
  const p = protocol(); await p.protocol.receive(hello()); await p.protocol.receive(done());
  await assert.rejects(p.protocol.receive(hello()), /duplicate-claim/); assert.throws(() => p.protocol.finish());
  assert.deepEqual(p.protocol.observations, { hello: true, ack: true, done: true });
});
for (const [name, mutate] of [
  ['different PID', value => ({ ...value, pid: 202 })], ['wrong version', value => ({ ...value, version: '1.1.0' })],
  ['unknown fields', value => ({ ...value, arbitrary: true })], ['wrong start', value => ({ ...value, start: '999' })],
]) test(`synthetic protocol: ${name} rejects before ACK`, async () => {
  const p = protocol(); await assert.rejects(p.protocol.receive(mutate(hello()))); assert.equal(p.sent.length, 0); assert.throws(() => p.protocol.finish());
});
test('synthetic protocol: failed executable verification and premature complete EOF do not pass', async () => {
  const p = protocol(async () => { throw new Error('running-artifact-mismatch'); });
  await assert.rejects(p.protocol.receive(hello()), /running-artifact-mismatch/); assert.throws(() => p.protocol.finish()); assert.equal(p.sent.length, 0);
  const pending = protocol(); await pending.protocol.receive(hello()); assert.throws(() => pending.protocol.finish(), /incomplete-handshake/);
});
test('synthetic protocol: a failed ACK send is not reported as queued acknowledgement', async () => {
  const p = claimProtocol({ expected, supervisor, verify: async () => {}, send: () => { throw new Error('stream-failed'); }, end: () => {} });
  await assert.rejects(p.receive(hello()), /stream-failed/); assert.equal(p.observations.ack, false); assert.throws(() => p.finish());
});
test('synthetic framing: ordinary fragmentation and expected clean EOF work', async () => {
  const [a, b] = duplexPair(); const received = [];
  const wire = channel(a, value => received.push(value), { timeout: 1000 });
  a.once('end', () => a.destroy()); b.resume();
  b.write('{"typ'); b.write('e":"fixture"}\n'); b.end(); a.end();
  await wire.closed; assert.deepEqual(received, [{ type: 'fixture' }]);
});
for (const [name, bytes, pattern] of [
  ['partial EOF', '{"type":', /incomplete-frame/], ['bad JSON', '{bad}\n', /JSON/],
  ['oversized frame', 'x'.repeat(LIMIT.frame), /frame-overflow/], ['invalid UTF8', Buffer.from([0xff, 10]), /encoded data/],
]) test(`synthetic framing: ${name} fails`, async () => {
  const [a, b] = duplexPair(); const wire = channel(a, () => {}, { timeout: 1000 }); b.end(bytes); a.end();
  await assert.rejects(wire.closed, pattern); b.destroy();
});
test('synthetic framing: missing response reaches the bounded handshake deadline', async () => {
  const [a, b] = duplexPair(); const wire = channel(a, () => {}, { timeout: 30 });
  await assert.rejects(wire.closed, /handshake-timeout/); b.destroy();
});
test('synthetic process: opened live Node executable cannot qualify from selected Pi metadata', async () => {
  const live = runningArtifact(process.pid);
  assert.equal(live.artifact.sha256, digestFile(process.execPath).sha256); assert.notEqual(live.artifact.sha256, PIN.artifact);
  const [a, b] = duplexPair(); let buffer = '';
  b.on('data', bytes => {
    buffer += bytes; if (!buffer.includes('\n')) return;
    const value = JSON.parse(buffer.trim()); buffer = '';
    b.end(`${JSON.stringify({ type: 'ACK', v: 1, pid: value.pid, start: value.start, invocation: 'b'.repeat(64), artifact: PIN.artifact,
      supervisor: { pid: process.ppid, start: processIdentity(process.ppid).start } })}\n`);
  });
  await assert.rejects(probeChannel('1.3.0', { socket: () => a, timeout: 1000 }), /own-process-mismatch/); b.destroy();
});
test('synthetic process: missing channel, output overflow and incomplete final results fail', async () => {
  await assert.rejects(probeChannel('1.3.0', { socket: () => { throw new Error('missing-channel'); } }), /missing-channel/);
  const task = boundedSpawn(process.execPath, [join(here, 'child.mjs'), 'overflow']); const result = await task.result;
  assert.equal(result.failure, 'output-overflow'); assert.throws(() => finalResult(result), /output-overflow/);
  assert.throws(() => finalResult({ code: 0, signal: null, stdout: '{"schema":1,"complete":false}', failure: null }));
});
test('disposable resources: changed/deleted files and symlink sidecars invalidate manifests', t => {
  const root = mkdtempSync('/var/tmp/pi-launch-resources-'); t.after(() => rmSync(root, { recursive: true, force: true }));
  const path = join(root, 'package.json'); writeFileSync(path, '{"version":"1.3.0"}'); const before = manifest(root).digest;
  writeFileSync(path, '{"version":"1.1.0"}'); assert.notEqual(manifest(root).digest, before);
  unlinkSync(path); assert.notEqual(manifest(root).digest, before);
  symlinkSync('/dev/null', path); assert.throws(() => manifest(root), /manifest-symlink/);
});
test('fixed launch policy excludes ambient mounts, secrets, package override and arbitrary arguments', () => {
  const args = sandboxArgs({ experiment: here, output: '/fixture-output', input: '/fixture-input', mode: 'positive' });
  assert(args.includes('--unshare-pid') && args.includes('--unshare-net') && args.includes('--die-with-parent'));
  assert(!args.includes('--share-net')); assert(!('PI_PACKAGE_DIR' in ENV)); assert(!Object.keys(ENV).some(key => /TOKEN|SECRET|API_KEY|PROXY|NODE_OPTIONS/.test(key)));
  assert.equal(PI_ARGS.at(-1), '--help'); assert(!PI_ARGS.includes('--resume')); assert(FILES.includes('probe.mjs'));
  assert.throws(() => sandboxArgs({ mode: 'arbitrary' }), /unknown-phase/);
  for (const [index, value] of args.entries()) if (value === '--bind') assert.equal(args[index + 1], '/fixture-output');
});
test('copied preparation output cannot act as a source-checkout experiment', t => {
  assert(sourceCheckout().commit.match(/^[a-f0-9]{40}$/));
  const temp = mkdtempSync('/var/tmp/pi-launch-not-git-'); t.after(() => rmSync(temp, { recursive: true, force: true }));
  assert.throws(() => sourceCheckout(temp), /experiment-requires-source-checkout/);
});
test('host output: simulated sandbox symlink cannot overwrite a private host victim or block the separate failed report', t => {
  const root = mkdtempSync('/var/tmp/pi-launch-output-'); t.after(() => rmSync(root, { recursive: true, force: true }));
  const output = join(root, 'output'); mkdirSync(output, { mode: 0o700 });
  const victim = join(root, 'host-victim'); writeFileSync(victim, 'HOST UNCHANGED', { mode: 0o600 });
  symlinkSync(victim, join(output, 'supervisor.stdout'));
  assert.throws(() => savePrivate(join(output, 'supervisor.stdout'), 'overwrite'), /unsafe-output-entry/);
  assert.throws(() => readEvidence(join(output, 'supervisor.stdout')));
  assert.equal(readFileSync(victim, 'utf8'), 'HOST UNCHANGED');
  savePrivate(join(root, 'report.json'), { status: 'failed', reason: 'unsafe-output-entry' });
  assert.equal(JSON.parse(readFileSync(join(root, 'report.json'))).status, 'failed');
});
test('host output: hardlinks, directories and symlinked parent directories are refused', t => {
  const root = mkdtempSync('/var/tmp/pi-launch-output-types-'); t.after(() => rmSync(root, { recursive: true, force: true }));
  const victim = join(root, 'victim'); writeFileSync(victim, 'UNCHANGED', { mode: 0o600 });
  linkSync(victim, join(root, 'linked')); assert.throws(() => savePrivate(join(root, 'linked'), 'bad'), /unsafe-output-entry/);
  assert.throws(() => readEvidence(join(root, 'linked')), /unsafe-evidence-file/);
  mkdirSync(join(root, 'directory'), { mode: 0o700 }); assert.throws(() => savePrivate(join(root, 'directory'), 'bad'), /unsafe-output-entry/);
  symlinkSync(join(root, 'directory'), join(root, 'parent-link'));
  assert.throws(() => savePrivate(join(root, 'parent-link', 'file'), 'bad'));
  assert.throws(() => readEvidence(join(root, 'parent-link', 'file')));
  assert.equal(readFileSync(victim, 'utf8'), 'UNCHANGED');
  savePrivate(join(root, 'normal.json'), { status: 'initial' }); savePrivate(join(root, 'normal.json'), { status: 'updated' });
  assert.equal(JSON.parse(readFileSync(join(root, 'normal.json'))).status, 'updated');
  assert.equal(JSON.parse(readEvidence(join(root, 'normal.json')).text).status, 'updated');
  writeFileSync(join(root, 'oversize'), Buffer.alloc(LIMIT.output + 1), { mode: 0o600 });
  assert.throws(() => readEvidence(join(root, 'oversize')), /evidence-output-overflow/);
});

function sessionFixture({ accepted = true } = {}) {
  const handlers = new Map(), calls = [], errors = []; let branch = [], session = 'fixture-session', runtime = 'fixture-process', connected = true;
  const ctx = { mode: 'tui', sessionManager: { getSessionId: () => session, getBranch: () => branch } };
  const gate = sessionGate({ accepted, session, runtime, current: () => runtime, alive: () => connected, invoke: (command, input) => {
    calls.push({ command, input }); return { status: command === 'recall' ? 'recalled' : command === 'capture-transcript' ? 'queued' : 'registered', context: 'SYNTHETIC RECALL' };
  } });
  gate.install(createPiAdapter({ agentVersion: '1.3.0', owner: 'fixture-owner' }, gate.invoke, error => errors.push(error.message)), { on: (event, fn) => handlers.set(event, fn) });
  return { handlers, calls, errors, ctx, gate, set session(value) { session = value; }, set runtime(value) { runtime = value; }, set connected(value) { connected = value; },
    start: () => handlers.get('session_start')({ reason: 'startup' }, ctx),
    async turn() {
      await handlers.get('before_agent_start')({ messageType: 'user', prompt: 'synthetic question' }, ctx);
      branch.push({ id: 'u', type: 'message', message: { role: 'user', content: 'synthetic question' } });
      const recalled = await handlers.get('context')({ messages: [] }, ctx);
      const answer = { role: 'assistant', stopReason: 'stop', content: [{ type: 'text', text: 'synthetic answer' }] };
      branch.push({ id: 'a', type: 'message', message: answer });
      await handlers.get('agent_end')({ messages: [answer] }, ctx); return recalled;
    },
  };
}
test('synthetic callbacks only: accepted fixture binds one fresh session and reuses the existing Pi adapter', async () => {
  const f = sessionFixture(); await f.start(); const output = await f.turn();
  assert.equal(output.messages.at(-1).content, 'SYNTHETIC RECALL');
  assert.deepEqual(f.calls.map(call => call.command), ['session', 'session-status', 'recall', 'capture-transcript']); assert.deepEqual(f.errors, []);
});
test('synthetic callbacks: absent launch acceptance and pre-start callbacks/invoke make zero calls', async () => {
  const absent = sessionFixture({ accepted: false }); await assert.rejects(absent.start()); assert.equal(absent.calls.length, 0);
  const early = sessionFixture(); await assert.rejects(early.handlers.get('before_agent_start')({ prompt: 'x' }, early.ctx));
  await assert.rejects(early.start()); assert.equal(early.calls.length, 0);
  const direct = sessionFixture(); assert.throws(() => direct.gate.invoke('recall', { session: 'fixture-session' })); assert.equal(direct.calls.length, 0);
});
for (const lifecycle of ['new', 'resume', 'fork', 'reload', 'unknown']) test(`synthetic callbacks: ${lifecycle} revokes after positive prefix with zero additional calls`, async () => {
  const f = sessionFixture(); await f.start(); const before = f.calls.length;
  await assert.rejects(f.handlers.get('session_start')({ reason: lifecycle }, f.ctx));
  await assert.rejects(f.handlers.get('context')({ messages: [] }, f.ctx)); assert.equal(f.calls.length, before);
});
for (const mismatch of ['runtime', 'session', 'connected', 'mode']) test(`synthetic callbacks: ${mismatch} mismatch permanently revokes even after restoration`, async () => {
  const f = sessionFixture(); await f.start(); const before = f.calls.length;
  if (mismatch === 'mode') f.ctx.mode = 'rpc'; else f[mismatch] = mismatch === 'connected' ? false : 'different';
  await assert.rejects(f.handlers.get('context')({ messages: [] }, f.ctx));
  if (mismatch === 'mode') f.ctx.mode = 'tui'; else f[mismatch] = mismatch === 'runtime' ? 'fixture-process' : mismatch === 'session' ? 'fixture-session' : true;
  await assert.rejects(f.handlers.get('context')({ messages: [] }, f.ctx)); assert.equal(f.calls.length, before);
});
test('production safety: temporary Pi configuration still refuses activation without network or agent execution', async t => {
  const root = mkdtempSync('/var/tmp/pi-launch-activation-'); chmodSync(root, 0o700);
  let requests = 0; const api = createServer((req, res) => { requests++; res.end('{}'); }); api.listen(0, '127.0.0.1'); await once(api, 'listening');
  t.after(async () => { await new Promise(resolve => api.close(resolve)); rmSync(root, { recursive: true, force: true }); });
  const env = { HOME: root, PATH: '/usr/bin:/bin', XDG_CONFIG_HOME: join(root, '.config'), XDG_STATE_HOME: join(root, '.local/state'), XDG_DATA_HOME: join(root, '.local/share') };
  const cli = fileURLToPath(new URL('../../src/cli.mjs', import.meta.url));
  async function command(name, input) {
    const child = spawn(process.execPath, ['--disable-warning=ExperimentalWarning', cli, name], { env, stdio: ['pipe', 'pipe', 'pipe'] });
    let text = ''; child.stdout.on('data', bytes => { text += bytes; }); child.stderr.resume(); child.stdin.end(input ? JSON.stringify(input) : '');
    const [code] = await once(child, 'close'); return { code, data: JSON.parse(text) };
  }
  assert.equal((await command('prepare')).code, 0);
  const secret = join(root, '.config/hindsight-memory/fixture-secret'); writeFileSync(secret, 'synthetic-only', { mode: 0o600 });
  const agent = join(root, 'must-not-run'); writeFileSync(agent, '#!/bin/sh\nexit 99\n', { mode: 0o700 });
  assert.equal((await command('configure', { schema_version: 1, endpoint: `http://127.0.0.1:${api.address().port}`, bank: 'synthetic-only', secret_file: secret,
    capture: true, adapters: ['pi'], agent_versions: { pi: '1.3.0' }, agent_commands: { pi: agent } })).code, 0);
  const result = await command('activate'); assert.equal(result.code, 1); assert.equal(result.data.reason, 'native-caller-binding-unqualified'); assert.equal(requests, 0);
});
test('harmless sandbox preflights: real namespaces, hidden sentinels, readonly binds and both parent-death paths', { timeout: 60000 }, async () => {
  const result = await runExperiment({ preflightOnly: true }); assert.equal(result.status, 'passed', JSON.stringify(result));
  assert.deepEqual(result.phases.map(item => item.phase), ['preflight', 'inner-supervisor-death', 'outer-parent-death']);
  const report = JSON.parse(readFileSync(result.report, 'utf8')); assert(report.phases.every(item => item.cleanup === 'reaped'));
  assert.equal(report.preflightOnly, true); assert.equal(report.nativeSessionAttachment, false);
});
