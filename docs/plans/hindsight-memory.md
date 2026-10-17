# Standalone personal Hindsight memory

```work-item
{
  "schema_version": 2,
  "id": "hindsight-memory",
  "title": "Standalone personal Hindsight memory",
  "owner": "Peter",
  "state": "Queued",
  "objective": "Provide optional personal Hindsight memory for general macOS and Linux machine setup, independently of Nucleus, Xpando tooling and repository membership.",
  "deliverable": "An approved standalone design, then separately authorized implementation and isolated verification of a reusable client component, agent adapters and optional Dotfiles profile; publication and live rollout remain separate approvals.",
  "current": "2026-10-17: Peter moved full ownership to Dotfiles. The complete immutable Nucleus audit is preserved as an input. The old Nucleus-release monitor was deleted. This expanded design awaits Peter's approval; no implementation or live configuration has started.",
  "next": "Present the revised standalone proposal and self-review to Peter. Wait for explicit approval before implementation. Send the committed successor task IDs to Nucleus for its Superseded transfer.",
  "scope": {
    "included": [
      "Preserve all relevant Nucleus audit findings and unresolved obligations in this sole canonical plan.",
      "Propose a reusable local Hindsight client component, optional profile, agent adapters, durable delivery, private state and safe rollback.",
      "Plan all used supported routes on GEEKOM, Omen and Mini, including remote work and conversations outside repositories.",
      "Plan verification, review and separate publication/rollout decisions."
    ],
    "excluded": [
      "Implementation before renewed approval; prior consumer-only implementation approval is superseded.",
      "Nucleus or Xpando runtime dependencies, company-bank sharing, new provider abstraction or memory service.",
      "Historical imports, Git ingestion, surveys, bulk files, secret files and hidden reasoning capture.",
      "Unapproved package/product publication, new repository, resident service, main merge or live deployment.",
      "Server upgrade/recreation, backup changes, credential rotation, reboot or deployment to Adam."
    ]
  },
  "inputs": [
    {
      "category": "objective",
      "owner": "Peter",
      "source_kind": "instruction",
      "locator": "Nucleus chat 01a12fb1-16b4-7082-b244-f48a800ce904, human turns 01a14b82-9c39-7312-a3d7-0851fef110d7 and 01a14b85-3143-7123-bba1-2067cb839287, verified through read_thread on 2026-10-17.",
      "role": "Moves ownership fully to Dotfiles; authorizes planning, transfer and plan commit/push only; revised proposal precedes implementation.",
      "availability": "available",
      "required_at": "start"
    },
    {
      "category": "evidence",
      "owner": "Nucleus audit author",
      "repository": "/home/fodurrr/dev/xpando/nucleus",
      "path": "plans/shared-personal-memory.md",
      "revision": "40fe44ee7657cae6f8b436c4ea7b14610bf06e0c",
      "track": "committed",
      "role": "Complete immutable audit, artifact digest, findings, host matrix, limits, tests, self-review and unresolved obligations; ownership-specific architecture is superseded.",
      "availability": "available",
      "required_at": "start"
    },
    {
      "category": "governing",
      "owner": "Peter",
      "repository": ".",
      "path": "AGENTS.md",
      "revision": "4c0a4d1d4248b1423e8675811b1a3726b00d2c24",
      "track": "committed",
      "role": "Dotfiles repository workflow, host boundaries, ownership and checks.",
      "availability": "available",
      "required_at": "start"
    },
    {
      "category": "evidence",
      "owner": "Dotfiles maintainer",
      "repository": ".",
      "path": "docs/plans/hindsight-memory.md",
      "revision": "4c0a4d1d4248b1423e8675811b1a3726b00d2c24",
      "track": "committed",
      "role": "Previous plan and installer/host audit; Nucleus release gate and narrow implementation approval are superseded.",
      "availability": "available",
      "required_at": "start"
    }
  ],
  "tasks": [
    {
      "id": "proposal-approval",
      "actor": "Dotfiles supervisor and Peter",
      "state": "open",
      "depends_on": [],
      "work": "Present and revise the standalone proposal, preserve the transfer, and obtain explicit approval of the expanded implementation.",
      "done_when": "Peter approves a concrete independent runtime/adapter/installer scope; no old approval is reused."
    },
    {
      "id": "standalone-runtime",
      "actor": "Dotfiles implementation owner",
      "state": "open",
      "depends_on": [
        "proposal-approval"
      ],
      "work": "Qualify upstream reuse and implement only the approved independently installable local component and versioned interface.",
      "done_when": "Runtime works with company tooling and source checkouts absent; qualified Node/storage APIs, private installation and upgrade behavior are verified."
    },
    {
      "id": "safe-capture",
      "actor": "Dotfiles implementation owner",
      "state": "open",
      "depends_on": [
        "standalone-runtime"
      ],
      "work": "Enforce activation and message boundaries, atomic admission, single-writer ownership and exclusion of historical/file/Git content.",
      "done_when": "Old/resumed/forked/corrupt-cursor sentinels never reach the API; accepted chunks and cursor advance atomically; unknown state stops capture."
    },
    {
      "id": "reliable-delivery",
      "actor": "Dotfiles implementation owner",
      "state": "open",
      "depends_on": [
        "standalone-runtime"
      ],
      "work": "Implement bounded durable admission, retry/poll accounting, stable operation identities and visible failure.",
      "done_when": "Crash/restart/capacity/uncertain-ack/stale-worker tests pass; accepted work persists within all documented budgets."
    },
    {
      "id": "adapter-coverage",
      "actor": "Dotfiles implementation owner",
      "state": "open",
      "depends_on": [
        "safe-capture",
        "reliable-delivery"
      ],
      "work": "Qualify each installed native agent, desktop/provider and remote route, including Hermes handover and pre-admission gaps.",
      "done_when": "Each route has explicit support evidence or an unresolved blocker; unsupported classification does not silently satisfy the coverage requirement."
    },
    {
      "id": "privacy-rollback",
      "actor": "Dotfiles implementation owner",
      "state": "open",
      "depends_on": [
        "standalone-runtime"
      ],
      "work": "Protect local secrets/state, safe diagnostics, untrusted recall, existing configuration and ownership-aware rollback.",
      "done_when": "Permission, redaction, destination-isolation, pending-job, in-flight-delivery and intervening-edit tests pass without deleting memories or state."
    },
    {
      "id": "installer-integration",
      "actor": "Dotfiles implementation owner",
      "state": "open",
      "depends_on": [
        "standalone-runtime"
      ],
      "work": "Add the optional profile, explicit prerequisites, safe preparation layer, status handling and runtime-preservation guards.",
      "done_when": "macOS/Linux profile and failure tests pass; preparation does not activate capture or require company tooling; addon/clean modes cannot prune unrelated runtimes."
    },
    {
      "id": "verification-review",
      "actor": "Dotfiles supervisor and independent reviewer",
      "state": "open",
      "depends_on": [
        "safe-capture",
        "reliable-delivery",
        "adapter-coverage",
        "privacy-rollback",
        "installer-integration"
      ],
      "work": "Run isolated component/adapter/installer tests, repository checks, self-review and required independent ExitGate.",
      "done_when": "Evidence identifies exact artifacts and tested versions; all accepted obligations pass or Peter explicitly changes scope; no live acceptance is inferred."
    },
    {
      "id": "publication-rollout",
      "actor": "Peter and Dotfiles supervisor",
      "state": "open",
      "depends_on": [
        "verification-review"
      ],
      "work": "Present exact publication/main/host-update/activation commands and quota-consuming checks for separate approval.",
      "done_when": "Only separately approved actions execute; per-host activation and end-to-end evidence are recorded; no deployment to Adam is inferred."
    }
  ],
  "risks": [
    {
      "id": "historical-capture",
      "owner": "Dotfiles safe-capture task",
      "detail": "Stock cursor replacement and whole-branch retention can upload history; missing state must fail closed."
    },
    {
      "id": "support-claims",
      "owner": "Dotfiles adapter-coverage task",
      "detail": "Installed/MCP/CLI presence does not establish desktop, T3, Gemini or Hermes completion coverage."
    },
    {
      "id": "secrets-and-queue",
      "owner": "Dotfiles reliable-delivery and privacy-rollback tasks",
      "detail": "Finite storage and imperfect redaction need visible rejection, durable accepted jobs, permission checks and honest limits."
    },
    {
      "id": "ownership",
      "owner": "Dotfiles privacy-rollback and installer-integration tasks",
      "detail": "Preserve personal/company isolation, unrelated auth/hooks/settings, runtime ownership and network routes."
    },
    {
      "id": "runtime-scope",
      "owner": "Peter and Dotfiles standalone-runtime task",
      "detail": "A substantial reusable local runtime is proposed explicitly; do not hide it as installer glue or publish a product without approval."
    }
  ],
  "exit": [
    "Peter approves the revised independent implementation before code changes.",
    "Every transferred obligation has a verified outcome or explicit owner-approved scope disposition.",
    "Standalone runtime and installer pass isolated tests with no company dependencies.",
    "Required independent ExitGate passes before Completed; main merge and live actions retain separate approval."
  ],
  "verification": {
    "exit_passed": false,
    "status": "Planning and evidence transfer only. Nucleus audit includes six isolated cursor-decision checks; no live capture acceptance. New runtime, adapters and proposed budgets remain unimplemented."
  },
  "relationships": []
}
```


