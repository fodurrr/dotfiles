import { createHash } from 'node:crypto';
import { diagnostic, envelope, makeInvoker, readPrivateJson, requireValue } from './common.mjs';
import { opencodeV1Transcript } from './transcripts.mjs';

export function createOpenCodeV1(descriptor, invoke = makeInvoker(descriptor), report = diagnostic) {
  requireValue(descriptor.agentVersion === '1.18.35', 'unqualified_agent_version');
  return async ({ client }) => {
    const base = session => envelope('opencode-v1', session, descriptor.owner);
    const snapshot = async session => {
      const response = await client.session.messages({ path: { id: session } });
      requireValue(Array.isArray(response.data), 'native_snapshot_failed');
      return opencodeV1Transcript(response.data, session);
    };
    return {
      'chat.message': async (input, output) => {
        try {
          requireValue(output.message?.sessionID === input.sessionID, 'session_mismatch');
          const normalized = opencodeV1Transcript([{ info: output.message, parts: output.parts }], input.sessionID);
          const user = normalized.at(-1);
          requireValue(user?.role === 'user', 'missing_prompt_identity');
          requireValue(invoke('session-status', base(input.sessionID)).status === 'registered', 'session_not_registered');
          const recalled = invoke('recall', { ...base(input.sessionID), turn_id: user.id, query: user.text });
          if (recalled.status === 'recalled' && typeof recalled.context === 'string') {
            // Native synthetic text parts are provider context, but are excluded
            // by opencodeV1Transcript on every later capture.
            output.parts.push({ id: 'prt_' + createHash('sha256').update(user.id).digest('hex').slice(0, 26),
              sessionID: input.sessionID, messageID: user.id, type: 'text', text: recalled.context, synthetic: true });
          }
        } catch (error) { report(error); }
      },
      event: async ({ event }) => {
        try {
          if (event.type === 'session.created') {
            requireValue(!event.properties.info.parentID, 'fork_route_unqualified');
            const session = event.properties.info.id;
            const baseline = await snapshot(session);
            invoke('session', { ...base(session), baseline, fresh: baseline.length === 0 });
          } else if (event.type === 'session.idle') {
            const session = event.properties.sessionID;
            invoke('capture-transcript', { ...base(session), messages: await snapshot(session) });
          }
        } catch (error) { report(error); }
      },
    };
  };
}
export function openCodeV1FromDescriptor(path) {
  try { return createOpenCodeV1(readPrivateJson(path)); }
  catch (error) { diagnostic(error); return async function hindsightMemoryDisabled() { return {}; }; }
}
