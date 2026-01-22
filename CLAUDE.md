# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS (Apple Silicon) dotfiles repository using a **profile-based installation system** with a **two-phase architecture**.

### Two-Phase Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 1: BOOTSTRAP                          │
│                (Always runs, installs infrastructure)            │
├─────────────────────────────────────────────────────────────────┤
│  Source: Brewfile.bootstrap                                      │
│  Installs: mise, stow, sheldon, dasel, gum, mas, sevenzip       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 2: PROFILE                            │
│              (Installs apps based on selected profiles)          │
├─────────────────────────────────────────────────────────────────┤
│  Source: apps.toml (centralized app registry)                    │
│                                                                  │
│  Layer 1: Homebrew - Casks and brews                            │
│  Layer 2: Stow     - Config symlinks                            │
│  Layer 3: Mise     - CLI tools and runtimes                     │
│  Layer 5: Curl     - AI CLI installers                          │
└─────────────────────────────────────────────────────────────────┘
```

### Profiles

| Profile | Target User | Key Features |
|---------|-------------|--------------|
| **minimal** | Fresh Mac, testing | Core essentials only |
| **standard** | Friends/family | Full GUI experience + AI Desktop apps |
| **developer** | Power users | Terminal-centric + AI CLI tools + Aerospace |

## Common Commands

```bash
# Interactive installation (profile selection menu)
./install.sh

# Install specific profile(s)
./install.sh --profile=developer
./install.sh -p minimal -p standard

# Clean mode (removes apps not in selected profiles)
./install.sh --profile=developer --clean

# List available profiles
./install.sh --list-profiles

# Update AI tools only (Layer 5)
bash scripts/curl-installs.sh

# Update mise tools only (Layer 3)
mise install

# Stow a single package (Layer 2)
cd ~/dotfiles && stow <package>

# Reload shell
source ~/.zshrc
```

## Key Files

| File | Purpose |
|------|---------|
| `apps.toml` | **Centralized app registry** - All apps with profile assignments |
| `Brewfile.bootstrap` | Infrastructure packages only (runs before apps.toml can be read) |
| `install.sh` | Two-phase installer with profile support and clean mode |
| `scripts/curl-installs.sh` | Layer 5: AI CLI installers |

## The Centralized Config: apps.toml

All apps are defined in `apps.toml` with profile assignments:

```toml
[apps.ghostty]
type = "cask"
category = "terminals"
profiles = ["minimal", "standard", "developer"]

[apps.warp]
type = "cask"
category = "terminals"
profiles = ["standard"]  # Only in standard profile

[apps.tmux]
type = "mise"
category = "cli"
profiles = ["developer"]  # Only in developer profile

[apps.tmux-config]
type = "stow"
package = "tmux"
category = "config"
profiles = ["developer"]
```

### App Types

| Type | Description | Example |
|------|-------------|---------|
| `cask` | Homebrew cask (GUI app) | Ghostty, VSCode, Spotify |
| `brew` | Homebrew formula (CLI) | Used rarely, most CLIs via mise |
| `mise` | Mise-managed tool/runtime | starship, eza, node, python |
| `stow` | Config symlinks | git, zsh, ghostty configs |
| `curl` | Curl installer script | claude-cli, opencode-cli |

## Adding New Tools

### Decision Flowchart

```
Is it a GUI app?
├─ Yes → Add to apps.toml with type = "cask"
└─ No (CLI)
     ├─ AI tool with curl installer? → type = "curl" + update scripts/curl-installs.sh
     ├─ Language runtime/CLI tool?   → type = "mise"
     └─ Otherwise                    → type = "brew"
```

### To apps.toml

```toml
# Add a GUI app
[apps.figma]
type = "cask"
category = "design"
profiles = ["standard", "developer"]

# Add a CLI tool
[apps.lazydocker]
type = "mise"
category = "cli"
profiles = ["developer"]

# Add a new config to manage
[apps.newtool-config]
type = "stow"
package = "newtool"
category = "config"
profiles = ["developer"]
```

### Creating a Stow Package

```bash
mkdir -p ~/dotfiles/newtool/.config/newtool
mv ~/.config/newtool/config ~/dotfiles/newtool/.config/newtool/
cd ~/dotfiles && stow newtool
```

## Directory Structure

```
~/dotfiles/
├── apps.toml                    # Centralized app registry
├── Brewfile.bootstrap           # Infrastructure packages only
├── install.sh                   # Two-phase installer
├── scripts/
│   └── curl-installs.sh         # Layer 5: AI tool installers
├── git/                         # Stow package → ~/.gitconfig
├── zsh/                         # Stow package → ~/.zshrc
├── mise/                        # Stow package → ~/.config/mise/
├── sheldon/                     # Stow package → ~/.config/sheldon/
├── starship/                    # Stow package → ~/.config/starship.toml
├── ghostty/                     # Stow package → ~/.config/ghostty/
├── aerospace/                   # Stow package → ~/.config/aerospace/
├── tmux/                        # Stow package → ~/.config/tmux/
├── nvim/                        # Stow package → ~/.config/nvim/
├── yazi/                        # Stow package → ~/.config/yazi/
├── docs/                        # Documentation
├── README.md                    # User documentation
└── CLAUDE.md                    # This file
```

## The Enforcer Pattern

`install.sh` uses a `stow_enforce` function that:
1. Detects existing real files at target paths
2. Backs them up with `.bak` extension
3. Creates the symlink

This ensures the repo is always the source of truth without data loss.

## Profile Switching Modes

### Merge Mode (Default)
```bash
./install.sh --profile=developer
```
- **ADDS** apps from the new profile
- **KEEPS** all existing apps

### Clean Mode (Strict)
```bash
./install.sh --profile=developer --clean
```
- **ADDS** apps from the selected profile(s)
- **REMOVES** managed apps NOT in the selected profile(s)
- Affects: Homebrew packages, Stow configs, Mise tools

## Shell Initialization Order

`.zshrc` loads in this order:
1. PATH setup (Homebrew, local bin)
2. Mise activation (`mise activate zsh`)
3. Sheldon plugins (`sheldon source`)
4. Tool inits (starship, direnv, fzf)
5. Aliases

## AI Tools Reference

| Tool | Standard Profile | Developer Profile |
|------|-----------------|-------------------|
| Claude | Desktop app (cask) | CLI only (curl) |
| ChatGPT | Desktop app (cask) | - |
| Codex | Desktop app (cask) | CLI only (mise) |
| OpenCode | Desktop app (cask) | CLI only (curl) |
| Gemini | - | CLI only (mise) |

## Conductor Workspace Workflow

When working in a Conductor workspace (separate git worktree), changes are isolated from the main dotfiles directory.

**IMPORTANT: After every commit and push, always remind the user:**

> To get this into your main environment, in your main dotfiles repo run:
> ```bash
> git fetch origin
> git merge origin/<branch-name>
> source ~/.zshrc  # if zsh changes were made
> ```
> Or create a PR at: `https://github.com/fodurrr/dotfiles/pull/new/<branch-name>`