## Decision and approval boundary

Personal memory is an optional general computer setup capability owned fully by
Dotfiles. It must work without Nucleus, Xpando AI Layer, company repositories,
company skills, Erlang or Elixir. Hindsight remains the external memory service.

Peter's human instructions were verified in the Nucleus chat on 2026-10-17.
He moved this work fully into Dotfiles and requested a revised plan before code.
The previous consumer-only implementation approval does not cover this expanded
design. The old released-Nucleus-contract gate is removed, not carried forward.

The current authority covers plan revision, self-review, plan checks, plan
commit/push and coordination. No implementation, installation, package publication,
main merge, host update, activation, restart or live memory write is authorized.

Peter's example of his son Adam establishes portability, not deployment scope.
Endpoint, bank, user identity and secret references are local choices.
Peter's intended destination is the existing Mini server and bank fodurrr.
A different user must supply a different explicit configuration. Creating a bank
or server is not implicit in preparation. Separate bank names are not access
control: any future multi-user deployment must verify server-side authorization.

This is the sole canonical work item. Its portable JSON block supports obligation
transfer only; it creates no plan-engine, Nucleus or runtime dependency.
The implementation stays Queued pending Peter's revised-plan approval.

## Immutable evidence and transfer

Read completely on 2026-10-17:

- Nucleus audit: repository /home/fodurrr/dev/xpando/nucleus, commit
  40fe44ee7657cae6f8b436c4ea7b14610bf06e0c, file plans/shared-personal-memory.md.
  Retrieve with git show at that exact revision even after Nucleus closes its item.
- Previous Dotfiles plan: commit 4c0a4d1d4248b1423e8675811b1a3726b00d2c24,
  file docs/plans/hindsight-memory.md. Its inspection evidence remains useful;
  its ownership, release gate and narrower implementation approval are superseded.
