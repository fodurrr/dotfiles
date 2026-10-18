// Own harmless fixture. This module never imports or executes Pi/Bun.
import { readlinkSync, readdirSync } from 'node:fs';
import { setTimeout as delay } from 'node:timers/promises';
if (!process.stdin.isTTY || !process.stdout.isTTY || !process.stderr.isTTY) throw new Error('tty-required');
const fds = readdirSync('/proc/self/fd').flatMap(fd => { try { return [{ fd, target: readlinkSync(`/proc/self/fd/${fd}`) }]; } catch { return []; } });
if (!['0','1','2'].every(fd => fds.find(item => item.fd === fd)?.target.startsWith('/dev/pts/'))) throw new Error('terminal-fds-required');
if (fds.some(item => item.target.startsWith('/input/') || item.target.startsWith('/output/'))) throw new Error('unexpected-inherited-file-descriptor');
process.stdout.write('SURROGATE_TTY_READY\n');
const mode = process.argv[2];
if (mode === 'overflow') process.stdout.write('x'.repeat(300 * 1024));
else if (mode === 'linger' || mode === 'deadline') await delay(60000);
else {
  let input = ''; process.stdin.setEncoding('utf8');
  process.stdin.on('data', chunk => {
    input += chunk;
    if (input.includes('harmless-script\n')) {
      process.stdout.write('SURROGATE_SCRIPT_OK\n'); process.stdin.pause(); process.exitCode = 0;
    }
  });
}
