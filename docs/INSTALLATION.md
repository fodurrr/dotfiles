# Installation Guide

Complete guide for installing Peter's dotfiles on a fresh Ubuntu, Debian, or Fedora system.

## Quick Start

### One-Command Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/fodurrr/dotfiles/feature/reorganize-installer/setup.sh | bash
```

This will:
1. Clone the dotfiles repository
2. Run the interactive installer
3. Set up your development environment

### Manual Install

```bash
# Clone the repository
git clone https://github.com/fodurrr/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installer
./install.sh
```

---

## Installation Profiles

Choose the profile that best fits your needs:

### 🚀 Quick Profile (~5 minutes)

Essential tools for basic shell work.

**Includes:**
- System base packages
- Zsh + Starship + Zinit
- Modern CLI tools (eza, fzf, bat, zoxide)
- Git configuration + GitHub CLI
- GNU Stow

**Perfect for:** Lightweight setups, servers, minimal installations

```bash
./install.sh --quick
```

### 💎 Full Profile (~15 minutes)

Complete development environment with all tools.

**Includes:** Everything in Quick, plus:
- Neovim + LazyVim configuration
- Devbox for package management
- LazyGit

**Perfect for:** Primary development machines, complete setups

```bash
./install.sh --full
```

### 🎯 Custom Profile

Interactively choose which components to install.

**Features:**
- Select specific components
- Skip tools you don't need
- Uses gum for nice TUI (falls back to prompts)

```bash
./install.sh --custom
```

---

## Command-Line Options

```bash
./install.sh [OPTIONS]

OPTIONS:
    --quick             Quick installation (essential tools only, 3-5 min)
    --full              Full installation (everything, 15-20 min)
    --custom            Custom installation (choose components)
    --help, -h          Show help message
```

### Examples

```bash
# Interactive mode (default)
./install.sh

# Quick installation
./install.sh --quick

# Full installation
./install.sh --full

# Custom component selection
./install.sh --custom
```

---

## Post-Installation Steps

### 1. Sync Dotfiles

```bash
./sync.sh
```

This creates symlinks from the repository to your `$HOME` directory using GNU Stow.

### 2. Reload Shell

```bash
# Option 1: Source your new config
source ~/.zshrc

# Option 2: Start a new shell
exec zsh

# Option 3: Log out and log back in (recommended)
```

### 3. Authenticate with GitHub

```bash
gh auth login
```

Follow the prompts to authenticate the GitHub CLI.

### 4. Enter Devbox Environment (if installed)

```bash
cd ~/dotfiles
devbox shell
```

All devbox-managed tools will be available inside the shell.

---

## What Gets Installed

### System Base
- Essential utilities (curl, wget, git)
- Build tools (build-essential/Development Tools)
- Compression tools
- GPG and certificates
- Clipboard utilities

### Shell Environment
- **Zsh**: Modern shell with better features
- **Starship**: Fast, customizable prompt
- **Zinit**: Plugin manager with these plugins:
  - zsh-syntax-highlighting
  - zsh-autosuggestions
  - zsh-completions
  - fzf-tab
  - zsh-vi-mode

### Modern CLI Tools
- **eza**: Modern `ls` replacement with icons
- **fzf**: Fuzzy finder for files/commands
- **bat**: `cat` with syntax highlighting
- **zoxide**: Smarter `cd` command (learns your paths)

### Git Tools
- Global git configuration
- GitHub CLI (`gh`)
- LazyGit (Full profile only)

### Development Environment (Full Profile)
- **Neovim**: Latest version with LazyVim configuration
- **Devbox**: Nix-based package manager with:
  - gum, stow, gh, jq, yq-go
  - hcloud, tealdeer
  - nodejs, pnpm
  - Elixir + Erlang (via custom flakes)

---

## System Requirements

### Supported Operating Systems
- Ubuntu 20.04+
- Debian 11+
- Fedora 35+

### Minimum Requirements
- **Disk Space**: 1GB free (Quick), 2GB free (Full)
- **RAM**: 1GB minimum
- **Internet**: Required for downloads
- **Sudo Access**: Required

### Pre-Installed Requirements
- `bash` (usually pre-installed)
- `curl` or `wget` (for one-command install)

---

## Troubleshooting

### Installation Fails with "Permission Denied"

**Solution:** Ensure you have sudo access and run without `sudo` (the script requests sudo internally).

```bash
# Don't do this:
sudo ./install.sh  # ❌

# Do this:
./install.sh       # ✅
```

### Sync Fails with "Conflicting Files"

**Solution:** Manually backup conflicting files before running sync.

```bash
# Backup existing configs
mv ~/.zshrc ~/.zshrc.backup
mv ~/.config/starship.toml ~/.config/starship.toml.backup

# Then run sync
./sync.sh
```

### Zsh Doesn't Load After Installation

**Solution:** You may need to log out and log back in for the shell change to take effect.

```bash
# Check current shell
echo $SHELL

# If not zsh, manually change it
chsh -s $(which zsh)

# Then log out and log back in
```

### Devbox Commands Not Found

**Solution:** Devbox tools are only available inside `devbox shell`.

```bash
cd ~/dotfiles
devbox shell
# Now devbox tools are available
```

### GitHub CLI Authentication Fails

**Solution:** Ensure you're using a supported authentication method.

```bash
# Try browser-based auth
gh auth login --web

# Or use a token
gh auth login --with-token < token.txt
```

---

## Component-Specific Installation

You can also install individual components directly:

```bash
# System base only
./scripts/components/system-base.sh

# Shell environment only
./scripts/components/shell.sh

# Modern CLI tools only
./scripts/components/cli-tools.sh

# Neovim only
./scripts/components/neovim.sh

# Git configuration only
./scripts/components/git-config.sh

# LazyGit only
./scripts/components/lazygit.sh

# Devbox only
./scripts/components/devbox.sh
```

All component scripts are idempotent and can be run multiple times safely.

---

## Uninstallation

To remove installed tools:

```bash
# Remove symlinks created by stow
cd ~/dotfiles
stow -D .

# Optionally remove the dotfiles directory
rm -rf ~/dotfiles
```

Individual tools can be uninstalled using your system's package manager:

```bash
# Ubuntu/Debian
sudo apt remove package-name

# Fedora
sudo dnf remove package-name
```

---

## Additional Resources

- **GitHub Repository**: https://github.com/fodurrr/dotfiles
- **Issues**: https://github.com/fodurrr/dotfiles/issues
- **Starship Documentation**: https://starship.rs/
- **Zinit Documentation**: https://github.com/zdharma-continuum/zinit
- **Devbox Documentation**: https://www.jetify.com/devbox/docs/

---

## Next Steps

After installation:

1. ✅ Explore your new zsh configuration
2. ✅ Try the modern CLI tools:
   - `ls` (now eza with icons)
   - `bat file.txt` (syntax-highlighted cat)
   - `z dirname` (jump to frequently used directories)
   - `fzf` (fuzzy find files)
3. ✅ Launch Neovim: `nvim` (LazyVim will auto-install plugins)
4. ✅ Try LazyGit: `lg` or `lazygit`
5. ✅ Customize further by editing `~/.zshrc` and `~/.config/`

Enjoy your new development environment! 🎉
