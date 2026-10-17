# Profile System Architecture

This document describes how profile-driven installation works and how to inspect profile/app assignments from `profiles/*.toml`.

## Overview

The installer uses profile files (`profiles/*.toml`) plus a centralized app registry (`apps.toml`) and layered installation logic.

- Profile membership source: `profiles/*.toml`
- App metadata source: `apps.toml`
- Install entrypoint: `./install.sh`
- Modes: interactive, profile, extras, clean, reconciliation

## Profiles

Discover available profiles with `./install.sh --list-profiles`.
The [README machine table](../README.md#machine-profiles-and-branches) records the intended host selections.
GEEKOM uses `developer` with optional `geekom-vpn`; Omen uses `omen`.
The retired `clevo` profile remains available as a reference.
Profiles choose app membership; use shared `main` for normal installation.

Do not maintain duplicate app matrices in docs. Query the TOML files below.

## Installation Architecture

### Phase 1: Bootstrap

On macOS, installs Homebrew prerequisites from `Brewfile.bootstrap`.
On Linux, installs native `apt`/`dnf` prerequisites and checks TOML-capable `yq`.

### Phase 2: App Layers

Apps are installed from `apps.toml` by type and platform:

1. Homebrew (`cask`/`brew`) on macOS, or mapped native Linux packages (`brew` metadata).
2. Generated mise configuration, then stable configuration files linked with Stow (`stow`).
3. Mise tools (`mise`), then local launchers handled by the fallback layer (`curl`).
4. Linux extras: `apt-repo`, `deb`, `script`, `snap`, `gsettings`, `gnome-shortcut` and `font`.
5. Remaining platform configuration and the final summary.

App/layer failures are recorded while later steps continue. The final summary returns nonzero if failures occurred.
Bootstrap or invalid input can stop earlier. Successful installs remain installed.

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
yq -p toml -oy '.macos | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/hacker.toml
yq -p toml -oy '.linux | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/hacker.toml
```

### List app + type in a profile

```bash
for app in $(yq -p toml -oy '.macos | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/developer.toml); do
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
- `curl`: exceptional local launcher handling (currently `codex-xpando`; its source is copied, not downloaded)
- Linux native extras: vendor packages, scripts, Snap apps, GNOME preferences, shortcuts and fonts
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
2. A CLI that the mise registry offers is a mise app on every platform; a Homebrew cask owns only the desktop app (for example `codex-app`).

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
