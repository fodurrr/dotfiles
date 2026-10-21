# Dotfiles

Profile-based dotfiles for macOS (Apple Silicon) and Linux (Ubuntu, Debian, Fedora).
This repository installs apps and shell/config tooling through a single `install.sh` entrypoint, with optional cleanup and reconciliation workflows.

## Machine profiles and branches

**Use `main` for normal installation and updates. Profiles choose the machine setup; branches hold changes under development.**
After the 2026-10-17 consolidation, `main` includes the GEEKOM, Omen and Clevo installer work.
You do not need to switch to an old machine branch to install its profile.

| Machine or purpose | Profile selection | Scope |
|---|---|---|
| GEEKOM daily desktop | `developer` | Linux desktop, development tools, display shortcuts, dictation and Tailscale tray |
| GEEKOM VPN additions | `developer` + `geekom-vpn` | Adds native Firefox, qBittorrent and Private Internet Access |
| Omen development host | `omen` | Ubuntu Server tools, agent CLIs, Docker and PostgreSQL; no desktop or VPN apps |
| Retired Clevo laptop | `clevo` | Retained reference profile without GEEKOM display and dictation defaults |
| Other machines | Discover with `--list-profiles` | Inspect the selected platform in `profiles/*.toml` before installing |

These are intended machine assignments, not hostname enforcement by the main installer.
The GEEKOM VPN configuration helper separately checks the hostname.
The retired Clevo profile remains optional; its general installer fixes are shared by all profiles.

### GEEKOM installation

Run as your normal user, with sudo available:

```bash
cd /home/fodurrr/dev/dotfiles
./install.sh -p developer -p geekom-vpn
```

For a desktop without the VPN additions, select only `developer`.
After installing the VPN apps, sign in to PIA and close qBittorrent before applying the separate helper:

```bash
bash scripts/configure-geekom-pia.sh
```

See [GEEKOM VPN setup](docs/geekom-pia.md) for the application rules, `wgpia0` binding,
Tailscale routing, backups and remaining checks. Credentials stay outside Git.
The `developer` profile also installs the Tailscale tray autostart entry.
On Linux it includes the full LibreOffice suite through the native package manager
(`libreoffice`). Writer opens Word documents; Calc and Impress handle spreadsheets
and presentations. The headless `omen` and `server` profiles do not select it.

### Omen installation

Run on Omen, including when connected through `ssh omen`:

```bash
cd /home/fodurrr/dev/dotfiles
./install.sh --profile=omen
```

Do not select `developer` or `geekom-vpn` on this headless host.
Provider logins, SSH access, database roles and background services require separate setup.
T3 Code's server runtime is managed separately to match the GEEKOM client.

### Updating a checkout versus applying a profile

First check that the working tree is clean. Preserve local changes before switching branches.
For a checkout with `origin` configured:

```bash
cd /home/fodurrr/dev/dotfiles
git status --short --branch
git fetch origin
git switch main
git merge --ff-only origin/main
```

Stop if the checkout is dirty or the fast-forward fails. Do not reset local work.
Fetching code does not install packages or rerun host setup.
Existing Stow symlinks can reflect tracked configuration edits immediately.
Run the appropriate profile command separately when you want to apply package or installer changes.

Omen currently receives this personal repository through Git bundles from GEEKOM, without an `origin` remote.
Use the bundle workflow in [the agent guide](AGENTS.md) for that checkout.
Do not copy private SSH keys or access tokens between machines.

For repository changes, create a feature branch from current `main`.
Merge or push `main` only after explicit user approval.
Keep using the same checkout path because existing Stow links point into it.

**Profile installs are additive by default.** `--clean` removes managed apps outside the selected profile set.
Do not run `--clean` with only `geekom-vpn` on the GEEKOM desktop.

Temporary storage preparation is another explicit host operation, outside profile installation.
See [SSD-backed temporary storage](docs/linux-temp-storage.md) before running its root helper.

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
git clone git@github.com:fodurrr/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
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

### Create Profile

Create a new profile TOML interactively.

```bash
./install.sh --create-profile
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

Avoid static profile/app matrices in README. Use live data from `profiles/*.toml` and `apps.toml`.

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
yq -p toml -oy '.linux | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/hacker.toml
yq -p toml -oy '.macos | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/hacker.toml
```

### List app + type for a profile (example: `developer`)

```bash
for app in $(yq -p toml -oy '.macos | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/developer.toml); do
  printf "%s (%s)\n" "$app" "$(yq -p toml -oy ".apps.\"$app\".type" apps.toml)"
done
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
| `./install.sh --list-profiles` | Print profiles parsed from `profiles/*.toml` |
| `./install.sh --list-installed` | Print local install status for configured apps |
| `./install.sh --create-profile` | Create a profile TOML interactively |
| `mise install` | Update/install Mise tools from generated config |
| `bash scripts/curl-installs.sh` | Placeholder entrypoint (no active manual curl installers) |
| `source ~/.zshrc` | Reload shell after config/tool changes |

## Global AI Secrets

Store machine-local AI auth outside repositories:

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
zed ~/.config/secrets/ai.env
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
- `codex`, `grok`, `claude`, `opencode`, `gemini` CLIs: `mise` on macOS and Linux
- macOS Codex desktop app: Homebrew cask (`codex-app`)

```bash
# Codex ownership check: the first path must be the mise shim
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

- [`AGENTS.md`](AGENTS.md): Canonical agent guide; `CLAUDE.md` imports it
- [`docs/geekom-pia.md`](docs/geekom-pia.md): GEEKOM VPN and qBittorrent setup
- [`docs/linux-temp-storage.md`](docs/linux-temp-storage.md): Explicit temporary storage and swap preparation

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
