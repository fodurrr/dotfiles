import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fail,hash} from './config.mjs';
export function inspectAgent(command) {
 if(typeof command!=='string' || !path.isAbsolute(command))fail('explicit-agent-command-required');
 const executable=fs.realpathSync(command);const stat=fs.lstatSync(executable);
 if(!stat.isFile() || stat.mode & 0o022 || !(stat.mode & 0o111) || ![0,process.getuid?.()].includes(stat.uid))fail('unsafe-agent-command');
 for(let parent=path.dirname(executable);parent!==path.dirname(parent);parent=path.dirname(parent)){
  const s=fs.lstatSync(parent);if(s.isSymbolicLink() || !s.isDirectory() || ![0,process.getuid?.()].includes(s.uid) || ((s.mode & 0o022) && !(s.uid===0 && s.mode & 0o1000)))fail('unsafe-agent-command-parent');
 }
 return {requested:command,path:executable,dev:stat.dev,ino:stat.ino,size:stat.size,mtimeMs:stat.mtimeMs,sha256:hash(fs.readFileSync(executable))};
}
export function qualifyAgent(command,expectedVersion) {
 const identity=inspectAgent(command);
 // Only explicit activation probes the selected executable. Preview never executes it.
 const executable=identity.path;
 const result=spawnSync(executable,['--version'],{encoding:'utf8',timeout:5000,maxBuffer:16384,stdio:['ignore','pipe','pipe'],shell:false});
 const detected=result.status===0 && !result.error ? result.stdout.match(/\b(\d+\.\d+\.\d+)\b/)?.[1] : null;
 if(detected!==expectedVersion)fail('detected-agent-version-not-qualified');
 const after=inspectAgent(command);if(JSON.stringify(after)!==JSON.stringify(identity))fail('agent-changed-during-qualification');
 return {...identity,version:detected};
}
