# Personal Hindsight memory with official integrations

```work-item
{"current":"2026-11-03: Official 0.8.1 runs on GEEKOM, Omen and Mini with one settings file and token; T3 Claude, Codex, Grok and Antigravity work on all three; captures verified except T3 Antigravity, which is accepted as not captured; a T3 fix is requested and the test links were removed. Manual steps are in docs/hindsight-new-machine.md; ./install.sh does not set up memory. Retired tools/hindsight-memory removed from the tree (last in b170d88). Desktop checks cancelled. Push and main merge approved. Active; ExitGate false.","decisions":[{"date":"2026-10-17","decision":"Approve standalone component, adapters, installer safeguards, tests and review; publication, main merge and live rollout require separate approval. Measure the 100 ms target honestly.","id":"isolated-implementation-approved","owner":"Peter"},{"date":"2026-10-17","decision":"Approve a 200,000-token ceiling for exact Grok 4.7 review, supported fixes and local save. Publication, main merge and live rollout remain separate approvals.","id":"grok-packet-ceiling-approved","owner":"Peter"},{"date":"2026-10-17","decision":"Approve a 205,000 estimated-token ceiling for the same Grok 4.7 remediation review, local saving and Nucleus coordination. Publication, main merge and live rollout still require separate approval.","id":"grok-remediation-ceiling-approved","owner":"Peter"},{"date":"2026-10-17","decision":"Approve designing and locally saving the isolated Pi launch experiment. This turn is design-only; publication, main merge and live rollout require explicit approval. Present the revised bounded experiment before implementation or native execution.","id":"pi-launch-experiment-design-approved","owner":"Peter"},{"date":"2026-10-18","decision":"Approve the bounded experiment preview: build experiment-only harness and synthetic tests; verify confinement; run bounded isolated Pi --help factory probes; review and save results in local commits. No native conversation, publication, main merge, installed launcher, production activation or live rollout.","id":"pi-launch-experiment-implementation-approved","owner":"Peter"},{"date":"2026-10-18","decision":"Approve read-only transport diagnosis, local findings and Nucleus coordination. No native rerun. Publication, main merge and live rollout still require approval.","id":"pi-transport-readonly-diagnosis-approved","owner":"Peter"},{"date":"2026-10-18","decision":"Request a much simpler locally saved phased plan, using a fresh GPT-6.1 Sol supervisor and subordinate planning/review agents. This turn is planning/documentation only. Pi-first remains proposed sequencing; full scope and privacy remain unchanged. Nucleus/Xpando coordination is revoked. No implementation, native rerun, paid review, publication, push, main merge or installed/live change is authorized by this planning turn.","id":"simplified-plan-only-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Approved. Start Pi-first with a fresh GPT-6.1 Sol supervisor and delegated work. No Nucleus communication. No native rerun yet; publication, main merge and live rollout still need my approval. Earlier isolated component, adapters, tests and local-save permission persists; no provider call, installer change, push or paid review is authorized by this continuation. Skills are local workflow tools, never runtime dependencies.","id":"pi-first-sequence-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Run the bounded Pi test with delegated work, review and save results locally. No Nucleus communication. Publication, main merge and live rollout still need my approval. This authorizes only the frozen preview at 892994e90b4ae53ee190d22acbebed444875a91b, one invocation with five harmless preflights and at most one native process. It does not authorize modified native retries.","id":"pi-native-bounded-run-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Approve the corrected bounded Pi native test, delegated execution, independent outcome review and local saves only, frozen at 9fba423bc9bae3a01f172515d69760ace4e92d63. Exactly one invocation repeats five harmless preflights and starts at most one pinned native Pi process for two synthetic conversations. No automatic retry, fallback, transport/mount/capability change, Nucleus/Xpando communication, external-company investigation, paid review, publication, push, main merge, installation, production activation or live rollout.","id":"pi-corrected-native-bounded-run-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Go ahead with the remaining Pi readiness checks using delegated work. Reuse existing evidence and save locally. No Nucleus communication. Further native tests, publication, main merge and live rollout still need my approval. Existing isolated component/installer-safeguard and harmless fixture authority applies; no production gate or installed configuration change.","id":"pi-remaining-readiness-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Go ahead with the bounded native-test preview using delegated work. Save locally and run it. This authorizes preparing and reviewing the exact confined Pi qualification preview, bounded native execution and supported corrections, independent normal review and local commits without another preview approval stop. No Nucleus communication. Publication, main merge and live rollout still require approval; no host installation, permission changes, real-service credentials or personal-bank writes in this phase.","id":"pi-prepared-native-qualification-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Approve delegated saved live Pi pilot, discover endpoint and secret-file path from existing local settings rather than guessing, and save locally. No Nucleus communication. Publication and main merge still require approval. Existing exact preview bounds retain/API/native actions; additional runtime-directory changes outside its four named chmod paths were not authorized.","id":"pi-live-pilot-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Approve the four runtime permission fixes, finish Pi installation and proceed with delegated Codex and Claude implementation, actual installation, review and reversible repairs. Journal host changes and roll back failed owned changes while preserving working agents. Existing endpoint and key are reused without guessing. No Nucleus communication. Publication, push and main merge remain unapproved.","id":"pi-codex-live-implementation-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Approved the complete local replacement with official installer plus custom settings only. Withdraw bespoke human-only/final-answer-only restrictions and custom integration maintenance. Authorization includes backups, draining/removal of custom wiring, actual official install, normal session capture, native checks, supported fixes and rollback, independent normal review and local saving. No Nucleus communication. Publication and main merge remain separate approvals; other host rollout is not included.","id":"official-only-cutover-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Make Hindsight work in Codex Desktop and Claude Desktop using official integration and settings only, with delegated work. No Nucleus communication. Existing publication/main/other-host boundaries persist.","id":"official-desktop-support-approved-2026-10-18","owner":"Peter"},{"date":"2026-10-18","decision":"Approved Mini Hindsight upgrade to1.0.0 and server-wide English across all3banks, delegated work, backups, cloned-volume migration, bounded verification and rollback. Official integration/settings only. No Nucleus communication, publication, push or main merge.","id":"mini-server-1-0-0-english-approved-2026-10-18","owner":"Peter"},{"date":"2026-11-03","decision":"Approved rolling the official integration out to Omen and Mini as on GEEKOM, using the same API token on all three hosts; add Grok and Antigravity where supported. Node 26 goes to the vault security plan's Stage 8 item.","id":"omen-mini-rollout-same-token-approved-2026-11-03","owner":"Peter"},{"date":"2026-11-03","decision":"Native Codex Desktop and Claude Desktop Chat checks are not needed; most work happens in T3 Code from now on. Make the same T3 providers available on Omen and Mini as on GEEKOM.","id":"desktop-checks-dropped-t3-first-2026-11-03","owner":"Peter"},{"date":"2026-11-03","decision":"Same T3 providers on Omen and Mini as GEEKOM except Claude-API. Copy GEEKOM's Antigravity sign-in to Omen and Mini (Way 1). Try local links for Hindsight hooks in T3's private Antigravity folder (option B).","id":"t3-providers-antigravity-way1-b-2026-11-03","owner":"Peter"},{"date":"2026-11-03","decision":"Approved finishing: keep Hindsight a documented manual step (new-machine runbook), fix the Antigravity apps.toml description, remove the retired tools/hindsight-memory tree (history keeps it), push the branch, merge to main and update Omen's checkout.","id":"finish-runbook-merge-approved-2026-11-03","owner":"Peter"},{"date":"2026-11-03","decision":"T3 Antigravity memory: accept that it does not capture and ask T3 for an opt-in hook/MCP setting and per-turn Stop (option 2). Remove the GEEKOM test links. Update Mini's checkout.","id":"t3-antigravity-accept-and-request-2026-11-03","owner":"Peter"}],"deliverable":"Official Hindsight integrations installed on the approved local host, with private custom settings and verified ordinary-agent capture/recall. No replacement integration code.","evidence":[{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/*.test.mjs","repository":".","result":"pass; 91 tests, 0 failures","revision":"a704108c175508a8d01cef26f17d83f45a3190da","source_kind":"reproducible-check"},{"command":"cd tools/hindsight-memory && /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test test/review-remediation.test.mjs","repository":".","result":"pass; 18 tests, 0 failures","revision":"a704108c175508a8d01cef26f17d83f45a3190da","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test tools/hindsight-memory/experiments/pi-launch/test.mjs","repository":".","result":"pass; 35 tests, 0 failures; includes harmless real confinement and both parent-death tests","revision":"1fb18fac1944b5b3fba4b7466bc9a9d2074492b2","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-launch/run.mjs","repository":".","result":"fail; 3 preflight phases passed; positive native phase failed supervisor-exit / incomplete-handshake; 2 later native phases skipped","revision":"1fb18fac1944b5b3fba4b7466bc9a9d2074492b2","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-concurrency=1 tools/hindsight-memory/test/*.test.mjs","repository":".","result":"pass; 112 tests, 0 failures; worker execution at tested revision; identical component tree integrated as 4ecb36384ff2e41e27ae2c5dac06d62e9cc667a8 without rerun","revision":"15b83ea94f66a521c2b101f4aa269bdea214c7ef","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test tools/hindsight-memory/experiments/pi-turn/test.mjs","repository":".","result":"pass; 9 tests, 0 failures; includes five harmless PTY/network/death preflight phases; no native execution","revision":"f2a76c10e7acfdd4aa511eae62ae63a5af1a42f2","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --native","repository":".","result":"fail; exit 1; five harmless preflights passed; native setup failed unsafe-private-path; PTY driver not started; exact Pi ELF not observed; native acceptance cases not reached","revision":"892994e90b4ae53ee190d22acbebed444875a91b","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-name-pattern='fixed native arguments|harmless confined PTY preflights' tools/hindsight-memory/experiments/pi-turn/test.mjs","repository":".","result":"pass; 2 selected tests, 0 failures; five harmless preflights passed, actual native fixture preparation covered; tested uncommitted patch atop this revision, identical reviewed files committed as fd15a9811d6b29a380d40ae228684c89ff3d93f1; no native request, attempt or execution","revision":"1df4b8311716e2e46b04840b2834ce7a13d21862","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --native","repository":".","result":"pass; exit 0; 5 harmless preflight phases and 1 native phase passed; 1 native Pi process, 2 synthetic conversations, 2 model requests, 1 recall, 2 bank checks, 2 retains, 2 completed polls; passing harness asserts 2 durable completed jobs and 0 pending stages; intentional PTY stop -9 reaped; confined fake endpoints only","revision":"9fba423bc9bae3a01f172515d69760ace4e92d63","source_kind":"reproducible-check"},{"command":"node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/cli.test.mjs","repository":".","result":"pass; 7 tests, 0 failures; final worker packaging patch, identical relevant files integrated as 88e3b82311ba5ac1a4e15b999b0ecdcc7e6268ce; no repeat after integration; invoked node by name, observed version v24.22.0, resolved executable path not recorded","revision":"c3486474bae5ef449b38d462117b9cdb64e3264f","source_kind":"reproducible-check"},{"command":"node --disable-warning=ExperimentalWarning --test --test-name-pattern='Disk-backed Pi CLI' tools/hindsight-memory/test/pi-candidate.test.mjs","repository":".","result":"pass; 2 selected tests, 0 failures; final worker staged-status patch, identical relevant source/adapter/Pi-test files integrated as 0a28d30122483b3e004e6f8769749920b48056b6; initial assertions failed before correction; no native execution; invoked node by name, observed version v24.22.0, resolved executable path not recorded","revision":"43856f6441120b73cb2f3d36a93443028a268192","source_kind":"reproducible-check"},{"command":"node --test tools/hindsight-memory/test/ownership.test.mjs","repository":".","result":"pass; 10 tests, 0 failures; 3 new Pi cases; identical ownership test integrated as 14a2826da879a205e98d49ec09b70a36625b7176; no native execution; invoked node by name, observed version v24.22.0, resolved executable path not recorded","revision":"f5fee9a46489ba2de523fc0501138e1948c2e73d","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/experiments/pi-turn/test.mjs","repository":".","result":"pass; 11 tests, 0 failures; actual prepared-release mount layout, no native execution; final tested patch committed at this revision","revision":"2dd943255abeb1f31a9fcefde8c5a54dc776950d","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-name-pattern='qualification fixture' tools/hindsight-memory/experiments/pi-turn/test.mjs","repository":".","result":"pass; 1 selected test, 0 failures; exact request accounting including rejected request","revision":"0733e7ee266a39989eef4a301460611b57e7f250","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-name-pattern='qualification startup' tools/hindsight-memory/experiments/pi-turn/test.mjs","repository":".","result":"pass; 1 selected test, 0 failures; observed early startup rejected, binding/title required","revision":"921db5bd1e98752adbfec5070dc2bbc1f82faf9d","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --qualify-native","repository":".","result":"fail; 5 harmless preflight phases passed, 1 native phase failed qualification-consent-not-observed from early startup submission race; exact ELF observed; PTY stopped/reaped, no cleanupFailure; service/admission totals not saved and unknown","revision":"15adbff6eb325a760ae0b6265bd95a7eb699bce3","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --qualify-native","repository":".","result":"pass; 5 harmless preflights and 1 native qualification phase, exit 0; prepared release/unchanged generated bridge, 2 completed jobs, native cancel/switch/resume rejection, exact 15 HTTP requests, PTY deliberate stop -9 reaped; fake endpoints only","revision":"ae83170f9bfa023a86440b0749ae4d7a5a999042","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/activation.test.mjs tools/hindsight-memory/test/qualification.test.mjs","repository":".","result":"pass; 10 tests, 0 failures; harmless identity/CLI fixtures only","revision":"9bbc11df03d08c6b83a4c32cb7f6d2ad42182181","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/cli.test.mjs","repository":".","result":"pass; 7 tests, 0 failures","revision":"9bbc11df03d08c6b83a4c32cb7f6d2ad42182181","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test --test-name-pattern='Pi candidate process binding|Actual Node process observation|Fresh consent names|Fresh /new accepts' tools/hindsight-memory/test/pi-candidate.test.mjs","repository":".","result":"pass; 4 selected tests, 0 failures; no native Pi executed","revision":"9bbc11df03d08c6b83a4c32cb7f6d2ad42182181","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --disable-warning=ExperimentalWarning --test --test-name-pattern='sandbox component file allowlist contains the complete CLI import closure' tools/hindsight-memory/experiments/pi-turn/test.mjs","repository":".","result":"pass; 1 selected test, 0 failures; prior red ERR_MODULE_NOT_FOUND activation.mjs reproduced, no native process","revision":"fe8c02195760ed399b066eafaab49c96404399bc","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-name-pattern=Codex\\ owned\\ launcher tools/hindsight-memory/test/codex-native.test.mjs","repository":".","result":"pass; 1 selected test, 0 failures; native prompt deadline and plugin-disable arguments","revision":"ae6db65b8013df4c0315557dbbec8153d1177f37","source_kind":"reproducible-check"},{"command":"/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-name-pattern=\"isolated launch|Pi and scoped Codex\" tools/hindsight-memory/test/codex-native.test.mjs tools/hindsight-memory/test/activation.test.mjs","repository":".","result":"pass; 2 selected tests, 0 failures; native state outside queue preserves Store.status and combined activation","revision":"4483050eae19a055f7b5faf9d43fb61577b542cd","source_kind":"reproducible-check"}],"exit":["Official installer/configuration use the existing endpoint, bank and protected authentication.","Owned custom runtime wiring is inactive and cannot be reinstalled by Dotfiles profiles.","Actual Pi, Claude Code and Codex CLI outcomes and any remaining limits are saved honestly.","Independent normal review and repository checks pass. Required independent ExitGate remains necessary before administrative Completed; publication/main/other host actions retain separate approval."],"id":"hindsight-memory","inputs":[{"availability":"available","category":"objective","locator":"Direct Dotfiles chat approval on 2026-10-18: official installer and custom settings only; full local replacement approved.","owner":"Peter","required_at":"start","role":"Authorizes local installation, settings, native checks, fixes/rollback, delegated work, review and local save; no publication/main merge/other hosts.","source_kind":"instruction"},{"availability":"available","category":"governing","owner":"Dotfiles maintainer","path":"AGENTS.md","repository":".","required_at":"start","revision":"c9d976d5677d0c96967f9c64c71ba07d75a04674","role":"Repository workflow and host boundaries; superseding direct user approval controls local rollout.","source_kind":"document","track":"committed"},{"availability":"available","category":"evidence","locator":"@vectorize-io/hindsight-coding-agents0.8.1; upstream commit5331da2f4db369528bb122075341a7de9c3df6df","owner":"Vectorize","required_at":"start","role":"Official installer, supported settings and capture implementation. Existing installed artifact inspected. No company repository or Nucleus release required.","source_kind":"package"}],"inspection_triggers":[],"next":"Optional: ExitGate review before marking Completed. Peter files the drafted T3 issue about Antigravity hooks; if T3 adds it, enable and test. Node 26 is tracked in the vault security-scan-baseline Stage 8 item.","objective":"Provide optional personal Hindsight memory for general macOS and Linux machine setup, independently of Nucleus, Xpando tooling and repository membership.","owner":"Peter","relationships":[],"risks":[{"detail":"Official full-session fallback can include earlier text from resumed old conversations; start fresh sessions after cutover. No bulk import flag alone prevents this.","id":"older-resumed-session","owner":"Peter and agent user"},{"detail":"Detection and wiring do not prove native capture. Report tested CLI routes separately from other agents, desktop and remote hosts.","id":"support-claims","owner":"Dotfiles supervisor"},{"detail":"Keep token-bearing configuration/backups private and preserve newer native auth refreshes and unrelated settings during recovery.","id":"credentials-and-settings","owner":"Dotfiles cutover owner"},{"detail":"Production1.0.0 now accepts writes on migrated clone. Frozen0.9.2 original is recovery evidence, not lossless automatic rollback. Preserve migrated state/new writes and current refreshed auth; never run old binary against migrated clone.","id":"server-frozen-rollback-after-writes","owner":"Mini service operator"},{"detail":"One API token is shared by GEEKOM, Omen and Mini. Revoking or rotating it affects all three; a leak from any host exposes the bank.","id":"shared-api-token","owner":"Peter"},{"detail":"T3 isolates hooks and MCP for its Antigravity agent and fires no per-turn Stop; T3 Antigravity sessions are not captured. Accepted 2026-11-03; do not claim coverage.","id":"t3-antigravity-isolation","owner":"Dotfiles supervisor"},{"detail":"GEEKOM's T3 Antigravity Google sign-in is copied to Omen and Mini; signing out or revoking on one may sign out all three.","id":"shared-antigravity-signin","owner":"Peter"}],"schema_version":2,"scope":{"excluded":["Nucleus communication or runtime dependency.","Publication, push or main merge without approval.","Other host changes or service/server/backup/credential changes.","New integration code, wrappers, queues, capture-policy engines, provider frameworks, vendor forks or custom harnesses.","Bulk historical import, Git/file ingestion and codebase surveys.","Claiming desktop coverage from CLI proof or claiming literally all machine activity is captured."],"included":["Install official @vectorize-io/hindsight-coding-agents0.8.1 for supported installed agents on GEEKOM using existing Mini service/fodurrr bank.","Use normal meaningful session capture, including supported progress and automated activity. The former human-only/final-only restrictions were additional engineering choices and are withdrawn.","Keep private settings; disable Git ingestion, initial seeding, codebase surveys, bank configuration management and automatic package updates. No bulk historical import.","Drain and remove owned custom capture wiring/launchers; preserve auth, unrelated settings, receipts, source/history and rollback evidence.","Use fresh sessions after cutover. Run real Pi/Claude/Codex CLI capture and fresh-recall checks, supported settings fixes, independent normal review and local saving.","Retire custom app/profile/installer plumbing without replacement wrappers or capture code.","Use official integrations/settings for installed Codex Desktop and Claude Desktop; distinguish Code, Chat and Cowork, preserve native work, and save actual evidence or unsupported limits without custom integration code."]},"state":"Active","tasks":[{"actor":"Dotfiles cutover worker","depends_on":[],"done_when":"Official supported routes are installed with verified settings and private rollback evidence.","id":"official-cutover","state":"completed","work":"Back up, drain/suspend custom capture, install official package and private settings, preserve one writer."},{"actor":"Dotfiles installer worker","depends_on":["official-cutover"],"done_when":"Installer has no path to custom preparation; historical source is explicitly retired.","id":"custom-retirement","state":"completed","work":"Retire custom app/profile/installer plumbing and owned launchers."},{"actor":"Delegated native check workers","depends_on":["official-cutover"],"done_when":"Actual outcomes and supported corrections/rollback are saved without desktop/all-agent overclaim.","id":"native-checks","state":"completed","work":"Prove actual Pi, Claude Code and Codex CLI capture and later fresh recall with existing accounts."},{"actor":"Dotfiles supervisor and independent normal reviewer","depends_on":["custom-retirement","native-checks"],"done_when":"Checks and normal review pass; exact remaining limits and ExitGate status are recorded.","id":"local-save-review","state":"completed","work":"Update current guide/work item, resolve supported review findings and save local commit."},{"actor":"Peter and Dotfiles supervisor","depends_on":["local-save-review"],"done_when":"Only explicitly approved later actions execute; no coverage is inferred.","id":"other-hosts-publication","state":"completed","work":"Push and main merge approved by Peter on 2026-11-03; Omen and Mini rollout done under omen-mini-rollout."},{"actor":"Desktop supervisor and scoped desktop workers","depends_on":["official-cutover"],"done_when":"Official supported desktop settings and actual evidence are saved; missing native checks and unsupported capture remain explicit.","id":"desktop-setup-check","state":"completed","work":"Inspect real installed desktop products, configure supported official tools, preserve settings and document actual capability."},{"actor":"Peter and desktop supervisor","depends_on":["desktop-setup-check"],"done_when":"Fresh main desktop sessions prove capture, extraction and later recall; Chat/Cowork limitations have explicit disposition. UI steps remain open because native controls are unavailable.","id":"desktop-native-verification","state":"cancelled","work":"Cancelled by Peter on 2026-11-03: not needed, because work moves to T3 Code. Earlier desktop evidence and limits stay recorded; no Codex Desktop or Claude Chat capture is claimed."},{"actor":"Mini upgrade supervisor and runtime worker","depends_on":["official-cutover"],"done_when":"Official1.0.0 and global English verified after restored-clone acceptance; original recovery artifacts retained and limitations saved.","id":"mini-server-english-upgrade","state":"completed","work":"Upgrade approved Mini shared server to pinned official1.0.0 using frozenbackup/restoredclone and enable English across all3existingbanks."},{"actor":"Dotfiles supervisor","depends_on":["local-save-review"],"done_when":"Omen and Mini run the official integration with GEEKOM's settings; actual T3 capture/recall results and limits are saved.","id":"omen-mini-rollout","state":"completed","work":"Back up, install official 0.8.1 per named agent, add Claude SessionEnd, record Codex trust, test through T3 Code."}],"title":"Personal Hindsight memory with official integrations","verification":{"exit_passed":false,"status":"2026-11-03: Omen/Mini settings hash equals GEEKOM (a702a042); installer logs show 6 agents per host (+opencode2 on Omen); Codex hooks/list trusted for 3 Hindsight hooks on both. T3 tests: diag retain_ok for Omen Claude/Codex, Mini Codex, GEEKOM Grok; server operations completed; direct recall ranks 0/6/2/4; Antigravity no hook run. Earlier Mini 1.0.0 verification unchanged. No new ExitGate. Desktop native checks still open. Later 2026-11-03: Grok on Omen/Mini and Claude on Mini captured through T3 (retain_ok); Antigravity answered on all three machines; T3 Antigravity Stop capture not observed."}}
```

