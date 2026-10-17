# Optional Hindsight memory through Nucleus

## Current state and authority

- Owner: Peter.
- Status: approved plan; waiting for Nucleus's released contract.
- Approval date: 2026-10-17, Europe/London.
- Implementation: not started. No live activation or memory writes authorized.
- Working branch: `codex/hindsight-memory`, from `main` at
  `396d946550a153f5297bcf0c7f0b603937bb9965`.
- Next action: obtain and inspect Nucleus's released integration contract.
  Do not implement against a proposed, guessed or generic AI Layer interface.

This is the canonical Dotfiles work item. The vault handoff is an input, not
a second ongoing plan. Dotfiles has no existing Genome binding or work-item
schema; this item follows AGENTS.md and keeps implementation planning in docs.

Peter approved the revised plan in the Dotfiles chat on 2026-10-17:

> Approve the plan. Save it as the canonical Dotfiles work item, then wait for
> Nucleus’s released contract. Do not implement against a guessed interface.
> Main merge and live rollout still need my approval.

Peter also explicitly authorized coordination with the existing Nucleus chat.
The approved repository scope covers implementation after the contract gate,
verification, review, and feature-branch commit/push. Main merge/push, host
checkout updates, installation, activation and live rollout need separate approval.
Nucleus implementation and publication are owned and authorized separately.

## Objective and ownership

Add an optional, composable `hindsight-memory` profile for macOS and Linux.
Dotfiles prepares prerequisites and invokes Nucleus's released capability.
Profile installation prepares artifacts; explicit activation remains separate.

Nucleus owns agent discovery, adapters, hook/plugin coexistence, configuration,
secret loading, capture filtering, cursors, recall, retention, queues, diagnostics
and ownership-aware rollback. Do not duplicate those functions in Dotfiles.
Nucleus must include supported manually installed agents in its discovery.
Dotfiles must not install every agent merely because memory is selected.

Use the existing Mini server and personal bank `fodurrr` through explicit local
configuration. Preserve existing memories. Never make Peter's endpoint, bank or
capture choice unconditional defaults for other Dotfiles users.

Preserve company-recall and its isolated `xpando` bank on Frigg. Preserve agent
authentication, plugins, personal settings, Tailscale and GEEKOM PIA routing.
No new server, server upgrade/recreation, backup-policy change, credential
rotation, reboot or agent restart is included.

## Sources and inspected baseline

Primary input, read completely on 2026-10-17:
`/home/fodurrr/dev/xpando/xpando-notes-vault/Research/Hindsight Shared Memory/Dotfiles Handoff.md`.
The sibling `Nucleus Handoff.md` was also read completely.

Repository sources at `396d946550a153f5297bcf0c7f0b603937bb9965`:

- `AGENTS.md`: ownership, Git workflow, host boundaries and checks.
- `README.md`; `profiles/developer.toml`, `profiles/geekom-vpn.toml`,
  `profiles/omen.toml`, `profiles/hacker.toml`; `apps.toml`.
- `install.sh:127-148`: installation order and guarded steps.
- `scripts/lib/app_config.sh:67-165`: validation and profile union.
- `scripts/lib/mise.sh:209-235,324-407`: dependency handling and config replacement.
- `scripts/install/layer_mise.sh:80-110`: unconditional pruning and clean removal.
- `scripts/install/layer_curl.sh`: codex-xpando-specific launcher handling.
- `scripts/install/layer_linux_extra.sh`: Linux-only script installer behavior.
- `scripts/lib/app_state.sh`, `scripts/install/list_installed.sh`,
  `scripts/install/extras.sh`, `scripts/install/alacarte.sh`: lifecycle dispatch.
- `scripts/lib/summary.sh:70-94`; `scripts/install/summary.sh:182-189`:
  failure continuation and final nonzero exit.
- `scripts/install/logging.sh`: output is copied into repository-local install.log.
- `docs/profile-system.md`, `docs/linux-support.md`, `docs/stow-policy.md`,
  `docs/geekom-pia.md`: platform, state and network constraints.

Nucleus dependency sources inspected on 2026-10-17:

- `/home/fodurrr/dev/xpando/nucleus/plans/shared-personal-memory.md`:
  queued work; released Dotfiles contract required at lines 240-243.
- `/home/fodurrr/dev/xpando/nucleus/distribution/manifest.yml`: AI Layer 0.6.97,
  private-unpublished; no personal-memory setup capability identified.
- `/home/fodurrr/dev/xpando/nucleus/lib/nucleus/agent_core/hindsight_client.ex`:
  retain/poll/bank client with company defaults, not this integration.
