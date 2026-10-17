import test from 'node:test';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {once} from 'node:events';
import {performance} from 'node:perf_hooks';
import {fixture,message} from './helpers.mjs';
import {register} from '../src/capture.mjs';

// Actual disk-backed Linux fixture. Direct main() dependency injection suppresses
// only detached wake creation, so every child can be joined before cleanup.
// There is no CLI flag or environment variable that bypasses production policy.
test('fresh core command waits through ordinary disk contention and refuses sustained locks honestly',{skip:process.platform!=='linux'},async t=>{
 const f=fixture(t,{}, {temporaryRoot:'/var/tmp'});register(f.store,f.event);
 const script=`import {main,safeFailure} from ${JSON.stringify(new URL('../src/cli.mjs',import.meta.url).href)};main('capture',{wakeImpl:()=> 'fixture-suppressed'}).then(r=>console.log(JSON.stringify({schema_version:1,...r}))).catch(e=>{console.log(JSON.stringify(safeFailure(e)));process.exitCode=1;});`;
 const env={...process.env,HOME:f.home,XDG_CONFIG_HOME:f.home+'/.config',XDG_STATE_HOME:f.home+'/.local/state',XDG_DATA_HOME:f.home+'/.local/share'};
 for(const [id,holdMs,expected] of [['1',150,0],['2',1000,1]]) {
  f.store.db.exec('BEGIN EXCLUSIVE');let held=true;t.after(()=>{if(held){try{f.store.db.exec('ROLLBACK');}catch{}}});
  const start=performance.now();const child=spawn(process.execPath,['--disable-warning=ExperimentalWarning','--input-type=module','-e',script],{env,stdio:['pipe','pipe','pipe']});let out='';child.stdout.on('data',v=>out+=v);let stderr='';child.stderr.on('data',v=>stderr+=v);const exited=once(child,'exit');child.stdin.end(JSON.stringify({...f.event,previous:id==='1'?null:'1',messages:[message(id,'Synthetic five-kilobyte message. '.repeat(170))]}));
  await new Promise(resolve=>setTimeout(resolve,holdMs));f.store.db.exec('ROLLBACK');held=false;
  const [code]=await exited;const result=JSON.parse(out);assert.equal(code,expected,out+stderr);
  if(expected===0){assert.equal(result.status,'queued');assert.ok(result.admission_ms>=75,'local metric includes constructor contention');}
  else{assert.equal(result.reason,'state-busy-admission-not-confirmed');assert.equal(f.store.getSession(f.event).cursor,'1');assert.equal(f.store.db.prepare('SELECT count(*) n FROM jobs').get().n,1);}
  assert.ok(performance.now()-start<3000,'bounded test and command lifetime');
 }
});
