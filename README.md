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
5. Clone: `git clone git@github.com:fodurrr/dotfiles.git ~/dotfiles`
6. cd ~/dotfiles
7. Run: `./install.sh`
8. Verify everything works, then apply to your real machine

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

## Keyboard Shortcuts Cheatsheet

Both **developer** and **hacker** profiles include a built-in keyboard shortcuts reference that you can open at any time.

### Hacker Profile

| Method | How to Use |
|--------|------------|
| **Keyboard** | Press `alt + ?` (alt-shift-slash) |
| **Mouse** | Click the help icon (?) in the center of SketchyBar |

The cheatsheet includes: Helix modes & motions, Aerospace, Ghostty, Yazi, Zsh, Zed, tmux, file navigation (eza), and Git aliases.

### Developer Profile

| Method | How to Use |
|--------|------------|
| **Raycast** | Open Raycast and search for "Keybinds" or "Cheatsheet" |

The cheatsheet includes: Helix modes & motions, Ghostty, Zsh, Zed, file navigation (eza), and Git aliases.

> **Tip:** Press `q` to close the cheatsheet window.

> **Note:** The cheatsheet window centering and sizing requires **Raycast Pro** subscription. Without Pro, the window will still open but may not be properly centered.

---

## Keyboard Layout Viewer (Voyager)

Both **developer** and **hacker** profiles include a Voyager keyboard layout viewer to quickly reference your layer mappings.

### Hacker Profile

| Method | How to Use |
|--------|------------|
| **Keyboard** | Press `alt + ;` (all layers) or `alt + :` (cycle mode) |
| **Mouse** | Click the keyboard icon (⌨) in SketchyBar |

### Developer Profile

| Method | How to Use |
|--------|------------|
| **Raycast** | Open Raycast and search for "Keyboard Layout" |

**In cycle mode:**
- `SPACE` or `n` - Next layer
- `p` - Previous layer
- `q` - Quit

> **Note:** Layer images are stored in `~/.config/keyboard-layout/`. To update them, export new screenshots from Keymapp and replace `layer-1.png`, `layer-2.png`, `layer-3.png`.

---

## Profile System

This dotfiles repo uses a **profile-based installation system** to support different use cases.

### Available Profiles

| Profile | Target User | Description |
|---------|-------------|-------------|
| **minimal** | Fresh Mac, testing | Bare essentials on top of macOS |
| **standard** | Regular users (spouse/family) | Browsing, media, basic productivity |
| **developer** | GUI-centric developers | VSCode, Warp, mouse-driven workflow |
| **hacker** | Terminal-centric power users | Helix, tmux, Aerospace, keyboard-driven |
| **server** | SSH/remote admin | Terminal-only tools for headless servers |

### Usage Examples

```bash
# Interactive mode (shows profile selection menu)
./install.sh

# Non-interactive: install a single profile
./install.sh --profile=hacker

# Install multiple profiles (merged together)
./install.sh --profile=developer --profile=standard
./install.sh -p developer -p standard

# Clean mode: remove apps not in selected profile(s)
./install.sh --profile=hacker --clean

# List available profiles
./install.sh --list-profiles
```

### Profile Switching Behavior

When switching between profiles, there are two modes:

#### Merge Mode (Default)
```bash
./install.sh --profile=hacker
```
- **ADDS** apps from the new profile
- **KEEPS** all existing apps (even if not in the new profile)
- Safe for experimentation

**Example:** If you have `developer` installed and run this:
- Keeps: Warp, VSCode, Zed (from developer)
- Adds: Aerospace, tmux, Helix, AI CLI tools (from hacker)
- Result: Everything combined

#### Clean Mode (Strict)
```bash
./install.sh --profile=hacker --clean
```
- **ADDS** apps from the selected profile(s)
- **REMOVES** managed apps NOT in the selected profile(s)
- Strict enforcement of profile

**Example:** If you have `developer` installed and run this:
- Removes: (nothing - hacker includes all of developer)
- Adds: Aerospace, tmux, Helix, AI CLI tools (hacker-only)
- Keeps: Everything from developer

