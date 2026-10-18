import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
import {randomUUID} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {paths,privateDir,readPrivate,writePrivate,loadConfig,destination} from '../src/config.mjs';
import {diagnostic,envelope,makeInvoker,readBounded,readPrivateJson,requireValue,safeParents} from './common.mjs';
import {inspectAgent} from '../src/qualification.mjs';

export const CODEX_VERSIONS=['0.163.0'];
export const CODEX_ELF_SHA256='399ff69c431c066e40de318fba45c2b07f45a76b19939d247ee4828fc70c4215';
export const CODEX_BINDING_ENV='HINDSIGHT_CODEX_BINDING';
const quote=value=>"'"+value.replaceAll("'","'\\''")+"'";

export function processIdentity(pid,root='/proc') {
  requireValue(Number.isInteger(pid) && pid>0,'invalid_caller_identity');
  const base=path.join(root,String(pid));
  const stat=fs.readFileSync(path.join(base,'stat'),'utf8');
  const rest=stat.slice(stat.lastIndexOf(')')+2).trim().split(/\s+/);
  const executable=fs.realpathSync(path.join(base,'exe'));const s=fs.statSync(path.join(base,'exe'));
  return {pid,ppid:Number(rest[1]),start:rest[19],executable,dev:s.dev,ino:s.ino};
}
export function verifyCaller(binding,descriptor,{observe=processIdentity,pid=process.ppid}={}) {
  requireValue(binding.schema_version===1 && !binding.revoked && binding.child,'codex_launch_required');
  const expected=descriptor.agent_identity;
  let current=pid;
  for(let depth=0;depth<3 && current>1;depth++) {
    const found=observe(current);
    if(found.pid===binding.child.pid) {
      requireValue(found.start===binding.child.start && found.executable===expected.path &&
        found.dev===expected.dev && found.ino===expected.ino,'unqualified_codex_caller');
      return;
    }
    // Native hooks use at most a shell between the helper and native process.
    requireValue(depth<2 && found.pid!==binding.launcher,'unqualified_codex_caller');
    current=found.ppid;
  }
  requireValue(false,'unqualified_codex_caller');
}
export function codexHookConfig(descriptor,descriptorPath) {
  const command=[descriptor.runtime,path.join(path.dirname(path.dirname(descriptor.cli)),'adapters/codex.mjs'),'hook',descriptorPath].map(quote).join(' ');
  return ['--config','features.hooks=true','--config','cli_auth_credentials_store="file"',...['SessionStart','UserPromptSubmit','Stop','Interrupt','SessionEnd','PreCompact'].flatMap(event=>[
    '--config',`hooks.${event}=[{hooks=[{type="command",command=${JSON.stringify(command)},timeout=${event==='UserPromptSubmit'?20:['Interrupt','SessionEnd'].includes(event)?3:10}}]}]`
  ])];
}
export function handleCodexHook(input,descriptor,binding,invoke=makeInvoker(descriptor),save=()=>{}) {
  requireValue(CODEX_VERSIONS.includes(descriptor.agentVersion),'unqualified_agent_version');
  requireValue(!input.agent_id && !input.agent_type,'subagent_route_unqualified');
  const base={...envelope('codex-cli',input.session_id,descriptor.owner),expected_destination:binding.destination};
  const event=input.hook_event_name;
  if(event==='SessionStart') {
    if(input.source!=='startup' || binding.session) {binding.revoked=true;save(binding);requireValue(false,'codex_fresh_session_required');}
    invoke('session',{...base,baseline:[],fresh:true});binding.session=input.session_id;save(binding);return {};
  }
  requireValue(binding.session===input.session_id && !binding.revoked,'codex_fresh_session_required');
  if(['SessionEnd','PreCompact'].includes(event)) {
    binding.revoked=true;save(binding);
    if(binding.pending)invoke('abort-turn',{...base,turn_id:binding.pending});
    return {};
  }
  requireValue(typeof input.turn_id==='string' && input.turn_id.length>0,'missing_prompt_identity');
  if(event==='Interrupt') {
    requireValue(binding.pending===input.turn_id,'unmatched_codex_turn');
    // Clear eligibility before admission; storage failures never restore it.
    binding.poisoned=input.turn_id;binding.pending=null;save(binding);
    invoke('abort-turn',{...base,turn_id:input.turn_id});return {};
  }
  if(event==='UserPromptSubmit') {
    requireValue(typeof input.prompt==='string' && input.prompt.length>0,'missing_prompt');
    requireValue(input.stop_hook_active!==true,'stop_continuation_unqualified');
    if(binding.pending || binding.poisoned===input.turn_id) {
      const pending=binding.pending;binding.poisoned=input.turn_id;binding.pending=null;save(binding);
      if(pending)invoke('abort-turn',{...base,turn_id:pending});
      requireValue(false,'codex_steering_unqualified');
    }
    binding.pending=input.turn_id;save(binding);
    try {invoke('stage-turn',{...base,turn_id:input.turn_id,prompt:input.prompt});}
    catch(error){binding.poisoned=input.turn_id;binding.pending=null;save(binding);try{invoke('abort-turn',{...base,turn_id:input.turn_id});}catch{}throw error;}
    const recalled=invoke('recall',{...base,turn_id:input.turn_id,query:input.prompt});
    return recalled.status==='recalled' && typeof recalled.context==='string'
      ? {hookSpecificOutput:{hookEventName:event,additionalContext:recalled.context}}:{};
  }
  requireValue(event==='Stop','unsupported_native_event');
  requireValue(input.stop_hook_active!==true,'stop_continuation_unqualified');
  requireValue(binding.pending===input.turn_id && binding.poisoned!==input.turn_id,'unmatched_codex_turn');
  requireValue(typeof input.last_assistant_message==='string' && input.last_assistant_message.length>0,'incomplete_turn_boundary');
  invoke('complete-turn',{...base,turn_id:input.turn_id,text:input.last_assistant_message});
  binding.pending=null;save(binding);return {};
}

