import { diagnostic, envelope, makeInvoker, readPrivateJson, requireValue } from './common.mjs';
import { piTranscript } from './transcripts.mjs';

export const PI_VERSIONS = ['1.1.0', '1.3.0'];

export function createPiAdapter(descriptor, invoke = makeInvoker(descriptor), report = diagnostic) {
  requireValue(PI_VERSIONS.includes(descriptor.agentVersion), 'unqualified_agent_version');
  return function hindsightMemory(pi) {
    let prompt = null;
    let recalled = null;
    const base = ctx => envelope('pi', ctx.sessionManager.getSessionId(), descriptor.owner);
    const safely = fn => async (...args) => { try { return await fn(...args); } catch (error) { report(error); } };
    pi.on('session_start', safely(async (event, ctx) => {
      prompt = null; recalled = null;
      requireValue(['startup', 'reload', 'new', 'resume', 'fork'].includes(event.reason), 'unsupported_start_boundary');
      const baseline = piTranscript(ctx.sessionManager.getBranch());
      invoke('session', { ...base(ctx), baseline, fresh: ['startup', 'new'].includes(event.reason) && baseline.length === 0 });
    }));
    pi.on('before_agent_start', safely(async (event, ctx) => {
      prompt = event.messageType && event.messageType !== 'user' ? null : event.prompt;
      recalled = null;
    }));
    pi.on('context', safely(async (event, ctx) => {
      if (typeof prompt !== 'string') return;
      const branch = piTranscript(ctx.sessionManager.getBranch());
      const user = branch.findLast(m => m.role === 'user');
      requireValue(user && user.text === prompt, 'missing_prompt_identity');
      const state = invoke('session-status', base(ctx));
      requireValue(state.status === 'registered', 'session_not_registered');
      if (recalled === null) recalled = invoke('recall', { ...base(ctx), query: prompt, turn_id: user.id });
      if (recalled.status === 'recalled' && typeof recalled.context === 'string') {
        // context transforms are request-local. Even if another extension later
        // persists it, role=custom is excluded from piTranscript.
        return { messages: [...event.messages, { role: 'custom', customType: 'hindsight-memory-untrusted',
          content: recalled.context, display: false, timestamp: Date.now() }] };
      }
    }));
    pi.on('agent_end', safely(async (event, ctx) => {
      const last = event.messages?.filter(m => m.role === 'assistant').at(-1);
      requireValue(last && ['stop', 'length'].includes(last.stopReason), 'incomplete_turn_boundary');
      invoke('capture-transcript', { ...base(ctx), messages: piTranscript(ctx.sessionManager.getBranch()) });
      prompt = null; recalled = null;
    }));
    // Tree switches retain their existing core cutoff. A changed prefix refuses
    // capture; no new baseline is silently created for an existing session.
  };
}

export function piFromDescriptor(path) { return createPiAdapter(readPrivateJson(path)); }
