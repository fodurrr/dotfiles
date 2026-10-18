// Harmless files, injected identities and core state only. Never execute Pi.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {activationPlans} from '../src/activation.mjs';
import {inspectAgent} from '../src/qualification.mjs';
import {paths,privateDir,writePrivate,validateConfig} from '../src/config.mjs';
import {Store} from '../src/state.mjs';
import {PI_ELF_SHA256} from '../adapters/pi.mjs';

const source=fileURLToPath(new URL('..',import.meta.url));
function fixture(t) {
  const home=fs.mkdtempSync(path.join(os.tmpdir(),'memory-activation-'));fs.chmodSync(home,0o700);
  t.after(()=>fs.rmSync(home,{recursive:true,force:true}));
  const p={...paths({HOME:home}),configHome:path.join(home,'.config')};
  privateDir(p.data);privateDir(p.config);const release=path.join(p.data,'releases','fixture');privateDir(release);
  writePrivate(path.join(p.data,'installation.json'),JSON.stringify({release,runtime:{path:process.execPath}}));
  const secret=path.join(p.config,'secret');writePrivate(secret,'synthetic-secret');
  const config=validateConfig({schema_version:1,endpoint:'https://memory.invalid',bank:'synthetic',secret_file:secret,adapters:['pi'],agent_versions:{pi:'1.3.0'},agent_commands:{pi:path.join(home,'pi')},capture:true});
  const identity={requested:config.agent_commands.pi,path:config.agent_commands.pi,dev:1,ino:2,size:100,mtimeMs:3,sha256:PI_ELF_SHA256};
  const options={sourceDir:release,platform:'linux',inspectAgentImpl:()=>({...identity}),qualifyAgentImpl:()=>({...identity,version:'1.3.0'})};
  const plan=(value=config,extra={})=>activationPlans(p,value,{...options,...extra})[0];
  return {home,p,release,config,identity,options,plan};
}
function run(home,command,input,root=source) {
  const env={...process.env,HOME:home,XDG_CONFIG_HOME:path.join(home,'.config'),XDG_DATA_HOME:path.join(home,'.local/share'),XDG_STATE_HOME:path.join(home,'.local/state')};
  const result=spawnSync(process.execPath,['--disable-warning=ExperimentalWarning',path.join(root,'src/cli.mjs'),command],{env,cwd:home,input:input?JSON.stringify(input):undefined,encoding:'utf8'});
  return {...result,data:JSON.parse(result.stdout)};
}
test('Pi preview exposes exact generated owner and sole launch without probing or writing',t=>{
  const f=fixture(t);let probes=0;
  const before=fs.readdirSync(f.p.config);const plan=f.plan(f.config,{qualifyAgentImpl:()=>{probes++;throw Error('must not execute');}});
  assert.equal(probes,0);assert.equal(plan.activation_blocker,'capture-owner-selection-required');
  assert.match(plan.capture_owner,/^[a-f0-9]{64}$/);assert.deepEqual(plan.capture_owner_selection,{required:true,selected:null,matches:false});
  assert.equal(plan.installed_writers_verified,false);assert.equal(plan.qualification,'prepared-native-fixture-qualified');
  assert.deepEqual(plan.launch.args,['--no-extensions','-e',path.join(f.home,'.pi/agent/extensions/hindsight-memory.js')]);
  assert.equal(plan.launch.executable,f.identity.path);assert.deepEqual(plan.launch.unset_environment,['NODE_OPTIONS','BUN_OPTIONS','LD_PRELOAD','LD_LIBRARY_PATH']);
  assert.equal(plan.descriptor.bridge_path,plan.launch.args[2]);
  assert.deepEqual(fs.readdirSync(f.p.config),before);assert.equal(fs.existsSync(path.join(f.home,'.pi')),false);
});
test('Pi activation planning needs exact owner selection and pinned executable',t=>{
  const f=fixture(t);let inspections=0;const inspect=()=>{inspections++;return f.identity;};
  assert.throws(()=>f.plan(f.config,{qualify:true,inspectAgentImpl:inspect}),/capture-owner-selection-required/);
  assert.throws(()=>f.plan({...f.config,capture_owners:{pi:'0'.repeat(64)}},{qualify:true,inspectAgentImpl:inspect}),/capture-owner-selection-mismatch/);
  assert.equal(inspections,0);
  const config={...f.config,capture_owners:{pi:f.plan().capture_owner}};
  const plan=f.plan(config,{qualify:true});
  assert.equal(plan.activation_blocker,null);assert.equal(plan.capture_owner_selection.matches,true);
  assert.deepEqual(plan.descriptor.agent_identity,{...f.identity,version:'1.3.0'});
  assert.deepEqual(JSON.parse(plan.files.at(-1).content),plan.descriptor);
  let probes=0;
  assert.throws(()=>f.plan(config,{qualify:true,inspectAgentImpl:()=>({...f.identity,sha256:'0'.repeat(64)}),qualifyAgentImpl:()=>{probes++;}}),/native-caller-binding-unqualified/);
  assert.equal(probes,0);
  assert.throws(()=>f.plan(config,{qualify:true,qualifyAgentImpl:()=>({...f.identity,ino:99,version:'1.3.0'})}),/agent-changed-during-qualification/);
});
test('owner selection is bound to the host destination and does not qualify another route',t=>{
  const f=fixture(t);const owner=f.plan().capture_owner;const config={...f.config,capture_owners:{pi:owner}};
  for(const changed of [{...config,bank:'different'},{...config,endpoint:'https://different.invalid'}])assert.throws(()=>f.plan(changed,{qualify:true}),/capture-owner-selection-mismatch/);
  let inspected=0;const inspect=()=>{inspected++;throw Error('must not inspect');};
  for(const changed of [{...config,adapters:['codex-cli']},{...config,adapters:['pi','codex-cli']},{...config,agent_versions:{pi:'1.1.0'}},{...config,agent_versions:{pi:'1.3.1'}}])assert.throws(()=>f.plan(changed,{qualify:true,inspectAgentImpl:inspect}),/native-caller-binding-unqualified/);
  assert.throws(()=>f.plan(config,{qualify:true,platform:'darwin',inspectAgentImpl:inspect}),/native-caller-binding-unqualified/);
  assert.equal(inspected,0);
  assert.equal(f.plan(config,{platform:'darwin'}).activation_blocker,'native-caller-binding-unqualified');
});
test('activation must use the installed release instead of blessing older prepared code',t=>{
  const f=fixture(t);const config={...f.config,capture_owners:{pi:f.plan().capture_owner}};
  assert.throws(()=>f.plan(config,{qualify:true,sourceDir:source,inspectAgentImpl:()=>{throw Error('must not inspect');}}),/use-installed-release-command/);
  assert.equal(f.plan(config,{sourceDir:source}).activation_blocker,'use-installed-release-command');
});
test('capture owner selection survives config normalization and rejects malformed values',t=>{
  const f=fixture(t);const owner=f.plan().capture_owner;
  assert.deepEqual(validateConfig({...f.config,capture_owners:{pi:owner}}).capture_owners,{pi:owner});
  for(const value of [null,[],{pi:'wrong'},{pi:1},{other:owner}])assert.throws(()=>validateConfig({...f.config,capture_owners:value}),/invalid-capture-owner-selection/);
});
test('executable inspection and actual CLI preview never execute selected command',t=>{
  const f=fixture(t);const sentinel=path.join(f.home,'EXECUTED');
  fs.writeFileSync(f.config.agent_commands.pi,`#!/bin/sh\ntouch '${sentinel}'\nprintf '1.3.0\\n'\n`,{mode:0o700});
  assert.equal(inspectAgent(f.config.agent_commands.pi).path,f.config.agent_commands.pi);assert.equal(fs.existsSync(sentinel),false);
  assert.equal(run(f.home,'prepare').status,0);assert.equal(run(f.home,'configure',f.config).status,0);
  const before=fs.readdirSync(f.p.config);const preview=run(f.home,'activation-preview');
  assert.equal(preview.status,0,preview.stdout+preview.stderr);assert.equal(preview.data.adapters[0].activation_blocker,'native-caller-binding-unqualified');
  assert.equal(preview.data.adapters[0].installed_writers_verified,false);
  assert.equal(fs.existsSync(sentinel),false);assert.deepEqual(fs.readdirSync(f.p.config),before);assert.equal(fs.existsSync(f.p.state),false);
});
test('actual CLI owner and executable refusals preserve active consent and owned artifacts',t=>{
  const f=fixture(t);assert.equal(run(f.home,'prepare').status,0);
  const installation=JSON.parse(fs.readFileSync(path.join(f.p.data,'installation.json')));const release=installation.release;
  const sentinel=path.join(f.home,'EXECUTED');fs.writeFileSync(f.config.agent_commands.pi,`#!/bin/sh\ntouch '${sentinel}'\nprintf '1.3.0\\n'\n`,{mode:0o700});
  const preview=run(f.home,'configure',f.config);assert.equal(preview.status,0);
  const owner=run(f.home,'activation-preview').data.adapters[0].capture_owner;
  const artifact=path.join(f.home,'.pi/agent/extensions/hindsight-memory.js');privateDir(path.dirname(artifact));writePrivate(artifact,'UNRELATED_ARTIFACT');
  const ownership=path.join(f.p.config,'ownership.json');writePrivate(ownership,JSON.stringify({schema_version:1,state:'applied',records:[]}));
  for(const [capture_owners,reason] of [[undefined,'capture-owner-selection-required'],[{pi:'0'.repeat(64)},'capture-owner-selection-mismatch'],[{pi:owner},'native-caller-binding-unqualified']]) {
    const config=validateConfig({...f.config,...(capture_owners?{capture_owners}:{})});
    writePrivate(path.join(f.p.config,'config.json'),JSON.stringify(config));
    let store=new Store(f.p);store.deactivate();const generation=store.activate(config);store.close();
    const before=fs.readFileSync(ownership,'utf8');const failed=run(f.home,'activate',null,release);
    assert.equal(failed.status,1,failed.stdout+failed.stderr);assert.equal(failed.data.reason,reason);
    store=new Store(f.p,{readOnly:true});try{assert.equal(store.status().generation,generation);assert.equal(store.status().active,true);}finally{store.close();}
    assert.equal(fs.readFileSync(artifact,'utf8'),'UNRELATED_ARTIFACT');assert.equal(fs.readFileSync(ownership,'utf8'),before);assert.equal(fs.existsSync(sentinel),false);
  }
  const stale=run(f.home,'activate');assert.equal(stale.data.reason,'use-installed-release-command');assert.equal(fs.existsSync(sentinel),false);
});
test('Pi and scoped Codex can activate together with separate selected owners and pinned native identities',async t=>{
  const {CODEX_ELF_SHA256}=await import('../adapters/codex.mjs');
  const f=fixture(t);const command=path.join(f.home,'codex');
  const config={...f.config,adapters:['pi','codex-cli'],agent_versions:{pi:'1.3.0','codex-cli':'0.163.0'},agent_commands:{pi:f.config.agent_commands.pi,'codex-cli':command}};
  const identities={pi:f.identity,[command]:{requested:command,path:command,dev:1,ino:4,size:200,mtimeMs:5,sha256:CODEX_ELF_SHA256}};
  const options={...f.options,inspectAgentImpl:requested=>requested===f.config.agent_commands.pi?identities.pi:identities[requested],qualifyAgentImpl:(requested,version)=>({...((requested===f.config.agent_commands.pi)?identities.pi:identities[requested]),version})};
  const preview=activationPlans(f.p,config,options);assert.deepEqual(preview.map(p=>p.id),['pi','codex-cli']);
  assert.notEqual(preview[0].capture_owner,preview[1].capture_owner);
  const selected={...config,capture_owners:Object.fromEntries(preview.map(p=>[p.id,p.capture_owner]))};
  const plans=activationPlans(f.p,selected,{...options,qualify:true});
  assert(plans.every(p=>p.activation_blocker===null));assert.equal(plans[1].jsonPatches.length,0);
  assert.equal(plans[1].launch.executable,path.join(f.home,'.local/bin/codex-memory'));
  assert.equal(plans[1].qualification,'scoped-native-candidate-qualified');
  assert.equal(plans[1].descriptor.agent_identity.sha256,CODEX_ELF_SHA256);
  assert.deepEqual(validateConfig(selected).capture_owners,selected.capture_owners);
  assert.throws(()=>activationPlans(f.p,{...selected,capture_owners:{pi:plans[0].capture_owner,'codex-cli':plans[0].capture_owner}},{...options,qualify:true}),/selection-mismatch/);
});