// This is a deliberately narrow accepted TOML subset, not a general parser.
// Native trust changes may persist only hook state and workspace trust.
export function validateProfileConfig(text) {
  let section='root';
  for(const raw of text.split('\n')) {
    const line=raw.trim();if(!line || line.startsWith('#'))continue;
    if(/^\[hooks(?:\.state)?\]$/.test(line)){section='empty';continue;}
    if(/^\[hooks\.state\.(?:[A-Za-z0-9_-]+|"(?:[^"\\]|\\["\\])+")\]$/.test(line)){section='hook-state';continue;}
    if(/^\[projects\."(?:[^"\\]|\\["\\])+"\]$/.test(line)){section='project';continue;}
    if(line==='[tui]'){section='tui';continue;}
    const safe=section==='hook-state'?/^(?:enabled\s*=\s*(?:true|false)|trusted_hash\s*=\s*"[a-zA-Z0-9:_-]+")$/.test(line)
      :section==='project'?/^trust_level\s*=\s*"(?:trusted|untrusted)"$/.test(line)
      :section==='tui'?/^screen_reader_detection_done\s*=\s*(?:true|false)$/.test(line)
      :section==='root'?/^(?:model|model_reasoning_effort)\s*=\s*"[a-zA-Z0-9_.-]+"$/.test(line):false;
    requireValue(safe,'codex_profile_config_unqualified');
  }
}

