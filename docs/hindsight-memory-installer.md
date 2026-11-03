# Hindsight installation ownership

Hindsight uses the **official installer plus private settings**.
Follow [personal Hindsight memory](hindsight-memory.md) for the command,
configuration, fresh-session limit and recovery.

The former `hindsight-memory` app, profile and custom installer layer are retired.
`./install.sh` does not prepare or activate that component.
Selecting machine profiles does not install a memory integration.

The historical source under `tools/hindsight-memory` was removed from the tree on
2026-11-03. Commit `b170d88` is the last one that contains it; read it there with
`git show b170d88:tools/hindsight-memory/README.md`.

For the manual per-machine steps, follow
[Hindsight memory on a new machine](hindsight-new-machine.md).

The existing Mini service, bank and credentials remain independently managed.
Agent authentication, unrelated plugins and host networking are preserved.
