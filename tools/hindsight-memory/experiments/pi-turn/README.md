# Confined Pi turn preview

This experiment is prepared for a separate native-execution approval. Pi and Bun
have not run during preparation. Production activation remains blocked.

The default and `--preflight-only` modes execute only our harmless Node surrogate
through a Python PTY. They never execute or import Pi, Bun or upstream clients.

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test tools/hindsight-memory/experiments/pi-turn/test.mjs
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --preflight-only
```

## Exact proposed native command

Run from `/home/fodurrr/dev/dotfiles` **only after native approval**:

```sh
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-turn/run.mjs --native
```

The runner requires committed, clean component sources. It repeats all five
harmless preflights before one native process. A failed prerequisite stops it.
The child command is fixed; arbitrary flags and prompts are unavailable:

```text
/pi/pi --no-extensions -e /work/sole-bridge.mjs
```

The read-only `/pi` mount is the selected Pi 1.3.0 package at
`/home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi`.
Its ELF SHA-256 is
`c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca`.
The sole generated wrapper composes the existing bridge with native event
observers. It does not fabricate callbacks or register a provider extension.

## Fixed two-turn acceptance

1. Submit `HISTORY_EXCLUSION_SENTINEL` before consent. Require native settlement
   and zero registered memory sessions, jobs or recalls.
2. Submit native `/new`. Wait for the actual destination-confirmation event and
   displayed fixture endpoint. Send one LF byte to accept the default Yes.
3. Submit `Synthetic Pi turn: say TURN_FINAL_SENTINEL.`. Require real Pi input,
   persisted `turn_end` identity and successful `agent_settled` observations.
4. Require one original-prompt recall, two exact retained messages, two bank
   checks, two completed operation polls and two durable completed jobs. Reject
   historical, recalled, tool or reasoning sentinels from retained content.
5. Stop the PTY child deliberately after acceptance. Record its actual exit
   status and reap every descendant; do not claim a natural clean Pi exit.

Both model requests use the private OpenAI-compatible SSE fixture. The second
must contain the fresh prompt and untrusted recall, without historical text.
Private `models.json` and settings select only `loopback/fixture`, disable tools,
cache warming and Pi/provider retries, and set a five-second provider timeout. Dummy keys
stay inside the sandbox. No external provider, quota or personal bank is used.

Enter accepts Yes in the pinned [confirmation component](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/coding-agent/src/modes/interactive/components/extension-selector.ts#L88).
The fixture follows the pinned [provider stream contract](https://github.com/earendil-works/pi/blob/71023aec1546d6d677a65669c5665c0927ce0dd0/packages/ai/src/api/openai-completions.ts#L541).
This source evidence does not replace the proposed native observation.

## Isolation, budgets and evidence

| Boundary | Fixed behavior |
|---|---|
| Confinement | Bubblewrap 0.11.1; separate mount, user, PID, network, IPC and UTS namespaces; all capabilities dropped |
| Environment | Cleared, then only `ENV` in [policy.mjs](policy.mjs); private HOME, XDG, agent, session and working directories; no host auth or sockets |
| Read-only files | Selected Pi package, Node 24.22.0, Python 3.14, 37 listed standard-library files, nine shared libraries and named component/harness files |
| Writable state | Disposable tmpfs; only the private report directory is writable on the host |
| Services | Two loopback HTTP fixtures inside the private network namespace; the host listener must remain unreachable |
| Activation | Existing private `Store.activate` test seam only; no production CLI activation or installer changes |
| Deadlines | 180 seconds overall; 60 seconds per sandbox; 45 seconds for native PTY; five seconds per provider request; no provider retry |
| Output and HTTP | 256 KiB combined process output; 128 KiB terminal output; 64 KiB request bodies; at most 12 fixture requests |
| Cleanup | Existing PID/start-time tracking, namespace teardown and both parent-death preflights; residual processes fail the run |
| Stop rule | First identity, source, confinement, protocol, counter, deadline, output, drift or cleanup failure stops; no automatic native retry |

The exact file and environment allowlists are executable in `policy.mjs`.
Read-only mounts do not freeze host files; the runner checks fingerprints before
and after phases. The Python helper uses `-I -S -B`; no Python runtime is installed.

Reports remain under private `/var/tmp/hindsight-pi-turn-*` directories.
Inspect sandbox-produced files with `readEvidence` from
`../pi-launch/safe-output.mjs`. Do not follow their names with ordinary readers.
Reports separate native request/attempt from exact-ELF observation. After an
attempt, `not-observed` does not prove that no native code executed.

Harmless preflights qualify PTY transport, local reachability, confinement,
limits and cleanup. They do not qualify native Pi events or completed capture.
Other routes, queued capture, live API semantics, performance and ExitGate stay open.
