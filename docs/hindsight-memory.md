# Personal Hindsight memory

The optional `hindsight-memory` profile prepares a standalone personal-memory
component. It does not activate capture. Existing Hindsight memories remain on
the configured external server. This repository does not create or upgrade it.

Implementation is under review. **Every automatic adapter currently refuses activation** because actual native caller binding remains unqualified. Publication, main merge and live rollout require
separate approval. The commands below describe the later workflow; they were not
run against the operator's home or memory bank during implementation.

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

Shared `~/.local/bin` can use mode 0755. Group-writable directories such as 0775
are refused, including writable ancestors. The component does not chmod shared
directories. GEEKOM's inspected bin permissions need a separately reviewed rollout
prerequisite; no permission change occurred during implementation.

Create an existing server-side bank and authorization independently. Bank names
alone do not isolate users. Configure a private 0600 file containing only the
Hindsight API credential. Its directory and ancestors must be safe and owned.
The component does not reuse Hermes or company credentials.

Pipe explicit configuration through stdin. Replace every example value:

```json
{
  "schema_version": 1,
  "endpoint": "https://memory.example.invalid",
  "bank": "my-existing-personal-bank",
  "secret_file": "/absolute/private/path/hindsight-api-key",
  "adapters": ["codex-cli"],
  "agent_versions": {"codex-cli": "0.163.0"},
  "agent_commands": {"codex-cli": "/absolute/path/to/qualified/codex"},
  "capture": true
}
```

```sh
hindsight-memory configure < /private/path/personal-memory-config.json
hindsight-memory activation-preview
```

The example file must stay outside Git. The secret value never enters this JSON.
There is no default endpoint, bank, person or enabled adapter. The local core
accepts HTTPS, or loopback HTTP for explicit local deployments and isolated tests.
It rejects URL credentials, query strings, redirects and path prefixes.

The eventual activation workflow also needs separate host approval and native hook/plugin trust. The current candidate refuses this command with `native-caller-binding-unqualified`:

```sh
hindsight-memory activate
hindsight-memory status
```

Activation records actual UTC time and a generation. It preserves unrelated
hooks and settings. It does not weaken native trust settings. `active:true`
means local consent and installed adapter artifacts, **not verified live capture**.
`capture_verified:false` remains explicit. Authentication, bank access and
cross-agent recall still need approved harmless live checks.

Changing configuration while active is refused. Deactivate first. Changing the selected adapter set also requires rollback of its owned hooks first. A matching
configuration resumes the existing generation, cutoff and pending jobs. A new
destination creates a separate generation; older jobs keep their original bank,
endpoint, operation UUID and request bytes.

## Adapter qualification

| Adapter | Exact source/fixture versions | Remaining qualification |
|---|---|---|
| Claude Code | 2.1.302 | Native trust and host execution; cancellation and lost pre-bridge events remain visible |
| Codex CLI | 0.162.0, 0.163.0 | Unstable pinned transcript format; actual host hooks/trust and completion persistence |
| Pi | 1.1.0, 1.3.0 | Actual extension execution and session switches on each host |
| OpenCode v1 | 1.18.35 | Independent v1 plugin and actual provider lifecycle |
| OpenCode v2 | 2.0.32 | Independent Promise plugin/event API and pre-dispatch crash gap |
| Grok | Investigated 1.0.62 | Native prompt-hook output is discarded; complete automatic recall route unqualified |
| Gemini | Investigated 0.64.0 | Stable original prompt identity and synthetic recording boundaries unqualified |
| Hermes | Investigated installed provider path | In-memory executor precedes durable provider admission; safe handover also required |
| Desktop, T3, Zed | Separate routes | Actual provider, native lifecycle and exclusive capture owner unqualified |

The qualification helper probes an explicit agent executable with `--version` and records its identity. Production activation stops before this probe until caller binding is qualified. Native bridges reject a changed selected executable or retargeted alias before admission. Codex checks its transcript creator version and source. A resumed session preserves that original header, so it cannot establish the current invoking application or version. **All automatic adapter activation is refused** until actual native caller binding is qualified. Another installed binary can otherwise load the same global config. Their implemented source/fixture adapters remain available for isolated qualification; they are not active supported routes. Unsupported adapters, mismatched detected versions and unqualified versions fail activation. Existing OpenCode `opencode.jsonc` also refuses activation until its coexistence behavior is qualified. They do not become
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

Admission commits all chunks, message identities and the cursor in one SQLite
transaction. A failed or full admission commits none. Short ordinary writer contention waits instead of forcing a 50 ms rejection. Sustained contention still returns `state-busy-admission-not-confirmed`; it never reports acceptance or moves the cursor. Constructor initialization does not rewrite schema metadata on every hook. The disk-backed 30-turn source-fixture stress test counts every rejection. Whole bridge tail latency can exceed 100 ms while preserving acceptance under contention; it is reported separately from direct admission. Each request has a stable
UUID and unique message/chunk document ID. Accepted bytes stay immutable across
retries. Completed payloads are removed locally; replay evidence remains.

| Limit | Implemented behavior |
|---|---|
| Local admission | 100 ms measurement target; SQLite can wait up to 500 ms per contended lock; truthful failure overrides timing |
| Recall | Direct request once per turn; 1.5-second core deadline budget, including local work after CLI process start |
| Recall output | 256 KiB HTTP response; at most 1,000 UTF-8 bytes including injected labels/provenance |
| Native bridge | 1.5-second total recall invocation deadline across child startup, local work and HTTP; outer application event overhead is measured separately |
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
fails safely instead of relying on the server's lazy creation behavior.

A submitted operation is not completed extraction. Lost acknowledgements trigger
reconciliation using the same operation UUID. A missing/expired operation becomes
visible unresolved work; it is not blindly resubmitted. An offline request that
may never have reached the server can therefore require explicit recovery.
Submission success alone does not prove exactly-once processing.

`status` reports safe counts and at most ten pending operation IDs, states and reason codes. `hindsight-memory status 10` reads the next page. It never includes request bodies, destination URLs or secret-file paths. It does not display transcript text or secrets.
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
