# Terminal Workflow Recommendations

This document explains the profile system, provides complete app matrices, and suggests terminal alternatives for GUI apps.

---

## Profile System Overview

The dotfiles support three profiles with different philosophies:

| Profile | Philosophy | Target User |
|---------|-----------|-------------|
| **minimal** | Bare essentials only | Fresh Mac, testing, minimal footprint |
| **standard** | Full GUI experience | Friends/family, casual users, new Mac owners |
| **developer** | Terminal-centric workflow | Power users, keyboard-driven workflows |

### Key Differences

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROFILE COMPARISON                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  minimal          standard          developer                    │
│  ────────         ────────          ─────────                    │
│  Ghostty          Ghostty           Ghostty                      │
│                   + Warp            + tmux                       │
│                                                                  │
│  Zed              Zed               Zed                          │
│                   + VSCode          + VSCode                     │
│                   + Antigravity     + Neovim                     │
│                                                                  │
│  Firefox          Firefox           Firefox                      │
│                   + Chrome                                       │
│                   + Edge                                         │
│                                                                  │
│  (none)           Claude Desktop    claude-cli                   │
│                   ChatGPT Desktop   opencode-cli                 │
│                   Codex Desktop     codex-cli                    │
│                   OpenCode Desktop  gemini-cli                   │
│                                                                  │
│  (none)           (macOS native)    Aerospace                    │
│                                                                  │
│  Finder           Finder            yazi                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Complete App Matrix

### GUI Applications (Homebrew Casks)

| App | Minimal | Standard | Developer | Notes |
|-----|:-------:|:--------:|:---------:|-------|
| **Terminals** |||||
| Ghostty | ✓ | ✓ | ✓ | Primary terminal |
| Warp | | ✓ | | AI-powered terminal |
| **Editors** |||||
| Zed | ✓ | ✓ | ✓ | Fast, modern editor |
| VSCode | | ✓ | ✓ | Extension ecosystem |
| Antigravity | | ✓ | | Markdown/writing |
| **Browsers** |||||
| Firefox | ✓ | ✓ | ✓ | Privacy-focused |
| Chrome | | ✓ | | DevTools, compatibility |
| Edge | | ✓ | | PDF, Microsoft integration |
| **AI Desktop Apps** |||||
| Claude Desktop | | ✓ | | GUI chat interface |
| ChatGPT Desktop | | ✓ | | GUI chat interface |
| Codex Desktop | | ✓ | | AI coding GUI |
| OpenCode Desktop | | ✓ | | AI coding GUI |
| **Productivity** |||||
| Raycast | ✓ | ✓ | ✓ | Launcher, extensions |
| Obsidian | | ✓ | ✓ | Notes, knowledge base |
| Bitwarden | ✓ | ✓ | ✓ | Password manager |
| Wispr Flow | | ✓ | | Voice dictation |
| **Media** |||||
| Spotify | | ✓ | ✓ | Music streaming |
| VLC | | ✓ | ✓ | Media player |
| Discord | | ✓ | ✓ | Communication |
| **Virtualization** |||||
| OrbStack | | ✓ | ✓ | Docker/Linux VMs |
| UTM | | ✓ | ✓ | macOS/Windows VMs |
| **Display** |||||
| MonitorControl | | ✓ | ✓ | DDC brightness/volume |
| **Window Management** |||||
| Aerospace | | | ✓ | i3-like tiling WM |
| **Fonts** |||||
| JetBrains Mono NF | ✓ | ✓ | ✓ | Nerd Font icons |

### CLI Tools (Mise)

| Tool | Minimal | Standard | Developer | Notes |
|------|:-------:|:--------:|:---------:|-------|
| **Core CLI** |||||
| starship | ✓ | ✓ | ✓ | Cross-shell prompt |
| eza | ✓ | ✓ | ✓ | Modern ls |
| bat | ✓ | ✓ | ✓ | cat with syntax highlighting |
| ripgrep | ✓ | ✓ | ✓ | Fast grep |
| fzf | ✓ | ✓ | ✓ | Fuzzy finder |
| jq | ✓ | ✓ | ✓ | JSON processor |
| yq | ✓ | ✓ | ✓ | YAML processor |
| gh | ✓ | ✓ | ✓ | GitHub CLI |
| direnv | ✓ | ✓ | ✓ | Directory environments |
| **Developer Extras** |||||
| tmux | | | ✓ | Terminal multiplexer |
| neovim | | | ✓ | Modal editor |
| yazi | | | ✓ | Terminal file manager |
| btop | | | ✓ | System monitor |
| ncdu | | | ✓ | Disk usage analyzer |
| lazygit | | | ✓ | TUI for git |
| **AI CLI** |||||
| codex-cli | | | ✓ | OpenAI Codex |
| gemini-cli | | | ✓ | Google Gemini |

