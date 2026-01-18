#!/bin/bash
set -e

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
    "LICENSE"
    ".gitignore"
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
            if [ -L "$target_path" ]; then
                continue # It's a link, we are good.
            else
                # 🛑 REAL FILE FOUND in HOME.
                echo "      ⚠️  Conflict: Real file found at ~/$relative_path"
                echo "      🛡️  Backing it up to ~/$relative_path.bak"

                # Backup: Rename the file in place
                mv -v "$target_path" "${target_path}.bak"
            fi
        fi
    done

    # 3. Create Links
    stow --restow --target="$HOME" "${stow_opts[@]}" "$package"
}

# =============================================================================
# 1. Install Homebrew
# =============================================================================
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

# =============================================================================
# 2. Install Apps (Includes Sheldon via Brewfile)
# =============================================================================
echo "📦 Installing Apps..."
if ! brew bundle --file=~/dotfiles/Brewfile; then
    echo "❌ Error: brew bundle failed"
    exit 1
fi

if [[ "$1" == "--clean" ]]; then
    echo "🧹 STRICT MODE: Cleaning up unlisted apps..."
    brew bundle cleanup --force --file=~/dotfiles/Brewfile
    echo "🧹 Pruning old Mise runtimes..."
    mise prune -y
fi

# =============================================================================
# 3. Smart Stow Loop (Source of Truth Mode)
# =============================================================================
echo "🔗 Stowing dotfiles..."
cd ~/dotfiles

for folder in */; do
    package_name="${folder%/}"

    # Check if package is in the global IGNORE_LIST
    # (Surrounding spaces allow exact matching)
    if [[ " ${IGNORE_LIST[*]} " =~ " ${package_name} " ]]; then
        continue
    fi

    echo "   → Checking: $package_name"
    stow_enforce "$package_name"
done

# =============================================================================
# 4. Final Setup
# =============================================================================
echo "🛠️ Installing Runtimes..."
if ! mise install; then
    echo "❌ Error: mise install failed"
    exit 1
fi

echo "✅ Done! Reloading..."
echo "Press [ENTER] to reload the shell..."
read
exec zsh -l
