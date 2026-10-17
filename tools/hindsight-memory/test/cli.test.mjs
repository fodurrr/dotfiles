import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const source=fileURLToPath(new URL('..',import.meta.url));
function home(t){const h=fs.mkdtempSync(path.join(os.tmpdir(),'memory-cli-'));fs.chmodSync(h,0o700);t.after(()=>fs.rmSync(h,{recursive:true,force:true}));return h;}
function run(h,args,input,root=source){const child=spawnSync(process.execPath,['--disable-warning=ExperimentalWarning',path.join(root,'src/cli.mjs'),...args],{env:{...process.env,HOME:h,XDG_CONFIG_HOME:path.join(h,'.config'),XDG_STATE_HOME:path.join(h,'.local/state'),XDG_DATA_HOME:path.join(h,'.local/share')},input:input?JSON.stringify(input):undefined,encoding:'utf8',cwd:h});return {...child,data:JSON.parse(child.stdout)};}
test('prepare is checkout-independent, inactive, private, and idempotent with shared0755 bin',t=>{
 const h=home(t);const root=path.join(h,'source');fs.cpSync(source,root,{recursive:true});const bin=path.join(h,'.local/bin');fs.mkdirSync(bin,{recursive:true,mode:0o755});fs.chmodSync(bin,0o755);
 assert.equal(run(h,['prepare'],null,root).status,0);assert.equal(run(h,['prepare'],null,root).data.status,'activation-pending');
 fs.rmSync(root,{recursive:true});const launcher=path.join(bin,'hindsight-memory');const status=spawnSync(launcher,['status'],{env:{...process.env,HOME:h,XDG_CONFIG_HOME:path.join(h,'.config'),XDG_STATE_HOME:path.join(h,'.local/state'),XDG_DATA_HOME:path.join(h,'.local/share')},cwd:'/',encoding:'utf8'});
 assert.equal(status.status,0,status.stdout+status.stderr);assert.equal(JSON.parse(status.stdout).active,false);assert.equal(fs.statSync(bin).mode&0o777,0o755);assert.equal(fs.existsSync(path.join(h,'.claude')),false);assert.equal(fs.existsSync(path.join(h,'.local/state/hindsight-memory')),false);
});
test('prepare refuses group-writable launcher dir without chmod',t=>{
 const h=home(t);fs.mkdirSync(path.join(h,'.local'),{mode:0o700});const bin=path.join(h,'.local/bin');fs.mkdirSync(bin,{recursive:true,mode:0o775});fs.chmodSync(bin,0o775);const result=run(h,['prepare']);assert.equal(result.status,1);assert.equal(result.data.reason,'unsafe-launcher-directory');assert.equal(fs.statSync(bin).mode&0o777,0o775);
});
test('prepare refuses unowned launcher without overwrite',t=>{
 const h=home(t);const bin=path.join(h,'.local/bin');fs.mkdirSync(bin,{recursive:true,mode:0o700});const launcher=path.join(bin,'hindsight-memory');fs.writeFileSync(launcher,'user content',{mode:0o700});assert.equal(run(h,['prepare']).status,1);assert.equal(fs.readFileSync(launcher,'utf8'),'user content');
});
test('interrupted launcher/record upgrade is resumed from private intent',t=>{
 const h=home(t);const root=path.join(h,'source');fs.cpSync(source,root,{recursive:true});assert.equal(run(h,['prepare'],null,root).status,0);
 const pkg=path.join(root,'package.json');const value=JSON.parse(fs.readFileSync(pkg));value.version='0.1.1';fs.writeFileSync(pkg,JSON.stringify(value));
 const script=`import fs from 'node:fs';const original=fs.renameSync;fs.renameSync=function(a,b){if(String(b).endsWith('/installation.json'))throw Error('injected');return original(a,b)};const {main}=await import(${JSON.stringify(new URL('file://'+path.join(root,'src/cli.mjs')).href)});await main('prepare');`;
 const failed=spawnSync(process.execPath,['--input-type=module','-e',script],{env:{...process.env,HOME:h,XDG_CONFIG_HOME:path.join(h,'.config'),XDG_STATE_HOME:path.join(h,'.local/state'),XDG_DATA_HOME:path.join(h,'.local/share')},encoding:'utf8'});assert.notEqual(failed.status,0);
 assert.equal(run(h,['prepare'],null,root).status,0);const record=JSON.parse(fs.readFileSync(path.join(h,'.local/share/hindsight-memory/installation.json')));assert.equal(record.version,'0.1.1');assert.equal(fs.existsSync(path.join(h,'.local/share/hindsight-memory/prepare-intent.json')),false);
});
test('status is read-only and invalid configure never writes secret input to output',t=>{
 const h=home(t);const absent=run(h,['status']);assert.equal(absent.data.status,'missing');assert.equal(fs.existsSync(path.join(h,'.config')),false);
 const invalid=run(h,['configure'],{schema_version:1,endpoint:'https://SECRET@example.com',bank:'synthetic'});assert.equal(invalid.status,1);assert.ok(!invalid.stdout.includes('SECRET'));assert.equal(fs.existsSync(path.join(h,'.config')),false);
});
test('real installer preparation layer validates actual component output in temporary home',t=>{
 const h=home(t);const root=path.resolve(source,'../..');const script=`source "$DOTFILES_DIR/scripts/lib/memory.sh"
source "$DOTFILES_DIR/scripts/install/layer_memory.sh"
main_fixture_selected=true
memory_selection_requested(){ return 0; }
mise(){ if [[ "$1" == which && "$2" == node ]]; then printf '%s\\n' "$MEMORY_FIXTURE_NODE"; else return 1; fi; }
record_install_failure(){ printf 'fixture preparation failed\\n' >&2; }
add_to_summary(){ :; }
log_info(){ :; }
run_layer_memory
`;
 const env={...process.env,HOME:h,XDG_CONFIG_HOME:path.join(h,'.config'),XDG_STATE_HOME:path.join(h,'.local/state'),XDG_DATA_HOME:path.join(h,'.local/share'),DOTFILES_DIR:root,MEMORY_FIXTURE_NODE:process.execPath};
 const result=spawnSync('/bin/bash',['-c',script],{env,encoding:'utf8'});assert.equal(result.status,0,result.stdout+result.stderr);const launcher=path.join(h,'.local/bin/hindsight-memory');const status=spawnSync(launcher,['status'],{env,encoding:'utf8'});assert.equal(status.status,0,status.stdout+status.stderr);assert.equal(JSON.parse(status.stdout).status,'activation-pending');assert.equal(fs.existsSync(path.join(h,'.codex')),false);assert.equal(fs.existsSync(path.join(h,'.local/state/hindsight-memory')),false);
});
