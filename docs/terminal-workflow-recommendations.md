# Terminal Workflow Recommendations

This document explains the 5-profile system, provides complete app matrices, and suggests terminal alternatives for GUI apps.

---

## Profile System Overview

The dotfiles support five profiles with different philosophies:

| Profile | Philosophy | Target User |
|---------|-----------|-------------|
| **minimal** | Bare essentials only | Fresh Mac, testing, minimal footprint |
| **standard** | Full GUI experience | Friends/family, casual users, new Mac owners |
| **developer** | GUI + dev tools | Developers who prefer VSCode/Zed |
| **hacker** | Terminal-centric workflow | Power users, keyboard-driven workflows |
| **server** | Headless/CLI only | Remote servers, SSH environments |

### Key Differences

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROFILE COMPARISON                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  minimal       standard          developer      hacker         server          │
│  ────────      ─────          ─────────      ──────         ──────          │
│  Ghostty       Ghostty        Ghostty        Ghostty        (none)          │
│                               + Warp         + Warp                         │
│                                              + tmux         + tmux          │
│                                                                              │
│  (none)        (none)         Zed            Zed            (none)          │
│                               + VSCode       + VSCode                       │
│                                              + Neovim       + Neovim        │
│                                                                              │
│  Firefox       Firefox        Firefox        Firefox        (none)          │
│  Chrome        + Chrome       + Chrome       + Chrome                       │
│                + Edge         + Edge         + Edge                         │
│                                                                              │
│  (none)        Claude         Claude         Claude         (none)          │
│                ChatGPT        ChatGPT        ChatGPT                        │
│                               Codex          Codex                          │
│                               OpenCode       OpenCode                       │
│                                              + CLI tools                    │
│                                                                              │
│  (none)        (none)         (none)         Aerospace      (none)          │
│                                                                              │
│  Finder        Finder         Finder         yazi           yazi            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Complete App Matrix

### GUI Applications (Homebrew Casks)

| App | minimal | standard | developer | hacker | server | Notes |
|-----|:-------:|:-----:|:---------:|:------:|:------:|-------|
| **Terminals** |||||||
| Ghostty | ✓ | ✓ | ✓ | ✓ | | GPU-accelerated terminal |
| Warp | | | ✓ | ✓ | | AI-powered terminal |
| **Editors** |||||||
| Zed | | | ✓ | ✓ | | Fast, modern editor |
| VSCode | | | ✓ | ✓ | | Extension ecosystem |
| Antigravity | | | ✓ | ✓ | | Note-taking |
| **Browsers** |||||||
| Firefox | ✓ | ✓ | ✓ | ✓ | | Privacy-focused |
| Chrome | ✓ | ✓ | ✓ | ✓ | | DevTools, compatibility |
| Edge | | ✓ | ✓ | ✓ | | PDF, Microsoft integration |
| **AI Desktop Apps** |||||||
| Claude Desktop | | ✓ | ✓ | ✓ | | GUI chat interface |
| ChatGPT Desktop | | ✓ | ✓ | ✓ | | GUI chat interface |
| Codex Desktop | | | ✓ | ✓ | | AI coding GUI |
| OpenCode Desktop | | | ✓ | ✓ | | AI coding GUI |
| **Productivity** |||||||
| Raycast | ✓ | ✓ | ✓ | ✓ | | Launcher, extensions |
| Obsidian | | ✓ | ✓ | ✓ | | Notes, knowledge base |
| Bitwarden | ✓ | ✓ | ✓ | ✓ | | Password manager |
| Aqua Voice | | | ✓ | ✓ | | Real-time voice dictation |
| **Media** |||||||
| Spotify | | ✓ | ✓ | ✓ | | Music streaming |
| VLC | | ✓ | ✓ | ✓ | | Media player |
| Discord | | ✓ | ✓ | ✓ | | Communication |
| **Virtualization** |||||||
| OrbStack | | | ✓ | ✓ | | Docker/Linux VMs |
| UTM | | | ✓ | ✓ | | macOS/Windows VMs |
| **Display** |||||||
| BetterDisplay | | ✓ | ✓ | ✓ | | DDC control, virtual monitors |
| **Window Management** |||||||
| Aerospace | | | | ✓ | | i3-like tiling WM |
| **Fonts** |||||||
| JetBrains Mono NF | ✓ | ✓ | ✓ | ✓ | ✓ | Nerd Font icons |

