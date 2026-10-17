# Native memory adapters

These are explicit activation artifacts, not installed hooks. Source inspection
and isolated fixtures qualify the protocols below. They do not establish live
capture, GUI trust, network access, extraction completion or cross-host recall.
No native hook, upstream module or real agent was executed to obtain fixtures.

## Contract

`manage.mjs` exports `adapterArtifacts(options)`. It returns owned files and JSON
array appends without changing configuration. The core owns preview, safe writes,
exclusive activation, write digests and rollback. Existing arrays remain intact.
Conflicting edits must fail rather than overwrite another hook or plugin.

Every bridge calls the recorded absolute Node and CLI paths. The command is a
fixed CLI verb. JSON arrives on stdin. There is no shell or PATH fallback in that
call. Native shell hook command templates quote each path separately.
Descriptors contain `schema_version`, `runtime`, `cli`, `owner` and `agentVersion`.
Descriptors require private regular files and safe parent directories.
Malformed descriptors disable only the adapter and emit a content-free warning.

All envelopes use `schema_version:1`, `agent`, `session` and `owner`.

| CLI verb | Adapter input | Meaning |
|---|---|---|
| `session` | `baseline`, `fresh` | Explicit native registration; no baseline retention; existing cutoffs never reset |
| `session-status` | Envelope | Check registration without exposing content |
| `capture-transcript` | Complete normalized `messages` | Core validates its immutable enrolled prefix before atomic suffix admission |
| `stage-turn` | `turn_id`, `prompt` | Private durable original prompt; not accepted outbox work |
| `complete-turn` | `turn_id`, `text` | Admit staged user and final assistant together; stable IDs |
| `abort-turn` | `turn_id` | Remove only that unaccepted staged turn after a native terminal failure |
| `recall` | `query`, `turn_id` | Bounded once-per-turn recall; response is labeled untrusted by core |

Machine results use `status`, not `state`. Nonzero exits, malformed results and
failure statuses produce safe diagnostics. The normal agent continues. No bridge
claims capture merely because its callback ran. Only the core acknowledges durable
admission. Failed delivery remains the core's responsibility.

## Source and fixture qualification

The inspected versions are exact allowlists. An update needs requalification.
The generic installer must discover the actual selected executable's version.
An installed version number alone cannot establish the route used by a desktop.

| Adapter | Versions | Registration and capture | Recall |
|---|---|---|---|
| `claude-code` | 2.1.302 | Native `SessionStart`; `UserPromptSubmit` stages `prompt_id`/original prompt; `Stop` supplies same ID/final text | Native prompt ID; `additionalContext` output |
| `codex-cli` | 0.162.0, 0.163.0 | `SessionStart` baseline; pinned `event_msg` turn boundaries and native `Stop` final text; only transcript source `cli` | Native `turn_id` on `UserPromptSubmit` |
| `pi` | 1.1.0, 1.3.0 | Reasoned `session_start`, immutable branch entry IDs, terminal `agent_end` | `context` after user persistence; custom request-local message |
| `opencode-v1` | 1.18.35 | Fresh `session.created`; SDK `session.messages`; `session.idle` snapshot | `chat.message`; synthetic native text part excluded from every later capture |
| `opencode-v2` | 2.0.32 | Promise API; durable `session.created`/`session.execution.succeeded` data envelopes; stored `session.context` snapshot | Request-local `session.hook('context')`; no privileged system injection |

Claude's transcript is written asynchronously. Its final answer may be absent
when `Stop` runs. The adapter therefore never reads Claude's transcript.
Resume registration has an empty baseline because only newly staged native prompt
events can enter this route. Missing prompt IDs or final text fail closed.
`StopFailure` aborts that staged prompt without retaining API error output.
User interruption has no qualified matching native cancellation hook here.
An interrupted pending stage stays visible. A later prompt cannot replace it.
Explicit recovery must name and discard the unaccepted staged turn, or preserve
it for investigation. The adapter never guesses completion or silently discards it.
Other hooks may request continuation from `Stop`; a changed completion for the
same ID is refused. End-to-end continuation coverage remains a live qualification
limit; the first Stop event is not proof that every future continuation completed.

Codex's transcript format is not a stable public hook interface. These parsers
are pinned to inspected protocol sources. They ignore tool and reasoning records.
Missing/truncated/incomplete old boundaries, rollback and compaction markers refuse
capture. They never fall back to uploading an entire transcript. The core checks
prefix identities and text before extracting a new suffix. Source values `vscode`,
`exec`, unknown strings and subagent objects are refused. This prevents a shared
global hooks file from silently certifying Desktop or T3 execution.

Pi calls `before_agent_start` before it persists the new user. Recall therefore
runs during `context`, where a persisted native user entry must match the prompt.
The bridge never invents a user ID. Custom/injected recall, tool results, reasoning
and summaries are excluded. A native abort/error/length response drops its pending
users from the normalized conversation. A later successful turn cannot collect
that cancelled user's text. An incomplete resumed session refuses registration.
Only `stop` qualifies as a completed assistant. Branch changes must pass the core's
existing prefix check; registering another baseline cannot bypass it.

OpenCode v1 and v2 are independent adapters. Their package names, plugin exports,
configuration keys, event envelopes and message schemas differ. V1 uses global
`opencode.json` key `plugin`; v2 uses `plugins`. Both accept local file URLs.
Existing sessions are not discovered or scanned. They remain off until a qualified
native registration event. Forks remain refused. Compaction or context projection
that changes the enrolled prefix stops capture. V2's event subscription is not a
synchronous durable bridge callback. A process crash before dispatch is not
accepted work and remains a route qualification limit.

## Immutable evidence

