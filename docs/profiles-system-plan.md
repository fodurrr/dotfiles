# Plan: Centralized Config + Multi-Profile System

## Summary

Create a **centralized app registry** (`apps.toml`) that defines ALL applications with profile tags. This enables:
1. **Unlimited profiles** - minimal, standard, developer, or any custom profile
2. **Single source of truth** - one file to manage all apps
3. **Easy maintenance** - add/remove apps from profiles by editing arrays

Initial profiles:
- **Minimal**: Bare essentials - core tools only
- **Standard** (default): GUI-focused for regular Mac users
- **Developer**: Terminal-centric power-user setup with Aerospace

---

## Architecture

### Two-Phase Installation

```
┌─────────────────────────────────────────────────────────────────┐
│                      BOOTSTRAP PHASE                             │
│            (Hardcoded, runs for ALL profiles)                    │
├─────────────────────────────────────────────────────────────────┤
│  1. Install Homebrew (if missing)                                │
│  2. Install INFRASTRUCTURE packages:                             │
│     brew "mise"      # Version manager                          │
│     brew "stow"      # Symlink manager                          │
│     brew "sheldon"   # Zsh plugin manager                       │
│     brew "dasel"     # TOML/YAML/JSON parser ← KEY              │
│     brew "gum"       # Interactive CLI menus                    │
│     brew "mas"       # Mac App Store CLI                        │
│     brew "sevenzip"  # Archive tool                             │
│                                                                  │
│  NOTE: NO user apps here - only tools needed by install.sh      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                       PROFILE PHASE                              │
│           (Reads apps.toml, installs for --profile)              │
├─────────────────────────────────────────────────────────────────┤
│  3. Interactive profile selection (using gum)                    │
│  4. Parse apps.toml using dasel                                  │
│  5. Install Homebrew casks/brews where profile matches           │
│  6. Stow packages where profile matches                          │
│  7. Run mise install for tools where profile matches             │
│  8. Run curl installers where profile matches                    │
└─────────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
~/dotfiles/
├── apps.toml                    # CENTRALIZED APP REGISTRY ← NEW
├── Brewfile.bootstrap           # Infrastructure only (hardcoded)
├── install.sh                   # Two-phase installer with interactive menu
├── scripts/
│   └── curl-installs.sh         # AI CLI installers
├── git/                         # Stow packages...
├── zsh/
├── ghostty/
├── aerospace/
├── tmux/
├── nvim/
├── yazi/
└── docs/
    └── terminal-workflow-recommendations.md
```

---

## The Centralized Config: apps.toml

### Format

