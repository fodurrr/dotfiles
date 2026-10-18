import { realpathSync } from 'node:fs';
import { join } from 'node:path';
import { PIN, LIBRARIES, ENV as BASE_ENV, demand } from '../pi-launch/policy.mjs';
export { PIN, demand };
export const LIMIT = Object.freeze({ process: 60000, overall: 180000, output: 256 * 1024, requests: 12, body: 64 * 1024 });
export const ENV = Object.freeze({ ...BASE_ENV, TERM: 'xterm-256color' });
export const PYTHON = '/usr/bin/python3.14';
export const STDLIB = '/usr/lib/python3.14';
// Exact modules observed from this own helper import set under Python -I -S.
export const PYTHON_FILES = [
  "/usr/lib/python3.14/_collections_abc.py",
  "/usr/lib/python3.14/abc.py",
  "/usr/lib/python3.14/base64.py",
  "/usr/lib/python3.14/codecs.py",
  "/usr/lib/python3.14/collections/__init__.py",
  "/usr/lib/python3.14/copyreg.py",
  "/usr/lib/python3.14/encodings/__init__.py",
  "/usr/lib/python3.14/encodings/aliases.py",
  "/usr/lib/python3.14/encodings/utf_8.py",
  "/usr/lib/python3.14/enum.py",
  "/usr/lib/python3.14/functools.py",
  "/usr/lib/python3.14/genericpath.py",
  "/usr/lib/python3.14/importlib/_bootstrap_external.py",
  "/usr/lib/python3.14/json/__init__.py",
  "/usr/lib/python3.14/json/decoder.py",
  "/usr/lib/python3.14/json/encoder.py",
  "/usr/lib/python3.14/json/scanner.py",
  "/usr/lib/python3.14/keyword.py",
  "/usr/lib/python3.14/lib-dynload/resource.cpython-314-x86_64-linux-gnu.so",
  "/usr/lib/python3.14/lib-dynload/termios.cpython-314-x86_64-linux-gnu.so",
  "/usr/lib/python3.14/linecache.py",
  "/usr/lib/python3.14/operator.py",
  "/usr/lib/python3.14/os.py",
  "/usr/lib/python3.14/posixpath.py",
  "/usr/lib/python3.14/pty.py",
  "/usr/lib/python3.14/re/__init__.py",
  "/usr/lib/python3.14/re/_casefix.py",
  "/usr/lib/python3.14/re/_compiler.py",
  "/usr/lib/python3.14/re/_constants.py",
  "/usr/lib/python3.14/re/_parser.py",
  "/usr/lib/python3.14/reprlib.py",
  "/usr/lib/python3.14/signal.py",
  "/usr/lib/python3.14/stat.py",
  "/usr/lib/python3.14/struct.py",
  "/usr/lib/python3.14/tty.py",
  "/usr/lib/python3.14/types.py",
  "/usr/lib/python3.14/zipimport.py"
];
export const PYTHON_LIBRARIES = ['libexpat.so.1', 'libz.so.1'];
export const FILES = ['policy.mjs', 'supervisor.mjs', 'services.mjs', 'qualification.mjs', 'pty.py', 'surrogate.mjs'];
export const SHARED = ['policy.mjs', 'identity.mjs', 'processes.mjs', 'safe-output.mjs'];
export const COMPONENT = ['package.json', ...['activation', 'capture', 'cli', 'config', 'delivery', 'ownership', 'qualification', 'state'].map(x => `src/${x}.mjs`),
  ...['common', 'hook', 'manage', 'opencode-v1', 'opencode-v2', 'pi', 'transcripts'].map(x => `adapters/${x}.mjs`)];
export const PI_ARGS = Object.freeze(['--no-extensions', '-e', '/work/sole-bridge.mjs']);
export const QUALIFICATION_ARGS = Object.freeze(['--no-extensions', '-e', '/home/fixture/.pi/agent/extensions/hindsight-memory.js']);
export const QUALIFICATION_REQUEST_LIMIT = 16;
export const QUALIFICATION_TEXT = Object.freeze({ positive: 'QUALIFICATION_POSITIVE_SENTINEL', cancel: 'QUALIFICATION_CANCEL_SENTINEL', afterCancel: 'QUALIFICATION_POST_CANCEL_SENTINEL',
  switched: 'QUALIFICATION_SWITCHED_SENTINEL', resumed: 'QUALIFICATION_RESUMED_SENTINEL', answer: 'QUALIFICATION_ANSWER_SENTINEL' });
// Pinned interactive init installs real submission before binding extensions.
// rebindCurrentSession updates the title after that binding and agent subscription.
export function qualificationStartupReady(text) {
  return text.includes('hindsight-memory: pi_fresh_session_required;') && text.includes('\u001b]0;π - work\u0007');
}
export const TEXT = Object.freeze({ history: 'HISTORY_EXCLUSION_SENTINEL', historyAnswer: 'HISTORY_ANSWER_SENTINEL',
  prompt: 'Synthetic Pi turn: say TURN_FINAL_SENTINEL.', final: 'TURN_FINAL_SENTINEL', recall: 'RECALL_EXCLUSION_SENTINEL' });
export function sandboxArgs({ experiment, output, input, mode, prepared = null }) {
  demand(['preflight', 'native', 'qualification', 'linger', 'deadline', 'overflow'].includes(mode), 'unknown-phase');
  const launch = join(experiment, '../pi-launch'); const component = prepared?.release ?? join(experiment, '../..');
  const args = ['--unshare-user', '--unshare-pid', '--unshare-net', '--unshare-ipc', '--unshare-uts', '--new-session', '--die-with-parent', '--cap-drop', 'ALL',
    '--clearenv', '--proc', '/proc', '--dev', '/dev', '--tmpfs', '/tmp', '--tmpfs', '/home', '--dir', '/home/fixture', '--perms', '0700', '--tmpfs', '/agent',
    '--tmpfs', '/sessions', '--tmpfs', '/xdg', '--tmpfs', '/work', '--dir', '/runtime', '--dir', '/experiment', '--dir', '/pi-turn', '--dir', '/pi-launch', '--dir', '/component', '--dir', '/input',
    '--ro-bind', PIN.package, '/pi', '--ro-bind', PIN.runtime, '/runtime/node', '--ro-bind', PYTHON, PYTHON];
  for (const file of PYTHON_FILES) args.push('--ro-bind', file, file);
  for (const file of FILES) args.push('--ro-bind', join(experiment, file), `/pi-turn/${file}`);
  for (const file of SHARED) args.push('--ro-bind', join(launch, file), `/pi-launch/${file}`);
  for (const file of COMPONENT) args.push('--ro-bind', join(component, file), `/component/${file}`);
  if (prepared) {
    args.push('--ro-bind', PIN.runtime, PIN.runtime);
    for (const file of COMPONENT) args.push('--ro-bind', join(component, file), join(component, file));
  }
  for (const lib of [...LIBRARIES, ...PYTHON_LIBRARIES]) args.push('--ro-bind', realpathSync(`/lib/x86_64-linux-gnu/${lib}`), `/lib/x86_64-linux-gnu/${lib}`);
  args.push('--symlink', '/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2', '/lib64/ld-linux-x86-64.so.2',
    '--ro-bind', input, '/input/config.json', '--ro-bind', join(output, 'readonly-sentinel'), '/input/readonly-sentinel', '--bind', output, '/output', '--chdir', '/work');
  for (const [key, value] of Object.entries(ENV)) args.push('--setenv', key, value);
  args.push('--remount-ro', '/', '--', '/runtime/node', '/pi-turn/supervisor.mjs', mode);
  return args;
}