### Visual Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  Scenario: User has "standard" installed, wants "hacker"           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Daily profile:             Hacker profile:                      │
│  ├── Ghostty                ├── Ghostty                         │
│  ├── Chrome                 ├── Chrome                          │
│  ├── Claude Desktop         ├── Claude Desktop                  │
│  ├── ChatGPT Desktop        ├── Aerospace                       │
│  └── Firefox                ├── tmux, Helix                     │
│                             └── AI CLI tools                    │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│  MERGE: ./install.sh --profile=hacker                           │
│  Result: Everything from standard + Aerospace, tmux, Helix,        │
│          AI CLI tools (everything combined)                     │
├─────────────────────────────────────────────────────────────────┤
│  CLEAN: ./install.sh --profile=hacker --clean                   │
│  Result: Hacker apps only (standard-only items removed)            │
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
│  3. Install TPM (Tmux Plugin Manager)                            │
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
├── zed/                         # Stow package → ~/.config/zed/
├── aerospace/                   # Stow package → ~/.config/aerospace/
├── tmux/                        # Stow package → ~/.config/tmux/
├── helix/                       # Stow package → ~/.config/helix/
├── yazi/                        # Stow package → ~/.config/yazi/
├── cheatsheet/                  # Stow package → ~/.config/cheatsheet/
├── keyboard-layout/             # Stow package → ~/.config/keyboard-layout/
├── docs/                        # Documentation
├── README.md
├── AGENTS.md                    # AI assistant instructions (mirrors CLAUDE.md)
└── CLAUDE.md                    # AI assistant instructions (source of truth)
```

---

## The Centralized Config: apps.toml

All apps are defined in a single `apps.toml` file with profile assignments:

```toml
# Example entries from apps.toml

[apps.ghostty]
type = "cask"
category = "terminals"
profiles = ["minimal", "standard", "developer", "hacker"]

[apps.warp]
type = "cask"
category = "terminals"
profiles = ["developer", "hacker"]  # Developer profiles only

[apps.aerospace]
type = "cask"
tap = "nikitabobko/tap"
name = "aerospace"
category = "window-management"
profiles = ["hacker"]  # Keyboard-centric profile only

[apps.tmux]
type = "mise"
category = "cli"
profiles = ["hacker", "server"]

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
| `mise` | Mise-managed tool | starship, eza, bat, node, python |
| `stow` | Config symlinks | git, zsh, ghostty configs |
| `curl` | Curl installer script | claude-cli, opencode-cli |

### Creating a New Profile

Just add your profile name to any app's `profiles` array:

```toml
[apps.my-special-app]
type = "cask"
profiles = ["hacker", "my-new-profile"]  # Creates "my-new-profile" automatically
```

Then run: `./install.sh --profile=my-new-profile`

---

## What Gets Installed by Profile

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
| codex-acp | | | ✓ | ✓ | |
| opencode-cli | | | | ✓ | |
| gemini-cli | | | | ✓ | |
| **PRODUCTIVITY** |
| Obsidian | | ✓ | ✓ | ✓ | |
| KeyCastr | | | ✓ | ✓ | |
| Bettershot | | ✓ | ✓ | ✓ | |
| Kap | | ✓ | ✓ | ✓ | |
| Stretchly | | ✓ | ✓ | ✓ | |
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
| Keymapp | | | | ✓ | |
| Pearcleaner | | ✓ | ✓ | ✓ | |
| **SECURITY** |
| SandVault | | | ✓ | ✓ | |
| **CLI TOOLS** |
| starship | ✓ | ✓ | ✓ | ✓ | ✓ |
| eza | ✓ | ✓ | ✓ | ✓ | ✓ |
| bat | ✓ | ✓ | ✓ | ✓ | ✓ |
| fzf | ✓ | ✓ | ✓ | ✓ | ✓ |
| ripgrep | | | ✓ | ✓ | ✓ |
| jq | | | ✓ | ✓ | ✓ |
| gh | | | ✓ | ✓ | ✓ |
| direnv | | | ✓ | ✓ | |
| yazi | | | | ✓ | ✓ |
| lazygit | | | | ✓ | ✓ |
| btop | | | | ✓ | ✓ |
| ncdu | | | | ✓ | ✓ |
| chafa | | | ✓ | ✓ | |
| Mole | ✓ | ✓ | ✓ | ✓ | |
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
| mise-config | ✓ | ✓ | ✓ | ✓ | ✓ |
| zed-config | | | ✓ | ✓ | |
| aerospace-config | | | | ✓ | |
| sketchybar-config | | | | ✓ | |
| tmux-config | | | | ✓ | ✓ |
| helix-config | | | ✓ | ✓ | ✓ |
| yazi-config | | | | ✓ | ✓ |
| cheatsheet-config | | | ✓ | ✓ | |
| keyboard-layout-config | | | ✓ | ✓ | |

