import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fixture} from './helpers.mjs';
import {applyArtifacts,rollbackArtifacts} from '../src/ownership.mjs';

test('owned hooks preserve unrelated settings and rollback only owned values',t=>{
 const f=fixture(t);const file=path.join(f.home,'.agent/settings.json');fs.mkdirSync(path.dirname(file),{mode:0o700});
 fs.writeFileSync(file,JSON.stringify({auth:'untouched',hooks:{Stop:[{command:'existing'}]}}),{mode:0o600});
 const plan={files:[],jsonPatches:[{path:file,arrayPath:['hooks','Stop'],value:{command:'owned'}}]};
 applyArtifacts(f.p,[plan]);assert.equal(JSON.parse(fs.readFileSync(file)).hooks.Stop.length,2);
 applyArtifacts(f.p,[plan]);assert.equal(JSON.parse(fs.readFileSync(file)).hooks.Stop.length,2);
 rollbackArtifacts(f.p);assert.deepEqual(JSON.parse(fs.readFileSync(file)),{auth:'untouched',hooks:{Stop:[{command:'existing'}]}});
});
test('intervening config edits cause whole rollback refusal',t=>{
 const f=fixture(t);const file=path.join(f.home,'.agent/settings.json');const other=path.join(f.home,'.agent/plugin.mjs');
 applyArtifacts(f.p,[{files:[{path:other,content:'owned'}],jsonPatches:[{path:file,arrayPath:['hooks','Stop'],value:{command:'owned'}}]}]);
 fs.appendFileSync(file,' ');assert.throws(()=>rollbackArtifacts(f.p),/intervening/);assert.equal(fs.readFileSync(other,'utf8'),'owned');
});
test('unowned files and hooks are never adopted silently',t=>{
 const f=fixture(t);const file=path.join(f.home,'plugin');fs.writeFileSync(file,'user',{mode:0o600});
 assert.throws(()=>applyArtifacts(f.p,[{files:[{path:file,content:'owned'}]}]),/ownership/);assert.equal(fs.readFileSync(file,'utf8'),'user');
});
test('symlinked agent configuration and group writable parent are refused',t=>{
 const f=fixture(t);const file=path.join(f.home,'plugin');fs.symlinkSync(f.config.secret_file,file);
 assert.throws(()=>applyArtifacts(f.p,[{files:[{path:file,content:'owned'}]}]),/unsafe/);
 const writable=path.join(f.home,'writable');fs.mkdirSync(writable,{mode:0o700});fs.chmodSync(writable,0o777);
 assert.throws(()=>applyArtifacts(f.p,[{files:[{path:path.join(writable,'plugin'),content:'owned'}]}]),/unsafe/);
});
test('mutation lock excludes concurrent writers and releases after process death',async t=>{
 const {spawn}=await import('node:child_process');const {once}=await import('node:events');const {withMutationLock}=await import('../src/ownership.mjs');const f=fixture(t);
 const script=`import {withMutationLock} from ${JSON.stringify(new URL('../src/ownership.mjs',import.meta.url).href)};withMutationLock(${JSON.stringify(f.p)},()=>{process.send('locked');Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0)});`;
 const child=spawn(process.execPath,['--input-type=module','-e',script],{stdio:['ignore','ignore','ignore','ipc']});await once(child,'message');assert.throws(()=>withMutationLock(f.p,()=>{}),/locked/);const exited=once(child,'exit');child.kill('SIGKILL');await exited;assert.equal(withMutationLock(f.p,()=>true),true);
});
test('prototype patch keys are refused without agent writes',t=>{
 const f=fixture(t);const file=path.join(f.home,'settings.json');assert.throws(()=>applyArtifacts(f.p,[{jsonPatches:[{path:file,arrayPath:['__proto__'],value:{malicious:true}}]}]),/patch/);assert.equal(fs.existsSync(file),false);
});
test('release upgrade replaces owned hook instead of adding a second writer',t=>{
 const f=fixture(t);const file=path.join(f.home,'settings.json');fs.writeFileSync(file,JSON.stringify({hooks:{Stop:[{command:'user-owned'}]}}),{mode:0o600});
 const make=release=>({jsonPatches:['SessionStart','Stop'].map(event=>({path:file,arrayPath:['hooks',event],value:{command:release}}))});
 applyArtifacts(f.p,[make('release-A')]);applyArtifacts(f.p,[make('release-B')]);const updated=JSON.parse(fs.readFileSync(file));assert.deepEqual(updated.hooks.Stop,[{command:'user-owned'},{command:'release-B'}]);assert.deepEqual(updated.hooks.SessionStart,[{command:'release-B'}]);rollbackArtifacts(f.p);assert.deepEqual(JSON.parse(fs.readFileSync(file)),{hooks:{Stop:[{command:'user-owned'}]}});
});
