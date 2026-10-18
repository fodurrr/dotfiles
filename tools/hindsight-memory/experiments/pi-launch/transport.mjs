import { Socket } from 'node:net';
import { channel, exact } from './channel.mjs';
import { processIdentity, runningArtifact } from './identity.mjs';
import { demand, PIN } from './policy.mjs';

export async function probeChannel(version, { socket = () => new Socket({ fd: 3, readable: true, writable: true }), timeout } = {}) {
  const self = processIdentity(process.pid); let accepted = false;
  const stream = socket();
  const wire = channel(stream, value => {
    demand(!accepted, 'duplicate-ack'); exact(value, ['type', 'v', 'pid', 'start', 'invocation', 'artifact', 'supervisor']);
    exact(value.supervisor, ['pid', 'start']);
    demand(value.type === 'ACK' && value.v === 1 && value.pid === process.pid && value.start === self.start && /^[a-f0-9]{64}$/.test(value.invocation) && value.artifact === PIN.artifact, 'invalid-ack');
    const parent = processIdentity(process.ppid); const current = runningArtifact(process.pid);
    demand(parent.pid === value.supervisor.pid && parent.start === value.supervisor.start && current.start === self.start && current.artifact.sha256 === value.artifact && current.artifact.size === PIN.size, 'own-process-mismatch');
    accepted = true;
    wire.send({ type: 'DONE', v: 1, pid: self.pid, start: self.start, invocation: value.invocation, artifact: value.artifact });
    wire.end();
  }, { timeout });
  wire.send({ type: 'HELLO', v: 1, pid: self.pid, start: self.start, version });
  await wire.closed; demand(accepted, 'missing-ack');
  // This observation grants no callback authority and is never persisted as scope.
  return { pid: self.pid, start: self.start, observed: true };
}
