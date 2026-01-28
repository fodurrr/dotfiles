# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚨 Git Workflow Rules (MANDATORY)

1. **NEVER commit, merge, or push to `main` branch** - Always work in a feature branch
2. **After completing work**, commit AND push to GitHub so the user can test in their VM
3. **Provide VM testing commands** after every push, using the **actual repo path** from your working directory:

```bash
# Example format (replace <repo-path> with actual path like ~/dev/dotfiles):
cd <repo-path>
git pull
./install.sh --profile=<profile>
```

**IMPORTANT:** Always use the actual repo path from your current working directory, not a hardcoded path.

## Documentation Searches

When searching for tool/app documentation online:
- **ALWAYS Search for "latest" or "current"** documentation, not dated versions
- **NEVER include year constraints** (like "2025" or "2026") - docs change rapidly
- **Prefer official sites** using `site:` operator (e.g., `site:ghostty.org`)

## Asking Questions & Making Recommendations

When presenting options to the user:
- **Always include a recommendation** with "(Recommended)" suffix
- Explain WHY it's recommended in the description
- Put the recommended option FIRST in the list
- Don't just present options neutrally - take a stance based on best practices
---

## Overview

This is a macOS (Apple Silicon) dotfiles repository using a **profile-based installation system** with a **two-phase architecture**.

## ⚠️ Critical Development Constraints

### Bash 3.2 Compatibility (MANDATORY)

**macOS ships with bash 3.2** (due to GPL v3 licensing of bash 4+). All shell scripts MUST work with bash 3.2.

| ❌ Bash 4+ (DO NOT USE) | ✅ Bash 3.2 Alternative |
|-------------------------|-------------------------|
| `declare -A arr` (associative arrays) | Use delimited strings: `VAR="\|key1\|\|key2\|"` and `[[ "$VAR" == *"\|key\|"* ]]` |
| `readarray` / `mapfile` | Use `while read` loops |
| `${var,,}` (lowercase) | Use `tr '[:upper:]' '[:lower:]'` or `awk '{print tolower($0)}'` |
| `${var^^}` (uppercase) | Use `tr '[:lower:]' '[:upper:]'` |
| `${var:offset:length}` negative offset | Calculate positive offset first |
| `&>` for redirect | Use `>file 2>&1` |
| `\|&` for pipe stderr | Use `2>&1 \|` |
| `coproc` | Not available - redesign |
| `[[ $var =~ regex ]]` capture groups | Use `grep -oE` or `sed` instead |

**Before committing any shell script changes, verify syntax:**
```bash
bash -n install.sh  # Syntax check (uses system bash 3.2)
```

### TOML Parsing

Use **yq** (installed in bootstrap) with `-p toml` flag:

```bash
# Get a property
yq -p toml -oy '.apps.ghostty.type' apps.toml

# Get array values
yq -p toml -oy '.apps.ghostty.profiles' apps.toml
```

### Target Environment

Scripts must work on **any macOS system** - from fresh installs to fully configured machines:
- Fresh install: Only system tools available, no Homebrew yet
- Existing system: User adds an app to `apps.toml` and re-runs `install.sh`
- Scripts must be **idempotent** (safe to run multiple times)

**Testing:** Use a fresh macOS VM for clean-slate testing.

