import {performance} from 'node:perf_hooks';
import { spawnSync } from 'node:child_process';
import { lstatSync, realpathSync, fstatSync, openSync, readSync, closeSync, constants } from 'node:fs';
import {readPrivate, RECALL_DEADLINE_MS} from '../src/config.mjs';
import { isAbsolute, dirname } from 'node:path';

export const MAX_TRANSCRIPT_BYTES = 8 * 1024 * 1024;
export class AdapterError extends Error {
  constructor(code) { super(code); this.code = code; }
}
export function requireValue(ok, code = 'invalid_native_event') {
  if (!ok) throw new AdapterError(code);
}
export function identifier(value) {
  requireValue(typeof value === 'string' && value.length > 0 && value.length <= 512);
  return value;
}
export function textOnly(content) {
  if (typeof content === 'string') return content;
  requireValue(Array.isArray(content));
  return content.filter(p => p?.type === 'text' && typeof p.text === 'string').map(p => p.text).join('\n');
}
export function message(id, role, text) {
  identifier(id);
  requireValue(['user', 'assistant'].includes(role) && typeof text === 'string');
  return { id, role, text, completed: true };
}
export function unique(messages) {
  const ids = new Set();
  for (const m of messages) {
    requireValue(!ids.has(m.id), 'duplicate_native_id'); ids.add(m.id);
  }
  requireValue(Buffer.byteLength(JSON.stringify(messages)) <= MAX_TRANSCRIPT_BYTES, 'transcript_limit');
  return messages;
}
export function safeParents(file) {
  for(let parent=dirname(file);;parent=dirname(parent)){
    const stat=lstatSync(parent);const sticky=stat.uid===0 && (stat.mode & 0o1000)!==0;
    requireValue(stat.isDirectory() && !stat.isSymbolicLink() && [0,process.getuid()].includes(stat.uid) && (!(stat.mode & 0o022) || sticky),'unsafe_adapter_parent');
    if(parent===dirname(parent))break;
  }
}
export function readPrivateJson(path) {
  requireValue(isAbsolute(path), 'absolute_path_required');
  const text=readPrivate(path);requireValue(Buffer.byteLength(text)<=16*1024,'descriptor_limit');const descriptor=JSON.parse(text);requireValue(descriptor.agent_identity && descriptor.runtime_identity,'missing_native_qualification');return descriptor;
}
export function readBounded(fd, maximum) {
  const buffer = Buffer.alloc(maximum + 1);
  let offset = 0;
  while (offset <= maximum) {
    const bytes = readSync(fd, buffer, offset, buffer.length - offset, null);
    if (!bytes) break;
    offset += bytes;
  }
  requireValue(offset <= maximum, 'input_limit');
  return buffer.subarray(0, offset).toString('utf8');
}
export function readTranscript(path) {
  requireValue(isAbsolute(path), 'absolute_path_required');
  safeParents(path);
  // No directory scans, relative paths or symlinked transcript files.
  const stat = lstatSync(path);
  requireValue(stat.isFile() && !stat.isSymbolicLink() && stat.nlink===1 && stat.uid === process.getuid() && !(stat.mode & 0o022), 'unsafe_transcript');
  requireValue(stat.size <= MAX_TRANSCRIPT_BYTES, 'transcript_limit');
  const fd = openSync(path, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
  try {
    const actual = fstatSync(fd);
    requireValue(actual.isFile() && actual.ino === stat.ino && actual.dev === stat.dev && actual.nlink===1 && actual.uid === process.getuid() && !(actual.mode & 0o022), 'unsafe_transcript');
    return readBounded(fd, MAX_TRANSCRIPT_BYTES);
  } finally { closeSync(fd); }
}
export function jsonLines(text) {
  return text.split('\n').filter(line => line.trim()).map(line => JSON.parse(line));
}
export function makeInvoker(descriptor, run = spawnSync) {
  requireValue(descriptor.schema_version === 1 && isAbsolute(descriptor.runtime) && isAbsolute(descriptor.cli), 'invalid_adapter_descriptor');
  identifier(descriptor.owner);
  return (command, input) => {
    const started=performance.now();
    if(descriptor.agent_identity){const expected=descriptor.agent_identity;requireValue(realpathSync(expected.requested)===expected.path,'agent_changed_requalify');safeParents(expected.requested);const actual=lstatSync(expected.path);requireValue(actual.isFile() && !actual.isSymbolicLink() && actual.dev===expected.dev && actual.ino===expected.ino && actual.size===expected.size && actual.mtimeMs===expected.mtimeMs,'agent_changed_requalify');}
    if(descriptor.runtime_identity){const actual=lstatSync(descriptor.runtime);const expected=descriptor.runtime_identity;requireValue(actual.isFile() && !actual.isSymbolicLink() && actual.dev===expected.dev && actual.ino===expected.ino && actual.size===expected.size && actual.mtimeMs===expected.mtimeMs,'runtime_changed_requalify');}
    const payload=JSON.stringify(command==='recall'?{...input,recall_deadline_utc_ms:Date.now()+RECALL_DEADLINE_MS}:input);
    const result = run(descriptor.runtime, [descriptor.cli, command], {
      input: payload, encoding: 'utf8', timeout: command === 'recall' ? Math.max(1,Math.floor(RECALL_DEADLINE_MS-(performance.now()-started))) : 5000,
      maxBuffer: 300 * 1024, shell: false, windowsHide: true,
      // No shell and no credential values in argv. Core validates runtime/config/state.
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    if(command==='recall' && performance.now()-started>=RECALL_DEADLINE_MS)return {schema_version:1,status:'recall-unavailable',context:''};
    if (result.error || result.status !== 0) {
      let failed;try{failed=JSON.parse(result.stdout);}catch{}
      if(failed?.schema_version===1 && failed.status==='failed' && failed.reason==='state-busy-admission-not-confirmed')throw new AdapterError('state_busy_admission_not_confirmed');
      throw new AdapterError('local_admission_failed');
    }
    let parsed;
    try { parsed = JSON.parse(result.stdout); } catch { throw new AdapterError('invalid_core_result'); }
    requireValue(parsed.schema_version === 1 && typeof parsed.status === 'string', 'invalid_core_result');
    requireValue(!['failed', 'rejected', 'partial', 'unsupported'].includes(parsed.status), 'local_admission_failed');
    const expected={session:['registered'],'session-status':['registered'],'capture-transcript':['queued','duplicate'],capture:['queued','duplicate'],'stage-turn':['staged'],'complete-turn':['queued','duplicate'],'abort-turn':['aborted'],recall:['recalled','recall-already-attempted','recall-unavailable','recall-output-budget']};
    requireValue(expected[command]?.includes(parsed.status),'invalid_core_result');
    return parsed;
  };
}
export function envelope(agent, session, owner) {
  return { schema_version: 1, agent, session: identifier(session), owner: identifier(owner) };
}
export function diagnostic(error, write = text => process.stderr.write(text)) {
  const code = error instanceof AdapterError ? error.code : 'adapter_failed';
  write(`hindsight-memory: ${code}; conversation continues; capture was not confirmed\n`);
}
