import { randomBytes } from 'node:crypto';
import { closeSync, constants, fstatSync, fsyncSync, lstatSync, openSync, readSync, renameSync, unlinkSync, writeFileSync } from 'node:fs';
import { isAbsolute } from 'node:path';
import { demand, LIMIT } from './policy.mjs';

// Outer host writes must never follow names created through the writable sandbox
// output mount. Walk parent directories without links and anchor all final names
// to the opened directory. Renaming a symlink never writes through its target.
function withDirectory(path, action) {
  demand(isAbsolute(path), 'absolute-output-path-required');
  const parts = path.split('/').filter(Boolean);
  demand(parts.length && parts.every(part => part !== '.' && part !== '..'), 'invalid-output-path');
  const name = parts.pop();
  let directory = openSync('/', constants.O_RDONLY | constants.O_DIRECTORY | constants.O_NOFOLLOW);
  try {
    for (const component of parts) {
      const next = openSync(`/proc/self/fd/${directory}/${component}`, constants.O_RDONLY | constants.O_DIRECTORY | constants.O_NOFOLLOW);
      closeSync(directory); directory = next;
    }
    const parent = fstatSync(directory);
    demand(parent.isDirectory() && parent.uid === process.getuid() && (parent.mode & 0o777) === 0o700, 'unsafe-output-directory');
    return action(directory, name);
  } finally { closeSync(directory); }
}

export function savePrivate(path, value) {
  return withDirectory(path, (directory, name) => {
    let temporary, file;
    try {
      const destination = `/proc/self/fd/${directory}/${name}`;
      try {
        const old = lstatSync(destination);
        demand(old.isFile() && old.nlink === 1 && old.uid === process.getuid() && (old.mode & 0o777) === 0o600, 'unsafe-output-entry');
      } catch (error) { if (error.code !== 'ENOENT') throw error; }
      temporary = `/proc/self/fd/${directory}/.host-write-${randomBytes(16).toString('hex')}`;
      file = openSync(temporary, constants.O_WRONLY | constants.O_CREAT | constants.O_EXCL | constants.O_NOFOLLOW | constants.O_NONBLOCK, 0o600);
      const created = fstatSync(file);
      demand(created.isFile() && created.nlink === 1 && created.uid === process.getuid(), 'unsafe-output-temporary');
      writeFileSync(file, typeof value === 'string' ? value : `${JSON.stringify(value, null, 2)}\n`);
      fsyncSync(file);
      renameSync(temporary, destination); temporary = undefined;
      const final = lstatSync(destination);
      demand(final.isFile() && final.nlink === 1 && final.dev === created.dev && final.ino === created.ino && (final.mode & 0o777) === 0o600, 'output-replaced-during-save');
    } finally {
      if (file !== undefined) closeSync(file);
      if (temporary) { try { unlinkSync(temporary); } catch {} }
    }
  });
}

// Read this way again when inspecting diagnostics. A failed sandbox can leave
// names that must never be followed by host cat/readFileSync calls.
export function readEvidence(path) {
  return withDirectory(path, (directory, name) => {
    const file = openSync(`/proc/self/fd/${directory}/${name}`, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
    try {
      const before = fstatSync(file);
      demand(before.isFile() && before.nlink === 1 && before.uid === process.getuid() && (before.mode & 0o777) === 0o600, 'unsafe-evidence-file');
      demand(before.size <= LIMIT.output, 'evidence-output-overflow');
      const buffer = Buffer.alloc(before.size + 1); let total = 0, count;
      while (total < buffer.length && (count = readSync(file, buffer, total, buffer.length - total, total))) total += count;
      const after = fstatSync(file);
      demand(total === before.size && before.size === after.size && before.mtimeMs === after.mtimeMs && before.ctimeMs === after.ctimeMs && after.nlink === 1, 'evidence-changed-during-read');
      return { bytes: total, text: new TextDecoder('utf-8', { fatal: true }).decode(buffer.subarray(0, total)) };
    } finally { closeSync(file); }
  });
}
