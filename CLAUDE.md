# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS (Apple Silicon) dotfiles repository using a **5-layer installation model**:

| Layer | Tool | Purpose | Config File |
|-------|------|---------|-------------|
| 1 | Homebrew | System tools + GUI apps | `Brewfile` |
| 2 | Stow | Config deployment (symlinks) | Each `*/` folder |
| 3 | Mise | Language runtimes + CLI tools | `mise/.config/mise/config.toml` |
| 4 | mas | Mac App Store (optional) | Manual or Brewfile |
| 5 | Curl scripts | Bleeding-edge AI coding tools | `scripts/curl-installs.sh` |

## Common Commands

```bash
# Full setup (runs all 5 layers)
./install.sh

# Strict cleanup mode (removes unlisted packages)
./install.sh --clean

# Update only AI coding tools (Layer 5)
bash scripts/curl-installs.sh

# Update only runtimes/CLI (Layer 3)
mise install

# Manually stow a single package (Layer 2)
cd ~/dotfiles && stow <package-name>

# Reload shell after zsh changes
source ~/.zshrc
```

## Architecture

### The 5-Layer Model

```
Layer 1: Homebrew   →  System infrastructure + GUI apps
       ↓
Layer 2: Stow       →  Deploy config files via symlinks
       ↓
Layer 3: Mise       →  Install runtimes + CLI tools (reads stowed config)
       ↓
Layer 4: mas        →  Mac App Store apps (optional)
       ↓
Layer 5: curl       →  AI coding tools (bleeding edge)
```

**Why this order?**
- Homebrew installs `mise`, `stow`, `sheldon` (needed for later layers)
- Stow deploys `~/.config/mise/config.toml` (needed by mise install)
- Mise reads the config to install tools
- Curl scripts run last (no dependencies)

### Directory Structure

```
~/dotfiles/
├── Brewfile                     # Layer 1: Homebrew packages
├── install.sh                   # Main orchestrator
├── scripts/
│   └── curl-installs.sh         # Layer 5: AI tool installers
├── git/                         # Stow package → ~/.gitconfig
├── zsh/                         # Stow package → ~/.zshrc
├── mise/                        # Stow package → ~/.config/mise/
├── sheldon/                     # Stow package → ~/.config/sheldon/
├── starship/                    # Stow package → ~/.config/starship.toml
├── ghostty/                     # Stow package → ~/.config/ghostty/
├── yazi/                        # Stow package → ~/.config/yazi/
├── README.md                    # User documentation
└── CLAUDE.md                    # This file
```

### The Enforcer Pattern

`install.sh` uses a `stow_enforce` function that:
1. Detects existing real files at target paths
2. Backs them up with `.bak` extension
3. Creates the symlink

This ensures the repo is always the source of truth without data loss.

## Adding New Tools

### Decision Flowchart

```
Is it a GUI app?
├─ Yes → App Store only? → Layer 4 (mas)
│                       → Layer 1 (cask in Brewfile)
└─ No (CLI)
     ├─ AI tool with curl installer? → Layer 5 (scripts/curl-installs.sh)
     ├─ Language runtime?            → Layer 3 (mise config)
     ├─ Mise can install it?         → Layer 3 (mise config)
     └─ Otherwise                    → Layer 1 (brew formula)
```

### Layer 1: Homebrew (GUI apps, system tools)

```ruby
# Add to Brewfile:
cask "new-gui-app"    # GUI application
brew "new-cli-tool"   # System CLI tool (if not in Mise)
```

Then run `./install.sh`

### Layer 3: Mise (runtimes, CLI tools)

```toml
# Add to mise/.config/mise/config.toml:
new-tool = "latest"   # or specific version like "1.2.3"
```

Then run `mise install`

### Layer 5: Curl scripts (AI coding tools)

```bash
# Add function to scripts/curl-installs.sh:
install_new_ai_tool() {
    log_info "Installing New AI Tool..."
    curl -fsSL https://example.com/install.sh | bash
}

# Add to main():
install_new_ai_tool
```

### New config to manage (Stow package)

```bash
mkdir -p ~/dotfiles/<tool>/.config/<tool>
mv ~/.config/<tool>/config ~/dotfiles/<tool>/.config/<tool>/
cd ~/dotfiles && stow <tool>
```

## Shell Initialization Order

`.zshrc` loads in this order:
1. PATH setup (Homebrew, local bin)
2. Mise activation (`mise activate zsh`)
3. Sheldon plugins (`sheldon source`)
4. Tool inits (starship, direnv, fzf)
5. Aliases

## AI Tools Reference

| Tool | Desktop App | CLI | Installation Layer |
|------|-------------|-----|-------------------|
| Claude | `cask "claude"` | `claude` | GUI: Layer 1, CLI: Layer 5 |
| ChatGPT | `cask "chatgpt"` | - | Layer 1 |
| Codex | `cask "codex"` | `codex` | GUI: Layer 1, CLI: Layer 3 |
| OpenCode | `cask "opencode-desktop"` | `opencode` | GUI: Layer 1, CLI: Layer 5 |
| Gemini | - | `gemini` | Layer 3 (no official desktop) |

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
