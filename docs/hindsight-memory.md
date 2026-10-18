# Personal Hindsight memory

The optional `hindsight-memory` profile prepares a standalone personal-memory
component. It does not activate capture. Existing Hindsight memories remain on
the configured external server. This repository does not create or upgrade it.

**Pi capture and later fresh-session recall passed on GEEKOM.** The pinned compiled Linux Pi 1.3.0 installation is active. Other automatic adapters remain blocked pending qualification. Publication, main merge and other host rollouts require approval.

Use the exact qualified launch, then `/new` and accept its endpoint/bank consent:

```sh
env -u NODE_OPTIONS -u BUN_OPTIONS -u LD_PRELOAD -u LD_LIBRARY_PATH /home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi/pi --no-extensions -e /home/fodurrr/.pi/agent/extensions/hindsight-memory.js
```

Ordinary `pi` does not qualify capture. The approved live pilot uses the existing Pi `xai` OAuth login and `grok-4.3`. OpenAI Subscription Sharing was exhausted. All other Pi settings and authentication were preserved. The seven approved directories remain 0755. [The canonical checkpoint](plans/hindsight-memory.md#pi-live-completion-attempt-and-account-quota-blocker) records exact changes, evidence and ownership-aware rollback.

## Preparation and explicit activation

The component requires **Node 24.15 or newer within Node 24** and the tested
`node:sqlite` APIs. Node's SQLite API remains a release candidate. The installer
uses the existing mise owner. Future Node majors require requalification.

On a fresh, approved host, profile selection is optional:

```sh
./install.sh -p hindsight-memory
```

Configured hosts must preserve their complete profile set. The installer refuses
memory-only selection there, runtime-key loss and `--clean`. Read the
[installer boundaries](hindsight-memory-installer.md) before choosing profiles.
A separately approved component-only preparation can avoid refreshing other apps:

```sh
/path/to/qualified/node tools/hindsight-memory/src/cli.mjs prepare
```

Preparation copies versioned artifacts to the user's data directory. It creates
`~/.local/bin/hindsight-memory` with an absolute qualified runtime path. It does
not create a bank, register agent hooks, set credentials or start a service.
The component works outside repositories after the source checkout is removed.
Newly prepared releases exclude `test/`, `node_modules/` and `experiments/`.
This exclusion does not remove older releases or change an existing installation.

Shared `~/.local/bin` can use mode 0755. Group-writable directories such as 0775
are refused, including writable ancestors. The component does not chmod shared
directories. GEEKOM's inspected bin permissions need a separately reviewed rollout
prerequisite; no permission change occurred during implementation.

Create an existing server-side bank and authorization independently. Bank names
alone do not isolate users. Configure a private 0600 file containing only the
Hindsight API credential. Its directory and ancestors must be safe and owned.
The component does not automatically discover or reuse another application's credentials.

Pipe explicit configuration through stdin. Replace every example value:

```json
{
  "schema_version": 1,
  "endpoint": "https://memory.example.invalid",
  "bank": "my-existing-personal-bank",
  "secret_file": "/absolute/private/path/hindsight-api-key",
  "adapters": ["pi"],
  "agent_versions": {"pi": "1.3.0"},
  "agent_commands": {"pi": "/absolute/path/to/qualified/pi"},
  "capture": true
}
```

```sh
hindsight-memory configure < /private/path/personal-memory-config.json
hindsight-memory activation-preview
```

The example file must stay outside Git. The secret value never enters this JSON.
There is no default endpoint, bank, person or enabled adapter. The local core accepts HTTPS. Cleartext HTTP permits only literal `127.0.0.1`
or `[::1]` for explicit local deployments and isolated tests. Named hosts,
including `localhost`, require HTTPS.
It rejects URL credentials, query strings, redirects and path prefixes.

The preview reads executable metadata and its hash; it never executes Pi or contacts the service.
For Pi, it shows `capture_owner`, the exact sole-extension launch, and
`installed_writers_verified:false`. Inventory and select one installed capture
writer before activation. The generated owner does not prove that inventory happened.
After choosing this writer, copy the preview's exact owner into the private JSON:

```json
"capture_owners": {"pi": "<exact 64-character capture_owner from preview>"}
```

Run `configure` again, then review `activation-preview`. Missing or different
selection refuses activation. The owner is tied to this host, endpoint and bank.
Changing the destination requires selecting its new generated owner.
Use the prepared launcher; activation from a different source checkout refuses
`use-installed-release-command`. Prepare the intended version first.

Activation needs host approval and native trust. The Linux routes accept the
pinned Pi 1.3.0 and dedicated Codex CLI 0.163.0 executables. Select each route's
generated owner in `capture_owners`. Other routes refuse
`native-caller-binding-unqualified`. These are host commands:

```sh
hindsight-memory activate
hindsight-memory status
```

Activation records actual UTC time and a generation. It preserves unrelated
hooks and settings. It does not weaken native trust settings. `active:true`
means local consent and installed adapter artifacts, **not verified live capture**.
`capture_verified:false` remains explicit. Authentication, bank access and
cross-agent recall still need approved harmless live checks.
`installed_writers_verified:false` remains explicit after activation.
Launch only the preview's exact executable and arguments:
`--no-extensions -e <absolute generated bridge path>`. Clear the four preload
variables listed in `launch.unset_environment`. Ambient extension discovery,
extra arguments and copied bridges cannot satisfy the bridge's process checks.
Create a fresh `/new` TUI session and accept its endpoint/bank consent.
Startup and resumed sessions do not inherit consent.

### Dedicated Codex CLI

After selecting `codex-cli` and its exact capture owner, activation installs
`~/.local/bin/codex-memory`. It accepts interactive sessions and an optional
`--model <name>`. Its default model is `gpt-6-luna`.
It starts in its own persistent workspace at
`~/.local/state/hindsight-memory/codex-workspace`. Files written there remain
after exit. Existing project directories, resume, fork, positional prompts and
other arguments are not supported by this route.
Ordinary `codex`, Codex Desktop and this running conversation are unchanged.

The launcher keeps its own profile at
`~/.local/state/hindsight-memory/codex-profile`. Its validated authentication link
uses the existing Codex ChatGPT authentication file and native file store.
Native refreshes update that same file, as ordinary Codex sessions do.
It does not copy authentication tokens, global settings, plugins or hook trust.
API-key and custom-provider authentication are not supported here.

On the first launch, use native `/hooks` to review and trust the six memory
hooks. Close that session and relaunch `codex-memory` before sending a prompt.
The initial skipped `SessionStart` is not replayed after trust changes.
The private profile keeps native hook trust for later launches.
The launcher refuses extra profile hooks, plugins or unsupported configuration.
It does not bypass native hook trust.

Rollback removes the owned launcher and descriptor. It preserves the private
Codex profile's authentication link, trust and native history, and its workspace.
These are user state, not managed code. Per-launch binding files are removed
when the launcher exits.

Changing configuration while active is refused. Deactivate first. Changing the selected adapter set also requires rollback of its owned hooks first. A matching
configuration resumes the existing generation, cutoff and pending jobs. A new
destination creates a separate generation; older jobs keep their original bank,
endpoint, operation UUID and request bytes.

## Adapter qualification

| Adapter | Exact source/fixture versions | Remaining qualification |
|---|---|---|
| Claude Code | 2.1.302 | Automatic activation refused: emitted prompt hooks omit human versus automated origin. An interactive launcher cannot fill that missing field. |
| Codex CLI | Dedicated Linux 0.163.0 route | `codex-memory` uses direct native prompt/final-answer hooks and a separate private profile. Actual native trust and delivery need verification; desktop/global hooks are not enabled. |
| Pi | Pinned compiled Linux 1.3.0, sole generated extension; prepared native fake-service path passed | Local eligibility requires explicit owner selection. GEEKOM installed capture and fresh-session real recall passed; other hosts still need qualification. Pi 1.1 remains unqualified. See the [adapter contract](../tools/hindsight-memory/adapters/README.md). |
| OpenCode v1 | 1.18.35 | Independent v1 plugin and actual provider lifecycle |
| OpenCode v2 | 2.0.32 | Independent Promise plugin/event API and pre-dispatch crash gap |
| Grok | Investigated 1.0.62 | Native prompt-hook output is discarded; complete automatic recall route unqualified |
| Gemini | Investigated 0.64.0 | Stable original prompt identity and synthetic recording boundaries unqualified |
| Hermes | Investigated installed provider path | In-memory executor precedes durable provider admission; safe handover also required |
| Desktop, T3, Zed | Separate routes | Actual provider, native lifecycle and exclusive capture owner unqualified |

The qualification helper probes an explicit agent executable with `--version` and records its identity only during explicit activation. Pi must first match the pinned ELF hash and owner selection. The bridge independently checks its actual process, exact arguments and saved generated bridge path before admission. Its prepared native qualification covered completed capture, cancellation, session changes, resumed sessions and conflicting capture owners against a fake service. These checks do not certify real service access or intentional edits by the same user.

Native bridges reject a changed selected executable or retargeted alias before admission. The dedicated Codex route binds hooks to the exact launched native process. It stages the native prompt and completes the matching native turn without reading a transcript. Its private profile excludes global hooks and plugins that could request more work after `Stop`. Fresh registration uses an empty baseline. Resume, compaction, subagents, steering and cancellation cannot inherit accepted capture eligibility. The earlier transcript parser remains fixture-only; creator headers cannot prove the current invoking application. **Other automatic adapter activation remains refused.** Their implemented source/fixture adapters remain available for isolated qualification. Unsupported adapters, mismatched detected versions and unqualified versions fail activation. Existing OpenCode `opencode.jsonc` also refuses activation until its coexistence behavior is qualified. They do not become
successful skips. These unresolved routes remain work-item obligations. CLI
support does not establish desktop or T3 support. The component does not install
Hermes, an agent suite or company tooling merely to prepare memory.

Claude uses native stable prompt IDs and completed assistant text. It stages the
original user prompt, then admits both messages atomically at completion. It does
not depend on Claude's asynchronously written transcript. A staged prompt is not
accepted retention. Missing completion or overlapping pending turns is visible;
an explicit native cancellation can call `abort-turn`. Do not invent completion.

Transcript adapters enroll one explicit native session. They verify the saved
prefix before admitting its suffix. Missing, changed, forked or truncated cursors
stop capture. They never scan session directories or upload whole-history
fallbacks. Remote sessions capture on the execution host. One owner must be
chosen for each provider/T3 session before activation.

## Delivery, privacy and limits

Private config, state and installed releases use the user's HOME/XDG paths:

| Data | Default location |
|---|---|
| Local configuration, adapter descriptors and ownership records | `~/.config/hindsight-memory` |
| SQLite sessions, staged turns, outbox and receipts | `~/.local/state/hindsight-memory` |
| Content-addressed releases and installation ownership | `~/.local/share/hindsight-memory` |

State directories use 0700 and files 0600. Symlinks, hard-linked private files,
unsafe owners and writable ancestors are refused. No whole state directory is
Stowed. Configuration ownership records contain owned writes and hashes, not
copies of authentication or conversation files. Known secret patterns are
redacted before durable capture; redaction cannot detect every secret.

Only new user/assistant conversation text is retained. Tool output, hidden
reasoning, Git, files, provider logins and injected recall are excluded. Assistant
claims remain attributed claims. Recalled text is labeled untrusted context and
cannot authorize tools or change current instructions.
Retained metadata includes the execution host name, agent, session, message,
role, activation, chunk and UTC timestamp. Host names and identifiers reach the
configured memory service alongside the eligible text.

Admission commits all chunks, message identities and the cursor in one SQLite
transaction. A failed or full admission commits none. Short ordinary writer contention waits instead of forcing a 50 ms rejection. Sustained contention still returns `state-busy-admission-not-confirmed`; it never reports acceptance or moves the cursor. Constructor initialization does not rewrite schema metadata on every hook. The disk-backed 30-turn source-fixture stress test counts every rejection. Whole bridge tail latency can exceed 100 ms while preserving acceptance under contention; it is reported separately from direct admission. Each request has a stable
UUID and unique message/chunk document ID. Accepted bytes stay immutable across
retries. Completed payloads are removed locally; replay evidence remains.

| Limit | Implemented behavior |
|---|---|
| Local admission | 100 ms measurement target; SQLite can wait up to 500 ms per contended lock; truthful failure overrides timing |
| Recall | Complete facts fit a 1000-byte labeled context in relevance order; an oversized fact is skipped. Direct request once per turn; 8-second core deadline budget, including local work after CLI process start |
| Recall output | 256 KiB HTTP response; at most 1,000 UTF-8 bytes including injected labels/provenance |
| Native bridge | 8-second total recall invocation deadline across child startup, local work and HTTP; outer application event overhead is measured separately |
| Payload | At most 64 KiB per job; stable chunks with all-or-none admission |
| Outbox | At most 1,000 outstanding jobs or 64 MiB; failed jobs count |
| Mutable state | 128 MiB budget with conservative SQLite recovery headroom; physical capacity can reject earlier |
| Staging | At most 1,000 pending native turns or 64 MiB, plus the shared physical bound |
| Background worker | One kernel-held worker mutex and fenced lease; 60-second wake budget, requests at most 10 seconds; an OS-paused process stays visibly pending |
| Retry | At most 8 retain/existence-check attempts and 24 operation polls per 24-hour automatic cycle |
| Backoff | Five seconds exponential, capped at 15 minutes, bounded jitter and Retry-After |

SQLite uses FULL synchronous DELETE journalling. Its page ceiling and conservative
headroom reserve room for a rollback journal. Completed receipts and session
watermarks are never silently deleted to regain capacity. State growth eventually
stops admission visibly. The default benchmark uses `os.tmpdir()`. GEEKOM `/tmp` is tmpfs, so those numbers exclude physical-disk fsync latency. A disk-backed private `/var/tmp` fixture must be measured separately. Actual ENOSPC, macOS durability and slow storage remain
separate qualification; Linux crash and SQLite page-limit fixtures are not proof
of those environments.

A read-only bank-profile check must confirm the existing bank before a retain
POST. It never calls bank creation/configuration, seeding, reflect or imports.
The bank-profile endpoint is pinned to the inspected API schema. A missing bank
fails safely instead of relying on the server's lazy creation behavior. Profile
HTTP 429 and 5xx responses retry within the same attempt, age and backoff limits;
auth, missing-bank and invalid-schema responses remain terminal.

A submitted operation is not completed extraction. Lost acknowledgements trigger
reconciliation using the same operation UUID. A missing/expired operation becomes
visible unresolved work; it is not blindly resubmitted. An offline request that
may never have reached the server can therefore require explicit recovery.
Submission success alone does not prove exactly-once processing.

`status` reports safe counts and at most ten pending operation IDs, states and reason codes. `hindsight-memory status 10` reads the next page. It never includes request bodies, destination URLs or secret-file paths. It does not display transcript text or secrets.
`staged_turns` counts prompts awaiting accepted completion. A failed completion
and failed abort can leave such a prompt without its assistant answer. It is
unaccepted input, not a submitted operation; `retry` cannot recover that answer.
`doctor` and `inspect` are also read-only. They do not retry, repair or contact
memory. A queue cannot preserve unlimited later conversation during an indefinite
outage. Accepted jobs survive; later rejected turns are reported as not captured.

Background delivery wakes on session events, accepted capture or explicit retry.
It can wait for due retries/polls within its 60-second lifetime. Delivery is not
guaranteed while all agents are closed. No resident service is added.

For an unresolved operation, inspect its safe local status before an explicit
recovery action. `retry` accepts stdin with `operation_id` and `action:"reconcile"`.
A deliberate `action:"resubmit"` requires
`acknowledge_duplicate_extraction:true`. It preserves UUID and bytes but may
repeat extraction if server operation history expired. It resets only the
explicit automatic recovery cycle; it never creates a new request identity.
Recovery holds the worker process mutex through its state transaction. An expired
lease cannot authorize recovery while a paused worker still holds that mutex.
No automatic recovery weakens this boundary.

## Deactivation, rollback and updates

```sh
hindsight-memory deactivate
hindsight-memory status
hindsight-memory rollback
```

Deactivation stops new admission and claims. Kernel-held SQLite mutexes account for worker and recall process lifetimes. They remain held during an OS pause. In-flight processes produce `suspension-pending`; timestamps alone never prove suspension complete. Read-only status keeps crashed in-flight markers pending until an explicit mutating reconciliation confirms the process released its mutex. Recalled context is suppressed after deactivation. Rollback removes
only owned adapter writes. It preserves remote memories, local jobs, consent
history, cursors and installed code. It never deletes agent authentication.

Intervening edits cause rollback refusal. Resolve the specific configuration
conflict manually; do not overwrite user changes. Interrupted artifact application
stays inactive with a visible partial ownership journal. Automatic repair is
intentionally refused because the remaining writes need inspection. Installation
launcher/record interruption uses a private intent journal and is safely resumed
by another explicit `prepare`.

Updates preserve existing consent and state. A missing or changed runtime fails
with a requalification instruction. Explicit `prepare` using a newly qualified
Node can repair the recorded runtime. Do not rely on arbitrary PATH fallback.
Unknown state schemas are refused before mutation. New adapters require explicit
selection and qualification; they are not enabled on update.

See the [canonical work item](plans/hindsight-memory.md) for acceptance obligations
and the [component interface](../tools/hindsight-memory/README.md) for isolated
verification commands. No live capture, rollout or cross-host acceptance is
implied by the repository test results.
