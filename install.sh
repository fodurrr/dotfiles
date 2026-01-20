#!/bin/bash
set -e

# =============================================================================
# Dotfiles Installation Script
# =============================================================================
# This script orchestrates the 5-layer installation model:
#   Layer 1: Homebrew (system tools + GUI apps)
#   Layer 2: Stow (config deployment via symlinks)
#   Layer 3: Mise (language runtimes + CLI tools)
#   Layer 4: Mac App Store (optional, manual)
#   Layer 5: Curl scripts (bleeding-edge AI coding tools)
# =============================================================================

# =============================================================================
# 0. Global Configuration
# =============================================================================
IGNORE_LIST=(
    ".git"
    ".DS_Store"
    ".gitkeep"
    "install.sh"
    "Brewfile"
    "README.md"
    "CLAUDE.md"
    "LICENSE"
    ".gitignore"
    "scripts"  # Layer 5 scripts - not a stow package
)

# =============================================================================
# 🛡️ THE ENFORCER: Link with Backup Logic
# =============================================================================
stow_enforce() {
    local package="$1"
    local target_home="$HOME"

    # 1. Build Ignore Flags for Stow
    local stow_opts=()
    for ignore_item in "${IGNORE_LIST[@]}"; do
        stow_opts+=("--ignore=$ignore_item")
    done
    # 🔥 SAFETY: Tell Stow to NEVER link .bak files
    stow_opts+=("--ignore=\.bak$")

    # 2. Find Files (STRICT PRUNE MODE)
    #    We exclude .bak files here so the loop NEVER runs for them.
    find "$package" -type f \( -name ".DS_Store" -o -name ".gitkeep" -o -name "*.bak" \) -prune -o -type f -print | while read source_file; do

        local relative_path="${source_file#$package/}"
        local target_path="$target_home/$relative_path"

        # Check for Conflict
        if [ -e "$target_path" ]; then
            # Skip if target is a file-level symlink
            if [ -L "$target_path" ]; then
                continue
            fi

            # Skip if resolved path is inside dotfiles (stow tree folding)
            # This happens when stow created a directory-level symlink
            resolved_path="$(cd "$(dirname "$target_path")" 2>/dev/null && pwd -P)/$(basename "$target_path")"
            if [[ "$resolved_path" == "$PWD"/* ]]; then
                continue  # Already linked via parent directory symlink
            fi

            # 🛑 REAL FILE FOUND in HOME - back it up
            echo "      ⚠️  Conflict: Real file found at ~/$relative_path"
            echo "      🛡️  Backing it up to ~/$relative_path.bak"
            mv -v "$target_path" "${target_path}.bak"
        fi
    done

    # 3. Create Links
    stow --restow --target="$HOME" "${stow_opts[@]}" "$package"
}

# =============================================================================
# Layer 1: Homebrew (System Infrastructure + GUI Apps)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 1: Homebrew"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup Homebrew environment (works on both Apple Silicon and Intel Macs)
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    echo "❌ Error: Homebrew not found after installation"
    exit 1
fi

echo "📦 Installing Homebrew packages..."
if ! brew bundle --file=~/dotfiles/Brewfile; then
    echo "❌ Error: brew bundle failed"
    exit 1
fi

if [[ "$1" == "--clean" ]]; then
    echo "🧹 STRICT MODE: Cleaning up unlisted Homebrew packages..."
    brew bundle cleanup --force --file=~/dotfiles/Brewfile
fi

# =============================================================================
# Layer 2: Stow (Config Deployment)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 2: Stow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔗 Stowing dotfiles..."
cd ~/dotfiles

for folder in */; do
    package_name="${folder%/}"

    # Check if package is in the global IGNORE_LIST
    # (Surrounding spaces allow exact matching)
    if [[ " ${IGNORE_LIST[*]} " =~ " ${package_name} " ]]; then
        continue
    fi

    echo "   → Stowing: $package_name"
    stow_enforce "$package_name"
done

# =============================================================================
# Layer 3: Mise (Runtimes + CLI Tools)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 3: Mise"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🛠️  Installing runtimes and CLI tools..."
if ! mise install; then
    echo "❌ Error: mise install failed"
    exit 1
fi

if [[ "$1" == "--clean" ]]; then
    echo "🧹 STRICT MODE: Pruning old Mise runtimes..."
    mise prune -y
fi

# =============================================================================
# Layer 5: Curl Scripts (AI Coding Tools)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 5: AI Coding Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🤖 Installing AI coding tools (bleeding edge)..."
if [ -f ~/dotfiles/scripts/curl-installs.sh ]; then
    bash ~/dotfiles/scripts/curl-installs.sh
else
    echo "   ⚠️  scripts/curl-installs.sh not found, skipping Layer 5"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Press [ENTER] to reload the shell..."
read
exec zsh -l
