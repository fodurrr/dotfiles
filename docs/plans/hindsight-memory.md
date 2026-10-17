# Standalone personal Hindsight memory

```work-item
{"current":"2026-10-17: Peter approved the 205,000-token ceiling. The unchanged Grok 4.7/high remediation review passed request validation and READY preflight, measured 202,497 estimated tokens, and is RUNNING against frozen a704108c175508a8d01cef26f17d83f45a3190da. No remediation verdict yet. Repairs are integrated locally at e8fbfef; 91 tests and independent acceptance pass. All native activation remains blocked; no publication, main merge or live rollout.","decisions":[{"date":"2026-10-17","decision":"Approve standalone component, adapters, installer safeguards, tests and review; publication, main merge and live rollout require separate approval. Measure the 100 ms target honestly.","id":"isolated-implementation-approved","owner":"Peter"},{"date":"2026-10-17","decision":"Approve a 200,000-token ceiling for exact Grok 4.7 review, supported fixes and local save. Publication, main merge and live rollout remain separate approvals.","id":"grok-packet-ceiling-approved","owner":"Peter"},{"date":"2026-10-17","decision":"Approve a 205,000 estimated-token ceiling for the same Grok 4.7 remediation review, local saving and Nucleus coordination. Publication, main merge and live rollout still require separate approval.","id":"grok-remediation-ceiling-approved","owner":"Peter"}],"deliverable":"An approved standalone design, then separately authorized implementation and isolated verification of a reusable client component, agent adapters and optional Dotfiles profile; publication and live rollout remain separate approvals.","evidence":[{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/*.test.mjs","repository":".","result":"pass; 91 tests, 0 failures","revision":"a704108c175508a8d01cef26f17d83f45a3190da","source_kind":"reproducible-check"},{"command":"cd tools/hindsight-memory && /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test test/review-remediation.test.mjs","repository":".","result":"pass; 18 tests, 0 failures","revision":"a704108c175508a8d01cef26f17d83f45a3190da","source_kind":"reproducible-check"}],"exit":["Peter approves the revised independent implementation before code changes.","Every transferred obligation has a verified outcome or explicit owner-approved scope disposition.","Standalone runtime and installer pass isolated tests with no company dependencies.","Required independent ExitGate passes before Completed; main merge and live actions retain separate approval."],"id":"hindsight-memory","inputs":[{"availability":"available","category":"objective","freshness":"Verified direct human approval in this Dotfiles chat on 2026-10-17; later scope supersedes prior planning-only authority.","locator":"Nucleus chat 01a12fb1-16b4-7082-b244-f48a800ce904, human turns 01a14b82-9c39-7312-a3d7-0851fef110d7 and 01a14b85-3143-7123-bba1-2067cb839287, verified through read_thread on 2026-10-17. Direct Dotfiles human instruction on 2026-10-17: approve isolated component, adapters, installer safeguards, tests and review; publication, main merge and live rollout remain separate.","owner":"Peter","required_at":"start","role":"Moves full ownership to Dotfiles and authorizes isolated implementation and review. The existing immutable audit remains evidence, not a runtime dependency.","source_kind":"instruction"},{"availability":"available","category":"evidence","owner":"Nucleus audit author","path":"plans/shared-personal-memory.md","repository":"/home/fodurrr/dev/xpando/nucleus","required_at":"start","revision":"40fe44ee7657cae6f8b436c4ea7b14610bf06e0c","role":"Complete immutable audit, artifact digest, findings, host matrix, limits, tests, self-review and unresolved obligations; ownership-specific architecture is superseded.","track":"committed"},{"availability":"available","category":"governing","owner":"Peter","path":"AGENTS.md","repository":".","required_at":"start","revision":"4c0a4d1d4248b1423e8675811b1a3726b00d2c24","role":"Dotfiles repository workflow, host boundaries, ownership and checks.","track":"committed"},{"availability":"available","category":"evidence","owner":"Dotfiles maintainer","path":"docs/plans/hindsight-memory.md","repository":".","required_at":"start","revision":"4c0a4d1d4248b1423e8675811b1a3726b00d2c24","role":"Previous plan and installer/host audit; Nucleus release gate and narrow implementation approval are superseded.","track":"committed"}],"inspection_triggers":[],"next":"Wait for the running Grok 4.7 remediation review. Validate the terminal result and save it locally with exact candidate and report evidence. Notify Nucleus. Stop after a passing verdict; a failing remediation or runner failure requires an explicit next decision under the review skill. Preserve native-caller, route, macOS, live-service and full ExitGate obligations.","objective":"Provide optional personal Hindsight memory for general macOS and Linux machine setup, independently of Nucleus, Xpando tooling and repository membership.","owner":"Peter","relationships":[],"risks":[{"detail":"Stock cursor replacement and whole-branch retention can upload history; missing state must fail closed.","id":"historical-capture","owner":"Dotfiles safe-capture task"},{"detail":"Installed/MCP/CLI presence does not establish desktop, T3, Gemini or Hermes completion coverage.","id":"support-claims","owner":"Dotfiles adapter-coverage task"},{"detail":"Finite storage and imperfect redaction need visible rejection, durable accepted jobs, permission checks and honest limits.","id":"secrets-and-queue","owner":"Dotfiles reliable-delivery and privacy-rollback tasks"},{"detail":"Preserve personal/company isolation, unrelated auth/hooks/settings, runtime ownership and network routes.","id":"ownership","owner":"Dotfiles privacy-rollback and installer-integration tasks"},{"detail":"A substantial reusable local runtime is proposed explicitly; do not hide it as installer glue or publish a product without approval.","id":"runtime-scope","owner":"Peter and Dotfiles standalone-runtime task"}],"schema_version":2,"scope":{"excluded":["Publication or push of implementation, main merge, host installation or live rollout without separate approval.","Nucleus or Xpando runtime dependencies, company-bank sharing, new provider abstraction or memory service.","Historical imports, Git ingestion, surveys, bulk files, secret files and hidden reasoning capture.","Unapproved package/product publication, new repository or resident service.","Server upgrade/recreation, backup changes, credential rotation, reboot, live memory writes or deployment to Adam."],"included":["Preserve all relevant Nucleus audit findings and unresolved obligations in this sole canonical plan.","Implement and verify the approved independently installable local Hindsight component, native adapters and optional Dotfiles profile in isolated fixtures.","Implement safe capture, durable bounded delivery, private state, ownership-aware preparation and rollback, and installer runtime-preservation guards.","Qualify supported routes and keep unresolved host/adapter coverage obligations explicit.","Measure local admission and whole-process startup; run tests, normal review and prepare the independent ExitGate; make local checkpoints."]},"state":"Active","tasks":[{"actor":"Dotfiles supervisor and Peter","depends_on":[],"done_when":"Peter approves a concrete independent runtime/adapter/installer scope; no old approval is reused.","id":"proposal-approval","result":"Peter explicitly approved isolated implementation, adapters, installer safeguards, tests and review in the Dotfiles chat on 2026-10-17. Publication, main merge and live rollout remain unapproved.","state":"completed","work":"Present and revise the standalone proposal, preserve the transfer, and obtain explicit approval of the expanded implementation."},{"actor":"Dotfiles implementation owner","depends_on":["proposal-approval"],"done_when":"Runtime works with company tooling and source checkouts absent; qualified Node/storage APIs, private installation and upgrade behavior are verified.","id":"standalone-runtime","result":"Implemented private standalone Node 24 component and owned installation; isolated tests pass. Final independent review remains pending.","state":"open","work":"Qualify upstream reuse and implement only the approved independently installable local component and versioned interface."},{"actor":"Dotfiles implementation owner","depends_on":["standalone-runtime"],"done_when":"Old/resumed/forked/corrupt-cursor sentinels never reach the API; accepted chunks and cursor advance atomically; unknown state stops capture.","id":"safe-capture","result":"Implemented atomic new-message admission, transcript prefix checks and staged turns. Codex recall provenance gap repaired; other native routes remain blocked.","state":"open","work":"Enforce activation and message boundaries, atomic admission, single-writer ownership and exclusion of historical/file/Git content."},{"actor":"Dotfiles implementation owner","depends_on":["standalone-runtime"],"done_when":"Crash/restart/capacity/uncertain-ack/stale-worker tests pass; accepted work persists within all documented budgets.","id":"reliable-delivery","result":"Implemented bounded immutable outbox and kernel-held worker ownership. Grok findings repaired: profile 429/5xx retry within eight-attempt/24-hour bounds; explicit recovery holds worker mutex through transaction. Independent real HTTP/SIGSTOP proves both recovery actions refuse unchanged beyond lease and succeed after release. No actual ENOSPC/power-loss/macOS/live-service proof.","state":"open","work":"Implement bounded durable admission, retry/poll accounting, stable operation identities and visible failure."},{"actor":"Dotfiles implementation owner","depends_on":["safe-capture","reliable-delivery"],"done_when":"Each route has explicit support evidence or an unresolved blocker; unsupported classification does not silently satisfy the coverage requirement.","id":"adapter-coverage","result":"All native production activation remains blocked pending actual invoking-client binding. Codex resume preserves original creator metadata, so per-event header checks are insufficient. Source/fixture adapters exist; Grok/Gemini/Hermes/Desktop/T3/Zed obligations also remain open.","state":"open","work":"Qualify each installed native agent, desktop/provider and remote route, including Hermes handover and pre-admission gaps."},{"actor":"Dotfiles implementation owner","depends_on":["standalone-runtime"],"done_when":"Permission, redaction, destination-isolation, pending-job, in-flight-delivery and intervening-edit tests pass without deleting memories or state.","id":"privacy-rollback","result":"Private state, redaction, ownership-aware rollback and literal-loopback-only HTTP implemented. Exact Node 24.22 parser confirms bracketed IPv6 is valid. Independent security review of repaired candidate a704108 found no residual defect in its three areas. Native caller binding and live qualification remain open.","state":"open","work":"Protect local secrets/state, safe diagnostics, untrusted recall, existing configuration and ownership-aware rollback."},{"actor":"Dotfiles implementation owner","depends_on":["standalone-runtime"],"done_when":"macOS/Linux profile and failure tests pass; preparation does not activate capture or require company tooling; addon/clean modes cannot prune unrelated runtimes.","id":"installer-integration","result":"Implemented optional profile and prepare-only layer, pre-bootstrap runtime-preservation guards and failure-safe status. Linux isolated fixtures pass; macOS host remains unqualified.","state":"open","work":"Add the optional profile, explicit prerequisites, safe preparation layer, status handling and runtime-preservation guards."},{"actor":"Dotfiles supervisor and independent reviewer","depends_on":["safe-capture","reliable-delivery","adapter-coverage","privacy-rollback","installer-integration"],"done_when":"Evidence identifies exact artifacts and tested versions; all accepted obligations pass or Peter explicitly changes scope; no live acceptance is inferred.","id":"verification-review","result":"Repaired candidate a704108 passes 18 focused and91 full tests; independent full suite 91/91 plus loopback/SIGSTOP checks pass. Initial Grok advisory DO-NOT-SHIP findings repaired. Remediation packet 202,497 exceeds approved 200,000 and is blocked before preflight/transfer. All native activation remains blocked; full ExitGate open.","state":"open","work":"Run isolated component/adapter/installer tests, repository checks, self-review and required independent ExitGate."},{"actor":"Peter and Dotfiles supervisor","depends_on":["verification-review"],"done_when":"Only separately approved actions execute; per-host activation and end-to-end evidence are recorded; no deployment to Adam is inferred.","id":"publication-rollout","state":"open","work":"Present exact publication/main/host-update/activation commands and quota-consuming checks for separate approval."}],"title":"Standalone personal Hindsight memory","verification":{"exit_passed":false,"status":"Initial exact Grok 4.7/high advisory review completed with valid DO-NOT-SHIP/FAIL at 26cb306: three findings. All supported defects repaired at a704108 and integrated as e8fbfef. Builder 18/18 focused and 91/91 full tests passed; independent acceptance 91/91 full tests plus real HTTP/SIGSTOP, transient-profile and IPv6 checks passed; independent security review found no residual defect in repaired areas. Remediation packet 202,497>approved 200,000 stopped before provider preflight/transfer, exit 4 packet_approval_required. No remediation verdict and no full ExitGate. Native activation remains blocked."}}
```