### Profile Summaries

**Minimal (~16 apps):** Bare essentials - Raycast, Bitwarden, Firefox, Chrome, Ghostty, basic CLI tools

**Standard (~36 apps):** Regular users - adds Edge, Spotify, VLC, Discord, Obsidian, Claude/ChatGPT Desktop, BetterDisplay, OneDrive, Google Drive, Microsoft Office, Teams, WhatsApp, Bettershot, Kap, Stretchly, Pearcleaner, Mole

**Developer (~53 apps):** GUI-centric devs - adds Warp, Zed, VSCode, Aqua Voice, KeyCastr, dev AI apps, OrbStack, UTM, Beekeeper Studio, pgAdmin4, SandVault, all runtimes

**Hacker (~61 apps):** Terminal-centric - adds Aerospace, tmux, Helix, yazi, lazygit, btop, ncdu, AI CLI tools, Keymapp, SandVault

**Server (~20 apps):** Headless/SSH - terminal tools only, no GUI apps

---

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

# Clean install (removes apps not in profile)
./install.sh --profile=hacker --clean

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

## Stow Policy (Must Follow)

We only stow stable config files. We never stow runtime/state directories.

- Only include files we explicitly want versioned in each stow package
- Never symlink an app’s entire config directory if it also stores runtime data there
- Prefer stowing stable subpaths (e.g., `scripts/`) rather than the parent directory

Full policy: `docs/stow-policy.md`

---

## Zed Editor Configuration

Zed is configured with vim mode and keybindings that match Helix/tmux for unified muscle memory:

| Key | Action |
|-----|--------|
| `jk` | Escape to normal mode |
| `Ctrl+hjkl` | Navigate panes (matches tmux) |
| `ss` | Split vertical |
| `sv` | Split horizontal |
| `Shift+h/l` | Previous/next buffer |
| `Space Space` | File finder |
| `Space e` | Toggle project panel |

Config files are in `zed/.config/zed/`:
- `settings.json` - Vim mode, theme, fonts
- `keymap.json` - Custom keybindings

---

## Catppuccin Mocha Theme

All tools are configured with a consistent **Catppuccin Mocha** theme for visual harmony:

| Tool | Theme Source |
|------|--------------|
| Ghostty | Built-in Catppuccin Mocha |
| Helix | Built-in catppuccin_mocha |
| Zed | Built-in Catppuccin Mocha |
| Tmux | catppuccin/tmux plugin (via TPM) |
| Starship | Catppuccin Mocha palette |
| FZF | Catppuccin colors in .zshrc |
| Yazi | catppuccin-mocha.yazi flavor |

---

## Tmux with TPM

Tmux uses [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm) for plugins including:

- **catppuccin/tmux** - Catppuccin Mocha theme
- **tmux-resurrect** - Persist sessions across restarts
- **tmux-continuum** - Auto-restore sessions
- **tmux-yank** - Enhanced copy/paste

**Post-install step:** After tmux starts for the first time, press `Ctrl+A` then `Shift+I` to install plugins.

**Keybindings (vim-style):**
| Key | Action |
|-----|--------|
| `Ctrl+A` | Prefix (instead of default `Ctrl+B`) |
| `h/j/k/l` | Navigate panes |
| `v` | Split vertical |
| `s` | Split horizontal |
| `H/J/K/L` | Resize panes |
| `r` | Reload config |

---

## AI Agent Sandboxing

Both **developer** and **hacker** profiles include SandVault for running AI coding agents safely in isolation.

See **[docs/ai-agent-sandbox-guide.md](docs/ai-agent-sandbox-guide.md)** for the complete workflow guide.

**Quick start:**
```bash
cd ~/dev/my-project
sandbox-claude                              # Claude in sandbox
sandbox-claude --dangerously-skip-permissions  # Autonomous mode
```

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
./install.sh --profile=hacker --clean
```

### Backup files everywhere
```bash
# Find all backups
find ~ -name "*.bak" -type f 2>/dev/null
```

---

## License

MIT
