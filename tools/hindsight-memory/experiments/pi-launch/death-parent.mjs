import { spawn } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { sandboxArgs } from './policy.mjs';

// Harmless parent-death preflight only. This helper cannot select a native phase.
const options = JSON.parse(readFileSync(process.argv[2], 'utf8'));
const child = spawn('/usr/bin/bwrap', sandboxArgs({ ...options, mode: 'linger' }), { env: {}, shell: false, stdio: ['ignore', 'pipe', 'pipe'] });
let sent = false;
child.stdout.on('data', bytes => {
  if (!sent) { sent = true; process.stdout.write(`${JSON.stringify({ type: 'death-parent-ready', bwrap: child.pid })}\n`); }
});
child.stderr.pipe(process.stderr);
child.once('error', error => { process.stderr.write(error.message); process.exitCode = 1; });
child.once('close', code => { process.exitCode = code || 1; });
