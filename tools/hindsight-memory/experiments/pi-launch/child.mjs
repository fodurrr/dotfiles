import { setTimeout as delay } from 'node:timers/promises';
import { probeChannel } from './transport.mjs';

const role = process.argv[2];
if (role === 'claim') {
  try { await probeChannel('1.3.0'); process.exitCode = 73; }
  catch { process.exitCode = 72; }
} else if (role === 'linger') {
  await delay(60000);
} else if (role === 'overflow') {
  process.stdout.write(Buffer.alloc(300 * 1024, 120));
} else if (role === 'exit') {
  process.exitCode = 0;
} else throw new Error('unknown-child-role');
