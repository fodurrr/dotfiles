# CLAUDE.md

This file is the source of truth for agent guidance in this repo. `AGENTS.md` must mirror this file exactly.

## 🚨 Git Workflow Rules (MANDATORY)

1. **NEVER commit, merge, or push to `main` branch**; always work in a feature branch.
2. **After completing work**, commit and push so the user can test in a VM.
3. **After every push**, provide VM commands using the actual repo path from the current working directory.

```bash
# Example format (replace <repo-path> with your actual path):
cd <repo-path>
git pull
./install.sh --profile=<profile>
```

## Documentation Searches

When researching tool/app docs:
- Check local installed version first (for example `tool --version`).
- Prefer latest/current docs.
- Do not add year constraints to searches.
- Prefer official domains.

## Asking Questions and Recommendations

When presenting options:
- Include a recommendation marked with `(Recommended)`.
- Put the recommended option first.
- Briefly explain why.

## Overview

This is a macOS (Apple Silicon) and Linux (Ubuntu, Debian, Fedora) dotfiles repository with a profile-based installer and a platform-aware two-phase install flow.

## Critical Constraints

### Bash 3.2 Compatibility (MANDATORY)

All shell scripts must run on macOS system bash 3.2.

Do not use bash 4+ features like associative arrays, `mapfile`, `${var,,}`, `${var^^}`, `&>`, `|&`, `coproc`, or `[[ =~ ]]` capture groups.

Before committing shell changes:

```bash
bash -n install.sh
bash -n scripts/install/*.sh
bash -n scripts/lib/*.sh
```

### TOML Parsing

Use `yq` with TOML input:

```bash
yq -p toml -oy '.apps.ghostty.type' apps.toml
yq -p toml -oy '.apps.ghostty.profiles' apps.toml
```

### Target Environment

Scripts must be idempotent and work on:
- fresh macOS installs
- already-configured systems
- repeated runs after editing `apps.toml`

Use a clean macOS VM for confidence checks.

## Install Architecture (High Level)

1. **Phase 1 bootstrap**: installs install-time dependencies (`Brewfile.bootstrap`).
2. **Phase 2 profile/extras**: installs configured apps from `apps.toml` in layers:
- Layer 1: Homebrew (`cask`/`brew`)
- Layer 2: Stow (`stow`)
- Layer 3: Mise (`mise`)
- Layer 5: Curl fallback (`curl`, exceptional/vendor-only cases)

## Profiles

- `minimal`: bare essentials
- `standard`: general user profile
- `developer`: GUI-forward development
- `hacker`: terminal-forward power usage
- `server`: terminal-only/headless

Use dynamic discovery instead of static matrices:

```bash
./install.sh --list-profiles
./install.sh --list-installed
```

## Common Commands

```bash
# Interactive
./install.sh

# Profile installs
./install.sh --profile=hacker
./install.sh -p minimal -p standard

# Strict sync
./install.sh --profile=hacker --clean
./install.sh --profile=hacker --clean --clean-untracked --yes

# Extras menu
./install.sh --extras

# Reconciliation
./install.sh --profile=standard --reconcile-casks --reconcile-dry-run
./install.sh --profile=standard --reconcile-casks
./install.sh --profile=standard --reconcile-only

# Discovery
./install.sh --list-profiles
./install.sh --list-installed

# Layers
mise install
bash scripts/curl-installs.sh

# Shell reload
source ~/.zshrc
```

## App Registry Rules

`apps.toml` is the only source of app/profile truth.

Supported app types:
- `cask`: Homebrew GUI app
- `brew`: Homebrew formula
- `mise`: Mise-managed CLI/runtime
- `stow`: symlinked config package
- `curl`: vendor installer fallback (exceptional)
- `defaults`: macOS defaults writes

CLI decision guide:
- Prefer `mise` for runtimes/CLIs.
- Use `curl` only when no reliable `mise`/Homebrew path exists.

## Profile Switching Semantics

- Default mode is merge: add selected profile apps, keep existing installs.
- `--clean` mode enforces selected profile set by removing managed out-of-scope apps.

## Stow Policy

Only stow stable, version-worthy config paths.
Never stow runtime/state directories.

Full policy: `docs/stow-policy.md`

## Shell Initialization Order

`.zshrc` should initialize in this order:
1. PATH setup
2. Mise activation
3. Sheldon plugins
4. Tool init (starship/fzf/etc.)
5. aliases/functions

## Linux Platform Support

This repository now supports Linux (Ubuntu, Debian, Fedora) in addition to macOS.

### Platform Detection
- The installer automatically detects the platform (macOS or Linux)
- Uses appropriate package manager: Homebrew (macOS), apt (Ubuntu/Debian), or dnf (Fedora)
- Platform-aware layering: Homebrew layer runs on macOS, Linux layer runs on Linux

### apps.toml Platform Fields
- GUI apps have `platform = ["macos"]` to skip on Linux
- CLI tools have `platform = ["macos", "linux"]` for cross-platform support
- No `platform` field = all platforms supported

### Linux Testing
- Run `./scripts/test-linux.sh` to test platform detection and package manager integration
- Use `docs/linux-support.md` for Linux-specific installation guidance

### Platform-Specific Behavior
- **macOS**: Homebrew for all packages, GUI apps via casks, full profile support
- **Linux**: apt/dnf for packages, mise for version management, GUI apps skipped (install manually)

### Platform Notes for Agents
- When adding new apps, specify `platform` field appropriately
- Cross-platform CLI tools should include both macOS and Linux
- GUI apps should be marked macOS-only (`platform = ["macos"]`)

## Documentation Map

- `README.md`: onboarding and quick start
- `docs/profile-system.md`: architecture and profile behavior
- `docs/linux-support.md`: Linux platform support and installation guide
- `docs/terminal-workflow-recommendations.md`: terminal workflow guidance
- `docs/vm-testing.md`: VM workflow
- `docs/stow-policy.md`: stow boundaries
- `docs/ai-agent-sandbox-guide.md`: sandboxing AI coding tools
- `docs/ssh-github-setup.md`: SSH setup

## Docs Drift Check

Run before committing docs changes:

```bash
bash scripts/docs/check-doc-drift.sh
```

## Conductor Workspace Workflow

When using separate worktrees:
- keep changes isolated
- push after each logical unit
- provide VM validation commands with actual path

For shell changes, include:

```bash
source ~/.zshrc
```
