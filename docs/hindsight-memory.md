# Personal Hindsight memory

Personal memory uses the official `@vectorize-io/hindsight-coding-agents` integration.
Dotfiles does not install a separate memory runtime or maintain capture adapters.
The former custom component and profile are retired.

## Installation and settings

The approved GEEKOM installation uses package **0.8.1**, the existing Mini service
at `https://peters-mac-mini.wisent-fence.ts.net`, and the existing personal bank
`fodurrr`. Credentials stay in private machine settings outside Git.

The official command detects supported agents already installed on the machine:

```sh
npx @vectorize-io/hindsight-coding-agents@0.8.1 install all --server self-hosted --api-url https://peters-mac-mini.wisent-fence.ts.net
```

This installs integrations, not missing agent applications. Review detection:
leftover agent directories can be mistaken for installed applications.
Do not run the command on another host without its rollout approval.

Private settings live in `~/.hindsight/coding-agent.json` with mode **0600**.
The API token belongs only in that private file or the official environment setting.
Never copy it into this repository, commands, screenshots or logs.

The local configuration selects:

```json
{
  "apiUrl": "https://peters-mac-mini.wisent-fence.ts.net",
  "bankId": "fodurrr",
  "dynamicBankId": false,
  "retainSessions": true,
  "autoInject": "recall",
  "injectTimeoutMs": 10000,
  "recallOptions": {"types": null},
  "autoSeed": false,
  "gitIngest": "none",
  "codebaseSurvey": false,
  "manageBankConfig": false,
  "autoUpdate": false,
  "pages": {
    "Component map": false,
    "Core concepts": false,
    "Conventions and patterns": false,
    "Key decisions and rationale": false,
    "Initiatives and enhancements": false
  }
}
```

The private file also contains `apiToken`. The example intentionally omits it.
Check project settings and environment overrides when changing these choices.
Package updates remain explicit and reviewable. Direct recall avoids the default
reflection step, which repeatedly timed out at 20 seconds on this service.
`types:null` includes fresh facts before they become consolidated observations.

## Capture and ordinary use

Start a **fresh session** after installation. Use ordinary `pi`, `claude` or
`codex`; the former restricted Pi command and `codex-memory` launcher are retired.
Native hook or extension trust still applies. Restart existing sessions to load
new wiring. Codex CLI verification does not establish Codex Desktop coverage.

The official integration retains meaningful session messages and supported
activity, including progress and automated work. It has no custom human-only
or final-answer-only filter. Its parsers do not retain every raw tool result,
internal reasoning or every file on the machine.

Historical bulk import is not enabled. Git ingestion, initial seeding and codebase
surveys are disabled. **Resuming an older conversation can still send its earlier
messages.** The official full-session fallback is separate from bulk import.
Use fresh sessions when older history must remain excluded.

Existing Hermes memory stays with its existing official plugin. Do not add a
second writer for the same session. The installer's supported-agent list does not
prove successful end-to-end capture for every detected application.

Claude also runs the **same official retain command at native `SessionEnd`**
with timeout 60. This appends final assistant text after transcript flush.
The normal `Stop` hook remains for per-turn capture. Both use one cursor.
No vendor code or capture wrapper is changed.

## Desktop applications

Checked on **2026-10-18** using the installed official Linux desktop applications.
CLI checks above do not substitute for desktop checks.

| Desktop surface | Actual result | Remaining limit |
|---|---|---|
| Codex in ChatGPT desktop 26.1013.40934 | Its native backend 0.163.0-alpha.10.2 initialized the official Hindsight MCP server. All three official hooks have persisted trust entries. | Main desktop-session hook execution, capture and fresh recall remain unverified. Native UI controls were unavailable. |
| Claude Desktop 2.42304.0, local Code | Its bundled Code 2.1.299 uses shared user hooks/MCP/settings. Actual desktop hooks injected recall and submitted retention. Nine identified old-session operations were cancelled after approval. | No fresh desktop test or completed extraction is claimed. The old live session can submit again; start a fresh session. |
| Claude Desktop Chat | Added the official Hindsight stdio MCP server to desktop settings. Its exact command initialized, listed eight tools and diagnosed the existing `fodurrr` bank. | The app still needs to load the new settings. Tools provide requested memory access; they do not automatically capture Chat transcripts. |
| Claude Cowork | No dedicated automatic Hindsight capture support was established. | No Cowork change or working-capture claim. |

Codex already reads the official MCP and hooks from `~/.codex`; no Codex setting
changed. Its desktop backend differs from the separately installed CLI. Native
MCP initialization was observed in its logs, but those rows rotated before export.
The private report identifies this as an observation rather than a saved raw log.

Claude Desktop Code shares `~/.claude/settings.json` and user MCP settings with
Claude Code CLI. Desktop Chat uses a separate file:
`~/.config/Claude/claude_desktop_config.json`. Only its `mcpServers.hindsight` key
was added:

