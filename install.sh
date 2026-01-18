#!/bin/bash

# =============================================================================
# 🛡️ THE ENFORCER: Link with Backup Logic
# =============================================================================
# Usage: stow_enforce "folder_name"
# Description: Checks if a REAL file exists at the target. 
#              If yes, backs it up. Then runs stow.
stow_enforce() {
    local package="$1"
    local target_home="$HOME"

    # 1. Find every file that Stow WANTS to link
    #    (Looks inside dotfiles/zsh, dotfiles/git, etc.)
    find "$package" -type f \( -name ".DS_Store" -o -name ".gitkeep" \) -prune -o -type f -print | while read source_file; do
        
        # 2. Calculate where it SHOULD go
        #    Strip the package name to get relative path (e.g., "zsh/.zshrc" -> ".zshrc")
        local relative_path="${source_file#$package/}"
        local target_path="$target_home/$relative_path"
        
        # 3. Check for Conflict
        if [ -e "$target_path" ]; then
            if [ -L "$target_path" ]; then
                # It's already a symlink. We assume it's fine (Stow handles restowing).
                continue
            else
                # 🛑 CONFLICT DETECTED: It is a REAL file, not a link.
                echo "      ⚠️  Conflict: Real file found at ~/$relative_path"
                echo "      🛡️  Enforcing Source of Truth: Backing up and overriding..."
                
                # Move the real file to a backup
                mv "$target_path" "${target_path}.backup.$(date +%s)"
            fi
        fi
    done

    # 4. Now that conflicts are moved, Stow can link safely
    stow --restow --target="$HOME" "$package"
}

# =============================================================================
# 1. Install Homebrew
# =============================================================================
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# =============================================================================
# 2. Install Apps (Standard vs Strict Mode)
# =============================================================================
echo "📦 Installing Apps from Brewfile..."
brew bundle --file=~/dotfiles/Brewfile

# CHECK FOR CLEAN FLAG
if [[ "$1" == "--clean" ]]; then
    echo "🧹 STRICT MODE: Cleaning up unlisted apps..."
    # Force cleanup of anything not in the Brewfile
    brew bundle cleanup --force --file=~/dotfiles/Brewfile

    # Optional: Prune old Mise versions
    echo "🧹 Pruning old Mise runtimes..."
    mise prune -y
else
    echo "ℹ️  Skipping cleanup. (Run with --clean to uninstall undefined apps)"
fi

# =============================================================================
# 3. Initialize Zinit
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo "⚡ Installing Zinit..."
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# =============================================================================
# 4. Smart Stow Loop (Source of Truth Mode)
# =============================================================================
echo "🔗 Stowing dotfiles..."
cd ~/dotfiles

IGNORE_LIST=(
    ".git"
    ".DS_Store"
    "install.sh"
    "Brewfile"
    "README.md"
    "LICENSE"
    ".gitignore"
)

for folder in */; do
    package_name="${folder%/}"
    
    # Check if package is in the ignore list
    # (Surrounding spaces allow exact matching)
    if [[ " ${IGNORE_LIST[*]} " =~ " ${package_name} " ]]; then
        continue
    fi

    echo "   → Checking: $package_name"
    stow_enforce "$package_name"
done

# =============================================================================
# 5. Install Runtimes via Mise
# =============================================================================
echo "🛠️ Installing Dev Runtimes..."
mise install

# =============================================================================
# 6. Reload Shell
# =============================================================================
echo "✅ Done!"
echo "Press [ENTER] to reload the shell..."
read
exec zsh -l
