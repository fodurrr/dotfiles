// Synthetic observations and native callbacks only. No Pi/Bun/provider execution.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { spawn, spawnSync } from 'node:child_process';
import { once } from 'node:events';
import { fileURLToPath } from 'node:url';
import { fixture as coreFixture } from './helpers.mjs';
import { register, stageTurn, completeTurn, abortTurn, capture } from '../src/capture.mjs';
import { recall } from '../src/delivery.mjs';
import { destination as configDestination } from '../src/config.mjs';
import { createPiAdapter, PI_ELF_SHA256, qualifyPiProcess, observePiProcess } from '../adapters/pi.mjs';
import { makeInvoker } from '../adapters/common.mjs';

const descriptor = { schema_version: 1, runtime: '/synthetic/node', cli: '/synthetic/cli.mjs', owner: 'synthetic-owner', agentVersion: '1.3.0',
  agent_identity: { requested: '/synthetic/pi', path: '/synthetic/pi', dev: 1, ino: 2, size: 100, mtimeMs: 3 } };
const bridgePath = '/synthetic/sole-bridge.mjs';
const observation = () => ({ platform: 'linux', executable: '/synthetic/pi', elf: true, sha256: PI_ELF_SHA256,
  identity: { dev: 1, ino: 2, size: 100, mtimeMs: 3 }, argv: ['--no-extensions', '-e', bridgePath], preloads: [] });
const initialMetadata = [{ type: 'thinking_level_change', id: 'initial-thinking', parentId: null, thinkingLevel: 'off' }];
const user = (id, text) => ({ type: 'message', id, message: { role: 'user', content: [{ type: 'text', text }] } });
const assistant = (id, text, stopReason = 'stop') => ({ type: 'message', id, message: { role: 'assistant', stopReason,
  content: [{ type: 'thinking', thinking: 'REASONING_SENTINEL' }, { type: 'text', text }] } });
function fixture(options = {}) {
  const handlers = new Map(); const calls = []; const errors = []; const confirmations = [];
  let branch = structuredClone(initialMetadata); let session = 'fresh'; let idle = true; let pending = false;
  let observed = observation(); let destination = { endpoint: 'https://memory.invalid', bank: 'personal' };
  const ctx = { mode: 'tui', hasUI: true, signal: undefined, isIdle: () => idle, hasPendingMessages: () => pending,
    sessionManager: { getSessionId: () => session, getBranch: () => branch },
    ui: { confirm: async (...args) => { confirmations.push(args); return options.confirm ? options.confirm(...args) : true; } } };
  const invoke = (command, input) => {
    calls.push({ command, input });
    if (options.invoke) return options.invoke(command, input);
    if (options.fail === command) throw new Error('PRIVATE_ERROR_SENTINEL');
    return { schema_version: 1, status: { session: 'registered', 'stage-turn': 'staged', 'abort-turn': 'aborted',
      'complete-turn': options.duplicate ? 'duplicate' : 'queued', recall: 'recalled' }[command], context: 'UNTRUSTED_RECALL_SENTINEL' };
  };
  createPiAdapter(descriptor, invoke, e => errors.push(e), { bridgePath,
    observeProcess: options.observeProcess || (() => observed), readDestination: () => destination })({ on: (name, fn) => handlers.set(name, fn) });
  const emit = (name, event = {}) => handlers.get(name)(event, ctx);
  const start = () => emit('session_start', { reason: 'new' });
  const input = text => emit('input', { source: 'interactive', text });
  const before = (text = 'question') => { idle = false; return emit('before_agent_start', { messageType: 'user', prompt: text }); };
  const context = () => emit('context', { messages: [{ role: 'user', content: 'question' }] });
  const turn = (entry = branch.at(-1)) => emit('turn_end', { messageEntryId: entry.id, message: entry.message, outcome: 'completed' });
  const settle = (aborted = false) => { idle = true; return emit('agent_settled', { aborted }); };
  return { ctx, handlers, emit, start, input, before, context, turn, settle, calls, errors, confirmations,
    get branch() { return branch; }, set branch(value) { branch = value; },
    set session(value) { session = value; }, set idle(value) { idle = value; }, set pending(value) { pending = value; },
    set observed(value) { observed = value; }, set destination(value) { destination = value; } };
}
async function staged(f = fixture()) {
  await f.start(); await f.input('question'); await f.before();
  f.branch = [...initialMetadata, user('native-user', 'question')];
  await f.context(); return f;
}
async function final(f, text = 'answer') {
  f.branch = [...f.branch, assistant('native-final', text)];
  await f.turn(); await f.settle();
}
const commands = f => f.calls.map(call => call.command);

