import fs from 'node:fs';
import path from 'node:path';
import {DatabaseSync} from 'node:sqlite';
import {hash,fail,privateDir,readPrivate,writePrivate} from './config.mjs';

function safeParent(file) {
  if(!path.isAbsolute(file)) fail('invalid-artifact-path');
  let dir=path.dirname(file);
  while(!fs.existsSync(dir)) dir=path.dirname(dir);
  for(let p=dir;p!==path.dirname(p);p=path.dirname(p)) {
    const s=fs.lstatSync(p);if(s.isSymbolicLink() || !s.isDirectory() || ((s.mode & 0o022) && !(s.uid===0 && s.mode & 0o1000)) || (s.uid!==process.getuid?.() && s.uid!==0)) fail('unsafe-artifact-parent');
  }
}
function existing(file) {
  safeParent(file);if(!fs.existsSync(file))return null;
  const s=fs.lstatSync(file);if(!s.isFile() || s.isSymbolicLink() || s.nlink!==1 || s.uid!==process.getuid?.() || s.mode & 0o022 || s.size>1024*1024)fail('unsafe-artifact-file');
  return fs.readFileSync(file,'utf8');
}
export function atomicOwnedFile(file,text,mode=0o600) {
  safeParent(file);fs.mkdirSync(path.dirname(file),{recursive:true,mode:0o700});
  const tmp=`${file}.hindsight-${process.pid}.tmp`;const fd=fs.openSync(tmp,fs.constants.O_WRONLY|fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_NOFOLLOW,mode);
  try {fs.writeFileSync(fd,text);fs.fsyncSync(fd);}finally{fs.closeSync(fd);}
  fs.renameSync(tmp,file);const dir=fs.openSync(path.dirname(file),'r');try{fs.fsyncSync(dir);}finally{fs.closeSync(dir);}
}
function at(object,keys,create=false) {
  let current=object;
  for(const key of keys) {if(['__proto__','constructor','prototype'].includes(key))fail('invalid-patch-path');if(current[key]===undefined && create)current[key]={};if(!current[key] || typeof current[key]!=='object' || Array.isArray(current[key]))fail('config-shape-conflict');current=current[key];}
  return current;
}
export function withMutationLock(p,fn) {
  privateDir(p.config);const file=path.join(p.config,'mutation-lock.sqlite');
  if(!fs.existsSync(file)){try{const fd=fs.openSync(file,fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_WRONLY|fs.constants.O_NOFOLLOW,0o600);fs.closeSync(fd);}catch(error){if(error.code!=='EEXIST')throw error;}}
  readPrivate(file);const db=new DatabaseSync(file,{timeout:50});
  try{db.exec('BEGIN IMMEDIATE');try{const result=fn();db.exec('COMMIT');return result;}catch(error){try{db.exec('ROLLBACK');}catch{}throw error;}}finally{db.close();}
}
export function applyArtifacts(p,plans,{locked=false}={}) {
  if(!locked)return withMutationLock(p,()=>applyArtifacts(p,plans,{locked:true}));
  const recordFile=path.join(p.config,'ownership.json');privateDir(p.config);
  const old=fs.existsSync(recordFile)?JSON.parse(readPrivate(recordFile)):{schema_version:1,records:[]};
  if(old.schema_version!==1)fail('unsupported-ownership-schema');
  if(old.state==='applying')fail('partial-artifacts-need-manual-recovery');
  const records=old.records;
  // Preflight every edit, including a partial prior activation, before touching agent files.
  const mutations=new Map();
  for(const plan of plans) {
    for(const file of plan.files || []) {
      const before=existing(file.path);const owned=records.find(r=>r.path===file.path);
      if(before!==null && (!owned || hash(before)!==owned.after))fail('artifact-ownership-conflict');
      mutations.set(file.path,{path:file.path,text:file.content,before:before===null?null:hash(before),record:{kind:'file',path:file.path,after:hash(file.content),mode:file.mode || 0o600}});
    }
    for(const patch of plan.jsonPatches || []) {
      const pending=mutations.get(patch.path);const before=pending?.text ?? existing(patch.path);
      const owned=records.find(r=>r.path===patch.path);
      if(!pending && owned && before!==null && hash(before)!==owned.after)fail('intervening-config-edit');
      let object;try{object=before===null?{}:JSON.parse(before);}catch{fail('invalid-agent-config');}
      if(!pending && owned?.patches){
        for(const prior of owned.patches){const parent=at(object,prior.arrayPath.slice(0,-1));const key=prior.arrayPath.at(-1);if(!Array.isArray(parent[key]))fail('config-shape-conflict');parent[key]=parent[key].filter(value=>JSON.stringify(value)!==JSON.stringify(prior.value));}
      }
      const parent=at(object,patch.arrayPath.slice(0,-1),true);const key=patch.arrayPath.at(-1);if(['__proto__','constructor','prototype'].includes(key))fail('invalid-patch-path');const existingPath=owned?.patches?.find(prior=>JSON.stringify(prior.arrayPath)===JSON.stringify(patch.arrayPath));const existed=existingPath ? existingPath.existed : Object.hasOwn(parent,key);
      if(parent[key]===undefined)parent[key]=[];if(!Array.isArray(parent[key]))fail('config-shape-conflict');
      const serialized=JSON.stringify(patch.value);const duplicate=parent[key].some(v=>JSON.stringify(v)===serialized);
      if(duplicate && !owned && !pending)fail('unowned-hook-conflict');
      if(!duplicate)parent[key].push(patch.value);
      const text=JSON.stringify(object,null,2)+'\n';
      const priorPatches=pending?.record.patches || [];
      const patches=priorPatches.some(x=>JSON.stringify(x.value)===serialized && JSON.stringify(x.arrayPath)===JSON.stringify(patch.arrayPath))?priorPatches:[...priorPatches,{arrayPath:patch.arrayPath,value:patch.value,existed}];
      mutations.set(patch.path,{path:patch.path,text,before:pending ? pending.before : (before===null?null:hash(before)),record:{kind:'json',path:patch.path,after:hash(text),patches,created:owned?.created ?? before===null}});
    }
  }
  const merged=records.filter(r=>!mutations.has(r.path));for(const m of mutations.values())merged.push(m.record);
  // Journal intent first. Any interrupted write stays inactive and can be inspected/repaired explicitly.
  writePrivate(recordFile,JSON.stringify({schema_version:1,state:'applying',records:merged}));
  for(const m of mutations.values()){const current=existing(m.path);if((current===null?null:hash(current))!==m.before)fail('intervening-config-edit');atomicOwnedFile(m.path,m.text,m.record.mode);}
  writePrivate(recordFile,JSON.stringify({schema_version:1,state:'applied',records:merged}));
  return {status:'artifacts-prepared',files:mutations.size};
}
export function rollbackArtifacts(p,{locked=false}={}) {
  if(!locked)return withMutationLock(p,()=>rollbackArtifacts(p,{locked:true}));
  const recordFile=path.join(p.config,'ownership.json');if(!fs.existsSync(recordFile))return {status:'no-owned-artifacts'};
  const ownership=JSON.parse(readPrivate(recordFile));if(ownership.schema_version!==1)fail('unsupported-ownership-schema');
  // No changes if any owned file has an intervening edit.
  for(const r of ownership.records) {const current=existing(r.path);if(current!==null && hash(current)!==r.after)fail('intervening-config-edit');}
  for(const r of [...ownership.records].reverse()) {
    const current=existing(r.path);if(current===null)continue;if(hash(current)!==r.after)fail('intervening-config-edit');
    if(r.kind==='file')fs.unlinkSync(r.path);
    else {
      const object=JSON.parse(current);
      for(const patch of [...r.patches].reverse()) {
        const parent=at(object,patch.arrayPath.slice(0,-1));const key=patch.arrayPath.at(-1);
        parent[key]=parent[key].filter(value=>JSON.stringify(value)!==JSON.stringify(patch.value));
        if(!patch.existed && !parent[key].length)delete parent[key];
      }
      // Keep unrelated configuration and empty containers; no secret-bearing backup copies.
      if(r.created && Object.keys(object).length===0)fs.unlinkSync(r.path);else atomicOwnedFile(r.path,JSON.stringify(object,null,2)+'\n');
    }
  }
  writePrivate(recordFile,JSON.stringify({schema_version:1,state:'rolled-back',records:[]}));return {status:'rolled-back'};
}
