import { spawn } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { LIMIT, demand } from './policy.mjs';
import { processIdentity } from './identity.mjs';

export function ownedTree(pid) {
  const found = [];
  function visit(current) {
    let identity;
    try { identity = processIdentity(current); } catch { return; }
    found.push(identity);
    let children;
    try { children = readFileSync(`/proc/${current}/task/${current}/children`, 'utf8').trim(); } catch { return; }
    for (const child of children.split(/\s+/).filter(Boolean)) visit(Number(child));
  }
  visit(pid); return found;
}
export function alive(identity) {
  try { const now = processIdentity(identity.pid); return now.start === identity.start; } catch { return false; }
}
export async function gone(identities, milliseconds = 1500) {
  const end = performance.now() + milliseconds;
  do {
    if (identities.every(identity => !alive(identity))) return true;
    await new Promise(resolve => setTimeout(resolve, 20));
  } while (performance.now() < end);
  return false;
}
export function boundedSpawn(command, args, { env = {}, extra = [], timeout = LIMIT.process, onSpawn = () => {} } = {}) {
  const child = spawn(command, args, { shell: false, env, stdio: ['ignore', 'pipe', 'pipe', ...extra] });
  let output = 0, failure = null; const stdout = [], stderr = [];
  const stop = reason => { failure ??= reason; child.kill('SIGKILL'); };
  const timer = setTimeout(() => stop('process-timeout'), timeout);
  for (const [stream, target] of [[child.stdout, stdout], [child.stderr, stderr]]) {
    stream.on('data', bytes => {
      output += bytes.length;
      if (output > LIMIT.output) { stop('output-overflow'); return; }
      target.push(bytes);
    });
    stream.on('error', () => stop('output-error'));
  }
  const result = new Promise((resolve, reject) => {
    child.once('error', error => { clearTimeout(timer); reject(error); });
    child.once('close', (code, signal) => {
      clearTimeout(timer); resolve({ code, signal, failure, stdout: Buffer.concat(stdout).toString('utf8'), stderr: Buffer.concat(stderr).toString('utf8') });
    });
  });
  child.once('spawn', () => { try { onSpawn(child); } catch { stop('spawn-observer-failed'); } });
  return { child, result, stop };
}
export function finalResult(result) {
  demand(!result.failure && result.code === 0 && result.signal === null, result.failure ?? 'supervisor-exit');
  const lines = result.stdout.trim().split('\n'); demand(lines.length === 1, 'incomplete-supervisor-result');
  const parsed = JSON.parse(lines[0]); demand(parsed.schema === 1 && parsed.complete === true, 'incomplete-supervisor-result');
  return parsed;
}
