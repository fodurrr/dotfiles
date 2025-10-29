# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ IMPORTANT: Read DEV_PREFERENCES.md First

**Before proceeding with any task, you MUST read and follow the instructions in `DEV_PREFERENCES.md`.**

This file contains:
- Mandatory rules that must never be changed or ignored
- Peter's identity and communication preferences
- MCP server usage requirements (Tidwave for Elixir, Context7 for other libraries)
- Technical environment details
- Critical rules about commits and verification

The DEV_PREFERENCES.md file takes precedence over all other instructions in this file.

## Documentation and Information Retrieval

**IMPORTANT**: When answering questions about libraries, frameworks, tools, or packages:

1. **ALWAYS use the Context7 MCP server FIRST** to retrieve up-to-date documentation
2. Use `mcp__context7__resolve-library-id` to find the correct library identifier
3. Then use `mcp__context7__get-library-docs` with the resolved ID to fetch documentation
4. Only fall back to web search or built-in knowledge if Context7 doesn't have the library

Example workflow:
- User asks: "How do I use hooks in React?"
- First: Call `mcp__context7__resolve-library-id` with "react"
- Then: Call `mcp__context7__get-library-docs` with the resolved library ID and topic "hooks"
- Provide answer based on the fetched documentation

This ensures answers are based on current, accurate documentation rather than potentially outdated information.

## Repository Overview

This is a personal dotfiles repository for configuring a Linux development environment (WSL2/Ubuntu/Fedora). It uses GNU Stow for symlink management and Devbox (Nix-based) for development tool isolation.

## Key Architecture

### Configuration Management

- **GNU Stow**: All configs use Stow's directory structure. Running `stow .` from repo root creates symlinks from dotfiles to `$HOME`
- **Sync workflow**: `sync.sh` removes existing `.zshrc` and runs `stow .` to sync all dotfiles
- **Installation scripts**:
  - `install.sh` - Ubuntu/Debian setup
  - `install-fedora.sh` - Fedora setup (more idempotent with checks)

### Development Environment

**Devbox (Nix)**: Primary tool manager defined in `devbox.json`. Tools are only available inside `devbox shell`.

Current packages in devbox:
- `gum`, `stow`, `gh`, `jq`, `yq-go`, `hcloud`, `tealdeer`, `nodejs`, `pnpm`
- Elixir & Erlang via custom local flakes (see Nix Flakes section below)

**Shell**: Zsh with Zinit plugin manager, Starship prompt

### Important Directories

- `.config/nvim/` - LazyVim configuration (Neovim)
- `.config/fabric/` - Fabric AI tool configs (includes `.env` with API keys)
- `.config/starship.toml` - Starship prompt config
- `bin/` - Contains compiled Go binaries (`fabric`, `yt`)
- `tooling_docs/` - Documentation for advanced workflows
- `.devbox-flakes/` - Local Nix flakes referenced by `devbox.json` (likely in `~/.devbox-flakes/`)

## Common Commands

### Initial Setup

```bash
# Install all dependencies and tools
./install.sh              # Ubuntu/Debian
./install-fedora.sh       # Fedora

# Sync dotfiles to home directory
./sync.sh

# Reload shell configuration
source ~/.zshrc

# Enter devbox environment (must be in dotfiles dir)
devbox shell
```

### Daily Usage

```bash
# Enter devbox environment (provides gum, gh, stow, etc.)
devbox shell

# Update devbox packages
devbox update

# Git workflow (custom aliases in .zshrc)
gs          # git status
gcam "msg"  # git add -A && git commit -m
gp          # git push
lg          # lazygit

# File management (eza replaces ls)
ls          # eza --icons --git
la          # eza --long --all --header --icons --git
lt          # eza --icons --git --tree --level=2

# Editor
nvim        # Neovim with LazyVim config
```

## Advanced: Nix Flakes for Custom Packages

When you need packages not in Devbox's curated index (e.g., bleeding-edge versions):

1. Create local flake in `~/.devbox-flakes/<package-name>/flake.nix`
2. Reference it in `devbox.json` with absolute path:
   ```json
   "path:/home/username/.devbox-flakes/elixir#elixir": ""
   ```
3. See `tooling_docs/installing_unstable_nix_package.md` for detailed guide

Current example: Elixir 1.19.1 installed via local flake at `~/.devbox-flakes/elixir/`

## Shell Customization

### Key Zsh Features

- **Vi mode**: Enabled by default (`bindkey -v`)
- **History**: 10,000 entries, deduplication enabled
- **Plugins** (via Zinit):
  - `zsh-syntax-highlighting`
  - `zsh-autosuggestions`
  - `zsh-completions`
  - `fzf-tab`
  - `zsh-vi-mode`
  - OMZ plugins: git, sudo, docker, command-not-found

### Custom Functions

- `y()` - Yazi file manager wrapper that changes directory on exit
- `dev()`, `repros()`, `forks()` - Navigate to `~/dev/$1`, `~/r/$1`, `~/f/$1`
- `clone()` - `gh clone` and `cd` into the repo
- `pr ls` / `pr <num>` - List or checkout GitHub PRs
- `mkdirg()`, `cpg()`, `mvg()` - Make/copy/move and cd in one command

### Path Management

Custom functions `pathappend()` and `pathprepend()` ensure no duplicates when adding to `$PATH`.

Priority order:
1. Local user bins: `~/.local/bin`, `~/bin`, `~/.bin`
2. Devbox/Nix managed tools
3. Language-specific: `~/.cargo/bin`, pnpm global, mise
4. System paths

## Editor Configuration

**Neovim**: Uses LazyVim distribution (`.config/nvim/init.lua` is entry point)

LazyVim is an opinionated Neovim distribution with:
- Lazy.nvim plugin manager
- Pre-configured LSP, treesitter, telescope, etc.
- Configurations in `lua/` directory

## Fabric AI Tool

Fabric is installed as a Go binary in `bin/fabric`. Configuration lives in `.config/fabric/`:
- `.env` - API keys and settings
- `patterns/` - AI prompt patterns
- `custompatterns/` - User-defined patterns

Setup: `fabric --setup` (requires Go installation first via `go install github.com/danielmiessler/fabric@latest`)

## Git Configuration

Global settings applied by install scripts:
- Default branch: `main`
- User: Peter Fodor <fodurrr@gmail.com>

Custom aliases in `.zshrc` prefer short forms (`gs`, `gp`, `gcam`, etc.)

## Notes

- This is a **personal configuration** - install scripts contain specific user details
- **Devbox must be run from dotfiles directory** - `devbox.json` is location-dependent
- `.zshrc` sets custom timeouts for Claude Code: `BASH_DEFAULT_TIMEOUT_MS=600000`
- The repo contains a `pkg/` directory with Go module cache - this is likely unintentional and should potentially be added to `.gitignore`
