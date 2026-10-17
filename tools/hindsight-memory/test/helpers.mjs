import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {paths,privateDir,validateConfig} from '../src/config.mjs';
import {Store} from '../src/state.mjs';
export function fixture(t,limits={}, {temporaryRoot=os.tmpdir()}={}) {
  const home=fs.mkdtempSync(path.join(temporaryRoot,'hindsight-fixture-'));fs.chmodSync(home,0o700);
  const p=paths({HOME:home});privateDir(p.config);const secret=path.join(p.config,'secret');fs.writeFileSync(secret,'synthetic-secret',{mode:0o600});
  const config=validateConfig({schema_version:1,endpoint:'http://127.0.0.1:1',bank:'synthetic',secret_file:secret,adapters:['fixture'],capture:true});
  const store=new Store(p,{limits});store.activate(config,1000);
  const event={schema_version:1,agent:'fixture',session:'session-1',owner:'single-writer'};
  t.after(()=>{try{store.close();}catch{}fs.rmSync(home,{recursive:true,force:true});});return {home,p,config,store,event};
}
export const message=(id,text='new synthetic conversation',role='user')=>({id,text,role,completed:true});