```toml
# =============================================================================
# apps.toml - Centralized App Registry
# =============================================================================
# Every app, tool, and config is defined here with profile assignments.
#
# Fields:
#   type     = "cask" | "brew" | "mise" | "curl" | "stow"
#   name     = package name (optional, defaults to section name)
#   tap      = homebrew tap (optional, for casks from taps)
#   category = grouping for documentation
#   profiles = ["minimal", "standard", "developer", ...]
#
# To add an app to a profile: add the profile name to the profiles array
# To create a new profile: just use a new name in any profiles array
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# TERMINALS
# ─────────────────────────────────────────────────────────────────────────────
[apps.ghostty]
type = "cask"
category = "terminals"
profiles = ["minimal", "standard", "developer"]

[apps.warp]
type = "cask"
category = "terminals"
profiles = ["standard"]

# ─────────────────────────────────────────────────────────────────────────────
# EDITORS
# ─────────────────────────────────────────────────────────────────────────────
[apps.zed]
type = "cask"
category = "editors"
profiles = ["minimal", "standard", "developer"]

[apps.visual-studio-code]
type = "cask"
category = "editors"
profiles = ["standard", "developer"]

[apps.antigravity]
type = "cask"
category = "editors"
profiles = ["standard"]

[apps.neovim]
type = "mise"
category = "editors"
profiles = ["developer"]

# ─────────────────────────────────────────────────────────────────────────────
# BROWSERS
# ─────────────────────────────────────────────────────────────────────────────
[apps.firefox]
type = "cask"
category = "browsers"
profiles = ["minimal", "standard", "developer"]

[apps.google-chrome]
type = "cask"
category = "browsers"
profiles = ["standard"]

[apps.microsoft-edge]
type = "cask"
category = "browsers"
profiles = ["standard"]

# ─────────────────────────────────────────────────────────────────────────────
# AI TOOLS
# ─────────────────────────────────────────────────────────────────────────────
# Standard users: Desktop GUI apps
[apps.claude-desktop]
type = "cask"
name = "claude"
category = "ai"
profiles = ["standard"]

[apps.chatgpt-desktop]
type = "cask"
name = "chatgpt"
category = "ai"
profiles = ["standard"]

[apps.codex-desktop]
type = "cask"
name = "codex"
category = "ai"
profiles = ["standard"]

[apps.opencode-desktop]
type = "cask"
category = "ai"
profiles = ["standard"]

# Developer users: CLI tools only
[apps.claude-cli]
type = "curl"
category = "ai"
profiles = ["developer"]

[apps.opencode-cli]
type = "curl"
category = "ai"
profiles = ["developer"]

[apps.codex-cli]
type = "mise"
name = "codex"
category = "ai"
profiles = ["developer"]

[apps.gemini-cli]
type = "mise"
category = "ai"
profiles = ["developer"]

# ─────────────────────────────────────────────────────────────────────────────
# WINDOW MANAGEMENT
# ─────────────────────────────────────────────────────────────────────────────
[apps.aerospace]
type = "cask"
tap = "nikitabobko/tap"
name = "nikitabobko/tap/aerospace"
category = "window-management"
profiles = ["developer"]

# ─────────────────────────────────────────────────────────────────────────────
# PRODUCTIVITY
# ─────────────────────────────────────────────────────────────────────────────
[apps.raycast]
type = "cask"
category = "productivity"
profiles = ["minimal", "standard", "developer"]

[apps.obsidian]
type = "cask"
category = "productivity"
profiles = ["standard", "developer"]

[apps.bitwarden]
type = "cask"
category = "productivity"
profiles = ["minimal", "standard", "developer"]

[apps.wispr-flow]
type = "cask"
category = "productivity"
profiles = ["standard"]

# ─────────────────────────────────────────────────────────────────────────────
# MEDIA & COMMUNICATION
# ─────────────────────────────────────────────────────────────────────────────
[apps.discord]
type = "cask"
category = "media"
profiles = ["standard", "developer"]

[apps.spotify]
type = "cask"
category = "media"
profiles = ["standard", "developer"]

[apps.vlc]
type = "cask"
category = "media"
profiles = ["standard", "developer"]

# ─────────────────────────────────────────────────────────────────────────────
# VIRTUALIZATION
# ─────────────────────────────────────────────────────────────────────────────
[apps.orbstack]
type = "cask"
category = "virtualization"
profiles = ["standard", "developer"]

[apps.utm]
type = "cask"
category = "virtualization"
profiles = ["standard", "developer"]

# ─────────────────────────────────────────────────────────────────────────────
# DISPLAY
# ─────────────────────────────────────────────────────────────────────────────
[apps.monitorcontrol]
type = "cask"
category = "display"
profiles = ["standard", "developer"]

# ─────────────────────────────────────────────────────────────────────────────
# FONTS
# ─────────────────────────────────────────────────────────────────────────────
[apps.font-jetbrains-mono-nerd-font]
type = "cask"
category = "fonts"
profiles = ["minimal", "standard", "developer"]

# ─────────────────────────────────────────────────────────────────────────────
# CLI TOOLS (mise)
# ─────────────────────────────────────────────────────────────────────────────
[apps.starship]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.eza]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.bat]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.ripgrep]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.fzf]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.jq]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.yq]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.gh]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

[apps.direnv]
type = "mise"
category = "cli"
profiles = ["minimal", "standard", "developer"]

# Developer extras
[apps.tmux]
type = "mise"
category = "cli"
profiles = ["developer"]

[apps.yazi]
type = "mise"
category = "cli"
profiles = ["developer"]

[apps.btop]
type = "mise"
category = "cli"
profiles = ["developer"]

[apps.ncdu]
type = "mise"
category = "cli"
profiles = ["developer"]

[apps.lazygit]
type = "mise"
category = "cli"
profiles = ["developer"]

# ─────────────────────────────────────────────────────────────────────────────
# RUNTIMES (mise)
# ─────────────────────────────────────────────────────────────────────────────
[apps.node]
type = "mise"
version = "lts"
category = "runtimes"
profiles = ["minimal", "standard", "developer"]

[apps.python]
type = "mise"
version = "3.14"
category = "runtimes"
profiles = ["minimal", "standard", "developer"]

[apps.rust]
type = "mise"
version = "stable"
category = "runtimes"
profiles = ["standard", "developer"]

[apps.bun]
type = "mise"
version = "1.3"
category = "runtimes"
profiles = ["standard", "developer"]

[apps.pnpm]
type = "mise"
version = "10.28"
category = "runtimes"
profiles = ["standard", "developer"]

[apps.erlang]
type = "mise"
version = "28.3"
category = "runtimes"
profiles = ["developer"]

[apps.elixir]
type = "mise"
version = "1.19.5-otp-28"
category = "runtimes"
profiles = ["developer"]

# ─────────────────────────────────────────────────────────────────────────────
# STOW PACKAGES (configs)
# ─────────────────────────────────────────────────────────────────────────────
[apps.git-config]
type = "stow"
package = "git"
category = "config"
profiles = ["minimal", "standard", "developer"]

[apps.zsh-config]
type = "stow"
package = "zsh"
category = "config"
profiles = ["minimal", "standard", "developer"]

[apps.sheldon-config]
type = "stow"
package = "sheldon"
category = "config"
profiles = ["minimal", "standard", "developer"]

[apps.starship-config]
type = "stow"
package = "starship"
category = "config"
profiles = ["minimal", "standard", "developer"]

[apps.ghostty-config]
type = "stow"
package = "ghostty"
category = "config"
profiles = ["minimal", "standard", "developer"]

[apps.mise-config]
type = "stow"
package = "mise"
category = "config"
profiles = ["minimal", "standard", "developer"]

[apps.aerospace-config]
type = "stow"
package = "aerospace"
category = "config"
profiles = ["developer"]

[apps.tmux-config]
type = "stow"
package = "tmux"
category = "config"
profiles = ["developer"]

[apps.nvim-config]
type = "stow"
package = "nvim"
category = "config"
profiles = ["developer"]

[apps.yazi-config]
type = "stow"
package = "yazi"
category = "config"
profiles = ["developer"]
```