### CLI Tools (Mise)

| Tool | minimal | standard | developer | hacker | server | Notes |
|------|:-------:|:-----:|:---------:|:------:|:------:|-------|
| **Core CLI** |||||||
| starship | ✓ | ✓ | ✓ | ✓ | ✓ | Cross-shell prompt |
| eza | ✓ | ✓ | ✓ | ✓ | ✓ | Modern ls |
| bat | ✓ | ✓ | ✓ | ✓ | ✓ | cat with syntax highlighting |
| fzf | ✓ | ✓ | ✓ | ✓ | ✓ | Fuzzy finder |
| **Developer CLI** |||||||
| ripgrep | | | ✓ | ✓ | ✓ | Fast grep |
| jq | | | ✓ | ✓ | ✓ | JSON processor |
| yq | | | ✓ | ✓ | ✓ | YAML processor |
| gh | | | ✓ | ✓ | ✓ | GitHub CLI |
| direnv | | | ✓ | ✓ | | Directory environments |
| **Hacker/Server Extras** |||||||
| tmux | | | | ✓ | ✓ | Terminal multiplexer |
| neovim | | | | ✓ | ✓ | Modal editor |
| yazi | | | | ✓ | ✓ | Terminal file manager |
| btop | | | | ✓ | ✓ | System monitor |
| ncdu | | | | ✓ | ✓ | Disk usage analyzer |
| lazygit | | | | ✓ | ✓ | TUI for git |

### AI CLI Tools (Hacker Profile Only)

| Tool | minimal | standard | developer | hacker | server | Notes |
|------|:-------:|:-----:|:---------:|:------:|:------:|-------|
| claude-cli | | | | ✓ | | Claude Code CLI |
| codex-cli | | | | ✓ | | OpenAI Codex CLI |
| opencode-cli | | | | ✓ | | OpenCode CLI |
| gemini-cli | | | | ✓ | | Google Gemini CLI |

### Runtimes (Mise)

| Runtime | minimal | standard | developer | hacker | server | Version |
|---------|:-------:|:-----:|:---------:|:------:|:------:|---------|
| Node.js | | | ✓ | ✓ | | lts |
| Python | | | ✓ | ✓ | | 3.14 |
| Rust | | | ✓ | ✓ | | stable |
| Bun | | | ✓ | ✓ | | 1.3 |
| pnpm | | | ✓ | ✓ | | 10.28 |
| Erlang | | | ✓ | ✓ | | 28.3 |
| Elixir | | | ✓ | ✓ | | 1.19.5-otp-28 |

### Stow Packages (Configs)

| Package | minimal | standard | developer | hacker | server | Target Path |
|---------|:-------:|:-----:|:---------:|:------:|:------:|-------------|
| git | ✓ | ✓ | ✓ | ✓ | ✓ | ~/.gitconfig |
| zsh | ✓ | ✓ | ✓ | ✓ | ✓ | ~/.zshrc |
| sheldon | ✓ | ✓ | ✓ | ✓ | ✓ | ~/.config/sheldon/ |
| starship | ✓ | ✓ | ✓ | ✓ | ✓ | ~/.config/starship.toml |
| mise | ✓ | ✓ | ✓ | ✓ | ✓ | ~/.config/mise/ |
| ghostty | ✓ | ✓ | ✓ | ✓ | | ~/.config/ghostty/ |
| zed | | | ✓ | ✓ | | ~/.config/zed/ |
| aerospace | | | | ✓ | | ~/.config/aerospace/ |
| tmux | | | | ✓ | ✓ | ~/.config/tmux/ |
| nvim | | | | ✓ | ✓ | ~/.config/nvim/ |
| yazi | | | | ✓ | ✓ | ~/.config/yazi/ |

---

## Terminal Alternatives for GUI Apps

The **hacker** profile replaces several GUI apps with terminal equivalents:

### Clipboard Manager
**GUI:** Paste (Setapp)
**Terminal:** tmux buffers + pbcopy

```bash
# In tmux copy mode (Ctrl+a + [)
v          # Start selection (vi-mode)
y          # Copy to system clipboard (pbcopy)
Ctrl+a + b # List all buffers (clipboard history)
```

