import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { DatabaseSync } from 'node:sqlite';
import { privateDir, privatePath, fail, hash, destination } from './config.mjs';

export const LIMITS = Object.freeze({jobs:1000, bytes:64*1024*1024, disk:128*1024*1024, job:64*1024, age:86400000, attempts:8, polls:24, worker:60000, request:10000});
export class Store {
  constructor(p, {readOnly = false, limits = {}} = {}) {
    this.p = p; this.limits = {...LIMITS, ...limits}; this.file = path.join(p.state, 'state.sqlite');
    if (!readOnly) privateDir(p.state); else privatePath(p.state, true);
    const exists = fs.existsSync(this.file);
    if (exists) privatePath(this.file); else if (readOnly) fail('state-missing');
    // Sidecars are never trusted or followed. DELETE journalling bounds one rollback journal.
    for (const suffix of ['-journal','-wal','-shm']) if (fs.existsSync(this.file + suffix)) privatePath(this.file + suffix);
    if (!exists) { const fd = fs.openSync(this.file, fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW | fs.constants.O_RDWR, 0o600); fs.closeSync(fd); }
    this.db = new DatabaseSync(this.file, {readOnly, timeout:50});
    this.readOnly = readOnly;
    if(this.db.prepare('PRAGMA page_size').get().page_size!==4096){this.db.close();fail('unsupported-sqlite-page-size');}
    if (exists) {
      try { if (this.db.prepare("SELECT value FROM meta WHERE key='schema'").get()?.value !== '1') fail('unsupported-state-schema'); }
      catch (error) { this.db.close(); throw error; }
    }
    if (!readOnly) {
      this.db.exec('PRAGMA journal_mode=DELETE; PRAGMA synchronous=FULL; PRAGMA foreign_keys=ON; PRAGMA max_page_count=14336;');
      this.db.exec(`CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY,value TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS activations(id TEXT PRIMARY KEY,created INTEGER NOT NULL,config TEXT NOT NULL,destination TEXT NOT NULL,active INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS sessions(key TEXT PRIMARY KEY,generation TEXT NOT NULL,agent TEXT NOT NULL,session TEXT NOT NULL,owner TEXT NOT NULL,cursor TEXT,prefix TEXT NOT NULL,count INTEGER NOT NULL,dirty INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS messages(session_key TEXT NOT NULL,id TEXT NOT NULL,digest TEXT NOT NULL,PRIMARY KEY(session_key,id));
        CREATE TABLE IF NOT EXISTS jobs(id TEXT PRIMARY KEY,generation TEXT NOT NULL,endpoint TEXT NOT NULL,bank TEXT NOT NULL,secret_file TEXT NOT NULL,body TEXT,bytes INTEGER NOT NULL,created INTEGER NOT NULL,state TEXT NOT NULL,attempts INTEGER NOT NULL DEFAULT 0,polls INTEGER NOT NULL DEFAULT 0,next INTEGER NOT NULL,uncertain INTEGER NOT NULL DEFAULT 0,reason TEXT,recovery INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS worker(id INTEGER PRIMARY KEY CHECK(id=1),token TEXT NOT NULL,expires INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS staged(session_key TEXT PRIMARY KEY,turn_id TEXT NOT NULL,prompt TEXT NOT NULL,created INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS recalls(key TEXT PRIMARY KEY,created INTEGER NOT NULL,in_flight_until INTEGER NOT NULL);`);
      const version = this.db.prepare("SELECT value FROM meta WHERE key='schema'").get();
      if (version && version.value !== '1') fail('unsupported-state-schema');
      this.db.prepare("INSERT OR IGNORE INTO meta VALUES('schema','1')").run();
    } else if (this.db.prepare("SELECT value FROM meta WHERE key='schema'").get()?.value !== '1') fail('unsupported-state-schema');
  }
  close() { this.db.close(); }
  transaction(fn) {
    this.db.exec('BEGIN IMMEDIATE');
    try { const result = fn(); this.db.exec('COMMIT'); return result; }
    catch (error) { try { this.db.exec('ROLLBACK'); } catch {} throw error; }
  }
  diskBytes() {
    return fs.readdirSync(this.p.state).reduce((sum, file) => {
      let s;try{s=fs.lstatSync(path.join(this.p.state,file));}catch(error){if(error.code==='ENOENT')return sum;throw error;} if (s.isSymbolicLink() || !s.isFile()) fail('unexpected-state-file'); return sum + s.size;
    },0);
  }
  capacity(bytes = 0) {
    // A rollback transaction may duplicate modified pages. Keep headroom before BEGIN writes.
    const physical = this.diskBytes();
    if (physical * 2 + bytes * 3 + 1024*1024 > this.limits.disk) fail('state-capacity');
  }
  active() {
    const row = this.db.prepare('SELECT * FROM activations WHERE active=1').get();
    if (!row) fail('inactive'); return {...row, config:JSON.parse(row.config)};
  }
  activate(config, now = Date.now()) {
    this.capacity();
    return this.transaction(() => {
      const old = this.db.prepare('SELECT * FROM activations WHERE active=1').get();
      const normalized = JSON.stringify(config);
      if (old) { if (old.config === normalized) return old.id; fail('deactivate-before-config-change'); }
      const previous = this.db.prepare('SELECT id FROM activations WHERE config=? ORDER BY created DESC LIMIT 1').get(normalized);
      if (previous) { this.db.prepare('UPDATE activations SET active=1 WHERE id=?').run(previous.id); return previous.id; }
      const id = crypto.randomUUID();
      this.db.prepare('INSERT INTO activations VALUES(?,?,?,?,1)').run(id,now,normalized,destination(config)); return id;
    });
  }
  deactivate(now = Date.now()) {
    return this.transaction(() => {
      this.db.prepare('UPDATE activations SET active=0 WHERE active=1').run();
      this.db.prepare("INSERT INTO meta VALUES('lifecycle','1') ON CONFLICT(key) DO UPDATE SET value=CAST(value AS INTEGER)+1").run();
      const worker = this.db.prepare('SELECT expires FROM worker WHERE id=1').get();
      const recall=this.db.prepare('SELECT max(in_flight_until) expires FROM recalls').get();
      const until=Math.max(worker?.expires || 0,recall?.expires || 0);
      const held=this.workerLocked();const recallHeld=this.recallLocked();
      if(!held)this.db.prepare('DELETE FROM worker').run();
      if(!recallHeld)this.db.prepare('UPDATE recalls SET in_flight_until=0').run();
      return {status:held || recallHeld ? 'suspension-pending' : 'suspended',in_flight_until:(held || recallHeld) && until>now?until:null,worker_process_holds_lock:held,recall_process_holds_lock:recallHeld};
    });
  }
  sessionKey(a, input) { return hash(JSON.stringify([a.id,input.agent,input.session])); }
  register(input, normalized, now = Date.now()) {
    this.capacity(Buffer.byteLength(JSON.stringify(normalized)));
    return this.transaction(() => {
      const a = this.active(); if (!a.config.adapters.includes(input.agent)) fail('adapter-not-selected');
      const key = this.sessionKey(a,input); const old = this.db.prepare('SELECT * FROM sessions WHERE key=?').get(key);
      if (old) { if (old.owner !== input.owner) fail('session-owner-conflict'); return {status:'registered',previous:old.cursor,count:old.count}; }
      this.db.prepare('INSERT INTO sessions(key,generation,agent,session,owner,cursor,prefix,count) VALUES(?,?,?,?,?,?,?,?)').run(key,a.id,input.agent,input.session,input.owner,normalized.at(-1)?.id || null,hash(JSON.stringify(normalized)),normalized.length);
      for (const m of normalized) this.db.prepare('INSERT INTO messages VALUES(?,?,?)').run(key,m.id,hash(JSON.stringify(m)));
      return {status:'registered',previous:normalized.at(-1)?.id || null,count:normalized.length};
    });
  }
  getSession(input) {
    const a = this.active(); const row = this.db.prepare('SELECT * FROM sessions WHERE key=?').get(this.sessionKey(a,input));
    if (!row || row.owner !== input.owner || row.dirty) fail('unknown-or-dirty-session'); return row;
  }
  admit(input, messages, {transcript = false, now = Date.now(), makeJobs, beforeCommit, inside = false} = {}) {
    this.capacity(Buffer.byteLength(JSON.stringify(messages)));
    const work = () => {
      const a = this.active(); if (!a.config.adapters.includes(input.agent)) fail('adapter-not-selected');
      const row = this.getSession(input);
      let suffix = messages;
      if (transcript) {
        if (messages.length < row.count || hash(JSON.stringify(messages.slice(0,row.count))) !== row.prefix) fail('transcript-boundary-conflict');
        suffix = messages.slice(row.count);
      } else if ((input.previous ?? null) !== row.cursor) {
        // Repeat delivery is harmless only if every identity and digest already matches.
        if (messages.length && messages.every(m => this.db.prepare('SELECT digest FROM messages WHERE session_key=? AND id=?').get(row.key,m.id)?.digest === hash(JSON.stringify(m)))) return {status:'duplicate',accepted:0};
        fail('cursor-conflict');
      }
      if (!suffix.length) return {status:'duplicate',accepted:0};
      for (const m of suffix) if (this.db.prepare('SELECT id FROM messages WHERE session_key=? AND id=?').get(row.key,m.id)) fail('message-identity-conflict');
      const jobs = makeJobs(a,suffix,now);
      if (jobs.some(j => j.bytes > this.limits.job)) fail('job-too-large');
      const used = this.db.prepare("SELECT count(*) AS n,coalesce(sum(bytes),0) AS bytes FROM jobs WHERE state!='completed'").get();
      const bytes = jobs.reduce((n,j) => n+j.bytes,0);
      if (used.n + jobs.length > this.limits.jobs || used.bytes + bytes > this.limits.bytes) fail('outbox-capacity');
      this.capacity(bytes);
      for (const j of jobs) this.db.prepare("INSERT INTO jobs(id,generation,endpoint,bank,secret_file,body,bytes,created,state,next) VALUES(?,?,?,?,?,?,?,?,'queued',?)").run(j.id,a.id,a.config.endpoint,a.config.bank,a.config.secret_file,j.body,j.bytes,now,now);
      for (const m of suffix) this.db.prepare('INSERT INTO messages VALUES(?,?,?)').run(row.key,m.id,hash(JSON.stringify(m)));
      // Direct events cannot later switch to full-transcript recovery without registration.
      const prefix = transcript ? hash(JSON.stringify(messages)) : hash(JSON.stringify([row.prefix,...suffix]));
      this.db.prepare('UPDATE sessions SET cursor=?,prefix=?,count=? WHERE key=?').run(suffix.at(-1).id,prefix,row.count+suffix.length,row.key);
      beforeCommit?.();
      return {status:'queued',accepted:suffix.length,jobs:jobs.length,bytes};
    };
    return inside ? work() : this.transaction(work);
  }
  workerMutex({probe=false,name='worker'}={}) {
    const file=path.join(this.p.state,`${name}-lock.sqlite`);
    if(!fs.existsSync(file)){
      if(probe)return null;
      try{const fd=fs.openSync(file,fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_WRONLY|fs.constants.O_NOFOLLOW,0o600);fs.closeSync(fd);}catch(error){if(error.code!=='EEXIST')throw error;}
    }
    privatePath(file);const db=new DatabaseSync(file,{timeout:0});
    try{db.exec('BEGIN IMMEDIATE');}catch(error){db.close();if(error.code==='ERR_SQLITE_ERROR' && /locked/.test(error.message))return false;throw error;}
    const release=()=>{try{db.exec('ROLLBACK');}finally{db.close();}};
    if(probe){release();return null;}return release;
  }
  workerLocked() {return this.workerMutex({probe:true})===false;}
  recallLocked() {return this.workerMutex({probe:true,name:'recall'})===false;}
  claim(now = Date.now(), {exclusive = false} = {}) {
    return this.transaction(() => {
      this.active();
      const current = this.db.prepare('SELECT * FROM worker WHERE id=1').get();
      if (!exclusive && current && current.expires > now) return null;
      const token = crypto.randomUUID(); const expires = now+LIMITS.worker+LIMITS.request;
      this.db.prepare('INSERT OR REPLACE INTO worker VALUES(1,?,?)').run(token,expires); return {token,expires,lifecycle:this.lifecycle()};
    });
  }
  validClaim(claim, now = Date.now()) {
    const row = this.db.prepare('SELECT * FROM worker WHERE id=1').get();
    const active = this.db.prepare('SELECT id FROM activations WHERE active=1').get();
    return !!active && claim.lifecycle===this.lifecycle() && row?.token === claim.token && row.expires > now;
  }
  release(claim) { this.db.prepare('DELETE FROM worker WHERE token=?').run(claim.token); }
  updateJob(claim,id,values,now = Date.now()) {
    return this.transaction(() => {
      if (!this.validClaim(claim,now)) fail('worker-fenced');
      const allowed = ['state','attempts','polls','next','uncertain','reason'];
      const keys = Object.keys(values); if (keys.some(k => !allowed.includes(k))) fail('invalid-job-update');
      this.db.prepare(`UPDATE jobs SET ${keys.map(k=>`${k}=?`).join(',')} WHERE id=?`).run(...keys.map(k=>values[k]),id);
      if (values.state === 'completed') this.db.prepare('UPDATE jobs SET body=NULL,bytes=0 WHERE id=?').run(id);
    });
  }
  nextJob(now = Date.now()) {
    return this.db.prepare("SELECT jobs.* FROM jobs JOIN activations ON jobs.generation=activations.id WHERE activations.active=1 AND jobs.state IN ('queued','submitted') AND next<=? ORDER BY created,id LIMIT 1").get(now);
  }
  recover(input,now=Date.now()) {
    if (!/^[a-f0-9-]{36}$/.test(input?.operation_id || '') || !['reconcile','resubmit'].includes(input.action)) fail('invalid-recovery');
    if(input.action==='resubmit' && input.acknowledge_duplicate_extraction!==true) fail('recovery-needs-duplicate-risk-acknowledgement');
    return this.transaction(()=>{
      const a=this.active(); const job=this.db.prepare('SELECT * FROM jobs WHERE id=?').get(input.operation_id);
      if(!job || job.generation!==a.id || !job.body || !['failed','queued','submitted'].includes(job.state)) fail('job-not-recoverable');
      const lease=this.db.prepare('SELECT expires FROM worker WHERE id=1').get();
      if(lease && lease.expires>now) fail('wait-for-worker-before-recovery');
      this.db.prepare('UPDATE jobs SET state=?,attempts=0,polls=0,next=?,uncertain=?,reason=?,recovery=? WHERE id=?').run(input.action==='reconcile'?'submitted':'queued',now,input.action==='reconcile'?1:0,'explicit-recovery',now,job.id);
      return {status:'recovery-queued',operation_id:job.id,action:input.action};
    });
  }
  nextDue() {return this.db.prepare("SELECT min(next) due FROM jobs JOIN activations ON jobs.generation=activations.id WHERE activations.active=1 AND jobs.state IN ('queued','submitted')").get()?.due;}
  recallOnce(key,now = Date.now()) {
    this.capacity(); return this.transaction(() => { this.active(); return this.db.prepare('INSERT OR IGNORE INTO recalls VALUES(?,?,?)').run(key,now,now+1500).changes === 1; });
  }
  lifecycle() {return this.db.prepare("SELECT value FROM meta WHERE key='lifecycle'").get()?.value || '0';}
  finishRecall(key) {this.db.prepare('UPDATE recalls SET in_flight_until=0 WHERE key=?').run(key);}
  status(now = Date.now(), {offset=0}={}) {
    if(!Number.isInteger(offset) || offset<0 || offset>1000)fail('invalid-status-offset');
    const a = this.db.prepare('SELECT id,created FROM activations WHERE active=1').get();
    const counts = Object.fromEntries(this.db.prepare('SELECT state,count(*) n FROM jobs GROUP BY state').all().map(r=>[r.state,r.n]));
    const worker = this.db.prepare('SELECT expires FROM worker WHERE id=1').get();
    const total=this.db.prepare("SELECT count(*) n FROM jobs WHERE state!='completed'").get().n;
    const operations=this.db.prepare("SELECT id,state,reason,attempts,polls,created,next FROM jobs WHERE state!='completed' ORDER BY created,id LIMIT 10 OFFSET ?").all(offset).map(row=>({
      operation_id:/^[a-f0-9-]{36}$/.test(row.id)?row.id:'invalid-id',state:['queued','submitted','failed'].includes(row.state)?row.state:'unknown',
      reason:row.reason===null?null:/^[a-z0-9-]{1,80}$/.test(row.reason)?row.reason:'invalid-reason',attempts:row.attempts,polls:row.polls,next_attempt_at_ms:row.next
    }));
    return {operations,operations_offset:offset,operations_limit:10,operations_remaining:Math.max(0,total-offset-operations.length),active:!!a,generation:a?.id || null,activated_at:a ? new Date(a.created).toISOString() : null,counts,worker_in_flight:!!worker,recall_in_flight:this.db.prepare('SELECT count(*) n FROM recalls WHERE in_flight_until>0').get().n,disk_bytes:this.diskBytes()};
  }
}
