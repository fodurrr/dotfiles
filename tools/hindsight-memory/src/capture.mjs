import { hash, fail, redact } from './config.mjs';
import { LIMITS } from './state.mjs';
export function envelope(input) {
  if (input?.schema_version !== 1 || !/^[a-z0-9-]{1,40}$/.test(input.agent || '') || typeof input.session !== 'string' || !input.session || input.session.length>256 || typeof input.owner !== 'string' || !input.owner || input.owner.length>256) fail('invalid-event');
}
export function normalize(messages) {
  if (!Array.isArray(messages) || messages.length > 10000) fail('invalid-messages');
  const ids = new Set();
  return messages.map(m => {
    if (typeof m?.id !== 'string' || !m.id || m.id.length > 256 || ids.has(m.id) || !['user','assistant'].includes(m.role) || typeof m.text !== 'string' || m.completed !== true || m.source === 'recall' || m.injected === true || Buffer.byteLength(m.text)>8*1024*1024) fail('ineligible-message');
    ids.add(m.id);
    return {id:m.id,role:m.role,text:redact(m.text),completed:true};
  });
}
// UUID-shaped stable operation ids meet the server's client-supplied UUID contract.
function uuid(seed) { const x=hash(seed); return `${x.slice(0,8)}-${x.slice(8,12)}-5${x.slice(13,16)}-a${x.slice(17,20)}-${x.slice(20,32)}`; }
function chunks(text, size = 24000) {
  const result=[]; let chunk=''; let bytes=0;
  for (const char of text) { const n=Buffer.byteLength(char); if (bytes+n>size) {result.push(chunk);chunk='';bytes=0;} chunk+=char;bytes+=n; }
  if (chunk || !result.length) result.push(chunk); return result;
}
export function makeJobs(input, host) {
  return (activation,messages,now) => messages.flatMap(m => chunks(m.text).map((text,index) => {
    const identity=JSON.stringify([activation.destination,host,activation.id,input.agent,input.session,m.id,index]);
    const id=uuid(identity);
    const body=JSON.stringify({async:true,operation_id:id,items:[{content:`${m.role}: ${text}`,document_id:`personal-${hash(identity)}`,timestamp:new Date(now).toISOString(),metadata:{host,agent:input.agent,session:input.session,message:m.id,role:m.role,activation:activation.id,chunk:String(index),source:'new-conversation'}}]});
    const bytes=Buffer.byteLength(body); if(bytes>LIMITS.job) fail('job-too-large');
    return {id,body,bytes};
  }));
}
export function register(store,input) { envelope(input); return store.register(input,normalize(input.baseline || input.messages || [])); }
export function capture(store,input,{transcript=false,now=Date.now(),beforeCommit,host='local',inside=false}={}) {
  envelope(input); return store.admit(input,normalize(input.messages),{transcript,now,beforeCommit,makeJobs:makeJobs(input,host),inside});
}

function turnEnvelope(input) {envelope(input);if(typeof input.turn_id!=='string' || !input.turn_id || input.turn_id.length>200)fail('invalid-turn-id');}
export function stageTurn(store,input,now=Date.now()) {
 turnEnvelope(input);if(typeof input.prompt!=='string' || Buffer.byteLength(input.prompt)>1024*1024)fail('invalid-prompt');
 const prompt=redact(input.prompt);store.capacity(Buffer.byteLength(prompt));
 return store.transaction(()=>{
  const row=store.getSession(input);const prior=store.db.prepare('SELECT * FROM staged WHERE session_key=?').get(row.key);
  if(prior){if(prior.turn_id===input.turn_id && prior.prompt===prompt)return {status:'staged',accepted:0};fail('pending-turn-conflict');}
  const used=store.db.prepare('SELECT count(*) n,coalesce(sum(length(CAST(prompt AS BLOB))),0) bytes FROM staged').get();
  if(used.n>=1000 || used.bytes+Buffer.byteLength(prompt)>64*1024*1024)fail('staging-capacity');
  store.db.prepare('INSERT INTO staged VALUES(?,?,?,?)').run(row.key,input.turn_id,prompt,now);return {status:'staged',accepted:0};
 });
}
export function completeTurn(store,input,{now=Date.now(),host='local'}={}) {
 turnEnvelope(input);if(typeof input.text!=='string' || Buffer.byteLength(input.text)>8*1024*1024)fail('invalid-assistant-text');
 return store.transaction(()=>{
  const row=store.getSession(input);const staged=store.db.prepare('SELECT * FROM staged WHERE session_key=? AND turn_id=?').get(row.key,input.turn_id);
  if(!staged) {
   const already=store.db.prepare('SELECT id FROM messages WHERE session_key=? AND id=?').get(row.key,input.turn_id+':assistant');
   if(already)return {status:'duplicate',accepted:0};fail('turn-not-staged');
  }
  const result=capture(store,{...input,previous:row.cursor,messages:[{id:input.turn_id+':user',role:'user',text:staged.prompt,completed:true},{id:input.turn_id+':assistant',role:'assistant',text:input.text,completed:true}]},{inside:true,now,host});
  store.db.prepare('DELETE FROM staged WHERE session_key=?').run(row.key);return result;
 });
}
export function abortTurn(store,input) {
 turnEnvelope(input);return store.transaction(()=>{const row=store.getSession(input);const result=store.db.prepare('DELETE FROM staged WHERE session_key=? AND turn_id=?').run(row.key,input.turn_id);return {status:'aborted',removed:Number(result.changes),accepted:0};});
}
