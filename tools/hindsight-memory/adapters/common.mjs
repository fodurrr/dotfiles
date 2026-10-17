import { spawnSync } from 'node:child_process';
import { lstatSync, fstatSync, openSync, readSync, closeSync, constants } from 'node:fs';
import { isAbsolute } from 'node:path';

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
export function readPrivateJson(path) {
  requireValue(isAbsolute(path), 'absolute_path_required');
  const stat = lstatSync(path);
  requireValue(stat.isFile() && !stat.isSymbolicLink() && stat.uid === process.getuid() && (stat.mode & 0o077) === 0, 'unsafe_adapter_descriptor');
  requireValue(stat.size <= 16 * 1024, 'descriptor_limit');
  const fd = openSync(path, constants.O_RDONLY | constants.O_NOFOLLOW);
  try {
    const actual = fstatSync(fd);
    requireValue(actual.ino === stat.ino && actual.dev === stat.dev && actual.uid === process.getuid() && (actual.mode & 0o077) === 0, 'unsafe_adapter_descriptor');
    return JSON.parse(readBounded(fd, 16 * 1024));
  } finally { closeSync(fd); }
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
  // No directory scans, relative paths or symlinked transcript files.
  const stat = lstatSync(path);
  requireValue(stat.isFile() && !stat.isSymbolicLink() && stat.uid === process.getuid(), 'unsafe_transcript');
  requireValue(stat.size <= MAX_TRANSCRIPT_BYTES, 'transcript_limit');
  const fd = openSync(path, constants.O_RDONLY | constants.O_NOFOLLOW);
  try {
    const actual = fstatSync(fd);
    requireValue(actual.ino === stat.ino && actual.dev === stat.dev && actual.uid === process.getuid(), 'unsafe_transcript');
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
    const result = run(descriptor.runtime, [descriptor.cli, command], {
      input: JSON.stringify(input), encoding: 'utf8', timeout: command === 'recall' ? 1800 : 5000,
      maxBuffer: 300 * 1024, shell: false, windowsHide: true,
      // No shell and no credential values in argv. Core validates runtime/config/state.
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    if (result.error || result.status !== 0) throw new AdapterError('local_admission_failed');
    let parsed;
    try { parsed = JSON.parse(result.stdout); } catch { throw new AdapterError('invalid_core_result'); }
    requireValue(parsed.schema_version === 1 && typeof parsed.status === 'string', 'invalid_core_result');
    requireValue(!['failed', 'rejected', 'partial', 'unsupported'].includes(parsed.status), 'local_admission_failed');
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
