# Linux Support

This repository now supports Linux (Ubuntu, Debian, Fedora) in addition to macOS.

## Supported Platforms

- **macOS** (Apple Silicon) - Full support
- **Ubuntu** 20.04+ - Full support
- **Debian** 11+ - Full support
- **Fedora** 35+ - Full support
- **RHEL/CentOS** - Experimental support

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/fodurrr/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Interactive installation
./install.sh

# Non-interactive with profile
./install.sh --profile=hacker
```

### Platform Detection

The installer automatically detects your platform and installs packages using the appropriate package manager:

- **macOS**: Homebrew
- **Ubuntu/Debian**: apt
- **Fedora/RHEL**: dnf

## Platform-Specific Notes

### Linux

**Package Managers**:
- CLI tools are installed via `apt` or `dnf`
- Version management (mise) works the same as macOS
- Stow config management is cross-platform

**GUI Applications**:
- GUI apps (casks) are marked as `platform = ["macos"]` in `apps.toml`
- These are automatically skipped on Linux systems
- Install Linux GUI apps manually (e.g., via apt/dnf, AppImage, or Snap)

**Available on Linux**:
- CLI tools: eza, bat, ripgrep, fzf, jq, lazygit, tmux, yazi, etc.
- Runtimes: Node, Python, Rust, Elixir, Erlang, etc.
- Version manager: mise (for all above)
- Configs: git, zsh, starship, tmux, helix, yazi, etc.

**Not Available on Linux**:
- GUI terminals: Ghostty, Warp
- GUI editors: Zed, VS Code
- GUI productivity: Raycast, Obsidian, etc.
- macOS-specific: Hammerspoon, SketchyBar, Aerospace

### macOS

**No Changes** - macOS installation works exactly as before:
- Homebrew for all packages
- GUI apps via Homebrew casks
- Same profiles, same layers, same functionality

## App Registry (apps.toml)

### Platform Field

Each app in `apps.toml` now has an optional `platform` field:

```toml
[apps.ghostty]
type = "cask"
platform = ["macos"]
profiles = ["minimal", "standard", "developer", "hacker"]
description = "GPU-accelerated terminal emulator"

[apps.ripgrep]
type = "mise"
platform = ["macos", "linux"]
profiles = ["developer", "hacker", "server"]
description = "Fast recursive grep"
```

### Platform Values

- `macos` - macOS only
- `linux` - All Linux distributions
- `ubuntu` - Ubuntu/Debian only
- `debian` - Debian only
- `fedora` - Fedora/RHEL/CentOS only

### Default Behavior

If `platform` is not specified, the app is assumed to work on all platforms:

```toml
[apps.some-tool]
type = "mise"
# No platform field = all platforms supported
profiles = ["hacker"]
```

## Profiles

All profiles work on all supported platforms:

| Profile  | Description                                  | Linux Support |
|----------|----------------------------------------------|--------------|
| minimal  | Shell + essential CLI tools                  | ✓ Full      |
| standard | GUI apps + CLI tools (many macOS-only)      | ✓ Partial   |
| developer| Full development environment                   | ✓ Partial   |
| hacker   | Terminal-forward power usage                  | ✓ Full      |
| server   | Server/headless environment                  | ✓ Full      |

**Linux-specific recommendations**:
- `hacker` - Best choice for Linux (CLI-focused, no GUI)
- `server` - For headless servers
- `minimal` - Lightweight setup

## Installation Layers

The installer uses platform-aware layering:

### macOS
1. **Bootstrap** - Install Homebrew
2. **Homebrew Layer** - Install brew/cask packages
3. **Stow Layer** - Symlink config files
4. **Mise Layer** - Install tools via mise
5. **Curl Layer** - Vendor-specific installers

### Linux
1. **Bootstrap** - Install apt/dnf dependencies
2. **Linux Layer** - Install packages via apt/dnf
3. **Stow Layer** - Symlink config files
4. **Mise Layer** - Install tools via mise
5. **Curl Layer** - Vendor-specific installers

## Testing

Run the Linux test suite to verify your setup:

```bash
./scripts/test-linux.sh
```

This tests:
- Platform detection
- Package manager availability
- App filtering by platform
- App state detection

## Troubleshooting

### "Skipping Homebrew layer (not a macOS system)"

This is expected on Linux systems. The Linux layer handles package installation instead.

### GUI apps not available on Linux

Many GUI apps are macOS-only (marked in `apps.toml` with `platform = ["macos"]`). Install Linux alternatives manually:

```bash
# Example: Install Linux terminal emulator
sudo apt install alacritty

# Example: Install Linux code editor
sudo apt install neovim
```

### Package not found in apt/dnf

Some tools in `apps.toml` may not be available in your distro's repositories. Install them manually:

```bash
# Example: Install mise version manager
curl https://mise.jdx.dev/install.sh | sh

# Example: Install ripgrep
cargo install ripgrep
```

### Permissions issues on Linux

You may need sudo for package operations:

```bash
# Add current user to sudoers (if needed)
sudo visudo

# Then run installer with sudo
./install.sh
```

## Platform Comparison

| Feature               | macOS           | Linux                    |
|-----------------------|-----------------|--------------------------|
| Package Manager       | Homebrew        | apt / dnf                |
| GUI Apps            | Homebrew casks  | Manual / AppImage / Snap  |
| CLI Tools            | Homebrew/mise   | apt/dnf/mise             |
| Runtimes            | mise            | mise                     |
| Config Management     | Stow            | Stow (same)             |
| Shell               | Zsh             | Zsh (same)              |

## Contributing

When adding new apps to `apps.toml`:

1. Specify the `platform` field if it's platform-specific
2. Use `["macos"]` for macOS GUI apps
3. Use `["macos", "linux"]` for cross-platform CLI tools
4. Omit `platform` if app works on all platforms

Example:

```toml
# macOS GUI app
[apps.ghostty]
type = "cask"
platform = ["macos"]
profiles = ["minimal", "standard", "developer", "hacker"]
description = "GPU-accelerated terminal emulator"

# Cross-platform CLI tool
[apps.ripgrep]
type = "mise"
platform = ["macos", "linux"]
profiles = ["developer", "hacker", "server"]
description = "Fast recursive grep"
```

## Future Enhancements

Planned improvements for Linux support:

- [ ] AppImage auto-detection and installation
- [ ] Snap integration for Ubuntu
- [ ] Flatpak support
- [ ] Linux-specific GUI apps (optional layer)
- [ ] Distro-specific profiles
- [ ] Automated GUI app installation via native package managers
