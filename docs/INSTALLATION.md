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
./install-new.sh
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
./install-new.sh --profile quick
```

### 💎 Full Profile (~15 minutes)

Complete development environment with all tools.

**Includes:** Everything in Quick, plus:
- Neovim + LazyVim configuration
- Devbox for package management
- Fabric AI tool
- LazyGit

**Perfect for:** Primary development machines, complete setups

```bash
./install-new.sh --profile full
```

### 🎯 Custom Profile

Interactively choose which components to install.

**Features:**
- Select specific components
- Skip tools you don't need
- Uses gum for nice TUI (falls back to prompts)

```bash
./install-new.sh --profile custom
```

---

## Command-Line Options

```bash
./install-new.sh [OPTIONS]

OPTIONS:
    --profile PROFILE    Installation profile (quick/full/custom)
    --yes, -y            Skip all confirmations
    --no-sync            Skip running sync.sh after installation
    --help, -h           Show help message
```

### Examples

```bash
# Interactive mode (default)
./install-new.sh

# Quick install without prompts
./install-new.sh --profile quick --yes

# Full install with prompts
./install-new.sh --profile full

# Custom selection
./install-new.sh --profile custom
```

---

## Post-Installation Steps

### 1. Sync Dotfiles

```bash
./sync-new.sh
```

This creates symlinks from the repository to your `$HOME` directory.

**Options:**
```bash
./sync-new.sh --dry-run    # Preview changes
./sync-new.sh --backup     # Backup conflicting files
./sync-new.sh --yes        # Skip confirmations
```

### 2. Reload Shell

```bash
# Option 1: Source your new config
source ~/.zshrc

# Option 2: Start a new shell
exec zsh

# Option 3: Log out and log back in (recommended)
```

### 3. Configure API Keys (if using Fabric)

```bash
# Copy the example file
cp ~/.config/fabric/.env.example ~/.config/fabric/.env

# Edit and add your API keys
nano ~/.config/fabric/.env
```

Get API keys:
- OpenAI: https://platform.openai.com/api-keys
- Anthropic: https://console.anthropic.com/

### 4. Authenticate with GitHub

```bash
gh auth login
```

Follow the prompts to authenticate the GitHub CLI.

### 5. Enter Devbox Environment (if installed)

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
- **Fabric**: AI tool for text processing

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
sudo ./install-new.sh  # ❌

# Do this:
./install-new.sh       # ✅
```

### Sync Fails with "Conflicting Files"

**Solution:** Use the `--backup` flag to automatically backup conflicting files.

```bash
./sync-new.sh --backup
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

# Fabric only
./scripts/components/fabric.sh
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
- **Fabric Documentation**: https://github.com/danielmiessler/fabric

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
