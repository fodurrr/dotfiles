import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import http from 'node:http';
import {once} from 'node:events';
import {performance} from 'node:perf_hooks';
import {spawn} from 'node:child_process';
import {Store} from '../src/state.mjs';
import {applyArtifacts} from '../src/ownership.mjs';
import {adapterArtifacts} from '../adapters/manage.mjs';
import {qualifyAgent} from '../src/qualification.mjs';
import {paths} from '../src/config.mjs';
import {fileURLToPath} from 'node:url';
const cli=fileURLToPath(new URL('../src/cli.mjs',import.meta.url));
function command(runtime,args,env,input) {
 return new Promise((resolve,reject)=>{const child=spawn(runtime,args,{env,stdio:['pipe','pipe','pipe']});let out='',err='';child.stdout.on('data',v=>out+=v);child.stderr.on('data',v=>err+=v);child.on('error',reject);child.on('exit',status=>resolve({status,out,err,data:out?JSON.parse(out):null}));child.stdin.end(input?JSON.stringify(input):'');});
}
test('disk-backed source-fixture Codex bridge admits 30 growing turns during background delivery',async t=>{
 const h=fs.mkdtempSync(path.join(fs.realpathSync(process.platform==='linux'?'/var/tmp':os.tmpdir()),'hindsight-e2e-'));fs.chmodSync(h,0o700);
 const env={...process.env,HOME:h,XDG_CONFIG_HOME:path.join(h,'.config'),XDG_STATE_HOME:path.join(h,'.local/state'),XDG_DATA_HOME:path.join(h,'.local/share')};
 const calls=[];const operations=new Set();const api=http.createServer(async(req,res)=>{let raw='';for await(const v of req)raw+=v;calls.push({url:req.url,method:req.method,body:raw});res.setHeader('content-type','application/json');
  if(req.url.endsWith('/profile'))res.end(JSON.stringify({bank_id:'synthetic-only'}));
  else if(req.url.endsWith('/memories/recall'))res.end(JSON.stringify({results:[{id:'synthetic-memory',text:'An explicitly untrusted synthetic fact.'}]}));
  else if(req.method==='POST' && req.url.endsWith('/memories')){const body=JSON.parse(raw);operations.add(body.operation_id);res.end(JSON.stringify({success:true,async:true,operation_id:body.operation_id}));}
  else if(req.method==='GET' && req.url.includes('/operations/')){const id=req.url.split('/').at(-1);res.end(JSON.stringify({operation_id:id,status:operations.has(id)?'completed':'not_found'}));}
  else {res.statusCode=500;res.end('{}');}
 });api.listen(0,'127.0.0.1');await once(api,'listening');
 const run=(name,input)=>command(process.execPath,['--disable-warning=ExperimentalWarning',cli,name],env,input);
 t.after(async()=>{await run('deactivate');let idle=false;for(let i=0;i<120;i++){const r=await run('status');if(r.status===0 && r.data.worker_in_flight===false && r.data.recall_in_flight===0){idle=true;break;}await new Promise(r=>setTimeout(r,100));}assert.ok(idle,'worker must finish before deleting synthetic home/server');await new Promise(r=>api.close(r));fs.rmSync(h,{recursive:true,force:true});});
 assert.equal((await run('prepare')).status,0);
 const secret=path.join(h,'.config/hindsight-memory/test-secret');fs.writeFileSync(secret,'synthetic-only',{mode:0o600});
 const agent=path.join(h,'synthetic-agent');fs.writeFileSync(agent,`#!/bin/sh\nprintf '0.163.0 (Synthetic fixture)\\n'\n`,{mode:0o700});
 const config={schema_version:1,endpoint:`http://127.0.0.1:${api.address().port}`,bank:'synthetic-only',secret_file:secret,capture:true,adapters:['codex-cli'],agent_versions:{'codex-cli':'0.163.0'},agent_commands:{'codex-cli':agent}};
 assert.equal((await run('configure',config)).status,0);const preview=await run('activation-preview');assert.equal(preview.data.adapters[0].id,'codex-cli');assert.equal(fs.existsSync(path.join(h,'.codex')),false);
 const activation=await run('activate');assert.equal(activation.status,1);assert.equal(activation.data.reason,'native-caller-binding-unqualified');
 // This is an explicit synthetic fixture, not a production activation override.
 // Native caller binding remains blocked. Direct core APIs let us test the
 // artifact protocol without executing or certifying an upstream application.
 const record=JSON.parse(fs.readFileSync(path.join(h,'.local/share/hindsight-memory/installation.json')));const descriptor=path.join(h,'.config/hindsight-memory/adapters/codex-cli.json');
 const plan=adapterArtifacts({adapter:'codex-cli',version:'0.163.0',runtime:record.runtime.path,cli:path.join(record.release,'src/cli.mjs'),releaseDir:record.release,descriptorPath:descriptor,owner:'explicit-synthetic-owner',home:h});
 plan.descriptor.runtime_identity=record.runtime;plan.descriptor.agent_identity=qualifyAgent(agent,'0.163.0');plan.files.push({path:descriptor,content:JSON.stringify(plan.descriptor),mode:0o600});
 applyArtifacts(paths(env),[plan]);const fixtureStore=new Store(paths(env));fixtureStore.activate(config);fixtureStore.close();
 assert.equal((await run('configure',config)).data.reason,'deactivate-before-configure');
 const hook=input=>command(process.execPath,[path.join(record.release,'adapters/hook.mjs'),'codex-cli',descriptor],env,input);
 const transcript=path.join(h,'native-session.jsonl');const meta={type:'session_meta',payload:{id:'native-synthetic',source:'cli',cli_version:'0.163.0'}};fs.writeFileSync(transcript,JSON.stringify(meta)+'\n',{mode:0o600});
 const base={session_id:'native-synthetic',turn_id:'native-turn-1',transcript_path:transcript};
 assert.equal((await hook({...base,hook_event_name:'SessionStart',source:'startup'})).status,0);
 const prompt=await hook({...base,hook_event_name:'UserPromptSubmit',prompt:'New synthetic user question.'});assert.equal(prompt.status,0,prompt.err);assert.ok(prompt.data.hookSpecificOutput.additionalContext.includes('untrusted'));
 const samples=[];const failures=[];
 for(let i=0;i<30;i++){
  const turn_id=`native-turn-${i+1}`;
  const user=i===0?'New synthetic user question.':(`Synthetic user ${i}. `).padEnd(2450,'u');
  const answer=i===0?'New synthetic assistant answer.':(`Synthetic assistant ${i}. `).padEnd(2450,'a');
  fs.appendFileSync(transcript,[{type:'event_msg',payload:{type:'task_started',turn_id}},{type:'event_msg',payload:{type:'user_message',message:user}},{type:'event_msg',payload:{type:'task_complete',turn_id,last_agent_message:answer}}].map(row=>JSON.stringify(row)).join('\n')+'\n');
  const started=performance.now();const stopped=await hook({...base,turn_id,hook_event_name:'Stop',last_assistant_message:answer});samples.push(performance.now()-started);
  if(stopped.status!==0)failures.push({iteration:i+1,status:stopped.status,diagnostic:stopped.err});
 }
 samples.sort((a,b)=>a-b);t.diagnostic(JSON.stringify({fixture:'synthetic source bridge only; production activation remains blocked',filesystem_type_hex:'0x'+fs.statfsSync(h).type.toString(16),samples:30,rejected:failures.length,p50_ms:samples[15],p95_ms:samples[28],max_ms:samples[29]}));
 assert.deepEqual(failures,[],'every rejection is counted; later suffix recovery cannot hide a failed sample');
 let state;for(let i=0;i<200;i++){state=(await run('status')).data;if(state.counts?.completed===60 && !state.worker_in_flight)break;await new Promise(r=>setTimeout(r,100));}
 assert.equal(state.counts?.completed,60,JSON.stringify(state));assert.equal(calls.filter(c=>c.method==='POST' && c.url.endsWith('/memories')).length,60);assert.equal(calls.filter(c=>c.url.endsWith('/recall')).length,1);assert.ok(calls.every(c=>!c.url.includes('reflect') && !c.url.includes('bank/config')));
 const bodies=calls.filter(c=>c.url.endsWith('/memories')).map(c=>JSON.parse(c.body).items[0].content);assert.ok(bodies.includes('user: New synthetic user question.'));assert.ok(bodies.includes('assistant: New synthetic assistant answer.'));assert.ok(bodies.every(body=>!body.includes('synthetic fact')));
 const rollback=await run('rollback');assert.equal(rollback.status,0);const settings=JSON.parse(fs.readFileSync(path.join(h,'.codex/hooks.json')));assert.ok(!settings.hooks.Stop);assert.equal((await run('status')).data.active,false);
});
