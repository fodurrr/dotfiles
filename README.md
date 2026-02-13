# Dotfiles

Profile-based dotfiles for macOS (Apple Silicon) and Linux (Ubuntu, Debian, Fedora).
This repository installs apps and shell/config tooling through a single `install.sh` entrypoint, with optional cleanup and reconciliation workflows.

## Quick Start

### Prerequisites

**macOS**:
- macOS on Apple Silicon
- Xcode Command Line Tools (`xcode-select --install`)
- Git

**Linux**:
- Ubuntu 20.04+, Debian 11+, Fedora 35+
- Git
- sudo access for package installation
- Native package manager support only (`apt` or `dnf`; Linuxbrew is not used)
- Installer finalizes zsh login shell (`chsh`) as part of successful setup

Optional:
- Fresh VM testing workflow: see [`docs/vm-testing.md`](docs/vm-testing.md)

### Install

```bash
git clone git@github.com:fodurrr/dotfiles.git
cd dotfiles
./install.sh
```

For a full flag list with one-line explanations:

```bash
./install.sh --help
```

## Install Modes

### Interactive Install

Use profile/a-la-carte prompts and install selected items.

```bash
./install.sh
```

### Profile Install

Install one profile directly without interactive prompts.

```bash
./install.sh --profile=hacker
```

Install multiple profiles as a merged set:

```bash
./install.sh -p minimal -p standard
```

### Clean Mode

Remove managed apps that are not in the selected profile set.

```bash
./install.sh --profile=hacker --clean
```

Allow non-interactive removal of untracked Homebrew apps during clean:

```bash
./install.sh --profile=hacker --clean --clean-untracked --yes
```

### Extras Mode

Install individual apps interactively.

```bash
./install.sh --extras
```

### Cask Reconciliation

macOS only.

Adopt unmanaged `/Applications` GUI apps into Homebrew cask ownership.

Preview only:

```bash
./install.sh --profile=standard --reconcile-casks --reconcile-dry-run
```

Apply and continue install:

```bash
./install.sh --profile=standard --reconcile-casks
```

Apply only reconciliation and exit:

```bash
./install.sh --profile=standard --reconcile-only
```

## Profiles and Apps (Dynamic Listing)

Avoid static profile/app matrices in README. Use live data from `apps.toml`.

### List available profiles

```bash
./install.sh --list-profiles
```

### List install status for apps in `apps.toml`

```bash
./install.sh --list-installed
```

### List apps in a profile (example: `hacker`)

```bash
yq -p toml -oy '
  .apps
  | to_entries
  | map(select((.value.profiles // [])[] == "hacker"))
  | .[].key
' apps.toml
```

### List app + type for a profile (example: `developer`)

```bash
yq -p toml -oy '
  .apps
  | to_entries
  | map(select((.value.profiles // [])[] == "developer"))
  | map({"app": .key, "type": .value.type})
' apps.toml
```

### List all apps by type

```bash
yq -p toml -oy '
  .apps
  | to_entries
  | sort_by(.value.type)
  | group_by(.value.type)
  | map({"type": .[0].value.type, "apps": map(.key)})
' apps.toml
```

## Common Commands

| Command | Purpose |
|---|---|
| `./install.sh` | Interactive install flow |
| `./install.sh --help` | Show flags and examples |
| `./install.sh --profile=<name>` | Install one profile non-interactively |
| `./install.sh -p <a> -p <b>` | Install merged profiles |
| `./install.sh --profile=<name> --clean` | Strict profile sync for managed apps |
| `./install.sh --extras` | Install individual apps interactively |
| `./install.sh --list-profiles` | Print profiles parsed from `apps.toml` |
| `./install.sh --list-installed` | Print local install status for configured apps |
| `mise install` | Update/install Mise tools from generated config |
| `bash scripts/curl-installs.sh` | Placeholder entrypoint (no active manual curl installers) |
| `source ~/.zshrc` | Reload shell after config/tool changes |

## Global AI Secrets

Store machine-local AI tokens outside repositories:

- file: `~/.config/secrets/ai.env`
- expected mode: `600`
- loaded automatically by `.zshrc`
- synced to launchd for GUI tools from login shell or manually with:
  - `ai-env-sync`

Quick setup:

```bash
mkdir -p ~/.config/secrets
chmod 700 ~/.config/secrets
cp .env.ai.example ~/.config/secrets/ai.env
chmod 600 ~/.config/secrets/ai.env
source ~/.zshrc
ai-env-sync
```

## Troubleshooting

### 1) Command not found after install

```bash
source ~/.zshrc
hash -r
which -a starship fzf mise sheldon yazi eza gum
echo "$SHELL"
getent passwd "$USER" | cut -d: -f7
# If needed:
chsh -s "$(command -v zsh)" "$USER"
```

### 2) Homebrew cask conflict (example: Office vs OneDrive)

```bash
brew list --cask | rg 'onedrive|microsoft-office'
./install.sh --profile=standard --reconcile-casks --reconcile-dry-run
```

### 3) Clean mode stops because of untracked Homebrew apps

macOS only.

This is expected safety behavior. Re-run with explicit acknowledgment:

```bash
./install.sh --profile=hacker --clean --clean-untracked --yes
```

### 4) Config symlink/state looks wrong

```bash
ls -la ~/.config/mise/config.toml
ls -la ~/.zshrc
find ~ -name "*.bak" -type f 2>/dev/null
```

### 5) AI CLI command-source collision (strict mise enforcement)

Layer 3 fails for strict AI CLI tools (`claude`, `opencode`, `gemini`, and Linux `codex`) when a command resolves to multiple sources or the first path is not the expected mise install path.

Ownership model:
- macOS `codex` CLI: Homebrew cask (`codex`)
- macOS Codex desktop app: Homebrew cask (`codex-app`)
- Linux `codex` CLI: `mise`
- `claude`, `opencode`, `gemini`: `mise`

```bash
# macOS Codex ownership check
which -a codex
brew info --cask codex codex-app

# Linux Codex ownership check
which -a codex
mise current codex

# Strict mise-owned AI CLIs
which -a gemini
mise current gemini-cli
mise latest gemini-cli

which -a claude opencode
mise current claude opencode

# Example cleanup for legacy Claude vendor symlink:
rm ~/.local/bin/claude
hash -r
which -a claude
```

`version = "latest"` mise tools are refreshed on each install run, while your existing `lts`/`stable`/pinned versions remain unchanged.

## Documentation Map

- [`docs/profile-system.md`](docs/profile-system.md): Profile architecture and deeper behavior
- [`docs/terminal-workflow-recommendations.md`](docs/terminal-workflow-recommendations.md): Terminal-focused recommendations and profile detail
- [`docs/linux-support.md`](docs/linux-support.md): Linux platform support and installation guide
- [`docs/vm-testing.md`](docs/vm-testing.md): Safe testing in a macOS VM
- [`docs/ai-secrets.md`](docs/ai-secrets.md): Portable global AI secret loading and launchd sync behavior
- [`docs/stow-policy.md`](docs/stow-policy.md): Stow rules for stable config-only symlinking
- [`docs/ai-agent-sandbox-guide.md`](docs/ai-agent-sandbox-guide.md): Sandboxing patterns for AI coding tools
- [`docs/ssh-github-setup.md`](docs/ssh-github-setup.md): SSH setup for GitHub access
- [`docs/ntfs-fuse-t-automount.md`](docs/ntfs-fuse-t-automount.md): Optional NTFS FUSE-T automount reference (manual setup)

## License

MIT
