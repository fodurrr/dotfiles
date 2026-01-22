#!/bin/bash
set -e

# =============================================================================
# Dotfiles Installation Script - Two-Phase Architecture
# =============================================================================
# Phase 1: Bootstrap - Install infrastructure (runs for ALL profiles)
# Phase 2: Profile  - Install apps based on selected profile(s)
#
# Usage:
#   ./install.sh                          # Interactive mode
#   ./install.sh --profile=developer      # Non-interactive, single profile
#   ./install.sh -p dev -p devops         # Merge multiple profiles
#   ./install.sh --list-profiles          # Show available profiles
#   ./install.sh --clean                  # Strict cleanup mode
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================
SELECTED_PROFILES=()
CLEAN_MODE=false
INTERACTIVE=true
DOTFILES_DIR=~/dotfiles
APPS_CONFIG="$DOTFILES_DIR/apps.toml"

# =============================================================================
# Error Handler
# =============================================================================
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Installation failed. Check the errors above."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Press [ENTER] to reload the shell anyway..."
        read
        exec zsh -l
    fi
}
trap cleanup EXIT

# =============================================================================
# Global Configuration
# =============================================================================
IGNORE_LIST=(
    ".git"
    ".DS_Store"
    ".gitkeep"
    "install.sh"
    "Brewfile"
    "Brewfile.bootstrap"
    "apps.toml"
    "README.md"
    "CLAUDE.md"
    "LICENSE"
    ".gitignore"
    "scripts"
    "docs"
)

