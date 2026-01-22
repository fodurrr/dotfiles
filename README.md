# Dotfiles

A modern, declarative, and reproducible development environment for macOS (Apple Silicon).

## Testing in a Virtual Machine (Safety First)

Before running these dotfiles on your main machine, test them safely in a macOS VM using UTM.

**Why test in a VM?**
- Zero risk to your real system
- Easy to roll back after testing
- Verify installation works end-to-end
- Catch issues before they affect your workflow

**Quick workflow:**
1. Create a macOS VM in UTM (auto-download IPSW or manual IPSW)
2. Install Xcode Command Line Tools (for Git)
3. Create a restore point (duplicate the VM or use disposable mode)
4. Configure SSH keys for GitHub access
5. Clone: `git clone git@github.com:username/dotfiles.git ~/dotfiles`
6. Run: `./install.sh`
7. Verify everything works, then apply to your real machine

For complete setup instructions including UTM/IPSW prep, snapshots, and troubleshooting, see **[docs/vm-testing.md](docs/vm-testing.md)**.

---

## Quick Start

```bash
# Clone and install (interactive profile selection)
git clone https://github.com/fodurrr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will show an interactive menu to select which profile(s) to install. The **minimal** profile is pre-selected by default.

---

## Profile System

This dotfiles repo uses a **profile-based installation system** to support different use cases.

### Available Profiles

| Profile | Target User | Key Apps |
|---------|-------------|----------|
| **minimal** | Fresh Mac, testing | Ghostty, Zed, Firefox, Raycast, Bitwarden |
| **standard** | Friends/family, casual users | All of minimal + Warp, Chrome, AI Desktop apps, Spotify |
| **developer** | Power users, terminal-centric | Ghostty, Aerospace, tmux, neovim, AI CLI tools |

### Usage Examples

```bash
# Interactive mode (shows profile selection menu)
./install.sh

# Non-interactive: install a single profile
./install.sh --profile=developer

# Install multiple profiles (merged together)
./install.sh --profile=developer --profile=standard
./install.sh -p developer -p standard

# Clean mode: remove apps not in selected profile(s)
./install.sh --profile=developer --clean

# List available profiles
./install.sh --list-profiles
```

### Profile Switching Behavior

When switching between profiles, there are two modes:

#### Merge Mode (Default)
```bash
./install.sh --profile=developer
```
- **ADDS** apps from the new profile
- **KEEPS** all existing apps (even if not in the new profile)
- Safe for experimentation

**Example:** If you have `standard` installed and run this:
- Keeps: Warp, Claude Desktop, ChatGPT Desktop (from standard)
- Adds: Aerospace, tmux, neovim (from developer)
- Result: Everything combined

#### Clean Mode (Strict)
```bash
./install.sh --profile=developer --clean
```
- **ADDS** apps from the selected profile(s)
- **REMOVES** managed apps NOT in the selected profile(s)
- Strict enforcement of profile

**Example:** If you have `standard` installed and run this:
- Removes: Warp, Claude Desktop, ChatGPT Desktop (standard-only)
- Adds: Aerospace, tmux, neovim (developer-only)
- Keeps: Ghostty, Firefox, Zed (in both profiles)

### Visual Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  Scenario: User has "standard" installed, wants "developer"     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Standard profile:          Developer profile:                   │
│  ├── Ghostty                ├── Ghostty                         │
│  ├── Warp                   ├── Aerospace                       │
│  ├── Claude Desktop         ├── tmux                            │
│  ├── ChatGPT Desktop        ├── neovim                          │
│  └── Firefox                └── Firefox                         │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│  MERGE: ./install.sh --profile=developer                        │
│  Result: Ghostty, Warp, Claude, ChatGPT, Firefox,               │
│          Aerospace, tmux, neovim (everything combined)          │
├─────────────────────────────────────────────────────────────────┤
│  CLEAN: ./install.sh --profile=developer --clean                │
│  Result: Ghostty, Firefox, Aerospace, tmux, neovim              │
│          (Warp, Claude, ChatGPT REMOVED)                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Two-Phase Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 1: BOOTSTRAP                          │
│                (Always runs, installs infrastructure)            │
├─────────────────────────────────────────────────────────────────┤
│  1. Install Homebrew (if missing)                                │
│  2. Install infrastructure packages:                             │
│     - mise (version manager)                                     │
│     - stow (symlink manager)                                     │
│     - sheldon (zsh plugin manager)                               │
│     - dasel (TOML parser)                                        │
│     - gum (interactive menus)                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 2: PROFILE                            │
│              (Installs apps based on selected profiles)          │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1: Homebrew - Casks and brews from apps.toml              │
│  Layer 2: Stow     - Config symlinks from apps.toml              │
│  Layer 3: Mise     - CLI tools and runtimes from apps.toml       │
│  Layer 5: Curl     - AI CLI installers from apps.toml            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
~/dotfiles/
├── apps.toml                    # Centralized app registry (all apps + profiles)
├── Brewfile.bootstrap           # Infrastructure packages only
├── install.sh                   # Two-phase installer with profile support
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
├── README.md
└── CLAUDE.md                    # AI assistant instructions
```

