# Personal memory installer boundary

The optional `hindsight-memory` profile selects only Node and the local memory
component. It does not select agent CLIs, company launchers, a bank or a server.
The component can also prepare itself independently of the Dotfiles installer.

Preparation installs versioned artifacts and the owned local launcher.
It does not activate hooks, change credentials, write memories or start services.
Activation is a separate approved host operation.
See the [canonical work item](plans/hindsight-memory.md) for the full scope.

## Profile selection

A fresh host can select the optional profile alone. A configured host must select
its complete existing profile set alongside `hindsight-memory`.
The installer refuses `--clean` whenever memory preparation is selected.
These checks run before bootstrap on hosts with a working TOML-capable `yq`.

The installer previews its actual mise tool generator and compares runtime keys
against existing global mise configurations. A missing runtime key stops the run.
An unreadable or invalid global configuration also stops the run.
The guard does not merge configurations or preserve arbitrary settings automatically.
Review the complete profile selection before applying it.

If TOML-capable `yq` is unavailable, configured hosts stop before bootstrap.
Install that prerequisite separately before selecting profiles interactively.
Only fresh additive installs can bootstrap the parser before their first selection.
Discovery commands (`--help`, `--list-profiles`, `--list-installed`) keep their
existing read-only behavior and do not enter bootstrap.

Extras and a la carte selection exclude the component explicitly.
A la carte removal refuses it. Use the component's ownership-aware deactivate and
rollback workflow after separate approval. Package removal must not delete queues,
activation records or unrelated hooks.

## Runtime and result checks

The preparation layer runs after mise and Linux extras. It resolves Node through
`mise which node`, requires an absolute executable and checks Node 24.15 or newer within major 24
plus `node:sqlite`. It never falls back to a random `node` on `PATH`.
The component records and verifies the actual runtime used by its launcher.
A later missing, pruned or replaced runtime requires requalification.

The layer validates the component's JSON schema, booleans and status.
Artifact presence alone does not establish configuration or activation.
`activation-pending` means installation succeeded and capture remains inactive.
Partial, malformed and failed preparation produce a final nonzero installer result.
Independent later installer steps still run.

`--list-installed` inspects the fixed owned launcher at
`~/.local/bin/hindsight-memory`, using its read-only `status` command.
It reports the validated state or `unavailable` when that state cannot be checked.
It does not invoke a similarly named command from `PATH`.
Before execution, it rejects symlinked launchers or ancestors, multiple hard links,
and group/world-writable launchers or ancestors. Root-owned sticky temporary
directories are allowed. Normal owned `0755` parents are accepted.
Unsafe permissions cause an `unavailable` status; inspection does not change them.
Raw component output and error details are not copied into `install.log`.
No configuration values, conversation text or secret values belong in that log.

## Isolated checks

Run `bash scripts/test-memory-installer.sh` for temporary-home tests.
The suite uses fake runtimes and replaces bootstrap with a failure marker.
It tests actual entrypoint ordering, custom-profile clean/addon guards, runtime
preservation, status validation, preparation failures and later-step continuation.
It does not install packages, change the operator's home or call a memory server.

A fixture pass is not macOS host validation or a live installation test.
Host installation, main merge and publication require separate approval.