test('Pi candidate process binding rejects selected-file identity without actual matching ELF and exact sole-extension argv', () => {
  assert.doesNotThrow(() => qualifyPiProcess(descriptor, bridgePath, observation()));
  for (const change of [{ platform: 'darwin' }, { executable: '/synthetic/bun' }, { elf: false }, { sha256: 'wrong' },
    { identity: { ...observation().identity, ino: 9 } }, { preloads: ['BUN_OPTIONS'] },
    ...[[], ['-e', bridgePath], ['--no-extensions', '-e', bridgePath, '@file'],
      ['--no-extensions', '-e', bridgePath, '-e', '/other'],
      ['--no-extensions', '-e', '/other'], ['--no-extensions', '-e', bridgePath, '--mode', 'rpc']].map(argv => ({ argv }))]) {
    assert.throws(() => qualifyPiProcess(descriptor, bridgePath, { ...observation(), ...change }));
  }
});
test('Actual Node process observation cannot qualify as Pi; no UI, destination read or core admission occurs', async () => {
  const f = fixture({ observeProcess: observePiProcess });
  await f.start();
  assert.deepEqual(f.calls, []); assert.deepEqual(f.confirmations, []);
  assert.equal(f.errors[0].code, 'unqualified_pi_process');
});
test('Fresh consent names actual endpoint/bank and registers only an empty new TUI session', async () => {
  const f = fixture(); await f.start();
  assert.match(f.confirmations[0][1], /personal at https:\/\/memory.invalid/);
  assert.deepEqual(commands(f), ['session']);
  assert.deepEqual(f.calls[0].input.baseline, []); assert.equal(f.calls[0].input.fresh, true);
  for (const reason of ['startup', 'resume', 'reload', 'fork', 'unknown']) {
    const denied = fixture(); await denied.emit('session_start', { reason });
    assert.deepEqual(denied.calls, []); assert.deepEqual(denied.confirmations, []);
  }
  for (const mutate of [f => { f.ctx.mode = 'rpc'; }, f => { f.ctx.hasUI = false; }, f => { f.idle = false; },
    f => { f.pending = true; }, f => { f.branch = [user('old', 'OLD_HISTORY_SENTINEL')]; }]) {
    const denied = fixture(); mutate(denied); await denied.start(); assert.deepEqual(denied.calls, []);
  }
});
test('Fresh /new accepts only source-native root model/thinking metadata and never registers it as history', async () => {
  const model = { type: 'model_change', id: 'initial-model', parentId: null, provider: 'synthetic', modelId: 'synthetic' };
  const thinking = { ...initialMetadata[0], parentId: model.id };
  const f = fixture(); f.branch = [model, thinking]; await f.start();
  assert.deepEqual(commands(f), ['session']); assert.deepEqual(f.calls[0].input.baseline, []);
  await f.input('question'); await f.before(); f.branch = [...f.branch, user('u', 'question')];
  await f.context(); await final(f); assert.equal(f.calls.at(-1).command, 'complete-turn');
  for (const entries of [[], [model], [thinking, model], [model, { ...thinking, parentId: null }],
    [model, thinking, { type: 'session_info', id: 'extra', parentId: thinking.id }],
    [{ ...initialMetadata[0], parentId: 'prior-history' }],
    [{ type: 'custom', id: 'custom', parentId: null }], [{ type: 'compaction', id: 'summary', parentId: null }],
    [{ type: 'context_edit', id: 'edit', parentId: null }]]) {
    const denied = fixture(); denied.branch = entries; await denied.start();
    assert.deepEqual(denied.calls, []); assert.deepEqual(denied.confirmations, []);
  }
});
test('Declined, stale or destination-changed consent cannot register', async () => {
  const denied = fixture({ confirm: async () => false }); await denied.start(); assert.deepEqual(denied.calls, []);
  let resolve; const f = fixture({ confirm: () => new Promise(r => { resolve = r; }) });
  const waiting = f.start(); await f.emit('session_shutdown'); resolve(true); await waiting;
  assert.deepEqual(f.calls, []);
  const g = fixture({ confirm: async () => { g.destination = { endpoint: 'https://other.invalid', bank: 'other' }; return true; } });
  await g.start(); assert.deepEqual(g.calls, []);
});
test('Initial metadata identity and content must stay unchanged while consent is pending', async () => {
  for (const change of [{ id: 'replaced-initial' }, { thinkingLevel: 'high' }]) {
    let resolve; const f = fixture({ confirm: () => new Promise(r => { resolve = r; }) });
    const waiting = f.start(); f.branch = [{ ...initialMetadata[0], ...change }];
    resolve(true); await waiting;
    assert.deepEqual(f.calls, []); assert.equal(f.errors.length, 1);
  }
});
test('A stale consent dialog cannot discard a newer session candidate', async () => {
  let resolve; let confirms = 0;
  const f = fixture({ confirm: () => ++confirms === 1 ? new Promise(r => { resolve = r; }) : true });
  const stale = f.start(); f.session = 'newer'; await f.start();
  await f.input('question'); await f.before(); resolve(true); await stale;
  assert.deepEqual(commands(f), ['session', 'stage-turn']);
  f.branch = [...initialMetadata, user('newer-user', 'question')]; await f.context(); await final(f);
  assert.equal(f.calls.at(-1).command, 'complete-turn'); assert.equal(f.errors.length, 0);
});
test('One input stages once after matching model-validated boundary, binds native user and recalls once', async () => {
  const f = fixture(); await f.start(); await f.input('question');
  assert.deepEqual(commands(f), ['session']);
  await f.before(); assert.deepEqual(commands(f), ['session', 'stage-turn']);
  f.branch = [...initialMetadata, user('native-user', 'question')];
  const first = await f.context(); await f.context();
  assert.equal(first.messages.at(-1).role, 'custom');
  assert.equal(first.messages.at(-1).content, 'UNTRUSTED_RECALL_SENTINEL');
  assert.equal(f.calls.filter(call => call.command === 'recall').length, 1);
  await final(f);
  assert.deepEqual(commands(f), ['session', 'stage-turn', 'recall', 'complete-turn']);
  assert.equal(new Set(f.calls.slice(1).map(call => call.input.turn_id)).size, 1);
  assert.equal(f.calls.at(-1).input.text, 'answer'); assert.equal(f.errors.length, 0);
  assert(!JSON.stringify(f.calls).includes('REASONING_SENTINEL'));
  assert(!JSON.stringify(f.calls).includes('UNTRUSTED_RECALL_SENTINEL'));
});
test('Matching message_end or agent_end cannot admit; only exact persisted turn_end then settlement can', async () => {
  const f = await staged(); f.branch = [...f.branch, assistant('native-final', 'answer')];
  assert.equal(f.handlers.has('message_end'), false); assert.equal(f.handlers.has('agent_end'), false);
  await f.settle();
  assert(!commands(f).includes('complete-turn')); assert.equal(commands(f).at(-1), 'abort-turn');
  const g = await staged(); await final(g); await g.settle(); await g.turn();
  assert.equal(commands(g).filter(command => command === 'complete-turn').length, 1);
});
test('Transformed, skill/template-expanded and custom-triggered runs never stage original or expanded text', async () => {
  for (const event of [{ messageType: 'user', prompt: 'EXPANDED_FILE_SENTINEL' }, { messageType: 'custom', message: { content: 'CUSTOM_SENTINEL' } },
    { messageType: 'user', prompt: 'question', images: [{}] }]) {
    const f = fixture(); await f.start(); await f.input('question'); await f.emit('before_agent_start', event);
    assert.deepEqual(commands(f), ['session']);
  }
  for (const text of ['/skill:example', '/template']) {
    const f = fixture(); await f.start(); await f.input(text); await f.before('EXPANDED_FILE_SENTINEL');
    assert.deepEqual(commands(f), ['session']);
  }
});
test('RPC, extension, queued, image and busy inputs refuse admission', async () => {
  for (const event of [{ source: 'rpc' }, { source: 'extension' }, { streamingBehavior: 'steer' }, { streamingBehavior: 'followUp' }, { images: [{}] }]) {
    const f = fixture(); await f.start(); await f.emit('input', { source: 'interactive', text: 'question', ...event });
    await f.before(); assert.deepEqual(commands(f), ['session']);
  }
  for (const kind of ['busy', 'pending', 'aborted']) {
    const f = fixture(); await f.start();
    if (kind === 'busy') f.idle = false;
    if (kind === 'pending') f.pending = true;
    if (kind === 'aborted') f.ctx.signal = { aborted: true };
    await f.input('question'); assert.deepEqual(commands(f), ['session']);
  }
});
test('Any second input drops the current pair; queued steer/follow-up text cannot replace it', async () => {
  for (const streamingBehavior of [undefined, 'steer', 'followUp']) {
    const f = await staged();
    await f.emit('input', { source: 'interactive', text: 'QUEUED_SENTINEL', streamingBehavior });
    await final(f); assert.deepEqual(commands(f), ['session', 'stage-turn', 'recall', 'abort-turn']);
    assert(!JSON.stringify(f.calls).includes('QUEUED_SENTINEL'));
  }
  const f = fixture(); await f.start(); await f.input('first'); await f.input('second'); await f.before('first');
  assert.deepEqual(commands(f), ['session']);
});
test('Changed or extra persisted users, images and changed branch IDs invalidate the staged pair', async () => {
  for (const replacement of [[user('other', 'changed')], [user('u', 'question'), user('extra', 'EXTRA_USER_SENTINEL')],
    [{ ...user('u', 'question'), message: { role: 'user', content: [{ type: 'text', text: 'question' }, { type: 'image', data: 'FILE_SENTINEL' }] } }]]) {
    const f = await staged(); f.branch = [...initialMetadata, ...replacement]; await f.context(); await final(f);
    assert(!commands(f).includes('complete-turn')); assert.equal(commands(f).at(-1), 'abort-turn');
  }
  const f = await staged(); f.branch = [...initialMetadata, user('changed-native-id', 'question')]; await f.context();
  assert.equal(commands(f).at(-1), 'abort-turn');
});
test('History and request-local recall never enter a later admitted pair; literal TUI paths remain literal', async () => {
  const f = await staged(); await final(f);
  await f.input('@literal-file'); await f.before('@literal-file');
  f.branch = [...f.branch, { type: 'custom_message', id: 'custom-recall', content: 'RECALL_HISTORY_SENTINEL' }, user('second-user', '@literal-file')];
  await f.context(); f.branch = [...f.branch, assistant('second-final', 'second answer')]; await f.turn(); await f.settle();
  assert.deepEqual(f.calls.filter(call => call.command === 'complete-turn').map(call => call.input.text), ['answer', 'second answer']);
  assert(!JSON.stringify(f.calls).includes('RECALL_HISTORY_SENTINEL'));
  assert.equal(f.calls.filter(call => call.command === 'stage-turn').at(-1).input.prompt, '@literal-file');
});
test('turn_end requires matching persisted assistant ID, text and final stop reason', async () => {
  for (const change of [{ messageEntryId: 'not-persisted' }, { message: assistant('x', 'different').message },
    { message: assistant('x', 'answer', 'length').message }, { outcome: 'error' }]) {
    const f = await staged(); f.branch = [...f.branch, assistant('final', 'answer')];
    await f.emit('turn_end', { messageEntryId: 'final', message: f.branch.at(-1).message, outcome: 'completed', ...change });
    await f.settle(); assert(!commands(f).includes('complete-turn')); assert.equal(commands(f).at(-1), 'abort-turn');
  }
});
test('Tool turns can precede the final answer; tool and reasoning text never enter admission', async () => {
  const f = await staged(); f.branch = [...f.branch, assistant('tool-turn', 'TOOL_CALL_SENTINEL', 'toolUse')];
  await f.turn(); f.branch = [...f.branch, { type: 'message', id: 'tool-result', message: { role: 'toolResult', content: 'TOOL_RESULT_SENTINEL' } }];
  await f.context(); await final(f);
  assert.equal(f.calls.at(-1).command, 'complete-turn');
  assert(!JSON.stringify(f.calls).includes('TOOL_CALL_SENTINEL')); assert(!JSON.stringify(f.calls).includes('TOOL_RESULT_SENTINEL'));
});
test('Settlement refuses abort, pending input, extra user and mutated final assistant', async () => {
  for (const change of ['abort', 'pending', 'extra-user', 'changed-text', 'changed-id', 'changed-stop']) {
    const f = await staged(); f.branch = [...f.branch, assistant('native-final', 'answer')]; await f.turn();
    if (change === 'pending') f.pending = true;
    if (change === 'extra-user') f.branch = [...f.branch, user('extra', 'EXTRA_USER_SENTINEL')];
    if (change === 'changed-text') f.branch = [...f.branch.slice(0, -1), assistant('native-final', 'changed')];
    if (change === 'changed-id') f.branch = [...f.branch.slice(0, -1), assistant('other-final', 'answer')];
    if (change === 'changed-stop') f.branch = [...f.branch.slice(0, -1), assistant('native-final', 'answer', 'error')];
    await f.settle(change === 'abort'); assert(!commands(f).includes('complete-turn')); assert.equal(commands(f).at(-1), 'abort-turn');
  }
});
test('Lifecycle boundaries abort the pair and require new consent; late events cannot capture', async () => {
  for (const event of ['session_before_switch', 'session_before_fork', 'session_before_tree', 'session_tree', 'session_before_compact',
    'session_compact', 'session_compact_failed', 'session_shutdown']) {
    const f = await staged(); await f.emit(event); await final(f);
    await f.input('late'); await f.before('late'); assert.equal(commands(f).at(-1), 'abort-turn');
    assert(!commands(f).includes('complete-turn'));
  }
});
test('Destination or current process changes disable admission after consent', async () => {
  for (const change of ['destination', 'process']) {
    const f = await staged();
    if (change === 'destination') f.destination = { endpoint: 'https://other.invalid', bank: 'other' };
    else f.observed = { ...observation(), sha256: 'wrong' };
    await final(f); assert(!commands(f).includes('complete-turn'));
    assert(f.errors.length > 0);
    // Failed abort is visible; a changed route/destination cannot issue further core calls.
    assert.deepEqual(commands(f), ['session', 'stage-turn', 'recall']);
  }
});
test('Core failures clear the slot without replay; duplicate acknowledgements do not create extra admissions', async () => {
  for (const fail of ['stage-turn', 'recall', 'complete-turn']) {
    const f = await staged(fixture({ fail })); await final(f); await f.settle();
    assert.equal(commands(f).filter(command => command === fail).length, 1);
    assert(f.errors.length > 0); assert.equal(commands(f).at(-1), 'abort-turn');
  }
  const f = await staged(fixture({ duplicate: true })); await final(f); await f.turn(); await f.settle();
  assert.equal(commands(f).filter(command => command === 'complete-turn').length, 1);
});

