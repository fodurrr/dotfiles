// Synthetic local admission only. No HTTP, actual host state, or provider calls.
import {performance} from 'node:perf_hooks';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {spawnSync} from 'node:child_process';
import {Store} from '../src/state.mjs';
import {paths,privateDir} from '../src/config.mjs';
import {register,capture} from '../src/capture.mjs';
const home=fs.mkdtempSync(path.join(os.tmpdir(),'hindsight-benchmark-'));fs.chmodSync(home,0o700);
const p=paths({HOME:home});privateDir(p.config);const secret=path.join(p.config,'secret');fs.writeFileSync(secret,'synthetic',{mode:0o600});
const config={schema_version:1,endpoint:'http://127.0.0.1:1',bank:'synthetic',secret_file:secret,adapters:['fixture'],agent_versions:{},capture:true};
const store=new Store(p);store.activate(config);const local=[];const whole=[];
try {
 for(let i=0;i<30;i++) {
  const event={schema_version:1,agent:'fixture',session:`local-${i}`,owner:'benchmark'};register(store,event);
  const start=performance.now();capture(store,{...event,previous:null,messages:[{id:'1',role:'user',text:'Synthetic measured turn. '.repeat(100),completed:true}]});local.push(performance.now()-start);
 }
 // Isolated protocol harness includes Node startup, Store open, validation, SQLite commit and exit.
 const script=`import {Store} from ${JSON.stringify(new URL('../src/state.mjs',import.meta.url).href)};import {register,capture} from ${JSON.stringify(new URL('../src/capture.mjs',import.meta.url).href)};const s=new Store(${JSON.stringify(p)});const e={schema_version:1,agent:'fixture',session:process.argv[1],owner:'benchmark'};register(s,e);capture(s,{...e,previous:null,messages:[{id:'1',role:'user',text:'Synthetic measured turn. '.repeat(100),completed:true}]});s.close();`;
 for(let i=0;i<30;i++){const start=performance.now();const result=spawnSync(process.execPath,['--disable-warning=ExperimentalWarning','--input-type=module','-e',script,`whole-${i}`],{stdio:'ignore'});if(result.status!==0)throw new Error('benchmark failed');whole.push(performance.now()-start);}
 const summary=values=>{values.sort((a,b)=>a-b);return {samples:values.length,p50_ms:+values[Math.floor(values.length*.5)].toFixed(3),p95_ms:+values[Math.floor(values.length*.95)].toFixed(3),max_ms:+values.at(-1).toFixed(3)};};
 console.log(JSON.stringify({node:process.version,platform:process.platform,admission:summary(local),whole_process:summary(whole),qualification:'synthetic Linux filesystem only; no GUI, macOS, slow-disk or network timing'},null,2));
}finally{store.close();fs.rmSync(home,{recursive:true,force:true});}