- Complete Dotfiles Handoff.md and Nucleus Handoff.md under
  /home/fodurrr/dev/xpando/xpando-notes-vault/Research/Hindsight Shared Memory/.
  The later human ownership decision overrides their former ownership split.
- Nucleus handoff SHA-256 recorded by the audit:
  fdce83ebf9d4a8a1b5fc871fd2a5374ff226a9d7de94720c29cbc1f39b844cad.
- Initial research attachment was background only; its history/Git/per-project-bank
  suggestions remain superseded by the accepted personal-memory requirements.

Nucleus owns closing its item as Superseded after verifying this committed
replacement. Dotfiles owns all remaining personal-integration obligations.
No obligation or risk is cancelled merely to permit that closure.

| Original obligation | Preserved result or successor task |
|---|---|
| Repository, artifact, host and API audit | Immutable audit above; requalification in standalone-runtime and adapter-coverage |
| Original design and author self-review | Evidence retained; revised independent design below; proposal-approval |
| Present revised plan and obtain approval | proposal-approval |
| Safe historical boundary and provenance | safe-capture |
| Bounded delivery, retries, queue and completion | reliable-delivery |
| Support claims and actual execution environments | adapter-coverage |
| Secrets, company isolation, existing settings and rollback | privacy-rollback |
| Profile/runtime safety | installer-integration |
| Implementation acceptance and independent review | verification-review |
| Publication and host activation | publication-rollout; separate approval |
| Original historical-capture risk | Open under safe-capture |
| Original support-claims risk | Open under adapter-coverage |
| Original secrets-and-queue risk | Open under reliable-delivery and privacy-rollback |
| Original ownership risk | Open under privacy-rollback and installer-integration |

Nucleus-specific architecture placement, global skills, package projections,
Elixir-first constraints and release delivery are superseded. Do not copy its
company-default Hindsight client or create its proposed capability commands.

## What the audit proves

Exact inspected package: @vectorize-io/hindsight-coding-agents 0.8.1.
Tarball SHA-256:
407abd66ba5d4603a460ecfe6795d47a0e0687439a800d4bc79305f2ee2f5e1b.

npm's latest metadata was rechecked on 2026-10-17 and still named 0.8.1.
The immutable audit, not floating documentation, owns the behavioral findings.

| Finding | Exact audit source | Required response |
|---|---|---|
| Missing/dirty cursor, unavailable append, expired pending data or changed bank selects replacement | dist/codex-stop-hook.js:2070 and :2269 | No full-transcript fallback; explicit new-message boundary |
| Pi passes the whole session branch | dist/pi.js:18860 and :18910 | Filter qualified events before retention |
| Retention, bank management, seeding, surveys and auto-update default on; Git defaults to message; injection defaults to reflect | dist/codex-stop-hook.js:1620-1692 | Do not inherit installer/runtime defaults |
| manageBankConfig=false still permits seedPages | dist/codex-stop-hook.js:1023-1043 | Exclude actual forbidden calls, not just flags |
| Stock retry state has 12-hour/256-KiB pending bounds and two rate-limit retries | dist/codex-stop-hook.js:2051-2052 and :2140 | Cannot claim the required shared durable outbox |
| Hermes 1.2.1 uses an unbounded in-memory queue and clears its buffer after enqueue | Installed plugin __init__.py:414, :844, :1436 | Single-writer handover and durable admission required |
| Mini health and schema expose needed request fields | /health, /version, /openapi.json; MemoryItem.update_mode, RetainRequest.operation_id | Candidate API compatibility only; no live write proof |

Nucleus ran six isolated pure-function checks from the exact package.
Missing cursor, dirty cursor, expired pending data and unavailable append returned
replace. A valid cursor returned append from turn 1; unchanged input returned skip.
All six expected results passed. No upstream module, installer, hook or live
retention request ran. These are decision tests, not end-to-end acceptance.

The package declares an idempotent-retain minimum of API 0.8.6
(dist/codex-stop-hook.js:688 and :930). Mini 0.9.2 exceeds that minimum.
Schema/version checks do not prove authenticated idempotency, operation completion,
bank access or cross-agent recall. No server upgrade is indicated or authorized.

Additional Dotfiles self-review found a pre-admission Hermes gap:
installed Hermes commit 7bc05085f09ee9bfa9cecaaa3cf44758bdff96a6,
run_agent.py:887-910 and agent/memory_manager.py:599-664.
Completed user/assistant text is passed to providers through an in-memory daemon
executor. Replacing the provider queue alone cannot protect a turn lost before
the provider runs. Qualify a synchronous admission event or proven new-only
recovery from a durable transcript; do not patch installed Hermes implicitly.

Official supporting references:

