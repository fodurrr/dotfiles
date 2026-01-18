# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS (Apple Silicon) dotfiles repository using a declarative, reproducible setup with:
- **Homebrew** for system packages (`Brewfile`)
- **Mise** for dev tool version management (`mise/.config/mise/config.toml`)
- **GNU Stow** for modular config symlinks
- **Sheldon** for zsh plugin management

## Common Commands

```bash
# Full setup/sync (install apps, stow configs, install runtimes)
./install.sh

# Strict cleanup mode (removes Homebrew apps not in Brewfile)
./install.sh --clean

# Manually stow a single package
cd ~/dotfiles && stow <package-name>

# Install runtimes after editing mise config
mise install

# Reload shell after zsh changes
source ~/.zshrc
```

## Architecture

### Stow Packages
Each top-level folder is a stow package that symlinks to `$HOME`:
- `git/` → `.gitconfig`, `.gitignore_global`
- `mise/` → `.config/mise/config.toml`
- `sheldon/` → `.config/sheldon/plugins.toml`
- `starship/` → `.config/starship.toml`
- `zsh/` → `.zshrc`

### The Enforcer Pattern
`install.sh` uses a `stow_enforce` function that:
1. Detects existing real files at target paths
2. Backs them up with `.bak` extension
3. Creates the symlink

This ensures the repo is always the source of truth without data loss.

### Adding New Tools

**System apps (Homebrew):** Add to `Brewfile`, run `./install.sh`

**Language runtimes (Mise):** Add to `mise/.config/mise/config.toml`, run `./install.sh`

**New config to manage:**
1. `mkdir -p ~/dotfiles/<tool>/.config/<tool>`
2. Move config: `mv ~/.config/<tool>/config ~/dotfiles/<tool>/.config/<tool>/`
3. Stow: `cd ~/dotfiles && stow <tool>`

### Shell Initialization Order
`.zshrc` loads in this order:
1. PATH setup (Homebrew, local bin)
2. Mise activation (`mise activate zsh`)
3. Sheldon plugins (`sheldon source`)
4. Tool inits (starship, direnv, fzf)
5. Aliases
