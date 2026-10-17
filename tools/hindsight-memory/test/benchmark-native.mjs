// Explicit SOURCE FIXTURE only. Production native activation MUST remain blocked.
// No upstream application, operator HOME, live endpoint, or real hook is executed.
import fs from 'node:fs';import path from 'node:path';import http from 'node:http';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';import {performance} from 'node:perf_hooks';import {pathToFileURL,fileURLToPath} from 'node:url';
const component=path.resolve(process.argv[2]||fileURLToPath(new URL('..',import.meta.url)));
const root=fs.mkdtempSync(path.join(fs.realpathSync(process.env.TMPDIR||'/var/tmp'),'hindsight-source-bridge-benchmark-'));fs.chmodSync(root,0o700);
const env={...process.env,HOME:root,XDG_CONFIG_HOME:path.join(root,'.config'),XDG_STATE_HOME:path.join(root,'.local/state'),XDG_DATA_HOME:path.join(root,'.local/share')};
let cli=path.join(component,'src/cli.mjs');const requests=[];const operations=new Set();
const api=http.createServer(async(req,res)=>{let raw='';for await(const part of req)raw+=part;requests.push({method:req.method,url:req.url});res.setHeader('content-type','application/json');if(req.url.endsWith('/profile'))res.end(JSON.stringify({bank_id:'synthetic-benchmark'}));else if(req.method==='POST'&&req.url.endsWith('/memories')){const body=JSON.parse(raw);operations.add(body.operation_id);res.end(JSON.stringify({success:true,async:true,operation_id:body.operation_id}));}else if(req.url.includes('/operations/')){const id=req.url.split('/').at(-1);res.end(JSON.stringify({operation_id:id,status:operations.has(id)?'completed':'not_found'}));}else{res.statusCode=404;res.end('{}');}});await new Promise(resolve=>api.listen(0,'127.0.0.1',resolve));
function command(args,input){const started=performance.now();return new Promise((resolve,reject)=>{const child=spawn(process.execPath,['--disable-warning=ExperimentalWarning',...args],{env,cwd:'/',stdio:['pipe','pipe','pipe']});let out='',err='';child.stdout.on('data',value=>out+=value);child.stderr.on('data',value=>err+=value);child.on('error',reject);child.on('exit',code=>{try{resolve({code,data:out?JSON.parse(out):null,err,ms:performance.now()-started});}catch(error){reject(error);}});child.stdin.end(input?JSON.stringify(input):'');});}
const run=(name,input)=>command([cli,name],input);
const summary=values=>{const sorted=[...values].sort((a,b)=>a-b);return{samples:sorted.length,p50_ms:+sorted[Math.ceil(sorted.length*.5)-1].toFixed(3),p95_ms:+sorted[Math.ceil(sorted.length*.95)-1].toFixed(3),max_ms:+sorted.at(-1).toFixed(3)};};
let fixtureActive=false;let result;
try{
 assert.equal((await run('prepare')).code,0);
 const record=JSON.parse(fs.readFileSync(path.join(root,'.local/share/hindsight-memory/installation.json')));cli=path.join(record.release,'src/cli.mjs');
 const secret=path.join(root,'.config/hindsight-memory/synthetic-key');fs.writeFileSync(secret,'synthetic-only',{mode:0o600});
 const agent=path.join(root,'synthetic-agent');fs.writeFileSync(agent,"#!/bin/sh\nprintf '0.163.0 (Synthetic fixture)\\n'\n",{mode:0o700});
 const config={schema_version:1,endpoint:`http://127.0.0.1:${api.address().port}`,bank:'synthetic-benchmark',secret_file:secret,capture:true,adapters:['codex-cli'],agent_versions:{'codex-cli':'0.163.0'},agent_commands:{'codex-cli':agent}};
 assert.equal((await run('configure',config)).code,0);
 const blocked=await run('activate');assert.equal(blocked.code,1);assert.equal(blocked.data.reason,'native-caller-binding-unqualified');assert.equal(fs.existsSync(path.join(root,'.codex')),false);
 // Direct core/artifact APIs wire only this deliberately synthetic isolated fixture.
 // There is no production bypass option; this does NOT qualify actual caller binding.
 const module=relative=>import(pathToFileURL(path.join(record.release,relative)).href);
 const {paths}=await module('src/config.mjs');const {Store}=await module('src/state.mjs');const {applyArtifacts}=await module('src/ownership.mjs');const {qualifyAgent}=await module('src/qualification.mjs');const {adapterArtifacts}=await module('adapters/manage.mjs');
 const descriptorPath=path.join(root,'.config/hindsight-memory/adapters/codex-cli.json');const plan=adapterArtifacts({adapter:'codex-cli',version:'0.163.0',runtime:record.runtime.path,cli,releaseDir:record.release,descriptorPath,owner:'explicit-synthetic-benchmark-owner',home:root});
 plan.descriptor.runtime_identity=record.runtime;plan.descriptor.agent_identity=qualifyAgent(agent,'0.163.0');plan.files.push({path:descriptorPath,content:JSON.stringify(plan.descriptor),mode:0o600});
 applyArtifacts(paths(env),[plan]);const store=new Store(paths(env));store.activate(config);store.close();fixtureActive=true;
 const transcript=path.join(root,'synthetic-native-session.jsonl');fs.writeFileSync(transcript,JSON.stringify({type:'session_meta',payload:{id:'synthetic-source-bridge',source:'cli',cli_version:'0.163.0'}})+'\n',{mode:0o600});
 const base={session_id:'synthetic-source-bridge',transcript_path:transcript};const hook=input=>command([path.join(record.release,'adapters/hook.mjs'),'codex-cli',descriptorPath],input);
 const start=await hook({...base,hook_event_name:'SessionStart',source:'startup'});assert.equal(start.code,0,start.err);
 const user='Synthetic new user text. '.repeat(100),answer='Synthetic assistant text. '.repeat(100);const attempts=[];
 for(let i=0;i<30;i++){
  const turn=`synthetic-turn-${i}`;fs.appendFileSync(transcript,[{type:'event_msg',payload:{type:'task_started',turn_id:turn}},{type:'event_msg',payload:{type:'user_message',message:user}},{type:'event_msg',payload:{type:'task_complete',turn_id:turn,last_agent_message:answer}}].map(row=>JSON.stringify(row)).join('\n')+'\n');
  const stopped=await hook({...base,hook_event_name:'Stop',turn_id:turn,last_assistant_message:answer});attempts.push({iteration:i+1,code:stopped.code,ms:+stopped.ms.toFixed(3),error:stopped.code?stopped.err.trim():null});
 }
 const state=(await run('status')).data;const rejected=attempts.filter(attempt=>attempt.code!==0);const acceptedJobs=Object.values(state.counts).reduce((sum,count)=>sum+count,0);
 result={component_version:record.version,artifact_digest:record.digest,node:process.version,platform:process.platform,filesystem_type_hex:'0x'+fs.statfsSync(root).type.toString(16),tmpfs:fs.statfsSync(root).type===0x01021994,payload_utf8_bytes:Buffer.byteLength(user+answer),attempted:attempts.length,succeeded:attempts.length-rejected.length,rejected:rejected.length,rejections:rejected,all_attempt_latency:summary(attempts.map(attempt=>attempt.ms)),accepted_jobs:acceptedJobs,qualification:'SOURCE FIXTURE ONLY; explicitly manual core/artifact fixture; production native activation refused; full two-Node-process bridge, growing30-turn transcript, rapid cadence and normal background worker, loopback fake API; no real agent startup/current-invoker trust, live service, macOS, slowdisk or powerloss proof'};
 if(rejected.length||acceptedJobs!==60)process.exitCode=1;
}finally{
 if(fixtureActive){await run('deactivate');let idle=false;for(let i=0;i<120;i++){const response=await run('status');const status=response.data;if(response.code===0 && status.worker_in_flight===false && status.recall_in_flight===0){idle=true;break;}await new Promise(resolve=>setTimeout(resolve,100));}assert.ok(idle,'synthetic worker must drain before cleanup');}
 await new Promise(resolve=>api.close(resolve));fs.rmSync(root,{recursive:true,force:true});
}
if(result)console.log(JSON.stringify({...result,cleanup:'all synthetic workers drained; fakeAPI closed; private fixture removed'}));
