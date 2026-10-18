import { createServer } from 'node:http';
import { LIMIT, TEXT, demand } from './policy.mjs';
export async function fixtureServices() {
  const evidence = { provider: [], recalls: [], retains: [], completed: [], profile: 0, health: 0 };
  let failure = null; let requests = 0;
  const fail = reason => { failure ??= reason; };
  const operations = new Map();
  const listen = async handler => {
    const server = createServer(async (req, res) => {
      try {
        demand(++requests <= LIMIT.requests, 'fake-request-limit');
        if (req.method === 'GET' && req.url === '/health') { evidence.health++; res.end('{"healthy":true}'); return; }
        let bytes = 0; const chunks = [];
        for await (const chunk of req) { bytes += chunk.length; demand(bytes <= LIMIT.body, 'fake-body-limit'); chunks.push(chunk); }
        await handler(req, res, Buffer.concat(chunks).toString('utf8'));
      } catch (error) { fail(error.message); res.writeHead(400); res.end('{"error":"fixture-refused"}'); }
    });
    server.requestTimeout = 3000; server.headersTimeout = 3000; server.maxConnections = 4;
    await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
    return server;
  };
  const provider = await listen(async (req, res, body) => {
    demand(req.method === 'POST' && req.url === '/v1/chat/completions' && req.headers.authorization === 'Bearer fixture-only', 'unexpected-provider-request');
    const value = JSON.parse(body); const text = JSON.stringify(value.messages);
    demand(value.model === 'fixture' && value.stream === true && value.tools === undefined && evidence.provider.length < 2, 'unexpected-provider-body');
    const first = evidence.provider.length === 0;
    demand(first ? text.includes(TEXT.history) && !text.includes(TEXT.recall) :
      text.includes(TEXT.prompt) && text.includes(TEXT.recall) && !text.includes(TEXT.history) && !text.includes(TEXT.historyAnswer), 'provider-context-mismatch');
    evidence.provider.push({ text, model: value.model });
    const answer = first ? TEXT.historyAnswer : TEXT.final;
    res.writeHead(200, { 'content-type': 'text/event-stream; charset=utf-8', 'cache-control': 'no-cache' });
    const chunk = (delta, finish_reason) => ({ id: `fixture-${evidence.provider.length}`, object: 'chat.completion.chunk', created: 1, model: 'fixture',
      choices: [{ index: 0, delta, finish_reason }] });
    res.write(`data: ${JSON.stringify(chunk({ role: 'assistant' }, null))}\n\n`);
    res.write(`data: ${JSON.stringify(chunk({ content: answer }, null))}\n\n`);
    res.write(`data: ${JSON.stringify(chunk({}, 'stop'))}\n\n`);
    res.write(`data: ${JSON.stringify({ ...chunk({}, null), choices: [], usage: { prompt_tokens: 1, completion_tokens: 1, total_tokens: 2 } })}\n\n`);
    res.end('data: [DONE]\n\n');
  });
  let memory;
  try {
    memory = await listen(async (req, res, body) => {
      demand(req.headers.authorization === 'Bearer synthetic-secret', 'unexpected-memory-auth');
      demand(req.url.startsWith('/v1/default/banks/synthetic/'), 'unexpected-memory-bank');
      req.url = req.url.slice('/v1/default/banks/synthetic'.length);
      res.setHeader('content-type', 'application/json');
      if (req.method === 'GET' && req.url === '/profile') { demand(++evidence.profile <= 2, 'duplicate-profile'); res.end('{"bank_id":"synthetic"}'); return; }
      if (req.method === 'POST' && req.url === '/memories/recall') {
        const value = JSON.parse(body); demand(evidence.recalls.length === 0 && value.query === TEXT.prompt, 'unexpected-recall');
        evidence.recalls.push(value); res.end(JSON.stringify({ results: [{ id: 'fixture-memory', text: TEXT.recall }] })); return;
      }
      if (req.method === 'POST' && req.url === '/memories') {
        const value = JSON.parse(body);
        demand(evidence.retains.length < 2 && value.async === true && /^[a-f0-9-]{36}$/.test(value.operation_id) && !operations.has(value.operation_id), 'unexpected-retain');
        const expected = evidence.retains.length === 0 ? `user: ${TEXT.prompt}` : `assistant: ${TEXT.final}`;
        demand(value.items?.length === 1 && value.items[0].content === expected, 'retained-content-mismatch');
        demand(![TEXT.history, TEXT.historyAnswer, TEXT.recall, 'TOOL_SENTINEL', 'REASONING_SENTINEL'].some(sentinel => body.includes(sentinel)), 'excluded-content-retained');
        operations.set(value.operation_id, value); evidence.retains.push(value);
        res.end(JSON.stringify({ success: true, async: true, operation_id: value.operation_id })); return;
      }
      if (req.method === 'GET' && /^\/operations\/[a-f0-9-]{36}$/.test(req.url)) {
        const id = req.url.split('/').at(-1); demand(operations.has(id) && !evidence.completed.includes(id), 'unexpected-operation-poll');
        evidence.completed.push(id); res.end(JSON.stringify({ operation_id: id, status: 'completed' })); return;
      }
      throw new Error('unexpected-memory-request');
    });
  } catch (error) { provider.close(); throw error; }
  return { provider: `http://127.0.0.1:${provider.address().port}`, memory: `http://127.0.0.1:${memory.address().port}`, evidence,
    check: () => demand(!failure, failure), close: async () => { provider.closeAllConnections(); memory.closeAllConnections(); await Promise.all([new Promise(r => provider.close(r)), new Promise(r => memory.close(r))]); } };
}
