# Profile System Architecture

This document describes the centralized app registry and 5-profile system used in these dotfiles.

---

## Overview

The dotfiles use a **centralized app registry** (`apps.toml`) that defines ALL applications with profile assignments. This enables:

1. **5 profiles** - minimal, standard, developer, hacker, server
2. **Single source of truth** - one file to manage all apps
3. **Easy maintenance** - add/remove apps from profiles by editing arrays
4. **Custom profiles** - create new profiles by adding names to arrays

---

## The 5 Profiles

| Profile | Target User | Description |
|---------|-------------|-------------|
| **minimal** | Fresh Mac, testing | Bare essentials on top of macOS |
| **standard** | Regular users (spouse/family) | Browsing, media, basic productivity |
| **developer** | GUI-centric developers | VSCode, Zed, Warp, mouse-driven workflow |
| **hacker** | Terminal-centric power users | Helix, tmux, Aerospace, keyboard-driven |
| **server** | SSH/remote admin | Terminal-only tools for headless servers |

### Profile Progression

```
minimal → standard → developer → hacker
                           ↘
                             server (branched for headless)
```

Each profile builds on the previous, with **server** being a specialized branch for headless environments.

---

## Two-Phase Installation Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 1: BOOTSTRAP                          │
│                (Always runs, installs infrastructure)            │
├─────────────────────────────────────────────────────────────────┤
│  Source: Brewfile.bootstrap                                      │
│  Installs: mise, stow, sheldon, yq, gum, mas                    │
│  Also: TPM (Tmux Plugin Manager) via git clone                  │
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
│  Layer 5: Curl     - Optional vendor CLI installers (fallback)                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Centralized Config: apps.toml

All apps are defined in `apps.toml` with profile assignments:

```toml
[apps.ghostty]
type = "cask"
category = "terminals"
profiles = ["minimal", "standard", "developer", "hacker"]
description = "GPU-accelerated terminal emulator"

[apps.warp]
type = "cask"
category = "terminals"
profiles = ["developer", "hacker"]
description = "AI-powered modern terminal"

[apps.tmux]
type = "mise"
category = "cli"
profiles = ["hacker", "server"]
description = "Terminal multiplexer"

[apps.tmux-config]
type = "stow"
package = "tmux"
category = "config"
profiles = ["hacker", "server"]
description = "Tmux multiplexer config"
```

### App Types

| Type | Description | Example |
|------|-------------|---------|
| `cask` | Homebrew cask (GUI app) | Ghostty, VSCode, Spotify |
| `brew` | Homebrew formula (CLI) | btop, ncdu |
| `mise` | Mise-managed tool/runtime | starship, eza, node, python |
| `stow` | Config symlinks | git, zsh, ghostty configs |
| `curl` | Vendor installer fallback (optional) | Reserved for exceptional cases |

---

## Profile Comparison Matrix

| Category | minimal | standard | developer | hacker | server |
|----------|:-------:|:-----:|:---------:|:------:|:------:|
| **Target User** | Fresh Mac | Friends/family | Developers | Power users | Remote/SSH |
| **Window Mgmt** | macOS | macOS | macOS | Aerospace | N/A |
| **Terminals** | Ghostty | Ghostty | Ghostty+Warp | Ghostty+Warp+tmux | tmux |
| **Editors** | - | - | Zed+VSCode+Helix | Zed+VSCode+Helix | Helix |
| **AI Tools** | - | Desktop | Desktop | Desktop+CLI | - |
| **File Manager** | Finder | Finder | Finder | yazi | yazi |
| **Browsers** | Firefox+Chrome | All | All | All | - |

---

## Usage

### Interactive Mode (Default)
```bash
./install.sh
```

Shows an interactive menu with profile selection using gum.

### Command-Line Mode
```bash
# Single profile
./install.sh --profile=hacker

# Multiple profiles merged
./install.sh --profile=developer --profile=hacker

# List available profiles
./install.sh --list-profiles

# Clean mode (removes apps not in profile)
./install.sh --profile=hacker --clean
```

### Profile Switching Modes

**Merge Mode (Default)**
```bash
./install.sh --profile=hacker
```
- ADDS apps from the new profile
- KEEPS all existing apps

**Clean Mode (Strict)**
```bash
./install.sh --profile=hacker --clean
```
- ADDS apps from the selected profile(s)
- REMOVES managed apps NOT in the selected profile(s)

---

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

### Example: Adding a GUI App

```toml
[apps.figma]
type = "cask"
category = "design"
profiles = ["developer", "hacker"]
description = "Design tool"
```

### Example: Adding a CLI Tool

```toml
[apps.lazydocker]
type = "mise"
category = "cli"
profiles = ["hacker", "server"]
description = "Docker TUI"
```

### Example: Adding a Config

```toml
[apps.newtool-config]
type = "stow"
package = "newtool"
category = "config"
profiles = ["hacker", "server"]
description = "Newtool configuration"
```

---

## Creating a Stow Package

```bash
# Create the directory structure
mkdir -p ~/dotfiles/newtool/.config/newtool

# Move existing config
mv ~/.config/newtool/config ~/dotfiles/newtool/.config/newtool/

# Stow it
cd ~/dotfiles && stow newtool
```

---

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
├── zed/                         # Stow package → ~/.config/zed/
├── aerospace/                   # Stow package → ~/.config/aerospace/
├── tmux/                        # Stow package → ~/.config/tmux/
├── helix/                       # Stow package → ~/.config/helix/
├── yazi/                        # Stow package → ~/.config/yazi/
├── docs/                        # Documentation
├── README.md                    # User documentation
├── AGENTS.md                    # AI assistant guidance (mirrors CLAUDE.md)
└── CLAUDE.md                    # AI assistant guidance (source of truth)
```

---

## The Enforcer Pattern

`install.sh` uses a `stow_enforce` function that:
1. Detects existing real files at target paths
2. Backs them up with `.bak` extension
3. Creates the symlink

This ensures the repo is always the source of truth without data loss.

---

## Shell Initialization Order

`.zshrc` loads in this order:
1. PATH setup (Homebrew, local bin)
2. Mise activation (`mise activate zsh`)
3. Sheldon plugins (`sheldon source`)
4. Tool inits (starship, direnv, fzf)
5. Aliases

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `apps.toml` | Centralized app registry with profile assignments |
| `Brewfile.bootstrap` | Infrastructure packages (runs before apps.toml) |
| `install.sh` | Two-phase installer with profile support |
| `scripts/curl-installs.sh` | Layer 5: Optional vendor CLI installer fallback |
| `AGENTS.md` | AI assistant guidance (mirrors CLAUDE.md) |
| `CLAUDE.md` | AI assistant guidance and constraints |
| `README.md` | User documentation |
