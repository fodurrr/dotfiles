# Isolated Pi factory-load experiment

This experiment runs only the pinned Linux Pi 1.3.0 executable with `--help`.
It tests process-scoped extension loading. It grants no lasting capability.
It does not prove native session attachment, prompt eligibility or completed-turn capture.
Production activation remains blocked with `native-caller-binding-unqualified`.

## Run and inspect

Use the exact Node runtime from a Git source checkout:

```bash
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --test tools/hindsight-memory/experiments/pi-launch/test.mjs
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-launch/run.mjs --preflight-only
```

The tests run synthetic callbacks and harmless sandbox helpers. They never execute Pi.
The runner prints the private report path. Reports and diagnostics remain outside Git.
Each directory uses mode 0700; report and diagnostic files use mode 0600.
Host writes walk parent directories without following links. Existing symlinks,
hardlinks and special entries are refused. Opened directory handles anchor atomic saves.
Sandbox-created output names cannot redirect host writes outside the private directory.
After reaping sandbox processes, the runner validates diagnostic leaves through no-follow
file handles. Reports label missing or unsafe evidence. Never use `cat` on retained
sandbox-created paths. Inspect them through the bounded reader:

```bash
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node --input-type=module -e 'import {readEvidence} from "./tools/hindsight-memory/experiments/pi-launch/safe-output.mjs"; process.stdout.write(readEvidence(process.argv[1]).text)' /absolute/private/diagnostic-path
```

Failed preflights stop the run. There is no weaker confinement fallback.

After review, the authorized native command is:

```bash
/home/fodurrr/.local/share/mise/installs/node/24.22.0/bin/node tools/hindsight-memory/experiments/pi-launch/run.mjs
```

Native runs require committed, clean experiment files. They repeat all preflights first.
The command accepts no arbitrary Pi arguments, services, providers or configuration.
It runs positive, missing-channel and inherited-channel negative factory probes.
The inherited-channel child is a Node fixture inside native Pi. It is not another Pi or an SDK qualification.
Every Pi invocation ends with `--help`. No TUI, RPC or conversation is started.

## Fixed boundary

The selected runtime stays owned by mise. The experiment mounts that package read-only.
It installs no second distribution, launcher, hook, service or global extension.

| Item | Fixed selection |
|---|---|
| Pi archive | `/home/fodurrr/.local/share/mise/installs/pi/1.3.0/pi` |
| ELF size | 107174016 bytes |
| ELF SHA-256 | `c2415d6e6f7c67b0a55744c5ace5054936e252fcc3cf56ce087bc314061315ca` |
| Sidecar SHA-256 | `83c3bb7619f590c213cc96a24216eb29a819a3ef6dc548607cc037ed276e8dc5` |
| Expected host VERSION | `1.3.0` |
| Source reference | `earendil-works/pi` at `71023aec1546d6d677a65669c5665c0927ce0dd0` |
| Bubblewrap | `/usr/bin/bwrap`, version 0.11.1 |
| Handshake / process / total deadlines | 5 seconds / 20 seconds / 10 minutes |
| Combined stdout and stderr cap | 256 KiB per process; overflow fails |
| Protocol bounds | 4096 bytes per frame; 16384 bytes per channel |

The source reference explains behavior. It is not a reproducible-build attestation.
Whole-package, experiment, Node and library manifests detect changes before and after phases.
Read-only mounts do not freeze underlying host files. These checks do not attest loaded modules atomically.

The process tree is outer runner → Bubblewrap reaper → Node supervisor → exact Pi ELF.
Mount, PID, network, IPC and UTS namespaces are separate. The sandbox uses a fresh `/proc`.
It exposes no host home, repository, `/run`, desktop, provider or agent sockets.
Only the private output directory is writable on the host.
Homes, settings, sessions, XDG directories, cwd and temporary files use disposable tmpfs mounts.
Seven named shared-library files and the interpreter are mounted individually.
Only the inner harness files listed in `policy.mjs` enter the sandbox.
The outer runner and helpers are included in the full experiment drift manifest.

The environment is constructed from `ENV` in `policy.mjs`. Bubblewrap adds `PWD`;
the policy explicitly pins it to `/work`. Ambient environment values are never logged.
The namespace preflight records descriptor targets and rejects exposed host sentinels.
It tests a private host loopback listener, never a provider or memory endpoint.
It also tests read-only behavior using a disposable sentinel, not the installed package.

Both death preflights use harmless Node helpers. One kills the inner supervisor.
The other kills a temporary outer parent. Both must remove their observed descendants.
Residual processes fail the run even if fallback cleanup later succeeds.

## One-use observation

FD3 carries bounded `HELLO`, `ACK` and `DONE` frames.
The supervisor checks the direct child PID and kernel start time.
It opens `/proc/<pid>/exe`, hashes and stats that handle, then rechecks process identity.
The live file must match the selected ELF digest, size, device and inode.
The probe checks its actual PID, start time, parent and opened executable against the reply.
The loaded host VERSION must match the pinned sidecar version.
The factory awaits this exchange before returning.

Fragmentation is allowed. Unknown fields, duplicate/replayed claims, partial EOF,
missing channels, oversized input, deadlines and identity mismatches fail closed.
Expected EOF after DONE is allowed. `ack` records a queued ACK; DONE confirms receipt.
An ACK alone is never a final pass.
Later protocol failure, output overflow, drift or supervisor death invalidates the run.
Failure reports retain any earlier ACK/DONE observations.

The missing-channel native case requires an explicit probe refusal diagnostic.
The nested negative deliberately passes both the allowlisted environment and FD3.
Its Node child reports its own PID and must fail the parent's process claim.
Unsupported Bun channel behavior is a failed experiment, not an accepted substitute.

## Evidence classes and packaging

`test.mjs` imports the existing Pi adapter with an injected fake invoker.
Its closure gate permits one fresh synthetic session and revokes lifecycle or identity changes.
Rejected steps must make zero additional fake calls. These are synthetic callback tests only.
The native probe imports no memory core and invokes no memory command.
Network confinement and hidden host state provide additional boundaries.

The current production `prepare` traversal can copy dormant experiment sources into a release.
No launcher or activation installs or invokes them. `run.mjs` checks its own location
and refuses outside the expected Git source checkout, regardless of caller cwd.
Excluding experiment files from release packaging remains a separate publication decision.
This experiment does not change production packaging or activation.

Before implementation handoff, only synthetic tests and harmless preflights were run.
Actual Pi factory loading, Bun FD3 compatibility and native negative outcomes remain unrun.
Native session callbacks, real prompts, capture, macOS and other Pi versions remain unproved.