Inspected on 2026-10-17. GitHub tag refs were resolved to commits before recording.

| Source | Exact revision | Relevant files |
|---|---|---|
| Codex 0.163.0 | `83086188ae0614bd882818ff1aa23f3194962012` | `codex-rs/hooks/src/events/session_start.rs`, `codex-rs/core/src/hook_runtime.rs`, `codex-rs/protocol/src/protocol.rs` |
| Codex 0.162.0 | `c1382380de69521303b416720a52f42d51af6248` | Matching session-start hook schema |
| Pi 1.3.0 | `71023aec1546d6d677a65669c5665c0927ce0dd0` | `packages/coding-agent/src/core/extensions/types.ts`, `agent-session.ts`; installed `docs/session-format.md`, `docs/message-types.md` |
| Pi 1.1.0 | `abe508e1b89912adde45528136c3221eb69acdd7` | Native extension types and session manager |
| OpenCode v1 | `53d1eabb61e21162157817bf677da0a4ad3332e3` | `packages/plugin/src/index.ts`, `packages/sdk/js/src/gen/types.gen.ts`, native message-v2 |
| OpenCode v2 | `843a6c514e606b436a7fe713422ace0a93ad3d61` | `packages/plugin/src/promise/{plugin,session,event}.ts`; schema session-message/session-event/config/plugin; generated client API |
| Gemini 0.64.0 | `4a0749aceac5643e6f85a36d7420314d85e13b52` | Core hooks types and handler; services chatRecordingService/chatRecordingTypes |

Claude 2.1.302 installed binary:
`/home/fodurrr/.local/share/mise/installs/claude/2.1.302/claude`.
SHA-256 `60d7eb7f12fbb28a52533fe8be5884097403562aa02dc73991a021c7067e29a5`.
Embedded source, byte offsets in that artifact: common hook schema `O` near
236063108; common input builder `ou(e,n,r,s)` at 246286345 sets
`prompt_id:Pde()??void 0`; `Pde` at 233926882 reads the request journal's prompt ID.
`Ebr` builds UserPromptSubmit from this common input. Native Stop spreads the same
common input and sets `last_assistant_message`. The Stop schema describes that
field as final assistant text. Missing optional fields are refused at runtime.
No binary was executed to inspect these fields.

OpenCode v2 recall cannot become stored user text through this bridge:
`packages/core/src/session.ts:386-389` reads `store.context(sessionID)`.
`session/model-request.ts:105-120` converts stored messages to provider messages;
`:252-264` supplies that request array to hooks; `:423-427` triggers context hooks.
`session/runner/llm.ts:228-245` passes transformed request data to the model step.
The stored native snapshot and request-local array are separate paths. Fixtures
also assert that recalled text is absent from later normalized stored messages.

Primary references:

- [Claude hook fields and asynchronous transcript caveat](https://code.claude.com/docs/en/hooks)
- [Codex pinned protocol](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/protocol/src/protocol.rs)
- [Pi pinned lifecycle](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/agent-session.ts)
- [OpenCode v2 pinned model request](https://github.com/anomalyco/opencode/blob/843a6c514e606b436a7fe713422ace0a93ad3d61/packages/core/src/session/model-request.ts)
- [Gemini pinned recording](https://github.com/google-gemini/gemini-cli/blob/4a0749aceac5643e6f85a36d7420314d85e13b52/packages/core/src/services/chatRecordingService.ts)
- [Grok official hook documentation](https://github.com/xai-org/grok-build/blob/main/crates/codegen/xai-grok-pager/docs/user-guide/10-hooks.md)

## Routes still blocked

`BLOCKED_ADAPTERS` provides machine-readable reasons. These are unresolved
obligations. Unsupported classification does not complete the work item.

| Route | Concrete remaining evidence or compatibility work |
|---|---|
| Claude 2.1.295 | Its exact native binary/schema was not inspected; 2.1.302 evidence does not certify it |
| Grok 1.0.62/1.0.50 | Installed 1.0.62 embedded docs expose camelCase `sessionId`/`promptId`, source `new`/`load`, and clipped final text. Allowing UserPromptSubmit output is discarded, so that hook cannot provide automatic recall. Original native prompt provenance and 1.0.50 compatibility remain unqualified |
| Gemini 0.64.0/0.63.0 | AfterAgent's prompt is `finalRequest`; native recording stores synthetic user messages with the same record shape. Stable original-prompt lineage and cancellation identity need qualification before automatic retention |
| Hermes | `agent/memory_manager.py:599-664` uses a daemon executor before provider `sync_turn`. A provider-only durable queue cannot close that pre-admission gap. Existing writer handover and new-only durable recovery remain open |
| Codex Desktop/ChatGPT | CLI hooks or MCP access do not prove actual native Desktop lifecycle, runtime path and trust. Codex source filtering refuses other transcript routes |
| Claude Desktop | Ordinary chats differ from Claude Code sessions. Code-in-Desktop must separately prove hook environment and trust; ordinary chats have no qualified automatic bridge |
| T3 | Qualify the actual provider and choose exactly one capture owner; neither generic CLI support nor two active writers prove coverage |
| Zed/OpenCode Desktop | Qualify the actual native provider route and GUI launch environment independently |

## Verification boundary

Run `node --test tools/hindsight-memory/test/adapters.test.mjs`.
Fixtures cover native IDs, resume baselines, source exclusion, terminal failure,
cancelled Pi users, imported recall/tool/reasoning exclusion, both OpenCode APIs,
shell-free core invocation, result validation and unsafe local paths.
All filesystem fixtures live under temporary directories. No real agent settings,
credentials, transcripts or memory endpoints are used. Bridge startup and durable
core admission must be measured together before making the 100 ms target a claim.
