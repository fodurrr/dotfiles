import { diagnostic, envelope, makeInvoker, readPrivateJson, requireValue } from './common.mjs';
import { opencodeV2Transcript } from './transcripts.mjs';

export function createOpenCodeV2(descriptor, invoke = makeInvoker(descriptor), report = diagnostic) {
  requireValue(descriptor.agentVersion === '2.0.32', 'unqualified_agent_version');
  // Structurally matches Plugin.define from @opencode/plugin's Promise API.
  return {
    id: 'hindsight-memory',
    async setup(ctx) {
      const base = session => envelope('opencode-v2', session, descriptor.owner);
      const registration = await ctx.session.hook('context', async event => {
        try {
          const rows = opencodeV2Transcript(await ctx.session.context({ sessionID: event.sessionID }));
          const user = rows.findLast(m => m.role === 'user');
          requireValue(user, 'missing_prompt_identity');
          requireValue(invoke('session-status', base(event.sessionID)).status === 'registered', 'session_not_registered');
          const recalled = invoke('recall', { ...base(event.sessionID), turn_id: user.id, query: user.text });
          if (recalled.status === 'recalled' && typeof recalled.context === 'string') {
            // Request-local context only. Never put retrieved text in privileged
            // system parts or native stored user messages.
            event.messages.push({ role: 'user', content: [{ type: 'text', text: recalled.context }] });
          }
        } catch (error) { report(error); }
      });
      let stopped = false;
      const events = ctx.event.subscribe()[Symbol.asyncIterator]();
      const handle = async event => {
        const session = event.data?.sessionID;
        if (event.type === 'session.created') {
          requireValue(!event.data.parentID, 'fork_route_unqualified');
          const baseline = opencodeV2Transcript(await ctx.session.context({ sessionID: session }));
          invoke('session', { ...base(session), baseline, fresh: baseline.length === 0 });
        } else if (event.type === 'session.execution.succeeded') {
          invoke('capture-transcript', { ...base(session), messages: opencodeV2Transcript(await ctx.session.context({ sessionID: session })) });
        }
      };
      // Native event observation is not synchronous durable admission. A source
      // crash before dispatch remains a qualification gap, not accepted work.
      const loop = (async () => {
        try {
          while (!stopped) {
            const item = await events.next();
            if (item.done || stopped) break;
            try { await handle(item.value); } catch (error) { report(error); }
          }
        } catch (error) { if (!stopped) report(error); }
      })();
      // Do not wait for the event loop in setup or it would block agent startup.
      void loop;
      return async () => { stopped = true; await registration.dispose(); await events.return?.(); };
    },
  };
}
export function openCodeV2FromDescriptor(path) { return createOpenCodeV2(readPrivateJson(path)); }
