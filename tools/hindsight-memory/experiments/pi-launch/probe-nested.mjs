import { spawn } from 'node:child_process';
import { demand, ENV, LIMIT } from './policy.mjs';

export default async function inheritedChannelProbe() {
  // Deliberately pass FD3 to a different direct executable. Its own PID must fail.
  const child = spawn('/runtime/node', ['/experiment/child.mjs', 'claim'], { shell: false, env: { ...ENV }, stdio: ['ignore', 'inherit', 'inherit', 3] });
  const timer = setTimeout(() => child.kill('SIGKILL'), LIMIT.handshake);
  const code = await new Promise((resolve, reject) => { child.once('error', reject); child.once('close', resolve); }).finally(() => clearTimeout(timer));
  demand(code === 72, 'nested-channel-not-refused');
  throw new Error('nested-child-refused');
}
