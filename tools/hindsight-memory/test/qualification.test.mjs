import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fixture} from './helpers.mjs';
import {qualifyAgent} from '../src/qualification.mjs';
import {makeInvoker} from '../adapters/common.mjs';

test('activation probes explicit executable version, not a declared string',t=>{
 const f=fixture(t);const agent=path.join(f.home,'agent');fs.writeFileSync(agent,"#!/bin/sh\nprintf '2.1.302 (synthetic)\\n'\n",{mode:0o700});
 assert.equal(qualifyAgent(agent,'2.1.302').version,'2.1.302');assert.throws(()=>qualifyAgent(agent,'9.9.9'),/version/);assert.throws(()=>qualifyAgent('agent','2.1.302'),/explicit/);
});
test('native bridge rejects changed executable and retargeted alias before spawning core',t=>{
 const f=fixture(t);const a=path.join(f.home,'a');const b=path.join(f.home,'b');const alias=path.join(f.home,'agent');for(const name of [a,b])fs.writeFileSync(name,"#!/bin/sh\nprintf '2.1.302 (synthetic)\\n'\n",{mode:0o700});fs.symlinkSync(a,alias);
 const identity=qualifyAgent(alias,'2.1.302');let called=false;const descriptor={schema_version:1,runtime:process.execPath,cli:'/fixture/cli',owner:'fixture',agent_identity:identity};const invoke=makeInvoker(descriptor,()=>{called=true;return {status:0,stdout:'{"schema_version":1,"status":"registered"}'};});
 fs.unlinkSync(alias);fs.symlinkSync(b,alias);assert.throws(()=>invoke('session',{}),/requalify/);assert.equal(called,false);
 fs.unlinkSync(alias);fs.symlinkSync(a,alias);fs.appendFileSync(a,'# changed');assert.throws(()=>invoke('session',{}),/requalify/);assert.equal(called,false);
});
test('OpenCode v2 artifact is a package directory with server entry, never a single configured file',async t=>{
 const {adapterArtifacts}=await import('../adapters/manage.mjs');const plan=adapterArtifacts({adapter:'opencode-v2',version:'2.0.32',runtime:'/node',cli:'/release/src/cli.mjs',releaseDir:'/release',descriptorPath:'/private/descriptor',owner:'fixture',home:'/synthetic'});
 assert.ok(plan.files.some(f=>f.path.endsWith('/opencode-v2/server.js')));assert.ok(plan.files.some(f=>f.path.endsWith('/opencode-v2/package.json')));assert.ok(plan.jsonPatches[0].value.endsWith('/opencode-v2'));assert.ok(!plan.jsonPatches[0].value.endsWith('.mjs'));
});