- Generic distribution update/doctor/rollback are not personal-memory interfaces.

Host observations are dated acceptance inputs, not a maintained machine inventory.
Machine inventory remains owned by the infrastructure notes vault. Recheck these
facts before rollout; do not update hosts merely to refresh this table.

| Host | Verified checkout and profile evidence | Integration evidence |
|---|---|---|
| GEEKOM | Ubuntu 26.04.1; `/home/fodurrr/dev/dotfiles`; clean main at `396d946`; fetched origin/main equal; developer plus optional geekom-vpn | Hermes plugin 1.2.1 configured for Mini and fodurrr; recall/retain/async enabled |
| Omen | Ubuntu 26.04.1; same checkout path and commit; clean main; no remote; install.log records omen | Shared coding-agent config and Hermes Hindsight plugin absent; T3 service exists |
| Mini | macOS 26.6.2; `/Users/fodurrr/dev/dotfiles`; clean main at `d50da8f9cd55088ee8ef85e9fb1e035f9d06417b`, six commits behind GEEKOM; last install.log records hacker | Shared coding-agent config and Hermes Hindsight plugin absent |

All three hosts link their active mise config to the generated Dotfiles config.
Mini's Claude launcher points to vendor 2.1.302 despite mise recording 2.1.295.
Its Node launcher resolves to Hermes Node 26.8.2; mise records Node 24.21.0.
Do not automatically resolve these ownership differences during memory setup.

GEEKOM and Omen could reach Mini's HTTPS health endpoint. Health reported a
connected database; the version endpoint reported API 0.9.2. Authenticated bank
stats, capture completion and cross-agent recall were not retested.

## Support matrix and qualification

Installed versions and upstream support are not proof of working automatic memory.
No route has end-to-end acceptance under this work item yet.

| Route | GEEKOM | Omen | Mini | Qualification |
|---|---|---|---|---|
| Claude Code | 2.1.302 | 2.1.302 | Vendor 2.1.302; mise 2.1.295 also present | Upstream route documented; local capture unverified |
| Codex CLI | 0.163.0 | 0.163.0 | 0.162.0 | Upstream route documented; local capture unverified |
| Pi | 1.3.0 | 1.3.0 | 1.1.0 | Upstream route documented; local capture unverified |
| OpenCode CLI | 2.0.32 | 2.0.32 | 1.18.35 | Qualify both major versions separately |
| Grok CLI | 1.0.62 | 1.0.62 | 1.0.50 | xAI CLI identified; exact adapter compatibility unverified |
| Hermes | Hindsight 1.2.1 configured | Plugin absent | Plugin absent | Existing configuration is not cutoff/completion proof |
| Gemini CLI | 0.64.0 | 0.64.0 | 0.63.0 | No verified automatic adapter; activation unavailable until proven |
| Codex desktop / ChatGPT app | Installed | Desktop not assessed | ChatGPT app installed | Qualify separately from CLI |
| T3 | Desktop installed | Service present | Desktop installed | Provider hooks and duplicate capture unverified |

Mini also has Claude Desktop, OpenCode Desktop and Zed. Qualification must cover
the actual agent/provider routes Peter uses, including remote and GUI sessions.
Unsupported routes must be named and skipped explicitly, never labeled active.

Official sources inspected on 2026-10-17:

