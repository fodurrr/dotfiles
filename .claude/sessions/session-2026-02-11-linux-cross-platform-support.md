# Session: Linux Cross-Platform Support

**Date**: 2026-02-11
**Repository**: fodurrr/dotfiles
**Branch**: feature/linux-cross-platform

---

## Topic

Adding Linux cross-platform support (Ubuntu, Debian, Fedora) to existing macOS dotfiles repository. The goal was to consolidate two separate dotfiles repos (macOS-only and Linux-focused) into a single platform-aware repository.

---

## Progress

### Completed Implementation

✅ **Phase 1: Foundation & Platform Detection**
- Created `scripts/lib/platform.sh` (145 lines)
  - `detect_platform()` - Detects OS family (macos, linux)
  - `detect_linux_distro()` - Detects Linux distribution (ubuntu, debian, fedora, rhel, centos)
  - `detect_architecture()` - Detects CPU architecture (amd64, arm64)
  - `is_supported_platform()` - Validates platform support
  - `get_package_manager()` - Returns appropriate package manager (brew/apt/dnf)
  - `platform_matches()` - Matches current platform to app's platform list
  - `show_platform_info()` - Displays platform information for debugging

✅ **Phase 2: Package Manager Abstraction**
- Created `scripts/lib/package-manager.sh` (280 lines)
  - `pm_get_os()` / `pm_get_manager()` - Platform/package manager detection
  - `pm_update()` - Updates package cache (apt/dnf/brew)
  - `pm_install()` / `pm_install_batch()` - Package installation
  - `pm_is_installed()` - Checks if package is installed
  - `pm_remove()` - Uninstalls packages
  - `pm_add_repository()` - Adds repos/PPAs/taps
  - `pm_enable_copr()` - Enables COPR repositories (dnf)
  - `pm_add_gpg_key()` - Adds GPG keys for repositories
  - `pm_clean()` - Cleans package cache
  - `pm_get_version()` - Gets installed package version
  - `pm_has_sudo()` - Checks sudo access

✅ **Phase 3: Linux Installation Layer**
- Created `scripts/install/layer_linux.sh` (268 lines)
  - `map_brew_to_linux_package()` - Maps brew package names to apt/dnf equivalents
  - `is_package_available()` - Checks package availability in repos
  - `install_package()` - Installs single package with error handling
  - `install_apt_packages()` - Installs apt packages (Ubuntu/Debian)
  - `install_dnf_packages()` - Installs dnf packages (Fedora/RHEL)
  - `run_layer_linux()` - Main entry point for Linux layer

✅ **Phase 4: App Registry Updates**
- Updated `apps.toml` with platform fields for all 82 apps
  - Added `platform = ["macos"]` to GUI apps (ghostty, warp, zed, vscode, browsers, etc.)
  - Added `platform = ["macos", "linux"]` to cross-platform CLI tools (starship, eza, bat, ripgrep, fzf, jq, gh, tmux, yazi, lazygit, node, python, rust, etc.)
  - Added `platform = ["macos"]` to macOS-specific configs (ghostty, zed, sketchybar, aerospace, hammerspoon, raycast, terminal)
  - Added `platform = ["macos", "linux"]` to cross-platform configs (git, zsh, sheldon, starship, mise, tmux, helix, yazi, cheatsheet, keyboard-layout)

✅ **Phase 5: Installer Integration**
- Updated `install.sh`
  - Added platform library loading
  - Added package manager library loading
  - Updated main run flow to detect platform
  - Added platform-aware layer selection (Homebrew for macOS, Linux layer for Linux)

- Updated `scripts/install/layer_homebrew.sh`
  - Added platform check to skip Homebrew layer on Linux

- Updated `scripts/lib/app_config.sh`
  - Added default `APPS_CONFIG` path for library-only usage
  - Added `get_app_platform()` - Gets platform list from apps.toml
  - Added `is_app_supported()` - Checks if app is supported on current platform
  - Added `get_apps_for_profile()` - Gets apps for profile, filtered by platform
  - Added `get_all_installable_apps()` - Gets all installable apps, filtered by platform
  - Added `is_gui_only_app()` - Checks if app is GUI-only

- Updated `scripts/lib/app_state.sh`
  - Added `is_linux_package_installed()` - Checks if Linux package is installed via apt/dnf
  - Updated `is_app_installed()` - Supports Linux package detection

