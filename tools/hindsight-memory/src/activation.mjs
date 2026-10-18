import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {fileURLToPath} from 'node:url';
import {readPrivate,hash,fail} from './config.mjs';
import {inspectAgent,qualifyAgent} from './qualification.mjs';
import {adapterArtifacts} from '../adapters/manage.mjs';
import {PI_ELF_SHA256,PI_VERSIONS} from '../adapters/pi.mjs';

// Dependency injection is used only by harmless fixtures. CLI supplies the defaults.
export function activationPlans(p,config,{qualify=false,platform=process.platform,sourceDir=fileURLToPath(new URL('..',import.meta.url)),inspectAgentImpl=inspectAgent,qualifyAgentImpl=qualifyAgent}={}) {
  const installation=JSON.parse(readPrivate(path.join(p.data,'installation.json')));
  const solePi=config.adapters.length===1 && config.adapters[0]==='pi' && platform==='linux' && PI_VERSIONS.includes(config.agent_versions.pi);
  if(qualify && !solePi)fail('native-caller-binding-unqualified');
  const installedRelease=path.resolve(sourceDir)===fs.realpathSync(installation.release);
  if(qualify && !installedRelease)fail('use-installed-release-command');
  const plans=[];
  for(const adapter of config.adapters) {
    if(adapter.startsWith('opencode-') && fs.existsSync(path.join(p.configHome,'opencode/opencode.jsonc')))fail('opencode-jsonc-coexistence-unqualified');
    const descriptorPath=path.join(p.config,'adapters',`${adapter}.json`);
    const owner=hash(JSON.stringify([os.hostname(),config.endpoint,config.bank,adapter]));
    const plan=adapterArtifacts({adapter,version:config.agent_versions[adapter],runtime:installation.runtime.path,cli:path.join(installation.release,'src/cli.mjs'),releaseDir:installation.release,descriptorPath,owner,home:p.home,configHome:p.configHome});
    plan.descriptor.runtime_identity=installation.runtime;
    plan.activation_blocker='native-caller-binding-unqualified';
    if(adapter==='pi') {
      const selected=config.capture_owners?.pi || null;
      const selectionBlocker=!selected?'capture-owner-selection-required':selected!==owner?'capture-owner-selection-mismatch':null;
      plan.capture_owner=owner;
      plan.capture_owner_selection={required:true,selected,matches:selected===owner};
      plan.installed_writers_verified=false;
      const bridge=plan.files[0].path;
      plan.launch={executable:config.agent_commands.pi || null,args:['--no-extensions','-e',bridge],unset_environment:['NODE_OPTIONS','BUN_OPTIONS','LD_PRELOAD','LD_LIBRARY_PATH'],requires:'fresh-/new-TUI-consent'};
      if(solePi) {
        // Selection binds the generated writer to this host/destination. It never
        // claims that other installed writers were discovered or disabled.
        if(qualify && selectionBlocker)fail(selectionBlocker);
        let identity;
        try {identity=inspectAgentImpl(config.agent_commands.pi);} catch(error) {
          if(qualify)throw error;
          plan.activation_blocker=typeof error.code==='string'?error.code:'agent-command-inspection-failed';
        }
        if(identity) {
          if(identity.sha256!==PI_ELF_SHA256) {
            if(qualify)fail('native-caller-binding-unqualified');
          } else {
            if(qualify) {
              const probed=qualifyAgentImpl(config.agent_commands.pi,config.agent_versions.pi);
              if(JSON.stringify(probed)!==JSON.stringify({...identity,version:config.agent_versions.pi}))fail('agent-changed-during-qualification');
              plan.descriptor.agent_identity=probed;
            }
            plan.launch.executable=identity.path;
            plan.qualification='prepared-native-fixture-qualified';
            plan.activation_blocker=installedRelease?selectionBlocker:'use-installed-release-command';
          }
        }
      }
    }
    plan.files.push({path:descriptorPath,content:JSON.stringify(plan.descriptor),mode:0o600});
    plans.push(plan);
  }
  return plans;
}