---

## The Centralized Config: apps.toml

All apps are defined in a single `apps.toml` file with profile assignments:

```toml
# Example entries from apps.toml

[apps.ghostty]
type = "cask"
category = "terminals"
profiles = ["minimal", "standard", "developer"]

[apps.warp]
type = "cask"
category = "terminals"
profiles = ["standard"]  # Only in standard profile

[apps.aerospace]
type = "cask"
tap = "nikitabobko/tap"
name = "nikitabobko/tap/aerospace"
category = "window-management"
profiles = ["developer"]  # Only in developer profile

[apps.tmux]
type = "mise"
category = "cli"
profiles = ["developer"]

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
| `mise` | Mise-managed tool | starship, eza, bat, node, python |
| `stow` | Config symlinks | git, zsh, ghostty configs |
| `curl` | Curl installer script | claude-cli, opencode-cli |

### Creating a New Profile

Just add your profile name to any app's `profiles` array:

```toml
[apps.my-special-app]
type = "cask"
profiles = ["developer", "my-new-profile"]  # Creates "my-new-profile" automatically
```

Then run: `./install.sh --profile=my-new-profile`

---

## What Gets Installed by Profile

### Minimal Profile
Core essentials for a clean Mac setup:

- **Terminals:** Ghostty
- **Editors:** Zed
- **Browsers:** Firefox
- **Productivity:** Raycast, Bitwarden
- **Fonts:** JetBrains Mono Nerd Font
- **CLI:** starship, eza, bat, ripgrep, fzf, jq, yq, gh, direnv
- **Runtimes:** Node.js (LTS), Python 3.14

### Standard Profile
Everything in minimal, plus:

- **Terminals:** + Warp
- **Editors:** + VSCode, Antigravity
- **Browsers:** + Chrome, Edge
- **AI Desktop:** Claude, ChatGPT, Codex, OpenCode
- **Media:** Spotify, VLC, Discord
- **Productivity:** + Obsidian, Wispr Flow
- **Virtualization:** OrbStack, UTM
- **Runtimes:** + Rust, Bun, pnpm

### Developer Profile
Terminal-centric workflow:

- **Window Management:** Aerospace (tiling WM with vim keybindings)
- **Terminals:** Ghostty + tmux
- **Editors:** Zed, VSCode, Neovim
- **Browsers:** Firefox
- **AI CLI:** claude-cli, opencode-cli, codex-cli, gemini-cli (no desktop apps)
- **File Manager:** yazi (terminal-based)
- **CLI Extras:** btop, ncdu, lazygit
- **Runtimes:** + Erlang, Elixir

---

## Common Commands

```bash
# Interactive installation (profile selection menu)
./install.sh

# Install specific profile(s)
./install.sh --profile=developer
./install.sh -p minimal -p standard

# Clean install (removes apps not in profile)
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

---

## Adding New Tools

### To apps.toml

```toml
# Add a GUI app
[apps.figma]
type = "cask"
category = "design"
profiles = ["standard", "developer"]

# Add a CLI tool
[apps.lazygit]
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

### Profile switching issues
```bash
# Use clean mode for strict enforcement
./install.sh --profile=developer --clean
```

### Backup files everywhere
```bash
# Find all backups
find ~ -name "*.bak" -type f 2>/dev/null
```

---

## License

MIT
