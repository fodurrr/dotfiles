import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, chmodSync, symlinkSync, linkSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { AdapterError, diagnostic, makeInvoker, readPrivateJson, readTranscript } from '../adapters/common.mjs';
import { handleHook } from '../adapters/hook.mjs';
import { adapterArtifacts } from '../adapters/manage.mjs';
import { createPiAdapter } from '../adapters/pi.mjs';
import { createOpenCodeV1 } from '../adapters/opencode-v1.mjs';
import { createOpenCodeV2 } from '../adapters/opencode-v2.mjs';
import { claudeTranscript, codexTranscript, piTranscript, opencodeV1Transcript, opencodeV2Transcript } from '../adapters/transcripts.mjs';

const descriptor = { schema_version: 1, runtime: '/qualified/node', cli: '/release/src/cli.mjs', owner: 'fixture-owner', agentVersion: '2.1.302' };
const jsonl = rows => rows.map(r => JSON.stringify(r)).join('\n');
const baseHook = { session_id: 's', transcript_path: '/fixture/session.jsonl' };
function recorder() {
  const calls = [];
  const invoke = (command, input) => {
    calls.push({ command, input });
    return { schema_version: 1, status: command === 'recall' ? 'recalled' : command === 'session-status' ? 'registered' : 'queued', context: 'UNTRUSTED RECALL SENTINEL' };
  };
  return { calls, invoke };
}
const piUser = (id, text) => ({ type: 'message', id, message: { role: 'user', content: text } });
const piAnswer = (id, text, stopReason = 'stop') => ({ type: 'message', id, message: { role: 'assistant', content: [{ type: 'thinking', thinking: 'REASONING_SENTINEL' }, { type: 'text', text }], stopReason } });

test('Claude registers native resume without reading history, stages original text and completes native final', () => {
  const { calls, invoke } = recorder();
  const neverRead = () => assert.fail('Claude native hook must not read transcripts');
  handleHook('claude-code', { ...baseHook, hook_event_name: 'SessionStart', source: 'resume' }, descriptor, invoke, neverRead);
  handleHook('claude-code', { ...baseHook, hook_event_name: 'UserPromptSubmit', prompt_id: 'p1', prompt: 'new user text' }, descriptor, invoke, neverRead);
  handleHook('claude-code', { ...baseHook, hook_event_name: 'Stop', prompt_id: 'p1', last_assistant_message: 'new answer' }, descriptor, invoke, neverRead);
  assert.deepEqual(calls.map(c => c.command), ['session', 'stage-turn', 'recall', 'complete-turn']);
  assert.deepEqual(calls[0].input.baseline, []);
  assert.equal(calls[0].input.fresh, false);
  assert.equal(calls[1].input.prompt, 'new user text');
  assert.equal(calls[3].input.text, 'new answer');
  assert.equal(calls[1].input.turn_id, calls[3].input.turn_id);
});
test('Claude refuses missing prompt IDs, subagents, unknown versions and incomplete stops before core writes', () => {
  for (const input of [
    { hook_event_name: 'UserPromptSubmit', prompt: 'x' },
    { hook_event_name: 'Stop', prompt_id: 'p' },
    { hook_event_name: 'StopFailure', last_assistant_message: 'API_ERROR_SENTINEL' },
    { hook_event_name: 'SessionStart', source: 'startup', agent_id: 'child' },
  ]) {
    const { calls, invoke } = recorder();
    assert.throws(() => handleHook('claude-code', { ...baseHook, ...input }, descriptor, invoke));
    assert.equal(calls.length, 0);
  }
  assert.throws(() => handleHook('claude-code', { ...baseHook, hook_event_name: 'SessionStart', source: 'startup' }, { ...descriptor, agentVersion: 'latest' }, () => assert.fail()));
});
test('Claude API failure aborts only that native staged turn before the next prompt', () => {
  const { calls, invoke } = recorder();
  handleHook('claude-code', { ...baseHook, hook_event_name: 'StopFailure', prompt_id: 'failed-turn', error: 'rate_limit', last_assistant_message: 'API_ERROR_SENTINEL' }, descriptor, invoke);
  handleHook('claude-code', { ...baseHook, hook_event_name: 'UserPromptSubmit', prompt_id: 'new-turn', prompt: 'new prompt' }, descriptor, invoke);
  assert.equal(calls[0].command, 'abort-turn');
  assert.equal(calls[0].input.turn_id, 'failed-turn');
  assert(!JSON.stringify(calls).includes('API_ERROR_SENTINEL'));
  assert.equal(calls[1].command, 'stage-turn');
});