### Two-Phase Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 1: BOOTSTRAP                          │
│                (Always runs, installs infrastructure)            │
├─────────────────────────────────────────────────────────────────┤
│  Source: Brewfile.bootstrap                                      │
│  Installs: mise, stow, sheldon, dasel, gum, mas, sevenzip       │
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
│  Layer 5: Curl     - AI CLI installers                          │
└─────────────────────────────────────────────────────────────────┘
```

### Profiles

| Profile | Target User | Description |
|---------|-------------|-------------|
| **minimal** | Fresh Mac, testing | Bare essentials on top of macOS |
| **standard** | Regular users (spouse/family) | Browsing, media, basic productivity |
| **developer** | GUI-centric developers | VSCode, Warp, mouse-driven workflow |
| **hacker** | Terminal-centric power users | Helix, tmux, Aerospace, keyboard-driven |
| **server** | SSH/remote admin | Terminal-only tools for headless servers |

### App Distribution Matrix

| App | minimal | standard | developer | hacker | server |
|-----|:-------:|:--------:|:---------:|:------:|:------:|
| **ESSENTIALS** |
| Raycast | ✓ | ✓ | ✓ | ✓ | |
| Bitwarden | ✓ | ✓ | ✓ | ✓ | |
| Firefox | ✓ | ✓ | ✓ | ✓ | |
| Ghostty | ✓ | ✓ | ✓ | ✓ | |
| JetBrains Mono Nerd | ✓ | ✓ | ✓ | ✓ | ✓ |
| **BROWSERS** |
| Chrome | ✓ | ✓ | ✓ | ✓ | |
| Edge | | ✓ | ✓ | ✓ | |
| **EDITORS** |
| Zed | | | ✓ | ✓ | |
| VSCode | | | ✓ | ✓ | |
| Helix | | | ✓ | ✓ | ✓ |
| Antigravity | | | ✓ | ✓ | |
| **TERMINALS** |
| Warp | | | ✓ | ✓ | |
| tmux | | | | ✓ | ✓ |
| **DICTATION** |
| Aqua Voice | | | ✓ | ✓ | |
| **AI DESKTOP** |
| Claude Desktop | | ✓ | ✓ | ✓ | |
| ChatGPT Desktop | | ✓ | ✓ | ✓ | |
| Codex Desktop | | | ✓ | ✓ | |
| OpenCode Desktop | | | ✓ | ✓ | |
| **AI CLI** |
| claude-cli | | | | ✓ | |
| codex-cli | | | | ✓ | |
| opencode-cli | | | | ✓ | |
| gemini-cli | | | | ✓ | |
| **PRODUCTIVITY** |
| Obsidian | | ✓ | ✓ | ✓ | |
| KeyCastr | | | ✓ | ✓ | |
| **CLOUD STORAGE** |
| OneDrive | | ✓ | ✓ | ✓ | |
| Google Drive | | ✓ | ✓ | ✓ | |
| **OFFICE** |
| Microsoft Office | | ✓ | | | |
| Microsoft Teams | | ✓ | | | |
| **COMMUNICATION** |
| WhatsApp | | ✓ | ✓ | ✓ | |
| **MEDIA** |
| Spotify | | ✓ | ✓ | ✓ | |
| VLC | | ✓ | ✓ | ✓ | |
| Discord | | ✓ | ✓ | ✓ | |
| **WINDOW MGMT** |
| Aerospace | | | | ✓ | |
| **VIRTUALIZATION** |
| OrbStack | | | ✓ | ✓ | |
| UTM | | | ✓ | ✓ | |
| **DATABASE** |
| Beekeeper Studio | | | ✓ | ✓ | |
| pgAdmin4 | | | ✓ | ✓ | |
| **DISPLAY** (choose one) |
| BetterDisplay | | ✓ | ✓ | ✓ | |
| ~~MonitorControl~~ | | ✓ | ✓ | ✓ | |
| **UTILITIES** |
| Setapp | | ✓ | ✓ | ✓ | |
| Keymapp | | | | ✓ | |
| **SECURITY** |
| SandVault | | | ✓ | ✓ | |
| **CLI TOOLS** |
| starship | ✓ | ✓ | ✓ | ✓ | ✓ |
| eza | ✓ | ✓ | ✓ | ✓ | ✓ |
| bat | ✓ | ✓ | ✓ | ✓ | ✓ |
| fzf | ✓ | ✓ | ✓ | ✓ | ✓ |
| ripgrep | | | ✓ | ✓ | ✓ |
| jq | | | ✓ | ✓ | ✓ |
| yq | | | ✓ | ✓ | ✓ |
| gh | | | ✓ | ✓ | ✓ |
| direnv | | | ✓ | ✓ | |
| yazi | | | | ✓ | ✓ |
| lazygit | | | | ✓ | ✓ |
| btop | | | | ✓ | ✓ |
| ncdu | | | | ✓ | ✓ |
| chafa | | | ✓ | ✓ | |
| **RUNTIMES** |
| Node | | | ✓ | ✓ | |
| Python | | | ✓ | ✓ | |
| Rust | | | ✓ | ✓ | |
| Bun | | | ✓ | ✓ | |
| pnpm | | | ✓ | ✓ | |
| Erlang | | | ✓ | ✓ | |
| Elixir | | | ✓ | ✓ | |
| **STOW CONFIGS** |
| git-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| zsh-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| sheldon-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| starship-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| ghostty-config | ✓ | ✓ | ✓ | ✓ | |
| terminal-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| mise-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| zed-config | | | ✓ | ✓ | |
| aerospace-config | | | | ✓ | |
| sketchybar-config | | | | ✓ | |
| tmux-config | | | | ✓ | ✓ |
| helix-config | | | ✓ | ✓ | ✓ |
| yazi-config | | | | ✓ | ✓ |
| cheatsheet-config | | | ✓ | ✓ | |
| keyboard-layout-config | | | ✓ | ✓ | |

## Common Commands

```bash
# Interactive installation (profile selection menu)
./install.sh

