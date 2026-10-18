// Experiment only. The sole Pi extension is the unchanged generated artifact.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { paths, privateDir, writePrivate, validateConfig, hash } from '/component/src/config.mjs';
import { Store } from '/component/src/state.mjs';
import { adapterArtifacts } from '/component/adapters/manage.mjs';
import { runningArtifact } from '../pi-launch/identity.mjs';
import { QUALIFICATION_ARGS, QUALIFICATION_TEXT as Q, PIN, demand, qualificationStartupReady } from './policy.mjs';

function sessions() {
  const files = [];
  function visit(dir) {
    for (const name of readdirSync(dir)) {
      const path = join(dir, name); const st = statSync(path);
      if (st.isDirectory()) visit(path);
      else {
        demand(name.endsWith('.jsonl') && st.size <= 65536 && files.length < 4, 'qualification-session-bound');
        const entries = readFileSync(path, 'utf8').trim().split('\n').filter(Boolean).map(line => JSON.parse(line));
        files.push({ path, entries });
      }
    }
  }
  visit('/sessions'); return files;
}
const text = message => typeof message.content === 'string' ? message.content : message.content.filter(part => part.type === 'text').map(part => part.text).join('\n');
const messages = session => session.entries.filter(entry => entry.type === 'message');
export async function runQualification({ input, output, services, tty, waitFor, setStore }) {
  demand(input.prepared?.runtime.path === PIN.runtime && existsSync(input.prepared.release), 'prepared-release-required');
  demand(!existsSync(join(input.prepared.release, 'experiments')) && !existsSync(join(input.prepared.release, 'test')), 'prepared-release-development-files');
  const p = paths(); privateDir(p.config); privateDir(p.data); privateDir('/work/private');
  writePrivate(join(p.data, 'installation.json'), JSON.stringify(input.prepared));
  writePrivate(join(p.config, 'secret'), 'synthetic-secret');
  const config = validateConfig({ schema_version: 1, endpoint: services.memory, bank: 'synthetic', secret_file: join(p.config, 'secret'),
    adapters: ['pi'], agent_versions: { pi: '1.3.0' }, capture: true });
  writePrivate(join(p.config, 'config.json'), JSON.stringify(config));
  const store = new Store(p); setStore(store); store.activate(config); // Existing private fixture seam.
  const descriptorPath = '/work/private/descriptor.json'; const owner = 'isolated-pi-qualification';
  const plan = adapterArtifacts({ adapter: 'pi', version: '1.3.0', runtime: PIN.runtime,
    cli: join(input.prepared.release, 'src/cli.mjs'), releaseDir: input.prepared.release, descriptorPath, owner, home: p.home });
  const s = statSync('/pi/pi');
  plan.descriptor.runtime_identity = input.prepared.runtime;
  plan.descriptor.agent_identity = { path: '/pi/pi', requested: '/pi/pi', dev: s.dev, ino: s.ino, size: s.size, mtimeMs: s.mtimeMs };
  writePrivate(descriptorPath, JSON.stringify(plan.descriptor));
  demand(plan.files.length === 1 && plan.files[0].path === QUALIFICATION_ARGS[2], 'unexpected-generated-bridge');
  writePrivate(plan.files[0].path, plan.files[0].content);
  writePrivate('/agent/models.json', JSON.stringify({ providers: { loopback: { baseUrl: `${services.provider}/v1`, api: 'openai-completions', apiKey: 'fixture-only', models: [{ id: 'fixture', maxTokens: 64 }] } } }));
  writePrivate('/agent/settings.json', JSON.stringify(input.piSettings));
  output.preparedRoute = { release: input.prepared.release, runtime: PIN.runtime, cli: plan.descriptor.cli,
    bridge: plan.files[0].path, bridgeHash: hash(plan.files[0].content), owner, generatedBridgeUnmodified: true, sourceCheckoutAbsent: input.hidden.every(path => !existsSync(path)) };
  const driver = tty();
  await waitFor(() => {
    const frame = driver.frames.find(frame => frame.type === 'pty-child'); if (!frame) return false;
    try {
      const live = runningArtifact(frame.pid);
      if (live.artifact.sha256 !== input.piArtifact || live.artifact.dev !== s.dev || live.artifact.ino !== s.ino || live.ppid !== driver.child.pid) return false;
      output.nativeExecuted = true; output.nativeExecutionEvidence = 'exact-elf-observed'; output.nativeProcess = live; return true;
    } catch { return false; }
  }, 'qualification-executable-not-observed');
  await waitFor(() => qualificationStartupReady(driver.text), 'qualification-startup-ui-not-observed');
  driver.write('/new\r');
  await waitFor(() => driver.text.includes('Personal Hindsight memory') && driver.text.includes(services.memory), 'qualification-consent-not-observed');
  driver.write(input.consentKeys);
  await waitFor(() => store.db.prepare('SELECT count(*) n FROM sessions').get().n === 1, 'qualification-registration-not-observed');
  const registered = store.db.prepare('SELECT agent,session,owner,count,cursor FROM sessions').get();
  demand(registered.agent === 'pi' && registered.owner === owner && registered.count === 0 && registered.cursor === null, 'qualification-writer-owner-mismatch');
  let conflict;
  try { store.register({ schema_version: 1, agent: 'pi', session: registered.session, owner: 'other-fixture-writer' }, []); }
  catch (error) { conflict = error.code; }
  demand(conflict === 'session-owner-conflict', 'qualification-second-owner-not-refused');
  const baseline = () => ({ sessions: store.db.prepare('SELECT count(*) n FROM sessions').get().n, jobs: store.db.prepare('SELECT count(*) n FROM jobs').get().n,
    messages: store.db.prepare('SELECT count(*) n FROM messages').get().n, staged: store.db.prepare('SELECT count(*) n FROM staged').get().n,
    recalls: services.evidence.recalls.length, retained: services.evidence.retains.length });
  driver.write(`${Q.positive}\r`);
  await waitFor(() => store.db.prepare("SELECT count(*) n FROM jobs WHERE state='completed'").get().n === 2, 'qualification-positive-delivery-not-completed', 15000);
  demand(services.evidence.retains.length === 2 && services.evidence.completed.length === 2 && baseline().messages === 2 && baseline().staged === 0, 'qualification-positive-not-admitted');
  const accepted = store.db.prepare('SELECT owner,count,cursor FROM sessions').get();
  demand(accepted.owner === owner && accepted.count === 2 && typeof accepted.cursor === 'string', 'qualification-positive-cursor-mismatch');
  const positive = { phase: 'prepared-positive-completed', ...baseline() };
  driver.write(`${Q.cancel}\r`);
  await waitFor(() => services.evidence.provider.length === 2 && baseline().staged === 1, 'qualification-cancellable-stream-not-observed');
  demand(baseline().recalls === 2, 'qualification-cancel-recall-not-observed');
  driver.write('\u001b');
  await waitFor(() => services.evidence.cancelledStreams === 1 && baseline().staged === 0 && sessions().some(session => messages(session).some(entry => entry.message.role === 'assistant' && entry.message.stopReason === 'aborted')), 'qualification-cancel-not-settled');
  const cancelledSession = sessions().find(session => messages(session).some(entry => entry.message.role === 'user' && text(entry.message) === Q.cancel));
  demand(cancelledSession, 'qualification-cancel-session-not-found');
  const assertNoAdmission = reason => {
    const value = baseline(); demand(value.sessions === 1 && value.jobs === 2 && value.messages === 2 && value.staged === 0 && value.recalls === 2 && value.retained === 2, reason);
    const row = store.db.prepare('SELECT owner,count,cursor FROM sessions').get(); demand(row.owner === owner && row.count === accepted.count && row.cursor === accepted.cursor, 'qualification-cursor-advanced');
    return value;
  };
  const checkpoints = [positive, { phase: 'cancelled', ...assertNoAdmission('qualification-cancel-admitted') }];
  const completed = prompt => sessions().some(session => {
    const entries = messages(session); const index = entries.findIndex(entry => entry.message.role === 'user' && text(entry.message) === prompt);
    return index >= 0 && entries.slice(index + 1).some(entry => entry.message.role === 'assistant' && entry.message.stopReason === 'stop' && text(entry.message) === Q.answer);
  });
  driver.write(`${Q.afterCancel}\r`);
  await waitFor(() => completed(Q.afterCancel), 'qualification-postcancel-turn-not-completed');
  checkpoints.push({ phase: 'after-cancel', ...assertNoAdmission('qualification-consent-survived-cancel') });
  let mark = driver.text.length; driver.write('/new\r');
  await waitFor(() => driver.text.slice(mark).includes('Personal Hindsight memory') && driver.text.slice(mark).includes(services.memory), 'qualification-switch-consent-not-observed');
  driver.write('\u001b[B\n');
  await waitFor(() => driver.text.slice(mark).includes('hindsight-memory: pi_consent_required'), 'qualification-decline-not-observed');
  // A fresh native session was selected; declining its dialog cannot inherit old consent.
  driver.write(`${Q.switched}\r`);
  await waitFor(() => completed(Q.switched), 'qualification-switched-turn-not-completed');
  const switchedSession = sessions().find(session => messages(session).some(entry => entry.message.role === 'user' && text(entry.message) === Q.switched));
  demand(switchedSession?.path !== cancelledSession.path, 'qualification-session-did-not-change');
  checkpoints.push({ phase: 'switched-declined', ...assertNoAdmission('qualification-consent-survived-switch') });
  mark = driver.text.length; driver.write('/resume\r');
  await waitFor(() => driver.text.slice(mark).includes('Resume Session') && driver.text.slice(mark).includes(Q.positive) && driver.text.slice(mark).includes(Q.switched), 'qualification-resume-selector-not-observed');
  driver.write(`${Q.positive}\r`);
  await waitFor(() => driver.text.slice(mark).includes('Resumed session'), 'qualification-resume-not-observed');
  driver.write(`${Q.resumed}\r`);
  await waitFor(() => completed(Q.resumed), 'qualification-resumed-turn-not-completed');
  const resumed = sessions().find(session => messages(session).some(entry => entry.message.role === 'user' && text(entry.message) === Q.resumed));
  demand(resumed?.path === cancelledSession.path, 'qualification-wrong-session-resumed');
  checkpoints.push({ phase: 'resumed', ...assertNoAdmission('qualification-consent-survived-resume') });
  demand(services.evidence.provider.length === 5 && services.evidence.profile === 2 && services.evidence.completed.length === 2 &&
    services.evidence.health === 2 && services.evidence.requests === 15, 'qualification-service-count-mismatch');
  demand(readFileSync(plan.files[0].path, 'utf8') === plan.files[0].content, 'qualification-generated-bridge-changed');
  output.qualification = { checkpoints, secondWriterRefused: conflict, cancelledSession: cancelledSession.path, switchedSession: switchedSession.path,
    resumedSession: resumed.path, sessions: sessions(), noCallbackObservers: true };
  output.services = services.evidence; output.argv = QUALIFICATION_ARGS;
  return { driver, store };
}