```json
{
  "command": "/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node",
  "args": ["/home/fodurrr/.hindsight/coding-agents/dist/mcp-server.js"],
  "env": {"HINDSIGHT_MCP_HARNESS": "claude-desktop"}
}
```

This uses the unmodified official server and protected shared Hindsight settings.
No token was copied into desktop settings. No custom integration or wrapper was
added. No application was restarted while active work was running.

**Existing older-session submission was observed.** A Claude Desktop Code session
began on 2026-10-16. After cutover, the official integration selected full-session
replacement on 2026-10-18 and submitted its parsed transcript, including older
messages. The reported 2,391 turns are the parsed transcript count, not a count
of extracted memories. Seven accepted operations remained pending at the first
inspection. After explicit approval on **2026-10-18**, each still reported `pending`.
The local cursor then identified two later accepted operations from that same
old session. Each also still reported `pending`. All nine initial official cancellation
requests returned HTTP 200. Follow-up status reads confirmed all nine were
`cancelled` at **2026-10-18 20:53:02 UTC**. There were no skipped operations,
HTTP 409 responses or request failures. No bank data was deleted. Cancellation
does not undo any memories already committed or establish child-operation status.
No old session was deliberately run for this check. Starting fresh avoids reusing
those old transcripts.

The bounded follow-up found no fresh main Codex Desktop capture evidence. Native
`hooks/list` requests prove hook discovery, not execution. The saved successful
Codex captures belong to CLI sessions; their `originator` field alone is insufficient.
Claude Desktop Chat still had no observed Hindsight server process or matching
connection log. Its new MCP setting therefore still needs a normal app reload.
No native desktop UI control was available. No CLI or delegated-child check was
substituted for a main desktop conversation.

This is a bounded cancellation snapshot. The old Claude Desktop Code session was
still running and can submit new work later. No broad capture setting was disabled.
Finish that session and start a fresh one. Cancellation evidence is in the private
desktop evidence directory's `cancellation` subdirectory. It records exact operation
IDs, status checks and responses without transcript contents or secrets.

### Latest native follow-up

The follow-up on **2026-10-18** found the reported Claude answer in the same
resumed Code session. That session began on **2026-10-16**. Its native process
started on **2026-10-18 at 10:35:18 UTC**. The main desktop process also predates
the Hindsight desktop setting. Reopening an existing conversation did not establish
a fresh session or loaded tools.

The native Code session's saved tool list contains three Chrome tools and no
Hindsight tools. Its startup log says:
`no stdio servers connected — announcing an empty local-MCP group`.
Both official Hindsight settings exist, and no explicit Hindsight denial was found.
No settings defect or server-file rebuild cause was established. The supported
next step is a full app quit/reopen after active work finishes, then a fresh session.

Existing Claude hook capture and injected recall were observed again. Three later
operations from that exact old session were pending. Each cancellation returned
HTTP 200 and each follow-up status was `cancelled`. This brings the bounded total
to **12 verified parent-operation cancellations**. The three latest responses still
show child operations as `pending`; child cancellation was not verified. No memories
were deleted. The current cursor
has `appendSupported:true`; 2,452 parsed turns alone does not prove another
full-history replacement. No capture setting was disabled.

No fresh main Codex Desktop test fact was identified. Current native MCP
initialization was saved, but the shared backend can initialize tools for delegated
children. That does not prove main desktop capture or recall. Claude Chat still
has no observed native Hindsight connection or actual `hindsight_diagnose` result.
No API fact lookup was run because no fresh desktop test fact was found.

**Subsequent user-reported fresh Claude Code result:** A genuinely new session
listed nine Hindsight MCP tools and called four. Its diagnosis reported the
configured endpoint, bank `fodurrr` and enabled configuration. Automatic recall
returned the supplied test label. This is user-supplied native evidence; this phase
did not independently match the new session's logs or prove its completed capture.
It supersedes the missing-tool result for that fresh Code session. Chat and main
Codex Desktop remain separate verification obligations.

The reported sync result lists eight conversations, zero knowledge pages, missing
Git seeding and `synced:false`. Git seeding and knowledge pages are deliberately
disabled here. Their absence does not justify enabling ingestion or demonstrate
a service failure. Nine reported jobs were not individually inspected in this
snapshot; their completion is not inferred. No unrelated watch was changed.

Remaining native checks, accounting for that reported fresh Code success:

1. Fully quit and reopen Claude Desktop. Merely closing its window may leave the app running.
2. Check `Claude Desktop -> Settings -> Developer` for Hindsight's connection.
3. In a fresh Chat, ask Hindsight to diagnose its bank and harness. Expect
   `fodurrr` and `claude-desktop`. This proves tools, not automatic Chat capture.
