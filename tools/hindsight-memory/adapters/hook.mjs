import { pathToFileURL } from 'node:url';
import { AdapterError, diagnostic, envelope, jsonLines, makeInvoker, readBounded, readPrivateJson, readTranscript, requireValue } from './common.mjs';
import { claudeTranscript, codexTranscript } from './transcripts.mjs';

export const HOOK_VERSIONS = Object.freeze({
  'claude-code': ['2.1.302'],
  'codex-cli': ['0.162.0', '0.163.0'],
});

export function handleHook(agent, input, descriptor, invoke = makeInvoker(descriptor), read = readTranscript) {
  requireValue(HOOK_VERSIONS[agent]?.includes(descriptor.agentVersion), 'unqualified_agent_version');
  requireValue(!input.agent_id && !input.agent_type, 'subagent_route_unqualified');
  const base = envelope(agent, input.session_id, descriptor.owner);
  const event = input.hook_event_name;
  if (agent === 'claude-code') {
    // Native prompt_id and Stop text are the primary interface. Claude's
    // asynchronously written transcript cannot prove a completed current turn.
    if (event === 'SessionStart') {
      requireValue(['startup', 'resume', 'clear', 'fork', 'compact'].includes(input.source), 'unsupported_start_boundary');
      invoke('session', { ...base, baseline: [], fresh: ['startup', 'clear'].includes(input.source) });
      return {};
    }
    requireValue(typeof input.prompt_id === 'string' && input.prompt_id.length > 0, 'missing_prompt_identity');
    if (event === 'UserPromptSubmit') {
      requireValue(typeof input.prompt === 'string', 'missing_prompt');
      invoke('stage-turn', { ...base, turn_id: input.prompt_id, prompt: input.prompt });
      const recalled = invoke('recall', { ...base, turn_id: input.prompt_id, query: input.prompt });
      return recalled.status === 'recalled' && typeof recalled.context === 'string'
        ? { hookSpecificOutput: { hookEventName: event, additionalContext: recalled.context } } : {};
    }
    requireValue(event === 'Stop', 'unsupported_native_event');
    requireValue(typeof input.last_assistant_message === 'string' && input.last_assistant_message.length > 0, 'incomplete_turn_boundary');
    invoke('complete-turn', { ...base, turn_id: input.prompt_id, text: input.last_assistant_message });
    return {};
  }
  if (event === 'UserPromptSubmit') {
    requireValue(typeof input.prompt === 'string', 'missing_prompt');
    const state = invoke('session-status', base);
    requireValue(state.status === 'registered', 'session_not_registered');
    if (typeof input.turn_id !== 'string') return {};
    const result = invoke('recall', { ...base, query: input.prompt, turn_id: input.turn_id });
    if (result.status === 'recalled' && typeof result.context === 'string') {
      return { hookSpecificOutput: { hookEventName: event, additionalContext: result.context } };
    }
    return {};
  }
  requireValue(['SessionStart', 'Stop'].includes(event), 'unsupported_native_event');
  requireValue(typeof input.transcript_path === 'string', 'missing_transcript');
  const rows = jsonLines(read(input.transcript_path));
  const messages = agent === 'claude-code'
    ? claudeTranscript(rows, input.session_id)
    : codexTranscript(rows, input.session_id, event === 'Stop' ? input : null);
  if (event === 'SessionStart') {
    requireValue(['startup', 'resume', 'clear', 'fork'].includes(input.source), 'unsupported_start_boundary');
    invoke('session', { ...base, baseline: messages, fresh: ['startup', 'clear'].includes(input.source) && messages.length === 0 });
  } else {
    if (agent === 'claude-code') {
      requireValue(messages.at(-1)?.role === 'assistant' && typeof input.last_assistant_message === 'string'
        && messages.at(-1).text === input.last_assistant_message, 'incomplete_turn_boundary');
    }
    invoke('capture-transcript', { ...base, messages });
  }
  return {};
}

export function main(args = process.argv.slice(2)) {
  try {
    requireValue(args.length === 2 && HOOK_VERSIONS[args[0]], 'invalid_adapter_arguments');
    const inputText = readBounded(0, 1024 * 1024);
    const result = handleHook(args[0], JSON.parse(inputText), readPrivateJson(args[1]));
    process.stdout.write(JSON.stringify(result));
  } catch (error) {
    diagnostic(error instanceof SyntaxError ? new AdapterError('invalid_event_json') : error);
    // Hooks fail open for agent work, while core never acknowledges capture.
    process.exitCode = 1;
  }
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