### Runtimes (Mise)

| Runtime | Minimal | Standard | Developer | Version |
|---------|:-------:|:--------:|:---------:|---------|
| Node.js | ✓ | ✓ | ✓ | lts |
| Python | ✓ | ✓ | ✓ | 3.14 |
| Rust | | ✓ | ✓ | stable |
| Bun | | ✓ | ✓ | 1.3 |
| pnpm | | ✓ | ✓ | 10.28 |
| Erlang | | | ✓ | 28.3 |
| Elixir | | | ✓ | 1.19.5-otp-28 |

### AI Tools via Curl (Layer 5)

| Tool | Minimal | Standard | Developer | Notes |
|------|:-------:|:--------:|:---------:|-------|
| claude-cli | | | ✓ | Claude Code CLI |
| opencode-cli | | | ✓ | OpenCode CLI |

### Stow Packages (Configs)

| Package | Minimal | Standard | Developer | Target Path |
|---------|:-------:|:--------:|:---------:|-------------|
| git | ✓ | ✓ | ✓ | ~/.gitconfig |
| zsh | ✓ | ✓ | ✓ | ~/.zshrc |
| sheldon | ✓ | ✓ | ✓ | ~/.config/sheldon/ |
| starship | ✓ | ✓ | ✓ | ~/.config/starship.toml |
| ghostty | ✓ | ✓ | ✓ | ~/.config/ghostty/ |
| mise | ✓ | ✓ | ✓ | ~/.config/mise/ |
| aerospace | | | ✓ | ~/.config/aerospace/ |
| tmux | | | ✓ | ~/.config/tmux/ |
| nvim | | | ✓ | ~/.config/nvim/ |
| yazi | | | ✓ | ~/.config/yazi/ |

---

## Terminal Alternatives for GUI Apps

The developer profile replaces several GUI apps with terminal equivalents:

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

## Creating Custom Profiles

### Example: DevOps Profile

Add your profile name to relevant apps in `apps.toml`:

```toml
# Add to existing apps
[apps.orbstack]
profiles = ["standard", "developer", "devops"]  # Add devops

# Add new apps specific to devops
[apps.k9s]
type = "mise"
category = "cli"
profiles = ["devops"]

[apps.terraform]
type = "mise"
category = "cli"
profiles = ["devops"]

[apps.awscli]
type = "mise"
category = "cli"
profiles = ["devops"]
```

Then install:
```bash
./install.sh --profile=devops
```

### Example: Writing Profile

```toml
[apps.ia-writer]
type = "cask"
category = "writing"
profiles = ["writing"]

[apps.marked-2]
type = "cask"
category = "writing"
profiles = ["writing"]

[apps.vale]
type = "mise"
category = "writing"
profiles = ["writing"]
```

---

## Setapp Analysis (For Power Users)

If you're migrating from Setapp, here's how apps map to this setup:

| Setapp App | Verdict | Replacement |
|------------|---------|-------------|
| CleanShot X | **KEEP** | No terminal replacement for annotations, OCR |
| TablePlus | **KEEP** | Complex DB queries need GUI |
| iStat Menus | **KEEP** | Passive menu bar monitoring |
| Paste | REPLACE | tmux buffers + pbcopy |
| CleanMyMac | REPLACE | ncdu + brew cleanup |
| BetterTouchTool | REPLACE | Aerospace config |
| Yoink | REPLACE | yazi file manager |
| Supercharge | REPLACE | Aerospace keybindings |

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
   rg --version
   fzf --version
   ```

3. **Developer tools (developer profile):**
   ```bash
   tmux -V
   nvim --version
   yazi --version
   btop --version
   lazygit --version
   ```

4. **Window management (developer profile):**
   ```bash
   aerospace --version
   # Verify keybindings: alt+h/j/k/l for focus
   ```

5. **AI CLI (developer profile):**
   ```bash
   claude --version
   opencode --version
   ```
