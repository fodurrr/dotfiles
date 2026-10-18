// Own fixtures only. No test invokes or imports Pi, Bun or an upstream client.
import test from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { chmodSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { ENV, PI_ARGS, TEXT, PYTHON, PYTHON_FILES, sandboxArgs } from './policy.mjs';
import { fixtureServices } from './services.mjs';
import { sourceCheckout, runExperiment } from './run.mjs';
import { savePrivate, readEvidence } from '../pi-launch/safe-output.mjs';
const here = dirname(fileURLToPath(import.meta.url));
test('fixed native arguments and mounts preserve the sole bridge and private namespaces', () => {
  assert.deepEqual(PI_ARGS, ['--no-extensions', '-e', '/work/sole-bridge.mjs']);
  const args = sandboxArgs({ experiment: here, output: '/private/output', input: '/private/input', mode: 'native' });
  const permissions = args.indexOf('--perms');
  assert.deepEqual(args.slice(permissions, permissions + 4), ['--perms', '0700', '--tmpfs', '/agent']);
  assert.equal(args.filter(arg => arg === '--perms').length, 1);
  for (const flag of ['--unshare-user', '--unshare-pid', '--unshare-net', '--unshare-ipc', '--unshare-uts', '--die-with-parent', '--remount-ro']) assert(args.includes(flag));
  assert(args.includes(PYTHON)); assert(args.includes(PYTHON_FILES[0])); assert(!args.includes('/usr/bin')); assert(!args.includes('--share-net'));
  assert(!Object.keys(ENV).some(key => /TOKEN|SECRET|API_KEY|PROXY|NODE_OPTIONS|BUN_OPTIONS/.test(key)));
  for (let index = 0; index < args.length; index++) if (args[index] === '--bind') assert.equal(args[index + 1], '/private/output');
  assert.throws(() => sandboxArgs({ mode: 'arbitrary' }));
});
test('native mode requires an explicit CLI flag and cannot run from default test imports', async () => {
  await assert.rejects(runExperiment({ native: true }), /explicit-native-flag-required/);
  assert.match(sourceCheckout().commit, /^[a-f0-9]{40}$/);
});
test('native clean-source gate detects both changed component files and untracked experiment files from its nested directory', t => {
  const root = mkdtempSync('/var/tmp/pi-turn-git-'); t.after(() => rmSync(root, { recursive: true, force: true }));
  const location = join(root, 'tools/hindsight-memory/experiments/pi-turn'); mkdirSync(location, { recursive: true });
  const file = join(root, 'tools/hindsight-memory/fixture.txt'); writeFileSync(file, 'committed');
  const env = { PATH: '/usr/bin:/bin', HOME: root, GIT_CONFIG_GLOBAL: '/dev/null', GIT_CONFIG_SYSTEM: '/dev/null' };
  const git = args => execFileSync('/usr/bin/git', ['-C', root, ...args], { env, stdio: 'ignore' });
  git(['init', '--quiet']); git(['add', 'tools']);
  git(['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '--quiet', '-m', 'fixture']);
  assert.equal(sourceCheckout(location).dirty, false);
  writeFileSync(file, 'modified'); assert.equal(sourceCheckout(location).dirty, true);
  writeFileSync(file, 'committed'); assert.equal(sourceCheckout(location).dirty, false);
  const untracked = join(location, 'untracked'); writeFileSync(untracked, 'untracked');
  assert.equal(sourceCheckout(location).dirty, true); rmSync(untracked);
  assert.equal(sourceCheckout(location).dirty, false);
});
test('own fake OpenAI fixture emits bounded pinned text SSE and excludes history from second request', async t => {
  const services = await fixtureServices(); t.after(() => services.close());
  for (const text of [TEXT.history, `${TEXT.prompt}\n${TEXT.recall}`]) {
    const response = await fetch(`${services.provider}/v1/chat/completions`, { method: 'POST', headers: { authorization: 'Bearer fixture-only', 'content-type': 'application/json' },
      body: JSON.stringify({ model: 'fixture', stream: true, messages: [{ role: 'user', content: text }] }) });
    assert.equal(response.status, 200); const raw = await response.text();
    const chunks = raw.split('\n\n').filter(Boolean).map(line => line.slice(6)); assert.equal(chunks.at(-1), '[DONE]');
    assert.equal(JSON.parse(chunks[0]).choices[0].delta.role, 'assistant');
    assert.equal(JSON.parse(chunks[2]).choices[0].finish_reason, 'stop');
    assert.deepEqual(JSON.parse(chunks[3]).usage, { prompt_tokens: 1, completion_tokens: 1, total_tokens: 2 });
  }
  services.check(); assert.equal(services.evidence.provider.length, 2);
});
test('own fake provider refuses a second request carrying history and never silently retries', async t => {
  const services = await fixtureServices(); t.after(() => services.close());
  const send = content => fetch(`${services.provider}/v1/chat/completions`, { method: 'POST', headers: { authorization: 'Bearer fixture-only' },
    body: JSON.stringify({ model: 'fixture', stream: true, messages: [{ role: 'user', content }] }) });
  await (await send(TEXT.history)).text(); const second = await send(`${TEXT.prompt} ${TEXT.recall} ${TEXT.history}`);
  assert.equal(second.status, 400); assert.throws(services.check, /provider-context-mismatch/);
});
test('own fake Hindsight requires exact new query and retained text; completed operation IDs stay fixed', async t => {
  const services = await fixtureServices(); t.after(() => services.close());
  const send = async (method, suffix, body) => {
    const response = await fetch(`${services.memory}/v1/default/banks/synthetic${suffix}`, { method,
      headers: { authorization: 'Bearer synthetic-secret', 'content-type': 'application/json' }, ...(body ? { body: JSON.stringify(body) } : {}) });
    assert.equal(response.status, 200); return response.json();
  };
  assert.equal((await send('POST', '/memories/recall', { query: TEXT.prompt })).results[0].text, TEXT.recall);
  for (const [index, text] of [`user: ${TEXT.prompt}`, `assistant: ${TEXT.final}`].entries()) {
    const id = `${index}`.repeat(8) + '-1111-5111-a111-111111111111';
    await send('GET', '/profile'); assert.equal((await send('POST', '/memories', { operation_id: id, async: true, items: [{ content: text }] })).operation_id, id);
    assert.equal((await send('GET', `/operations/${id}`)).status, 'completed');
  }
  services.check(); assert.equal(services.evidence.retains.length, 2); assert.equal(services.evidence.completed.length, 2);
});
test('own fake Hindsight refuses recall/history leakage before retaining it', async t => {
  const services = await fixtureServices(); t.after(() => services.close());
  const response = await fetch(`${services.memory}/v1/default/banks/synthetic/memories`, { method: 'POST', headers: { authorization: 'Bearer synthetic-secret' },
    body: JSON.stringify({ operation_id: '11111111-1111-5111-a111-111111111111', async: true, items: [{ content: TEXT.recall }] }) });
  assert.equal(response.status, 400); assert.equal(services.evidence.retains.length, 0); assert.throws(services.check);
});
test('guarded evidence paths reject sandbox links while preserving the host target', t => {
  const root = mkdtempSync('/var/tmp/pi-turn-output-'); chmodSync(root, 0o700); t.after(() => rmSync(root, { recursive: true, force: true }));
  const victim = join(root, 'victim'); writeFileSync(victim, 'unchanged', { mode: 0o600 }); symlinkSync(victim, join(root, 'terminal.json'));
  assert.throws(() => savePrivate(join(root, 'terminal.json'), 'bad')); assert.throws(() => readEvidence(join(root, 'terminal.json')));
  assert.equal(readFileSync(victim, 'utf8'), 'unchanged'); savePrivate(join(root, 'report.json'), { failed: true });
  assert.equal(JSON.parse(readEvidence(join(root, 'report.json')).text).failed, true);
});
test('harmless confined PTY preflights validate services, namespaces, limits and both death cleanup paths', { timeout: 120000 }, async t => {
  const result = await runExperiment(); t.diagnostic(JSON.stringify(result)); assert.equal(result.status, 'passed', JSON.stringify(result));
  assert.equal(result.nativeExecuted, false);
  assert.deepEqual(result.phases.map(phase => phase.phase), ['preflight', 'deadline', 'overflow', 'inner-supervisor-death', 'outer-parent-death']);
  const report = JSON.parse(readEvidence(result.report).text); assert(report.phases.every(phase => phase.cleanup === 'reaped' && phase.nativeExecuted === false));
  assert.equal(report.nativeRequested, false); assert.equal(report.nativeLaunchAttempted, false);
  assert.equal(report.nativeExecutionEvidence, 'not-requested');
  const preflight = report.phases.find(phase => phase.phase === 'preflight');
  assert.equal(preflight.nativeLaunchAttempted, false);
  assert.deepEqual(preflight.nativePreparation, { '/agent': 0o700, '/agent/models.json': 0o600, '/agent/settings.json': 0o600 });
});
