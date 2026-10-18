import { LIMIT, demand } from './policy.mjs';

export function exact(value, keys) {
  demand(value && typeof value === 'object' && !Array.isArray(value) && Object.keys(value).sort().join() === [...keys].sort().join(), 'unknown-frame-fields');
}
export function frame(value) {
  const bytes = Buffer.from(`${JSON.stringify(value)}\n`); demand(bytes.length <= LIMIT.frame, 'frame-overflow'); return bytes;
}
export function channel(stream, onFrame, { timeout = LIMIT.handshake, onFailure = () => {} } = {}) {
  let pending = Buffer.alloc(0), total = 0, ended = false, failed = false;
  let finish, reject;
  const closed = new Promise((resolve, fail) => { finish = resolve; reject = fail; });
  // Consumers await closed after installing their protocol state; no unhandled rejection.
  closed.catch(() => {});
  const fail = error => { if (failed) return; failed = true; clearTimeout(timer); onFailure(error); reject(error); stream.destroy(); };
  const timer = setTimeout(() => fail(new Error('handshake-timeout')), timeout);
  stream.on('data', bytes => {
    try {
      total += bytes.length; demand(total <= LIMIT.channel, 'channel-overflow'); pending = Buffer.concat([pending, bytes]);
      let offset;
      while ((offset = pending.indexOf(10)) !== -1) {
        demand(offset > 0 && offset + 1 <= LIMIT.frame, 'invalid-frame-length');
        const text = new TextDecoder('utf-8', { fatal: true }).decode(pending.subarray(0, offset)); pending = pending.subarray(offset + 1);
        const result = onFrame(JSON.parse(text));
        if (result?.then) result.catch(fail);
      }
      demand(pending.length < LIMIT.frame, 'frame-overflow');
    } catch (error) { fail(error); }
  });
  stream.on('error', fail);
  stream.on('end', () => { ended = true; if (pending.length) fail(new Error('incomplete-frame')); });
  stream.on('close', () => { clearTimeout(timer); if (!failed) { if (!ended) fail(new Error('premature-close')); else finish(); } });
  return { closed, fail, send: value => { demand(!failed && !stream.destroyed, 'channel-closed'); stream.write(frame(value)); }, end: () => stream.end() };
}

export function claimProtocol({ expected, supervisor, verify, send, end }) {
  let state = 'hello'; const observations = { hello: false, ack: false, done: false };
  return {
    observations,
    async receive(value) {
      if (state === 'hello') {
        state = 'verifying'; exact(value, ['type', 'v', 'pid', 'start', 'version']);
        demand(value.type === 'HELLO' && value.v === 1, 'invalid-hello');
        demand(value.pid === expected.pid && value.start === expected.start && value.version === expected.version, 'caller-mismatch');
        observations.hello = true;
        await verify(); demand(state === 'verifying', 'duplicate-claim'); state = 'done';
        observations.ack = true;
        send({ type: 'ACK', v: 1, pid: expected.pid, start: expected.start, invocation: expected.invocation, artifact: expected.artifact, supervisor });
        return;
      }
      if (state === 'done') {
        state = 'closed'; exact(value, ['type', 'v', 'pid', 'start', 'invocation', 'artifact']);
        demand(value.type === 'DONE' && value.v === 1 && value.pid === expected.pid && value.start === expected.start && value.invocation === expected.invocation && value.artifact === expected.artifact, 'invalid-done');
        observations.done = true; end(); return;
      }
      state = 'failed'; throw new Error('duplicate-claim');
    },
    finish() { demand(state === 'closed' && observations.done, 'incomplete-handshake'); },
  };
}
