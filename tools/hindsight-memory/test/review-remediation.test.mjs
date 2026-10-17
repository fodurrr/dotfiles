import test from 'node:test';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {once} from 'node:events';
import {fixture,message} from './helpers.mjs';
import {register,capture} from '../src/capture.mjs';
import {worker} from '../src/delivery.mjs';
import {validateConfig} from '../src/config.mjs';
import {LIMITS} from '../src/state.mjs';

function queued(t,count=1){const f=fixture(t);register(f.store,f.event);capture(f.store,{...f.event,previous:null,messages:Array.from({length:count},(_,i)=>message(String(i)))},{now:2000});return f;}
const jobs=f=>f.store.db.prepare('SELECT * FROM jobs ORDER BY id').all();
const run=(f,clock,fetchImpl)=>worker(f.store,{now:()=>clock,fetchImpl,wait:false,budget:1,random:()=>0.5});

for(const status of [429,503])test(`profile HTTP ${status} preserves every queued job, then submits identical requests after recovery`,async t=>{
 const f=queued(t,2);const original=jobs(f);let healthy=false;const calls=[];
 const fetchImpl=async(url,options)=>{
  calls.push({url,method:options.method,body:options.body});
  if(url.endsWith('/profile'))return healthy?new Response(JSON.stringify({bank_id:'synthetic'})):new Response('{}',{status,headers:{'Retry-After':'10'}});
  const body=JSON.parse(options.body);return new Response(JSON.stringify({success:true,async:true,operation_id:body.operation_id}));
 };
 await run(f,3000,fetchImpl);assert.equal(calls.filter(c=>c.method==='POST').length,0);
 for(const job of jobs(f)){assert.equal(job.state,'queued');assert.equal(job.attempts,1);assert.equal(job.uncertain,0);assert.equal(job.next,13000);assert.equal(job.reason,`bank-check-http-${status}`);assert.equal(job.body,original.find(x=>x.id===job.id).body);}
 healthy=true;await run(f,13000,fetchImpl);assert.equal(calls.filter(c=>c.method==='POST').length,2);
 for(const before of original){const after=jobs(f).find(x=>x.id===before.id);assert.equal(after.state,'submitted');assert.equal(after.id,before.id);assert.equal(after.body,before.body);assert.equal(calls.find(c=>c.method==='POST' && JSON.parse(c.body).operation_id===before.id).body,before.body);}
});

test('profile transient retries exhaust at eight attempts without POST or automatic reset',async t=>{
 const f=queued(t);const original=jobs(f)[0];let calls=0;const fetchImpl=async(_url,options)=>{calls++;assert.equal(options.method,'GET');return new Response('{}',{status:503});};
 let clock=3000;for(let i=0;i<LIMITS.attempts;i++){await run(f,clock,fetchImpl);const job=jobs(f)[0];assert.equal(job.state,'queued');assert.equal(job.attempts,i+1);clock=job.next;}
 await run(f,clock,fetchImpl);const failed=jobs(f)[0];assert.equal(calls,8);assert.equal(failed.state,'failed');assert.equal(failed.reason,'attempts-exhausted');assert.equal(failed.body,original.body);assert.equal(failed.id,original.id);
});

test('profile retry age stops automatic work without losing accepted content',async t=>{
 const f=queued(t);const before=jobs(f)[0];let calls=0;const fetchImpl=async()=>{calls++;return new Response('{}',{status:503});};await run(f,3000,fetchImpl);await run(f,2000+LIMITS.age,fetchImpl);assert.equal(calls,1);assert.equal(jobs(f)[0].reason,'expired-needs-explicit-recovery');assert.equal(jobs(f)[0].body,before.body);
});

for(const [retryAfter,delay] of [['120',120000],['999999',900000]])test(`profile Retry-After ${retryAfter} respects the bounded retry delay`,async t=>{
 const f=queued(t);await run(f,3000,async()=>new Response('{}',{status:429,headers:{'Retry-After':retryAfter}}));assert.equal(jobs(f)[0].next,3000+delay);assert.equal(jobs(f)[0].uncertain,0);
});

for(const status of [400,401,403,404,409,422])test(`profile HTTP ${status} remains terminal and cannot issue a retain POST`,async t=>{
 const f=queued(t);let calls=0;await run(f,3000,async(_url,options)=>{calls++;assert.equal(options.method,'GET');return new Response('{}',{status});});assert.equal(calls,1);assert.equal(jobs(f)[0].state,'failed');assert.equal(jobs(f)[0].attempts,1);
});