## Decision and approval boundary

Personal memory is an optional general computer setup capability owned fully by
Dotfiles. It must work without Nucleus, Xpando AI Layer, company repositories,
company skills, Erlang or Elixir. Hindsight remains the external memory service.

Peter moved ownership fully to Dotfiles in the Nucleus chat on 2026-10-17.
On 2026-10-17, he explicitly approved isolated implementation of the revised
standalone component, adapters, installer safeguards, tests and review in the
Dotfiles chat. This new approval replaces the earlier consumer-only boundary.
The old released-Nucleus-contract gate is removed.

Authorized work includes repository code, isolated tests, local commits and
review preparation. Tests use temporary homes and a fake API. Publication,
push, main merge, host update, installation, activation, restart and live memory
writes still require explicit approval. No deployment to Adam is authorized.

Peter questioned whether the 100 ms local admission target is achievable.
Measure durable admission and the entire command, including startup, separately.
Report actual distributions and failure conditions; do not weaken durability to
meet that target or present it as an achieved guarantee.

Endpoint, bank, user identity and secret references are local choices.
Peter's intended destination remains the existing Mini server and bank fodurrr.
A different user must supply an explicit separate configuration. Creating a bank
or server is not implicit in preparation. Bank names are not access control;
any later multi-user deployment must verify server-side authorization.

