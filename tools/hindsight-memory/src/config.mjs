import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import crypto from 'node:crypto';

export const RECALL_DEADLINE_MS = 8000;

export class SafeError extends Error { constructor(code) { super(code); this.code = code; } }
export const fail = code => { throw new SafeError(code); };
export const hash = value => crypto.createHash('sha256').update(value).digest('hex');
export function paths(env = process.env) {
  const home = env.HOME || os.homedir();
  for(const candidate of [home,env.XDG_CONFIG_HOME,env.XDG_STATE_HOME,env.XDG_DATA_HOME].filter(Boolean))if(!path.isAbsolute(candidate))fail('absolute-user-path-required');
  return { home, config: path.join(env.XDG_CONFIG_HOME || path.join(home, '.config'), 'hindsight-memory'),
    state: path.join(env.XDG_STATE_HOME || path.join(home, '.local/state'), 'hindsight-memory'),
    data: path.join(env.XDG_DATA_HOME || path.join(home, '.local/share'), 'hindsight-memory'), bin: path.join(home, '.local/bin') };
}
export function privatePath(target, directory = false) {
  const stat = fs.lstatSync(target);
  if (stat.isSymbolicLink() || (!directory && stat.nlink !== 1) || stat.uid !== process.getuid?.() || (stat.mode & 0o077) || (directory ? !stat.isDirectory() : !stat.isFile())) fail('unsafe-private-path');
  // Refuse a symlink in every ancestor, including intermediate XDG components.
  for (let parent = path.dirname(target); parent !== path.dirname(parent); parent = path.dirname(parent)) {
    const ancestor = fs.lstatSync(parent);
    if (ancestor.isSymbolicLink()) fail('symlink-ancestor');
    const trustedRoot = ancestor.uid === 0 && !(ancestor.mode & 0o022);
    const stickyTemp = ancestor.uid === 0 && (ancestor.mode & 0o1000);
    if (!trustedRoot && !stickyTemp && (ancestor.uid !== process.getuid?.() || (ancestor.mode & 0o022))) fail('unsafe-private-ancestor');
  }
  return stat;
}
export function privateDir(target) {
  if (!fs.existsSync(target)) {
    let ancestor = path.dirname(target);
    while (!fs.existsSync(ancestor)) ancestor = path.dirname(ancestor);
    for(let p=ancestor;p!==path.dirname(p);p=path.dirname(p)){const s=fs.lstatSync(p);if(s.isSymbolicLink())fail('symlink-ancestor');if(![0,process.getuid?.()].includes(s.uid) || ((s.mode & 0o022) && !(s.uid===0 && s.mode & 0o1000)))fail('unsafe-private-ancestor');}
    fs.mkdirSync(target, { recursive: true, mode: 0o700 });
  }
  privatePath(target, true);
}
export function readPrivate(file) {
  privatePath(file);
  const fd = fs.openSync(file, fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW | fs.constants.O_NONBLOCK);
  try { const s = fs.fstatSync(fd); if (!s.isFile() || s.nlink !== 1 || s.size > 65536 || s.uid !== process.getuid?.() || s.mode & 0o077) fail('unsafe-private-file'); return fs.readFileSync(fd, 'utf8'); }
  finally { fs.closeSync(fd); }
}
export function writePrivate(file, value) {
  privateDir(path.dirname(file));
  if (fs.existsSync(file)) privatePath(file);
  const tmp = `${file}.${crypto.randomUUID()}.tmp`;
  const fd = fs.openSync(tmp, fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW, 0o600);
  try { fs.writeFileSync(fd, value); fs.fsyncSync(fd); } finally { fs.closeSync(fd); }
  fs.renameSync(tmp, file);
  const dir = fs.openSync(path.dirname(file), 'r'); try { fs.fsyncSync(dir); } finally { fs.closeSync(dir); }
}
export function validateConfig(value) {
  if (value?.schema_version !== 1 || typeof value.endpoint !== 'string' || typeof value.bank !== 'string' || !/^[a-zA-Z0-9_.-]{1,128}$/.test(value.bank)) fail('invalid-config');
  let url; try { url = new URL(value.endpoint); } catch { fail('invalid-endpoint'); }
  if (url.username || url.password || url.search || url.hash || url.pathname !== '/') fail('invalid-endpoint');
  if (url.protocol !== 'https:' && !(url.protocol === 'http:' && ['127.0.0.1', '[::1]'].includes(url.hostname))) fail('insecure-endpoint');
  if (!path.isAbsolute(value.secret_file || '') || !Array.isArray(value.adapters) || !value.adapters.length || value.adapters.some(v => !/^[a-z0-9-]{1,40}$/.test(v)) || value.capture !== true) fail('invalid-config');
  const endpoint = url.origin;
  let owners={};
  if(value.capture_owners!==undefined){
    if(!value.capture_owners || typeof value.capture_owners!=='object' || Array.isArray(value.capture_owners) || Object.entries(value.capture_owners).some(([adapter,owner])=>!['pi','codex-cli'].includes(adapter) || typeof owner!=='string' || !/^[a-f0-9]{64}$/.test(owner)))fail('invalid-capture-owner-selection');
    owners={capture_owners:{...value.capture_owners}};
  }
  return {schema_version: 1, endpoint, bank: value.bank, secret_file: value.secret_file, adapters: [...new Set(value.adapters)], agent_commands: value.agent_commands && typeof value.agent_commands==='object' && !Array.isArray(value.agent_commands)?value.agent_commands:{}, agent_versions: value.agent_versions && typeof value.agent_versions === 'object' && !Array.isArray(value.agent_versions) ? value.agent_versions : {}, ...owners, capture: true};
}
export function loadConfig(p) { return validateConfig(JSON.parse(readPrivate(path.join(p.config, 'config.json')))); }
export function destination(config) { return hash(JSON.stringify([config.endpoint, config.bank])); }
export function credential(config) {
  const secret = readPrivate(config.secret_file).trim();
  if (!secret || /[\r\n]/.test(secret)) fail('invalid-secret-file');
  return secret;
}
export function qualifyRuntime() {
  if(!['linux','darwin'].includes(process.platform))fail('unsupported-platform');
  const [major, minor] = process.versions.node.split('.').map(Number);
  if (major !== 24 || minor < 15) fail('unsupported-node-use-24-15-or-newer-24');
  return fs.realpathSync(process.execPath);
}
export function redact(text) {
  return text.replace(/-----BEGIN [^-]*PRIVATE KEY-----[\s\S]*?-----END [^-]*PRIVATE KEY-----/g, '[REDACTED PRIVATE KEY]')
    .replace(/\b(?:sk-[a-zA-Z0-9_-]{16,}|gh[pousr]_[a-zA-Z0-9]{20,}|hsk_[a-zA-Z0-9_-]{12,})\b/g, '[REDACTED]')
    .replace(/\b((?:api[_-]?key|password|token|secret)\s*[:=]\s*)[^\s,;]+/gi, '$1[REDACTED]');
}