**Current direction: official installer plus private settings only.** The standalone
component, custom capture restrictions and installation plan below are retired
history. Human-only and final-answer-only restrictions were additional engineering
choices, not explicit requirements in the original handoff. The approved
[official replacement](#official-installer-replacement) owns current work.



## Decision and approval boundary

**Current plan — approved on 2026-10-18.** Keep the implemented core. Prove one ordinary Pi extension, cover remaining clients, then finish acceptance. Pi-first sequencing is approved. It does not cancel any client, host, privacy or durability requirement.

Peter approved the Pi-first sequence, then directly approved the frozen native test on 2026-10-18: “Run the bounded Pi test with delegated work, review and save results locally. No Nucleus communication. Publication, main merge and live rollout still need my approval.” That first invocation failed before PTY startup. Peter separately approved the corrected frozen test at `9fba423bc9bae3a01f172515d69760ace4e92d63`. Its single invocation passed the confined two-turn fake-provider/memory path. Both approvals are spent. Peter subsequently authorized designing and running the prepared-release lifecycle qualification. Its initial startup-race failure and sole corrected passing run are saved below. That bounded native budget is now spent.

This section owns the current sequence. Later sections preserve design history and evidence. Their obsolete next steps, Nucleus coordination instructions and spent review approvals are not current authority. The work item remains **Active**; ExitGate remains unpassed.

Peter intends the existing Mini server and bank fodurrr. Other users supply explicit separate configuration. Preparation never creates a bank or server implicitly. Bank names are not access control. Any multi-user rollout must verify server-side authorization.

The component must run without Nucleus, Xpando tooling, company repositories or skills, Erlang or Elixir. Hindsight remains the external memory service.

### Current state in plain words

| What exists | What it proves |
|---|---|
| Standalone Node core, private SQLite queue, adapters and optional installer profile | Implemented locally; preparation does not activate memory |
| 91 passing tests and earlier Grok advisory review at a704108c175508a8d01cef26f17d83f45a3190da | Isolated core/installer evidence within that reviewed scope |
| 35 passing Pi experiment tests at 1fb18fac1944b5b3fba4b7466bc9a9d2074492b2 | Harness fixtures and confinement checks; not native capture |
| Restricted Pi candidate at 4ecb36384ff2e41e27ae2c5dac06d62e9cc667a8 | Source-supported contract; worker serial suite 112/112 and normal review passed; no native execution |
| Native-turn preview at 360726ec276fd42f760430d9536923a0d749a077 | Reviewed harness; earlier 9/9 focused tests passed |
| Single approved native command at 892994e90b4ae53ee190d22acbebed444875a91b | Five harmless preflights passed; native setup failed `unsafe-private-path` before PTY startup; no native qualification |
| Fixture correction at fd15a9811d6b29a380d40ae228684c89ff3d93f1 | Actual preparation regression reproduced the failure, then two selected harmless tests and all five preflights passed; no native rerun |
| Corrected native test at 9fba423bc9bae3a01f172515d69760ace4e92d63 | Five harmless preflights and the confined native two-turn fake-provider/memory path passed; independent normal outcome review clear; production activation unchanged |
| Prepared bridge qualification at ae83170f9bfa023a86440b0749ae4d7a5a999042 | Actual prepared release and unchanged generated bridge passed positive delivery, cancellation, changed-session and resumed-session rejection; 15 exact fixture requests; independent normal outcome review clear |
| One failed native Pi factory probe | No HELLO/ACK/DONE; no qualified native session or completed turn |
| Read-only diagnosis at d58fa1aea07aaeee61a11aa549572c0f49629de9 | The chosen Bun 1.3.14 Socket constructor does not adopt FD3; descriptor availability remains unknown |

**The restricted prepared Pi route works against confined fake endpoints.** The local Pi-only eligibility change is implemented and normally reviewed. It requires Linux, the pinned Pi 1.3.0 ELF, explicit generated-owner selection and activation from the recorded installed release. Actual capture checks the exact generated bridge path and sole-extension arguments. Personal capture remains inactive; host preparation, existing-writer selection and real API proof still need approval. No native test reran on this new patch.

### Smallest useful deliverable

The approved first phase targets one **qualified Pi route** using the existing core. It recalls once for an eligible new prompt, admits the original prompt and completed answer durably, and delivers through the existing outbox. A later fresh session can recall the agreed harmless fact after approved live activation.

Isolated native evidence against a fake API comes first. It is not working personal-bank memory. A real Pi pilot needs separate approval for its publication, host preparation, activation and live requests. A Pi-only pilot would leave this whole work item Active. Remaining coverage stays required.

Before requesting an early pilot, qualify its exact host, runtime and Pi route: privacy and new-only capture, durable recovery, pending/uncertain operations, existing-writer ownership, safe preparation, experiment packaging and rollback. Reuse applicable frozen evidence; do not repeat a broad audit. Separate technical readiness from permission.

After a concrete isolated result, present the exact pilot commands and costs for separate approval. Prove real API operation/reconciliation behavior using only approved harmless requests before enabling automatic personal capture. Failure leaves capture disabled. No personal/live pilot is authorized by this plan, its acceptance, or the fake-API milestone.

### Simpler integration, with the same safeguards

Prefer an ordinary in-process Pi extension calling the fixed Node core. The existing adapters/pi.mjs and adapters/common.mjs already use that shape. Keep one capture policy, queue and delivery implementation.

Pi exposes supported input events before skill/template expansion. These are a candidate for original text. The revised Pi candidate matches that input against before_agent_start, then pairs persisted native user and completion IDs. Source and synthetic checks support only its restricted compiled Linux 1.3.0 TUI invocation; the confined native fake-provider path passed. Local Pi eligibility is now implemented; host/live qualification remains open.

The input source can be interactive, rpc or extension. Omitted source defaults to interactive. Extension commands run before input handlers. Therefore source===interactive, a command, ctx.mode, VERSION or an installed-file hash alone cannot establish a qualified route or original input.

Pinned source at Pi 71023aec1546d6d677a65669c5665c0927ce0dd0:

- [Input event and source fields](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/types.ts#L1167).
- [Command dispatch, source default and expansion order](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/agent-session.ts#L2058).
- [Compiled executable and package lookup](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/config.ts#L393).

Essential safeguards remain: explicit consent and destination, qualified current execution host and session, eligible original text only, no historical fallback, durable atomic admission, bounded delivery, private state, untrusted recall, and ownership-aware rollback. Mixed runtimes, SDK/RPC routes, nested agents and lifecycle changes require explicit qualification or rejection.

The threat model trusts the local user. It does not require universal authentication against hostile same-user software. Custom launchers, inherited socket handshakes and process supervisors are design choices, not user requirements. Replace or retain them only when evidence shows what the ordinary extension can prove. Keep OS confinement for isolated native experiments; it is not automatically production launch architecture.

### Three implementation phases

**Phase 1 — qualify one ordinary Pi route.** A fresh supervisor owns one bounded source-contract task, the narrow adapter change and its verification.

1. Prove a supported contract for current runtime/route, fresh-session consent, original-input lineage, stable message/completion matching and lifecycle invalidation. Cover command expansion, queued prompts, SDK/RPC and nested agents. The candidate uses process-local consent; the confined prepared-route proof below qualifies its positive and tested lifecycle behavior only.
2. If that contract holds, reuse stage-turn/complete-turn where their single-pending-turn contract fits. Add only the Pi bridge changes and focused synthetic tests. Do not add a second queue or silently enable other adapters.
3. Present one exact native test preview: artifact, argv, isolation, event path, fake endpoint, limits, cleanup and stop rule. Identify a supported provider-free completed-turn path, or state the provider/quota approval needed. Fabricated callbacks never qualify native completion.
4. After approval of that native execution, verify original prompt -> recall -> completed answer -> durable admission -> fake-API completion. Include replay/history/recall and lifecycle rejection cases. Record actual native evidence separately from fixtures.

**Phase 1 exits** with a qualified route and a candidate Pi pilot, or one concrete missing interface and its consequence. The first failed prerequisite stops native work. Do not keep iterating speculative transports or weaken a boundary to make progress. Existing production refusal remains until the qualified implementation passes its checks; live activation is separate.

**Phase 2 — cover the remaining clients and routes.** A fresh supervisor assigns independent, bounded route work. Reuse the core and the proven integration pattern; Pi evidence does not qualify another client.

Deliver native input/completion and capture-owner evidence for the complete route matrix. Keep Codex CLI and Desktop, Claude Code and Desktop, ChatGPT, both OpenCode generations and Desktop, Grok, Gemini, Hermes, T3, Zed and remote execution distinct. Preserve exact host/version differences. Resolve Hermes's pre-admission gap and existing-writer handover. Prove T3/provider single ownership.

**Phase 2 exits** when every required route has qualified evidence or a named blocker. A blocker leaves coverage open. Unsupported status never completes an obligation. Only Peter can explicitly change required coverage.

**Phase 3 — finish the complete package and acceptance.** A fresh supervisor integrates Linux/macOS, runtime/environment, disk-full/crash, physical storage, state-budget, privacy, rollback and performance qualification. Keep the existing acceptance suite as the checklist. Change core or installer code only for demonstrated defects or integration needs.

Deliver standalone preparation outside the checkout/company tooling, preserved runtime ownership, truthful status and rollback, and measured admission plus whole-process startup. Exclude experiment sources from installed releases or obtain an explicit packaging disposition. Record unavailable host, power-loss and live-service evidence honestly.

Run the relevant repository checks and changed-area regressions once on the integrated candidate. Run the required fresh cross-provider ExitGate through adversarial-review --purpose exitgate on the final accepted scope, code and evidence. The earlier advisory and normal reviews do not replace it. Do not reuse spent review budgets; obtain authorization for the concrete final review request.

**Phase 3 exits** only when required outcomes pass or Peter explicitly disposes their scope, and ExitGate passes. Publication, main merge and rollout remain separate actions. Without that evidence, save an incomplete checkpoint instead of marking Completed.

### Economical supervision and root checks

Each phase gets a **fresh GPT-6.1 Sol supervisor**. It assigns bounded workers or scouts for independent questions and one focused normal reviewer. Use separate worktrees for parallel writers. Finish agents when their task ends. Do not add phases or broad audits by default.

Only the phase supervisor reports to root. Its short handoff names the commit, changed paths, actual checks, failures, evidence limits, open obligations and next authorized action. Root spends roughly 10% of the effort checking that handoff, final diff, scope and authority. Root does not repeat source investigations or rerun unchanged suites. Reopen only a concrete inconsistency.

### Preserved obligations and authority

| Existing task | Current owner in this sequence |
|---|---|
| Proposal approval | Historical isolated approval stays completed; Peter approved this Pi-first sequence on 2026-10-18 |
| Standalone runtime, safe capture, reliable delivery and privacy/rollback | Pi integration in Phase 1; shared route checks in Phase 2; complete qualification in Phase 3 |
| Adapter coverage | Pi in Phase 1; all other routes in Phase 2; unresolved blockers remain open |
| Installer integration | Phase 3, including dormant experiment packaging |
| Verification and review | Focused checks per phase; final acceptance and ExitGate in Phase 3 |
| Publication and rollout | Separate explicit approval, including any early Pi pilot |

All existing tasks, risks, dependencies and evidence remain in this item. Preserve historical results at their exact revisions. Nucleus/Xpando communication is prohibited. No new external-repository investigation is required. Workflow skills used to save or review work do not become runtime dependencies.

**Pi-first work is authorized under a fresh GPT-6.1 Sol supervisor with delegated work.** Earlier isolated component, adapter, test and local-save authority persists. The prepared-release/generated-bridge qualification now passed after one supported startup-barrier correction. It proves one pinned Linux compiled Pi 1.3.0 sole-extension TUI route with fake endpoints, explicit fixture writer ownership and no inherited consent after tested lifecycle changes. The native budget for this phase is spent. Local Pi-only activation eligibility is implemented; host permissions and real-service qualification remain unchanged. No Nucleus communication, paid review, publication, push, main merge or installed/live action is authorized.

The sequencing decision is accepted. Do not ask again for already approved isolated work between phases. Seek new approval for a genuine scope/workflow change, a concrete native experiment or provider call, installer changes outside this phase, a new paid-review budget, or exact publication/main/host/live actions. Group related approval details once their commands and costs are known.

**Next action:** use the saved **Pi-only eligibility and live-pilot preview** for the next operator decision. Supply the real endpoint and private secret-file path, then approve the exact host/API pilot before any execution. That preview names four unsafe directory modes, installed-writer inventory/selection, existing-bank authorization, bounded harmless real-API operation/reconciliation/recall, restricted Pi launch and rollback. No further native test is needed in this local phase. Other authorized isolated route work may continue without repeating this approval. Keep all other routes and whole-item obligations open.

The **Pi readiness decision** preserves earlier packaging/status fixes, lock/rollback fixtures and host facts. The **Prepared Pi native qualification result** adds the now-passed prepared route and exact lifecycle proof. The **Pi-only eligibility and live-pilot preview** records the implemented narrow gate and remaining host/API prerequisites. Host permissions remain unchanged. The 100 ms target remains a measurement target.

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

**Current on 2026-10-18:** Peter approved the Pi-first sequence in Decision and approval boundary. A fresh GPT-6.1 Sol supervisor and delegated work have started. No scope reduction, weaker privacy or Pi-only finished product is approved.

The sequencing decision is closed. Source inspection supports a restricted compiled Linux Pi 1.3.0 TUI contract. The local candidate passed synthetic checks and normal review. The corrected approved run now passes its confined native two-turn fake-provider/memory path at `9fba423bc9bae3a01f172515d69760ace4e92d63`. Existing isolated component, adapter, test and local-save authority persists. Skills remain local workflow tools; they are never runtime dependencies. Nucleus/Xpando communication is prohibited.

Current-host/session/original-input qualification remains decisive. The restricted source contract and confined fake-provider path are supported; production qualification remains open. All route, macOS, durability, API idempotency/completion, measured performance and packaging obligations remain open. A supported-interface failure requires a concrete proposal, not silent omission or a broader service.

The separately approved frozen `pi-turn/run.mjs --native` command ran once and failed with `unsafe-private-path` before PTY startup. Five harmless preflights passed. That first run did not qualify native acceptance. Source-only diagnosis identified `/agent` tmpfs permissions. The minimum fix and actual preparation regression are now saved at `fd15a9811d6b29a380d40ae228684c89ff3d93f1`. Two selected harmless tests passed, including all five preflights; normal review cleared the change. Peter separately approved its corrected exact preview at `9fba423bc9bae3a01f172515d69760ace4e92d63`. The single corrected invocation passed all five harmless preflights and the confined native phase. No further native run is authorized. Any early live Pi pilot still needs its stated readiness evidence and separate approval before personal capture.

The earlier Grok advisory passed for its frozen isolated scope. Its review budgets are historical and cannot fund a new call. Final ExitGate remains outstanding; a concrete new paid request requires authorization. Publication, push, main merge, host installation, activation and live memory writes remain separate approvals. The work item remains Active with ExitGate false.

## Later host rollout

**Superseded on 2026-11-03** by [Omen and Mini rollout](#omen-and-mini-rollout); the retired profile route below is history.

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

**Current on 2026-10-18:** Peter revoked Nucleus/Xpando coordination. Do not message those chats or depend on their runtime, repository state or approval. This work remains wholly standalone. Local workflow skills do not become component dependencies.

Historical transfer references remain evidence only:

- Dotfiles chat: 01a14b4d-fc38-73f1-b75b-692acceb85cc.
- Former Nucleus chat: 01a12fb1-16b4-7082-b244-f48a800ce904.
- Nucleus previously verified successor e7977cfa85034f947412a1b25d440334a0c6fc28 and reported Superseded closure 4281c73fe9f50f277a171542adfeda8f6a107d27. Transfer anchor: 1a73d74467008abc703eca4e9353cf23c31de58f. These facts are retained from earlier inspection, not rechecked in this phase.
- The Nucleus-contract heartbeat was deleted on 2026-10-17. No runtime-contract wait remains.
- Isolated implementation was approved on 2026-10-17. Publication, main merge and live rollout remain separate approvals.

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

## Grok remediation passed; isolated code readiness only

Peter approved the 205,000 estimated-token ceiling on 2026-10-17.
The exact request passed validation before dispatch. The original rubric,
envelope, horizon base, repair matrix and Grok 4.7/high selection were retained.
The approved separate-session wrapper ran the native background launcher.

| Review fact | Accepted result |
|---|---|
| Execution status | COMPLETED; terminal end_turn; exit 0 |
| Result class | valid_verdict |
| Reviewer verdict / host gate | SHIP / PASS |
| Finding register | Empty; all three supported initial findings resolved |
| Reviewer | xAI Grok 4.7, high reasoning, Grok CLI 1.0.62 |
| Purpose | Advisory review of isolated code readiness; not full ExitGate |
| Reviewed candidate | a704108c175508a8d01cef26f17d83f45a3190da |
| Local integration | e8fbfef88a2bda95b5a73ab0f494303fb33f15ba; identical component and user-documentation contents |
| Packet | 601,482 bytes; 202,497 estimated tokens including reserve; approved ceiling 205,000 |
| Duration | 9 minutes 5 seconds |

The reviewer confirmed bounded transient bank-profile retries, recovery holding
the worker mutex through its transaction, and literal-loopback-only HTTP.
No further findings were recorded. This completes the permitted remediation
review; no further provider review is needed for this frozen repair series.

The report and complete lineage are retained privately in the primary checkout:
.opencode/adversarial-review-reports/20261017T221124Z-1942828-12098.md
and its .lineage.json sibling. Both were copied byte-for-byte from the isolated
review worktree. The raw event log was deleted by the runner after validated
success. The retained report includes runner diagnostics and the full verdict.

Report SHA-256:
ab1cab827e8ca8fee44c50c27a29a517a4ed2f2bdb6c09a8ccbbc1e05d009c1d.
Candidate fingerprint:
ea65a399b4a70b31d5397015c22e61a50207fada12df79a7f2cdca90ead7f7e4.
Review series:
565eb0f625aed89d9bf4cc8ed66170614b8bd6163ad029bdfab45fbaeaad1ec2.
These identifiers retain the result’s provenance; they are not test-output hashes.

The previous 18 focused and 91 full tests remain valid because the code did not
change during this review. Independent acceptance also passed 91 tests and the
real loopback/SIGSTOP checks described above. No new live or native-agent test
was performed. Effective route capacity remains unknown; successful completion
does not establish a general context-capacity guarantee.

Nucleus was informed of the accepted verdict, candidate, retained report and
remaining boundaries. The generic reviewer launcher work remains owned there.

All native production activation remains blocked until actual invoking-client
binding is qualified. Grok, Gemini, Hermes, desktop routes, T3 and Zed retain
open coverage obligations. macOS, real ENOSPC, power loss and live API behavior
remain unqualified. The full work-item ExitGate has not run or passed.
The work item stays Active. Publication, main merge and live rollout still need
Peter approval; none occurred. The next implementation obligation is native
current-caller binding, not publication of an active integration.

## Native current-caller investigation

Peter authorized continued investigation and local saving on 2026-10-17.
This phase inspected source and ran synthetic local observations only. It did not
implement a binding, execute native agents, read private conversations, inspect
credentials, install hooks or contact a memory service. Production activation
still fails with native-caller-binding-unqualified at src/cli.mjs:98.

Starting checkout: /home/fodurrr/dev/dotfiles, codex/hindsight-memory,
21b0d2d4fa4908ce5f403521d04f65fcc193c288. GEEKOM/Linux; clean, 18 commits ahead
and zero behind origin/codex/hindsight-memory after fetch. No active custom Git
hooks were configured. No implementation file changed during this investigation.
The 205,000-token review approval was not reused for another provider call.

### What binding needs to establish

Keep three questions separate: which execution host and version emitted the
event; which currently attached session and launch consent cover it; and whether
its user text is eligible original input. An installed-file probe answers none
of those questions for a later global-hook invocation. A historical creator
header answers a different question from current session attachment.

This is compatibility and consent scoping under the existing local-user model.
It is not a new requirement to authenticate hostile software running as the same
user. Do not demand impossible universal attestation, but do reject ordinary
mixed installations, SDK/GUI routes and inherited child-tool scope that the
adapter has not qualified. A server may be compatible while its frontend remains
unknown. Frontend equivalence must be proved before claiming broader coverage.

### Current implementation and local observations

At the starting commit, qualifyAgent in tools/hindsight-memory/src/qualification.mjs:5–17
probes and records a selected file. makeInvoker in adapters/common.mjs:75–81
checks that file and the Node runtime remain unchanged. It does not establish
which application invoked the adapter. The production refusal contains this gap;
these checks are useful update fences, not an already implemented caller binding.

Two temporary Node 24.22.0 investigations passed their expected assertions:

1. A private synthetic executable A returned version 1.2.3. A different Node
   program B obtained A's descriptor and called makeInvoker with a mock core.
   The installed-file checks accepted the mock session call while B was the
   current program. No production activation, native binary or network ran.
2. An imported synthetic JavaScript module retained its old exported version
   after its on-disk source was replaced. Reading current package bytes after
   loading therefore does not, by itself, identify the loaded code.

These are two bounded observations, not native acceptance tests or a new full
suite result. Temporary files were removed. Existing 91-test and Grok review
results still describe the unchanged implementation. No benchmark was repeated.

### Codex 0.162.0 and 0.163.0

The hook payload has session and lifecycle fields, but no current executable,
version or frontend identity. SessionStart.source means startup/resume/clear/
compact/fork. The transcript source and version describe historical provenance.
At 0.163.0, app-server resume supplies no replacement source, and core prefers
source recovered from history. Its initialize client name is stored separately.

The command dispatcher closes the environment ambiguity: Hooks::new snapshots
host process environment. The Unix child starts with a cleared environment and
receives that snapshot plus configured hook overrides. Reconfiguration reuses
the snapshot. Plugin additions identify plugin locations. No reserved current
CLI/Desktop/T3 marker is inserted in this inspected path. Hooks::new receives
neither current session_source nor the initialize client name. Static hook env
configuration is not a caller-specific dispatch contract.

Immutable evidence at 0.163.0, commit 83086188ae0614bd882818ff1aa23f3194962012:

- [Hook environment snapshot, registry.rs:70–100](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/hooks/src/registry.rs#L70-L100).
- [Shell launch and environment, command_runner.rs:384–435](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/hooks/src/engine/command_runner.rs#L384-L435).
- [Clean child environment, child_command.rs:72–101](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/utils/pty/src/child_command.rs#L72-L101).
- [Hook construction, session.rs:1618–1632](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/core/src/session/session.rs#L1618-L1632).
- [Separate client name, initialize_processor.rs:130–142](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/app-server/src/request_processors/initialize_processor.rs#L130-L142).
- [History-source preference, thread_manager.rs:1166–1182](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/core/src/thread_manager.rs#L1166-L1182).
- [App-server resume, thread_processor.rs:4200–4214](https://github.com/openai/codex/blob/83086188ae0614bd882818ff1aa23f3194962012/codex-rs/app-server/src/request_processors/thread_processor.rs#L4200-L4214).

The 0.162.0 SessionStart schema was inspected at
c1382380de69521303b416720a52f42d51af6248; the deeper dispatcher trace above is
0.163.0 evidence, not an unperformed 0.162.0 trace. No native caller binding is
established. Separate CODEX_HOME or a wrapper remains a new local proposal, not
an existing supported current-caller field. External Desktop/T3 launch behavior
was not tested.

### Claude Code 2.1.302

The exact installed binary remains the previously pinned artifact:
/home/fodurrr/.local/share/mise/installs/claude/2.1.302/claude,
SHA-256 60d7eb7f12fbb28a52533fe8be5884097403562aa02dc73991a021c7067e29a5.
Only embedded source was read; Claude was not executed.

Its common hook schema/input has no current PID, executable, version or app
identity. CLAUDE_CODE_ENTRYPOINT labels CLI, SDK, IDE and Desktop paths, but is a
mutable process environment label. Ordinary command hooks are shell mediated.
Neither the label nor an assumed immediate parent PID is a qualified binding.
The blanket refusal is src/cli.mjs:98; Claude Code is not a BLOCKED_ADAPTERS key.

A material prompt-origin gap was found. The optional UserPromptSubmit.source
schema at binary byte 236066151 names user, sdk, system and automated wakeups.
Upstream GDn at 244507067 and Iat at 244507252 compute these distinctions.
The bcr caller at 251434477 passes its computed label to xlt. However xlt at
246279996 does not use that argument and emits no source field. Ebr at 246279710
also omits it, including session-notice and poll-event paths. Common input ou at
246286345 does not supply it; dispatch at 246350800 serializes it without adding
source. Thus schema presence does not prove actual event delivery.

Correction to the initial research hypothesis: a source===user predicate would
reject the inspected missing-field payloads. Accepting a missing value would
remove that protection. This version cannot be qualified by that optional field
alone. Actual caller binding and eligible original-prompt provenance both remain
open; neither may silently be inferred from a stable prompt_id.
The [official hook reference](https://code.claude.com/docs/en/hooks) also describes
shared terminal, IDE, Desktop and cloud surfaces, so interactive input alone
would not distinguish those routes even if its origin field were populated.

### Pi 1.1.0 and 1.3.0

In embedded, bundled and source builds, the extension loader can supply the host's
loaded package namespace through virtualModules. Unbundled Node uses filesystem
aliases with moduleCache:false instead; qualify those loader modes independently.
VERSION is read from package.json when config initializes. PI_PACKAGE_DIR can
redirect that lookup, and binary archives include a package.json sidecar. Thus
VERSION is useful consistency metadata, not independent executable identity.
ctx.mode is also insufficient: SDK code can set the runner's mode.

Evidence at 1.3.0 commit 71023aec1546d6d677a65669c5665c0927ce0dd0:
[loader:69–124](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/loader.ts#L69-L124),
[virtual modules:9–37](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/virtual-modules.ts#L9-L37),
[package lookup:393–404](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/config.ts#L393-L404),
[VERSION initialization:565–582](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/config.ts#L565-L582),
and [runner mode:572–575](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/runner.ts#L572-L575).
Matching loader/config behavior was checked at 1.1.0 commit
abe508e1b89912adde45528136c3221eb69acdd7. No upstream module was imported or
native Pi session started.

### OpenCode 1.18.35 and 2.0.32

V1 plugins run with execution-server context. PluginInput has no direct host
version field. Its supplied client can report the server's compiled version
through health, which still does not identify the attached frontend. A local
client can attach to another server. Do not call Installation.info merely to
inspect a local version: its implementation also resolves the latest release.

V1 evidence at 53d1eabb61e21162157817bf677da0a4ad3332e3:
[PluginInput:56–75](https://github.com/anomalyco/opencode/blob/53d1eabb61e21162157817bf677da0a4ad3332e3/packages/plugin/src/index.ts#L56-L75),
[server client construction:143–168](https://github.com/anomalyco/opencode/blob/53d1eabb61e21162157817bf677da0a4ad3332e3/packages/opencode/src/plugin/index.ts#L143-L168),
and [server health:66–68](https://github.com/anomalyco/opencode/blob/53d1eabb61e21162157817bf677da0a4ad3332e3/packages/opencode/src/server/routes/instance/httpapi/handlers/global.ts#L66-L68).

V2 ctx.app comes from current execution-host App.Metadata, preserved by the
promise adapter. The ordinary CLI supplies compiled build metadata, but App.make
accepts supplied metadata and SDK options expose it. Name/version alone therefore
cannot prove the host is the CLI or identify its frontend. The server plugin
entrypoint is separate from TUI/RPC entrypoints. Different client/server versions
are supported with a warning, not necessarily refused.

V2 evidence at 843a6c514e606b436a7fe713422ace0a93ad3d61:
[host metadata:47–51](https://github.com/anomalyco/opencode/blob/843a6c514e606b436a7fe713422ace0a93ad3d61/packages/core/src/plugin/host.ts#L47-L51),
[App.make:12–28](https://github.com/anomalyco/opencode/blob/843a6c514e606b436a7fe713422ace0a93ad3d61/packages/core/src/app.ts#L12-L28),
[SDK metadata:18–41](https://github.com/anomalyco/opencode/blob/843a6c514e606b436a7fe713422ace0a93ad3d61/packages/sdk/src/internal/host.ts#L18-L41),
and [remote version mismatch:25–39](https://github.com/anomalyco/opencode/blob/843a6c514e606b436a7fe713422ace0a93ad3d61/packages/cli/src/services/server-connection.ts#L25-L39).

A qualified server route could establish capture ownership on that server without
proving frontend identity. That is a separate support claim. Prove equivalent
eligible-message behavior before covering multiple frontends; do not silently
waive the existing desktop/provider obligations. No health endpoint was called.

### Revised next experiment and rejected shortcuts

Independent architecture review recommends one isolated Pi direct-CLI experiment
if proceeding. Its in-process extension avoids shell ancestry as the first proof.
The experiment should select an exact qualified entrypoint, arrange proven
invocation-scoped extension loading, bind native session ownership to that launch,
and reject unscoped global, SDK, unsupported-mode and inherited child-tool paths
before any recall or capture. Recheck resume, extension reload and runtime changes.
It is a proposed experiment, not a supported route or an activation change.

An invocation marker expresses consent scope. A permanent marker or inherited
nonce alone is insufficient: child tools may carry it. A matching version label,
ctx.mode, process title, arbitrary ancestor or unchanged installed file is also
insufficient. Node process.execPath identifies the running Node executable, not
the JavaScript agent package; see the [Node process API](https://nodejs.org/api/process.html#processexecpath).
Linux /proc/pid/exe and starttime can help investigate process identity, but have
permission/lifetime limits and do not supply a portable session/route contract;
see [exe](https://man7.org/linux/man-pages/man5/proc_pid_exe.5.html) and
[stat](https://man7.org/linux/man-pages/man5/proc_pid_stat.5.html). No macOS process
verifier was tested or promised.

A dedicated copied agent distribution was considered but is not the selected
next step. It expands packaging and runtime ownership beyond a narrow bridge.
Keep mise as the existing agent-runtime owner. First determine whether an exact
launch and checks around loading can meet the stated boundaries without a second
runtime installation. If they cannot, report the limit instead of inventing a
second installer or claiming disk hashes prove loaded code. A new launcher also
changes workflow; present that concrete change before implementation.

Future acceptance must cover: installed A/current B; stale loaded code after
updates; Pi sidecar or PI_PACKAGE_DIR mismatch; SDK presenting TUI mode; child
and nested-agent inheritance; unscoped launch; resume/reconnect/reload; stale
session ownership; ambiguous OpenCode frontend; and missing Claude prompt source.
Every negative case must produce zero recall/admission calls. Keep eligibility
and ownership tests separate from version consistency tests.

The full route matrix remains open, including Grok, Gemini, Hermes, desktop,
T3 and Zed. This phase did not requalify those routes or erase earlier blockers.
Nucleus receives the saved findings for coordination only; no Nucleus runtime
contract or duplicated company-memory implementation is introduced.

## Isolated Pi launch experiment

Design saved on 2026-10-17. Peter authorized designing and saving this experiment.
This section is the revised proposal, not an implementation or a test result.
It belongs to adapter-coverage in this canonical work item.

### Question and narrow result

Can one explicit launch of the installed Linux Pi binary load only our probe,
and bind that probe to the actual process that the experiment launched?

The first native experiment ends after extension loading through --help.
It does not start a conversation or establish native session attachment.
Synthetic fixtures separately test a proposed session gate. Their results cannot
qualify native callbacks, original user input, completed turns or capture.
Production activation remains refused with native-caller-binding-unqualified.

This is compatibility and intentional launch scoping under the trusted local-user
model. It does not authenticate hostile software running as the same user.
No marker, version label, ctx.mode or selected installed file alone grants scope.

### Exact target and ownership

The only native target is the GEEKOM Linux x86-64 compiled Pi 1.3.0 archive:

- Executable: /home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi/pi.
- Observed size: 107174016 bytes.
- SHA-256: c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca.
- Source reference: earendil-works/pi at 71023aec1546d6d677a65669c5665c0927ce0dd0.
- Adjacent package.json declares @earendil-works/pi-coding-agent 1.3.0.
  Sidecar SHA-256: 83c3bb7619f590c213cc96a24216eb29a819a3ef6dc548607cc037ed276e8dc5.
  Its npm bin entry names dist/bundle/cli.js, which is not this archive's entrypoint.

The source reference explains expected behavior. It is not a reproducible-build
attestation linking every installed binary byte to that source commit.
Recheck the executable digest and required resource manifest before any native run.
Mismatch stops this experiment; never update the runtime to make the test pass.

Mise remains the sole runtime owner. Bind the existing package read-only into
the sandbox. Do not install or copy a second agent distribution. Node 24.22.0
runs the experimental supervisor; Pi uses its own compiled Bun runtime.
Node/npm Pi, Pi 1.1.0, macOS, RPC, SDK and other agents remain outside this proof.

### Source findings that constrain the experiment

--version exits before extension loading. --help exits after resource loading,
which awaits each extension factory. Therefore an asynchronous factory probe can
finish its bounded launch handshake without starting a native session.
--no-extensions still permits explicit --extension paths.

Those flags are not an isolation boundary. Resource loading resolves configured
packages before filtering the resource types. Empty private directories, a clean
environment and OS confinement must prevent ambient settings and package access.
--offline is an additional safeguard, not proof that all networking is impossible.

A no-prompt TUI session was considered and removed from this first experiment.
Pi can emit session_start, but ctx.shutdown starts an asynchronous shutdown while
initialization continues. This requires a separate lifecycle design and evidence.
Do not silently add TUI startup when --help cannot demonstrate session binding.

Pinned primary-source evidence, all at the Pi revision above:

- [Bun and CLI entry](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/bun/cli.ts#L1-L4).
- [Explicit extensions with discovery disabled](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/cli/args.ts#L326-L343).
- [Package resolution before filtering](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/resource-loader.ts#L527-L532).
- [Explicit prompt selection](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/resource-loader.ts#L646-L670).
- [Help exit after loading](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/main.ts#L878-L884).
- [Awaited extension factory](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/loader.ts#L613-L628).
- [Native session-start emission](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/agent-session.ts#L3288-L3311).
- [Asynchronous shutdown binding](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/modes/interactive/interactive-mode.ts#L2028-L2033).

The [Bubblewrap reference](https://github.com/containers/bubblewrap/blob/main/README.md)
explains that its argument list defines confinement. It supplies no automatic
complete sandbox policy. The Linux [executable link](https://man7.org/linux/man-pages/man5/proc_pid_exe.5.html)
and [process stat](https://man7.org/linux/man-pages/man5/proc_pid_stat.5.html)
references describe the process observations used here.

### Files and explicit workflow proposed for implementation

Keep all new executable work under tools/hindsight-memory/experiments/pi-launch/.
Use a small runner, an inner supervisor, a probe extension and focused tests.
Keep the experimental guard local to that directory. Inject a fake invoker into
existing createPiAdapter only in synthetic tests; do not copy the adapter/core.
Do not edit production activation, adapter installation, profiles or apps.toml.

The proposed explicit entrypoint is:

    /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-launch/run.mjs

That file does not exist yet. It accepts no arbitrary Pi arguments, endpoint,
bank, token or provider settings. It runs bounded probes and exits.
It is not a replacement for pi, a shell alias, a login hook or a resident service.
The ordinary Pi command and global extension directories remain unchanged.

### Isolation before any native execution

1. Inspect the installed bwrap interface and build a fixed, reviewed sandbox
   argument list. /usr/bin/bwrap exists, but namespace support has not been tested.
   Preflight confinement and supervisor-death cleanup with a harmless helper.
   Do this before starting Pi.
   Unsupported namespaces or denied access stop the experiment. No sudo,
   package installation, sysctl change or weaker fallback is allowed.
2. Use private mount, PID and network namespaces, a fresh /proc, and a new session.
   Keep the inner supervisor and Pi in the same PID namespace.
   Do not expose host /proc, home directories, repository parents, /run sockets,
   Docker, SSH-agent, D-Bus, display or provider sockets.
3. Mount only the selected Pi package, exact supervisor runtime, reviewed probe
   files and required system libraries read-only. Review each mount explicitly.
   Supply empty writable HOME, agent directory, XDG directories, cwd and /tmp.
   Their ancestor directories must contain no host project settings.
   Only a private experiment output directory may be written on the host.
4. Construct the environment from an allowlist. Set private HOME and
   PI_CODING_AGENT_DIR, PI_CODING_AGENT_SESSION_DIR, fixed cwd, PI_OFFLINE=1,
   PI_SKIP_VERSION_CHECK=1, PI_TELEMETRY=0 and minimal locale/PATH values.
   Exclude inherited PI_PACKAGE_DIR, provider keys, proxies, loader injection
   variables, telemetry configuration and user shell initialization.
   Preserve the archive's binary-to-sidecar layout inside the sandbox.
5. Close inherited file descriptors except bounded standard output/error,
   /dev/null stdin and the explicit supervisor channel. Use no interactive TTY.
   Prove namespace separation and inaccessible host sentinels before proceeding.
   Do not test isolation by contacting a real provider or memory endpoint.

Initial Pi argv inside that sandbox is fixed:

    <exact-mounted-pi> --offline --no-approve --no-extensions --no-mcp --no-skills --no-prompt-templates --no-themes --no-context-files --no-tools --no-session --system-prompt fixture-only-system --append-system-prompt fixture-only-append --extension <read-only-probe.mjs> --help

The placeholders are sandbox paths selected and logged by the runner.
They are not PATH lookups or an instruction to execute this command unsandboxed.
No initial prompt, @file, resume argument or SDK module import is allowed.
The explicit prompt strings prevent separate SYSTEM.md/APPEND_SYSTEM.md lookup.
Use empty controlled settings with telemetry disabled where supported.
Observe startup writes in the disposable directories rather than assuming none.

### Binding protocol to test, not an existing Pi contract

The protocol is Dotfiles experiment plumbing. It introduces no Nucleus interface.
The inner supervisor launches the exact ELF directly with shell:false.
It creates a dedicated inherited duplex channel, proposed as descriptor 3.
Bun support for that channel is a hypothesis to test; an unsupported channel
ends the experiment. Do not fall back to an environment nonce or writable ticket.

The supervisor owns a fresh random invocation ID, its own process identity,
child PID and start time, expected executable identity, and a single-use claim.
The probe sends bounded, schema-checked handshake data over that channel.
After exec, the supervisor opens the actual direct child's /proc/<pid>/exe.
It uses that open handle for fstat and hashing, then checks PID/start time again.
It compares the running executable against the selected artifact before replying.
PID and start time alone do not suffice because exec can retain both.

The response names the expected current PID, start time, invocation and artifact.
The probe derives its PID from process.pid and checks its own process against
that response before acknowledging the observation.
Compare the loaded host VERSION with the pinned sidecar as a consistency check.
Both sides fail closed on missing /proc access, unknown fields, incomplete frames
at EOF/deadline, oversized input, timeout, premature EOF, duplicate claim or mismatch.
Normal stream fragmentation is allowed within the frame and deadline limits.
After the probe confirms its validated acknowledgement, expect channel closure
with a clean child exit. That expected closure is not a protocol failure.
Only the outer runner can accept the final complete supervisor result; an
unexpected supervisor death before that result fails the run.
No claim can be reissued after supervisor restart or replayed into another launch.
Do not rely on argv, process title, ctx.mode or an arbitrary ancestor as identity.

Pin the probe, supervisor and relevant package resources as well as the ELF.
Check their manifest before and after loading. A read-only mount does not freeze
outside changes to the underlying files. Any observed change invalidates the run.
This is a change detector under the trusted local-user model, not atomic loaded
module attestation. The compiled ELF narrows the earlier Node module-cache gap;
it does not prove every external resource immutable.

The factory awaits that acknowledgement before reporting success and returning.
The acknowledgement proves factory execution at that moment. It returns no
lasting capability and grants no session or callback authority.
--help then exits. Native probes do not import the memory core, invoke its CLI,
register a production descriptor, request recall or admit any memory.
The channel is per-run and disappears at exit; there is no listener service.

For synthetic tests only, put the accepted scope in a closure around callbacks.
Bind it to one explicitly fresh initial session. Check scope before each event,
then allow only the expected session ID and fake operation sequence.
Invalidate on new/resume/fork/reload, different session, runtime change or lost
supervisor channel. Test exact native startup reason separately in later work.
Do not claim instantaneous atomic revocation between a check and an operation.
The current experiment has no real operation during that race.

### Acceptance matrix and evidence labels

| Case | Required observation | Evidence class |
|---|---|---|
| Confinement preflight | Separate namespaces; host sentinels and sockets inaccessible; only private outputs writable | Local sandbox test, before Pi |
| Exact selected binary | One probe factory loads; one matching process claim; --help exits successfully | Actual isolated native load |
| Ordinary launch without channel | Probe refuses scope; no successful claim | Actual isolated native negative |
| Different current executable | Selected Pi metadata cannot authorize a Node fixture process | Synthetic process negative |
| Nested child with inherited environment | Child cannot use parent's scope; wrong current PID refuses | Isolated child negative |
| Explicit channel inheritance/replay | A nested child inheriting FD3 reports its own process.pid and is refused; duplicate/replayed claims invalidate the run | Channel/process negative |
| Sidecar or package override | Controlled fixture mismatch refuses; ambient PI_PACKAGE_DIR never reaches Pi | Fixture plus launch-environment assertion |
| Changed/deleted resources or executable | Drift invalidates the run; old process cannot qualify from new disk metadata | Disposable fixture; never mutate mise files |
| Supervisor exit/timeout/partial response | Before acknowledgement, no accepted handshake; after acknowledgement, invalidate final result; bounded cleanup | Process/channel negative |
| SDK claims TUI; wrong mode | No grant without the launched process identity; mode alone has no authority | Synthetic fixture, not SDK qualification |
| Fresh session then changed lifecycle | Only intended fixture sequence passes; other sessions and reload/resume/fork/new reject | Synthetic callback fixture only |
| Production safety regression | Existing activation still returns native-caller-binding-unqualified | Existing isolated CLI test |

Every rejected fixture must show zero additional fake recall and admission calls
from the rejected step. Reset counters or record deltas after a positive prefix.
Every native probe, including the positive probe, must show zero real memory
operations. An extension log alone does not prove the supervisor accepted it.
Require matching supervisor records, exit status and complete bounded output.
A handshake acknowledgement is an observation, not the final pass. Later duplicate
claims, drift, unexpected supervisor death or output failure invalidate the run.
Keep the earlier observation in the report; do not claim it never occurred.
Missing output, skipped tests, timeouts and unavailable isolation are unproved
results, never passing acceptance.

Synthetic positive fixtures may count fake session, recall and capture calls.
Label those counts as fixtures. No native user prompt or completed assistant
turn is produced in this experiment. Original-prompt eligibility remains open.
Do not weaken this distinction by fabricating an agent_end event inside Pi.

Use a five-second handshake timeout, a twenty-second per-process deadline and
a ten-minute overall experiment limit. Bound output to 256 KiB per process.
Output overflow fails the run; truncation cannot yield a passing result.
On timeout terminate only experiment-owned processes, then reap them.
Record residual processes as failure. Never kill unrelated Pi sessions.
These are test limits, not the 100 ms local-admission target.

Save the exact candidate commit, executable/resource manifest, namespace checks,
argv, allowed environment key names, counts, reason codes and cleanup result.
Retain bounded private diagnostics outside version control. Commit the concise
findings to this canonical item. Never record ambient environment values or keys.
No new Grok review is part of this plan; previous review budgets are not reused.

### Self-review and revisions

| Weakness in the initial approach | Revision |
|---|---|
| A Node/npm launch assumption mismatched the installed archive | Target only the actual compiled ELF and adjacent resources |
| Disable flags looked like sufficient isolation | Require OS confinement; package resolution happens before filtering |
| A marker could reach child tools or a nested Pi | Use a supervisor-owned one-use channel plus actual current process checks |
| A writable launch record could become self-issued scope | Remove file tickets; test inherited channel support and stop on failure |
| PID/start time survive exec; disk files can change | Verify the running executable and resource manifest, and state race limits |
| Session-start shutdown looked like a simple native smoke test | Remove TUI/session startup from this first experiment |
| Synthetic callbacks could be presented as native coverage | Separate evidence classes; keep native session and prompt eligibility open |
| Namespace support and inherited-FD behavior were assumed | Make both explicit preconditions, with no weaker fallback |

The parent reviewed this plan and incorporated read-only source and acceptance
reviews. Security review accepted the narrowed factory-load proposal with corrections:
bounded acknowledgement, an opened executable handle, no lasting capability,
post-acknowledgement invalidation, rejected-step counter deltas, explicit FD3
child inheritance and output-overflow failure. These are normal plan reviews, not the independent ExitGate.

### Approval and next boundary

Implementation approval would authorize only the experimental files, focused
synthetic tests, confinement preflight, bounded isolated --help probes, review,
local findings and local commits described here. It would not authorize a native
conversation, production caller binding, an installed launcher, publication,
push, main merge, host rollout or live provider/memory calls.

After an approved experiment, report whether process-scoped extension loading
worked. If it failed, preserve the blocker and stop. If it passed, propose a
separate no-provider native session experiment before changing activation.
Keep all other route, macOS, durability and full ExitGate obligations open.

## Pi launch experiment results

Recorded on 2026-10-18 after Peter approved the bounded implementation and execution preview.
This section supersedes the design-only status in the historical proposal above.
The full work item remains Active. Its ExitGate remains unpassed.

### Implemented candidate and scope

The parent integrated the experiment as c5c83ac4912e68927a7862c276fa751def0cd7c6.
The reviewed output-safety repair is 1fb18fac1944b5b3fba4b7466bc9a9d2074492b2.
The latter is the exact tested native candidate. Experiment files were committed and clean.
Only the canonical work item had pending documentation changes during execution.

All executable additions are under tools/hindsight-memory/experiments/pi-launch/.
The harness reuses createPiAdapter with a fake invoker for synthetic callback tests.
It adds no Nucleus interface and duplicates no memory-core policy or delivery logic.
Production activation still refuses with native-caller-binding-unqualified.
No production adapter, installer, profile, app selection or live configuration changed.

The fixed sandbox uses Bubblewrap 0.11.1 and Node 24.22.0.
The Pi ELF and sidecar hashes match the exact pins in the proposal above.
The package manifest digest was f2a84302f1154e2ffbb334b28cf6595454f5435b751e43374d82f256fba0d382.
Mise remains the sole owner of the installed Pi distribution.

### Verification and native outcome

| Check | Result and limit |
|---|---|
| Existing adapter and qualification tests | Parent passed 19/19 before experiment integration; source and synthetic evidence only |
| Focused experiment tests | Parent independently passed 35/35 at 1fb18fac1944b5b3fba4b7466bc9a9d2074492b2; 0 failures, 0 skipped |
| Confinement preflight in the native run | Passed namespace, hidden-path, environment, read-only-mount and unreachable host-loopback fixture checks |
| Inner-supervisor death preflight | Passed; four observed experiment processes reaped |
| Outer-parent death preflight | Passed; five observed experiment processes reaped |
| Native positive factory-load probe | Failed; probe reported `Socket is closed`; supervisor reported `incomplete-handshake` |
| Native missing-channel and nested cases | Both skipped because the positive channel prerequisite failed |
| Native session, original prompt, completed turn and capture | Not tested; no acceptance claim |
| Production safety fixture | Activation remains refused; private fake configuration and loopback request counter were used |

The one native run started at 2026-10-18T09:23:25.588Z.
It ended at 2026-10-18T09:23:28.486Z with runner exit status 1.
The outer reason is `supervisor-exit`.
The inner reason is `incomplete-handshake`.
The probe diagnostic is `probe-refused` with reason `Socket is closed`.
Pi printed its help text. The explicit probe factory executed its error path.
That is a load observation, not successful caller verification.
HELLO, ACK and DONE observations were all false.
The saved `claim` contains supervisor-created expected identity, not an accepted claim.

The evidence establishes that this channel construction failed in this exact run.
It does not establish why the socket closed.
Compiled Bun compatibility, descriptor adoption and channel lifecycle remain possible causes.
Do not conclude that all Bun extra-descriptor support is impossible.
No alternate channel, environment nonce, writable ticket or native rerun was attempted.

The no-core probe, absent service state and separate network namespace prevent this
experiment from exercising the real memory path. This is structural evidence,
not a measured production memory-operation counter. No conversation was started.
The synthetic fresh-session and rejected-step counter results are separate evidence.
The 100 ms durable-admission target was not measured by this launch experiment.

### Security review, corrections and evidence limits

A normal independent security review found a host output-write escape before native execution.
A sandbox-created output symlink could have redirected a host-side diagnostic save.
The fix anchors no-follow directory handles, creates exclusive temporary files,
rejects unsafe entries and uses atomic rename. It never truncates an existing target.
Bounded diagnostic reads validate type, owner, mode, link count and size after cleanup.
Regression fixtures preserve a harmless host victim and reject links and special targets.
ACK evidence now changes only after the send succeeds; the failed-send fixture passes.

The reviewer cleared the frozen repair caf0b41f7a10512b84be458044cc28838c57de25
in the isolated worker checkout. The parent cherry-picked it as 1fb18fac1944b5b3fba4b7466bc9a9d2074492b2
and independently ran all 35 focused tests before native execution.
The reviewer then inspected the failed native report through the guarded reader.
No remaining execution blocker or unsupported success claim was found.
These are normal implementation and outcome reviews, not an ExitGate.
The previous Grok verdict covers the earlier implementation, not these experiment files.
No additional paid review was run.

All ten produced diagnostic files passed guarded validation.
The final tracked-process check reported no live tracked residuals or cleanup failure.
The PID namespace and successful parent-death preflights support bounded cleanup confidence.
The failed positive report does not retain a separate process inventory or child-exit record.
That limits independent reconstruction; do not infer a recorded clean Pi exit from help output.
Any future diagnostic revision should retain those failure details before another run.

Private raw report: /var/tmp/hindsight-pi-launch-LG6TxF/report.json.
Its manifest and phase diagnostics are beside it in the same private run directory.
Inspect them with readEvidence from the experiment's safe-output.mjs.
Do not blindly follow sandbox-created filenames with ordinary file readers.
The raw output remains outside Git; this committed section preserves the substantive result.

Preparation currently copies dormant experiment sources because its traversal excludes
only test and node_modules directories. The runner refuses execution outside its own
Git source checkout. Packaging exclusion or an explicit disposition remains required
before publication. Production packaging was not changed in this bounded experiment.

### Next boundary

The approved experiment has stopped at its failed channel prerequisite.
The next proposed step is read-only diagnosis of the exact compiled Pi/Bun transport.
It should distinguish descriptor adoption from lifecycle behavior and propose one bounded
instrumentation change. It must preserve the current isolation and identity requirements.
Present that concrete change before any additional native run or alternative transport.

All native session, prompt-origin, other-agent, macOS, durability and ExitGate obligations remain open.
Publication, push, main merge, an installed launcher, production activation and live rollout
still require Peter's explicit approval.

## Pi transport read-only diagnosis

Read-only diagnosis completed on 2026-10-18 under Peter's explicit approval.
No Pi or Bun process was started. No experiment, adapter or installer code changed.
This section narrows the unresolved cause recorded in the preceding experiment results.

### Supported cause

The chosen Socket constructor does not attach descriptor 3 in this exact Bun build.
The resulting Socket has no native handle. Its first HELLO write therefore fails.
This explains the observed error without requiring the operating system to close descriptor 3.

The pinned Bun constructor validates the numeric fd but leaves _handle null and connecting false.
Its read path waits for a connection. Its write path reports ERR_SOCKET_CLOSED when the handle is absent.
The experiment creates that Socket and immediately writes HELLO; it never establishes a different connection.
Node 24.22.0 has an explicit descriptor-adoption branch, which this Bun constructor lacks.

Primary sources inspected:

- [Bun constructor, pinned revision](https://github.com/oven-sh/bun/blob/0d9b296af33f2b851fcbf4df3e9ec89751734ba4/src/js/node/net.ts#L661-L780).
- [Bun read path](https://github.com/oven-sh/bun/blob/0d9b296af33f2b851fcbf4df3e9ec89751734ba4/src/js/node/net.ts#L1230-L1237).
- [Bun write path](https://github.com/oven-sh/bun/blob/0d9b296af33f2b851fcbf4df3e9ec89751734ba4/src/js/node/net.ts#L1440-L1466).
- [Node descriptor adoption](https://github.com/nodejs/node/blob/v24.22.0/lib/net.js#L698-L718).

The current [Bun compatibility page](https://bun.sh/docs/runtime/nodejs-compat#node-net)
also warns that this constructor cannot read an existing descriptor.
That floating page describes newer behavior too; the pinned source and installed bytes govern this diagnosis.

### Link to the installed artifact

Static inspection of the installed Pi ELF found the banner Bun v1.3.14 (0d9b296a), Linux x64 baseline.
GitHub resolves that revision to 0d9b296af33f2b851fcbf4df3e9ec89751734ba4.
The ELF hash still matches c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca.
The banner alone is not a reproducible-build attestation.

The ELF also contains readable built-in JavaScript matching the relevant behavior:

| Embedded body | Byte offset, zero-based | Observation |
|---|---:|---|
| Socket constructor | 30807286 | Validates fd; initializes null handle; does not attach fd |
| Socket write method | 30825976 | Missing handle selects the socket-closed error path |

Both bodies were inspected without executing them.
The cached pinned net.ts has SHA-256 54eb74326b2ab42d9d9a740df8da6f243ab6683b1b664fecfb30a5bc92bc158b.
Private source copies, byte extracts and provenance are under /var/tmp/dotfiles-pi-transport-duw9yg7c.
They are read-only research inputs, not replacement runtime files.

The existing guarded diagnostics were reread from /var/tmp/hindsight-pi-launch-LG6TxF.
They still show probe-refused / Socket is closed and incomplete-handshake, with HELLO/ACK/DONE false.
The old diagnostic recorded the message only. ERR_SOCKET_CLOSED is the source-supported error path,
not a newly observed error.code or captured runtime stack.

### What remains unknown

- Whether descriptor 3 remained open, and its exact type, when the factory ran.
- Whether another supported public API can safely use that inherited channel in this compiled runtime.
- Whether any proposed replacement preserves bounded IO, cleanup and the current process checks.
- Native session attachment, prompt provenance, completed-turn capture and all other open qualifications.

The diagnosis does not prove that Bun rejects every inherited descriptor.
It does not justify changing runtime versions, calling connect with guessed arguments,
using internal handles, or replacing process checks with an environment marker.
The existing process claim was expected identity only; it never passed live verification.

The 35 focused tests used injected Node streams for the relevant transport fixtures.
They test framing and rejection logic, not this compiled Bun constructor.
Their earlier passing result remains valid within that scope. No tests were rerun for this documentation-only diagnosis.

### Reviewed next step

Independent read-only review confirmed the pinned source, embedded bodies and unchanged ELF hash.
The reviewer agreed that another native run is unnecessary to establish this constructor limitation.
This normal diagnosis review is not an ExitGate.

The recommended next step is source-only design of a supported replacement transport.
It must identify an actual public interface before proposing implementation.
Preserve the exact artifact, private namespaces, fixed argv, limits and supervisor-owned process checks.
Do not assume that Node stream compatibility extends to the compiled Bun runtime.

A separate diagnostic is useful only if descriptor availability becomes a decision-making input.
If Peter approves that specific question later, the bounded proposal is:

1. Add diagnostic reporting only, keeping the failing constructor and transport unchanged.
2. Record non-consuming fstat/readlink observations of fd 3 before and after construction, and on first-write error.
3. Record stage, bounded error code/message, public stream flags and available Bun version/revision fields.
4. Preserve the actual child exit and tracked PID/start-time cleanup inventory even on failure.
5. Review the change and synthetic reporting fixtures, then run one positive --help probe after the same preflights.
6. Read outputs with the guarded reader, save the result locally and stop. No negative phase or automatic retry follows.

Diagnostic failures must be recorded as unavailable without hiding the original error.
This proposal adds no connect/open/read/dup/close fallback, raw IO, mount, environment key, endpoint or privilege.
Neither that implementation nor a native rerun is authorized by the current read-only approval.

Publication, push, main merge, production activation and live rollout remain separate approvals.
The canonical work item remains Active with ExitGate false and all unfinished obligations preserved.

## Pi-first restricted contract and isolated candidate

Recorded on 2026-10-18 under the approved Pi-first continuation. Source investigation supports the restricted contract, not a qualified native route. Implementation, focused synthetic tests and normal review completed locally. The integrated code is `4ecb36384ff2e41e27ae2c5dac06d62e9cc667a8`, cherry-picked from tested worker commit `15b83ea94f66a521c2b101f4aa269bdea214c7ef`. Both commits have the same `tools/hindsight-memory` tree `95a8713be7334c137bef6c0481cfdc356d63b885`. Tests were not repeated after that identical-tree integration. Native execution remains unapproved. Production activation still refuses with `native-caller-binding-unqualified`.

### Restricted candidate and workflow cost

The candidate uses the existing memory core through one ordinary in-process Pi bridge. It adds no transport supervisor, provider abstraction, queue or Nucleus interface.

The supported candidate is **Linux compiled Pi 1.3.0 TUI only**. Qualification checks the actual `/proc/self/exe` ELF hash and exact `process.argv.slice(2)`. The expected artifact has SHA-256 `c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca`. That parsed argument slice must select `--no-extensions -e <sole bridge>` with no additional route or prompt arguments. TUI mode alone, a version string, an installed-file hash or an inherited marker cannot grant capture authority.

Pi changes `process.title` before loading the factory. Raw `/proc/self/cmdline` preservation is therefore unproved and is not part of this contract. The candidate uses the same parsed API slice that the pinned CLI passes to `main`; it assumes nothing about `argv[0]` or `argv[1]` and has no procfs-cmdline fallback. Native validation remains pending.

The user's workflow requires that restricted invocation, native `/new` into a new session containing only expected startup metadata, then acceptance of the destination confirmation dialog. The bridge asks through `ui.confirm` when native `session_start` reports a new session. No custom consent command is added. Existing arbitrary global extensions are unavailable in this candidate invocation. Consent binds the current process, session and destination. It is not inherited by nested agents, resumed sessions or later launches. A missing or changed prerequisite refuses capture.

This cost is explicit. It does not establish ordinary unmodified Pi launches as qualified. Pi 1.1, other extension sets, SDK, RPC, queued/streaming prompts and non-Linux hosts remain unqualified obligations. Their absence from this candidate does not cancel their coverage requirements.

A genuine `/new` is not an empty branch array. The allowed startup branch is exactly one `thinking_level_change`, or `model_change` followed by `thinking_level_change`. The model entry has string `provider` and `modelId`; the thinking entry has string `thinkingLevel`. The root/child parent chain must match. Any conversation, extra entry, malformed metadata or change during consent refuses qualification. The session header is outside `getBranch`, so array length alone cannot prove freshness.

### Input, completion and lifecycle contract

| Boundary | Candidate rule |
|---|---|
| Fresh session and consent | Observe native `/new` into a new session containing only expected startup metadata before explicit destination consent; bind consent to the current process and session |
| Original input | Accept one idle Pi-normalized trimmed interactive prompt; reject commands, file-content expansion, images, queued or streaming input |
| Staging | Match that submitted text against validated `before_agent_start` before staging through the existing single-pending-turn core contract |
| A second input | Invalidate the entire pending pair rather than pairing an earlier prompt with a later answer |
| Completion identity | Use the stable persisted assistant `messageEntryId` from `turn_end`; do not use transcript array length or a synthetic counter |
| Final completion | Complete the existing stage only after `agent_settled`, with a matching successful final stop; `agent_end` alone is insufficient |
| Recall | Attach request-local custom recall; never treat that recall as user text or capture it again |
| Lifecycle | Invalidate consent and pending capture on session, destination, runtime or route change; resume/fork/reload/history cannot inherit consent |

The input handler receives prior extension transformations. Requiring this bridge as the sole extension removes that earlier-transform ambiguity. The pinned TUI trims submitted text, queues it and passes it directly to `session.prompt`. The captured original is therefore Pi-normalized trimmed submitted text, not raw keystrokes. That path does not expand `@file` contents. CLI initial `@file` processing remains outside this candidate because positionals are rejected.

The sole-extension flags constrain the final loaded extension list. The loader still resolves packages before filtering; this restriction does not prevent package resolution. Rejection must be local and visible, without substituting branch history or suppressing a memory-core error.

### Source evidence and remaining checks

The source cache is `/var/tmp/dotfiles-pi-contract-Cun2U5`, pinned to Pi commit `71023aec1546d6d677a65669c5665c0927ce0dd0`. Its `agent-session.ts`, `runner.ts` and `types.ts` were inspected without executing Pi. The phase scout also checked the pinned TUI submission path, CLI argument parsing and resource loader.

- [Input dispatch, command handling and default source](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/agent-session.ts#L2058) establish that input interception precedes skill/template expansion, but extension commands run first and omitted source defaults to interactive.
- [Sequential input handlers](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/runner.ts#L1525) pass transformed text and images to later extensions. Interactive source alone cannot prove original text.
- [Persisted completion identity](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/agent-session.ts#L850) resolves the assistant entry before `turn_end` and reports an error when no ID exists.
- [Final settlement](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/extensions/types.ts#L1032) is a distinct event after automatic retry, compaction and queued continuation stop.
- [TUI submission normalization](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/modes/interactive/interactive-mode.ts#L2985) trims and queues submitted text. The [main input loop](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/modes/interactive/interactive-mode.ts#L1168) submits the queued text to the session.
- [Extension flags](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/cli/args.ts#L181) and the [final explicit extension list](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/resource-loader.ts#L541) support the sole-extension restriction. [Earlier package resolution](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/resource-loader.ts#L496) still occurs.
- [CLI entry](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/cli.ts#L5) calls setup before passing `process.argv.slice(2)` to `main`. The checked main/TUI source has no later writes to that parsed slice. This corrected the earlier raw-procfs-cmdline proposal; no native observation is inferred.
- [Startup metadata before session events](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/sdk.ts#L427) and [branch traversal](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/core/session-manager.ts#L1368) require the two-form startup-metadata check. An empty array is not the native `/new` contract.

These are source observations. They are not native input, provider, recall, durable-admission or completion evidence. The implementation changed exactly these paths:

| Path | Change |
|---|---|
| `tools/hindsight-memory/adapters/pi.mjs` | Restricted current-process checks, fresh consent and staged prompt/completion matching |
| `tools/hindsight-memory/adapters/manage.mjs` | Pass the generated bridge URL into Pi initialization |
| `tools/hindsight-memory/src/state.mjs` | Check optional expected destination against active SQLite configuration |
| `tools/hindsight-memory/src/delivery.mjs` | Carry the existing active-state check into recall |
| `tools/hindsight-memory/test/pi-candidate.test.mjs` | Focused synthetic candidate and real temporary-core fixtures |
| `tools/hindsight-memory/test/adapters.test.mjs` | Preserve existing adapters and reject unqualified Pi invocations |
| `tools/hindsight-memory/adapters/README.md` | Exact candidate contract, workflow cost and evidence limits |

Normal review found that `config.json` and the active SQLite destination could drift. The worker added an optional `expected_destination` digest to Pi envelopes, checked through the existing `Store.active(input)` path for registration, admission and recall. It reuses the core and queue; no new schema or CLI verb was added. The focused normal reviewer cleared the destination, stale-consent and freshness findings. No actionable finding remained in that review. This was not an ExitGate.

The initial concurrent component run reported 108 tests: 107 passed and one existing Codex integration failed with `state_busy_admission_not_confirmed`. A targeted `integration.test.mjs` rerun passed its one test, covering 30/30 Codex turns. After the destination fence and metadata repairs, the serial full component suite passed 112/112 with Node 24.22.0. The final suite included all 22 Pi-focused tests and 15 existing adapter tests. Their last standalone combined run passed 36/36 before the final metadata-race test was added; all final 37 passed within the 112-test suite. There was no standalone 37-test run. The targeted rerun and final serial pass do not erase the earlier concurrent failure.

The exact final worker command was:

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-concurrency=1 tools/hindsight-memory/test/*.test.mjs
```

It ran in `/var/tmp/dotfiles-pi-bridge-T7Dv31` before cleanup. The last standalone focused command used `--test tools/hindsight-memory/test/pi-candidate.test.mjs tools/hindsight-memory/test/adapters.test.mjs`. The targeted Codex command used `--test tools/hindsight-memory/test/integration.test.mjs`, with the same absolute Node executable.

The worker checkout was removed after its component tree matched the integrated commit. The source branch `codex/pi-first-bridge` was preserved.

The normal reviewer inspected the final diff and `git diff --check`, plus the earlier 19-case focused test result. The reviewer did not rerun the final full suite. The final 112/112 result is the worker's attestation, not a reviewer execution. No native rerun, provider request, installer change, publication, push, main merge, paid review or live action was performed in this continuation.

### Next native experiment preparation

Source research supports a local fake OpenAI-compatible SSE provider through private Pi model/settings files. It needs no external provider key or paid quota. That is a candidate test path, not an executed provider or native-completion result.

The existing harness runs help-only probes. It has no PTY allocator and no loopback-listener preflight inside the same network namespace. The native test is therefore not ready to run. Do not request execution approval from this incomplete preview.

A later bounded continuation can build experiment-only PTY support, the private fake provider and memory endpoints, same-namespace listener preflights, and focused synthetic checks. Preserve existing confinement, identity, time/output limits and cleanup requirements. Then present the exact artifact, argv, event path, fake endpoint, limits, cleanup and stop rule for separate native execution approval. No harness expansion was performed in this checkpoint. No native launch follows from building those artifacts.

All other route, host, durability, packaging, performance and ExitGate obligations remain open. The item remains Active with ExitGate false.

## Pi native-turn experiment ready for approval

Prepared on 2026-10-18 under the existing isolated Pi-first authority. No native execution occurred. The runnable code is integrated at `360726ec276fd42f760430d9536923a0d749a077` through `a82996d`. Its eight executable/fixture files match tested worker commit `f2a76c10e7acfdd4aa511eae62ae63a5af1a42f2`, following `00e509b06db07fa797f0bcf134610452701a5d4c`. Only experiment files were added; the bridge, core, installer and failed FD3 experiment are unchanged.

The reviewed executable preview (`tools/hindsight-memory/experiments/pi-turn/README.md`, last present in commit `b170d88`) owns the exact command, environment, mounts and acceptance. The command to present for separate approval is:

```sh
cd /home/fodurrr/dev/dotfiles
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --native
```

The runner requires clean committed component sources. Its default and `--preflight-only` modes run only our own Node surrogate through Python. The explicit native mode first repeats five harmless preflights, then starts exactly one selected Pi ELF as `/pi/pi --no-extensions -e /work/sole-bridge.mjs`. No extra provider extension, arbitrary flags or production activation bypass exists.

### Fixed native approval scope

The future native phase has exactly two local fake-provider turns. The first supplies a history sentinel before consent and must create no memory session, job or recall. Native `/new` then opens the real destination dialog. One LF accepts its default Yes, as proven by the pinned selector source. The second fixed prompt must produce genuine persisted completion and `agent_settled` observations through the existing bridge/core.

Acceptance requires two model requests, one original-prompt recall, two bank checks, two exact retained messages, two completed operation polls and two durable completed jobs. History and recalled/tool/reasoning sentinels must not enter retention. Callbacks fabricated by the harness cannot satisfy these native conditions. The PTY child is deliberately stopped after acceptance; its actual exit and reaping are recorded, without claiming natural clean Pi shutdown.

Private model/settings files use the source-proven OpenAI-compatible SSE fixture. Tools, cache warming and Pi/provider retries are disabled. Both provider and Hindsight fixtures run inside the private network namespace. Dummy keys and a private `Store.activate` test seam are used; no personal bank, real provider, service or production CLI activation is touched.

The exact 15-key environment is constructed after clearing ambient values. Read-only mounts contain the pinned package, named component/helpers, Node, Python, 37 exact Python standard-library files and nine named shared libraries. Host home, repository, sockets and credentials remain hidden. The report directory is the only host-writable mount. No runtime is installed or newly owned.

Preview bounds are 180 seconds overall, 60 seconds per sandbox and 45 seconds for the native PTY. Provider requests have a five-second timeout and no retry. Process output is capped at 256 KiB; raw terminal output at 128 KiB; request bodies at 64 KiB; fixture HTTP requests at 12. These are the explicit two-turn preview limits, not the prior help-only probe limits.

The first prerequisite, identity, source, protocol, count, deadline, output, drift or cleanup failure stops the experiment. There is no automatic native retry. PID/start-time tracking, namespace teardown and both parent-death preflights enforce cleanup. Guarded no-follow evidence writers/readers remain in use. Reports distinguish requested/attempted native work from exact-ELF observation; after an attempt, not-observed never proves no native execution.

### Verification and review

Worker command:

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test tools/hindsight-memory/experiments/pi-turn/test.mjs
```

The final frozen candidate passed **9 tests, 0 failures**. Its five harmless phases passed: scripted PTY I/O, deadline, overflow, inner-supervisor death and outer-parent death. Both private endpoints were reachable; the host listener was unreachable. Every observed descendant was reaped. These observations qualify the harness, not native Pi.

The normal reviewer cleared the final code and preview documentation. Supported fixes included narrowing Python mounts around packaging symlinks, bounded single-copy diagnostics, preserved primary failure/exit evidence, and a top-anchored Git cleanliness check. A temporary-Git regression proves tracked and untracked changes are detected from the nested experiment directory. The initial clean-status report was incorrect before that fix; no native execution used it.

The supervisor inspected the final report with `readEvidence`, confirming passed phases, no native request/attempt and `nativeExecuted:false`. Private report: `/var/tmp/hindsight-pi-turn-z2TE0d/report.json`. Raw output stays outside Git. Tests were not repeated after integrating identical executable files. The unchanged 112-test component suite was not rerun. Its earlier parallel contention failure remains unresolved and preserved.

No Pi/Bun/client execution, upstream module import, external provider request, installer or live change, publication, push, main merge, paid review or Nucleus communication occurred. The normal review is not ExitGate. The work item remains **Active**, ExitGate **false**, with all other route, host, durability, packaging, performance and live-API obligations open.

## Pi native-turn acceptance result

Run on **2026-10-18** at clean source **892994e90b4ae53ee190d22acbebed444875a91b** on GEEKOM Linux. Peter directly approved: “Run the bounded Pi test with delegated work, review and save results locally. No Nucleus communication. Publication, main merge and live rollout still need my approval.” Approval covered the frozen preview and one invocation, not modified native retries.

A fresh native OpenAI supervisor delegated execution/evidence to one worker and independent outcome review to a read-only reviewer. The supervisor did not repeat the native command. Sandbox-created files were inspected through `readEvidence`. Raw diagnostics remain outside Git.

### Exact execution and first failure

The worker ran this command **once** from `/home/fodurrr/dev/dotfiles`:

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --native
```

The runner started at `2026-10-18T14:35:15.921Z` and finished at `2026-10-18T14:35:19.816Z`. It returned **exit 1**, with first failure **`unsafe-private-path`**. No fix, fallback or retry followed. Executable/fixture files matched tested worker `f2a76c10e7acfdd4aa511eae62ae63a5af1a42f2`; cleanliness and ELF/sidecar pin checks passed.

| Observation | Recorded result |
|---|---|
| Scripted PTY, deadline, overflow, inner-supervisor death, outer-parent death | All five harmless preflights passed and reported reaped |
| Native sandbox confinement prerequisites | Passed; private endpoints reachable, host loopback unreachable, host files hidden, mounts read-only |
| Outer native request and phase attempt | Both true; outer attempt marks sandbox launch |
| Inner Pi launch attempt and PTY driver | Both false |
| Exact pinned Pi ELF | Not observed; `nativeExecuted:false` |
| Native sandbox/Pi exit or intentional stop | No exit record or observed native forced stop; no natural zero exit claimed |
| Native event/service/session/job counters | Unrecorded; no measured zero counts |
| Two conversations, actual consent, persisted completion, recall and delivery acceptance | Not reached; remain unqualified |

After an outer attempt, not-observed alone cannot prove no native execution. Here the inner supervisor reports failure before driver startup and no inner Pi launch attempt. No native completion evidence exists.

### Source diagnosis and independent normal review

The worker and independent native OpenAI reviewer identified one **P1 blocker**. `policy.mjs:61` creates `/agent` through `--tmpfs` without `--perms`. Installed Bubblewrap documentation specifies default mode `0755`. `supervisor.mjs:103` calls `writePrivate('/agent/models.json', ...)` before `tty()` at line 105. `src/config.mjs:18` rejects group/other permissions on its existing parent. Only `/work` is made private before that write.

This explains the failure through source inspection. The report lacks a failing path or stack; call-site attribution is an **inference**. No implementation changed. The minimum later correction is a private `/agent`, with a harmless regression covering native setup before a revised native preview.

The reviewer guarded-read the report, manifest, native input and every listed diagnostic. It confirmed the blocker, launch distinctions, unknown counters and missing failed-phase checks. Its fresh identity check found no observed process alive. This normal review is **not ExitGate**.

### Cleanup, private evidence and limits

Private report: `/var/tmp/hindsight-pi-turn-gdwBMu/report.json`. Adjacent `manifest.json` and phase files preserve evidence. All 15 listed diagnostics were guarded-read. Native supervisor stdout is 1299 bytes; stderr is empty. No native terminal file exists because the driver did not start.

An independent observer tracked **30 PID/start-time identities**, including the runner. Guarded-read `/var/tmp/hindsight-pi-turn-observer-Vv8pdu/cleanup.json` records `allGone:true` and no residual identity after two seconds. Fresh worker and reviewer checks found none alive. The worker's guarded-read `recheck.json` records zero occupants of the six native sandbox namespaces and removal of the host socket. The supervisor guarded-read the report and observer evidence.

The failed phase skipped postphase drift/contact assertions. Its report omits native sandbox code/signal and an explicit native cleanup marker. Independent process evidence supports observed cleanup; it does not fill missing exit or counter records. Pre-failure confinement and prior preflights remain valid within their scope.

The earlier 112/112 serial component suite and 9/9 harness suite were **not rerun**. The earlier parallel Codex contention failure stays unresolved. No external provider/personal memory call, credential use, installer/production change, Nucleus communication, paid review, publication, push, main merge or live rollout occurred.

**Next action:** present the bounded permission fix and harmless native-setup regression for approval. Any new native attempt needs a revised exact preview and separate approval. Production remains **`native-caller-binding-unqualified`**. Other route, host, durability, packaging, performance and live-API obligations remain open. The item remains **Active**, ExitGate **false**.

## Pi fixture permission correction

Saved on **2026-10-18** under existing isolated implementation/test authority, after the failed-run checkpoint `1df4b8311716e2e46b04840b2834ce7a13d21862`. No new native execution was authorized or performed.

The minimum correction is committed at **`fd15a9811d6b29a380d40ae228684c89ff3d93f1`**. Four files changed under `tools/hindsight-memory/experiments/pi-turn/`: `policy.mjs`, `supervisor.mjs`, `test.mjs` and `README.md` (20 insertions, 2 deletions).

Only `/agent` receives `--perms 0700` before its tmpfs mount. Native mode and the harmless preflight share the actual `prepareNative()` function. The preflight performs the same Store fixture, bridge, model and settings preparation before starting the Node surrogate. It imports no Pi, Bun or upstream client. The core private-path guard and existing isolation remain intact.

The worker first reproduced `unsafe-private-path` through that harmless path. Private red report: `/var/tmp/hindsight-pi-turn-xaemN4/report.json`. It then applied the permission fix and ran:

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test --test-name-pattern='fixed native arguments|harmless confined PTY preflights' tools/hindsight-memory/experiments/pi-turn/test.mjs
```

**Two selected tests passed, zero failed**, including all five harmless preflight phases. Private green report: `/var/tmp/hindsight-pi-turn-1FvKV2/report.json`. It records `/agent` mode `0700`, model/settings modes `0600`, every phase reaped and no cleanup failure. Native request, attempt and execution are all **false**, with evidence `not-requested`.

These tests covered the uncommitted patch atop `1df4b8311716e2e46b04840b2834ce7a13d21862` (`sourceDirty:true`). The independent normal reviewer matched recorded fingerprints to the final files and found **no actionable findings**. Those identical files were committed as `fd15a9811d6b29a380d40ae228684c89ff3d93f1`; tests were not repeated after commit. The supervisor inspected the diff and guarded red/green reports. Documentation drift and `git diff --check` passed. Preservation checks retain all tasks, risks, scope, historical sections and Active/ExitGate false.

No broader component/full harness suite, native retry, core/adapter change, installer, provider/live request, paid review, Nucleus communication, push or main merge occurred. The earlier failed native result, unknown counters and skipped postphase checks remain unchanged. The correction qualifies fixture preparation only; native route acceptance remains open.

**Next action:** present the corrected exact committed native preview for separate approval. Freeze source before any approved attempt. This normal review is not ExitGate; production activation remains `native-caller-binding-unqualified`.

## Corrected Pi native-turn acceptance result

Run on **2026-10-18** at clean committed source **`9fba423bc9bae3a01f172515d69760ace4e92d63`**, on GEEKOM Linux. Peter separately approved this corrected bounded test, delegated execution, independent outcome review and local saves. This approval covered one exact invocation after the saved permission correction. It is now spent.

### Exact execution and observed result

The sole execution worker ran this command **once** from `/home/fodurrr/dev/dotfiles`:

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --native
```

The runner started at `2026-10-18T15:26:01.307Z` and finished at `2026-10-18T15:26:11.443Z`. It returned **exit 0**, with all **five harmless preflights and one native phase passed**. No native retry, fallback, implementation fix or scope expansion followed. The installed Pi 1.3.0 x86-64 ELF matched SHA-256 `c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca`. The report records clean sources and the exact observed running ELF.

| Observation | Recorded result |
|---|---|
| Scripted PTY, deadline, overflow, inner-supervisor death and outer-parent death | All five passed and reported reaped; deadline/overflow failures were expected negative fixtures |
| Fixture preparation | `/agent` mode `0700`; model/settings modes `0600` |
| Request, attempt and execution | Outer requested/attempted true; inner launch attempted true; PTY driver started; `nativeExecuted:true`, `exact-elf-observed` |
| Confinement | Separate namespaces, hidden host paths, read-only mounts, reachable private endpoints and unreachable host loopback passed |
| History before consent | Native history input/completion settled; passing harness asserted zero jobs, sessions and recalls before `/new` |
| Fresh-session consent | Native new session and actual destination confirmation appeared; scripted LF accepted Yes; harness asserted one registered session |
| Fresh original input and completion | Exact submitted prompt matched native `before_agent_start`; persisted assistant `turn_end` ID `c5482266` matched the final non-aborted `agent_settled` entry |
| Fake service counters | Two model requests, one original-prompt recall, two bank checks, two exact retained messages and two completed operation polls |
| Fixture HTTP budget | Two health checks plus the nine accepted model/memory requests: 11 requests within the cap of 12 |
| Durable local state | Passing harness asserted two completed jobs and zero pending stages; DB counts were not separately serialized |
| Postphase checks | Passing outer path checked observed descendants gone, unchanged package/experiment/mounted fingerprints and zero host-listener contacts |
| Deliberate stop | Native PTY status `-9`, `stopped:true`, `failure:null`, `reaped:true`; driver code 0, signal null; no natural clean Pi exit claimed |

The first model request contained history. After `/new`, the second contained the fresh prompt and clearly marked untrusted recall, without that history. Retained content was exactly `user: Synthetic Pi turn: say TURN_FINAL_SENTINEL.` and `assistant: TURN_FINAL_SENTINEL`. Neither history nor recall entered retention. The fixture also rejects tool/reasoning sentinels, but neither native turn emitted them; this run does not add native tool/reasoning negative coverage.

### Guarded evidence and independent normal review

Private report: `/var/tmp/hindsight-pi-turn-KXwZeJ/report.json`. Its adjacent manifest, inputs and diagnostics remain outside Git. The worker guarded-read the report, manifest and all **16** listed diagnostics using `readEvidence`. Native supervisor stdout is 8838 bytes, stderr is empty, and terminal JSON is 17124 bytes for 12225 raw terminal bytes. The terminal evidence shows the consent title/destination, fresh prompt and final answer.

The independent read-only native OpenAI outcome reviewer guarded-read the report, manifest, native input and every listed diagnostic. It confirmed the counts, event pairing, limits, deliberate stop and cleanup. All **75** recorded file fingerprints still matched. It found **no actionable findings**. This is a normal outcome review, **not ExitGate**.

A bounded external observer tracked **38 PID/start-time identities**, including the runner. Guarded `/var/tmp/hindsight-pi-turn-observer-w9f1505u/cleanup.json` records `allGone:true`, no residual identity, and a two-second post-run wait. Worker `recheck.json` in that directory records no live tracked identity, no occupants of the six native sandbox namespaces and removal of the host socket. The independent reviewer also found no tracked identity alive. No unrelated process was killed.

### Scope, preservation and next boundary

This result qualifies the **confined native fake-provider/memory path only**. It does not qualify personal-bank capture, ordinary unrestricted Pi launches, other hosts/routes, all lifecycle negatives, production preparation, live API semantics, durability under real failures or performance. Production activation remains **`native-caller-binding-unqualified`**. The private `Store.activate` fixture seam did not change that refusal.

The first failed native result, unknown counters and skipped failed-phase checks remain preserved above. The earlier parallel Codex `state_busy_admission_not_confirmed` failure remains unresolved. The prior 112-test component suite, full 9-test harness suite and focused permission tests were not rerun. Only the approved native command repeated its five harmless preflights.

No external provider, personal bank, real credential, installed configuration, installer, production activation, live rollout, Nucleus/Xpando communication, external-company investigation, paid review, publication, push or main merge occurred. All unfinished tasks, risks and historical evidence remain. The work item stays **Active**, ExitGate **false**.

The independent normal reviewer also cleared the canonical draft. Documentation checks `bash scripts/docs/check-doc-drift.sh` and `git diff --check` passed for the documentation patch atop the checked revision. Structured preservation checks retained all nine tasks and their states/dependencies/acceptance, eight open tasks, seven risks, unchanged scope/inputs/exits, all prior evidence/decisions and 30 historical sections. No raw output was committed.

**Next action:** preserve this local checkpoint and stop native execution. Existing bounded isolated work may address the remaining Pi pilot readiness gaps: exact-host privacy, durable recovery and pending/uncertain operations, writer ownership, safe preparation, experiment packaging and rollback. Present concrete commands and remaining costs before seeking separate approval for any further native test or personal/live action.

## Pi readiness decision

Recorded on **2026-10-18** for GEEKOM's exact compiled Linux Pi **1.3.0** route. Peter authorized delegated remaining readiness checks and local saves. Further native tests, publication, main merge and live rollout remain separate approvals. No Nucleus/Xpando communication is authorized.

**Decision: the confined fake-service path passed; personal Pi capture is not ready to activate.** The current production command still refuses `native-caller-binding-unqualified`. GEEKOM's `~/.local/bin` is also group-writable, so preparation would refuse it. This phase leaves both boundaries intact.

### Existing proof reused

Before editing, `git diff 15b83ea94f66a521c2b101f4aa269bdea214c7ef f316daa3d49a1ad726e2f5d33efef6364e4aa0f8 -- tools/hindsight-memory/src tools/hindsight-memory/adapters tools/hindsight-memory/test` was empty. The source and tests behind the frozen **112/112 serial** result were unchanged. The entire component also matched the corrected native source `9fba423bc9bae3a01f172515d69760ace4e92d63`. Later changes in this phase are limited below; no broad suite or positive native proof was repeated.

The supervisor guarded-read `/var/tmp/hindsight-pi-turn-KXwZeJ/report.json` and the observer's `cleanup.json` with `readEvidence`. They still record passed phases, clean `9fba423`, `exact-elf-observed`, unchanged production refusal and `allGone:true`. The previous worker/reviewer inspection of all diagnostics remains the detailed outcome evidence. This phase did not repeat it.

| Area | Applicable evidence and precise limit |
|---|---|
| Original input and consent | The native run proves history excluded before consent, actual `/new` consent, one original-prompt recall and exactly the fresh prompt/answer retained. Pi-normalized trimmed input is the supported original. The exact ELF, sole-extension argv and fresh-session restrictions remain. |
| Lifecycle and privacy | Existing Pi fixtures cover declined/stale consent, changed destination/process, queued/image/expanded input, aborted/mismatched completion, tool/reasoning exclusion and lifecycle invalidation. These are synthetic callbacks. The native run emitted no tool/reasoning turns and does not prove those negatives or cancellation/switch behavior. No unrestricted Pi launch is qualified. |
| Accepted work and uncertain delivery | Existing core/remediation fixtures cover atomic chunks/cursor, crash/reopen, capacity refusal, immutable retry bytes, unknown acknowledgements, bounded polls and paused-worker fencing. Pi uses that same outbox; the native run reached two completed jobs. Real server authentication, operation retention/reconciliation and protection against concurrent bank deletion remain unproved. |
| Capture ownership | The core enforces an owner within one activation/agent/session. It does not detect another adapter or pre-existing external writer. Sole-extension argv limits this Pi process; it does not inventory installed writers. Existing Hermes handover obligations remain separate. No installed writer was read, stopped or replaced. |
| Preparation and rollback | Existing fixtures prove private paths, runtime pinning, ownership conflicts and installer guards. New focused fixtures below close dormant-experiment copying and generated Pi artifact rollback coverage. They do not qualify installed host configuration or previous-writer handover. |
| Performance | Frozen disk-backed direct admission p95 was 10.058 ms; whole source-hook p95 was 275.227 ms. Different measurement boundaries cannot be combined. Neither measures native Pi callback/startup latency. The 100 ms value remains a target, not an activation gate or guarantee. No benchmark was repeated. |

### Small fixes and missing harmless checks

Preparation now excludes `experiments/` alongside `test/` and `node_modules/` from release copies and digests. A regression changes dormant source, confirms the same release identity, removes the source checkout and runs installed status. Previous releases are not purged. This changes no installed files because preparation was not run on the host.

Two new disk-backed Linux tests drive synthetic Pi callbacks through the actual synchronous Node CLI/Store path. Only detached worker wakes are suppressed. No native application or network runs. A child holds `BEGIN EXCLUSIVE` and is released and joined after each test.

- Stage refusal produces visible `state_busy_admission_not_confirmed`, with no staged prompt, jobs, messages or cursor advancement.
- Completion and its attempted abort can both refuse under that lock. The original staged prompt survives, unaccepted. No job/message/cursor advances. Late callbacks and fresh consent cannot silently replay or complete it.

This confirms shared SQLite contention can affect Pi admission. It does not reproduce or resolve the earlier parallel Codex suite failure. Its isolated 30-turn retry and later serial pass remain separate evidence.

The lock fixture also exposed a diagnostic gap: ordinary status omitted staged input entirely. Status now reports a safe numeric `staged_turns` count. It exposes no prompt or stage identifier. An unaccepted stage is **not** a submitted operation; ordinary `retry` cannot recover the missing assistant completion. The adapter clears its in-memory slot after refusal. No automatic stage recovery, transcript fallback or false durable acceptance was added.

Three new Pi ownership cases generate the actual bridge/descriptor plan in a synthetic private home. Repeated apply and rollback preserve unrelated settings, extensions and synthetic auth. Editing either owned file refuses the whole rollback without overwriting files or the ownership journal. These tests never import the generated Pi bridge or activate production.

### Exact host facts and next boundary

A metadata-only `lstat` check found `/home/fodurrr/.local/bin` mode **0775**, uid 1000, without a symlink. The checked HOME, `.local`, `.local/share`, `.local/state` and `.config` ancestors have safe ownership and no writable-group/other permissions. No credential, conversation or installed-writer content was read. No permission was changed. Any later permission correction requires explicit host approval and inspection of its effect on shared use.

The user guide now describes the confined Pi milestone, packaging exclusion and retained hostname/session/message metadata. That metadata already belongs to the accepted provenance design; this phase adds disclosure, not a new remote field.

Before a personal pilot, there are three concrete boundaries:

1. Prove the prepared release and generated bridge use the pinned runtime/ELF and restricted launch without source-checkout or ambient-resource dependence. Check actual native cancellation/session switch and resumed-session refusal: they must cause zero extra recall/admission and must not inherit consent. Existing synthetic negatives and the confined positive turn remain valid inputs, not substitutes for this route evidence. Together with explicit writer selection, these checks give a reviewer a concrete basis for a Pi-only activation-gate change. Freeze and approve any required native preview first; repeating the solved positive turn alone adds no proof. This phase leaves the gate unchanged.
2. Obtain exact host-preparation authority before changing bin permissions or installed artifacts. Inspect existing writers before choosing or replacing one. Do not run the whole installer merely to prepare this component.
3. Qualify the real configured API with separately approved harmless requests before enabling personal capture. Prove authorization, existing-bank access, operation acknowledgement/completion, uncertain-operation reconciliation and fresh recall. Fake services and schema support cannot establish these facts.

No runnable live/pilot command is presented because `activate` still refuses and those host/API prerequisites are unresolved. Pi latency, real ENOSPC/power-loss/macOS evidence and every other route remain the existing whole-item obligations. No new exhaustive test requirement or scope waiver is introduced. Final cross-provider ExitGate remains outstanding; normal review is not ExitGate. The item stays **Active**, ExitGate **false**.

### Phase verification and local save

Focused executable changes and test results are recorded in this item's evidence. Tests ran once on each final worker patch and were not repeated after integration of identical relevant files. The frozen component/harness suites and native command were not rerun. The failed native permission result and all previous contention failures remain preserved.

No Pi/Bun/client execution, native test, real endpoint/credential/personal-bank access, installed configuration change, live preparation/activation, external-company research, Nucleus/Xpando communication, paid review, publication, push or main merge occurred.

| Focused check | Final tested worker revision | Actual result |
|---|---|---|
| `node --disable-warning=ExperimentalWarning --test tools/hindsight-memory/test/cli.test.mjs` | `c3486474bae5ef449b38d462117b9cdb64e3264f` | 7 passed, 0 failed; packaging correction |
| `node --disable-warning=ExperimentalWarning --test --test-name-pattern='Disk-backed Pi CLI' tools/hindsight-memory/test/pi-candidate.test.mjs` | `43856f6441120b73cb2f3d36a93443028a268192` | 2 selected passed, 0 failed; both lock paths and safe staged count |
| `node --test tools/hindsight-memory/test/ownership.test.mjs` | `f5fee9a46489ba2de523fc0501138e1948c2e73d` | 10 passed, 0 failed; includes three new Pi cases |

Workers invoked `node` by name and separately observed version `v24.22.0`. They did not record the resolved executable path; no absolute runtime path is claimed for these new checks. Before the status correction, the new assertions failed twice: `undefined !== 0` and `undefined !== 1`. The earlier two lock tests had passed before adding those assertions. Final relevant worker files match integrated `88e3b82311ba5ac1a4e15b999b0ecdcc7e6268ce` (packaging), `10842354d847a4c2aa1f94b0fc5bcaa9e078b8b1` (lock fixtures), `14a2826da879a205e98d49ec09b70a36625b7176` (Pi ownership) and `0a28d30122483b3e004e6f8769749920b48056b6` (staged count). No CI run exists.

An independent read-only native OpenAI normal reviewer checked `f316daa..0a28d30`, affected callers, the user guide and readiness draft. It found **no actionable findings**, including additive status compatibility and all new fixture limitations. It did not rerun tests. This is not ExitGate.

Documentation checks `bash scripts/docs/check-doc-drift.sh` and `git diff --check` passed. A structured comparison retained all nine task identities/states/dependencies/acceptance, eight open tasks, seven risks, all nine prior evidence entries and ten decisions, unchanged scope/inputs/exits, and 32 historical sections. Only the current authority section was updated, and this readiness section was added. The first comparison script failed with `KeyError` from its own heading regex; the corrected comparison passed without changing plan content.

## Prepared Pi native qualification preview

Implementation frozen at `2dd943255abeb1f31a9fcefde8c5a54dc776950d`; exact request-accounting correction at `0733e7ee266a39989eef4a301460611b57e7f250`. This section records the approved bounded preview before native execution.


The user authorized this bounded preview and its execution on **2026-10-18**.
The phase performs a normal independent review before execution. It permits one
initial run and at most one corrected run justified by an observed failure.

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --qualify-native
```

The runner first calls the actual component `prepare` command in a disposable,
private HOME beneath its report directory. No installed host path changes.
Native confinement mounts **only that prepared release**, with its recorded
absolute runtime and release paths. `/component` is an alias of the release;
the component source checkout is absent. Empty ancestors needed for the exact
Node path do not expose host HOME, authentication or other host files.

The sole extension is the **unchanged** file returned by `adapterArtifacts`.
Its descriptor selects owner `isolated-pi-qualification`, the prepared CLI,
pinned Node and exact selected Pi ELF. No observer wrapper or extra extension
runs. The existing private `Store.activate` seam supplies fixture consent state;
the production activation gate stays unchanged.

The exact native command is:

```text
/pi/pi --no-extensions -e /home/fixture/.pi/agent/extensions/hindsight-memory.js
```

The fixed PTY sequence has **12 writes**:

1. `/new` and literal LF accept actual destination consent.
2. `QUALIFICATION_POSITIVE_SENTINEL` completes. Require two exact retained
   messages, two completed polls/jobs and the real session cursor.
3. `QUALIFICATION_CANCEL_SENTINEL` starts a held fixture stream. After its
   recall and durable stage, Escape aborts it. Require the persisted native
   aborted assistant, closed fixture stream and removed stage.
4. `QUALIFICATION_POST_CANCEL_SENTINEL` completes without new recall/admission.
5. `/new` opens actual consent. Down plus LF selects No. Require its diagnostic.
6. `QUALIFICATION_SWITCHED_SENTINEL` completes in a different native session,
   without new recall/admission.
7. `/resume` opens the native selector. Wait for both session names. One write
   filters `QUALIFICATION_POSITIVE_SENTINEL` and presses Enter. Require native
   `Resumed session` status.
8. `QUALIFICATION_RESUMED_SENTINEL` completes in the original native JSONL,
   without inherited consent, new recall or admission.

The prepared bridge therefore proves both completed capture and revocation.
Cancellation necessarily follows one recall for that cancelled request. The
claim is no additional recall after cancellation, and no cancelled retained pair.
The fixture owner is explicit. A second owner for the same registered native
session must receive `session-owner-conflict`. This does not inventory live writers.

The qualification-only HTTP cap is **16**, with **15 expected** requests: two
health, five model, two recall, two profile, two retain and two operation polls.
The earlier `--native` route keeps its cap of 12. All other existing limits stay:
45-second native PTY, 60-second sandbox, 180-second total, 12 PTY writes, output
and body caps, five harmless preflights, fingerprint checks and descendant cleanup.
Session JSONL and SQLite/HTTP provide evidence without fabricated callbacks.
The native process is deliberately stopped and reaped after assertions.

No real service, credentials, personal bank, installed writer or host permission
is accessed or changed. Publication, main merge and live rollout need approval.

Independent normal preview review cleared the design after requiring exact total/health accounting. The corrected harness asserts 15 total requests and two health requests, not only the hard cap. No native execution preceded this preview save.

### One justified corrected run

The initial native invocation at `15adbff6eb325a760ae0b6265bd95a7eb699bce3` failed `qualification-consent-not-observed` because `/new` reached early startup feedback before real submission was bound. Private report `/var/tmp/hindsight-pi-turn-naGmv1/report.json` preserves the failure. Exact ELF and generated bridge were observed; five preflights passed and PTY cleanup reaped. Service/admission totals were not saved and remain unknown.

The minimum correction at `921db5bd1e98752adbfec5070dc2bbc1f82faf9d` waits for actual startup refusal plus the terminal title emitted after extension binding and agent subscription. The targeted observed-startup regression passed 1/1. The corrected run uses the same command, case sequence and limits. It is the final native invocation in this phase budget.

## Prepared Pi native qualification result

Recorded **2026-10-18**. The user authorized preview, delegated execution, supported correction, independent normal review and local saving without another approval stop. This phase used one initial native invocation and its sole justified corrected invocation. Both budgets are spent. Publication, main merge, host/live rollout and real-service access remain unapproved. No Nucleus communication occurred.

**Result: the prepared sole-extension Linux compiled Pi 1.3.0 route passed its bounded fake-service qualification.** Production source and adapters are unchanged from `2296fba57b6062463885bc9438a77115d5931e77`; activation still refuses `native-caller-binding-unqualified`. This result now supports reviewing a narrow Pi-only activation-gate change. It does not qualify an unrestricted launch, another client/host/version or a real bank.

### Exact execution and scope

The real component `prepare` ran in a disposable report-root HOME. Native confinement mounted only files from prepared release `0.1.0-21191baf389da5b8`, plus the named runtime, Pi and harness resources. `/component` was a prepared-release alias. Original component sources and host authentication were absent. The direct sole extension was the unchanged `adapterArtifacts` bridge, with owner `isolated-pi-qualification`, the recorded absolute Node/runtime/CLI paths and exact pinned Pi ELF. No observer extension or fabricated callback ran. The existing private Store activation seam remained fixture-only.

The corrected source was **`ae83170f9bfa023a86440b0749ae4d7a5a999042`**, clean. The exact approved `--qualify-native` command ran from **2026-10-18T18:01:34.485Z** to **2026-10-18T18:01:45.804Z**, exit **0**, 11.319 seconds overall. Five harmless confinement/PTY/deadline/overflow/parent-death preflights and the one native qualification phase passed. The exact native ELF was observed. The process was deliberately stopped with PTY status **-9**, reaped, driver exit **0**; no natural clean Pi exit is claimed.

| Native checkpoint | Saved result |
|---|---|
| Fresh-session consent and positive turn | Actual consent; two exact positive messages retained, two jobs completed, two completed polls; registered cursor advanced to two messages |
| Cancellation | Held fixture stream closed, persisted native aborted assistant, stage removed; cancelled prompt/answer excluded |
| Post-cancel turn | Completed natively with no new recall, accepted message or cursor advancement |
| Changed session and declined consent | Native different JSONL path; completed turn with no inherited consent or extra recall/admission |
| Resume original session | Actual selector and resume; exact original JSONL path, completed resumed turn with no inherited consent or extra recall/admission |
| Capture owner | Explicit generated fixture owner selected; second owner refused `session-owner-conflict` |

The final checkpoints retained **one registered session, two jobs, two accepted messages, zero staged turns and two retained items**. Recall count rose from one for the positive turn to two for the cancelled turn before cancellation; it never rose afterward. The accepted cursor stayed unchanged through every negative case. The fixture recorded exactly **15 HTTP requests**: two health, five model, two recall, two profile, two retain and two operation polls. One stream was cancelled. The qualification-only request cap was **16**; the older route retains **12**. The 12 PTY writes, 45-second native deadline, 60-second sandbox/180-second overall deadlines and all prior output/body/process limits stayed intact.

### Preserved failure and supported correction

The initial invocation at **`15adbff6eb325a760ae0b6265bd95a7eb699bce3`** failed `qualification-consent-not-observed`. The early model-scope banner preceded actual submission readiness, so `/new` reached Pi startup feedback. Exact ELF and generated bridge were observed; all five preflights passed and PTY cleanup reaped. Request/admission totals were not serialized and remain unknown. Private failed report: `/var/tmp/hindsight-pi-turn-naGmv1/report.json`.

The minimum harness correction **`921db5bd1e98752adbfec5070dc2bbc1f82faf9d`** requires the actual bridge startup-refusal diagnostic plus terminal title emitted after extension binding and agent subscription. Pinned source and an observed-startup regression support that barrier. No product change, extra action, delay or callback observer was added. The corrected run was the final allowed native invocation; no further native run occurred.

### Verification, review and evidence limits

The worker passed **11/11 harmless harness tests** on the prepared-mount patch, **1/1 request-counter regression** after the review fix, and **1/1 startup regression** after the observed failure. Exact commands and revisions are in structured evidence. The whole component suite and prior baselines were reused, not rerun.

A fresh independent native OpenAI normal reviewer checked preview and corrections, then guarded-read the corrected report and all **16 diagnostics** with `readEvidence`. All **76 recorded file fingerprints** still matched; the prepared manifest was unchanged. It confirmed the actual abort/consent/resume UI, JSONL identity, exact counters, negative cursor/state checks, prepared-only mounts and cleanup. It found **no actionable findings**. This is a normal review, **not ExitGate**.

Passing report: `/var/tmp/hindsight-pi-turn-E5x7NJ/report.json`, with adjacent manifest, prepared manifest, input and diagnostics. Read sandbox-produced artifacts only with `readEvidence` from `experiments/pi-launch/safe-output.mjs`. Existing harness PID/start tracking, `gone` checks, namespace teardown, PTY reaping and both parent-death preflights establish its reported cleanup; no cleanup failure was recorded. No separate external observer was run or claimed.

The eight changed experiment files and detailed preview/results are in `tools/hindsight-memory/experiments/pi-turn/`; implementation revisions are `2dd943255abeb1f31a9fcefde8c5a54dc776950d`, `0733e7ee266a39989eef4a301460611b57e7f250` and `921db5bd1e98752adbfec5070dc2bbc1f82faf9d`. Worker result save: `b03812ffa6df910358428b6320e73c1e7474758f`. Documentation drift and whitespace checks passed.

**Next practical action:** implement and normally review isolated Pi-only eligibility in `src/cli.mjs` `activationPlans`, retaining refusal for every other route. Reuse existing runtime/ELF guards and this native proof. Show the generated capture owner, exact sole-extension launch and unresolved installed-writer selection in `activation-preview`; test eligibility/refusal/ownership with harmless fixtures. This local implementation already has isolated-work authorization and needs no repeated planning approval. It includes no further native execution or host activation. Then prepare exact host/API pilot actions. Existing host bin mode **0775**, installed-writer inventory/selection and real-service authorization, completion/reconciliation and recall remain unresolved. No installed permission/configuration, real credential/bank, publication, push, main merge or live state changed. Other routes, macOS, durability/performance and final cross-provider ExitGate remain open. Work item **Active**, ExitGate **false**.

## Pi-only eligibility and live-pilot preview

Recorded **2026-10-18**. This is a local implementation checkpoint and an unexecuted live-pilot preview. The user authorized isolated implementation, fixtures, review and local saves. Publication, main merge and live rollout remain separate approvals. No Nucleus communication occurred.

### Local result

Only the exact pinned Linux compiled Pi 1.3.0 route can become eligible. Eligibility also requires selecting this generated capture owner. Every other adapter, mixed selection, platform and version remains refused. Other hosts still need separate rollout qualification. Actual Pi capture still requires the exact sole generated bridge launch and fresh `/new` TUI consent. A copied bridge path, extra extension, changed executable, preload or inherited session consent is refused.

Activation must run from its recorded prepared release, so a current checkout cannot authorize older installed adapter code. Preview inspects the explicit executable without running it. It reports the exact executable/arguments, generated capture owner, owner-selection state and `installed_writers_verified:false`. Selecting an owner records an operator decision; it does not claim that installed writers were discovered or disabled.

No native test was repeated on this new eligibility patch. The earlier prepared native qualification above remains the positive and lifecycle evidence. The new release/bridge-path equality guards were verified with harmless fixtures only. This change adds local eligibility and fail-closed fixtures; it does not prove real authentication, a live operation or personal recall. `capture_verified:false` remains explicit.

### Verification and independent normal review

Implementation: **9bbc11df03d08c6b83a4c32cb7f6d2ad42182181**. README correction: **4d6e7ce38e5d196855881ccef052330db988dc27**. The worker attests tested source bytes match the implementation commit. Absolute Node **24.22.0** passed activation/qualification **10/10**, CLI **7/7**, and selected Pi process/consent **4/4**. Exact commands are in structured evidence. Documentation drift and whitespace checks passed. A fresh independent native OpenAI normal reviewer found no remaining actionable findings through `fe8c021` after reviewing the import-closure correction; two prose contradictions were corrected. It independently checked whitespace and reused worker results. This is not ExitGate.

The affected manual `pi-turn` descriptor gains the new generated bridge path. Root final review found the sandbox module allowlist omitted the newly imported `activation.mjs`. Correction **fe8c02195760ed399b066eafaab49c96404399bc** adds it and a harmless actual import-closure regression. Copying only allowlisted files first failed `ERR_MODULE_NOT_FOUND` for that module, then passed **1/1** after correction. No native/full-suite rerun occurred.

### Exact GEEKOM live-pilot preview — not executed

The intended existing bank remains **fodurrr** on the existing Mini service. There is no installed component config, installation record or launcher on this host. Therefore the endpoint and private secret-file path are still needed from the operator. Do not guess them, copy another application's authentication or create a bank.

A metadata-only check found user-owned real directories with mode **0775** at all four paths below. HOME, `.local`, `.local/share` and `.config` had safe ownership and modes. The generated `hindsight-memory.js` did not exist. No credential, settings or conversation content was read.

After separate approval, the bounded pilot will:

1. Inspect existing Pi capture writers and select this generated writer exclusively. Read only the configuration relevant to ownership. Preserve other extensions, settings and authentication. Stop on an unresolved competing writer.
2. Inspect shared-group use of the four named directories. If the approved changes remain appropriate, run exactly:

   ```sh
   chmod 0755 /home/fodurrr/.local/bin /home/fodurrr/.pi /home/fodurrr/.pi/agent /home/fodurrr/.pi/agent/extensions
   ```

   Record each original mode. Rollback restores **0775** only if its mode still matches this approved change and doing so will not expose active memory artifacts. Do not relax safety checks to avoid this prerequisite.
3. Prepare the reviewed local commit without rerunning the whole installer:

   ```sh
   cd /home/fodurrr/dev/dotfiles
   /home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/src/cli.mjs prepare
   ```

   This writes a private release and `/home/fodurrr/.local/bin/hindsight-memory`. Preparation leaves capture inactive.
4. Configure explicit endpoint, bank **fodurrr**, a private API-secret file, `adapters:["pi"]`, `agent_versions.pi:"1.3.0"`, and `agent_commands.pi:"/home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi/pi"`. Run `activation-preview`, then select its exact generated owner with `capture_owners.pi` after the inventory. Preview again and require no eligibility blocker. Keep private configuration outside Git. Do not print or copy the secret value into arguments, logs or evidence.
5. Before activation, qualify the existing real API using the component's bounded transport: `GET /v1/default/banks/fodurrr/profile`; one explicitly harmless asynchronous `POST /v1/default/banks/fodurrr/memories` with a saved UUID and immutable bytes; at most six `GET /v1/default/banks/fodurrr/operations/<same-UUID>` polls; one repeated read of that operation to prove reconciliation without another retain; and one `POST /v1/default/banks/fodurrr/memories/recall`. Require matching bank and operation identities, completed operation and recalled harmless marker. A missing/expired operation is a failure, not permission to resubmit. No bank creation, configuration, import, reflect, bulk/history data or intentional service disruption is included. Stop inactive on failure. These real requests may incur service extraction/recall costs. Use at most **10 requests** total: one profile, one retain, six operation polls, one same-operation reconciliation read and one recall. Stop after **90 seconds**, with a 10-second per-request cap. Never repeat the retain automatically. Freeze one generated UUID, UTC timestamp and document ID before the first request. The sole retained content is `Dotfiles Pi API qualification 2026-10-18: the harmless test label is violet-copper-4812.` Metadata identifies `source:dotfiles-pi-api-qualification`; recall asks for that test label. This checkpoint runs none.
6. Only after the API proof passes, run the installed `hindsight-memory activate` and inspect `status`. Require preview to match this exact launch, then run it:

   ```sh
   env -u NODE_OPTIONS -u BUN_OPTIONS -u LD_PRELOAD -u LD_LIBRARY_PATH /home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi/pi --no-extensions -e /home/fodurrr/.pi/agent/extensions/hindsight-memory.js
   ```

   Start `/new`, accept the displayed destination, and send one agreed harmless fact. Require exactly the eligible prompt/answer pair in completed local jobs and a later fresh-session recall. Bound the pilot to those two conversations; do not expose existing personal history.
7. Deactivate, verify suspension completes, then run ownership-aware `rollback` and inspect status. Preserve remote harmless evidence, local queues/cursors and authentication. An intervening edit stops rollback; do not overwrite it. Save a redacted evidence note and report service requests and any failures.

No step above is authorized merely by saving this preview. Endpoint, private secret-file path and live-pilot approval remain operator inputs. Publication and main merge are independent actions. The whole work item remains **Active**, ExitGate **false**. Other clients/hosts, durability, performance and final cross-provider ExitGate obligations remain open.

## GEEKOM live API proof and remaining Pi host blocker

Recorded 2026-10-18 at source `90bc229cd7c84ce1deaae2082787f939519c6ab3`.

### Result

The real API proof passed. The native Pi conversations did not run. The component remains inactive.

The proof made six requests in 10,493 ms: one existing-bank profile, one asynchronous retain, two operation polls, one same-operation reconciliation read and one recall. All returned HTTP 200. The profile confirmed bank `fodurrr`. The retained operation and both completed reads matched UUID `a631ec71-5f7b-4b24-afa5-6fb2d5a9a216`. Recall returned the harmless marker `violet-copper-4812`. There was exactly one retain submission and no automatic retry or bank creation.

The request guard capped ten requests, 90 seconds overall and ten seconds per request. The frozen body, UUID, UTC timestamp and document ID were saved before the first request. The sole retained text was the preview sentence: `Dotfiles Pi API qualification 2026-10-18: the harmless test label is violet-copper-4812.` Raw service responses and unrelated recalled facts were not logged.

### Local discovery and setup

The actual endpoint and bank came from `~/.hermes/hindsight/config.json`, fields `api_url` and `bank_id`. The file is mode 0600. The only existing key setting was `HINDSIGHT_API_KEY` in `~/.hermes/.env`, mode 0600. No dedicated raw-key file was found in the bounded search. The local Hermes Hindsight client explicitly binds this key, config endpoint and bank (`__init__.py:99`, `:745`, `:1060`).

The supervisor confirmed that the latest approval permits provisioning the same-service key for this pilot. Only that one setting was copied into `~/.config/hindsight-memory/api-secret`, mode 0600. The original dotenv was preserved. No secret value entered argv, output, tracked files or evidence. The dotenv file itself was not configured as `secret_file`.

The four approved directories changed from 0775 to 0755 after metadata checks found only UID/GID 1000 entries and no additional members in group `fodurrr`. Component-only `prepare` succeeded. The private release and launcher were created. Config selected Pi 1.3.0 and the exact installed executable. The exact generated owner was selected in `capture_owners.pi`.

The local Pi extension directory contains subagent sources and no Hindsight reference. Settings select `pi-subagents@0.62.0` and `@xpando/xpando-pi-ai-layer@0.6.97`. The bounded local inventory found no competing capture writer. It does not certify all package behavior. The restricted sole-extension route remained required.

### Native blocker

`activation-preview` refused `unsafe-agent-command-parent`. The following additional runtime ancestors are user/group-owned 0775:

- `/home/fodurrr/.local/share/mise`
- `/home/fodurrr/.local/share/mise/installs`
- `/home/fodurrr/.local/share/mise/installs/pi`
- `/home/fodurrr/.local/share/mise/installs/pi/1.3.0`

The Pi executable and its immediate `pi` directory are 0755. Immediate entries under the four blocked ancestors had UID/GID 1000. These four ancestors were outside the exact approved permission list. They were not changed. No production activation or native Pi launch occurred. The independent API proof proceeded while inactive under the supervisor's instruction.

### Cleanup and preserved state

`deactivate` returned `suspended`, with no worker or recall in flight. Ownership-aware `rollback` returned `no-owned-artifacts`. Final `status` reported `configured`, `active:false`, `generation:null`, empty jobs, zero staged turns and no in-flight worker/recall. The generated Pi bridge is absent.

The original modes 0775 were restored on `~/.pi`, `~/.pi/agent` and `~/.pi/agent/extensions`. `~/.local/bin` remains 0755 because the prepared owned launcher remains and requires a safe parent. The private config, separate API-secret, prepared release, installation record, launcher and empty local state remain for continuation. Rollback is not a full uninstall. The one harmless remote qualification document remains.

Pi settings, Pi auth, Pi MCP auth and the original Hermes dotenv retain their original inode, device, size, mtime and mode. No before-content hashes were recorded, so this is metadata preservation evidence only. No source-auth writes occurred. No Nucleus communication, publication, main merge, installer run or persistent activation occurred.

### Evidence and continuation

Private evidence is `/var/tmp/hindsight-pi-live-pilot-cm1uki_l`: `journal.json`, `setup.mjs`, `prepare.json`, `preview-before-owner.json`, `runtime-parent-blocker.json`, `frozen.json`, `api-proof.mjs`, `api-result.json`, `cleanup.mjs` and `cleanup.json`. These files were produced directly by the host worker, not by sandbox native code. `discovery.json` records the initial discovery assumption and is explicitly superseded by the final API result.

The minimal remaining native pilot requires explicit approval to tighten the four named runtime ancestors to 0755, temporarily reapply the three Pi-directory permissions, preview, activate, run the exact restricted generated bridge for two harmless conversations, deactivate and roll back. Keep the existing successful API proof; do not repeat the retain. Preserve original modes in a journal and restore them only when no remaining memory artifact depends on those safe parents. The shared `mise` and `installs` directories affect every mise runtime and need that concrete host-change decision.


Independent normal review verified the API runner, frozen body, result and host cleanup. No new component tests or native tests ran. Earlier component and confined Pi evidence was reused. This is not ExitGate. The full work item remains Active with ExitGate false; other route, host, durability and performance obligations remain open.

## Pi live completion attempt and account quota blocker

Recorded **2026-10-18**. The final installed component source is `f7de4f7`.

### Final result

**Pi capture and later fresh-session recall passed against the real service. The reviewed Pi installation remains active.** The existing Pi `xai` OAuth login and listed chat model `grok-4.3` completed the native conversations. No new login, API key, purchase or copied provider credential was used.

The first real capture run completed two fresh consented sessions. Both exact original prompt/answer pairs matched immutable core message digests. Four remote operations completed. Its later answer was `UNKNOWN`, so that run was rolled back instead of claimed successful. A single bounded read-only diagnosis then returned HTTP 200 in **4,084 ms**: 12 facts, 5,117 encoded context bytes, and the harmless label present. No unrelated fact text was logged. The previous 1.5-second deadline and all-or-nothing 1000-byte output refusal both prevented useful recall.

Reviewed fix **`f7de4f7`** shares an **8-second** deadline across the native invoker, CLI, core and in-flight marker. It packs complete redacted attributed facts in relevance order into the existing **1000 UTF-8 byte** labeled untrusted context. Oversized facts are skipped, not split. The deadline is checked after packing. Nine focused recall tests passed, including measured-latency acceptance, late-response refusal, byte limits, Unicode, escaping, lifecycle invalidation and the native deadline. Independent normal code review found no actionable issue. No broad suite was repeated.

The exact committed fix was prepared into the installed release. One corrective fresh-session conversation reused the already retained label, without repeating the first fact or baseline conversations. It ran **2026-10-18T18:55:12.182Z–18:55:28.746Z**. The prompt omitted the label. The actual `xai/grok-4.3` answer was exactly `cobalt-plum-6148`. Original prompt and answer matched core digests. Two new remote operations completed, and all four previous completed jobs remained completed. Final status was `active:true`, six completed jobs, zero staged turns, and no worker or recall in flight. The PTY child was intentionally stopped and reaped after proof; natural interactive exit was not claimed. The CLI's static `capture_verified:false` field remains; this evidence records the actual bounded live proof separately.

### Earlier failures and scope

The user approved the four additional runtime ancestor modes, completing Pi installation, and reversible fixes with rollback. The root/supervisor authorized bounded repairs. There were seven native launches; the initial two-launch cap was explicitly amended before subsequent corrective launches.

| Launch | Result |
|---|---|
| 1 | Existing `openai/gpt-5.5` returned unsupported-model HTTP 400. Pi refreshed its own OAuth login. No queued pair. |
| 2 | Native `/model` worked, but the verifier wrongly required persistent settings. No conversation or service request followed. |
| 3 | `/new` reset that session-local choice to existing `gpt-5.5`; another HTTP 400. |
| 4 | Owned persistent `gpt-5.3-codex` default was also unsupported by the account. |
| 5 | Proven current `openai/gpt-6-luna` reached the account's Subscription Sharing usage limit. |
| 6 | Existing `xai/grok-4.3` captured two exact pairs and completed four operations; later answer `UNKNOWN` exposed the measured recall defect. |
| 7 | After reviewed recall correction, one fresh session recalled the retained label and completed two more operations. Installation remains active. |

The initial `--list-models codex` search filtered Pi's catalog. The claim that its whole catalog was obsolete was wrong. Installed `--list-models gpt-6`, the Pi chat model store and the fresh same-account Codex model cache all contained current models. `gpt-6-luna` was verified as the chat `openai-responses` entry, not its separate classifier entry. No further OpenAI names were tried after the real quota refusal. The already configured nonexpired Pi `xai` OAuth route was separately approved and verified before use.

Native request counts are inferred from local job attempts/polls and recall records, not an HTTP trace: four earlier recall attempts, 16 estimated memory requests for launch 6, and seven for launch 7. The one direct recall diagnosis adds one observed request: **28 estimated/observed memory requests in this phase**. The previous six-request API qualification was reused without repeating its retain. Three successful model conversations were persisted: the original fact, the failed-recall answer `UNKNOWN`, and the corrective recalled answer. Six harmless conversation documents remain remote alongside the previous API qualification document. No remote cleanup or history import occurred.

### Active installation, use and rollback

The installed route is the unchanged generated Pi bridge. Ordinary `pi` does not qualify capture. Use:

```sh
env -u NODE_OPTIONS -u BUN_OPTIONS -u LD_PRELOAD -u LD_LIBRARY_PATH /home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi/pi --no-extensions -e /home/fodurrr/.pi/agent/extensions/hindsight-memory.js
```

Start `/new` and accept the displayed endpoint/bank consent. Each fresh session needs consent. This process uses the supported existing Pi defaults `defaultProvider:xai`, `defaultModel:grok-4.3`. Other settings and packages remain configured; the capture invocation deliberately selects only the generated bridge.

The four runtime ancestors and three Pi directories remain at the approved **0755**, from original **0775**:

- `/home/fodurrr/.local/share/mise`
- `/home/fodurrr/.local/share/mise/installs`
- `/home/fodurrr/.local/share/mise/installs/pi`
- `/home/fodurrr/.local/share/mise/installs/pi/1.3.0`
- `/home/fodurrr/.pi`
- `/home/fodurrr/.pi/agent`
- `/home/fodurrr/.pi/agent/extensions`

`~/.local/bin` remains 0755 for the previously prepared launcher. All failed launches deactivated, suspended, rolled back owned bridge artifacts and restored their owned settings/modes before repair. Model-field rollback compared all other parsed settings before writing. Launch 4 changed JSON formatting; parsed settings were restored. Renewed native OAuth state was preserved rather than replaced by stale tokens.

The final journal is `/var/tmp/hindsight-pi-live-corrective-recall/journal.json`. Exact before/owned settings are `settings-before.json` and `settings-selected.json`. They record the two intentional changes: `defaultProvider:openai→xai` and `defaultModel:gpt-5.5→grok-4.3`. Final-attempt hashes of Pi auth, Pi MCP auth and Hermes dotenv match their starting hashes; inode/mode checks also match. Settings differ only by the two owned parsed fields. No secret value entered arguments, output or tracked evidence.

To suspend this installation, run `/home/fodurrr/.local/bin/hindsight-memory deactivate` and require `suspended`. To remove owned adapter artifacts, run `/home/fodurrr/.local/bin/hindsight-memory rollback`. Keep private config, secret, state and remote harmless documents. Restore only the two settings fields from the journal if they still match the owned values and unrelated fields are unchanged. Restore original directory modes only after no remaining installed memory artifact or another client's work depends on the safe parents. If later Codex/Claude work changes the shared configuration or ownership, preserve that work and use its updated rollback owner. Do not blindly replay this phase's settings or permissions.

### Evidence and remaining work

Final evidence is `/var/tmp/hindsight-pi-live-corrective-recall/{plan,journal,baseline,prepare,preview,result,terminal}.json`, plus `settings-before.json`, `settings-selected.json`, `run.mjs` and `pty.py`. The earlier successful capture and measured diagnosis are under `/var/tmp/hindsight-pi-live-finish-xai`. Prior failed launch records remain under `/var/tmp/hindsight-pi-live-finish`, `-attempt2`, `-corrected`, `-final` and `-working`. Terminal frames are inspected with the existing guarded `readEvidence`. Private journals are not committed.

No Nucleus communication, publication or main merge occurred. The Pi host lease was released after success for the authorized Codex/Claude phase. This is one host/version/route proof, not all-client completion or ExitGate. The full work item remains **Active**, ExitGate **false**. Other agents, host routes, durability and performance obligations remain open.

## Dedicated Codex installation and cross-agent recall result

Recorded **2026-10-18** after integrating the reviewed Codex route and supported native repairs at `ae6db65`.

### Installed result

**Pi and the dedicated Codex CLI are installed and active on GEEKOM.** Two real Codex 0.163.0 / `gpt-6-luna` conversations completed through native trusted hooks. The first captured the exact harmless prompt and answer. A separate fresh conversation returned `CODEX=silver-finch-8251; PI=cobalt-plum-6148` without either value in its prompt. Native developer-context evidence contained both recalled values. No tools ran. Both native processes exited cleanly, and per-launch binding files were removed.

Final local status contains **ten completed jobs**: six preserved Pi jobs and four Codex jobs. Both Codex user/assistant pairs match the core's immutable message digests. Zero staged turns, worker activity or recall activity remain. The earlier six-request real API proof was reused; no extra qualification retain was sent. The model turns and their memory operations used the real existing service, bank and private secret-file setting. No raw service responses, unrelated recalled memories, authentication tokens or secret values were committed.

Installed release: `~/.local/share/hindsight-memory/releases/0.1.0-29146d96fc3bf5c9`, digest `29146d96fc3bf5c9bee10f176af0fee57badd0f15bd38e03b74dd73a434eaa11`. Source commits integrated as `7a86043`, `402f850`, `a7b6f47` and `ad97eb0`; repairs are `74a5b86`, `be610c3`, `4483050` and `ae6db65`. The reviewed eight-second shared recall limit and complete-fact 1,000-byte UTF-8 bound remain unchanged.

### Supported native repairs and evidence limits

The actual native install exposed four local integration defects, which were fixed without another approval stop:

- `UserPromptSubmit` now has a 20-second native outer timeout around existing five-second staging and eight-second recall limits. Other hook timeouts are unchanged.
- The private profile accepts only the native `[tui] screen_reader_detection_done` boolean in addition to its existing narrow trust fields.
- Native profile, workspace and launch bindings live under `~/.local/state/hindsight-memory-codex/{profile,workspace,launches}`. This preserves the bounded memory queue's flat-file invariant. Three initial native directories were journal-moved intact; native auth links, history and trust were preserved.
- The scoped launcher sets `features.plugins=false`. Codex otherwise synchronizes account remote plugins into a fresh private profile. Pinned official source `83086188ae0614bd882818ff1aa23f3194962012` verifies that this feature disables plugin bundle synchronization. The newly created private cache was quarantined, not deleted. It did not return during the final fresh conversation.

The first successful conversation preceded the plugin-disable repair. Its six synchronized manifests declared no hooks, commands or MCP registrations, and no tools ran. The final fresh conversation used the disabled-plugin route. This distinction remains explicit. Native first-launch trust and subsequent command changes were reviewed and trusted through the actual `/hooks` UI, followed by fresh launches. No trust injection or bypass was used. Native `SessionStart` was observed lazily at the first prompt. The initial `TERM=dumb` attempt refused before the TUI; successful launches used `TERM=xterm-256color`.

Ordinary Codex, Codex Desktop, existing project sessions, resume and fork remain outside this dedicated route. Claude Code 2.1.302 automatic capture remains blocked because its prompt event omits human-versus-automated origin. An interactive launcher cannot supply that missing native fact. Those coverage obligations remain open.

### Host preservation and undo

Five deployment parents changed from 0775 to 0755 after metadata checks: `~/.local/share/mise/installs/codex`, its `0.163.0` directory, `~/.local/share/mise/installs/node`, its `24.22.0` directory and `~/.codex`. The private journal records original device, inode and mode. The successful Pi permissions, xai/grok-4.3 settings, generated bridge and six completed jobs were preserved. Global Codex auth/config and Pi settings/auth/MCP-auth content hashes and file modes are unchanged. Native authentication refresh remains allowed through the shared auth symlink; no stale token snapshot is restored.

Launch Codex with `TERM=xterm-256color /home/fodurrr/.local/bin/codex-memory`. It starts in its dedicated persistent workspace and defaults to `gpt-6-luna`. The exact Pi launch above remains required, with fresh `/new` consent.

Stop capture with `/home/fodurrr/.local/bin/hindsight-memory deactivate`. To remove only Codex while restoring Pi-only active capture, close the dedicated Codex session and run the guarded private script `/var/tmp/hindsight-codex-live-finish/remove-codex.mjs` with the pinned Node 24.22.0 executable. It refuses intervening adapter changes and pending work, uses ownership-aware rollback/reconfiguration, and preserves completed receipts and native user state. The script was reviewed, not executed. Restore original directory modes only after removing affected routes and checking the recorded inode/current owned mode.

Private evidence is `/var/tmp/hindsight-codex-live-finish`: `journal.json`, `changed-permissions.json`, `native-state-move.json`, `native-trust.json`, `result.json`, `launch-and-undo.md`, `remove-codex.mjs` and pinned source excerpts. Native transcripts remain in the dedicated private profile. No remote terminal frames or authentication bytes were committed.

### Verification and remaining work

The source route's earlier 44 focused tests, eight terminal tests and one import-closure test were reused. Integration activation checks passed 8/8. Supported repairs passed selected checks: timeout 1/1, native TUI field 1/1, state separation plus combined activation 2/2, and plugin-disable arguments 1/1. Independent normal reviews found no remaining actionable findings in these changes. Documentation and whitespace checks are recorded at the final local checkpoint. No broad suite, separate Pi native run or qualification API retain was repeated.

No Nucleus communication, publication, push or main merge occurred. This is a successful GEEKOM Pi/dedicated-Codex deployment checkpoint, not the whole work item's completion. The work item remains **Active**, ExitGate **false**. Claude and other agent/desktop/project routes, other hosts, durability, performance and final ExitGate obligations remain open.

## Official installer replacement

Recorded **2026-10-18**. This is the current approved implementation direction.
The former standalone runtime and human-only/final-only capture restrictions are
retired. Those restrictions were additional engineering choices, not explicit
requirements in the original handoff. Earlier sections remain historical evidence.

### Installed local result

**GEEKOM now uses official integrations plus private settings.** No replacement
integration code, wrapper, queue, vendor fork or capture-policy engine was added.

The actual command was:

```sh
npx @vectorize-io/hindsight-coding-agents@0.8.1 install all --server self-hosted --api-url https://peters-mac-mini.wisent-fence.ts.net
```

The installer exited zero in approximately 1.7 seconds. It wired Pi, Claude Code,
Codex CLI, Grok and OpenCode. OpenCode v1/v2 aliases share one plugin entry, not two
writers. Kilo and Cline were detected from leftover state but have no installed
binaries; the newly added false-positive routes were removed through official
uninstall. Hermes retains its existing official plugin as its sole writer.
OpenCode, Grok and Hermes were not given new native conversation tests here.
Installation does not establish desktop, other-client or other-host coverage.

The service remains `https://peters-mac-mini.wisent-fence.ts.net`, bank `fodurrr`.
The protected `~/.hindsight/coding-agent.json` has mode 0600. Its private API token
was reused without printing or committing it. `dynamicBankId:false` and
`retainSessions:true` select normal shared personal-bank capture. Git ingestion
(`gitIngest:"none"`), initial seeding, codebase surveys, bank configuration
management and automatic package updates are disabled. The five documented
knowledge-page settings are false. Existing server pages were not deleted.
No bulk conversation import was enabled.

Normal capture includes meaningful session messages, progress and supported
automated activity. It does not capture every raw tool result, hidden reasoning
or every file on the machine. **Use fresh sessions after cutover.** Resuming older
conversations can still trigger upstream full-session retention of earlier text;
no no-history guarantee is claimed for old resumed conversations.

### Actual native checks and supported settings corrections

| Agent | Actual model | Native result |
|---|---|---|
| Pi 1.3.0 | Existing xai/grok-4.3 OAuth | Ordinary print-mode launch loaded normal extensions. Automatic retention included user and assistant text. A separate fresh session returned amber-cedar-9274 without the value in its prompt. Both runs exited zero. |
| Claude Code 2.1.302 | Existing claude-opus-5-5 OAuth | Automatic capture and fresh recall returned amber-ibis-9374 without the value in the prompt. Four checked operations completed. A supported SessionEnd setting correction captured final assistant text after transcript flush. |
| Codex CLI 0.163.0 | Existing gpt-6-luna | Actual native UI trusted three official hooks. Automatic capture retained two messages; remote extraction completed with zero extraction errors. Fresh automatic recall injected 21 results in 3.183 seconds. Exact new-label selection remains unproven: older same-topic test labels ranked ahead of the new fact. A read-only recall found the new label at rank32/46. |

The vendor default automatic reflection repeatedly timed out at 20 seconds.
Supported settings now use `autoInject:"recall"`, `injectTimeoutMs:10000` and
`recallOptions:{"types":null}`. This retrieves facts directly and includes fresh
facts before consolidation. Codex verifies the corrected automatic path. Pi and
Claude correctness evidence predates that shared correction and was reused; no
unnecessary repeat was run. One default Codex recall was stopped after 65 seconds
when it tried further reflection. No successful exact new-fact answer is claimed
for Codex. This is a retrieval-ranking limitation, not missing capture evidence.

Claude's normal Stop event read its transcript before final assistant text was
flushed. Configuration now invokes the same unmodified official
`claude-stop-hook.js` at native `SessionEnd`, timeout 60. The existing Stop hook
remains. The shared official cursor first retained one message, then appended the
final assistant message, ending clean at two messages. Both operations completed.
No second capture runtime or writer was added. This timing behavior was proved
for the tested print-mode sessions; no broader transcript timing guarantee is made.

Use ordinary `pi`, `claude` and `codex` with fresh sessions. Existing sessions need
a restart to load wiring. Native trust remains in force. Codex CLI proof does not
establish Codex Desktop coverage.

### Custom retirement, preservation and recovery

All ten previous custom deliveries were complete before deactivation. Owned
custom Pi extension, adapter descriptors and `hindsight-memory`/`codex-memory`
launchers were removed. The custom configuration, source, receipts, native history,
secret file and rollback evidence remain recoverable. No custom capture is active.

The bespoke app/profile, memory installer layer/helper, special-case selection,
listing/removal branches and obsolete installer test were removed. Dotfiles has
no installation path to the retired component. `tools/hindsight-memory` remains
explicitly marked as historical source. The user guide now contains only the
official command, private settings and normal usage/recovery directions.

Existing auth, unrelated hooks/plugins/settings and networking were preserved.
Codex's prior herdr hook remains. Native authentication refreshes were not replaced
with stale backups. Previously approved directory permissions were not blindly
reverted. No server upgrade, bank recreation, new service, reboot, credential
rotation or remote-host change occurred.

Private evidence and before-settings are under `/var/tmp/hindsight-official-cutover`:
`result.json`, `install.log`, `backup-manifest.json`, `after-manifest.json`,
`recall-settings-change.json`, and per-agent `pi`, `claude` and `codex` results.
A durable copy is `~/.local/state/hindsight-official-cutover/2026-10-18`.
Both directories are 0700; token-bearing settings/backups are 0600. No authentication
value or unrelated recalled text was committed.

**Claude removal needs one extra settings step:** vendor 0.8.1 uninstall removes
only its standard events. First remove only the owned `SessionEnd` entry whose
command is `node "/home/fodurrr/.hindsight/coding-agents/dist/claude-stop-hook.js"`
and timeout 60. Preserve other entries and later settings. Then run official
`uninstall claude-code`. Exact entry/backup/reversal details are in
`claude/sessionend-change.json` and `claude/README.md`. Other routes use official
per-agent uninstall. Do not blindly restore entire old authentication snapshots.

### Verification and remaining boundaries

The Linux installer suite passed with **zero failures**. Shell syntax, TOML
parsing, installer discovery, documentation drift and whitespace checks passed.
No custom integration test suite was rerun: that implementation is retired.
Independent normal review checked removal, settings, preservation, single writers,
native evidence and recovery. Its one supported recovery finding was corrected:
Claude SessionEnd must be removed before official uninstall. No remaining
supported defect was found. This normal review is not an ExitGate.

The approved GEEKOM replacement is installed and reviewed. Other host rollouts,
publication, push and main merge remain unapproved. No Nucleus communication
occurred. No new external-family paid review was run. The larger work item stays
Active with ExitGate false; administrative Completed and all-host completion are
not claimed. The former bespoke performance, caller-binding and adapter-building
work is superseded by the approved official-only direction, not outstanding code
work to resume.

## Desktop integration verification

Recorded **2026-10-18** under the user’s explicit desktop-support request.
Only official integration and settings were permitted. No Nucleus communication.

### Actual desktop support

| Desktop surface | Actual evidence | Open limit |
|---|---|---|
| Codex in official Linux ChatGPT desktop 26.1013.40934 | Bundled backend 0.163.0-alpha.10.2 uses `~/.codex`. Native process 11526 initialized Hindsight MCP. Three vendor hooks already have persisted trusted hashes. No Codex settings changed. | Main desktop hook execution, capture and fresh recall remain unverified. Native UI controls were unavailable. No CLI or delegated-child test is passed off as main desktop proof. |
| Official Claude Desktop Linux beta 2.42304.0, local Code | Its bundled Code 2.1.299 reads user/project/local settings. `CLAUDE_CODE_ENTRYPOINT=claude-desktop` identifies the native child. Actual desktop hooks injected 24 recall items and submitted retention. | Seven existing operations were pending when checked. No completed extraction or fresh desktop-session proof is claimed. |
| Claude Desktop Chat | Added only `mcpServers.hindsight` to `~/.config/Claude/claude_desktop_config.json`. The existing absolute Node path launches official `dist/mcp-server.js`, with literal `HINDSIGHT_MCP_HARNESS=claude-desktop`. Exact stdio settings initialized, listed eight tools and diagnosed bank `fodurrr` with matching protected credential. | The app must load the new settings on its next normal restart. This provides tools, not automatic Chat transcript capture. |
| Claude Cowork | No dedicated automatic Hindsight capture target was established in the installed official package. | No Cowork changes or working-capture claim. |

No app was restarted, main desktop conversation created, or old conversation deliberately tested.
No custom code was added, vendor code patched, remote host changed or shared
Hindsight configuration changed. Existing CLI routes and auth remain intact. Codex MCP log
rows were observed but rotated before export; the private report records that
observation limit rather than claiming a raw log snapshot.

### Existing older-session submission

The Claude Desktop Code session examined began on **2026-10-16**. Cutover began
on **2026-10-18** at 19:47:03Z. At 19:59:59Z the unmodified official runtime selected
`replace`, rendered the full parsed transcript and submitted it. Its diagnostic
reported 2,391 parsed turns. This confirms that pre-cutover messages were submitted;
it does not mean 2,391 facts were extracted. Seven cursor operation IDs were
accepted after cutover and were still `pending` on read-only inspection.
`retain_ok` establishes client submission/no-op, not completed extraction.
No transcript contents were copied into evidence. No operation was retried,
cancelled or deleted. This was preexisting activity, not a historical-import test.

The vendor’s full-session fallback therefore makes the fresh-session restriction
material. Start new desktop sessions; do not resume older ones to test capture.
Official pending-operation cancellation exists, but no server mutation was made:
`DELETE /v1/default/banks/{bank_id}/operations/{operation_id}`. Pending operations
can be stopped; processing cancellation may finish the current batch. Cancellation
does not undo committed memories, and child-operation cancellation is not established.
Terminal operations return 409.
Cancellation/deletion remains a concrete recovery decision, not an invented filter
or bank-wide cleanup.

### Preservation, verification and next native actions

Private evidence is `~/.local/state/hindsight-desktop-check/2026-10-18`.
Directories are 0700 and files 0600. Its `claude` directory contains the before-settings,
ownership journal, exact stdio readiness result and operation metadata. Its `codex`
directory contains findings and truthful desktop result metadata. Only the new
Claude Desktop MCP key is owned by this phase. Remove it only if it still matches
the journal; preserve unrelated and later settings. No token was copied to desktop
settings, repository files or output. No new Codex change needs rollback.

After active work ends, restart Claude Desktop normally. Check
`Claude Desktop -> Settings -> Developer`, then
use a fresh Chat to call `hindsight_diagnose`; expect `fodurrr`/`claude-desktop`.
This proves tools, not automatic Chat capture. A fresh local Code session still
needs capture/completed-extraction and later fresh-recall confirmation.
For Codex, use a fresh main Codex Desktop task for one harmless unique fact, verify the
matching native retention result, then ask for that fact in another new main task.
No desktop-control tool was available to perform those UI steps here.

Independent normal review found one short-snapshot overstatement: persisted hook
trust entries do not prove trust acceptance by the running backend. That wording
was corrected. Documentation and whitespace checks passed at this checkpoint.
This is supported configuration plus bounded desktop evidence, not complete desktop
memory verification. The work item remains **Active**, ExitGate **false**.
Publication, push, main merge and other host rollout remain unapproved.

Sources: [Codex hooks](https://learn.chatgpt.com/docs/hooks),
[Claude Desktop shared settings](https://code.claude.com/docs/en/desktop),
[local MCP settings](https://modelcontextprotocol.io/docs/develop/connect-local-servers),
[Hindsight cancellation](https://docs.hindsight.vectorize.io/api-reference/cancel-operation/).

## Pending-operation cancellation and desktop follow-up

Recorded **2026-10-18** under explicit approval to cancel pending old-session operations and finish desktop checks. Only official APIs and settings are permitted.

### Exact cancellation result

The seven previously saved operation IDs were each rechecked. All still reported `pending`. The same old Claude Desktop Code session's cursor identified two later accepted operation IDs. They also reported `pending`. The approval covers pending operations from that old session, so those two were included without enumerating unrelated bank work.

All **nine** official DELETE requests returned HTTP 200. Each follow-up GET confirmed `cancelled`. The final bounded snapshot was **2026-10-18 20:53:02 UTC**: nine cancellations, zero skipped, zero conflicts and zero request failures. No memories were deleted. Cancellation does not undo already saved memory or establish child-operation cancellation.

The old native Code session remains running and may submit later work. This snapshot does not claim permanent suppression. No broad capture setting was disabled. Finish that old session and use a fresh one.

Private evidence is `~/.local/state/hindsight-desktop-check/2026-10-18/cancellation`. `operations.json` records the original seven, `later-cancellation.json` records the additional two, and `combined-summary-nine.json` records the combined result. Exact IDs, before/after status and HTTP responses are retained without tokens or transcripts. Directories are 0700; files are 0600.

### Bounded desktop follow-up

| Surface | Follow-up result | Remaining action |
|---|---|---|
| Main Codex Desktop | Native `hooks/list` requests observed. No new vendor capture diagnostic or fresh main desktop session proof. Existing successful capture metadata says `source=cli`; `originator` alone is insufficient. | Fresh main desktop capture/extraction and later recall. |
| Claude Desktop Code | Same old native session still active. Actual earlier desktop hooks remain evidence of runtime use; no fresh-session proof. | Finish that session; check fresh local Code capture/extraction and later recall. |
| Claude Desktop Chat | No Hindsight server process or matching current desktop connection log observed. The saved setting has not demonstrably loaded. | After active work ends, restart normally; check `Claude Desktop -> Settings -> Developer`, then call `hindsight_diagnose` in fresh Chat. Expect `fodurrr` / `claude-desktop`. |
| Claude Cowork | No additional automatic-capture support established. | Keep automatic capture unsupported or unproved. |

Native desktop UI controls were unavailable. The available task-creation tool requires an explicit new-task request; general desktop verification authorization does not remove that tool prerequisite. No hidden UI transport, application restart, CLI substitute, custom integration, or delegated-child result was used as main desktop proof. Chat memory tools still do not automatically capture Chat transcripts.

No live settings changed during this follow-up. No Nucleus communication, publication, push, main merge or other-host change occurred. Repository documentation checks and independent normal review are recorded at the checkpoint. The work item remains Active, with native checks open and ExitGate false.

## Desktop fresh-session follow-up and English settings

Recorded **2026-10-18** after the user reported completing the native steps. Delegated native verification and official-language research used separate agents. A normal independent review checks the integrated result; no paid external review runs.

### Actual desktop results

| Surface | Verified result | Remaining limit |
|---|---|---|
| Claude Desktop Code | Reported answer belongs to the same resumed session begun on 2026-10-16. Native process started 2026-10-18 10:35:18 UTC. Existing hook capture/injected recall observed. | No fresh capture/extraction/recall proof. The saved enabled tool list contains three Chrome tools and no Hindsight; startup announced an empty local-MCP group. |
| Claude Desktop Chat | Official MCP settings remain present. Main desktop/native processes predate the added Hindsight setting. | No observed native Hindsight connection or actual Chat diagnosis. A full quit/reopen and fresh session is still needed; no settings defect was established. |
| Main Codex Desktop | Current native MCP initialization logs saved. | Backend is shared with delegated sessions. No new main desktop test fact or native main capture/recall proof. |

The supplied server-file rebuild explanation remains an unverified hypothesis. Existing official settings are present and no explicit Hindsight denial was found. No client setting was changed or custom repair code added. No API fact lookup ran because no fresh desktop test fact was identified. Reopening the old conversation does not prove a fresh session.

Three exact later operation IDs from the same old Claude session were each pending, cancelled with official DELETE returning HTTP 200, and confirmed cancelled by GET. This uses the earlier cancellation authorization; no unrelated operations were listed or changed. The bounded cumulative history is twelve successful parent cancellation acknowledgements and cancelled readbacks. These did not establish child cancellation; subsequent state changes are recorded below. No memories were deleted. The latest cursor has appendSupported true; 2,452 parsed turns does not establish another full-history replacement. No per-harness retain setting was disabled without such evidence.

Private evidence: `~/.local/state/hindsight-desktop-check/2026-10-18/fresh-verification/result.json`, current native log snapshots and `later-operation-cancellation.json`. Six saved files use 0600; the directory uses 0700. Exact same-session cancellation uses nine API requests: six GETs and three DELETEs. No API recall or retain was run by this check.

### Exact linked child closure

At 2026-10-18 21:07:46 UTC, all twelve exact linked children were inspected: two cancelled and verified, nine completed, one failed, none pending or processing. One processing child completed before DELETE; HTTP 409 was followed by GET completed. The failed child reports `Task exceeded the 3600s wall-clock limit for 'batch_retain'` and still reports 44 committed facts. No timeout setting was changed.

The original nine parents now read eight completed and one failed, superseding earlier cancelled readbacks. Parent cancellation did not prevent all extraction. Old-session data reached memory; no deletion was authorized or performed. Current statuses are bounded snapshots, not prevention of later submissions. The child follow-up used 27 API requests; combined with three later parent cancellations, 36 requests in this verification slice. Only exact same-old-session parent/child links were inspected; no bank-wide scan or fresh Claude job was touched. Full private responses are in fresh-verification/child-cancellation.json. No further polling was performed.

### Subsequent fresh Claude Code report

The user then reported a genuinely new Claude Code session: nine Hindsight MCP tools listed, four called; diagnosis confirmed the configured endpoint, fodurrr bank and enabled settings. Automatic recall returned the supplied harmless test label. This is user-supplied native evidence, not an independently matched fresh transcript/capture/completed-extraction result. It supersedes missing tools for that reported new Code session. Claude Chat and main Codex Desktop remain separate.

The user-reported sync status shows eight conversations, zero knowledge pages, missing Git seed and synced false. Seed/survey/knowledge pages are deliberately disabled; absent excluded work does not establish service failure or justify enabling ingestion. Nine reported jobs were not individually inspected. No unrelated watch/timer changed. A personal-server version inventory/upgrade is a separate next phase, not performed here.

### English output setting

The official setting is `HINDSIGHT_API_LLM_OUTPUT_LANGUAGE=English`. It is server-wide across banks, default unset; it is not a coding-agent client setting or per-bank override. It guides generated retain facts, consolidation observations/mental models and Hindsight reflect answers. It is prompt guidance, not a hard language validator.

A read-only GET /version reports live API 0.9.2. That version recognizes this setting but has conflicting preserve-source/extraction-language prompts. Official fix #3777 is included in release 0.10.0. Do not rely on English extraction on current 0.9.2. No server upgrade, environment edit or bank mission change was authorized or made.

Existing multilingual facts and raw transcripts are not translated. Current autoInject recall returns existing stored facts. The setting does not control Claude/Codex/Pi replies, repair missing MCP tools, or fix unrelated retrieval. The shared fodurrr bank intentionally spans projects. A retain/observations mission can request English but is softer prompt guidance, not a hard guarantee.

Private research: `~/.local/state/hindsight-desktop-check/2026-10-18/english-language-findings.md` (0600). Sources: [official multilingual settings](https://hindsight.vectorize.io/0.10/developer/multilingual), [bank scope](https://hindsight.vectorize.io/developer/api/memory-banks), [language prompt fix](https://github.com/vectorize-io/hindsight/pull/3777), [releases](https://github.com/vectorize-io/hindsight/releases).

### Next action and authority

After active Claude work ends, fully quit/reopen the app, check Claude Desktop -> Settings -> Developer, and use a genuinely fresh Chat/Code session. A fresh main Codex Desktop task is also needed. Match each harmless fact to native retention, completed extraction, then later fresh recall. No desktop UI control is available here. Existing old-session capture may continue; cancellation is a bounded snapshot, not permanent suppression.

English server configuration/upgrade remains a proposal requiring approval because it affects all banks on the Mini service. No Nucleus communication, publication, push, main merge, remote host or shared bank setting change occurred. The work item remains Active and ExitGate false. Independent normal review and repository documentation checks are recorded at this checkpoint.

## Mini server upgrade and English output

Recorded **2026-10-18** under explicit approval. This checkpoint updates the existing work item; it does not mark the full item Completed.

The official Mini server is now **1.0.0**, pinned to ARM64 manifest `sha256:0be688fa345092f6d88687330a6e9da012673652c5894787bef5527cc0082e30`. API, database health, existing authentication, provider/model, mounts, network and original production ports were verified. The canonical protected server environment adds only `HINDSIGHT_API_LLM_OUTPUT_LANGUAGE=English`; the effective setting is server-wide and not bank-overridable. All three original bank identity hashes were preserved. No other bank data/settings were inspected or rewritten beyond bounded aggregate preservation checks.

The first normal Docker stop failed with `Timeout reached, forcing shutdown...` while the API waited for five tasks. Automatic recovery restarted the original0.9.2 service before backup or migration. Source inspection and narrow independent review identified competing30-second shutdown timers. Native API-first signalling then allowed the API's own drain/requeue/PostgreSQL stop before wrapper cleanup. The corrected stop exited0. No vendor files were patched and no jobs were cancelled.

A full frozen-volume archive contains2,728,407,040bytes and3,122entries. SHA256 is `3c4f0e13834b4dab975bfa254942c56a5f6705ea83f23291cba4f4df82cbea24`. Tar comparisons against both original and restored clone passed; PostgreSQL control data reported shut down. Only the restored clone migrated, from revision `d1e2f3a4b5c6` to target Alembic head `c8e2f4a6b1d3`. Acceptance used alternate loopback ports while normal clients could not write to the candidate.

One short Russian statement of the approved English-memory preference produced an English fact. Exact-document recall and reflection succeeded in English. Existing multilingual facts and source transcripts were not translated. Language remains prompt guidance, not a hard validator. No unrelated bank test writes or historical cleanup occurred.

After acceptance, cleanly stopped clone storage was promoted to the original ports. The original frozen volume/image/stopped recovery container and checksum-verified archive remain. Recovery container restart is disabled; production retains `unless-stopped`. Production now accepts writes. Automatic rollback to frozen0.9.2 would lose newer visible state; preserve migrated storage and current refreshed authentication for any recovery. Never run an old binary on the migrated clone. Private exact manifests, logs, backup/restore proof and rollback notes are under `~/.local/state/hindsight-update-2026-10-18` and the recorded Mini backup directory.

Existing official coding-agents0.8.1 remains unchanged. ExternalAPI reports1.0.0. The existing official stdio server initialized eight tools; diagnosis confirmed `fodurrr`/`claude-desktop`, enabled settings and matching protected authentication; sync status succeeded. This proves transport/settings compatibility, not a new native desktop turn. Maintenance caused visible502 capture/retrieval failures. A bounded local cursor snapshot retains two Codex pending batches and one Claude pending batch, with zero dirty cursors. Complete client recovery is not claimed; normal official session activity must settle them. Deliberately disabled Git/pages still make `synced:false` expected.

Existing native fresh Claude DesktopCode evidence was independently matched: session created2026-10-18T21:03:18Z; actual diagnose+sync calls; automatic recall25facts/3562ms with an existing fact absent from prompt; completed parent/child extraction of five facts, zero errors. Four tools were loaded, not four MCP calls. This establishes fresh Code tools, existing-fact recall and completed capture; later fresh recall of a newly captured fact remains open. Main Codex Desktop and Claude Chat native checks remain open. No CLI/stdio/delegated-child result substitutes for them.

A bounded normal independent review checks the runtime and final documents. It is not an ExitGate. Documentation/whitespace checks and local checkpoint commit are recorded with this phase. No new integration code, framework, client upgrade, Nucleus communication, publication, push or main merge. Other host client rollouts remain unapproved. The whole work item remains **Active**, ExitGate **false**.

## Omen and Mini rollout

Recorded **2026-11-03** under Peter's approval: roll out as on GEEKOM, with the
same API token on all three machines, and add Grok and Antigravity where supported.
The full description is in [Personal Hindsight memory](../hindsight-memory.md#omen-mini-and-t3-code-environments).

- Official package 0.8.1 installed per named agent on Omen and Mini, after private
  backups under `~/.local/state/hindsight-host-rollout/2026-11-03`.
- Mini's Claude Code, Codex, Pi, Grok and Node raised to GEEKOM's versions with mise.
- Claude `SessionEnd` entry added and Codex hook trust recorded through the
  official Codex app server on both machines.
- Antigravity connected on GEEKOM too. T3 Code's Antigravity agent uses a private
  `GEMINI_HOME` that isolates hooks and MCP, so T3 Antigravity sessions are not captured.
- T3 tests: Omen Claude, Omen Codex, Mini Codex and GEEKOM Grok captured and
  completed on the server; one cross-machine automatic recall succeeded.
- Open: Peter's decision on T3 Antigravity capture; Claude login on Mini; desktop
  native checks. No push, publication or main merge. ExitGate remains false.

### T3 providers and Antigravity follow-up

Recorded later on **2026-11-03**. Grok and Antigravity were enabled in each
machine's T3 `settings.json` (no Claude-API, Peter), the Antigravity runtime was
installed with T3's pinned SHA-256, and GEEKOM's Antigravity sign-in was copied
(Peter: Way 1). Peter logged in Grok on both machines and Claude on Mini with the
Keychain unlocked. Grok (Omen, Mini) and Claude (Mini) captured through T3.
Option B links on GEEKOM load the hooks but have not produced a `Stop` capture.
Details: [Personal Hindsight memory](../hindsight-memory.md#t3-providers-on-omen-and-mini).