# Install specific profile(s)
./install.sh --profile=hacker
./install.sh -p minimal -p standard

# Install individual apps (extras mode)
# Select "➕ Install individual apps" from the menu, or:
./install.sh --extras

# Clean mode (removes apps not in selected profiles)
./install.sh --profile=hacker --clean

# List available profiles
./install.sh --list-profiles

# Update AI tools only (Layer 5)
bash scripts/curl-installs.sh

# Update mise tools only (Layer 3)
mise install

# Stow a single package (Layer 2) - run from repo root
stow <package>

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
profiles = ["minimal", "standard", "developer", "hacker"]

[apps.warp]
type = "cask"
category = "terminals"
profiles = ["developer", "hacker"]  # Developer profiles only

[apps.tmux]
type = "mise"
category = "cli"
profiles = ["hacker", "server"]  # Terminal-centric profiles

[apps.tmux-config]
type = "stow"
package = "tmux"
category = "config"
profiles = ["hacker", "server"]
```

### App Types

| Type | Description | Example |
|------|-------------|---------|
| `cask` | Homebrew cask (GUI app) | Ghostty, VSCode, Spotify |
| `brew` | Homebrew formula (CLI) | Used rarely, most CLIs via mise |
| `mise` | Mise-managed tool/runtime | starship, eza, node, python |
| `stow` | Config symlinks | git, zsh, ghostty configs |
| `curl` | Curl installer script | claude-cli, opencode-cli |
| `defaults` | macOS defaults write settings | Terminal.app, Raycast settings |

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
profiles = ["developer", "hacker"]

# Add a CLI tool
[apps.lazydocker]
type = "mise"
category = "cli"
profiles = ["hacker", "server"]

# Add a new config to manage
[apps.newtool-config]
type = "stow"
package = "newtool"
category = "config"
profiles = ["hacker", "server"]
```

### Creating a Stow Package

```bash
# From the repo root (e.g., ~/dev/dotfiles):
mkdir -p newtool/.config/newtool
mv ~/.config/newtool/config newtool/.config/newtool/
stow newtool
```

## Directory Structure

```
dotfiles/                        # Repo root (location varies, check working directory)
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
├── terminal/                    # Terminal.app profile (imported via defaults)
├── zed/                         # Stow package → ~/.config/zed/
├── aerospace/                   # Stow package → ~/.config/aerospace/
├── tmux/                        # Stow package → ~/.config/tmux/
├── helix/                       # Stow package → ~/.config/helix/
├── yazi/                        # Stow package → ~/.config/yazi/
├── cheatsheet/                  # Stow package → ~/.config/cheatsheet/
├── keyboard-layout/             # Stow package → ~/.config/keyboard-layout/
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
./install.sh --profile=hacker
```
- **ADDS** apps from the new profile
- **KEEPS** all existing apps

### Clean Mode (Strict)
```bash
./install.sh --profile=hacker --clean
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

| Tool | standard | developer | hacker |
|------|-------|-----------|--------|
| Claude | Desktop (cask) | Desktop (cask) | Desktop + CLI |
| ChatGPT | Desktop (cask) | Desktop (cask) | Desktop (cask) |
| Codex | - | Desktop (cask) | Desktop + CLI |
| OpenCode | - | Desktop (cask) | Desktop + CLI |
| Gemini | - | - | CLI only (mise) |

## Conductor Workspace Workflow

When working in a Conductor workspace (separate git worktree), changes are isolated from the main dotfiles directory.

**IMPORTANT: After every commit, push to GitHub and provide testing commands** (see Git Workflow Rules at top of this file).

When providing commands, always use the **actual repo path** from your current working directory. Example:
```
Changes merged to main! To apply:
cd /Users/fodurrr/dev/dotfiles   # Use actual path from working directory
git pull
./install.sh --profile=hacker
brew services restart sketchybar  # If sketchybar changes
```

For shell changes: `source ~/.zshrc`