✅ **Phase 6: Testing Infrastructure**
- Created `scripts/test-linux.sh` (258 lines)
  - Tests platform detection
  - Tests package manager availability
  - Tests app filtering by platform
  - Tests apps for profile (hacker)
  - Tests app state detection
  - Tests platform matching function

✅ **Phase 7: Documentation**
- Created `docs/linux-support.md`
  - Supported platforms (macOS, Ubuntu, Debian, Fedora, RHEL/CentOS)
  - Installation guide with quick start
  - Platform detection explanation
  - Platform-specific notes (Linux vs macOS)
  - App registry documentation with platform field usage
  - Troubleshooting guide
  - Platform comparison table
  - Contributing guidelines for adding apps

- Updated `README.md`
  - Updated overview to mention Linux support
  - Updated prerequisites to include Linux requirements
  - Added linux-support.md to documentation map

- Updated `AGENTS.md`
  - Updated overview to mention Linux platform support
  - Added "Linux Platform Support" section
  - Added notes on platform-specific behavior
  - Updated documentation map

---

## Key Decisions

### 1. **Consolidation Strategy**
- **Decision**: Keep macOS repo as primary, add Linux support instead of merging repos
- **Rationale**: macOS repo has superior architecture (layered approach, cleaner code, better documentation)
- **Alternative rejected**: Merging Linux repo into macOS repo (too complex, 1523-line install script)

### 2. **Package Manager Approach**
- **Decision**: Use native apt/dnf on Linux, not Homebrew Linux
- **Rationale**: More "Linux-native", better package availability, simpler maintenance
- **Alternative rejected**: Homebrew Linux (less common, more complexity)

### 3. **GUI App Handling**
- **Decision**: Mark GUI apps as macOS-only (`platform = ["macos"]`) and skip on Linux
- **Rationale**: Linux GUI apps have different installation methods (AppImage, snap, flatpak, native repos)
- **Alternative rejected**: Attempt to install GUI apps via Linux repos (not reliable, many unavailable)

### 4. **Config Protection**
- **Decision**: Do NOT touch `.zshrc` or any configs
- **Rationale**: User's current system is stow-linked, modifying configs could break it
- **Result**: Zero changes to `.zshrc`, `.zshrc.d/`, `.config/`, and all stowed packages

### 5. **Profile Strategy**
- **Decision**: Keep existing 5 profiles (minimal, standard, developer, hacker, server), filter by platform
- **Rationale**: Cleaner architecture, no profile duplication needed
- **Alternative rejected**: Add Linux-specific profiles (unnecessary complexity)

### 6. **App Platform Mapping**
- **Decision**: Use explicit `platform` field in apps.toml, default to all platforms if not specified
- **Rationale**: Backward compatible, clear visibility of platform support
- **Alternative rejected**: Separate apps.toml files per platform (duplication)

---

## Blockers & Issues

### Resolved Issues

1. **Bash 3.2 Syntax Error in package-manager.sh**
   - Issue: Double semicolon `;;` in pm_clean() function
   - Resolution: Removed extra semicolon

2. **Bash Syntax Error in app_config.sh (EOF)**
   - Issue: Unmatched quote in tr command with single quotes
   - Resolution: Rewrote platform parsing using sed instead of problematic tr command

3. **APPS_CONFIG Path Not Set**
   - Issue: Library functions couldn't find apps.toml when sourced directly
   - Resolution: Added default APPS_CONFIG path in app_config.sh

### Outstanding Issues

None explicitly encountered. Implementation is complete and syntax-validated.

---

## Environment State

### Git Status

```
On branch: feature/linux-cross-platform
Changes not staged for commit:
  modified:   AGENTS.md
  modified:   README.md
  modified:   apps.toml
  modified:   install.sh
  modified:   scripts/install/layer_homebrew.sh
  modified:   scripts/lib/app_config.sh
  modified:   scripts/lib/app_state.sh

Untracked files:
  docs/linux-support.md
  scripts/install/layer_linux.sh
  scripts/lib/package-manager.sh
  scripts/lib/platform.sh
  scripts/test-linux.sh
```

### Test Status

- Platform detection: ✅ Working (tested on macOS)
- Package manager abstraction: ✅ Working (syntax validated)
- App filtering: ✅ Working (tested on macOS)
- Test script: ✅ Runs successfully on macOS

### Next Validation Needed