const codexRows = [
  { type: 'session_meta', payload: { id: 's', source: 'cli', cli_version: '0.163.0' } },
  { type: 'event_msg', payload: { type: 'task_started', turn_id: 'old' } },
  { type: 'event_msg', payload: { type: 'user_message', message: 'OLD_USER_SENTINEL' } },
  { type: 'response_item', payload: { role: 'tool', content: 'TOOL_SENTINEL' } },
  { type: 'event_msg', payload: { type: 'agent_reasoning', text: 'REASONING_SENTINEL' } },
  { type: 'event_msg', payload: { type: 'task_complete', turn_id: 'old', last_agent_message: 'OLD_ANSWER_SENTINEL' } },
];
test('Codex supplies explicit old baseline, then full immutable snapshot to core suffix validation', () => {
  const { calls, invoke } = recorder();
  const d = { ...descriptor, agentVersion: '0.163.0' };
  handleHook('codex-cli', { ...baseHook, hook_event_name: 'SessionStart', source: 'resume' }, d, invoke, () => jsonl(codexRows));
  const next = [...codexRows,
    { type: 'event_msg', payload: { type: 'task_started', turn_id: 'new' } },
    { type: 'event_msg', payload: { type: 'user_message', message: 'new text' } },
  ];
  handleHook('codex-cli', { ...baseHook, hook_event_name: 'Stop', turn_id: 'new', last_assistant_message: 'new answer' }, d, invoke, () => jsonl(next));
  assert.equal(calls[0].command, 'session');
  assert.equal(calls[0].input.baseline.length, 2);
  assert.equal(calls[1].command, 'capture-transcript');
  assert.equal(calls[1].input.messages.length, 4);
  assert.deepEqual(calls[1].input.messages.slice(0, 2), calls[0].input.baseline);
  assert(!JSON.stringify(calls).includes('TOOL_SENTINEL'));
  assert(!JSON.stringify(calls).includes('REASONING_SENTINEL'));
});
test('Codex refuses missing/mismatched session, unclosed old turns and rollback markers', () => {
  assert.throws(() => codexTranscript(codexRows, 'other'));
  assert.throws(() => codexTranscript(codexRows.slice(1), 's'));
  assert.throws(() => codexTranscript(codexRows.slice(0, -1), 's'));
  assert.throws(() => codexTranscript([...codexRows, { type: 'event_msg', payload: { type: 'thread_rolled_back' } }], 's'));
  assert.throws(() => codexTranscript([...codexRows, { type: 'event_msg', payload: { type: 'task_started' } }], 's'));
  assert.throws(() => codexTranscript(codexRows, 's', null, '0.162.0'));
  for (const source of ['vscode', 'exec', 'desktop', { subagent: {} }, null]) {
    assert.throws(() => codexTranscript([{ type: 'session_meta', payload: { id: 's', source } }, ...codexRows.slice(1)], 's'));
  }
});
test('Claude Stop-hook continuations refuse a second final under the same prompt ID', () => {
  const { calls, invoke } = recorder();
  handleHook('claude-code', { ...baseHook, hook_event_name: 'Stop', prompt_id: 'p', last_assistant_message: 'first answer' }, descriptor, invoke);
  assert.throws(() => handleHook('claude-code', { ...baseHook, hook_event_name: 'Stop', prompt_id: 'p', stop_hook_active: true, last_assistant_message: 'changed answer' }, descriptor, invoke));
  assert.equal(calls.length, 1);
});
test('Transcript normalizers exclude custom, tool, synthetic and hidden reasoning material', () => {
  const pi = piTranscript([piUser('u', 'hello'), { type: 'custom_message', id: 'r', content: 'RECALL_SENTINEL' },
    { type: 'message', id: 't', message: { role: 'toolResult', content: 'TOOL_SENTINEL' } }, piAnswer('a', 'answer')]);
  assert.deepEqual(pi.map(m => m.text), ['hello', 'answer']);
  assert.equal(piTranscript([piAnswer('a', 'ABORT_SENTINEL', 'aborted')]).length, 0);
  const claude = claudeTranscript([
    { type: 'user', uuid: 'u', sessionId: 's', message: { role: 'user', content: 'hello' } },
    { type: 'user', uuid: 't', message: { role: 'user', content: [{ type: 'tool_result', content: 'TOOL_SENTINEL' }] } },
    { type: 'user', uuid: 'i', isMeta: true, message: { role: 'user', content: 'RECALL_SENTINEL' } },
    { type: 'assistant', uuid: 'a', message: { role: 'assistant', content: [{ type: 'thinking', thinking: 'REASONING_SENTINEL' }, { type: 'text', text: 'answer' }] } },
  ], 's');
  assert.deepEqual(claude.map(m => m.text), ['hello', 'answer']);
  assert.throws(() => piTranscript([piUser('u', 'one'), piUser('u', 'two')]));
});