---

## Profile Comparison Matrix

| Category | Minimal | Standard | Developer |
|----------|---------|----------|-----------|
| **Target User** | Fresh Mac, testing | Friends/family | Power users, you |
| **Window Management** | macOS native | macOS native | Aerospace |
| **Terminals** | Ghostty | Ghostty + Warp | Ghostty + tmux |
| **Editors** | Zed | Zed, VSCode, Antigravity | Zed, VSCode, Neovim |
| **AI Tools** | None | GUI (Claude, ChatGPT, etc.) | CLI only |
| **File Management** | Finder | Finder | yazi |
| **Browsers** | Firefox | Firefox, Chrome, Edge | Firefox |
| **Media** | None | Spotify, VLC, Discord | Spotify, VLC, Discord |

### Detailed App Distribution

#### GUI Applications (Homebrew Casks)

| App | Minimal | Standard | Developer |
|-----|:-------:|:--------:|:---------:|
| **Terminals** | | | |
| Ghostty | ✓ | ✓ | ✓ |
| Warp | | ✓ | |
| **Editors** | | | |
| Zed | ✓ | ✓ | ✓ |
| VSCode | | ✓ | ✓ |
| Antigravity | | ✓ | |
| **Browsers** | | | |
| Firefox | ✓ | ✓ | ✓ |
| Chrome | | ✓ | |
| Edge | | ✓ | |
| **AI Desktop Apps** | | | |
| Claude Desktop | | ✓ | |
| ChatGPT Desktop | | ✓ | |
| Codex Desktop | | ✓ | |
| OpenCode Desktop | | ✓ | |
| **Productivity** | | | |
| Raycast | ✓ | ✓ | ✓ |
| Obsidian | | ✓ | ✓ |
| Bitwarden | ✓ | ✓ | ✓ |
| Wispr Flow | | ✓ | |
| **Media** | | | |
| Spotify | | ✓ | ✓ |
| VLC | | ✓ | ✓ |
| Discord | | ✓ | ✓ |
| **Virtualization** | | | |
| OrbStack | | ✓ | ✓ |
| UTM | | ✓ | ✓ |
| **Display** | | | |
| MonitorControl | | ✓ | ✓ |
| **Window Management** | | | |
| Aerospace | | | ✓ |

#### CLI Tools (Mise)

| Tool | Minimal | Standard | Developer |
|------|:-------:|:--------:|:---------:|
| starship | ✓ | ✓ | ✓ |
| eza, bat, ripgrep, fzf | ✓ | ✓ | ✓ |
| jq, yq | ✓ | ✓ | ✓ |
| gh (GitHub CLI) | ✓ | ✓ | ✓ |
| direnv | ✓ | ✓ | ✓ |
| node, python | ✓ | ✓ | ✓ |
| rust, bun, pnpm | | ✓ | ✓ |
| erlang, elixir | | | ✓ |
| tmux, neovim, yazi | | | ✓ |
| btop, ncdu, lazygit | | | ✓ |
| codex, gemini-cli | | | ✓ |

#### AI Tools via Curl (Layer 5)

| Tool | Minimal | Standard | Developer |
|------|:-------:|:--------:|:---------:|
| claude (Claude Code CLI) | | | ✓ |
| opencode (OpenCode CLI) | | | ✓ |

#### Stow Packages (Configs)

| Package | Minimal | Standard | Developer |
|---------|:-------:|:--------:|:---------:|
| git | ✓ | ✓ | ✓ |
| zsh | ✓ | ✓ | ✓ |
| sheldon | ✓ | ✓ | ✓ |
| starship | ✓ | ✓ | ✓ |
| ghostty | ✓ | ✓ | ✓ |
| mise | ✓ | ✓ | ✓ |
| aerospace | | | ✓ |
| tmux | | | ✓ |
| nvim | | | ✓ |
| yazi | | | ✓ |