This remains the sole canonical work item, listed in docs/PLAN.md. Its portable
JSON block records obligation transfer and implementation progress. The work is
Active under Peter's approval. This documentation creates no Nucleus runtime,
company tooling or machine configuration dependency.

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

Peter approved the standalone runtime, adapter qualification, installer safeguards,
isolated tests and review on 2026-10-17. Implementation is proceeding locally.
The 100 ms admission target must be measured, not enforced at the expense of
durability. Native adapter startup and full command startup are separate measures.

Qualification gates remain open: exact Node/SQLite durability support; Hermes
complete-turn admission or safe recovery; Grok event compatibility; Codex desktop
trust and execution; T3 provider ownership; Gemini automatic capture; API operation
idempotency/completion; and actual measured startup/recall overhead.

If an existing upstream route cannot meet these checks, report the evidence.
Do not relax the capture boundary, add a resident service, change the server or
omit a required client silently. Any broader component or upstream change needs
a concrete new proposal. Unsupported routes remain open obligations.

The approved independent readiness review is separate from native specialist review.
It uses purpose review because full coverage remains open. A full ExitGate is
still required before this work item can become Completed.
Peter's explicit approval includes the required review described in the execution
preview. Its inspected matrix orders xAI Grok 4.7 then Anthropic Opus 5.5 for
OpenAI-authored work. Use that existing approval within the standard packet and
attempt bounds; do not request the same review approval again. Validate the exact
candidate and review request before dispatch. No independent request has run yet.