test('Synthetic Pi callbacks use the real temporary core: settlement admits the whole pair; queued cancellation admits nothing', async t => {
  const core = coreFixture(t); core.store.deactivate(); core.store.activate({ ...core.config, adapters: ['pi'] });
  const invoke = (command, input) => command === 'recall' ? { status: 'recall-unavailable' } :
    ({ session: register, 'stage-turn': stageTurn, 'complete-turn': completeTurn, 'abort-turn': abortTurn })[command](core.store, input);
  const f = fixture({ invoke }); f.destination = { endpoint: core.config.endpoint, bank: core.config.bank };
  await staged(f);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM staged').get().n, 1);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM jobs').get().n, 0);
  await final(f);
  assert.equal(f.errors.length, 0);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM staged').get().n, 0);
  const accepted = core.store.db.prepare('SELECT body FROM jobs ORDER BY rowid').all();
  assert.equal(accepted.length, 2);
  assert.deepEqual(accepted.map(job => JSON.parse(job.body).items[0].content), ['user: question', 'assistant: answer']);
  const g = fixture({ invoke }); g.session = 'second-fresh';
  g.destination = { endpoint: core.config.endpoint, bank: core.config.bank };
  await staged(g); await g.input('QUEUED_SENTINEL'); await final(g);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM staged').get().n, 0);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM jobs').get().n, 2);
});

