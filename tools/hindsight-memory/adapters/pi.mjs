import { createHash, randomUUID } from 'node:crypto';
import { closeSync, fstatSync, openSync, readSync, realpathSync } from 'node:fs';
import { isAbsolute } from 'node:path';
import { fileURLToPath } from 'node:url';
import { destination as configDestination, loadConfig, paths } from '../src/config.mjs';
import { diagnostic, envelope, identifier, makeInvoker, readPrivateJson, requireValue, textOnly } from './common.mjs';

// Candidate only. cli.mjs still refuses production activation for every adapter.
export const PI_VERSIONS = ['1.3.0'];
export const PI_ELF_SHA256 = 'c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca';
let executableCache;

export function observePiProcess() {
  requireValue(process.platform === 'linux', 'unqualified_pi_process');
  const fd = openSync('/proc/self/exe', 'r');
  try {
    const stat = fstatSync(fd);
    const identity = { dev: stat.dev, ino: stat.ino, size: stat.size, mtimeMs: stat.mtimeMs };
    const key = JSON.stringify(identity);
    if (executableCache?.key !== key) {
      const hash = createHash('sha256');
      const buffer = Buffer.alloc(1024 * 1024);
      let offset = 0;
      let elf = false;
      for (;;) {
        const count = readSync(fd, buffer, 0, buffer.length, offset);
        if (!count) break;
        if (!offset) elf = buffer.subarray(0, 4).equals(Buffer.from([0x7f, 0x45, 0x4c, 0x46]));
        hash.update(buffer.subarray(0, count));
        offset += count;
      }
      executableCache = { key, sha256: hash.digest('hex'), elf };
    }
    return { platform: process.platform, executable: realpathSync('/proc/self/exe'), identity,
      sha256: executableCache.sha256, elf: executableCache.elf,
      // Pinned cli.ts passes this exact slice to main after setupCli sets process.title.
      argv: process.argv.slice(2),
      preloads: ['NODE_OPTIONS', 'BUN_OPTIONS', 'LD_PRELOAD', 'LD_LIBRARY_PATH'].filter(key => process.env[key]) };
  } finally { closeSync(fd); }
}

export function qualifyPiProcess(descriptor, bridgePath, observed) {
  const expected = descriptor.agent_identity;
  requireValue(PI_VERSIONS.includes(descriptor.agentVersion) && expected && isAbsolute(expected.path || '') &&
    isAbsolute(expected.requested || '') && isAbsolute(bridgePath || ''), 'unqualified_pi_process');
  requireValue(observed?.platform === 'linux' && observed.elf === true && observed.sha256 === PI_ELF_SHA256 &&
    observed.executable === expected.path && ['dev', 'ino', 'size', 'mtimeMs'].every(key => observed.identity?.[key] === expected[key]), 'unqualified_pi_process');
  requireValue(Array.isArray(observed.preloads) && observed.preloads.length === 0 &&
    JSON.stringify(observed.argv) === JSON.stringify(['--no-extensions', '-e', bridgePath]), 'unqualified_pi_argv');
}

function configuredDestination() {
  const config = loadConfig(paths());
  requireValue(config.adapters.includes('pi'), 'pi_not_selected');
  return { endpoint: config.endpoint, bank: config.bank };
}
function destinationKey(value) {
  requireValue(typeof value?.endpoint === 'string' && typeof value?.bank === 'string', 'missing_pi_destination');
  return JSON.stringify([value.endpoint, value.bank]);
}
function freshMetadata(entries) {
  // Pi SDK creates only this root metadata before emitting session_start(reason=new).
  const thinking = entries.at(-1);
  if (thinking?.type !== 'thinking_level_change' || typeof thinking.thinkingLevel !== 'string') return false;
  if (entries.length === 1) return thinking.parentId === null;
  const model = entries[0];
  return entries.length === 2 && model.type === 'model_change' && model.parentId === null &&
    typeof model.provider === 'string' && typeof model.modelId === 'string' && thinking.parentId === model.id;
}
function plainUser(message) {
  requireValue(message?.role === 'user' && (typeof message.content === 'string' ||
    (Array.isArray(message.content) && message.content.every(part => part?.type === 'text' && typeof part.text === 'string'))), 'changed_pi_user');
  return textOnly(message.content);
}