- Test on actual Linux VM (Ubuntu, Debian, Fedora)
- Validate apt/dnf package installation
- Test profile installation (hacker, server profiles recommended for Linux)

---

## Next Steps

### Immediate Actions (Optional)

1. **Review Changes**
   ```bash
   git diff
   ```

2. **Create Commit**
   ```bash
   git add .
   git commit -m "Add Linux cross-platform support"
   ```

3. **Push for Testing**
   ```bash
   git push origin feature/linux-cross-platform
   ```

4. **VM Testing**
   - Set up Ubuntu/Fedora VM
   - Run installer: `cd /path/to/dotfiles && ./install.sh --profile=hacker`
   - Validate package installation
   - Verify configs are stowed correctly

### Future Enhancements (Optional)

1. **AppImage Integration**
   - Add AppImage auto-detection and installation for Linux GUI apps
   - Add to layer_linux.sh

2. **Snap/Flatpak Support**
   - Add snap integration for Ubuntu
   - Add flatpak integration for Fedora/Ubuntu

3. **Linux GUI Apps Layer**
   - Add optional layer for Linux GUI apps (vscode, neovim-qt, etc.)
   - Use native package managers

4. **Distro-Specific Profiles**
   - Add ubuntu.yaml, debian.yaml, fedora.yaml presets
   - Distro-specific optimizations

5. **Rollback Mechanism**
   - Add automated rollback if installation fails
   - Track changes made to revert on failure

---

## Files Modified

### Created Files (5)

1. `scripts/lib/platform.sh` - Platform detection library
2. `scripts/lib/package-manager.sh` - Package manager abstraction
3. `scripts/install/layer_linux.sh` - Linux installation layer
4. `scripts/test-linux.sh` - Linux test suite
5. `docs/linux-support.md` - Linux documentation

### Modified Files (7)

1. `AGENTS.md` - Added Linux platform support notes
2. `README.md` - Updated overview and prerequisites
3. `apps.toml` - Added platform fields to all 82 apps
4. `install.sh` - Added platform detection and layering
5. `scripts/install/layer_homebrew.sh` - Skip on Linux
6. `scripts/lib/app_config.sh` - Added platform filtering functions
7. `scripts/lib/app_state.sh` - Added Linux package detection

### Protected Files (Not Modified)

- `.zshrc` - No changes
- `.zshrc.d/` - No changes
- `.config/` - No changes
- All stowed packages - No changes
- All user configs - No changes

---

## Notes

### Platform Compatibility Matrix

| App Type      | macOS | Linux | Notes                          |
|---------------|--------|--------|---------------------------------|
| Cask (GUI)   | ✅    | ❌     | Skipped on Linux, install manually |
| Brew (CLI)   | ✅    | ✅     | Mapped to apt/dnf on Linux       |
| Mise (tools)  | ✅    | ✅     | Same on both platforms            |
| Stow (config) | ✅    | ✅     | Same on both platforms            |
| Curl (vendor) | ✅    | ✅     | Same on both platforms            |

### Recommended Linux Profiles

- **hacker**: CLI-focused, no GUI apps, perfect for Linux
- **server**: Headless environment, terminal-only
- **minimal**: Essential CLI tools only

### Linux Package Mapping Examples

```
brew: ripgrep      → apt/dnf: ripgrep
brew: fzf          → apt/dnf: fzf
brew: bat          → apt/dnf: bat
brew: eza          → apt/dnf: eza
brew: jq           → apt/dnf: jq
brew: gh           → apt/dnf: gh
brew: lazygit      → apt/dnf: lazygit
brew: tmux         → apt/dnf: tmux
brew: yazi         → apt/dnf: yazi
```

---

## Resume Instructions

To continue this session:

1. **Read this session file** to understand current state
2. **Checkout branch**: `git checkout feature/linux-cross-platform`
3. **Review changes**: `git status` and `git diff`
4. **Decide next action**:
   - Test on Linux VM (recommended)
   - Commit and push changes
   - Implement future enhancements

### Quick Resume Commands

```bash
# View changes
git diff

# Run test suite
./scripts/test-linux.sh

# Interactive install (dry-run for validation)
./install.sh --profile=hacker --dry-run

# Create commit
git add .
git commit -m "Add Linux cross-platform support"

# Push for testing
git push origin feature/linux-cross-platform
```

---

**Session Status**: Implementation complete, ready for validation and testing
