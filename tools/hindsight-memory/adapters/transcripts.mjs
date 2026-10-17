import { requireValue, message, textOnly, unique } from './common.mjs';

// These parsers consume only a native event's explicitly named session. They
// never enumerate session directories or choose a cutoff using timestamps.
export function claudeTranscript(rows, session) {
  const result = [];
  for (const row of rows) {
    if (row.sessionId !== undefined) requireValue(row.sessionId === session, 'session_mismatch');
    if (!['user', 'assistant'].includes(row.type) || row.isMeta || row.isSidechain || row.isCompactSummary) continue;
    const m = row.message;
    requireValue(m && m.role === row.type, 'unsupported_transcript_shape');
    if (Array.isArray(m.content) && m.content.some(p => p?.type === 'tool_result')) continue;
    const text = textOnly(m.content);
    // Claude serializes local command output and compaction notices as users.
    if (row.type === 'user' && /^<(local-command|command-name|system-reminder|ide_opened_file|ide_selection)/.test(text)) continue;
    if (text) result.push(message(row.uuid, row.type, text));
  }
  return unique(result);
}

export function codexTranscript(rows, session, stop = null) {
  const result = [];
  let turn = null;
  let sessionSeen = false;
  const finish = (final, error) => {
    requireValue(turn, 'missing_turn_boundary');
    if (!error && typeof final === 'string' && final && turn.users.length) {
      result.push(...turn.users, message(`${turn.id}:assistant`, 'assistant', final));
    }
    turn = null;
  };
  for (const row of rows) {
    if (row.type === 'session_meta') {
      requireValue(row.payload?.id === session, 'session_mismatch');
      requireValue(typeof row.payload.source !== 'object', 'subagent_route_unqualified');
      sessionSeen = true;
    }
    if (row.type !== 'event_msg') continue;
    const p = row.payload;
    if (['thread_rolled_back', 'context_compacted'].includes(p?.type)) {
      // Never recover through a changed transcript boundary implicitly.
      throw new Error('changed_transcript_boundary');
    }
    if (['task_started', 'turn_started'].includes(p?.type)) {
      requireValue(!turn, 'incomplete_turn_boundary');
      requireValue(typeof p.turn_id === 'string' && p.turn_id.length > 0, 'missing_turn_identity');
      turn = { id: p.turn_id, users: [] };
    } else if (p?.type === 'user_message') {
      requireValue(turn && typeof p.message === 'string', 'missing_turn_boundary');
      turn.users.push(message(`${turn.id}:user:${turn.users.length}`, 'user', p.message));
    } else if (['task_complete', 'turn_complete'].includes(p?.type)) {
      requireValue(turn?.id === p.turn_id, 'turn_mismatch');
      finish(p.last_agent_message, p.error);
    } else if (p?.type === 'turn_aborted') {
      turn = null;
    }
  }
  requireValue(sessionSeen, 'missing_session_boundary');
  if (turn) {
    requireValue(stop?.turn_id === turn.id && typeof stop.last_assistant_message === 'string', 'incomplete_turn_boundary');
    finish(stop.last_assistant_message, false);
  }
  return unique(result);
}

export function piTranscript(entries) {
  const result = [];
  for (const entry of entries) {
    if (entry.type !== 'message') continue;
    const m = entry.message;
    if (!['user', 'assistant'].includes(m?.role)) continue;
    // Error/abort fragments and tool-only assistant steps are not final answers.
    if (m.role === 'assistant' && !['stop', 'length'].includes(m.stopReason)) continue;
    const text = textOnly(m.content);
    if (text) result.push(message(entry.id, m.role, text));
  }
  return unique(result);
}

export function opencodeV1Transcript(rows, session) {
  const result = [];
  for (const row of rows) {
    const m = row.info;
    requireValue(m?.sessionID === session, 'session_mismatch');
    if (!['user', 'assistant'].includes(m.role)) continue;
    if (m.role === 'assistant' && (!m.time?.completed || m.error || m.summary || m.finish === 'tool-calls')) continue;
    requireValue(Array.isArray(row.parts), 'unsupported_transcript_shape');
    const text = row.parts.filter(p => p.type === 'text' && !p.synthetic && !p.ignored).map(p => {
      requireValue(typeof p.text === 'string'); return p.text;
    }).join('\n');
    if (text) result.push(message(m.id, m.role, text));
  }
  return unique(result);
}

export function opencodeV2Transcript(rows) {
  const result = [];
  for (const m of rows) {
    if (m.type === 'user') result.push(message(m.id, 'user', m.text));
    if (m.type === 'assistant' && m.time?.completed && !m.error && m.finish !== 'tool-calls') {
      const text = textOnly(m.content);
      if (text) result.push(message(m.id, 'assistant', text));
    }
  }
  return unique(result);
}