4. Match the reported fresh local Code session to native capture/completed extraction.
   Ask for its harmless fact in another fresh Code session.
5. Use `Codex Desktop -> New task` for the equivalent fresh main desktop fact.
6. Ask for each fact in another fresh session without repeating its value.
   Then match actual native capture, completed extraction and recall evidence.

No native app control was available here. No CLI or delegated-child result was
substituted for main desktop proof. Latest private metadata, native log snapshots
and three exact cancellation responses are in the `fresh-verification` directory.

Private desktop evidence is
`~/.local/state/hindsight-desktop-check/2026-10-18`, with directories 0700 and files
0600. Claude's backup and ownership journal are in its `claude` subdirectory.
To undo this phase, remove only `mcpServers.hindsight` if it still matches that
journal. Preserve all other keys. No new Codex change needs undoing.

## English memory output

Official Hindsight provides this **server-wide** setting:

```sh
HINDSIGHT_API_LLM_OUTPUT_LANGUAGE=English
```

Its default is unset, preserving source or query language. It guides newly
generated facts, observations, mental models and Hindsight reflect answers.
It is prompt guidance, not a hard language validator. It is not a field in
`~/.hindsight/coding-agent.json` and cannot be set separately for one bank.
It affects every bank served by that Hindsight deployment.

The live API reports **0.9.2**. That version recognizes the setting but has
conflicting retain prompt instructions. Official fix **#3777**, included in
**0.10.0**, resolves that conflict. Do not rely on the current server to enforce
English extraction. No server upgrade, environment change or bank mission change
was made during this check.

This setting does not translate existing memories or original transcripts.
Our `autoInject: "recall"` returns stored facts directly, including existing
Russian/French facts. It also does not set Claude/Codex/Pi's own answer language.
English extraction will not repair missing MCP tools or unrelated recall results.
The shared `fodurrr` bank intentionally spans projects; unrelated facts alone
are not proof of incorrect bank routing.

A bank's retain/observations missions can ask for English, but these are softer
prompt instructions. They do not provide an English-only guarantee. Changing a
shared server or bank language policy requires its own approval.

Sources: [official multilingual settings](https://hindsight.vectorize.io/0.10/developer/multilingual),
[bank setting scope](https://hindsight.vectorize.io/developer/api/memory-banks),
[language prompt fix](https://github.com/vectorize-io/hindsight/pull/3777),
[official release notes](https://github.com/vectorize-io/hindsight/releases).
Private source/version findings are in the desktop evidence directory's
`english-language-findings.md`.

## GEEKOM evidence and recovery

The canonical [work item](plans/hindsight-memory.md#official-installer-replacement)
records the actual installed agents, native checks and remaining limits.
The private working journal is `/var/tmp/hindsight-official-cutover`.
A durable copy is `~/.local/state/hindsight-official-cutover/2026-10-18`.
It contains before-settings, installation results and ownership-aware recovery
information. Keep this private; backups can contain authentication settings.

**Before removing Claude**, edit `~/.claude/settings.json` -> `hooks` ->
`SessionEnd`. Remove only the owned entry whose command is
`node "/home/fodurrr/.hindsight/coding-agents/dist/claude-stop-hook.js"`
and timeout is `60`. Preserve all other hooks. Remove the `SessionEnd` key
only if its list becomes empty. The exact entry and before-settings are saved
in `/var/tmp/hindsight-official-cutover/claude/sessionend-change.json`.
Vendor 0.8.1 uninstall does not remove this additional event automatically.

Then use the official per-agent removal commands:

```sh
npx @vectorize-io/hindsight-coding-agents@0.8.1 uninstall pi
npx @vectorize-io/hindsight-coding-agents@0.8.1 uninstall claude-code
npx @vectorize-io/hindsight-coding-agents@0.8.1 uninstall codex
```

Removal does not delete the existing remote bank. Restore only settings owned by
the cutover. Preserve newer logins and unrelated settings rather than restoring
whole stale authentication snapshots.

The former source under `tools/hindsight-memory` is historical evidence only.
No profile, installer layer or current launcher selects it. Existing custom
receipts, native history and rollback journals remain private and recoverable.
Publication, main merge and other host rollouts still require approval.

## Official references

- [Coding-agent integration guide](https://hindsight.vectorize.io/sdks/integrations/coding-agents)
- [Upstream integration source](https://github.com/vectorize-io/hindsight/tree/5331da2f4db369528bb122075341a7de9c3df6df/hindsight-integrations/coding-agents)
- [Codex hooks and trust](https://learn.chatgpt.com/docs/hooks)
- [Claude Desktop Code settings](https://code.claude.com/docs/en/desktop)
- [Claude Desktop local MCP servers](https://modelcontextprotocol.io/docs/develop/connect-local-servers)
- [Official Hindsight operation cancellation](https://docs.hindsight.vectorize.io/api-reference/cancel-operation/)