Publication, push, main merge, host installation, activation and live memory writes
remain outside this implementation approval.

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
- Nucleus verified committed successor e7977cfa85034f947412a1b25d440334a0c6fc28.
  Its agent confirmed Superseded closure 4281c73fe9f50f277a171542adfeda8f6a107d27
  was pushed after its closure gates passed. Transfer evidence anchor:
  1a73d74467008abc703eca4e9353cf23c31de58f. The original audit remains reachable.
- Nucleus-release heartbeat wait-for-nucleus-memory-contract was deleted through
  automation_update on 2026-10-17. No Nucleus runtime contract wait remains.
- Peter approved isolated implementation in this chat on 2026-10-17. Nucleus was
  notified of approval, timing qualification and subsequent test findings.
- Continue isolated implementation and checks. Keep Nucleus informed of material
  findings. Publication, main merge and live rollout require separate approval.

## Isolated implementation checkpoint

Isolated implementation is approved and implemented locally on codex/hindsight-memory.
This section supersedes planning-only status and future-tense implementation claims below.
The full work item remains Active. No route obligation is waived.

The component provides a private SQLite outbox, atomic cursor/message admission,
immutable request IDs and bytes, bounded retry/poll accounting, conservative state
limits, read-only diagnostics, explicit recovery, and ownership-aware preparation.
Kernel-held worker and recall mutexes prevent timer expiry from proving a paused
process has stopped. Deactivation fences late recall and later delivery claims.

The optional profile prepares artifacts through the existing mise runtime owner.
Selection guards precede bootstrap and refuse runtime loss, unsafe memory-only
selection on configured hosts, and memory plus cleanup. Preparation does not
activate hooks, contact a memory server, or add company tooling.

All native adapter activation is refused pending actual caller binding.
Source/fixture implementations exist for Codex CLI 0.162.0/0.163.0, Claude, Pi and
OpenCode. Codex headers identify the original creator; resumed sessions preserve
them. Per-event header validation therefore cannot prove the current invoker.
Grok, Gemini, Hermes, desktop, T3 and Zed also remain unresolved coverage
obligations. Blocked activation is not completed coverage. No actual installed
agent, macOS host or live bank was tested.

Native specialist review found and repaired schema mutation before refusal,
reactivation queue loss, late recall after suspension, unsafe filesystem paths,
interrupted installation ownership, active configuration mutation, hook update
duplication, stale-worker timer assumptions, missing recall route checks, and
missing safe operation identifiers for explicit recovery. A later full-bridge test found normal SQLite contention; final fixes and
measurements follow below. Native caller binding remains an unresolved obligation.
Final revision checks and independent provider review follow below.

The 100 ms admission target is measured, not guaranteed. Initial /tmp timings
used tmpfs. Disk-backed /var/tmp and full native bridge timing are reported
separately. Filesystem sync tests cannot establish power-loss or macOS behavior.
A bank-profile check proves existence only at that instant. Preventing lazy
creation after concurrent deletion still needs server-side permission or atomic
API qualification; no server change is authorized.

Independent review uses purpose review for isolated implementation readiness.
It does not replace the full work-item ExitGate or close remaining obligations.
Publication, push, main merge and live rollout still require explicit approval.

## Isolated verification evidence

Code candidate: 704c7bb628b2c24bdca53d48fd34b7e26c2b82c8 in /home/fodurrr/dev/dotfiles.
Checks below ran on 2026-10-17. No CI run exists. These are local author and
independent-agent attestations; raw output stays outside Git.

