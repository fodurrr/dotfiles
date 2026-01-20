# Dotfiles

A modern, declarative, and reproducible development environment for macOS (Apple Silicon).

## Quick Start

```bash
# Clone and install
git clone https://github.com/fodurrr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

That's it. The script handles everything.

---

## The 5-Layer Model

This setup uses a layered approach to balance **stability**, **portability**, and **freshness**:

```
Layer 0: Manual Bootstrap (one-time)
       ↓
Layer 1: Homebrew ─────── System tools + GUI apps
       ↓
Layer 2: Stow ─────────── Config deployment (symlinks)
       ↓
Layer 3: Mise ─────────── Language runtimes + CLI tools
       ↓
Layer 4: Mac App Store ── Optional (Xcode, etc.)
       ↓
Layer 5: Curl Scripts ─── Bleeding-edge AI coding tools
       ↓
Shell Reload
```

### Why This Architecture?

| Layer | Purpose | Updates | Best For |
|-------|---------|---------|----------|
| Homebrew | System integration | Weekly | GUI apps, system tools |
| Mise | Version management | On-demand | Runtimes, CLI tools |
| Curl | Bleeding edge | Auto-update | AI tools (Claude, OpenCode) |

---

## What Gets Installed

### Layer 1: Homebrew (`Brewfile`)

**System Tools:**
- `mise` - Version manager for everything else
- `stow` - Symlink manager
- `sheldon` - Zsh plugin manager
- `mas` - Mac App Store CLI

**GUI Applications:**
- Terminals: Ghostty, Warp
- Editors: Zed, VS Code
- Browsers: Firefox, Chrome, Edge
- AI Desktop: Claude, ChatGPT, Codex, OpenCode
- Utils: Raycast, Obsidian, Discord, Spotify

### Layer 3: Mise (`mise/.config/mise/config.toml`)

**Languages:**
- Node.js (LTS)
- Python 3.14
- Rust (stable)
- Erlang/Elixir

**Package Managers:**
- Bun, pnpm

**CLI Tools:**
- `eza` - Modern `ls` with icons
- `bat` - `cat` with syntax highlighting
- `ripgrep` - Fast grep
- `fzf` - Fuzzy finder
- `jq`, `yq` - JSON/YAML processors
- `gh` - GitHub CLI
- `starship` - Shell prompt
- `direnv` - Directory environments
- `yazi` - File manager

**AI CLIs (no curl installer):**
- `codex` - OpenAI Codex CLI
- `gemini-cli` - Google Gemini CLI

### Layer 5: Curl Scripts (`scripts/curl-installs.sh`)

**AI CLIs (auto-updating):**
- `claude` - Claude Code CLI (Anthropic)
- `opencode` - OpenCode CLI (Anomaly)

---

## Directory Structure

```
~/dotfiles/
├── Brewfile                     # Layer 1: Homebrew packages
├── install.sh                   # Main installation script
├── scripts/
│   └── curl-installs.sh         # Layer 5: AI tool installers
├── git/                         # → ~/.gitconfig, ~/.gitignore_global
├── zsh/                         # → ~/.zshrc
├── mise/                        # → ~/.config/mise/config.toml
├── sheldon/                     # → ~/.config/sheldon/plugins.toml
├── starship/                    # → ~/.config/starship.toml
├── ghostty/                     # → ~/.config/ghostty/config
├── yazi/                        # → ~/.config/yazi/
├── README.md
└── CLAUDE.md                    # AI assistant instructions
```

---

## Common Commands

```bash
# Full installation (all layers)
./install.sh

# Strict mode (removes unlisted packages)
./install.sh --clean

# Update AI tools only (Layer 5)
bash scripts/curl-installs.sh

# Update runtimes only (Layer 3)
mise install

# Stow a single package (Layer 2)
cd ~/dotfiles && stow <package>

# Reload shell
source ~/.zshrc
```

---

## Adding New Tools

### Decision Flowchart

```
Is it a GUI app?
├─ Yes → App Store exclusive? → mas (Layer 4)
│                            → Brewfile cask (Layer 1)
└─ No (CLI)
     ├─ AI tool with curl installer? → scripts/curl-installs.sh (Layer 5)
     ├─ Language runtime? → mise config (Layer 3)
     ├─ Mise can install it? → mise config (Layer 3)
     └─ Otherwise → Brewfile brew (Layer 1)
```

### Examples

**Add a GUI app:**
```ruby
# Brewfile
cask "figma"
```

**Add a CLI tool:**
```toml
# mise/.config/mise/config.toml
lazygit = "latest"
```

**Add an AI tool with curl installer:**
```bash
# scripts/curl-installs.sh
install_new_ai_tool() {
    curl -fsSL https://example.com/install.sh | bash
}
```

**Add a new config to manage:**
```bash
mkdir -p ~/dotfiles/newtool/.config/newtool
mv ~/.config/newtool/config ~/dotfiles/newtool/.config/newtool/
cd ~/dotfiles && stow newtool
```

---

## The Enforcer Pattern

The installer automatically handles conflicts:

| Scenario | Action | Result |
|----------|--------|--------|
| Target empty | Create symlink | Tool uses repo config |
| Target is symlink | Skip | Already managed |
| Target is real file | Backup to `.bak`, then symlink | Repo wins, data preserved |

This ensures the repository is always the source of truth without data loss.

---

## Shell Configuration

`.zshrc` loads in this order:

1. **PATH** - Homebrew, local bin
2. **Mise** - Activates version manager
3. **Sheldon** - Loads zsh plugins
4. **Tools** - Starship prompt, direnv, fzf
5. **Aliases** - Modern CLI replacements

### Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza --icons --git` | Modern ls |
| `cat` | `bat --style=plain` | Syntax highlighting |
| `tree` | `eza --tree --icons` | Directory tree |
| `la` | `eza --long --all --header --icons --git` | Detailed list |

---

## Git Configuration

- **Auto Remote:** `git push` sets upstream automatically
- **Rebase:** Pulls default to rebase (linear history)
- **Signing:** Commits signed with SSH key
- **Global Ignore:** `.DS_Store`, `.env`, `.vscode`, `.idea`

---

## Troubleshooting

### mise install fails
```bash
# Check if config is stowed
ls -la ~/.config/mise/config.toml
# Should show symlink to ~/dotfiles/mise/...
```

### Tool not found after install
```bash
# Reload shell
source ~/.zshrc
# Or restart terminal
```

### Homebrew package conflicts
```bash
# Run with cleanup
./install.sh --clean
```

### Backup files everywhere
```bash
# Find all backups
find ~ -name "*.bak" -type f 2>/dev/null
```

---

## License

MIT
