import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fixture} from './helpers.mjs';
import {writePrivate,privateDir,hash,destination} from '../src/config.mjs';
import {register,stageTurn,completeTurn,abortTurn} from '../src/capture.mjs';
import {handleCodexHook,verifyCaller,processIdentity,codexHookConfig,prepareCodexLaunch,validateProfileConfig,CODEX_ELF_SHA256} from '../adapters/codex.mjs';
import {adapterArtifacts} from '../adapters/manage.mjs';
const descriptor={schema_version:1,runtime:process.execPath,cli:'/release/src/cli.mjs',owner:'a'.repeat(64),agentVersion:'0.163.0',agent_identity:{path:'/native',requested:'/native',dev:1,ino:2,sha256:CODEX_ELF_SHA256}};
const event=(name,extra={})=>({session_id:'session',hook_event_name:name,...extra});
function recorder(){const calls=[];return {calls,invoke:(command,input)=>{calls.push({command,input});return {status:command==='recall'?'recalled':'queued',context:'UNTRUSTED MEMORY'};}};}
function binding(){return {schema_version:1,launcher:100,child:{pid:101,start:'20'},destination:'destination',session:null,revoked:false,pending:null};}
test('Codex direct native fields stage exact prompt, inject recall and complete matching answer without transcript reads',()=>{
 const b=binding();const r=recorder();
 handleCodexHook(event('SessionStart',{source:'startup'}),descriptor,b,r.invoke);
 const output=handleCodexHook(event('UserPromptSubmit',{turn_id:'turn',prompt:'exact question'}),descriptor,b,r.invoke);
 handleCodexHook(event('Stop',{turn_id:'turn',last_assistant_message:'exact answer',stop_hook_active:false}),descriptor,b,r.invoke);
 assert.deepEqual(r.calls.map(c=>c.command),['session','stage-turn','recall','complete-turn']);
 assert.deepEqual(r.calls[0].input.baseline,[]);assert.equal(r.calls[0].input.fresh,true);
 assert.equal(r.calls[1].input.prompt,'exact question');assert.equal(r.calls[3].input.text,'exact answer');
 assert.equal(r.calls[3].input.turn_id,'turn');assert.equal(r.calls[3].input.expected_destination,'destination');
 assert.equal(output.hookSpecificOutput.additionalContext,'UNTRUSTED MEMORY');assert.equal(b.pending,null);
});
test('Codex refuses unsupported boundaries, subagents, missing fields, wrong turns and continuations before writing',()=>{
 for(const input of [event('SessionStart',{source:'resume'}),event('SessionStart',{source:'fork'}),event('SessionStart',{source:'compact'}),event('SessionStart',{source:'startup',agent_id:'child'}),event('Stop',{turn_id:'wrong',last_assistant_message:'answer'}),event('UserPromptSubmit',{prompt:'x'}),event('UserPromptSubmit',{turn_id:'t'}),event('Stop',{turn_id:'t',stop_hook_active:true,last_assistant_message:'synthetic answer'})]){
  const b=binding();if(input.hook_event_name!=='SessionStart'){b.session='session';b.pending='t';}
  const r=recorder();assert.throws(()=>handleCodexHook(input,descriptor,b,r.invoke));assert.equal(r.calls.length,0);
 }
});
test('Codex interrupted and steered turns cannot later commit an incomplete prompt-answer pair',()=>{
 for(const boundary of ['Interrupt','UserPromptSubmit']){
  const b={...binding(),session:'session',pending:'turn'};const r=recorder();
  const input=event(boundary,{turn_id:'turn',prompt:'steering text'});
  if(boundary==='Interrupt')handleCodexHook(input,descriptor,b,r.invoke);else assert.throws(()=>handleCodexHook(input,descriptor,b,r.invoke),/steering/);
  assert.deepEqual(r.calls.map(c=>c.command),['abort-turn']);
  assert.throws(()=>handleCodexHook(event('Stop',{turn_id:'turn',last_assistant_message:'answer'}),descriptor,b,r.invoke),/unmatched/);
  assert.equal(r.calls.length,1);
 }
});
test('real core rejects wrong turns and failed staging, then accepts an exact completed pair',t=>{
 const f=fixture(t);f.store.deactivate();f.store.activate({...f.config,adapters:['codex-cli']});
 const b={...binding(),destination:destination(f.config)};
 const invoke=(command,input)=>command==='session'?register(f.store,input):command==='stage-turn'?stageTurn(f.store,input):command==='complete-turn'?completeTurn(f.store,input):command==='abort-turn'?abortTurn(f.store,input):{status:'recall-unavailable'};
 handleCodexHook(event('SessionStart',{source:'startup'}),descriptor,b,invoke);
 handleCodexHook(event('UserPromptSubmit',{turn_id:'turn',prompt:'new text'}),descriptor,b,invoke);
 assert.throws(()=>handleCodexHook(event('Stop',{turn_id:'other',last_assistant_message:'wrong answer'}),descriptor,b,invoke));
 assert.equal(f.store.db.prepare('SELECT count(*) n FROM jobs').get().n,0);
 assert.throws(()=>handleCodexHook(event('UserPromptSubmit',{turn_id:'turn',prompt:'steering'}),descriptor,b,invoke));
 assert.equal(f.store.status().staged_turns,0);
 assert.throws(()=>handleCodexHook(event('Stop',{turn_id:'turn',last_assistant_message:'unmatched'}),descriptor,b,invoke));
 assert.equal(f.store.db.prepare('SELECT count(*) n FROM jobs').get().n,0);
 const failed={...binding(),session:'session'};let saved;
 assert.throws(()=>handleCodexHook(event('UserPromptSubmit',{turn_id:'failure',prompt:'no false acceptance'}),descriptor,failed,(command,input)=>{if(command==='stage-turn')throw Error('disk unavailable');return invoke(command,input);},value=>{saved={...value};}));
 assert.equal(saved.pending,null);assert.equal(saved.poisoned,'failure');
 handleCodexHook(event('UserPromptSubmit',{turn_id:'good',prompt:'exact accepted prompt'}),descriptor,b,invoke);
 handleCodexHook(event('Stop',{turn_id:'good',last_assistant_message:'exact accepted answer'}),descriptor,b,invoke);
 const jobs=f.store.db.prepare('SELECT body FROM jobs').all();assert.equal(jobs.length,2);
 assert.deepEqual(jobs.map(job=>JSON.parse(job.body).items[0].content).sort(),['assistant: exact accepted answer','user: exact accepted prompt']);
 assert.equal(f.store.status().staged_turns,0);
});
test('caller binding checks native PID, start time, executable and close ancestor chain',()=>{
 const b=binding();const identity={pid:101,ppid:100,start:'20',executable:'/native',dev:1,ino:2};
 verifyCaller(b,descriptor,{pid:102,observe:pid=>pid===102?{pid:102,ppid:101}:identity});
 for(const changed of [{...identity,start:'reused'},{...identity,executable:'/other'},{...identity,ino:3}])assert.throws(()=>verifyCaller(b,descriptor,{pid:101,observe:()=>changed}));
 assert.throws(()=>verifyCaller(b,descriptor,{pid:500,observe:pid=>({pid,ppid:pid-1})}));
 assert.throws(()=>verifyCaller({...b,revoked:true},descriptor,{pid:101,observe:()=>identity}));
 const self=processIdentity(process.pid);assert.equal(self.pid,process.pid);assert.match(self.start,/^\d+$/);
});
test('Codex owned launcher uses inline scoped hooks, native trust and no global JSON patches',()=>{
 const plan=adapterArtifacts({adapter:'codex-cli',version:'0.163.0',runtime:'/node',cli:'/release/src/cli.mjs',releaseDir:'/release',descriptorPath:'/descriptor',owner:'a'.repeat(64),home:'/home/user'});
 assert.equal(plan.jsonPatches.length,0);assert.equal(plan.files[0].path,'/home/user/.local/bin/codex-memory');
 assert(plan.files[0].content.startsWith('#!/bin/sh\n'));assert(plan.files[0].content.includes('"$@"'));
 const args=codexHookConfig(descriptor,'/descriptor');assert(args.some(arg=>arg.startsWith('hooks.Interrupt=')));
 assert(!args.includes('--dangerously-bypass-hook-trust'));assert(args.includes('cli_auth_credentials_store="file"'));assert(!JSON.stringify(args).includes('hooks.json'));
});
test('private profile accepts only native trust state and rejects extra hook or plugin config',()=>{
 validateProfileConfig('[hooks.state.fixture]\nenabled = true\ntrusted_hash = "abcd1234"\n[projects."/private/work"]\ntrust_level = "trusted"\n');
 for(const text of ['[[hooks.Stop]]\n','[plugins.x]\nenabled = true\n','notify = ["capture"]\n','[hooks.state.x]\ncommand = "capture"\n'])assert.throws(()=>validateProfileConfig(text),/profile_config/);
});
test('isolated launch keeps global config, auth and trust intact; reuses private trust and refuses foreign sources',t=>{
 const f=fixture(t);const globalHome=path.join(f.home,'.codex');privateDir(globalHome);
 writePrivate(path.join(globalHome,'auth.json'),JSON.stringify({auth_mode:'chatgpt',tokens:{access_token:'SYNTHETIC'}}));
 writePrivate(path.join(globalHome,'config.toml'),'[hooks.state.global]\ntrusted_hash = "GLOBAL"\n');writePrivate(path.join(globalHome,'hooks.json'),'{"hooks":{"Stop":[]}}');
 const globalBefore=fs.readdirSync(globalHome).map(name=>[name,hash(fs.readFileSync(path.join(globalHome,name)))]);
 writePrivate(path.join(f.p.config,'config.json'),JSON.stringify({...f.config,adapters:['pi','codex-cli'],capture_owners:{'codex-cli':descriptor.owner}}));
 const options={env:{HOME:f.home,NODE_OPTIONS:'--forbidden'},systemFiles:[],inspectAgentImpl:()=>({...descriptor.agent_identity})};
 const launch=prepareCodexLaunch(descriptor,'/descriptor',[],options);
 assert.equal(launch.executable,'/native');assert.equal(launch.env.CODEX_HOME,path.join(f.p.state,'codex-profile'));assert.equal(launch.env.NODE_OPTIONS,undefined);
 assert(fs.lstatSync(path.join(launch.env.CODEX_HOME,'auth.json')).isSymbolicLink());assert.equal(fs.readlinkSync(path.join(launch.env.CODEX_HOME,'auth.json')),path.join(globalHome,'auth.json'));
 assert.equal(launch.cwd,path.join(f.p.state,'codex-workspace'));assert(!launch.cwd.startsWith(launch.root));assert.equal(launch.args.at(-1),'gpt-6-luna');
 writePrivate(path.join(launch.env.CODEX_HOME,'config.toml'),'[hooks.state.fixture]\nenabled = true\ntrusted_hash = "abc"\n');
 const second=prepareCodexLaunch(descriptor,'/descriptor',['--model','gpt-6-luna'],options);
 assert.equal(second.env.CODEX_HOME,launch.env.CODEX_HOME);assert.equal(second.cwd,launch.cwd);
 assert.deepEqual(fs.readdirSync(globalHome).map(name=>[name,hash(fs.readFileSync(path.join(globalHome,name)))]),globalBefore);
 // Native FileAuthStorage follows this shared reference when rotating tokens.
 fs.writeFileSync(path.join(launch.env.CODEX_HOME,'auth.json'),JSON.stringify({auth_mode:'chatgpt',tokens:{access_token:'ROTATED_SYNTHETIC'}}));
 assert.equal(JSON.parse(fs.readFileSync(path.join(globalHome,'auth.json'))).tokens.access_token,'ROTATED_SYNTHETIC');
 fs.writeFileSync(path.join(launch.cwd,'KEEP-USER-WORK'),'persistent user work');fs.rmSync(launch.root,{recursive:true,force:true});assert.equal(fs.readFileSync(path.join(launch.cwd,'KEEP-USER-WORK'),'utf8'),'persistent user work');
 for(const args of [['resume'],['exec','prompt'],['--config','hooks.Stop=[]'],['--cd','/project']])assert.throws(()=>prepareCodexLaunch(descriptor,'/descriptor',args,options));
 assert.throws(()=>prepareCodexLaunch(descriptor,'/descriptor',[],{...options,systemFiles:[path.join(globalHome,'config.toml')]}),/managed_config/);
 writePrivate(path.join(second.env.CODEX_HOME,'hooks.json'),'{}');assert.throws(()=>prepareCodexLaunch(descriptor,'/descriptor',[],options),/profile_config/);
});
