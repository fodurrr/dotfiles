# Experiment-only PTY driver. It executes only fixed commands, never shell text.
import base64, errno, fcntl, json, os, pty, resource, select, signal, struct, sys, termios, time

mode = sys.argv[1] if len(sys.argv) == 2 else ''
if mode not in ('native', 'preflight', 'linger', 'deadline', 'overflow'):
    raise RuntimeError('fixed-pty-mode-required')
command = ['/pi/pi', '--no-extensions', '-e', '/work/sole-bridge.mjs'] if mode == 'native' else ['/runtime/node', '/pi-turn/surrogate.mjs', mode]
limit = 45 if mode == 'native' else (0.3 if mode == 'deadline' else 10)
cap = 128 * 1024
pid, master = pty.fork()
if pid == 0:
    fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack('HHHH', 40, 120, 0, 0))
    os.closerange(3, min(resource.getrlimit(resource.RLIMIT_NOFILE)[0], 1048576))
    os.execve(command[0], command, dict(os.environ))

stopped = False
reaped = False
failure = None

def emit(value):
    print(json.dumps(value, separators=(',', ':')), flush=True)

def terminate(*_):
    global stopped
    stopped = True
    try:
        os.killpg(pid, signal.SIGKILL)
    except ProcessLookupError:
        pass

signal.signal(signal.SIGTERM, terminate)
signal.signal(signal.SIGINT, terminate)
started = time.monotonic()
received = 0
writes = 0
pending = b''
try:
    emit({'type': 'pty-child', 'pid': pid, 'mode': mode})
    while True:
        if time.monotonic() - started > limit:
            failure = 'pty-deadline'
            terminate()
            break
        readable, _, _ = select.select([master, 0], [], [], 0.05)
        if master in readable:
            try:
                data = os.read(master, 4096)
            except OSError as error:
                if error.errno == errno.EIO:
                    break
                raise
            if not data:
                break
            received += len(data)
            if received > cap:
                failure = 'pty-output-overflow'
                terminate()
                break
            emit({'type': 'output', 'data': base64.b64encode(data).decode('ascii')})
        if 0 in readable:
            chunk = os.read(0, 4096)
            if not chunk:
                terminate()
                break
            pending += chunk
            if len(pending) > 4096:
                raise RuntimeError('pty-input-overflow')
            while b'\n' in pending:
                line, pending = pending.split(b'\n', 1)
                value = json.loads(line)
                if value == {'type': 'stop'}:
                    terminate()
                    break
                if set(value) != {'type', 'text'} or value['type'] != 'write' or not isinstance(value['text'], str):
                    raise RuntimeError('invalid-pty-command')
                writes += 1
                encoded = value['text'].encode('utf8')
                if writes > 12 or len(encoded) > 1024:
                    raise RuntimeError('pty-write-limit')
                os.write(master, encoded)
        done, status = os.waitpid(pid, os.WNOHANG)
        if done:
            reaped = True
            break
    if not reaped:
        terminate()
        _, status = os.waitpid(pid, 0)
        reaped = True
    emit({'type': 'exit', 'status': os.waitstatus_to_exitcode(status), 'stopped': stopped, 'failure': failure, 'bytes': received, 'reaped': reaped})
    if failure:
        sys.exit(1)
finally:
    if not reaped:
        terminate()
        os.waitpid(pid, 0)
    os.close(master)