for(const body of ['{"bank_id":"wrong-bank"}','{}','not-json'])test(`profile schema ${body} cannot admit a retain POST`,async t=>{
 const f=queued(t);let calls=0;await run(f,3000,async(_url,options)=>{calls++;assert.equal(options.method,'GET');return new Response(body);});assert.equal(calls,1);assert.equal(jobs(f)[0].state,'failed');
});

test('paused worker beyond lease expiry blocks BOTH recovery actions without changing the job',{skip:process.platform!=='linux'},async t=>{
 const f=queued(t);const id=jobs(f)[0].id;
 const script=`import {Store} from ${JSON.stringify(new URL('../src/state.mjs',import.meta.url).href)};const s=new Store(${JSON.stringify(f.p)});const release=s.workerMutex();const claim=s.claim(3000,{exclusive:true});s.updateJob(claim,${JSON.stringify(id)},{attempts:1,uncertain:1},3000);process.on('message',()=>{s.release(claim);release();s.close();process.exit(0);});process.send(claim);`;
 const child=spawn(process.execPath,['--disable-warning=ExperimentalWarning','--input-type=module','-e',script],{stdio:['ignore','ignore','ignore','ipc']});t.after(()=>{try{child.kill('SIGKILL');}catch{}});const [claim]=await once(child,'message');child.kill('SIGSTOP');await new Promise(resolve=>setTimeout(resolve,20));
 const before=jobs(f)[0];const lease=f.store.db.prepare('SELECT * FROM worker').get();const clock=claim.expires+1000;
 for(const action of ['reconcile','resubmit']){assert.throws(()=>f.store.recover({operation_id:id,action,acknowledge_duplicate_extraction:true},clock),/wait-for-worker-before-recovery/);assert.deepEqual(jobs(f)[0],before);assert.deepEqual(f.store.db.prepare('SELECT * FROM worker').get(),lease);}
 assert.equal((await worker(f.store,{now:()=>clock,wait:false,budget:1,fetchImpl:async()=>assert.fail('paused worker owns the process mutex')})).status,'worker-busy');
 const exited=once(child,'exit');child.kill('SIGCONT');child.send('release');await exited;
 for(const action of ['reconcile','resubmit']){const result=f.store.recover({operation_id:id,action,acknowledge_duplicate_extraction:true},clock);assert.equal(result.status,'recovery-queued');const after=jobs(f)[0];assert.equal(after.id,before.id);assert.equal(after.body,before.body);assert.equal(after.state,action==='reconcile'?'submitted':'queued');}
 assert.equal(f.store.validClaim(claim,clock),false);
});

test('recovery holds the worker mutex before and throughout the main transaction, including refusal',t=>{
 const f=queued(t);const originalTransaction=f.store.transaction.bind(f.store);const originalMutex=f.store.workerMutex.bind(f.store);let acquired=false;
 f.store.workerMutex=(options)=>{if(!options?.probe){assert.equal(f.store.db.isTransaction,false,'acquire kernel mutex before main transaction');acquired=true;}return originalMutex(options);};
 f.store.transaction=fn=>originalTransaction(()=>{assert.equal(acquired,true);assert.equal(f.store.workerLocked(),true,'new worker cannot race recovery before commit');return fn();});
 const id=jobs(f)[0].id;f.store.recover({operation_id:id,action:'reconcile'},3000);assert.equal(originalMutex({probe:true}),null,'release after successful commit');
 assert.throws(()=>f.store.recover({operation_id:'00000000-0000-0000-0000-000000000000',action:'reconcile'},4000),/job-not-recoverable/);assert.equal(originalMutex({probe:true}),null,'release after failed transaction');
});

test('cleartext HTTP permits literal loopback IPv4 and IPv6, never named localhost',()=>{
 const base={schema_version:1,bank:'synthetic',secret_file:'/private/synthetic-key',adapters:['fixture'],capture:true};
 assert.equal(new URL('http://[::1]/').hostname,'[::1]','Node24 keeps brackets in URL.hostname');
 for(const endpoint of ['http://127.0.0.1:1234','http://[::1]:1234','http://[0:0:0:0:0:0:0:1]:1234'])assert.ok(validateConfig({...base,endpoint}).endpoint.startsWith('http://'));
 for(const endpoint of ['http://localhost','http://LOCALHOST:1234','http://localhost.','http://memory.example.invalid','http://[::2]','http://192.0.2.1'])assert.throws(()=>validateConfig({...base,endpoint}),/insecure-endpoint/);
 assert.equal(validateConfig({...base,endpoint:'https://localhost'}).endpoint,'https://localhost');
});
