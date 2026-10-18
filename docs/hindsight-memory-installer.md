# Hindsight installation ownership

Hindsight uses the **official installer plus private settings**.
Follow [personal Hindsight memory](hindsight-memory.md) for the command,
configuration, fresh-session limit and recovery.

The former `hindsight-memory` app, profile and custom installer layer are retired.
`./install.sh` does not prepare or activate that component.
Selecting machine profiles does not install a memory integration.

The historical source remains under `tools/hindsight-memory` for evidence and
recovery. It has no current installation path. Do not run its old preparation,
activation or dedicated launch commands.

The existing Mini service, bank and credentials remain independently managed.
Agent authentication, unrelated plugins and host networking are preserved.
Publication, main merge and other host rollouts require separate approval.
