# Peter's Dotfiles

Modern development environment configuration for Ubuntu, Debian, and Fedora Linux systems. Features a modular, profile-based installation system with intelligent defaults and full customization options.

## ✨ Features

- 🚀 **One-Command Installation** - Get started in seconds
- 📦 **Profile-Based Setup** - Quick, Full, or Custom installations
- 🔄 **Idempotent & Safe** - Run installers multiple times without issues
- 🎨 **Beautiful UI** - Interactive installer with gum integration
- 🐧 **Multi-Distro Support** - Works on Ubuntu, Debian, and Fedora
- 🛠️ **Modular Components** - Install only what you need
- 📝 **Well-Documented** - Comprehensive guides and examples

## 🚀 Quick Start

### One-Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/fodurrr/dotfiles/feature/reorganize-installer/setup.sh | bash
```

### Or Clone and Install

```bash
git clone https://github.com/fodurrr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-new.sh
```

## 📋 What's Included

### Shell Environment
- **Zsh** with vi-mode and extensive customization
- **Starship** prompt - Fast and beautiful
- **Zinit** plugin manager with curated plugins

### Modern CLI Tools
- **eza** - Modern ls with icons and git integration
- **fzf** - Fuzzy finder for everything
- **bat** - Cat with syntax highlighting
- **zoxide** - Smarter cd that learns your habits

### Development Tools
- **Neovim** - Latest version with LazyVim configuration
- **Devbox** - Nix-based development environment manager
- **Git** - Configured with GitHub CLI integration
- **LazyGit** - Beautiful terminal UI for git
- **Fabric** - AI-powered text processing tool

### Languages & Runtimes (via Devbox)
- Node.js 24.x + pnpm
- Elixir 1.19.1 + Erlang
- Go toolchain
- And more via devbox.json

## 🎯 Installation Profiles

### Quick Profile (~5 min)
Essential tools for basic shell work.

```bash
./install-new.sh --profile quick
```

**Includes:** Zsh, Starship, CLI tools, Git, Stow

### Full Profile (~15 min)
Complete development environment.

```bash
./install-new.sh --profile full
```

**Includes:** Everything + Neovim, Devbox, Fabric, LazyGit

### Custom Profile
Choose exactly what you want.

```bash
./install-new.sh --profile custom
```

**Interactive selection** of components with gum UI.

## 📖 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Complete installation instructions
- **[CLAUDE.md](CLAUDE.md)** - Instructions for Claude Code
- **[DEV_PREFERENCES.md](DEV_PREFERENCES.md)** - Developer preferences

## 🛠️ Key Commands

```bash
# Installation
./install-new.sh                 # Interactive install
./install-new.sh --profile quick # Quick profile
./install-new.sh --profile full  # Full profile

# Syncing dotfiles
./sync-new.sh                    # Sync with GNU Stow
./sync-new.sh --dry-run          # Preview changes
./sync-new.sh --backup           # Backup conflicting files

# Devbox environment
cd ~/dotfiles && devbox shell    # Enter dev environment
```

## 🎨 Shell Aliases & Functions

Once installed, you'll have access to:

### File Management
- `ls` → eza with icons
- `la` → eza long format with all files
- `lt` → eza tree view
- `cat` → bat with syntax highlighting

### Git
- `gs` → git status
- `gcam "message"` → git add all & commit
- `gp` → git push
- `lg` → lazygit
- `clone repo` → gh clone + cd

### Navigation
- `z directory` → jump to frequently used directories
- `dev project` → cd to ~/dev/project
- `repros project` → cd to ~/r/project
- `forks project` → cd to ~/f/project

### Custom Functions
- `y` → Yazi file manager with directory change on exit
- `mkdirg dir` → Make directory and cd into it
- `pr [num]` → List or checkout GitHub PRs

## 📁 Project Structure

```
dotfiles/
├── .config/              # Application configurations
│   ├── nvim/            # Neovim (LazyVim)
│   ├── fabric/          # Fabric AI tool
│   └── starship.toml    # Starship prompt config
├── scripts/
│   ├── lib/             # Shared library functions
│   ├── components/      # Modular installation scripts
│   └── profiles/        # Installation profiles
├── docs/                # Documentation
├── install-new.sh       # Main installer
├── setup.sh             # One-command setup script
├── sync-new.sh          # Dotfile sync script
├── devbox.json          # Devbox configuration
└── .zshrc               # Zsh configuration
```

## 🔧 Customization

All configurations are stored in this repository and symlinked to your home directory.

### Modifying Zsh Configuration

```bash
# Edit the configuration
vim ~/.zshrc  # This is a symlink to ~/dotfiles/.zshrc

# Reload
source ~/.zshrc
```

### Adding More Tools to Devbox

```bash
# Edit devbox.json
cd ~/dotfiles
vim devbox.json

# Update devbox
devbox update
devbox shell
```

### Customizing Neovim

```bash
# LazyVim configuration
vim ~/.config/nvim/lua/plugins/

# Install/update plugins
nvim
# Then type: :Lazy
```

## 🌐 Supported Systems

| OS | Version | Status |
|----|---------|--------|
| Ubuntu | 20.04+ | ✅ Fully Supported |
| Debian | 11+ | ✅ Fully Supported |
| Fedora | 35+ | ✅ Fully Supported |

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to:
- Fork and adapt for your own use
- Report issues
- Suggest improvements
- Submit pull requests

## 📝 License

MIT License - Feel free to use and modify as you wish.

## 👤 Author

**Peter Fodor**
- Email: fodurrr@gmail.com
- GitHub: [@fodurrr](https://github.com/fodurrr)
- 30+ years in tech, self-taught developer, IT geek

## 🙏 Acknowledgments

Built with and inspired by:
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Zinit](https://github.com/zdharma-continuum/zinit) - Zsh plugin manager
- [LazyVim](https://www.lazyvim.org/) - Neovim distribution
- [Devbox](https://www.jetify.com/devbox) - Development environment manager
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- [Fabric](https://github.com/danielmiessler/fabric) - AI text processing

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ by Peter

</div>
