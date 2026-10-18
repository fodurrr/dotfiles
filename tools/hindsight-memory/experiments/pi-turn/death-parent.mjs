import { spawn } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { sandboxArgs } from './policy.mjs';
const options = JSON.parse(readFileSync(process.argv[2], 'utf8'));
const child = spawn('/usr/bin/bwrap', sandboxArgs({ ...options, mode: 'linger' }), { env: {}, shell: false, stdio: ['ignore', 'pipe', 'pipe'] });
let ready = false;
child.stdout.on('data', () => { if (!ready) { ready = true; process.stdout.write('{"type":"death-parent-ready"}\n'); } });
child.stderr.pipe(process.stderr); child.once('error', () => { process.exitCode = 1; }); child.once('close', code => { process.exitCode = code || 1; });