| Check | Command | Result |
|---|---|---|
| Component suite, build owner | /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/*.test.mjs | PASS, 72 tests |
| Installer isolated homes and fake runtimes | bash scripts/test-memory-installer.sh | PASS, all isolated checks |
| Linux installer validation | bash scripts/test-linux.sh | PASS, zero failures |
| Shared shell syntax | bash -n install.sh; for script in scripts/install/*.sh scripts/lib/*.sh; do bash -n "$script" || break; done | PASS on installed Bash; not execution under Bash 3.2 |
| Documentation and read-only discovery | bash scripts/docs/check-doc-drift.sh | PASS |
| Whitespace | git diff --check | PASS |
| Native security review | Read-only specialist review of exact code candidate | Earlier fixes verified, then Codex caller provenance reopened; all activation now blocked pending qualification |

Tracked tests include SIGKILL before/after durable commit, atomic capacity refusal,
SQLite page exhaustion, Linux child file-size exhaustion, stable retry bytes after
lost acknowledgement, loopback redirects, history/privacy sentinels, ownership
interruption, runtime changes, and native route guards. SIGSTOP proves the worker
mutex remains held, using stub transport. Independent acceptance additionally paused worker and recall children after a
real loopback HTTP server received their bodies. With a simulated clock beyond
the lease, replacement sent no extra requests and deactivation remained pending.
SIGCONT drained the children; late recall returned no context. This did not wait
for real wall-clock lease expiry and did not contact a live service. No macOS, actual ENOSPC, power-loss or real
installed-agent execution is implied. No live Hindsight requests occurred.

Build-owner disk-backed /var/tmp benchmark: Node 24.22.0, filesystem type 0xef53,
30 samples. Durable admission p95 10.058 ms, maximum 10.129 ms. Separate Node
startup/Store/register/capture/exit p95 60.110 ms, maximum 60.301 ms.
This module harness is not the full native bridge. Earlier /tmp results used tmpfs.
The independent full-bridge measurement and provider review follow separately.

The later full source-hook benchmark found SQLite contention at the same code
candidate: 30 attempts, 23 successes, 7 visible rejections. It included all attempts:
p50 124.607 ms, p95 168.596 ms, maximum 177.729 ms. Each synthetic turn contained
5,100 UTF-8 bytes, through two Node processes on disk-backed /var/tmp, with a growing
transcript and normal worker wakes. Later suffix capture admitted all 60 messages;
rejected attempts were never acknowledged as durable acceptance. An earlier
aborted diagnostic did not retain its attempt count and is not a statistical result.

The correction removes repeated schema writes on existing-state opens and permits
500 ms bounded SQLite waiting. FULL durability remains. A 150 ms exclusive hold
must succeed; a one-second hold must reject atomically with a safe busy reason.
The 100 ms value is a measurement target, never a reason to weaken durability.
Final exact-revision results supersede the failed benchmark below.

## Corrected isolated candidate

Code candidate: 682a519cc91e5e990f01f0501cf694b30102f193. All implementation
commits remain local on codex/hindsight-memory. No CI run exists.

Build-owner check: /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node
--disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/*.test.mjs
passed 73 tests, including disk-backed concurrent 30-turn capture with 60 completed
jobs and zero rejections. Shared shell syntax, documentation drift and whitespace
checks passed after the fix. Installer/Linux checks at704c7bb remain applicable;
no installer code changed afterward.

The correction removes DDL and metadata writes on existing database opens.
SQLite waits at most 500 ms for a lock; FULL synchronization remains.
A 150 ms exclusive lock test succeeds. A one-second lock test refuses atomically
without cursor advancement. Safe busy diagnostics distinguish rejected admission.

The native caller finding is contained by refusing every production activation
with native-caller-binding-unqualified. It is not solved or waived.
Pinned Codex source83086188ae0614bd882818ff1aa23f3194962012 shows resume uses
RolloutRecorderParams::resume at codex-rs/thread-store/src/local/live_writer.rs:117;
recorder.rs:994 opens append with meta:None, while create at948 sets source/version.
The header writer at1893 emits nothing for absent metadata. An old CLI header
therefore cannot attest the current caller. Future activation needs a verified
current-caller contract; process history or creator metadata is insufficient.

Tracked disk stress: 30 attempts, 30 accepted, zero rejected, 60 completed jobs.
Whole source-hook timing: p50 100.751 ms, p95 484.436 ms, maximum 585.430 ms.
This suite also ran the artificial disk-lock regression in parallel.
The independent source-hook benchmark has separate measurements and load below.
Both use explicit manual temporary fixture wiring after asserting production
activation refusal. Neither executes or certifies an installed native agent.

The reusable source-fixture benchmark is tools/hindsight-memory/test/benchmark-native.mjs.
The 100 ms target applies to local admission measurement, not a guaranteed hook
deadline. Whole-hook startup and lock waiting exceed it. No durability is sacrificed.

Independent advisory review remains pending. This is not the full-item ExitGate.
All route, macOS, live API and publication obligations remain open.

Independent acceptance checked the exact final code682a519cc91e5e990f01f0501cf694b30102f193.
Command: /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node
--disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/*.test.mjs.
Result: PASS,73/73tests in11.55seconds. No CI run exists.

Command: TMPDIR=/var/tmp /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node
--disable-warning=ExperimentalWarning tools/hindsight-memory/test/benchmark-native.mjs.
Result: PASS,30attempts,30accepted,zero rejected,60jobs. Full source-hook latency
including both Node processes: p50 115.248ms,p95 275.227ms,maximum318.094ms.
This used ext4 on NVMe,5,100UTF-8bytes per synthetic turn,a growing30-turn
transcript and normal background delivery. Production activation refusal was
asserted before explicit manual temporary fixture wiring. All workers drained,
server closed and temporary home removed. This is not installed-agent acceptance.
The earlier module admission benchmark and stress distributions have different
measurement boundaries; do not combine them or claim a100ms whole-hook guarantee.

## Independent review authorization blocker

Frozen review candidate: 26cb3061761453041e06c46c9e3f05e6591bbf80.
Implementation code: 682a519cc91e5e990f01f0501cf694b30102f193.
The later plan-only checkpoint records this result; it does not change implementation.

The approved advisory review was structurally validated, then stopped before any
provider probe or transfer. Result class: packet_approval_required; exit status 4.
No reviewer was selected, no attempt was consumed, and no verdict exists.
Retained report: .opencode/adversarial-review-reports/20261017T210848Z-1246115-9730.md.
It is private and ignored by Git. Request inputs are preserved privately under
.opencode/adversarial-review-reports/requests/hindsight-memory-26cb306/.
No raw test output is committed.

The assembled packet is 568,625 bytes, estimated at 191,544 tokens including a 2,000-token reserve.
Default authorization ceiling: 128,000 estimated tokens. Packet fingerprint:
081a48055387066aaa0a22d5d3eec1170db608aa4d144de0abc50541e29c997e.
The configured first reviewer is xAI Grok 4.7, runner grok, CLI model grok-4.7,
reasoning high, via Grok Build CLI. Effective route capacity is unknown; the
runner's dated evidence is 2026-10-14. Neither the estimate nor model capacity
facts guarantee usable route capacity. No provider switch is justified.

The skill requires explicit approval of a larger packet and exact reviewer.
Proposed ceiling: 200,000 estimated packet tokens, exact reviewer grok/grok-4.7 high.
This is additional spending authorization, not repeat authorization of normal review.
After approval, preserve the frozen candidate in a managed isolated worktree,
validate the same rubric/envelope/context with explicit runner/model and approved
ceiling, remeasure, then run the review. Stop if it exceeds the ceiling or fails.
Fix registered supported defects and use the single permitted remediation review
within its separately measured ceiling. A further review or ceiling increase
requires approval. Keep the full work item Active; no scope waiver or ExitGate.

All 73 component tests and final 30/30 source-fixture capture checks pass.
Full-hook p50: 115.248 ms; p95: 275.227 ms; maximum: 318.094 ms. All production native activation
remains blocked pending actual caller binding. No publication, main merge,
live installation, configuration or memory writes occurred.

## Approved Grok review

Peter approved the 200,000-token ceiling for the exact Grok 4.7 review on 2026-10-17.
He authorized supported fixes and saving results. Publication, main merge and live
rollout still require separate approval.

The frozen candidate remains 26cb3061761453041e06c46c9e3f05e6591bbf80.
A managed isolated review worktree holds that exact commit. The primary checkout
keeps the later canonical-plan checkpoint. No implementation drift was introduced.

The exact request passed --validate-request before background dispatch.
Reviewer: xAI Grok 4.7, runner grok, CLI model grok-4.7, reasoning high.
Explicit selection permits no fallback. Purpose: advisory review, not ExitGate.
The remeasured packet is 191,603 estimated tokens, within the approved ceiling.
Effective route capacity remains unknown. The review is pending; no verdict exists.

Live report:
/home/fodurrr/dev/xpando/.worktrees/codex/memory-grok-review/dotfiles/.opencode/adversarial-review-reports/20261017T213330Z-1469261-21506.md.
Request inputs remain preserved privately under
.opencode/adversarial-review-reports/requests/hindsight-memory-26cb306/.

Keep the implementation frozen during review. After a valid verdict, assess all
findings, fix supported defects, verify the repairs, and use the one permitted
remediation review within the approved ceiling. Do not reinterpret a runner
failure as a verdict or silently retry it. All route obligations remain open.

## Grok launcher interruption and retry boundary

Peter approved the 200,000-token ceiling and exact Grok 4.7 review on 2026-10-17.
The request passed validation. The packet measured 191,603 estimated tokens.
The code and frozen candidate remained unchanged.

The launch did not complete. Both reported processes disappeared during preflight:
launcher PID1469254 and reviewer PID1469261. The launcher log stops at the capacity
assessment. No exit-status file, accepted verdict or lineage snapshot exists.
The report remains PREFLIGHT with result class pending and outbound transfer
not started. This is an observed launcher interruption, not a review finding,
provider context rejection or accepted terminal result class. An availability
probe may have started; repository transfer is not recorded as started.

Preserved report, copied byte-for-byte into the primary checkout:
.opencode/adversarial-review-reports/20261017T213330Z-1469261-21506.md.
Its launcher log is retained privately alongside it. Both are ignored by Git.
The original worktree report remains available for investigation.
No independent review attempt was consumed and no supported findings were returned.

A local non-provider reproduction used two identical eight-second marker jobs.
Plain nohup disappeared without writing its marker. The same command with
Python start_new_session=True completed its marker. No installed configuration,
provider request, service or runtime was changed. The packaged Linux launcher
uses nohup without a separate process session. This explains the observed host
lifecycle failure; Nucleus was sent the exact evidence for its launcher owner.

Proposed retry uses the unchanged skill launcher with --background inside a
separate OS session. It keeps exact Grok 4.7/high selection, the 200,000-token
ceiling, preserved rubric/envelope/context, frozen26cb306 candidate and mandatory
request validation. No fallback or plugin installation is proposed.
The skill says runner failures must not be silently relaunched. One operator
retry decision is therefore required; the larger-packet approval remains valid.

Implementation remains682a519, with73 passing tests and30/30 disk-backed source-hook
captures. All production adapter activation remains blocked pending current-caller
binding. No publication, main merge, live rollout or live memory writes occurred.

## Nucleus confirmation of launcher diagnosis

On 2026-10-17, the Nucleus agent reported its completed read-only diagnosis in
chat01a12fb1-16b4-7082-b244-f48a800ce904. It confirmed that the installed0.6.97
launcher and canonical Nucleus launcher have identical bytes, SHA-256:
cf139a788f1dbc0d3646a98301cc18ce3eaf5ebee24e557f80f46fb0a0d7ffc1.
This is Nucleus's source-level attestation; Dotfiles separately reproduced the
host-lifetime behavior with harmless local marker jobs.

Linux uses plain nohup without a new OS session. Its child EXIT trap should write
an exit-status file. Missing processes and status fit abrupt termination.
Existing launcher tests keep their outer ExUnit host alive and do not cover
survival after the outer command host returns. No matching OOM entry appeared in
Nucleus's bounded accessible journal inspection; the exact signal remains unknown.

Probe results are recorded only after probe_reviewer returns. Therefore the stale
PREFLIGHT report does not prove that a small READY request never began. No completed
probe, full packet transfer or accepted verdict is recorded. Preserve that distinction.

Nucleus supports the proposed separate-session wrapper around the unchanged
--background launcher, using the exact frozen candidate, Grok4.7/high and approved
200,000-token ceiling. No retry, plugin edit or new implementation lane occurred.
A permanent launcher correction needs host-lifetime regression coverage in its
own tooling work. It does not reopen Nucleus's closed personal-memory ownership.
The review retry still requires the operator decision already requested.

## Approved separate-session review retry

Peter explicitly approved the proposed separate-session retry on 2026-10-17.
The existing 200,000-token ceiling, exact Grok4.7/high selection, frozen26cb306
candidate, rubric, envelope and context remain unchanged.

The same request passed --validate-request again. Python subprocess.run with
start_new_session=True then invoked the unchanged skill's --background route.
The launcher and reviewer survived outer command return in a separate OS session.
The READY probe completed and the report entered RUNNING with Grok CLI1.0.62,
xAI modelgrok-4.7, reasoninghigh. This confirms the workaround for this run;
no plugin installation, configuration edit or permanent launcher change occurred.

Current report:
/home/fodurrr/dev/xpando/.worktrees/codex/memory-grok-review/dotfiles/.opencode/adversarial-review-reports/20261017T213947Z-1626528-2.md.
Review series:565eb0f625aed89d9bf4cc8ed66170614b8bd6163ad029bdfab45fbaeaad1ec2.
The previous interrupted report remains preserved separately. No verdict yet.
Nucleus received the successful launch evidence. Publication, main merge and
live rollout remain outside authorization.

## Grok findings repaired; remediation packet approval pending

The approved separate-session retry completed against frozen candidate
26cb3061761453041e06c46c9e3f05e6591bbf80. Grok 4.7/high returned a valid
DO-NOT-SHIP advisory verdict, gate FAIL, with three findings. This was a normal
review, not the full work-item ExitGate.

| Finding | Supported repair and evidence |
|---|---|
| Transient bank-profile failures (FIND-001, P2) | HTTP 429 and 500–599 now preserve queued work within eight-attempt and 24-hour limits. Matching HTTP 200 and bank identity remain mandatory before retain. Retry-After stays bounded. Auth, missing-bank and malformed-schema failures remain terminal. |
| Recovery while a worker is paused (FIND-002, P2) | Both recovery actions acquire the real worker mutex before the state transaction and hold it through commit or refusal. Expired lease metadata cannot bypass process ownership. |
| HTTP named localhost (FIND-003, P3) | Named hosts require HTTPS. HTTP allows literal IPv4 and IPv6 loopback only. The reviewer’s IPv6 parenthetical was incorrect: Node 24.22.0 returns hostname `[::1]`, including brackets. That existing behavior is retained. |

Repair commit: a704108c175508a8d01cef26f17d83f45a3190da on
codex/hindsight-review-fixes. Local integration commit:
e8fbfef88a2bda95b5a73ab0f494303fb33f15ba on codex/hindsight-memory.
Component and user-documentation contents are identical between these revisions.
The isolated review checkout remains frozen for the remediation series.

Builder checks passed: 18 focused regression tests, 91 full component tests,
JavaScript syntax, documentation drift and whitespace checks. Independent
acceptance reran the full suite: 91 tests, 0 failures, under Node 24.22.0.
Independent security review found no residual defect in the three repair areas.
No CI execution is claimed.

Independent temporary loopback fixtures verified HTTP 429/500/503 recovery,
identical retained bytes, no POST before bank confirmation, terminal auth/schema
failures, eight-attempt exhaustion and an actual IPv6 loopback request.
Real HTTP body receipt followed by SIGSTOP proved both recovery actions refuse
with the complete job row unchanged after simulated lease expiry. Both actions
succeed after process death and after separate graceful release. Operation ID,
body and byte count remain unchanged; refusal generated zero extra requests.
The clock advanced from 1000 to 100000 in both parent and child. This was not a
70-second wall-clock wait. Fixtures and child processes were cleaned up.

The original retained report and lineage are saved privately under
.opencode/adversarial-review-reports/20261017T213947Z-1626528-2.md and its
.lineage.json sibling. Original report SHA-256:
785a683139a4313b19ba74f47ca01747a8bd8de5cbb94c56620ed012e80a1530.
The same files remain in the isolated memory-grok-review worktree. Raw test
output is not committed.

The accepted remediation matrix declares every changed path and all three
finding IDs. The exact request passed --validate-request with the unchanged
rubric, envelope, horizon base, Grok 4.7 runner and high reasoning. The actual
launch stopped as packet_approval_required, exit 4, before provider preflight
or outbound transfer. No remediation attempt or verdict was consumed.

| Packet gate | Observed value |
|---|---|
| Packet size | 601,482 bytes |
| Estimated tokens, including reserve | 202,497 |
| Approved ceiling | 200,000 |
| Proposed ceiling for explicit approval | 205,000 |
| Effective Grok Build CLI capacity | Unknown; READY and advertised model limits do not prove this route’s capacity |
| Provider probe and repository transfer | Not started |

The blocked report is retained privately as
.opencode/adversarial-review-reports/20261017T220727Z-1927802-18306.md.
The request files remain under
.opencode/adversarial-review-reports/requests/hindsight-memory-26cb306/,
including remediation-a704108.json. Do not alter the frozen rubric, shrink the
packet, switch reviewer or raise the ceiling without approval. After approval,
validate the same request again and use the approved separate-session wrapper
around the native background launcher. One remediation review remains available.

Nucleus received the review findings, repair revision, independent checks and
packet-limit blocker. Its separate generic launcher repair does not change
personal-memory ownership or authorize installed plugin changes here.

All native production activation remains blocked pending current-caller binding.
Full route coverage, macOS, live service behavior and the full ExitGate remain
open. No new performance benchmark was needed for these background-delivery,
recovery and endpoint-validation repairs. The previously measured disk-backed
whole-bridge p95 remains 275.227 ms, above the 100 ms target.
No publication, push, main merge, installation, activation or live memory write
occurred. Those approvals remain separate. The canonical work item stays Active.