---

## Setapp Analysis (Your Personal Setup)

| App | Verdict | Reason |
|-----|---------|--------|
| CleanShot X | **KEEP** | Uses annotations, scrolling capture, OCR |
| TablePlus | **KEEP** | Frequent complex database queries |
| iStat Menus | **KEEP** | Passive menu bar monitoring |
| Paste | REPLACE | tmux buffers + pbcopy |
| CleanMyMac | REPLACE | ncdu + brew cleanup |
| LookAway | EVALUATE | Personal preference |
| Supercharge | REPLACE | Aerospace keybindings |
| BetterTouchTool | REPLACE | Aerospace config |
| Yoink | REPLACE | yazi file manager |
| Luminar Neo | EVALUATE | Keep only if actively used |

---

## Implementation Steps

### Step 1: Create Feature Branch
```bash
git checkout -b feature/profiles-system
```

### Step 2: Create apps.toml
Create `/Users/fodurrr/dotfiles/apps.toml` with the full centralized config shown above.

### Step 3: Create Bootstrap Brewfile
Create `/Users/fodurrr/dotfiles/Brewfile.bootstrap`:
```ruby
# =============================================================================
# Brewfile.bootstrap - Infrastructure Only
# =============================================================================
# These packages are required for install.sh to work.
# Installed BEFORE reading apps.toml (bootstrap phase).
# =============================================================================

brew "mise"      # Version manager (needed for Layer 3)
brew "stow"      # Symlink manager (needed for Layer 2)
brew "sheldon"   # Zsh plugin manager (needed for shell)
brew "dasel"     # TOML parser (needed to read apps.toml)
brew "gum"       # Interactive CLI menus (for profile selection)
brew "mas"       # Mac App Store CLI (Layer 4)
brew "sevenzip"  # Archive tool
```

### Step 4: Rewrite install.sh
Implement two-phase architecture with:
- Bootstrap phase (hardcoded infrastructure)
- Interactive profile selection using gum
- Multi-profile merging support
- Command-line flags for non-interactive use

Key features:
- `./install.sh` - Interactive menu
- `./install.sh --profile=X` - Non-interactive
- `./install.sh --profile=X --profile=Y` - Merge profiles
- `./install.sh --list-profiles` - Show available profiles

### Step 5: Remove Old Brewfile
The old `Brewfile` is replaced by:
- `Brewfile.bootstrap` - infrastructure only
- `apps.toml` - all apps with profile tags

### Step 6: Enhance tmux Config (vi-mode clipboard)
Add to `tmux/.config/tmux/tmux.conf`:
```bash
# Vi-mode for copy with system clipboard
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"

# Quick buffer list (clipboard history replaces Paste app)
bind b choose-buffer
```

### Step 7: Create Recommendations Document
Create `/Users/fodurrr/dotfiles/docs/terminal-workflow-recommendations.md`

### Step 8: Update Documentation
- `CLAUDE.md`: Document centralized config and profile system
- `README.md`: Update usage instructions

---

## Usage After Implementation

### Interactive Mode (Default)
```bash
./install.sh
```

Shows an interactive menu with profile selection using gum.

### Command-Line Mode
```bash
# Single profile (non-interactive)
./install.sh --profile=developer

# Multiple profiles merged together
./install.sh --profile=developer --profile=devops

# List available profiles with app counts
./install.sh --list-profiles

# With cleanup
./install.sh --profile=developer --clean

# Skip interactive menu (for CI/automation)
./install.sh --yes --profile=standard
```

### Profile Merging
When you select multiple profiles, they merge - all apps from ANY selected profile are installed.

### Creating a New Profile
1. Add the profile name to relevant apps in `apps.toml`
2. The menu automatically detects it
3. Run `./install.sh` and select it

No new files needed!

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `apps.toml` | CREATE - Centralized app registry |
| `Brewfile.bootstrap` | CREATE - Infrastructure + gum for interactive menu |
| `install.sh` | REWRITE - Two-phase + interactive menu + multi-profile |
| `Brewfile` | DELETE - Replaced by apps.toml |
| `tmux/.config/tmux/tmux.conf` | EDIT - Add vi-mode copy |
| `docs/terminal-workflow-recommendations.md` | CREATE |
| `CLAUDE.md` | EDIT - Document new system |
| `README.md` | EDIT - Update usage |

## Key Dependencies

| Tool | Purpose | Installed In |
|------|---------|--------------|
| `dasel` | Parse TOML config | Brewfile.bootstrap |
| `gum` | Interactive menus, confirmations | Brewfile.bootstrap |
| `mise` | Runtime/CLI tool management | Brewfile.bootstrap |
| `stow` | Symlink management | Brewfile.bootstrap |
