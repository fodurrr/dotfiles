import { createHash } from 'node:crypto';
import { closeSync, constants, fstatSync, lstatSync, openSync, readSync, readdirSync, realpathSync } from 'node:fs';
import { join } from 'node:path';

export const PIN = Object.freeze({
  package: '/home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi',
  runtime: '/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node',
  size: 107174016,
  artifact: 'c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca',
  sidecar: '83c3bb7619f590c213cc96a24216eb29a819a3ef6dc548607cc037ed276e8dc5',
  version: '1.3.0',
  source: '71023aec1546d6d677a65669c5665c0927ce0dd0',
});
export const LIMIT = Object.freeze({ handshake: 5000, process: 20000, overall: 600000, output: 256 * 1024, frame: 4096, channel: 16384 });
export const FILES = Object.freeze(['policy.mjs', 'identity.mjs', 'channel.mjs', 'transport.mjs', 'probe.mjs', 'probe-nested.mjs', 'supervisor.mjs', 'child.mjs']);
export const LIBRARIES = Object.freeze(['libc.so.6', 'libdl.so.2', 'libpthread.so.0', 'libm.so.6', 'libstdc++.so.6', 'libgcc_s.so.1', 'ld-linux-x86-64.so.2']);
export const ENV = Object.freeze({ HOME: '/home/fixture', PWD: '/work', PATH: '/runtime', LANG: 'C.UTF-8', TMPDIR: '/tmp',
  XDG_CONFIG_HOME: '/xdg/config', XDG_CACHE_HOME: '/xdg/cache', XDG_DATA_HOME: '/xdg/data', XDG_STATE_HOME: '/xdg/state',
  PI_CODING_AGENT_DIR: '/agent', PI_CODING_AGENT_SESSION_DIR: '/sessions', PI_OFFLINE: '1', PI_SKIP_VERSION_CHECK: '1', PI_TELEMETRY: '0' });
export const PI_ARGS = Object.freeze(['--offline', '--no-approve', '--no-extensions', '--no-mcp', '--no-skills', '--no-prompt-templates',
  '--no-themes', '--no-context-files', '--no-tools', '--no-session', '--system-prompt', 'fixture-only-system',
  '--append-system-prompt', 'fixture-only-append', '--extension', '/experiment/probe.mjs', '--help']);
export function demand(value, reason) { if (!value) throw new Error(reason); }
export function digestFd(fd) {
  const before = fstatSync(fd); demand(before.isFile(), 'not-regular-file');
  const hash = createHash('sha256'); const buffer = Buffer.alloc(1024 * 1024); let offset = 0, count;
  while ((count = readSync(fd, buffer, 0, buffer.length, offset))) { hash.update(buffer.subarray(0, count)); offset += count; }
  const after = fstatSync(fd);
  demand(before.dev === after.dev && before.ino === after.ino && before.size === after.size && before.mtimeMs === after.mtimeMs && before.ctimeMs === after.ctimeMs, 'changed-during-hash');
  return { size: before.size, sha256: hash.digest('hex'), dev: before.dev, ino: before.ino, mtime: before.mtimeMs, ctime: before.ctimeMs, mode: before.mode };
}
export function digestFile(path) {
  const fd = openSync(path, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
  try { return digestFd(fd); } finally { closeSync(fd); }
}
export function manifest(root) {
  const entries = [];
  function visit(relative) {
    const path = relative ? join(root, relative) : root; const st = lstatSync(path);
    demand(!st.isSymbolicLink(), 'manifest-symlink');
    if (st.isDirectory()) {
      entries.push({ path: relative || '.', type: 'directory', mode: st.mode });
      for (const name of readdirSync(path).sort()) visit(relative ? `${relative}/${name}` : name);
    } else { demand(st.isFile(), 'manifest-special-file'); entries.push({ path: relative, ...digestFile(path) }); }
  }
  visit('');
  return { entries, digest: createHash('sha256').update(JSON.stringify(entries)).digest('hex') };
}
export function verifyPins() {
  const binary = digestFile(join(PIN.package, 'pi')); const sidecar = digestFile(join(PIN.package, 'package.json'));
  demand(binary.size === PIN.size && binary.sha256 === PIN.artifact && sidecar.sha256 === PIN.sidecar, 'selected-artifact-mismatch');
  return { binary, sidecar };
}
export function sandboxArgs({ experiment, output, input, mode }) {
  demand(['preflight', 'linger', 'positive', 'missing-channel', 'nested'].includes(mode), 'unknown-phase');
  const args = ['--unshare-user', '--unshare-pid', '--unshare-net', '--unshare-ipc', '--unshare-uts', '--new-session', '--die-with-parent', '--cap-drop', 'ALL',
    '--clearenv', '--proc', '/proc', '--dev', '/dev', '--tmpfs', '/tmp', '--tmpfs', '/home', '--dir', '/home/fixture', '--tmpfs', '/agent',
    '--tmpfs', '/sessions', '--tmpfs', '/xdg', '--tmpfs', '/work', '--dir', '/runtime', '--dir', '/experiment', '--dir', '/input',
    '--ro-bind', PIN.package, '/pi', '--ro-bind', PIN.runtime, '/runtime/node'];
  for (const file of FILES) args.push('--ro-bind', join(experiment, file), `/experiment/${file}`);
  for (const lib of LIBRARIES) args.push('--ro-bind', realpathSync(`/lib/x86_64-linux-gnu/${lib}`), `/lib/x86_64-linux-gnu/${lib}`);
  args.push('--symlink', '/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2', '/lib64/ld-linux-x86-64.so.2',
    '--ro-bind', input, '/input/config.json', '--ro-bind', join(output, 'readonly-sentinel'), '/input/readonly-sentinel', '--bind', output, '/output', '--chdir', '/work');
  for (const [key, value] of Object.entries(ENV)) args.push('--setenv', key, value);
  args.push('--remount-ro', '/', '--', '/runtime/node', '/experiment/supervisor.mjs', mode);
  return args;
}