test('Pi candidate refuses older callback contracts and keeps cancelled parser users excluded', () => {
  assert.throws(() => createPiAdapter({ ...descriptor, agentVersion: '1.1.0' }, () => assert.fail()));
  const later = piTranscript([piUser('cancelled', 'CANCELLED_USER_SENTINEL'), piAnswer('bad', 'partial', 'aborted'), piUser('new', 'new user'), piAnswer('good', 'complete')]);
  assert.deepEqual(later.map(m => m.text), ['new user', 'complete']);
  assert.throws(() => piTranscript([piUser('pending-old', 'OLD_PENDING_SENTINEL')], { strictPending: true }));
});

const v1User = (id, text) => ({ info: { id, sessionID: 's', role: 'user', time: { created: 1 } }, parts: [{ type: 'text', text }] });
const v1Answer = { info: { id: 'a', sessionID: 's', role: 'assistant', time: { completed: 2 }, finish: 'stop' },
  parts: [{ type: 'reasoning', text: 'REASONING_SENTINEL' }, { type: 'text', text: 'answer' }] };
test('OpenCode v1 lifecycle captures only enrolled snapshot and excludes recalled synthetic part', async () => {
  const { calls, invoke } = recorder(); const errors = [];
  let rows = [];
  const plugin = await createOpenCodeV1({ ...descriptor, agentVersion: '1.18.35' }, invoke, e => errors.push(e))({ client: { session: { messages: async () => ({ data: rows }) } } });
  await plugin.event({ event: { type: 'session.created', properties: { info: { id: 's' } } } });
  const output = v1User('u', 'question');
  await plugin['chat.message']({ sessionID: 's' }, { message: output.info, parts: output.parts });
  assert.equal(output.parts.at(-1).synthetic, true);
  rows = [output, v1Answer];
  await plugin.event({ event: { type: 'session.idle', properties: { sessionID: 's' } } });
  assert.deepEqual(calls.at(-1).input.messages.map(m => m.text), ['question', 'answer']);
  assert.equal(errors.length, 0);
});
test('OpenCode v1 rejects forks, partial responses and mixed session snapshots', async () => {
  assert.throws(() => opencodeV1Transcript([v1User('u', 'x')], 'other'));
  assert.equal(opencodeV1Transcript([{ ...v1Answer, info: { ...v1Answer.info, time: {} } }], 's').length, 0);
  const { calls, invoke } = recorder(); const errors = [];
  const plugin = await createOpenCodeV1({ ...descriptor, agentVersion: '1.18.35' }, invoke, e => errors.push(e))({ client: {} });
  await plugin.event({ event: { type: 'session.created', properties: { info: { id: 'fork', parentID: 'parent' } } } });
  assert.equal(calls.length, 0); assert.equal(errors.length, 1);
});
test('OpenCode v2 uses durable data envelope and different native message schema', async () => {
  const { calls, invoke } = recorder(); const errors = []; let contextHandler; let disposed = false;
  let rows = [];
  const pending = [];
  let wake;
  const iterator = { next: () => pending.length ? Promise.resolve({ value: pending.shift() }) : new Promise(resolve => { wake = resolve; }),
    return: async () => { wake?.({ done: true }); return { done: true }; }, [Symbol.asyncIterator]() { return this; } };
  const ctx = { event: { subscribe: () => iterator }, session: {
    hook: async (event, handler) => { assert.equal(event, 'context'); contextHandler = handler; return { dispose: async () => { disposed = true; } }; },
    context: async () => rows,
  } };
  const cleanup = await createOpenCodeV2({ ...descriptor, agentVersion: '2.0.32' }, invoke, e => errors.push(e)).setup(ctx);
  const push = async event => { const resolve = wake; wake = null; if (resolve) resolve({ value: event }); else pending.push(event); await new Promise(r => setImmediate(r)); };
  await push({ type: 'session.created', data: { sessionID: 's' } });
  rows = [{ type: 'user', id: 'u', text: 'question' }];
  const event = { sessionID: 's', messages: [], system: [] };
  await contextHandler(event);
  assert.equal(event.system.length, 0);
  assert.equal(event.messages.at(-1).content[0].text, 'UNTRUSTED RECALL SENTINEL');
  rows.push({ type: 'synthetic', id: 'x', text: 'SYNTHETIC_SENTINEL' }, { type: 'assistant', id: 'a', time: { completed: 2 }, finish: 'stop', content: [{ type: 'reasoning', text: 'REASONING_SENTINEL' }, { type: 'text', text: 'answer' }] });
  await push({ type: 'session.execution.succeeded', data: { sessionID: 's' } });
  assert.deepEqual(calls.at(-1).input.messages.map(m => m.text), ['question', 'answer']);
  await cleanup(); assert.equal(disposed, true); assert.equal(errors.length, 0);
  assert.equal(opencodeV2Transcript([{ type: 'assistant', id: 'bad', content: [{ type: 'text', text: 'PARTIAL_SENTINEL' }], time: {} }]).length, 0);
});
test('Artifact plans pin exact versions and native config keys without mutating input', () => {
  const args = { version: '2.1.302', runtime: '/node', cli: '/release/cli.mjs', releaseDir: "/release/quote'$path", descriptorPath: '/private/descriptor.json', owner: 'fixture', home: '/synthetic-user' };
  const claude = adapterArtifacts({ ...args, adapter: 'claude-code' });
  assert.equal(claude.jsonPatches.length, 4);
  assert.equal(claude.jsonPatches[0].path, '/synthetic-user/.claude/settings.json');
  assert(claude.jsonPatches[0].value.hooks[0].command.includes("'\\''"));
  const v1 = adapterArtifacts({ ...args, adapter: 'opencode-v1', version: '1.18.35' });
  const v2 = adapterArtifacts({ ...args, adapter: 'opencode-v2', version: '2.0.32' });
  assert.deepEqual(v1.jsonPatches[0].arrayPath, ['plugin']);
  assert.deepEqual(v2.jsonPatches[0].arrayPath, ['plugins']);
  for (const adapter of ['grok', 'gemini', 'hermes', 'codex-desktop', 't3']) assert.throws(() => adapterArtifacts({ ...args, adapter }));
  assert.throws(() => adapterArtifacts({ ...args, adapter: 'pi', version: 'latest' }));
});
test('Bridge uses absolute recorded executable, JSON stdin, no shell or raw diagnostics', () => {
  let observed;
  const invoke = makeInvoker(descriptor, (executable, argv, options) => {
    observed = { executable, argv, options };
    return { status: 0, stdout: JSON.stringify({ schema_version: 1, status: 'queued' }) };
  });
  invoke('capture-transcript', { secret: 'SENSITIVE_SENTINEL' });
  assert.equal(observed.executable, '/qualified/node'); assert.equal(observed.options.shell, false);
  assert(!JSON.stringify(observed.argv).includes('SENSITIVE_SENTINEL'));
  assert(observed.options.input.includes('SENSITIVE_SENTINEL'));
  for (const stdout of ['bad', '{}', '{"schema_version":1,"status":"failed"}']) assert.throws(() => makeInvoker(descriptor, () => ({ status: 0, stdout }))('capture', {}));
  let diagnosticText = '';
  diagnostic(new Error('SENSITIVE_SENTINEL'), text => { diagnosticText = text; });
  assert(!diagnosticText.includes('SENSITIVE_SENTINEL')); assert(diagnosticText.includes('capture was not confirmed'));
});
test('Descriptor/transcript reads reject permissive descriptors and symlinks in isolated temporary files', () => {
  const root = mkdtempSync(join(tmpdir(), 'hindsight-adapter-'));
  try {
    const qualified={...descriptor,agent_identity:{path:'/synthetic'},runtime_identity:{path:'/synthetic'}};
    const path = join(root, 'descriptor.json'); writeFileSync(path, JSON.stringify(qualified), { mode: 0o600 });
    assert.deepEqual(readPrivateJson(path), qualified);
    chmodSync(path, 0o644); assert.throws(() => readPrivateJson(path));
    chmodSync(path, 0o600); symlinkSync(path, join(root, 'link'));
    assert.throws(() => readPrivateJson(join(root, 'link')));
    assert.throws(() => readTranscript(join(root, 'link')));
    assert.throws(() => readTranscript('relative'));
    linkSync(path, join(root, 'hardlink')); assert.throws(() => readPrivateJson(path));
    assert.throws(() => readTranscript(path)); rmSync(join(root, 'hardlink'));
    chmodSync(path, 0o622); assert.throws(() => readTranscript(path)); chmodSync(path, 0o600);
    const unsafe = join(root, 'unsafe'); mkdirSync(unsafe); chmodSync(unsafe, 0o777);
    const child = join(unsafe, 'child'); writeFileSync(child, '{}', { mode: 0o600 });
    assert.throws(() => readPrivateJson(child)); assert.throws(() => readTranscript(child));
    symlinkSync(root, join(root, 'alias')); assert.throws(() => readTranscript(join(root, 'alias', 'descriptor.json')));
  } finally { rmSync(root, { recursive: true, force: true }); }
});
test('Codex prompt recall rechecks actual native route/version before any core call',()=>{
 const d={...descriptor,agentVersion:'0.163.0'};const input={...baseHook,hook_event_name:'UserPromptSubmit',turn_id:'new',prompt:'new prompt'};
 for(const payload of [{id:'s',source:'desktop',cli_version:'0.163.0'},{id:'s',source:'cli',cli_version:'0.162.0'},{id:'other',source:'cli',cli_version:'0.163.0'}]){
  const {calls,invoke}=recorder();assert.throws(()=>handleHook('codex-cli',input,d,invoke,()=>jsonl([{type:'session_meta',payload}])));assert.equal(calls.length,0);
 }
 const {calls,invoke}=recorder();handleHook('codex-cli',input,d,invoke,()=>jsonl(codexRows));assert.deepEqual(calls.map(call=>call.command),['session-status','recall']);
});