- [Coding-agent integrations](https://hindsight.vectorize.io/sdks/integrations/coding-agents)
- [Hermes integration](https://hindsight.vectorize.io/sdks/integrations/hermes)
- [Portable-plugin limitations](https://hindsight.vectorize.io/sdks/integrations/agent-plugin)

The portable plugin provides skills and memory tools, not lifecycle-based capture.
It is unsupported as a substitute for automatic capture. Upstream documents
automatic seeding, Git ingestion, surveys and runtime updates; an unqualified
upstream installation does not meet the accepted boundary. Exact artifact
behavior and API compatibility must be proven by Nucleus's released contract.

## Contract gate

All entries below are unresolved release inputs, not invented commands or schemas.

- [ ] Committed source revision and released artifact/version are available.
- [ ] Supported OS/client combinations and prerequisites are explicit.
- [ ] Capability preparation is separate from explicit capture activation.
- [ ] Exact preparation/setup, read-only doctor and rollback invocations are documented.
- [ ] Configuration schema, permissions, secret references and noninteractive runtime paths are documented.
- [ ] Activation/cursor ownership and rerun/update preservation are specified.
- [ ] Installed, configured, active, skipped/unsupported, partial and failed states have exact semantics.
- [ ] Numeric recall/context/queue/retry/expiry bounds and failure evidence are supplied.
- [ ] New-activity-only capture, deduplication and Mini API compatibility have evidence.
- [ ] Ownership-aware rollback preserves memories, unrelated settings and queued obligations.

Inspect the actual released artifact and contract before opening implementation.
A draft plan, generic AI Layer command or upstream npm package is insufficient.
Material scope changes return to Peter. No speculative stubs become production code.

## Approved implementation design

1. Add `profiles/hindsight-memory.toml` with explicit macOS/Linux membership.
   Include only capability preparation and actual released prerequisites.
   Keep existing host profile membership unchanged.
2. Add capability metadata to apps.toml. Use the existing mise-owned Node LTS
   entry when required. Include Erlang/Elixir only if the released runtime needs
   them. A non-mise app's dependency field alone does not trigger current resolution.
3. Add one narrow setup type, provisionally `nucleus-prepare`, and
   `scripts/install/layer_nucleus_prepare.sh`. Invoke only the Nucleus contract.
   Run it after mise tools and Linux extras, when selected agents are available.
   Do not use the codex-only curl handler or Linux-only script handler.
4. Handle the type in app selection and status. Explicitly exclude unsupported
   extras and a-la-carte removal paths rather than silently ignoring selections.
   Removal must use Nucleus ownership-aware rollback, never delete a PATH binary.
5. Before installation layers, refuse addon-only runs on configured hosts.
   Reject memory selections that would drop existing runtime entries.
   Reject memory preparation with --clean before removal work. Preserve cleanup
   semantics for unrelated selections. Do not introduce a general config merger.
6. Profile installation prepares capability artifacts without enabling capture.
   Print the released activation instruction and mark activation pending.
7. Read documented diagnostic results and map safe fields into installer output.
   Missing capability, failed prerequisites, malformed results and partial failures
   reach record_install_failure; independent steps continue and final exit is nonzero.
   Missing credentials never become an active result or unexplained success.
8. Add docs/hindsight-memory.md and focused README, AGENTS and profile-guide links.
   Explain ownership, setup, supported routes, activation, failures and rollback.
   Do not Stow .codex, .claude, .pi, .hermes or .hindsight state directories.

The new layer must not stream raw secret-bearing output into install.log.
Use Nucleus's documented safe result interface; do not invent a second redactor.
Credentials, transcripts, local settings, activation records and diagnostic private
state stay outside Git. Redaction cannot guarantee detecting every transcript secret.

## Nucleus semantic acceptance requirements

- Preserve existing fodurrr memories and separate company memory.
- Capture new personal conversations inside and outside repositories.
- Record actual activation timestamps per host/adapter, never policy-date midnight.
- Prove per-message filtering for resumed sessions or enforce a disclosed fresh-session rule.
- Independently disable historical imports, Git ingestion, seeding, codebase surveys
  and bulk file ingestion, including across upgrades and background update paths.
- Keep recall time/context bounded and retention asynchronous.
- Bound durable queue size, retries and expiry; surface exhaustion without silent loss.
- Distinguish queued, submitted and completed retention; ordinary agent work continues offline.
- Preserve machine, agent, session, time and applicable repository provenance.
- Prevent duplicate capture from repeated events, reconnects and T3/provider overlap.
- Load secrets and runtimes correctly in CLI, GUI, service and remote contexts.
- Adopt existing GEEKOM Hermes settings only after ownership and capture-boundary checks.
  Do not reset existing state or invent a past activation timestamp.

Dotfiles validates the diagnostic contract and its acceptance evidence. It does
not implement these memory semantics itself.

## Self-review and corrections

This is the author's self-review, informed by two read-only investigations.
It is not an independent ExitGate verdict.

| Initial weakness | Accepted correction |
|---|---|
| Assumed a Nucleus command could be named | Released contract is a hard implementation dependency |
| Assumed additive mode preserves runtime configuration | Guard before generated-config replacement and pruning |
| Considered existing installer types sufficient | One narrow cross-platform preparation layer |
| Considered skipping mise only when no runtimes are selected | Rejected: adding Node still triggers replacement |
| Profile selection could imply capture consent | Separate preparation and explicit activation |
| CLI installation could imply broad support | Separate version, desktop, T3 and capture qualification |
| Existing Hermes capture could be treated as a fresh installation | Require adoption and boundary evidence |
| Raw diagnostics could expose secrets in install.log | Require safe output and secret-fixture checks |

## Verification and completion

- [x] Full handoff and relevant repository sources inspected on 2026-10-17.
- [x] Host facts and installed runtime versions checked without configuration changes.
- [x] Author self-review presented and corrected plan approved by Peter.
- [ ] Released Nucleus contract gate satisfied.
- [ ] TOML parsing, platform selection, profile composition and dependency ordering pass.
- [ ] Stubbed contract checks cover success, failure, partial, unsupported and malformed output.
- [ ] Missing credentials/capability, interruption and rerun checks pass.
- [ ] Runtime-preservation, cleanup-refusal and unsupported-selection checks pass.
- [ ] Preparation makes no activation or memory writes.
- [ ] Secret fixtures stay out of tracked files and captured installer logs.
- [ ] Bash 3.2 compatibility and relevant installer regressions pass.
- [ ] Documentation drift and git diff --check pass on implementation.
- [ ] Required independent ExitGate passes before marking implementation completed.
- [ ] Feature branch is committed and pushed with evidence; no main merge implied.

Baseline checks on 2026-10-17 at 396d946: bash -n passed for install.sh and all
scripts/install/*.sh and scripts/lib/*.sh; git diff --check passed. These checks
do not prove installation or capture. No live memory experiment or rollback ran.

Documentation checkpoint checks on 2026-10-17: scripts/docs/check-doc-drift.sh
passed its Claude import, local links, stale tokens and three read-only installer
discovery checks. git diff --check passed. The new work item was read back;
the drift script's link scan does not recurse into docs/plans. This item uses
literal repository paths and official web links, not unresolved local Markdown links.
Do not mark this work item completed while the contract or implementation remains open.

## Later rollout and rollback

The following selections are proposed, not executable instructions for the
current repository and not live authorization:

| Host | Checkout | Later profile selection |
|---|---|---|
| GEEKOM | /home/fodurrr/dev/dotfiles | ./install.sh -p developer -p geekom-vpn -p hindsight-memory |
| Omen | /home/fodurrr/dev/dotfiles | ./install.sh -p omen -p hindsight-memory |
| Mini | /Users/fodurrr/dev/dotfiles | ./install.sh -p hacker -p hindsight-memory |

Review Mini's current hacker profile changes and runtime differences before
rollout. Whole-profile runs may update unrelated tools. Omen retains its approved
Git-bundle transport; do not add remotes or copy credentials. Host checkout
updates themselves require the later rollout scope.

Present exact released commands, host update steps, any session restarts and
quota-consuming retain/recall checks for Peter's separate rollout approval.
Use Nucleus diagnostics for old/new/resumed-message boundaries, cross-host recall,
outside-repository conversations, provenance and duplicate capture. Preserve PIA,
Tailscale and Mini's existing server. No server or backup changes are included.

Rollback calls Nucleus's ownership-aware interface. Preserve memories, unrelated
settings, activation boundaries and unresolved queued work. Repository rollback
alone does not undo live hooks. Removing profile membership is not deactivation.

## Coordination and waiting

- Dotfiles chat: `01a14b4d-fc38-73f1-b75b-692acceb85cc`.
- Nucleus chat: `01a12fb1-16b4-7082-b244-f48a800ce904`, title `Read nucleus task file`.
- Nucleus owns `/home/fodurrr/dev/xpando/nucleus/plans/shared-personal-memory.md`.
- A dependency note was sent on 2026-10-17 with this item's path, approval boundary,
  contract requirements and host findings. No immediate reply or reprioritization
  was requested. Dotfiles approval does not authorize Nucleus work.
- Wait for the released contract. Read-only checks may identify readiness; do not
  install, activate, publish Nucleus packages or implement guessed interfaces while waiting.
- If delivery is incomplete, report precise missing contract fields and keep this item waiting.

### Nucleus audit update on 2026-10-17

Nucleus sent its audit outcome under Peter's coordination authorization.
Verified the committed proposal at
`40fe44ee7657cae6f8b436c4ea7b14610bf06e0c:plans/shared-personal-memory.md`.
This is proposal evidence, not a released contract or permission to implement.

- Nucleus's exact coding-agents 0.8.1 audit reports whole-transcript replacement
  when cursors are missing, dirty or pending data expires. Default seeding,
  Git ingestion and surveys also conflict with the accepted capture boundary.
- Its installed Hermes audit reports an unbounded in-memory queue. Async
  retention alone does not satisfy bounded durable delivery.
- Nucleus proposes explicit activation boundaries and one bounded durable
  delivery path. Names, commands and limits remain proposals until released.
- Mini 0.9.2 health/schema checks look suitable; live writes remain untested.
- Nucleus records the approved Dotfiles plan at e52fb66 as its consumer dependency.

Dotfiles keeps the existing release gate unchanged. Nucleus owns the fixes and
their evidence; Dotfiles will not copy them or use proposed interfaces. The quiet
hourly readiness check remains active. Main merge and live rollout still need
Peter's separate approval.
