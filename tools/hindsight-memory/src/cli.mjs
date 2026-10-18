#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {fileURLToPath} from 'node:url';
import {spawn} from 'node:child_process';
import {performance} from 'node:perf_hooks';
import {paths,privateDir,privatePath,readPrivate,writePrivate,validateConfig,loadConfig,credential,qualifyRuntime,fail,hash,RECALL_DEADLINE_MS} from './config.mjs';
import {Store} from './state.mjs';
import {register,capture,envelope,stageTurn,completeTurn,abortTurn} from './capture.mjs';
import {atomicOwnedFile,applyArtifacts,rollbackArtifacts,withMutationLock} from './ownership.mjs';
import {worker,recall} from './delivery.mjs';
import {activationPlans} from './activation.mjs';

const source=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const p=paths();
function manifest() { return JSON.parse(fs.readFileSync(path.join(source,'package.json'),'utf8')); }
function quote(value) {return `'${value.replaceAll("'", "'\\''")}'`;}
function tree(root) {
  const entries=[];
  for(const name of fs.readdirSync(root).sort()) {
    if(['test','node_modules','experiments'].includes(name)) continue;
    const file=path.join(root,name);const stat=fs.lstatSync(file);
    if(stat.isSymbolicLink()) fail('symlink-source-artifact');
    if(stat.isDirectory()) for(const [child,bytes] of tree(file)) entries.push([`${name}/${child}`,bytes]);
    else if(stat.isFile()) entries.push([name,fs.readFileSync(file)]);
  }
  return entries;
}
function runtimeIdentity(runtime) { const s=fs.statSync(runtime);return {path:runtime,dev:s.dev,ino:s.ino,size:s.size,mtimeMs:s.mtimeMs}; }
function verifyInstalledRuntime() {
  const installed=path.join(p.data,'installation.json');
  if(!fs.existsSync(installed)) return;
  const record=JSON.parse(readPrivate(installed));
  if(record.runtime && JSON.stringify(runtimeIdentity(fs.realpathSync(process.execPath)))!==JSON.stringify(record.runtime)) fail('runtime-changed-requalify');
}
function prepareUnlocked() {
  const runtime=qualifyRuntime();const version=manifest().version;
  privateDir(p.data);
  if (!fs.existsSync(p.bin)) fs.mkdirSync(p.bin,{recursive:true,mode:0o700});
  const binStat=fs.lstatSync(p.bin);
  if (!binStat.isDirectory() || binStat.isSymbolicLink() || binStat.uid!==process.getuid?.() || (binStat.mode & 0o022)) fail('unsafe-launcher-directory');
  const artifacts=tree(source);
  const digest=hash(Buffer.concat(artifacts.map(([name,bytes])=>Buffer.concat([Buffer.from(name+'\0'),bytes]))));
  const release=path.join(p.data,'releases',`${version}-${digest.slice(0,16)}`);
  const launcher=path.join(p.bin,'hindsight-memory');
  const owned=path.join(p.data,'installation.json');
  const intentFile=path.join(p.data,'prepare-intent.json');
  if(fs.existsSync(intentFile)){
    const intent=JSON.parse(readPrivate(intentFile));
    if(intent.schema_version!==1 || intent.record?.launcher!==launcher || !intent.record.release?.startsWith(path.join(p.data,'releases')+path.sep))fail('invalid-prepare-intent');
    if(fs.existsSync(launcher) && hash(readPrivate(launcher))===intent.record.launcher_hash){writePrivate(owned,JSON.stringify(intent.record));fs.unlinkSync(intentFile);}
    else if(!fs.existsSync(launcher) || hash(readPrivate(launcher))===intent.before){fs.unlinkSync(intentFile);}
    else fail('launcher-ownership-conflict');
  }
  let previous;
  if(fs.existsSync(owned)) previous=JSON.parse(readPrivate(owned));
  if(fs.existsSync(launcher) && (!previous || hash(readPrivate(launcher))!==previous.launcher_hash)) fail('launcher-ownership-conflict');
  if(fs.existsSync(release)) {
    privatePath(release,true);
    for(const [name,bytes] of artifacts) if(hash(readPrivate(path.join(release,name)))!==hash(bytes)) fail('release-content-conflict');
  } else {
    const staging=release+'.staging-'+process.pid;privateDir(staging);
    for(const [name,bytes] of artifacts) { const target=path.join(staging,name);privateDir(path.dirname(target));writePrivate(target,bytes); }
    fs.renameSync(staging,release);
  }
  const cli=path.join(release,'src/cli.mjs');
  const wrapper=`#!/bin/sh\n# Owned by hindsight-memory; state and consent are separate.\nif [ ! -f ${quote(runtime)} ] || [ ! -x ${quote(runtime)} ]; then\n  printf '%s\\n' '{"schema_version":1,"status":"failed","reason":"runtime-missing-requalify"}' >&2\n  exit 1\nfi\nexec ${quote(runtime)} --disable-warning=ExperimentalWarning ${quote(cli)} "$@"\n`;
  const record={schema_version:1,version,digest,release,launcher,launcher_hash:hash(wrapper),runtime:runtimeIdentity(runtime)};
  writePrivate(intentFile,JSON.stringify({schema_version:1,before:previous?.launcher_hash || null,record}));
  atomicOwnedFile(launcher,wrapper,0o700);
  writePrivate(owned,JSON.stringify(record));fs.unlinkSync(intentFile);
  return {...status(),version};
}
export function prepare() {return withMutationLock(p,prepareUnlocked);}
function status({offset=0}={}) {
  const installed=fs.existsSync(path.join(p.data,'installation.json')); const configured=fs.existsSync(path.join(p.config,'config.json'));
  if(configured) loadConfig(p);
  let state={active:false,counts:{}};
  if(fs.existsSync(path.join(p.state,'state.sqlite'))) {const store=new Store(p,{readOnly:true});try {state=store.status(Date.now(),{offset});}finally {store.close();}}
  if(fs.existsSync(path.join(p.config,'ownership.json')) && JSON.parse(readPrivate(path.join(p.config,'ownership.json'))).state==='applying')return {...state,schema_version:1,status:'partial',installed,configured,consent_active:state.active,active:false,reason:'partial-artifacts-need-manual-recovery'};
  return {schema_version:1,capture_verified:false,status:state.active?'active':configured?'configured':installed?'activation-pending':'missing',installed,configured,...state};
}
async function input() {
  const chunks=[];let bytes=0;
  for await(const part of process.stdin) {bytes+=part.length;if(bytes>8*1024*1024) fail('input-too-large');chunks.push(part);}
  try {return JSON.parse(Buffer.concat(chunks).toString('utf8'));} catch {fail('invalid-input-json');}
}
function wake() {
  // Accepted admission survives wake failure. Worker has no transcript in argv or stdout.
  try {const child=spawn(process.execPath,['--disable-warning=ExperimentalWarning',fileURLToPath(import.meta.url),'worker'],{detached:true,stdio:'ignore',env:process.env});child.on('error',()=>{});child.unref();return 'requested';} catch {return 'failed';}
}
const activationPaths={...p,configHome:process.env.XDG_CONFIG_HOME || path.join(p.home,'.config')};
export async function main(command=process.argv[2],{wakeImpl=wake}={}) {
  qualifyRuntime();
  if(command==='prepare') return prepare();
  verifyInstalledRuntime();
  if(['status','inspect','doctor'].includes(command)) return status({offset:process.argv[3]===undefined?0:Number(process.argv[3])});
  if(command==='activation-preview'){const plans=activationPlans(activationPaths,loadConfig(p));return {status:'activation-pending',adapters:plans.map(plan=>({id:plan.id,version:plan.version,qualification:plan.qualification,files:plan.files.map(file=>file.path),json_files:plan.jsonPatches.map(patch=>patch.path),prerequisites:plan.prerequisites,activation_blocker:plan.activation_blocker,...(['pi','codex-cli'].includes(plan.id)?{capture_owner:plan.capture_owner,capture_owner_selection:plan.capture_owner_selection,installed_writers_verified:false,launch:plan.launch}:{})})),active:false};}
  if(command==='configure') {const value=await input();const config=validateConfig(value);return withMutationLock(p,()=>{credential(config);if(fs.existsSync(path.join(p.state,'state.sqlite'))){const current=new Store(p,{readOnly:true});try{if(current.status().active)fail('deactivate-before-configure');}finally{current.close();}}if(fs.existsSync(path.join(p.config,'config.json')) && fs.existsSync(path.join(p.config,'ownership.json'))){const old=loadConfig(p);if(JSON.stringify([...old.adapters].sort())!==JSON.stringify([...config.adapters].sort()) && JSON.parse(readPrivate(path.join(p.config,'ownership.json'))).records.length)fail('rollback-before-adapter-selection-change');}writePrivate(path.join(p.config,'config.json'),JSON.stringify(config));return {status:'configured',configured:true,active:false};});}
  const localStart=performance.now();
  const store=new Store(p);
  try {
    if(command==='activate')return withMutationLock(p,()=>{const config=loadConfig(p);credential(config);const existing=store.db.prepare('SELECT config FROM activations WHERE active=1').get();if(existing && existing.config!==JSON.stringify(config))fail('deactivate-before-config-change');const plans=activationPlans(activationPaths,config,{qualify:true});store.deactivate();applyArtifacts(p,plans,{locked:true});return {status:'active',active:true,generation:store.activate(config),capture_verified:false,qualification:plans.every(plan=>plan.qualification==='prepared-native-fixture-qualified')?'prepared-native-fixture-qualified':'scoped-native-candidate-qualified',installed_writers_verified:false};});
    if(command==='deactivate')return withMutationLock(p,()=>store.deactivate());
    if(command==='rollback')return withMutationLock(p,()=>{const suspended=store.deactivate();const result=rollbackArtifacts(p,{locked:true});return {...result,suspension:suspended};});
    if(command==='session') {const result=register(store,await input());return {...result,wake:wakeImpl()};}
    if(command==='session-status') {const value=await input();envelope(value);const row=store.getSession(value);return {status:'registered',previous:row.cursor,count:row.count};}
    if(['capture','capture-transcript'].includes(command)) {const started=localStart;const result=capture(store,await input(),{transcript:command==='capture-transcript',host:os.hostname()});return {...result,admission_ms:Number((performance.now()-started).toFixed(3)),wake:result.status==='queued'?wakeImpl():'unneeded'};}
    if(command==='stage-turn')return stageTurn(store,await input());
    if(command==='complete-turn'){const result=completeTurn(store,await input(),{host:os.hostname()});return {...result,wake:result.status==='queued'?wakeImpl():'unneeded'};}
    if(command==='abort-turn')return abortTurn(store,await input());
    if(command==='worker') return await worker(store,{budget:Math.max(1,60000-performance.now())});
    if(command==='recall'){const value=await input();return await recall(store,value,{budget:Math.max(1,Math.min(RECALL_DEADLINE_MS-performance.now(),typeof value.recall_deadline_utc_ms==='number'?value.recall_deadline_utc_ms-Date.now():RECALL_DEADLINE_MS))});}
    if(command==='retry') return {...store.recover(await input()),wake:wakeImpl()};
    fail('unknown-command');
  } finally {store.close();}
}
export function safeFailure(error){return {schema_version:1,status:'failed',reason:error.code==='ERR_SQLITE_ERROR' && [5,6].includes(error.errcode)?'state-busy-admission-not-confirmed':typeof error.code==='string' && /^[a-z][a-z0-9_-]{1,80}$/.test(error.code)?error.code.replaceAll('_','-'):'local-operation-failed'};}
if(process.argv[1] && path.resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  main().then(result=>process.stdout.write(JSON.stringify({schema_version:1,...result})+'\n')).catch(error=>{
    // Native errors can include URLs, paths, JSON and payloads. Never print them.
    process.stdout.write(JSON.stringify(safeFailure(error))+'\n');process.exitCode=1;
  });
}
