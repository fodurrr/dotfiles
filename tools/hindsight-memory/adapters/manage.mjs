import { join, isAbsolute } from 'node:path';
import { pathToFileURL } from 'node:url';
import { requireValue } from './common.mjs';
import { HOOK_VERSIONS } from './hook.mjs';
import { PI_VERSIONS } from './pi.mjs';

export const ADAPTER_VERSIONS = Object.freeze({
  ...HOOK_VERSIONS, pi: PI_VERSIONS,
  'opencode-v1': ['1.18.35'], 'opencode-v2': ['2.0.32'],
});

export const BLOCKED_ADAPTERS = Object.freeze({
  gemini: 'AfterAgent receives finalRequest rather than a proven original prompt; recording synthetic user records lack origin markers. Native stable turn identity is unqualified.',
  grok: 'Installed 1.0.62 prompt hooks discard allowing stdout, so they cannot inject automatic recall; camelCase source/provenance and clipped final-text compatibility still need qualification.',
  hermes: 'Provider callbacks run through an in-memory background executor before durable admission; no proven synchronous native completion or new-only recovery interface.',
  'codex-desktop': 'Desktop hook trust, runtime path and native provider route require independent qualification.',
  'chatgpt-desktop': 'No qualified native conversation lifecycle capture interface; tools access does not establish automatic capture.',
  'claude-desktop': 'Claude Code sessions and ordinary Claude Desktop chats have different routes; no qualification for ordinary chat lifecycle capture.',
  t3: 'Execution provider and exclusive capture owner require a separately qualified route; no duplicate provider capture.',
  zed: 'Actual provider route and native lifecycle capture ownership remain unqualified.',
});

export function adapterArtifacts({ adapter, version, runtime, cli, releaseDir, descriptorPath, owner, home, configHome = join(home, '.config') }) {
  requireValue(ADAPTER_VERSIONS[adapter]?.includes(version), 'unqualified_agent_version');
  for (const path of [runtime, cli, releaseDir, descriptorPath, home, configHome]) requireValue(typeof path === 'string' && isAbsolute(path), 'absolute_path_required');
  requireValue(typeof owner === 'string' && owner.length > 0, 'invalid_capture_owner');
  const files = [];
  const jsonPatches = [];
  const moduleUrl = name => pathToFileURL(join(releaseDir, 'adapters', name)).href;
  // Native hook commands are shell strings. Quote every path individually;
  // descriptor contents and user prompts never enter the command string.
  const quote = value => "'" + value.replaceAll("'", "'\\''") + "'";
  if (HOOK_VERSIONS[adapter]) {
    const path = adapter === 'claude-code' ? join(home, '.claude', 'settings.json') : join(home, '.codex', 'hooks.json');
    const command = [runtime, join(releaseDir, 'adapters', 'hook.mjs'), adapter, descriptorPath].map(quote).join(' ');
    for (const event of ['SessionStart', 'UserPromptSubmit', 'Stop', ...(adapter === 'claude-code' ? ['StopFailure'] : [])]) {
      const value = { hooks: [{ type: 'command', command, timeout: 10 }] };
      if (event === 'SessionStart') value.matcher = 'startup|resume|clear|fork|compact';
      jsonPatches.push({ path, arrayPath: ['hooks', event], value });
    }
  } else if (adapter === 'pi') {
    files.push({ path: join(home, '.pi', 'agent', 'extensions', 'hindsight-memory.js'), mode: 0o600,
      content: `import { piFromDescriptor } from ${JSON.stringify(moduleUrl('pi.mjs'))};\nexport default piFromDescriptor(${JSON.stringify(descriptorPath)}, import.meta.url);\n` });
  } else {
    const v2 = adapter === 'opencode-v2';
    const name = v2 ? 'openCodeV2FromDescriptor' : 'openCodeV1FromDescriptor';
    if(v2){
      const directory=join(configHome,'hindsight-memory','adapters',adapter);
      files.push({path:join(directory,'package.json'),mode:0o600,content:JSON.stringify({name:'hindsight-memory-opencode-v2',private:true,type:'module'})+'\n'});
      files.push({path:join(directory,'server.js'),mode:0o600,content:`import { ${name} } from ${JSON.stringify(moduleUrl('opencode-v2.mjs'))};\nexport default ${name}(${JSON.stringify(descriptorPath)});\n`});
      jsonPatches.push({path:join(configHome,'opencode','opencode.json'),arrayPath:['plugins'],value:pathToFileURL(directory).href});
    }else{
      const path = join(configHome, 'hindsight-memory', 'adapters', `${adapter}.mjs`);
      files.push({ path, mode: 0o600, content: `import { ${name} } from ${JSON.stringify(moduleUrl('opencode-v1.mjs'))};\nexport default ${name}(${JSON.stringify(descriptorPath)});\n` });
      jsonPatches.push({ path: join(configHome, 'opencode', 'opencode.json'), arrayPath: ['plugin'], value: pathToFileURL(path).href });
    }
  }
  return { id: adapter, version, qualification: 'source-and-fixture-qualified',
    files, jsonPatches, prerequisites: ['explicit-activation', 'native-trust', 'fresh-or-explicitly-enrolled-session', 'exclusive-capture-owner'],
    descriptor: { schema_version: 1, runtime, cli, owner, agentVersion: version, ...(adapter==='pi'?{bridge_path:files[0].path}:{}) } };
}