### System Monitor
**GUI:** iStat Menus, Activity Monitor
**Terminal:** btop

```bash
btop       # Interactive system monitor
           # CPU, memory, disk, network, processes
           # Vim-like keybindings
```

### Disk Usage
**GUI:** CleanMyMac, DaisyDisk
**Terminal:** ncdu

```bash
ncdu /     # Scan from root
ncdu ~     # Scan home directory
           # Navigate with arrow keys
           # Press 'd' to delete
```

### File Manager
**GUI:** Finder
**Terminal:** yazi

```bash
yazi       # or just 'y' with shell wrapper
           # Image previews, vim keybindings
           # Bulk rename, copy/move operations
```

### Git GUI
**GUI:** GitHub Desktop, Tower
**Terminal:** lazygit

```bash
lazygit    # Full TUI for git
           # Stage hunks, interactive rebase
           # Cherry-pick, stash management
```

### Window Management
**GUI:** Magnet, Rectangle, BetterTouchTool
**Terminal-adjacent:** Aerospace

```toml
# ~/.config/aerospace/aerospace.toml
# i3-like tiling with vim keybindings
alt-h = "focus left"
alt-j = "focus down"
alt-k = "focus up"
alt-l = "focus right"

alt-shift-h = "move left"
alt-shift-j = "move down"
alt-shift-k = "move up"
alt-shift-l = "move right"
```

---

## Adding New Apps to Profiles

### Step 1: Determine the app type

| Type | When to Use | Example |
|------|-------------|---------|
| `cask` | GUI app installed via Homebrew | Spotify, VSCode |
| `brew` | CLI tool (rare, prefer mise) | btop, ncdu |
| `mise` | CLI tool or runtime | starship, node, python |
| `stow` | Config files to symlink | zsh, tmux configs |
| `curl` | AI tools with curl installers | claude-cli |

### Step 2: Add to apps.toml

```toml
# Example: Add a new GUI app
[apps.figma]
type = "cask"
category = "design"
profiles = ["developer", "hacker"]
description = "Design tool"

# Example: Add a new CLI tool
[apps.htop]
type = "mise"
category = "cli"
profiles = ["hacker", "server"]
description = "Process viewer"

# Example: Add a new config
[apps.alacritty-config]
type = "stow"
package = "alacritty"
category = "config"
profiles = ["hacker"]
description = "Alacritty terminal config"
```

### Step 3: Install

```bash
./install.sh --profile=hacker
```

---

## Creating Custom Profiles

### Example: DevOps Profile

Add your profile name to relevant apps in `apps.toml`:

```toml
# Add to existing apps
[apps.orbstack]
profiles = ["developer", "hacker", "devops"]  # Add devops

# Add new apps specific to devops
[apps.k9s]
type = "mise"
category = "cli"
profiles = ["devops"]
description = "Kubernetes TUI"

[apps.terraform]
type = "mise"
category = "cli"
profiles = ["devops"]
description = "Infrastructure as code"
```

Then install:
```bash
./install.sh --profile=devops
```

---

## tmux Clipboard Quick Reference

```bash
# Enter copy mode
Ctrl+a + [

# In copy mode (vi-mode)
v          # Start selection
V          # Line selection
y          # Copy to system clipboard
q          # Exit copy mode

# Buffer management
Ctrl+a + b # List all buffers
Ctrl+a + p # Paste most recent buffer
Ctrl+a + = # Choose buffer to paste

# From command line
echo "text" | pbcopy    # Copy to clipboard
pbpaste                 # Paste from clipboard
```

---

## Verification Checklist

After switching profiles, verify:

1. **Shell works:**
   ```bash
   source ~/.zshrc
   starship --version  # Prompt should load
   ```

2. **Core CLI tools:**
   ```bash
   eza --version
   bat --version
   fzf --version
   ```

3. **Developer tools (developer/hacker profiles):**
   ```bash
   rg --version
   jq --version
   gh --version
   ```

4. **Hacker tools (hacker profile):**
   ```bash
   tmux -V
   nvim --version
   yazi --version
   btop --version
   lazygit --version
   ```

5. **Window management (hacker profile):**
   ```bash
   aerospace --version
   # Verify keybindings: alt+h/j/k/l for focus
   ```

6. **AI CLI (hacker profile):**
   ```bash
   claude --version
   opencode --version
   ```