function diskPiCore(t) {
  const core = coreFixture(t, {}, { temporaryRoot: '/var/tmp' });
  assert.notEqual(fs.statfsSync(core.home).type, 0x01021994, 'contention fixture must not use tmpfs');
  core.store.deactivate(); core.store.activate({ ...core.config, adapters: ['pi'] });
  const cli = fileURLToPath(new URL('../src/cli.mjs', import.meta.url));
  // Run actual main/Store/input/error handling synchronously. Suppress only
  // detached wakes so all fixture processes can be joined before cleanup.
  const script = `import {main,safeFailure} from ${JSON.stringify(new URL('../src/cli.mjs', import.meta.url).href)};
    main(process.argv[1],{wakeImpl:()=> 'fixture-suppressed'}).then(r=>console.log(JSON.stringify({schema_version:1,...r}))).catch(e=>{console.log(JSON.stringify(safeFailure(e)));process.exitCode=1;});`;
  const env = { ...process.env, HOME: core.home, XDG_CONFIG_HOME: path.join(core.home, '.config'),
    XDG_STATE_HOME: path.join(core.home, '.local/state'), XDG_DATA_HOME: path.join(core.home, '.local/share') };
  const invoke = makeInvoker({ schema_version: 1, runtime: process.execPath, cli, owner: descriptor.owner },
    (runtime, args, options) => spawnSync(runtime, ['--disable-warning=ExperimentalWarning', '--input-type=module', '-e', script, args[1]], { ...options, env }));
  const candidate = () => {
    const f = fixture({ invoke }); f.destination = { endpoint: core.config.endpoint, bank: core.config.bank }; return f;
  };
  const unaccepted = session => {
    const row = core.store.getSession({ agent: 'pi', session, owner: descriptor.owner });
    assert.equal(row.cursor, null); assert.equal(row.count, 0);
    assert.equal(core.store.db.prepare('SELECT count(*) n FROM jobs').get().n, 0);
    assert.equal(core.store.db.prepare('SELECT count(*) n FROM messages').get().n, 0);
  };
  return { core, candidate, unaccepted };
}
async function withExclusivePiState(core, fn) {
  const script = `import {DatabaseSync} from 'node:sqlite';const db=new DatabaseSync(process.argv[1]);
    db.exec('BEGIN EXCLUSIVE');process.send('locked');process.on('message',()=>{db.exec('ROLLBACK');db.close();process.exit(0);});`;
  const child = spawn(process.execPath, ['--disable-warning=ExperimentalWarning', '--input-type=module', '-e', script, core.store.file],
    { stdio: ['ignore', 'ignore', 'pipe', 'ipc'], timeout: 8000 });
  let stderr = ''; child.stderr.on('data', chunk => { stderr += chunk; });
  const closed = once(child, 'close'); let locked = false;
  try {
    const ready = await Promise.race([once(child, 'message'), closed.then(result => { throw new Error(`lock child exited before readiness: ${result}; ${stderr}`); })]);
    assert.equal(ready[0], 'locked'); locked = true;
    return await fn();
  } finally {
    if (locked && child.connected) child.send('release');
    else if (child.exitCode === null) child.kill('SIGKILL');
    const [code, signal] = await closed;
    assert.equal(code, 0, `lock child must release and exit: ${signal}; ${stderr}`);
  }
}
test('Disk-backed Pi CLI stage contention reports busy without admission or late callback replay', { skip: process.platform !== 'linux', timeout: 15000 }, async t => {
  const { core, candidate, unaccepted } = diskPiCore(t); const f = candidate();
  await f.start(); await f.input('question');
  await withExclusivePiState(core, () => f.before());
  assert.deepEqual(commands(f), ['session', 'stage-turn', 'abort-turn']);
  assert.deepEqual(f.errors.map(error => error.code), ['state_busy_admission_not_confirmed', 'state_busy_admission_not_confirmed']);
  unaccepted('fresh'); assert.equal(core.store.db.prepare('SELECT count(*) n FROM staged').get().n, 0);
  const calls = commands(f); f.branch = [...initialMetadata, user('native-user', 'question')];
  await f.context(); await final(f); await f.turn(); await f.settle(); await f.before();
  assert.deepEqual(commands(f), calls); unaccepted('fresh');
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM staged').get().n, 0);
});
test('Disk-backed Pi CLI completion and abort contention preserve an unaccepted stage without replay or implicit recovery', { skip: process.platform !== 'linux', timeout: 15000 }, async t => {
  const { core, candidate, unaccepted } = diskPiCore(t); const f = candidate();
  await f.start(); await f.input('question'); await f.before();
  const pending = core.store.db.prepare('SELECT * FROM staged').get(); assert.equal(pending.prompt, 'question');
  f.branch = [...initialMetadata, user('native-user', 'question')];
  await withExclusivePiState(core, () => final(f));
  assert.deepEqual(commands(f), ['session', 'stage-turn', 'complete-turn', 'abort-turn']);
  assert.deepEqual(f.errors.map(error => error.code), ['state_busy_admission_not_confirmed', 'state_busy_admission_not_confirmed']);
  unaccepted('fresh'); assert.deepEqual(core.store.db.prepare('SELECT * FROM staged').get(), pending);
  const calls = commands(f); await f.context(); await f.turn(); await f.settle(); await f.before();
  assert.deepEqual(commands(f), calls); unaccepted('fresh');
  assert.deepEqual(core.store.db.prepare('SELECT * FROM staged').get(), pending);
  const restarted = candidate(); await restarted.start(); await restarted.input('question'); await restarted.before();
  assert.deepEqual(commands(restarted), ['session', 'stage-turn', 'abort-turn']);
  assert.equal(restarted.errors[0].code, 'local_admission_failed');
  assert.notEqual(restarted.calls[1].input.turn_id, pending.turn_id);
  await final(restarted); unaccepted('fresh');
  assert.deepEqual(core.store.db.prepare('SELECT * FROM staged').get(), pending);
  const fresh = candidate(); fresh.session = 'fresh-after-contention'; await fresh.start();
  fresh.branch = [...initialMetadata, user('native-user', 'question'), assistant('native-final', 'answer')];
  await fresh.turn(); await fresh.settle();
  assert.deepEqual(commands(fresh), ['session']); unaccepted('fresh-after-contention');
  assert.deepEqual(core.store.db.prepare('SELECT * FROM staged').get(), pending);
});