# =============================================================================
# The Enforcer: Link with Backup Logic
# =============================================================================
stow_enforce() {
    local package="$1"
    local target_home="$HOME"

    # Build Ignore Flags for Stow
    local stow_opts=()
    for ignore_item in "${IGNORE_LIST[@]}"; do
        stow_opts+=("--ignore=$ignore_item")
    done
    stow_opts+=("--ignore=\.bak$")

    # Find Files and backup conflicts
    find "$package" -type f \( -name ".DS_Store" -o -name ".gitkeep" -o -name "*.bak" \) -prune -o -type f -print 2>/dev/null | while read source_file; do
        local relative_path="${source_file#$package/}"
        local target_path="$target_home/$relative_path"

        if [ -e "$target_path" ]; then
            if [ -L "$target_path" ]; then
                continue
            fi
            resolved_path="$(cd "$(dirname "$target_path")" 2>/dev/null && pwd -P)/$(basename "$target_path")"
            if [[ "$resolved_path" == "$PWD"/* ]]; then
                continue
            fi
            echo "      Backing up: ~/$relative_path"
            mv "$target_path" "${target_path}.bak"
        fi
    done

    # Create Links
    stow --restow --target="$HOME" "${stow_opts[@]}" "$package" 2>/dev/null || true
}

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile=*)
            SELECTED_PROFILES+=("${1#*=}")
            INTERACTIVE=false
            shift
            ;;
        -p)
            SELECTED_PROFILES+=("$2")
            INTERACTIVE=false
            shift 2
            ;;
        --clean)
            CLEAN_MODE=true
            shift
            ;;
        --yes|-y)
            INTERACTIVE=false
            shift
            ;;
        --list-profiles)
            # Can't list profiles before bootstrap, just show message
            echo "Run bootstrap first, then use --list-profiles"
            echo "Or check apps.toml for available profiles"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# =============================================================================
# PHASE 1: BOOTSTRAP (runs first, unconditionally)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 1: Bootstrap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup Homebrew environment
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    echo "Error: Homebrew not found after installation"
    exit 1
fi

# Install infrastructure packages
echo "Installing infrastructure packages..."
echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"
if ! brew bundle --file="$DOTFILES_DIR/Brewfile.bootstrap"; then
    echo "Error: brew bundle failed"
    exit 1
fi

# =============================================================================
# PHASE 2: PROFILE SELECTION
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 2: Profile Selection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get available profiles from apps.toml (using grep for portability)
get_profiles() {
    grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u
}

# Interactive profile selection
if [[ "$INTERACTIVE" == true && ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
    echo ""
    echo "Select one or more profiles (SPACE to select, ENTER to confirm):"
    echo ""

    # Get profiles into array (compatible with bash 3.x)
    AVAILABLE_PROFILES=()
    while IFS= read -r line; do
        AVAILABLE_PROFILES+=("$line")
    done < <(get_profiles)

    if command -v gum &> /dev/null; then
        # Use gum for interactive selection
        while IFS= read -r line; do
            [[ -n "$line" ]] && SELECTED_PROFILES+=("$line")
        done < <(gum choose --no-limit \
            --header "Which profiles do you want to install?" \
            --cursor-prefix "[ ] " \
            --selected-prefix "[x] " \
            "${AVAILABLE_PROFILES[@]}")
    else
        # Fallback to simple select
        echo "Available profiles:"
        select profile in "${AVAILABLE_PROFILES[@]}" "Done"; do
            if [[ "$profile" == "Done" ]]; then
                break
            fi
            SELECTED_PROFILES+=("$profile")
            echo "Selected: ${SELECTED_PROFILES[*]}"
        done
    fi

    if [[ ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
        echo "No profiles selected. Using default: standard"
        SELECTED_PROFILES=("standard")
    fi

    # Show summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Selected profiles: ${SELECTED_PROFILES[*]}"
    echo ""

    # Confirm
    if command -v gum &> /dev/null; then
        gum confirm "Proceed with installation?" || exit 0
    else
        read -p "Proceed? (y/n) " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    fi
fi

# Default to standard if nothing selected
if [[ ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
    SELECTED_PROFILES=("standard")
fi

echo ""
echo "Installing for profiles: ${SELECTED_PROFILES[*]}"

# =============================================================================
# Helper Functions
# =============================================================================

# Check if app belongs to ANY selected profile
app_in_profile() {
    local app_key="$1"
    local profiles
    profiles=$(cat "$APPS_CONFIG" | dasel -i toml "apps.$app_key.profiles" 2>/dev/null || echo "")
    for profile in "${SELECTED_PROFILES[@]}"; do
        if echo "$profiles" | grep -q "$profile"; then
            return 0
        fi
    done
    return 1
}

# Get app property
get_app_prop() {
    local app_key="$1"
    local prop="$2"
    local result
    result=$(cat "$APPS_CONFIG" | dasel -i toml "apps.$app_key.$prop" 2>/dev/null || echo "")
    # Remove quotes if present
    echo "$result" | tr -d "'"
}

# Get all app keys (extract [apps.X] sections)
get_all_apps() {
    grep -oE '^\[apps\.[^]]+\]' "$APPS_CONFIG" | sed 's/\[apps\.//;s/\]//' | sort -u
}

# =============================================================================
# Layer 1: Homebrew (casks and brews from apps.toml)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 1: Homebrew"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Collect and add taps
echo "Adding taps..."
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        tap=$(get_app_prop "$app_key" "tap")
        if [[ -n "$tap" ]]; then
            echo "   Tapping: $tap"
            brew tap "$tap" 2>/dev/null || true
        fi
    fi
done

# Install casks
echo "Installing casks..."
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "cask" ]]; then
            name=$(get_app_prop "$app_key" "name")
            [[ -z "$name" ]] && name="$app_key"
            echo "   Installing: $name"
            brew install --cask "$name" 2>/dev/null || true
        fi
    fi
done

# Install brews
echo "Installing brews..."
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "brew" ]]; then
            name=$(get_app_prop "$app_key" "name")
            [[ -z "$name" ]] && name="$app_key"
            echo "   Installing: $name"
            brew install "$name" 2>/dev/null || true
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Cleaning up unlisted Homebrew packages..."
    # Note: Can't use brew bundle cleanup with apps.toml directly
    # Would need to generate a Brewfile from apps.toml first
fi

# =============================================================================
# Layer 2: Stow (configs from apps.toml)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 2: Stow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$DOTFILES_DIR"

for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "stow" ]]; then
            package=$(get_app_prop "$app_key" "package")
            if [[ -d "$package" ]]; then
                echo "   Stowing: $package"
                stow_enforce "$package"
            fi
        fi
    fi
done

# =============================================================================
# Layer 3: Mise (tools from apps.toml)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 3: Mise"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Installing mise tools..."
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "mise" ]]; then
            name=$(get_app_prop "$app_key" "name")
            [[ -z "$name" ]] && name="$app_key"
            version=$(get_app_prop "$app_key" "version")
            [[ -z "$version" ]] && version="latest"
            echo "   Installing: $name@$version"
            mise install "$name@$version" 2>/dev/null || echo "      Warning: failed to install $name"
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Pruning old mise runtimes..."
    mise prune -y
fi

# =============================================================================
# Layer 5: Curl installers
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 5: AI Coding Tools (curl)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CURL_TOOLS_FOUND=false
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "curl" ]]; then
            CURL_TOOLS_FOUND=true
            echo "   Installing: $app_key"
            case "$app_key" in
                claude-cli)
                    curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null || echo "      Warning: claude-cli install failed"
                    ;;
                opencode-cli)
                    curl -fsSL https://opencode.ai/install.sh | bash 2>/dev/null || echo "      Warning: opencode-cli install failed"
                    ;;
                *)
                    echo "      Unknown curl installer: $app_key"
                    ;;
            esac
        fi
    fi
done

if [[ "$CURL_TOOLS_FOUND" == false ]]; then
    echo "   No curl-based tools in selected profiles"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation Complete!"
echo "  Profiles: ${SELECTED_PROFILES[*]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Press [ENTER] to reload the shell..."
read
exec zsh -l
