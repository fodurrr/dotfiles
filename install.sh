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
# Logging Functions (colored output)
# =============================================================================
# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "   ${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "   ${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "   ${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "   ${RED}✗${NC} $1"
}

# =============================================================================
# Global Configuration
# =============================================================================
IGNORE_LIST=(
    ".git"
    ".DS_Store"
    ".gitkeep"
    "install.sh"
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
            profile_value="${1#*=}"
            echo "[DEBUG] Raw arg: '$1' -> extracted: '$profile_value'"
            SELECTED_PROFILES+=("$profile_value")
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

# Get available profiles from apps.toml in preferred order
get_profiles() {
    # Extract all unique profiles
    local all_profiles=$(grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u)

    # Output in preferred order: minimal, standard, developer, then others
    for preferred in minimal standard developer; do
        echo "$all_profiles" | grep -x "$preferred" 2>/dev/null || true
    done
    # Then any others not in the preferred list
    echo "$all_profiles" | grep -vxE "minimal|standard|developer" 2>/dev/null || true
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
        # Use gum for interactive selection (minimal pre-selected)
        while IFS= read -r line; do
            [[ -n "$line" ]] && SELECTED_PROFILES+=("$line")
        done < <(gum choose --no-limit \
            --header "Which profiles do you want to install? (SPACE to toggle, ENTER to confirm)" \
            --cursor-prefix "[ ] " \
            --selected-prefix "[x] " \
            --selected="minimal" \
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
        echo "No profiles selected. Using default: minimal"
        SELECTED_PROFILES=("minimal")
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

# Default to minimal if nothing selected
if [[ ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
    SELECTED_PROFILES=("minimal")
fi

echo ""
echo "[DEBUG] Final SELECTED_PROFILES array:"
for i in "${!SELECTED_PROFILES[@]}"; do
    echo "[DEBUG]   [$i] = '${SELECTED_PROFILES[$i]}' (hex: $(echo -n "${SELECTED_PROFILES[$i]}" | xxd -p))"
done
echo "Installing for profiles: ${SELECTED_PROFILES[*]}"

# =============================================================================
# Helper Functions
# =============================================================================

# Check if app belongs to ANY selected profile
app_in_profile() {
    local app_key="$1"
    local profiles
    profiles=$(yq -p toml -oy ".apps.\"$app_key\".profiles" "$APPS_CONFIG" 2>/dev/null || echo "")
    for profile in "${SELECTED_PROFILES[@]}"; do
        if echo "$profiles" | grep -q "$profile"; then
            return 0
        fi
    done
    return 1
}

# Get app property (returns empty string if property doesn't exist)
get_app_prop() {
    local app_key="$1"
    local prop="$2"
    local result
    result=$(yq -p toml -oy ".apps.\"$app_key\".$prop" "$APPS_CONFIG" 2>/dev/null || echo "")
    # yq returns literal "null" for missing properties, convert to empty string
    [[ "$result" == "null" ]] && result=""
    echo "$result"
}

# Get all app keys (extract [apps.X] sections)
get_all_apps() {
    grep -oE '^\[apps\.[^]]+\]' "$APPS_CONFIG" | sed 's/\[apps\.//;s/\]//'
}

# Track installed apps to avoid duplicates (for dependency resolution)
# Using string-based tracking for bash 3.2 compatibility (macOS default)
INSTALLED_APPS=""

# Install a mise app with dependency resolution
install_mise_app() {
    local app_key="$1"

    # Skip if already processed this session (pipe delimiters prevent partial matches)
    [[ "$INSTALLED_APPS" == *"|$app_key|"* ]] && return 0

    # Check for dependency
    local dep=$(get_app_prop "$app_key" "depends_on")
    if [[ -n "$dep" ]]; then
        log_info "$app_key requires $dep (dependency)"
        install_mise_app "$dep"
    fi

    # Mark as processed
    INSTALLED_APPS="${INSTALLED_APPS}|${app_key}|"

    # Get app details
    local name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"
    local version=$(get_app_prop "$app_key" "version")
    [[ -z "$version" ]] && version="latest"

    # Check if already installed with correct version
    local installed_version=$(mise list "$name" 2>/dev/null | awk '{print $2}' | head -1)

    if [[ -n "$installed_version" ]]; then
        if [[ "$version" == "latest" ]]; then
            # For "latest", check if there's a newer version available
            local latest_version=$(mise latest "$name" 2>/dev/null)
            if [[ "$installed_version" == "$latest_version" ]]; then
                log_info "$name@$installed_version already installed, skipping"
                return 0
            else
                log_info "$name@$installed_version outdated (latest: $latest_version), upgrading..."
            fi
        elif [[ "$installed_version" == "$version" ]]; then
            log_info "$name@$version already installed, skipping"
            return 0
        else
            log_info "$name@$installed_version installed, but $version requested, installing..."
        fi
    else
        log_success "Installing $name@$version..."
    fi

    mise install "$name@$version" 2>/dev/null || log_warning "Failed to install $name"
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
echo "[DEBUG] SELECTED_PROFILES: ${SELECTED_PROFILES[*]}"
for app_key in $(get_all_apps); do
    type=$(get_app_prop "$app_key" "type")
    if [[ "$type" == "cask" ]]; then
        echo "[DEBUG] Checking cask: $app_key"
        if app_in_profile "$app_key"; then
            name=$(get_app_prop "$app_key" "name")
            [[ -z "$name" ]] && name="$app_key"

            # Check if already installed
            if brew list --cask 2>/dev/null | grep -q "^${name}$"; then
                # Check if outdated
                if brew outdated --cask 2>/dev/null | grep -q "^${name}"; then
                    log_info "$name outdated, upgrading..."
                    brew upgrade --cask "$name" || log_warning "Failed to upgrade $name"
                else
                    log_info "$name already installed, skipping"
                fi
            else
                log_success "Installing $name..."
                brew install --cask "$name" || log_error "Failed to install $name"
            fi
        else
            echo "[DEBUG]   SKIPPED - not in profile"
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

            # Check if already installed
            if brew list 2>/dev/null | grep -q "^${name}$"; then
                # Check if outdated
                if brew outdated 2>/dev/null | grep -q "^${name}"; then
                    log_info "$name outdated, upgrading..."
                    brew upgrade "$name" || log_warning "Failed to upgrade $name"
                else
                    log_info "$name already installed, skipping"
                fi
            else
                log_success "Installing $name..."
                brew install "$name" || log_error "Failed to install $name"
            fi
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Cleaning up unlisted Homebrew packages..."

    # Generate temporary Brewfile from apps.toml for selected profiles
    TEMP_BREWFILE=$(mktemp)

    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            type=$(get_app_prop "$app_key" "type")
            name=$(get_app_prop "$app_key" "name")
            [[ -z "$name" ]] && name="$app_key"
            tap=$(get_app_prop "$app_key" "tap")

            case "$type" in
                cask)
                    [[ -n "$tap" ]] && echo "tap \"$tap\"" >> "$TEMP_BREWFILE"
                    echo "cask \"$name\"" >> "$TEMP_BREWFILE"
                    ;;
                brew)
                    echo "brew \"$name\"" >> "$TEMP_BREWFILE"
                    ;;
            esac
        fi
    done

    # Add bootstrap packages (always keep these)
    cat "$DOTFILES_DIR/Brewfile.bootstrap" >> "$TEMP_BREWFILE"

    # Run cleanup (removes packages not in the generated Brewfile)
    echo "   Packages to remove:"
    brew bundle cleanup --file="$TEMP_BREWFILE" || true

    read -p "   Remove these packages? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew bundle cleanup --force --file="$TEMP_BREWFILE" || true
    fi

    rm "$TEMP_BREWFILE"
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
                log_success "Linking $package config..."
                stow_enforce "$package"
            fi
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Removing stow packages not in selected profiles..."

    for app_key in $(get_all_apps); do
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "stow" ]]; then
            if ! app_in_profile "$app_key"; then
                package=$(get_app_prop "$app_key" "package")
                if [[ -d "$DOTFILES_DIR/$package" ]]; then
                    log_warning "Unlinking $package config..."
                    stow -D "$package" 2>/dev/null || true
                fi
            fi
        fi
    done
fi

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
            install_mise_app "$app_key"
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Cleaning up mise tools not in selected profiles..."

    # Build list of tools that SHOULD be installed
    WANTED_TOOLS=()
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "mise" ]]; then
                name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"
                WANTED_TOOLS+=("$name")
            fi
        fi
    done

    # Get currently installed tools
    INSTALLED_TOOLS=$(mise list --current 2>/dev/null | awk '{print $1}' | sort -u)

    # Remove tools not in the wanted list
    for tool in $INSTALLED_TOOLS; do
        if ! printf '%s\n' "${WANTED_TOOLS[@]}" | grep -qx "$tool"; then
            echo "   Removing: $tool"
            mise uninstall "$tool" --all 2>/dev/null || true
        fi
    done

    # Prune old versions
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
            case "$app_key" in
                claude-cli)
                    if command -v claude &> /dev/null; then
                        log_info "claude-cli already installed, skipping"
                    else
                        log_success "Installing claude-cli..."
                        curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null || log_warning "Failed to install claude-cli"
                    fi
                    ;;
                opencode-cli)
                    if command -v opencode &> /dev/null; then
                        log_info "opencode-cli already installed, skipping"
                    else
                        log_success "Installing opencode-cli..."
                        curl -fsSL https://opencode.ai/install.sh | bash 2>/dev/null || log_warning "Failed to install opencode-cli"
                    fi
                    ;;
                *)
                    log_warning "Unknown curl installer: $app_key"
                    ;;
            esac
        fi
    fi
done

if [[ "$CURL_TOOLS_FOUND" == false ]]; then
    log_info "No curl-based tools in selected profiles"
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