- [Exact npm artifact](https://registry.npmjs.org/@vectorize-io/hindsight-coding-agents/-/hindsight-coding-agents-0.8.1.tgz)
- [Coding agents](https://hindsight.vectorize.io/sdks/integrations/coding-agents)
- [Hermes integration](https://hindsight.vectorize.io/sdks/integrations/hermes)
- [Portable plugin limitations](https://hindsight.vectorize.io/sdks/integrations/agent-plugin)
- [Node 24 SQLite](https://nodejs.org/download/release/latest-v24.x/docs/api/sqlite.html)
- [SQLite atomic commit](https://www.sqlite.org/atomiccommit.html)

Portable skills/MCP do not establish lifecycle capture. T3 discussions 13117 and
15858 remain research leads, not installed-provider support evidence.

## Host and route qualification

These are dated acceptance inputs, not a second maintained machine inventory.
Machine inventory remains in the infrastructure notes vault. Recheck before
rollout without updating hosts merely to refresh evidence.

| Host | Inspected state on 2026-10-17 | Boundaries |
|---|---|---|
| GEEKOM | Ubuntu 26.04.1; /home/fodurrr/dev/dotfiles; base main 396d946; developer plus optional geekom-vpn | Preserve desktop, PIA split routing and Tailscale |
| Omen | Ubuntu 26.04.1; same checkout path and base commit; clean main without remote; omen installation log | Headless; retain Git-bundle update transport |
| Mini | macOS 26.6.2; /Users/fodurrr/dev/dotfiles; clean main d50da8f, six commits behind GEEKOM base; last install log hacker | Preserve existing Hindsight server; review profile delta before any update |

| Route | GEEKOM | Omen | Mini | Acceptance status |
|---|---|---|---|---|
| Claude Code | 2.1.302 | 2.1.302 | Vendor 2.1.302; mise 2.1.295 | Upstream route exists; compliant automatic capture unverified |
| Codex CLI | 0.163.0 | 0.163.0 | 0.162.0 | Hooks/trust/boundary require qualification |
| Pi | 1.3.0 | 1.3.0 | 1.1.0 | Native extension exists; whole-branch retention is unsafe |
| OpenCode CLI | 2.0.32 | 2.0.32 | 1.18.35 | Separate v1/v2 native-event tests |
| Grok CLI | 1.0.62 | 1.0.62 | 1.0.50 | xAI CLI identified; Grok Build event compatibility unverified |
| Hermes | v0.21.6+726.g7bc0508; Hindsight 1.2.1 configured | v0.22.2, local d923a5eb487a; plugin absent | v0.21.6+726.g7bc0508; plugin absent | Completed-turn admission and handover unverified |
| Gemini CLI | 0.64.0 | 0.64.0 | 0.63.0 | No verified automatic adapter; cannot activate automatically |
| Codex Desktop / ChatGPT / Claude Desktop | Desktop routes present | Not assessed | ChatGPT and Claude present | Qualify independently of CLI; tools-only is insufficient |
| T3 | Desktop present | User service present | Desktop present | Exact provider route and capture ownership unverified |
| OpenCode Desktop / Zed | Not assessed | Not assessed | Present | Qualify actual used provider routes |

No route is certified active under this proposal. Upstream-documented routes
are candidates, not acceptance. The portable plugin is unsupported as a substitute
for automatic lifecycle capture. Unverified routes stay visibly unactivated.
Marking a route unsupported does not silently satisfy the coverage requirement;
report the blocker and obtain an explicit scope decision if it cannot be resolved.

Shared ~/.hindsight/coding-agent.json was absent on all three hosts.
GEEKOM Hermes already enables recall/retain/async for Mini/fodurrr.
Past activation and compliant completion are unproved; do not reset its settings.

GEEKOM and Omen reached Mini's HTTPS health endpoint. API 0.9.2 reported a healthy,
connected database. Existing bank counts and extraction-provider details remain
handoff observations. Local hosting does not imply local-only model processing.

All hosts link their mise config to generated Dotfiles configuration.
Omen's noninteractive PATH omitted installed commands. Mini's vendor Claude and
Hermes Node launchers differ from mise. Dotfiles observed Node 24.22.0 on Linux
and Mini mise 24.21.0 versus Hermes Node 26.8.2. Nucleus observed GEEKOM Node
22.22.3 in another execution environment. Record executable paths and versions
per launch environment rather than treating these observations as one global version.

## Revised architecture proposal

### Upstream first, with an explicit runtime decision

Prefer proven upstream configuration or a narrow reusable adapter when it meets
all accepted boundaries. Stock coding-agents 0.8.1 and the installed Hermes
delivery path do not. Wrapping install-all or changing a few flags is insufficient.

The recommended proposal is one independently installable local client component,
co-located under tools/hindsight-memory. This is substantial new runtime work,
not merely installer glue. Peter must explicitly approve it in the revised plan.

The component has one Node core for capture policy, private state, HTTP recall,
durable admission and background delivery. Small native bridges translate agent
events. Hindsight continues to own extraction and stored memory; no local search
engine, provider framework, memory server, broker or resident service is proposed.

Use Node LTS through the existing mise owner. Proposed baseline: Node 24.15+
with the required node:sqlite APIs, then qualify exact supported patch versions.
The Node documentation labels this API release candidate, not fully stable.
Use only the small tested API subset; reject unsupported builds before activation.
No Erlang/Elixir dependency, Nucleus client reuse or company-bank defaults.

A minimal Python bridge is allowed only if Hermes's native plugin interface
requires it, using Hermes's own existing runtime. It translates events to the
Node core; it must not implement another queue, HTTP client or policy engine.
Qualify actual complete-turn events first. If host changes are needed, return
with a concrete upstream compatibility proposal rather than silently patching it.

Do not fork or vendor the full upstream integration. Reuse licensed protocols
and proven narrow facilities only when their mutation paths can be excluded.
A later exact upstream release can replace local functions only after the same
acceptance suite passes. No unreviewed automatic runtime downloads.

### Standalone packaging and installation

Proposed source boundaries, all under /home/fodurrr/dev/dotfiles:

| Path | Responsibility |
|---|---|
| tools/hindsight-memory/README.md and component manifest | Independent interface, runtime requirements, ownership and version |
| tools/hindsight-memory/src/cli.mjs | Inspect, prepare, activate, status, retry, deactivate and rollback dispatch |
| tools/hindsight-memory/src/config.mjs | Local endpoint/bank/secret references, validation and destination identity |
| tools/hindsight-memory/src/capture.mjs | Message eligibility, provenance and one capture owner per session |
| tools/hindsight-memory/src/state.mjs | Transactional cursors, activation, admission and bounded queue state |
| tools/hindsight-memory/src/delivery.mjs | Direct recall, immutable requests, worker claims, retries and completion |
| tools/hindsight-memory/adapters/ | Minimal qualified hooks/plugins; separate OpenCode v1/v2 bridges |
| tools/hindsight-memory/test/ | Fake API, clocks, isolated homes, crash and adapter fixtures |
| profiles/hindsight-memory.toml; apps.toml | Optional cross-platform membership and explicit prerequisites |
| scripts/install/layer_memory.sh | Artifact preparation only, after agent/runtime installation |
| install.sh and relevant selection/status/guard helpers | Dispatch, additive safety, failure reporting and removal boundaries |
| docs/hindsight-memory.md; README.md; AGENTS.md | User workflow and ownership guidance |

Names and layout are proposals, not installed commands. An internal manifest
does not authorize npm publication, a separate repository or a new product.
Prepare a versioned user-local copy of the component, independent of checkout/CWD.
A proposed user command is hindsight-memory, subject to collision checks.
Do not use the former Nucleus capability names as existing interfaces.

Proposed local locations are ~/.config/hindsight-memory for explicit configuration,
~/.local/state/hindsight-memory for private state, and
~/.local/share/hindsight-memory/releases/<version> for immutable installed code.
Use resolved user-home/XDG paths on both platforms; no /home/fodurrr constants.
No state symlinks into a checkout. Credentials are named private-file references,
not command arguments, values in tracked templates or copied Hermes credentials.

The core is reusable without the Dotfiles installer. Its entry point must work
from an unrelated directory with Nucleus, Xpando and the source checkout absent.
Installing only selected agents plus the component must not provision a developer
profile or company tooling. A synthetic separate-user configuration verifies this;
it does not create Adam's account, bank or deployment.

Resolve and record a qualified runtime path for CLI, GUI, service and SSH contexts.
An absolute Node path may later be pruned by mise. Detect missing/replaced runtimes
and fail safely with a requalification instruction. Never fall back to arbitrary
PATH, Hermes Node or shell startup scripts. Updates must reconcile this explicitly.

### Preparation, activation and diagnostics

Preparation copies verified artifacts and reports readiness. It does not register
active capture, write memory, create banks or enable a service. Missing auth can
yield installed/activation-pending, never active. Read-only inspect/status must
not run repairs, retry jobs or write to memory as a side effect.

Activation is a separate approved action. It requires explicit endpoint, existing
bank, secret reference, selected adapters and capture preference. Record actual
UTC activation time, host identity, adapter, configuration revision and generation.
Policy agreement date 2026-10-17 is not an activation timestamp.

Activation preserves unrelated hooks/plugins/auth and requires native trust where
the host demands it. It does not weaken tool security settings or enable unknown
adapters. Updates preserve consent and cursors; new adapters need explicit selection.

Define a versioned machine-readable result with installed, configured, active,
unsupported/skipped, partial, failed and activation-pending states. Selected adapter
failure or failed activation has nonzero exit status. Intentionally skipped routes
are distinct. Safe diagnostics expose counts and reasons, never transcript or secret
values. A read-only doctor cannot claim completed capture merely from connectivity.

### Message boundaries and single-writer ownership

Capture only eligible new user/assistant conversation text. Exclude raw tool
results, hidden reasoning, login stores, secret files and injected recalled context.
Personal subjects remain unrestricted; repository context is optional provenance.
Assistant statements remain attributed claims, not verified user decisions.

Prefer current-turn native events. Transcript readers require an explicit session
registration and stable message boundary before capture. Clock time alone is
insufficient. Missing, dirty, truncated, forked or unknown cursors stop capture;
they never trigger whole-transcript replacement or historical scanning.

Default to fresh sessions where safe resumption cannot be proved. For supported
resumed sessions, establish the end-of-existing-transcript baseline first and prove
only later messages enter payloads. Recovery may read only the explicitly enrolled
session's eligible suffix; no bulk session scans or file/codebase ingestion.

Assign one capture owner per host/agent/session/activation generation.
Remote sessions capture on the execution host. T3 and its provider must select one
proven owner; ambiguous routes stay off. Repeated events and reconnects keep the
same stable message/chunk IDs. Streamed partial answers and cancelled turns need
explicit adapter policy; do not silently treat them as completed conversation.

Prefer immutable message/turn-chunk documents over replaying session transcripts.
Bind stable document and operation IDs to destination, host, agent, activation,
session, message and chunk identity. Snapshot normalized endpoint/bank and payload
with each job. Later configuration changes cannot redirect pending work.
A destination change creates a new explicit activation generation.

Disable the previous capture writer before activating its replacement.
For GEEKOM Hermes, account for existing pending obligations and in-flight work.
Its in-memory queue cannot be reconstructed by guessing or erased by overwriting.
A safe handover may require separately approved session shutdown/drain and a fresh
boundary. Preserve existing memories and private configuration ownership records.

### Durable admission and delivery

SQLite is the proposed local transactional store, not a memory database product.
Qualify durability, short lock timeouts and crash behavior on Linux and macOS.
Do not acknowledge acceptance until message identities, the entire turn's chunks,
capacity accounting and cursor advancement commit atomically. A rejected turn
advances no capture cursor. No partial chunk admission or silent truncation.

Durability starts after successful bridge admission. It cannot protect events
lost inside an agent before the bridge runs. Hermes has this known gap.
Require a synchronous admission point or proven new-only recovery before claiming
completed-turn coverage. Otherwise show the limitation and keep qualification open.

Persist immutable operation identity before sending. Retries use identical IDs
and bytes. Uncertain acknowledgement requires reconciliation of that operation,
not a fresh document or operation. Schema support does not prove exactly-once
server behavior; qualify it before live acceptance. Never replace old transcript
content to recover a failed operation.

Separate queued, submitted, completed, failed/quarantined and suspended states.
Submission acknowledgement is not completed extraction. Unknown or expired server
operations remain unresolved. Worker ownership differs from session capture ownership:
use crash-safe claims/fencing and test a paused old worker resuming after replacement.

One bounded worker per host wakes on events, agent startup or explicit retry.
Wake failure leaves accepted jobs durable and visibly pending. No network delivery
runs in the foreground capture path. Delivery while all agents are closed is not
guaranteed; a resident service would need a separate proposal and approval.

## Proposed performance and storage limits

These are starting limits for approval and measurement, not active settings or
performance claims. Carry the audit's limits forward; added bounds are labeled.

| Boundary | Proposed value | Failure behavior |
|---|---|---|
| Recall | One direct recall per user turn; 1,500 ms total deadline; at most 1,000 returned tokens | No automatic reflect; timeout continues agent work with a safe status |
| Recall response | 256 KiB maximum | Reject oversized responses without injection |
| Local validation and durable admission | 100 ms target excluding startup | Measure bridge/Node startup, locks, redaction and commit separately and together; report failed admission |
| Retention job | 64 KiB maximum | Stable chunk IDs for larger eligible turns; reserve all chunks before acceptance |
| Outstanding outbox | At most 1,000 jobs or 64 MiB, whichever comes first; failed/quarantined jobs count | Stop accepting capture visibly; preserve accepted jobs |
| Total mutable local state, added bound | Proposed 128 MiB including SQLite sidecars, receipts, logs and recovery metadata | Reserve transaction/recovery headroom; stop admission before capacity; prove actual disk behavior |
| Background HTTP request | 10 seconds, bounded by remaining worker lifetime | No foreground blocking; persist uncertainty |
| Retain attempts | At most 8 per job within 24 hours | Backoff starts at 5 seconds, exponential, capped at 15 minutes, jitter and bounded Retry-After |
| Completion polls, added bound | At most 24 status checks per job within 24 hours; backoff rather than tight polling | Exhaustion stays unresolved and visible |
| Worker wake | One worker per host, at most 60 seconds including child requests | Persist progress, release ownership, resume later |
| Expiry | Stop automatic attempts after 24 hours | No silent deletion; explicit retry/recovery or discard decision |

The 24-hour horizon is a maximum age, not a promise that eight quick retries span
a full day. Auth/schema errors stop retries immediately. Status polls have their
own counter and cannot extend job age or the 60-second wake bound. Offline and
queue-full behavior must remain useful during long outages; measure and revise
these proposed defaults if fixtures show excessive early exhaustion.

Count serialized jobs and queue metadata consistently. Bound completed receipts,
session watermarks, logs, snapshots and SQLite journals/WAL separately within the
total mutable-state budget; do not imply 64 MiB payload means 64 MiB physical disk.
Capacity rejection cannot delete queued work or essential duplicate evidence.
Compact completed content only when required watermarks remain. If a closed-session
watermark is removed, old-session events must remain rejected, never be reimported.

A finite queue cannot guarantee unlimited lossless capture during indefinite
outages. Preserve accepted jobs. Report later rejected turns as not captured.
Disk-full or slow-disk failures must never masquerade as accepted messages.
Reserve recovery space and qualify a bounded failure notice even when persistence
fails. The 100 ms target cannot override a truthful durable-acceptance result.

## Privacy, coexistence and rollback

Private directories use 0700 and files 0600. Reject unsafe ownership, symlinked
state and permissive paths. Test umasks 002, 022 and 077. Store credentials outside
Git and logs; validate references without printing values. No credentials in
process arguments or diagnostic error dumps. Do not assume shell exports reach
GUI or background contexts.

Redact known secret patterns before durable payload storage and network use.
Redaction is imperfect and cannot guarantee detecting every secret. This is not
permission to read secret files. Agent/user text may contain secrets; describe the
risk honestly. Keep raw excluded material out of diagnostics and local backups.

Recall is untrusted context, clearly labeled with provenance. It cannot override
current instructions, invoke tools or become new retained user text automatically.
Use direct recall, not automatic reflect. Do not alter bank extraction policy,
knowledge pages, native memory settings or model defaults.

Only allow the required recall/retain/operation APIs. No configureBank, seedPages,
Git ingest, surveys, history import, bulk document tools or unrestricted mutation
MCP surface is enabled implicitly. Existing fodurrr documents stay available.
Do not create, delete or rebuild banks.

Personal credentials and destinations remain separate from company-recall,
Frigg transport and the xpando bank. Company tools may use the personal integration
only through an explicit later connection; no automatic merge, replication,
fallback or credential sharing.

Rollback first stops new capture and delivery claims, then accounts for in-flight
requests before reporting suspension complete. Remove only owned hooks/files.
Compare current configuration against the owned write and refuse to overwrite
intervening edits. Preserve remote memories, queued jobs, activation records and
cursor evidence. Deactivation is not data deletion. Reactivation preserves the
cutoff; rollback across incompatible state schemas must fail safely.

## Installer integration and host boundaries

Keep existing profile membership unchanged. The optional profile contains the
local component and explicit Node prerequisite, not every agent or a full developer
environment. Detect installed and selected agents, including manual installations.
Do not install Hermes merely to add memory to another client.

Use one narrow cross-platform preparation type and scripts/install/layer_memory.sh
after mise and Linux extras. Do not route it through the codex-only curl fallback
or Linux-only script type. Dependency order must be explicit because existing mise
resolution traverses mise entries only. No Linux server, GUI or VPN additions.

The current generator truncates configuration to selected tools
(scripts/lib/mise.sh:358-407). The mise layer prunes even without --clean
(scripts/install/layer_mise.sh:80-110). All three active configs are linked there.
Before installer mutation, reject addon-only runs on configured hosts and any
memory selection that would drop existing runtime entries. Reject --clean with
memory preparation before removals. Preserve unrelated clean-mode semantics.
Do not introduce a broad configuration merger.

Support the new type in selection/status. Explicitly exclude unsupported extras
or a-la-carte removal rather than silently ignoring them. Never remove whichever
binary happens to resolve on PATH. Rollback belongs to the component's ownership
records, not package disappearance.

Use existing record_install_failure/run_install_step behavior. Independent later
steps continue; selected capability/adapter failures appear in final summary and
produce nonzero exit. Missing runtime, malformed status, partial preparation or
failed activation cannot be reported as active. Preparation without activation is
an honest installed/activation-pending state.

Installer logging copies output into repository-local install.log. Emit only
safe structured fields; .gitignore is not a secret-protection mechanism. Do not
Stow .codex, .claude, .pi, .hermes, .hindsight or component runtime state.

The existing base profiles may themselves select company launchers. The memory
component must not add those dependencies. Verify a minimal generic profile and
isolated user fixture with only selected agents and Node, outside any company repo.

## Implementation phases after renewed approval

1. Freeze the standalone interface, event schema, runtime/storage API subset and
   ownership records. Recheck exact upstream version and reuse only proven safe
   facilities. If the runtime grows beyond the proposed local client, return for
   a separately reusable-component scope decision rather than hiding new services.
2. Implement the component in isolated temporary homes with a fake API. Prove
   transactional admission, stable identity, privacy and bounded delivery before
   wiring any real host. No installation into the operator's home.
3. Qualify native adapters independently, including Pi versions, OpenCode v1/v2,
   Grok, Hermes completion, desktop trust and T3/provider ownership. Keep unresolved
   routes explicit; no hand-waving from CLI support to desktop support.
4. Add the optional profile, preparation layer, status handling and installer
   runtime-preservation guards. Add user documentation and rollback instructions.
5. Run component/adapter/installer checks, Bash 3.2 compatibility, docs drift,
   whitespace checks and required independent ExitGate. Repair supported findings.
   Do not import Nucleus's Genome/Mix/Dialyzer gates into Dotfiles.
6. Present the verified candidate, packaging and publication scope for approval.
   Plan-only pushes are authorized now; implementation publication, a package
   registry/repository, main merge and release need separate explicit approval.
7. Present a separate per-host rollout with exact commands, selected adapters,
   runtime paths, hook trust/session restarts and quota-consuming harmless memory
   checks. No server upgrade or network change is implied by compatibility failure.

## Acceptance suite

| Area | Required isolated evidence |
|---|---|
| Independence | Install/run the component in an isolated home outside any repo with Nucleus, company skills and the source checkout absent |
| Multiple users | Two synthetic local configurations use distinct banks/secret references; no default destination or credential sharing; no Adam deployment |
| Preparation | No active hooks, memory writes, bank creation or service activation |
| Boundaries | Fake-clock old/new/resumed/forked/truncated sessions, missing/corrupt cursors, duplicates and imported recall; forbidden old/Git/file sentinels never leave |
| Admission | Crash before/after each transaction boundary; all turn chunks and cursor commit together or not at all; oversized/full-queue turns rejected visibly |
| Delivery | Offline/restart/crash, same ID/bytes, lost acknowledgements, failed/expired operations, rate limits, auth/schema errors and bounded polls |
| Storage | Both job and byte limits, failed/quarantined accounting, SQLite sidecars, disk full, metadata/log caps, compaction and dedup preservation |
| Concurrency | Repeated hooks, one writer/session, one worker/host, stale worker after pause/replacement, cancellation and in-flight deactivation |
| Privacy | Redaction fixtures, secret references, malicious recalled instructions, ownership/symlink refusal, umasks 002/022/077, no sensitive log output |
| Coexistence | Existing hooks/plugins/roles/auth survive prepare, activation preview, update and rollback; intervening edits cause safe refusal |
| Runtime | Qualified Node API availability, startup overhead, missing/pruned/replaced runtime, GUI/SSH/service environment, no PATH fallback |
| Adapters | Actual supported event shapes and completed text; Hermes pre-admission crash gap; independent OpenCode v1/v2; truthful unsupported statuses |
| Installer | TOML/platform/profile union, explicit dependencies, manual agents, addon/clean guards, unknown/malformed/partial status and continuation/nonzero summary |
| Updates | Consent/cursor/outbox schema preservation, bank change isolation, no auto-update import/seed paths, rollback compatibility |

Use fake clocks and a fake API that asserts payloads and forbidden endpoints.
Do not run full upstream hooks to obtain fixtures if they can touch live state.
Measure prompt overhead and background completion separately.

After approved live rollout, test an agreed harmless new fact across hosts and
agents, personal conversations outside repositories, the old/resumed/Git sentinel
exclusions, remote/GUI execution and provenance. Such trials write memory and may
consume extraction/model quota. Fixture success cannot replace this live evidence.

Baseline Dotfiles syntax checks passed at 396d946 for install.sh and shared layers.
Previous plan checkpoints passed docs drift and git diff --check. New plan checks
must be rerun for this revision. The docs link scanner does not recurse into
docs/plans; inspect this item's links and JSON metadata separately.

## Author self-review and corrections

This is the Dotfiles author's self-review with read-only architecture advice.
It is not an independent ExitGate. The complete earlier Nucleus self-review stays
available at the immutable audit anchor.

| Weakness challenged | Correction in this proposal |
|---|---|
| Moving ownership could leave a hidden Nucleus dependency | Replace the entire design; no company runtime/client/skills; standalone acceptance test |
| Adam's example could authorize deployment or assume bank names isolate users | Synthetic portability test only; later server authorization check for any multi-user rollout |
| Upstream configuration alone could meet the requirements | Exact 0.8.1 behavior disproves it; propose a reusable local runtime explicitly for approval |
| Calling substantial code thin glue hides maintenance cost | Name component, modules, storage/runtime dependencies and separate publication boundary |
| An Elixir-first company design automatically fits Dotfiles | Prefer qualified Node LTS and native bridges; no imported company language/toolchain rule |
| SQLite import proves durability | Require transaction, crash, lock, disk-budget and platform tests; API remains release candidate |
| Durable queue alone protects every completed Hermes turn | Preserve the pre-admission crash gap as a qualification blocker |
| Cursor can advance before enqueue or some chunks can fit | Commit complete admission and cursor atomically after capacity reservation |
| Retrying with a new operation ID fixes uncertain acknowledgement | Keep immutable ID/bytes and reconcile; unknown completion remains unresolved |
| Retain retry count also bounds polls | Add 24-poll/24-hour bound; preserve worker and request deadlines |
| 64 MiB jobs means 64 MiB total disk | Add proposed 128 MiB total mutable-state budget and sidecar/receipt/log accounting |
| Finite storage can preserve unlimited history/dedup metadata | Visible admission stop; compact only with replay-safe watermarks and unknown-session refusal |
| Eight backoff attempts last a day | 24 hours is maximum age; disclose early exhaustion and measure long-outage behavior |
| Absolute Node path remains valid forever | Detect pruning/replacement and require requalification, never arbitrary fallback |
| A provider and T3 can each capture safely | One proven owner/session; ambiguous overlaps remain off |
| Hermes migration can overwrite existing settings | Explicit handover and pending-state accounting; preserve unknown past activation |
| Safe rollback only removes files | Stop admission/claims, reconcile in-flight requests, preserve queues/cursors and user edits |
| Additive profile implies safe runtime preservation | Guard generated-config replacement/pruning and refuse --clean with memory |
| Marking unsupported routes finishes coverage | Keep unresolved obligations and require explicit owner scope decisions |
| Prior approval permits this broader implementation | New approval required; only plan commit/push authorized now |

## Open decisions and approval request

Recommended architecture: the independently installable Node client component
described above, with tiny qualified native bridges and an existing Hindsight
server. The additional local runtime is the principal scope/cost decision.

Qualification gates remain open: exact Node/SQLite durability support; Hermes
complete-turn admission or safe recovery; Grok event compatibility; Codex desktop
trust and execution; T3 provider ownership; Gemini automatic capture; API operation
idempotency/completion; and actual measured startup/recall overhead.

If an existing upstream route cannot meet these checks, report the evidence.
Do not relax the capture boundary, add a resident service, change the server or
omit a required client silently. A larger reusable component, external package
or upstream change needs a concrete new proposal.

Requested next approval is repository implementation and isolated verification
of this standalone design. It would cover the component, adapter qualification,
installer integration, documentation, checks, local checkpoints and review
preparation. Any reviewer/provider spending remains subject to applicable approval.
No live writes, installation, main merge or package/implementation publication
are included in that request.

## Later host rollout

These are profile proposals, not commands to run now:

| Host | Checkout | Intended selection |
|---|---|---|
| GEEKOM | /home/fodurrr/dev/dotfiles | ./install.sh -p developer -p geekom-vpn -p hindsight-memory |
| Omen | /home/fodurrr/dev/dotfiles | ./install.sh -p omen -p hindsight-memory |
| Mini | /Users/fodurrr/dev/dotfiles | ./install.sh -p hacker -p hindsight-memory |

Review Mini's hacker delta and runtime ownership before rollout. Whole-profile
runs may refresh unrelated apps. Omen retains its approved bundle transport;
no remote or credential copying. On configured hosts, use a separately reviewed
component-only preparation path when prerequisites already exist instead of
assuming a full profile rerun is harmless.

Preserve existing fodurrr memories, auth/plugins/preferences, company isolation,
Tailscale and GEEKOM PIA routing. No server upgrade/recreation, backup changes,
credential rotation, reboot or Adam deployment. Main merge, host updates,
activation, required restarts and harmless live test messages need exact approval.

## Coordination state

- Dotfiles chat: 01a14b4d-fc38-73f1-b75b-692acceb85cc.
- Nucleus chat: 01a12fb1-16b4-7082-b244-f48a800ce904, title Read nucleus task file.
- Nucleus-release heartbeat wait-for-nucleus-memory-contract was deleted through
  automation_update on 2026-10-17. No replacement background implementation monitor
  is created while this revised design awaits approval.
- Send the exact committed replacement and task IDs to Nucleus for its transfer.
  Nucleus owns its Superseded disposition; this plan does not declare it closed.
- Next action belongs to Peter: approve the expanded isolated implementation or
  request revisions. Do not continue under the former consumer-only approval.
