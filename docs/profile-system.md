# Profile System Architecture

This document describes how profile-driven installation works and how to inspect profile/app assignments from `profiles/*.toml`.

## Overview

The installer uses profile files (`profiles/*.toml`) plus a centralized app registry (`apps.toml`) and layered installation logic.

- Profile membership source: `profiles/*.toml`
- App metadata source: `apps.toml`
- Install entrypoint: `./install.sh`
- Modes: interactive, profile, extras, clean, reconciliation

## Profiles

Supported profiles:

- `minimal`
- `standard`
- `developer`
- `hacker`
- `server`

Do not maintain static profile matrices in docs. Use dynamic queries below.

## Installation Architecture

### Phase 1: Bootstrap

Installs installer dependencies from `Brewfile.bootstrap` so phase 2 can run consistently.

### Phase 2: App Layers

Apps are installed from `apps.toml` by type:

- Layer 1: Homebrew (`cask`, `brew`)
- Layer 2: Stow (`stow`)
- Layer 3: Mise (`mise`)
- Layer 5: Curl fallback (`curl`), reserved for exceptional cases (currently `sheldon-linux` on Linux)

## Install Modes

```bash
# Interactive
./install.sh

# Single profile
./install.sh --profile=hacker

# Multiple profiles (merge)
./install.sh -p minimal -p standard

# Strict mode (remove managed apps not in selected profiles)
./install.sh --profile=hacker --clean

# Strict mode with untracked cleanup allowed
./install.sh --profile=hacker --clean --clean-untracked --yes

# Extras mode
./install.sh --extras

# Create profile mode
./install.sh --create-profile

# Cask reconciliation
./install.sh --profile=standard --reconcile-casks --reconcile-dry-run
./install.sh --profile=standard --reconcile-casks
./install.sh --profile=standard --reconcile-only
```

## Dynamic Discovery Commands

### List profiles

```bash
./install.sh --list-profiles
```

### List install status for configured apps

```bash
./install.sh --list-installed
```

### List apps in a profile

```bash
yq -p toml -oy '.macos.apps[]' profiles/hacker.toml
yq -p toml -oy '.linux.apps[]' profiles/hacker.toml
```

### List app + type in a profile

```bash
for app in $(yq -p toml -oy '.macos.apps[]' profiles/developer.toml); do
  printf "%s (%s)\n" "$app" "$(yq -p toml -oy ".apps.\"$app\".type" apps.toml)"
done
```

### List apps grouped by type

```bash
yq -p toml -oy '
  .apps
  | to_entries
  | sort_by(.value.type)
  | group_by(.value.type)
  | map({"type": .[0].value.type, "apps": map(.key)})
' apps.toml
```

## App Type Guidance

- `cask`: GUI applications via Homebrew
- `brew`: CLI formulae where Homebrew is preferred
- `mise`: default for CLIs and runtimes
- `stow`: configuration symlink packages
- `curl`: exceptional fallback only (currently `sheldon-linux` on Linux)
- `defaults`: macOS defaults automation

Selected cask metadata:
- `kind = "desktop"`: GUI desktop app cask
- `kind = "cli"`: cask that owns a command on PATH
- `bin`: optional explicit command name used for ownership/collision checks

CLI tool decision order:
1. `mise` (Recommended)
2. `brew`
3. `curl` fallback only for explicit exceptions

Ownership rule:
1. A command must have one owner per platform/profile combination.
2. If a command is cask-owned on macOS (for example `codex`), do not also assign a strict mise owner for macOS.

## Stow and Config Ownership

Use stow only for stable config paths; avoid runtime/state directories.

Reference: [`docs/stow-policy.md`](stow-policy.md)

## Related Docs

- [`README.md`](../README.md)
- [`docs/terminal-workflow-recommendations.md`](terminal-workflow-recommendations.md)
- [`docs/vm-testing.md`](vm-testing.md)

## Documentation Maintenance

Run the docs drift check before committing doc changes:

```bash
bash scripts/docs/check-doc-drift.sh
```