export function createPiAdapter(descriptor, invoke = makeInvoker(descriptor), report = diagnostic,
  { bridgePath, observeProcess = observePiProcess, readDestination = configuredDestination } = {}) {
  requireValue(PI_VERSIONS.includes(descriptor.agentVersion), 'unqualified_agent_version');
  return function hindsightMemory(pi) {
    let consent = null;
    let candidate = null;
    let epoch = 0;
    const route = () => qualifyPiProcess(descriptor, bridgePath, observeProcess());
    const base = ctx => envelope('pi', ctx.sessionManager.getSessionId(), descriptor.owner);
    const destination = () => destinationKey(readDestination());
    const authorized = ctx => {
      route();
      requireValue(consent && consent.session === ctx.sessionManager.getSessionId() && ctx.mode === 'tui' &&
        destination() === consent.destination, 'pi_consent_required');
    };
    const call = (command, input) => {
      route();
      requireValue(consent && destination() === consent.destination, 'pi_destination_changed');
      return invoke(command, { ...input, expected_destination: consent.digest });
    };
    const discard = () => {
      const pending = candidate;
      candidate = null;
      if (pending?.staged) call('abort-turn', { ...pending.base, turn_id: pending.turnId });
    };
    const invalidate = () => {
      epoch++;
      try { discard(); } finally { consent = null; }
    };
    const safely = fn => async (...args) => {
      try { return await fn(...args); }
      catch (error) {
        try { discard(); } catch (abortError) { report(abortError); }
        // A failed durable call may have admitted work. Never retry it with a new identity.
        consent = null;
        epoch++;
        report(error);
      }
    };
    const branch = ctx => {
      const entries = ctx.sessionManager.getBranch();
      requireValue(Array.isArray(entries) && new Set(entries.map(entry => entry.id)).size === entries.length, 'invalid_pi_branch');
      for (const entry of entries) identifier(entry.id);
      return entries;
    };
    const suffix = ctx => {
      authorized(ctx);
      requireValue(candidate && candidate.session === consent.session && !ctx.hasPendingMessages() && !ctx.signal?.aborted, 'unmatched_pi_run');
      const entries = branch(ctx);
      requireValue(candidate.prefix.every((id, index) => entries[index]?.id === id), 'changed_pi_branch');
      return entries.slice(candidate.prefix.length);
    };
    const bindUser = ctx => {
      const entries = suffix(ctx);
      const users = entries.filter(entry => entry.type === 'message' && entry.message?.role === 'user');
      requireValue(users.length === 1 && plainUser(users[0].message) === candidate.prompt, 'missing_prompt_identity');
      identifier(users[0].id);
      requireValue(!candidate.userId || candidate.userId === users[0].id, 'changed_pi_user');
      candidate.userId = users[0].id;
      return entries;
    };
    pi.on('session_start', safely(async (event, ctx) => {
      invalidate();
      route();
      requireValue(event.reason === 'new' && ctx.mode === 'tui' && ctx.hasUI === true && ctx.isIdle() &&
        !ctx.hasPendingMessages() && !ctx.signal?.aborted && freshMetadata(branch(ctx)), 'pi_fresh_session_required');
      const session = ctx.sessionManager.getSessionId();
      const initial = JSON.stringify(branch(ctx));
      const value = readDestination();
      const key = destinationKey(value);
      const token = epoch;
      const accepted = await ctx.ui.confirm('Personal Hindsight memory',
        `Retain new prompts and completed answers from this session in bank ${value.bank} at ${value.endpoint}, and recall personal memory into model requests?`);
      // A replaced session owns its own consent and slot; an old dialog cannot clear them.
      if (token !== epoch) return;
      requireValue(accepted === true && session === ctx.sessionManager.getSessionId() &&
        ctx.mode === 'tui' && ctx.isIdle() && !ctx.hasPendingMessages() && !ctx.signal?.aborted && freshMetadata(branch(ctx)) &&
        destination() === key && JSON.stringify(branch(ctx)) === initial, 'pi_consent_required');
      consent = { session, destination: key, digest: configDestination(value) };
      call('session', { ...base(ctx), baseline: [], fresh: true });
    }));
    pi.on('input', safely(async (event, ctx) => {
      authorized(ctx);
      // A second input invalidates the whole pair, including a queued steer/follow-up.
      if (candidate) { discard(); return; }
      requireValue(event.source === 'interactive' && ctx.isIdle() && !ctx.hasPendingMessages() &&
        !ctx.signal?.aborted && event.streamingBehavior === undefined && !event.images?.length &&
        typeof event.text === 'string' && event.text.length > 0 && !event.text.startsWith('/'), 'unqualified_pi_input');
      candidate = { session: consent.session, prompt: event.text, prefix: branch(ctx).map(entry => entry.id),
        turnId: randomUUID(), base: base(ctx), staged: false, userId: null, final: null, recall: null };
    }));
    pi.on('before_agent_start', safely(async (event, ctx) => {
      const entries = suffix(ctx);
      requireValue(!candidate.staged && event.messageType === 'user' && event.prompt === candidate.prompt &&
        !event.images?.length && entries.length === 0, 'unmatched_pi_run');
      // Pi validates model/auth before this callback. The native user is persisted later.
      candidate.staged = true;
      call('stage-turn', { ...candidate.base, turn_id: candidate.turnId, prompt: candidate.prompt });
    }));
    pi.on('context', safely(async (event, ctx) => {
      if (!candidate) return;
      requireValue(candidate.staged, 'unmatched_pi_run');
      bindUser(ctx);
      if (candidate.recall === null) candidate.recall = call('recall', { ...candidate.base, query: candidate.prompt, turn_id: candidate.turnId });
      if (candidate.recall.status === 'recalled' && typeof candidate.recall.context === 'string') {
        // Request-local only. Never persist or recapture the transformed request array.
        return { messages: [...event.messages, { role: 'custom', customType: 'hindsight-memory-untrusted',
          content: candidate.recall.context, display: false, timestamp: Date.now() }] };
      }
    }));
    pi.on('turn_end', safely(async (event, ctx) => {
      if (!candidate) return;
      const entries = bindUser(ctx);
      const entry = entries.find(entry => entry.id === event.messageEntryId);
      requireValue(entry?.type === 'message' && entry.message?.role === 'assistant' && event.message?.role === 'assistant' &&
        entry.message.stopReason === event.message.stopReason && textOnly(entry.message.content) === textOnly(event.message.content), 'missing_pi_final_identity');
      if (event.message.stopReason === 'toolUse') { candidate.final = null; return; }
      requireValue(event.outcome === 'completed' && event.message.stopReason === 'stop', 'incomplete_turn_boundary');
      candidate.final = { id: identifier(event.messageEntryId), text: textOnly(event.message.content), stopReason: 'stop' };
    }));
    pi.on('agent_settled', safely(async (event, ctx) => {
      if (!candidate) return;
      const entries = bindUser(ctx);
      requireValue(candidate.staged && candidate.userId && candidate.final && event.aborted === false && ctx.isIdle(), 'incomplete_turn_boundary');
      const assistants = entries.filter(entry => entry.type === 'message' && entry.message?.role === 'assistant');
      const final = assistants.at(-1);
      requireValue(final?.id === candidate.final.id && final.message.stopReason === 'stop' &&
        textOnly(final.message.content) === candidate.final.text, 'changed_pi_final');
      call('complete-turn', { ...candidate.base, turn_id: candidate.turnId, text: candidate.final.text });
      candidate = null;
    }));
    for (const event of ['session_before_switch', 'session_before_fork', 'session_before_tree', 'session_tree',
      'session_before_compact', 'session_compact', 'session_compact_failed', 'session_shutdown']) {
      pi.on(event, safely(invalidate));
    }
  };
}

export function piFromDescriptor(path, bridgeUrl) {
  try { return createPiAdapter(readPrivateJson(path), undefined, diagnostic, { bridgePath: fileURLToPath(bridgeUrl) }); }
  catch (error) {
    diagnostic(error);
    return function hindsightMemoryDisabled() {};
  }
}
