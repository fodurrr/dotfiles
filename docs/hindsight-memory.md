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
