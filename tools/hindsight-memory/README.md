# Personal Hindsight memory component

This private local component prepares independently installable artifacts.
**All automatic adapter activation currently refuses** with
`native-caller-binding-unqualified`. Adapters remain isolated source/fixture
qualification artifacts until actual invoking applications can be bound safely. It uses
Node 24.15 or newer within Node 24, including `node:sqlite`. It needs no npm
packages, company tooling, source checkout, shell initialization or resident service.

See [the user guide](../../docs/hindsight-memory.md) for configuration, consent,
qualification limits and rollback. See [adapter evidence](adapters/README.md) for
exact native interfaces. The internal package is private; it is not an npm release.

## Interface version 1

`node src/cli.mjs <command>` emits one JSON object with `schema_version:1` and
`status`. Invalid operations return nonzero with a safe reason code. JSON inputs
arrive through stdin. Prompts, authentication and configuration values never
appear in process arguments.

| Command | Input / purpose |
|---|---|
| `prepare` | Copy a content-addressed release and fixed-runtime launcher; no hooks or activation |
| `configure` | Explicit schema-1 endpoint, bank, private secret-file reference, adapters and exact `agent_versions` |
| `activation-preview` | List source/fixture artifacts, native caller blocker and required trust; no changes |
| `activate` | Refuse with `native-caller-binding-unqualified`; no production adapter currently passes this gate |
| `status`, `inspect`, `doctor` | Read-only safe counts and state; no network, repair or retry |
| `session` | Enroll a native session with `{agent,session,owner,baseline}`; baseline is never retained |
| `session-status` | Return registered cursor identity and count, never conversation text |
| `capture` | Admit a completed eligible suffix with exact `previous` identity |
| `capture-transcript` | Verify enrolled prefix digest and admit only the eligible suffix |
| `stage-turn` | Persist an original prompt using a stable native `turn_id`; not yet accepted for retention |
| `complete-turn` | Atomically admit staged original prompt plus completed assistant text |
| `abort-turn` | Discard one explicitly cancelled staged turn; no retention |
| `recall` | Once per stable native turn; direct recall with untrusted labeled output |
| `worker` | Deliver eligible queued work for at most 60 seconds |
| `retry` | Explicit reconciliation or acknowledged same-operation resubmission; never invent a new UUID |
| `deactivate` | Stop admission and delivery claims; report outstanding network leases |
| `rollback` | Deactivate and remove only owned adapter writes; keep memories, cursors, jobs and installed code |

Every event envelope includes `schema_version:1`, `agent`, `session` and `owner`.
Message objects contain stable `id`, `role` (`user` or `assistant`), `text` and
`completed:true`. Tools, partial replies, injected recall and reasoning are refused.
Adapters use the same core queue and policy. They do not implement independent HTTP
clients, secret loading or queues.

## Verification

```sh
node --disable-warning=ExperimentalWarning --test test/*.test.mjs
node --disable-warning=ExperimentalWarning test/benchmark.mjs
node --disable-warning=ExperimentalWarning test/benchmark-native.mjs
```

Tests use synthetic users, temporary homes and loopback HTTP only. They do not
start upstream applications or change the operator's configuration. The benchmark
measures direct durable admission and a separate Node/Store/admission/exit process.
It excludes native application startup and network extraction. It reports the filesystem type. On the inspected host, `/tmp` is tmpfs; those results do not measure physical-disk fsync. Use an explicitly chosen private disk-backed temporary root, such as `TMPDIR=/var/tmp`, for disk timing. Fixture success
is not live host qualification or proof of macOS filesystem behavior.

The native benchmark explicitly wires only a synthetic source fixture after
asserting production activation is blocked. It records every attempted sample,
including rejections. It measures 30 growing 5.1 KiB turns through two local Node
processes with normal background delivery and a loopback fake API. It defaults to
a private `/var/tmp` fixture. This does not certify an actual native caller.