test('Consent destination B cannot register, stage, capture or recall against actual active destination A', async t => {
  const core = coreFixture(t); core.store.deactivate(); core.store.activate({ ...core.config, adapters: ['pi'] });
  const f = fixture({ invoke: (command, input) => {
    assert.equal(command, 'session'); return register(core.store, input);
  } });
  // Fixture UI reads B while the real temporary core remains active at A.
  await f.start(); assert.match(f.confirmations[0][1], /personal at https:\/\/memory.invalid/);
  assert.equal(f.errors.length, 1);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM sessions').get().n, 0);
  const input = { schema_version: 1, agent: 'pi', session: 'bound', owner: 'synthetic-owner', turn_id: 'turn',
    expected_destination: configDestination({ endpoint: 'https://memory.invalid', bank: 'personal' }) };
  const actual = { ...input, expected_destination: configDestination(core.config) };
  register(core.store, actual);
  assert.throws(() => stageTurn(core.store, { ...input, prompt: 'NOT_STAGED_SENTINEL' }), /destination-mismatch/);
  stageTurn(core.store, { ...actual, prompt: 'question' });
  assert.throws(() => completeTurn(core.store, { ...input, text: 'NOT_ADMITTED_SENTINEL' }), /destination-mismatch/);
  assert.throws(() => capture(core.store, { ...input, messages: [{ id: 'unbound', role: 'user', text: 'NOT_ADMITTED_SENTINEL', completed: true }] }), /destination-mismatch/);
  let requests = 0;
  const result = await recall(core.store, { ...input, query: 'NOT_SENT_SENTINEL' }, { fetchImpl: async () => { requests++; assert.fail('destination mismatch must not issue a request'); } });
  assert.equal(result.status, 'recall-unavailable'); assert.equal(requests, 0);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM jobs').get().n, 0);
  assert.equal(core.store.db.prepare('SELECT count(*) n FROM recalls').get().n, 0);
  assert.equal(core.store.db.prepare('SELECT prompt FROM staged').get().prompt, 'question');
});
