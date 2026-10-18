import { closeSync, openSync, readFileSync } from 'node:fs';
import { demand, digestFd } from './policy.mjs';

export function processIdentity(pid) {
  demand(Number.isSafeInteger(pid) && pid > 0, 'invalid-pid');
  const text = readFileSync(`/proc/${pid}/stat`, 'utf8'); const end = text.lastIndexOf(')');
  demand(end > 0 && Number(text.slice(0, text.indexOf(' '))) === pid, 'invalid-proc-stat');
  const fields = text.slice(end + 2).trim().split(/\s+/);
  demand(/^\d+$/.test(fields[19]), 'invalid-start-time');
  return { pid, start: fields[19], state: fields[0], ppid: Number(fields[1]) };
}
export function runningArtifact(pid) {
  const before = processIdentity(pid);
  // /proc/PID/exe intentionally follows the kernel's executable link. Hash the opened
  // executable, never the selected pathname; keep that handle through the second stat.
  const fd = openSync(`/proc/${pid}/exe`, 'r');
  try {
    const artifact = digestFd(fd); const after = processIdentity(pid);
    demand(before.start === after.start && before.pid === after.pid && !['Z', 'X'].includes(after.state), 'process-changed');
    return { ...after, artifact };
  } finally { closeSync(fd); }
}