export function prepareCodexLaunch(descriptor,descriptorPath,args=[],{env=process.env,terminal=process.stdin.isTTY===true && process.stdout.isTTY===true,inspectAgentImpl=inspectAgent,systemFiles=['/etc/codex/config.toml','/etc/codex/requirements.toml','/etc/codex/hooks.json']}={}) {
  requireValue(process.platform==='linux' && CODEX_VERSIONS.includes(descriptor.agentVersion),'unqualified_codex_process');
  requireValue(terminal,'codex_interactive_terminal_required');
  requireValue(args.length===0 || (args.length===2 && ['--model','-m'].includes(args[0]) && /^[a-zA-Z0-9_.-]{1,100}$/.test(args[1])),'codex_interactive_arguments_required');
  requireValue(!env[CODEX_BINDING_ENV],'nested_codex_memory_launch');
  requireValue(systemFiles.every(file=>!fs.existsSync(file)),'codex_managed_config_unqualified');
  const expected=descriptor.agent_identity;const actual=inspectAgentImpl(expected.requested);
  requireValue(actual.sha256===CODEX_ELF_SHA256 && Object.entries(actual).every(([key,value])=>expected[key]===value),'agent_changed_requalify');
  const p=paths(env);const config=loadConfig(p);
  requireValue(config.adapters.includes('codex-cli') && config.capture_owners?.['codex-cli']===descriptor.owner,'capture_owner_selection_required');
  const sourceHome=env.CODEX_HOME || path.join(p.home,'.codex');
  requireValue(path.isAbsolute(sourceHome),'absolute_path_required');safeParents(path.join(sourceHome,'auth.json'));
  const sourceAuth=path.resolve(sourceHome,'auth.json');const auth=readPrivate(sourceAuth);
  let parsed;try{parsed=JSON.parse(auth);}catch{requireValue(false,'invalid_codex_auth');}
  requireValue(parsed?.auth_mode==='chatgpt' && parsed.tokens && typeof parsed.tokens.access_token==='string','codex_chatgpt_auth_required');
  const root=path.join(p.state,'codex-launches',randomUUID());privateDir(root);
  try {
    const codexHome=path.join(p.state,'codex-profile');const cwd=path.join(p.state,'codex-workspace');privateDir(codexHome);privateDir(cwd);
    requireValue(['config.toml','hooks.json'].every(name=>!fs.existsSync(path.join(cwd,'.codex',name))),'codex_workspace_config_unqualified');
    requireValue(!fs.existsSync(path.join(codexHome,'hooks.json')) && !fs.existsSync(path.join(codexHome,'plugins')),'codex_profile_config_unqualified');
    const profileConfig=path.join(codexHome,'config.toml');
    if(fs.existsSync(profileConfig))validateProfileConfig(readPrivate(profileConfig));
    else writePrivate(profileConfig,'');
    const profileAuth=path.join(codexHome,'auth.json');
    if(!fs.existsSync(profileAuth) && !fs.lstatSync(profileAuth,{throwIfNoEntry:false}))fs.symlinkSync(sourceAuth,profileAuth);
    const link=fs.lstatSync(profileAuth);
    requireValue(link.isSymbolicLink() && link.uid===process.getuid?.() && fs.readlinkSync(profileAuth)===sourceAuth && fs.realpathSync(profileAuth)===sourceAuth,'codex_auth_reference_conflict');
    const bindingFile=path.join(root,'binding.json');
    const binding={schema_version:1,launcher:process.pid,destination:destination(config),session:null,pending:null,revoked:false};
    writePrivate(bindingFile,JSON.stringify(binding));
    const childEnv={...env,CODEX_HOME:codexHome,[CODEX_BINDING_ENV]:bindingFile};
    for(const key of ['NODE_OPTIONS','BUN_OPTIONS','LD_PRELOAD','LD_LIBRARY_PATH','CODEX_CONFIG','CODEX_CONFIG_PATH','CODEX_MANAGED_CONFIG_PATH'])delete childEnv[key];
    return {root,binding,bindingFile,executable:expected.path,args:[...codexHookConfig(descriptor,descriptorPath),...(args.length?args:['--model','gpt-6-luna'])],env:childEnv,cwd};
  }catch(error){fs.rmSync(root,{recursive:true,force:true});throw error;}
}
export async function launchCodex(descriptor,descriptorPath,args,options) {
  const launch=prepareCodexLaunch(descriptor,descriptorPath,args,options);
  try {
    const child=spawn(launch.executable,launch.args,{env:launch.env,cwd:launch.cwd,stdio:'inherit',shell:false});
    const done=new Promise(resolve=>{child.once('error',()=>resolve(1));child.once('exit',(code,signal)=>resolve(code??(signal==='SIGINT'?130:1)));});
    const forward=signal=>{try{child.kill(signal);}catch{}};
    const int=()=>forward('SIGINT');const term=()=>forward('SIGTERM');process.on('SIGINT',int);process.on('SIGTERM',term);
    try {
      if(child.pid){launch.binding.child=processIdentity(child.pid);writePrivate(launch.bindingFile,JSON.stringify(launch.binding));}
      return await done;
    } catch(error){forward('SIGKILL');await done;throw error;}
    finally{process.off('SIGINT',int);process.off('SIGTERM',term);}
  }finally{fs.rmSync(launch.root,{recursive:true,force:true});}
}
async function main() {
  const [mode,descriptorPath,...args]=process.argv.slice(2);
  requireValue(['launch','hook'].includes(mode),'invalid_adapter_arguments');
  const descriptor=readPrivateJson(descriptorPath);
  if(mode==='launch'){process.exitCode=await launchCodex(descriptor,descriptorPath,args);return;}
  requireValue(args.length===0,'invalid_adapter_arguments');
  const bindingFile=process.env[CODEX_BINDING_ENV];requireValue(typeof bindingFile==='string' && path.isAbsolute(bindingFile),'codex_launch_required');
  const binding=JSON.parse(readPrivate(bindingFile));verifyCaller(binding,descriptor);
  const input=JSON.parse(readBounded(0,1024*1024));
  const result=handleCodexHook(input,descriptor,binding,undefined,value=>writePrivate(bindingFile,JSON.stringify(value)));
  process.stdout.write(JSON.stringify(result));
}
if(process.argv[1] && path.resolve(process.argv[1])===fileURLToPath(import.meta.url))main().catch(error=>{diagnostic(error);process.exitCode=1;});
