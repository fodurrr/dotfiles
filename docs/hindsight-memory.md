# Personal Hindsight memory

Personal memory uses the official `@vectorize-io/hindsight-coding-agents` integration.
Dotfiles does not install a separate memory runtime or maintain capture adapters.
The former custom component and profile are retired.

## Installation and settings

GEEKOM, Omen and Mini use package **0.8.1**, the existing Mini service
at `https://peters-mac-mini.wisent-fence.ts.net`, and the existing personal bank
`fodurrr`. Credentials stay in private machine settings outside Git.
Omen and Mini were added on **2026-11-03**; see
[Omen, Mini and T3 Code environments](#omen-mini-and-t3-code-environments).

The official command can detect supported agents already installed on the machine:

```sh
npx @vectorize-io/hindsight-coding-agents@0.8.1 install all --server self-hosted --api-url https://peters-mac-mini.wisent-fence.ts.net
```

This installs integrations, not missing agent applications. Review detection:
leftover agent directories can be mistaken for installed applications.
On GEEKOM, `all` matched Kilo and Cline, which were then removed.
For another host, **name the agents explicitly** instead of `all`:

```sh
npx -y @vectorize-io/hindsight-coding-agents@0.8.1 install claude-code codex pi grok-build opencode antigravity-cli --server self-hosted --api-url https://peters-mac-mini.wisent-fence.ts.net
```

Add `opencode2` where that command exists, as on GEEKOM and Omen.
In a non-interactive zsh, run `npx` through `mise exec node@lts --`.

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

## Omen, Mini and T3 Code environments

Rolled out on **2026-11-03** with Peter's approval. The goal: an agent that
T3 Code runs on Omen or Mini saves to and recalls from the same `fodurrr` bank
as on GEEKOM.

**Why each machine needs its own install.** A linked T3 Code environment runs
its own T3 server (`t3 serve`). That server starts `claude`, `codex` and the
other agents **on that machine**. They read that machine's `~/.claude`,
`~/.codex`, `~/.pi`, `~/.grok` and `~/.config/opencode` settings. GEEKOM's hooks
do not travel with the T3 Desktop window.

### What each machine has

| Item | GEEKOM | Omen | Mini |
|---|---|---|---|
| Hindsight settings | `~/.hindsight/coding-agent.json` | Same file content | Same file content |
| Connected agents | Claude Code, Codex, Pi, Grok, OpenCode, `opencode2`, Antigravity | Claude Code, Codex, Pi, Grok, OpenCode, `opencode2`, Antigravity | Claude Code, Codex, Pi, Grok, OpenCode, Antigravity |
| Claude `SessionEnd` capture entry | Yes | Yes | Yes |
| Codex hook trust | Yes | Yes | Yes |

**One API token on all three machines** (Peter's decision, 2026-11-03).
The three settings files are identical; their normalized SHA-256 starts with
`a702a042`. Revoking that token stops capture on all three machines together.

Before installing, Mini's mise tools were brought to GEEKOM's versions with
`mise upgrade claude codex pi grok node`: Claude Code 2.1.317, Codex 0.166.0,
Pi 1.5.0, Grok 1.0.70, Node 24.22.2. All are `latest`/`lts` in the shared
mise configuration.

The extra Claude `SessionEnd` entry is the same one GEEKOM uses (see
[GEEKOM evidence and recovery](#geekom-evidence-and-recovery)), with that
machine's home path.

**Codex hook trust.** Codex runs a hook only after it is trusted. On GEEKOM this
was done in the Codex screen ("trust all"). Omen and Mini have no screen session.
There, the official Codex app server recorded the same trust: `hooks/list`
returns each hook's `key` and `currentHash`, and `config/value/write` stores
`hooks.state.<key>.trusted_hash`. Only the three Hindsight hooks were trusted.
On GEEKOM, the recorded hashes equal the `currentHash` values from `hooks/list`,
so both routes write the same record.

### Test results through T3 Code (2026-11-03)

Each test thread received one harmless label and was told not to use tools.
Each machine's own `~/.hindsight/coding-agents-logs/diag.jsonl` was then read.

| Machine and agent | Capture | Recall injected |
|---|---|---|
| Omen, Claude Code | `retain_ok`, 1 turn (the label message) | Not recorded for this turn |
| Omen, Codex | `retain_ok`, 2 turns | 12 facts |
| Mini, Codex | `retain_ok`, 2 turns | 16 facts |
| GEEKOM, Grok | `retain_ok`, 2 turns | 20 facts |
| GEEKOM, Antigravity | **No Hindsight hook ran** | None |

All four captured retains **completed** on the server between 20:28:34 and
20:28:48 UTC. A direct recall API query per label then found each label in the
`fodurrr` bank (result ranks 0, 6, 2 and 4). The Antigravity label is absent.

**Cross-machine automatic recall.** Two fresh T3 threads, Claude on GEEKOM and
Codex on Mini, asked for all four labels in one question without being given
them. Mini's Codex answered Omen Claude's label correctly from injected memory.
The other labels were not among the 12 to 20 facts the hook injects for that
combined question. This shows ranking limits, not missing capture.
Those recall-test sessions were themselves captured, including their "not in
memory" answers; treat those test facts as noise.

### Limits

- **Antigravity inside T3 Code is not captured.** T3 starts its Antigravity agent
  with a private `GEMINI_HOME` under `~/.t3/userdata/providers/antigravity/`.
  T3's code states: "Private GEMINI_HOME isolates credentials/hooks/MCP; link
  global skills from the real ~/.gemini." The official Hindsight hooks live in
  `~/.gemini/config/hooks.json`, which that agent does not read. The hooks remain
  installed for a real `agy` command-line tool. No workaround is installed.
- **Mini's Claude Code is not logged in.** T3 reports "Claude Code is not
  authenticated". Run `claude auth login` on Mini before using Claude there.
- **T3 provider switches.** On Omen and Mini, T3 has only Claude and Codex
  enabled (Mini: Codex only until the login above). Grok, Pi, OpenCode and
  Antigravity are connected to Hindsight but disabled in T3 there.
- Pi and OpenCode capture was not tested through T3 on any machine.
- Start fresh T3 threads after installation. A resumed older thread can send its
  earlier messages.

### Recovery

Each machine keeps a private journal at
`~/.local/state/hindsight-host-rollout/2026-11-03` (0700): copies of every file
the installer could change, `install.log`, the Claude `SessionEnd` change and the
Codex configuration before trust. To remove the integration, first remove the
`SessionEnd` entry as described for GEEKOM, then run the official per-agent
`uninstall` commands. Removal does not delete the remote bank.

## Desktop applications

**Further desktop checks are cancelled** (Peter, 2026-11-03): work happens in
T3 Code from now on. The results below stay as recorded; no Codex Desktop or
Claude Chat capture is claimed.

Checked on **2026-10-18** using the installed official Linux desktop applications.
CLI checks above do not substitute for desktop checks.

| Desktop surface | Actual result | Remaining limit |
|---|---|---|
| Codex in ChatGPT desktop 26.1013.40934 | Its native backend 0.163.0-alpha.10.2 initialized the official Hindsight MCP server. All three official hooks have persisted trust entries. | Main desktop-session hook execution, capture and fresh recall remain unverified. Native UI controls were unavailable. |
| Claude Desktop 2.42304.0, local Code | A fresh native session loaded Hindsight, called diagnosis and sync status, recalled an existing fact absent from its prompt, and completed capture with five facts and no extraction errors. | Later fresh-session recall of a newly captured fact remains unverified. Older live sessions can still submit again; start a fresh session. |
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
to **12 parent cancellation acknowledgements and cancelled readbacks** at those
checkpoints. Those readbacks did not establish child cancellation. No memories
were deleted. The current cursor
has `appendSupported:true`; 2,452 parsed turns alone does not prove another
full-history replacement. No capture setting was disabled.

No fresh main Codex Desktop test fact was identified. Current native MCP
initialization was saved, but the shared backend can initialize tools for delegated
children. That does not prove main desktop capture or recall. Claude Chat still
has no observed native Hindsight connection or actual `hindsight_diagnose` result.
No API fact lookup was run because no fresh desktop test fact was found.

The final exact-link check at **2026-10-18 21:07:46 UTC** inspected all 12 linked
child operations. Two were cancelled and verified. Nine completed. One failed
with `Task exceeded the 3600s wall-clock limit for 'batch_retain'`.
That failed operation still reports 44 committed facts. No linked child was
pending or processing at the final snapshot. A processing child completed before
its cancellation request; DELETE returned HTTP 409 and GET confirmed `completed`.

Earlier parent cancellation did not stop every child. Rechecking the original
nine parents found eight `completed` and one `failed`, superseding their earlier
`cancelled` readbacks. Old-session data has reached memory. No stored memory was
deleted. Exact-link child checks used 27 API requests; this follow-up used 36
including the three later parent cancellations. No fresh-session jobs were touched.
The full bounded result is saved in `fresh-verification/child-cancellation.json`.

**Independently matched fresh Claude Code result:** Saved native desktop metadata
matches the Code session created at **2026-10-18 21:03:18 UTC**. Four Hindsight
tools were loaded; diagnosis and sync status were actually called. Diagnosis
confirmed `fodurrr`, harness `claude-code` and matching configured authentication.
The prompt hook recalled 25 facts in 3,562 ms. The answer cited an existing test
fact absent from the prompt. Capture retained seven parsed turns; parent and child
operations completed with five committed facts and zero extraction errors.
This proves fresh native tools, existing-fact recall and completed capture.
It does not prove later fresh-session recall of a newly captured fact. The private
evidence is `fresh-verification/fresh-claude-followup.json`. Chat and main Codex
Desktop remain separate verification obligations.

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
4. Ask for a newly captured harmless fact in another fresh Code session.
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

The approved Mini upgrade on **2026-10-18** installed official server **1.0.0**
and enabled this setting across **all three existing banks**. It uses the pinned
ARM64 image manifest
`sha256:0be688fa345092f6d88687330a6e9da012673652c5894787bef5527cc0082e30`.
Official fix **#3777**, included since **0.10.0**, removes the conflicting
source-language extraction instructions in the former **0.9.2** server.

The runtime setting and protected canonical `server.env` both specify English.
No bank configuration was rewritten. The setting is not bank-overridable.
A short Russian statement of the user's English-memory preference produced an
English fact. Exact-document recall and English reflection both succeeded.

This setting does not translate existing memories or original transcripts.
Our `autoInject: "recall"` returns stored facts directly, including existing
Russian/French facts. It also does not set Claude/Codex/Pi's own answer language.
English extraction will not repair missing MCP tools or unrelated recall results.
The shared `fodurrr` bank intentionally spans projects; unrelated facts alone
are not proof of incorrect bank routing.

A bank's retain/observations missions can ask for English, but these are softer
prompt instructions. They do not provide an English-only guarantee.

### Upgrade verification and recovery

The upgrade retained the existing endpoint, authentication, provider/model,
network and production ports. The official coding-agent package remains **0.8.1**.
No adapters, capture code or vendor files were changed.

The first ordinary Docker stop failed: the vendor wrapper reported
`Timeout reached, forcing shutdown...` while the API waited for five tasks.
Automatic recovery restarted **0.9.2** on its original volume before migration.
The corrected native shutdown signalled the API first, allowing its own drain
and PostgreSQL shutdown before wrapper cleanup. It exited **0**.

The frozen original volume was archived before migration. The archive contains
**2,728,407,040 bytes** and **3,122 entries**. Its checksum was saved privately.
Archive comparisons passed against both the original and a restored clone.
PostgreSQL control data reported clean shutdown for both. Server **1.0.0**
migrated only the clone to Alembic head **`c8e2f4a6b1d3`**.
Acceptance used alternate loopback ports while production remained unavailable.
All three bank identity hashes were preserved; legitimate jobs were not cancelled.

After acceptance, the migrated clone was promoted to the original ports.
API/database health and authenticated access passed; unauthenticated access
returned **401**. The external endpoint reports **1.0.0**. The existing official
stdio server initialized eight tools; diagnosis confirmed `fodurrr`, matching
authentication and harness `claude-desktop`. Sync status also succeeded.
This proves transport/settings compatibility, not a new native desktop turn.

The maintenance interval caused visible **502** capture/retrieval failures.
At the bounded post-upgrade snapshot, official local cursors held two pending
Codex batches and one pending Claude batch. No cursor was dirty. Recovery waits
for normal supported integration activity; complete client draining is not claimed.
Disabled Git seed/pages still make `synced:false` expected.

The original **0.9.2** image, stopped recovery container, frozen volume and
verified archive remain available. The recovery container has restart policy
`no`; production retains `unless-stopped`. Private exact manifests and recovery
instructions are under `~/.local/state/hindsight-update-2026-10-18`.
The original authentication bind stays live; do not restore stale login snapshots.
**Production now accepts writes.** Starting the frozen original would discard
newer writes. Preserve the migrated volume and use the saved recovery instructions
instead of attempting an automatic downgrade.

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
