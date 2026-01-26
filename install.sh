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
#   ./install.sh --extras                 # Install extra apps interactively
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================
SELECTED_PROFILES=()
CLEAN_MODE=false
INTERACTIVE=true
EXTRAS_MODE=false
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_CONFIG="$DOTFILES_DIR/apps.toml"

# Installation tracking for summary (newline+pipe delimited: "name|description\nname|description")
SUMMARY_INSTALLED=""
SUMMARY_SKIPPED=""
SUMMARY_REMOVED=""

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

    # Build Ignore Flags for Stow
    local stow_opts=()
    for ignore_item in "${IGNORE_LIST[@]}"; do
        stow_opts+=("--ignore=$ignore_item")
    done
    stow_opts+=("--ignore=\.bak$")

    # Back up .config/* subdirectories that would conflict with stow
    for top_dir in "$package"/.config/*/; do
        if [[ -d "$top_dir" ]]; then
            local dir_name
            dir_name="${top_dir#$package/.config/}"
            dir_name="${dir_name%/}"
            local target_path="$HOME/.config/$dir_name"

            # If target is a real directory (not symlink), back it up
            if [[ -d "$target_path" && ! -L "$target_path" ]]; then
                echo "      Backing up: $target_path"
                mv "$target_path" "${target_path}.bak"
            fi
        fi
    done

    # Back up home directory dotfiles (e.g., .gitconfig, .zshrc)
    # Skip .config - it's handled above
    for top_file in "$package"/.[!.]*; do
        if [[ -e "$top_file" ]]; then
            local file_name="${top_file##*/}"
            # Skip .config directory - handled by the loop above
            [[ "$file_name" == ".config" ]] && continue

            local target_path="$HOME/$file_name"

            # If target exists and is not a symlink, back it up
            if [[ -e "$target_path" && ! -L "$target_path" ]]; then
                echo "      Backing up: $target_path"
                mv "$target_path" "${target_path}.bak"
            fi
        fi
    done

    # Create Links - stow will succeed now that conflicts are backed up
    local stow_output
    if ! stow_output=$(stow --restow --target="$HOME" "${stow_opts[@]}" "$package" 2>&1); then
        log_error "Failed to link $package"
        echo "$stow_output" | head -3 | sed 's/^/      /'
        return 1
    fi
}

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile=*)
            profile_value="${1#*=}"
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
        --extras)
            EXTRAS_MODE=true
            shift
            ;;
        --list-profiles)
            # Check if yq is available (installed during bootstrap)
            if command -v yq &> /dev/null && [[ -f "$APPS_CONFIG" ]]; then
                echo "Available profiles:"
                echo ""
                # Extract unique profiles from apps.toml
                grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u | while read -r profile; do
                    # Count apps in this profile
                    count=$(grep -c "\"$profile\"" "$APPS_CONFIG" 2>/dev/null || echo "0")
                    printf "  %-12s (%d apps)\n" "$profile" "$count"
                done
            else
                echo "Run bootstrap first (./install.sh), then use --list-profiles"
                echo "Or check apps.toml for available profiles"
            fi
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

# Install TPM (Tmux Plugin Manager) if not present
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log_success "TPM installed. After tmux starts, press Ctrl+A then Shift+I to install plugins."
else
    log_info "TPM already installed"
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

    # Output in preferred order: minimal, standard, developer, hacker, server, then others
    for preferred in minimal standard developer hacker server; do
        echo "$all_profiles" | grep -x "$preferred" 2>/dev/null || true
    done
    # Then any others not in the preferred list
    echo "$all_profiles" | grep -vxE "minimal|standard|developer|hacker|server" 2>/dev/null || true
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

    # Add extras option at the end
    AVAILABLE_PROFILES+=("➕ Install individual apps")

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

    # Check if user selected "Install individual apps"
    if [[ " ${SELECTED_PROFILES[*]} " == *"➕ Install individual apps"* ]]; then
        EXTRAS_MODE=true
        SELECTED_PROFILES=()  # Clear - not installing profiles
    fi

    if [[ ${#SELECTED_PROFILES[@]} -eq 0 && "$EXTRAS_MODE" != true ]]; then
        echo "No profiles selected. Using default: minimal"
        SELECTED_PROFILES=("minimal")
    fi

    # Show summary (skip for extras mode)
    if [[ "$EXTRAS_MODE" != true ]]; then
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
fi

# Default to minimal if nothing selected (skip for extras mode)
if [[ ${#SELECTED_PROFILES[@]} -eq 0 && "$EXTRAS_MODE" != true ]]; then
    SELECTED_PROFILES=("minimal")
fi

# =============================================================================
# Logging Setup (after interactive prompts, before installation)
# =============================================================================
LOG_FILE="$DOTFILES_DIR/install.log"

# Initialize log file with header
{
    echo "================================================================================"
    echo "Dotfiles Installation Log"
    echo "================================================================================"
    echo "Date:     $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host:     $(hostname)"
    echo "User:     $(whoami)"
    echo "Profiles: ${SELECTED_PROFILES[*]}"
    echo "Clean:    $CLEAN_MODE"
    echo "================================================================================"
    echo ""
} > "$LOG_FILE"

# Duplicate all output to log file (append mode)
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ "$EXTRAS_MODE" != true ]]; then
    echo ""
    echo "Installing for profiles: ${SELECTED_PROFILES[*]}"
fi

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

# Get the .app name for a cask (checks /Applications for non-Homebrew installs)
get_cask_app_name() {
    local cask="$1"
    local app_name=""
    local json=$(brew info --cask --json=v2 "$cask" 2>/dev/null)

    # Try 1: Get from app artifact (direct .app downloads)
    app_name=$(echo "$json" | yq -r '.casks[0].artifacts[] | select(has("app")) | .app[0]' 2>/dev/null | head -1)
    if [[ -n "$app_name" ]] && [[ "$app_name" != "null" ]]; then
        echo "$app_name"
        return
    fi

    # Try 2: Get from uninstall.delete (pkg-based casks like OneDrive)
    app_name=$(echo "$json" | yq -r '.casks[0].artifacts[].uninstall[].delete[]?' 2>/dev/null | grep -m1 '/Applications/.*\.app$' | sed 's|/Applications/||')
    if [[ -n "$app_name" ]]; then
        echo "$app_name"
        return
    fi

    # Try 3: Use cask display name + .app (fallback)
    app_name=$(echo "$json" | yq -r '.casks[0].name[0]' 2>/dev/null)
    if [[ -n "$app_name" ]] && [[ "$app_name" != "null" ]]; then
        echo "${app_name}.app"
        return
    fi
}

# Check if an app is currently installed
is_app_installed() {
    local app_key="$1"
    local type=$(get_app_prop "$app_key" "type")
    local name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"

    case "$type" in
        cask)
            # Check if installed via Homebrew
            if brew list --cask 2>/dev/null | grep -q "^${name}$"; then
                return 0
            fi
            # Check if app exists in /Applications (installed by other means)
            local app_name=$(get_cask_app_name "$name")
            if [[ -n "$app_name" ]] && [[ -d "/Applications/$app_name" ]]; then
                return 0
            fi
            return 1
            ;;
        brew)
            brew list 2>/dev/null | grep -q "^${name}$"
            ;;
        mise)
            local status=$(mise list "$name" 2>/dev/null | head -1)
            [[ -n "$status" ]] && [[ "$status" != *"(missing)"* ]]
            ;;
        curl)
            case "$app_key" in
                claude-cli) command -v claude &>/dev/null ;;
                opencode-cli) command -v opencode &>/dev/null ;;
                *) return 1 ;;
            esac
            ;;
        stow)
            # Stow packages are always "installable" - skip them in extras
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Add entry to summary list (newline+pipe delimited format)
add_to_summary() {
    local list_type="$1"
    local name="$2"
    local app_key="$3"

    local desc=$(get_app_prop "$app_key" "description")
    [[ -z "$desc" ]] && desc="-"

    local record="${name}|${desc}"

    case "$list_type" in
        INSTALLED)
            [[ -z "$SUMMARY_INSTALLED" ]] && SUMMARY_INSTALLED="$record" || SUMMARY_INSTALLED="${SUMMARY_INSTALLED}
${record}"
            ;;
        SKIPPED)
            [[ -z "$SUMMARY_SKIPPED" ]] && SUMMARY_SKIPPED="$record" || SUMMARY_SKIPPED="${SUMMARY_SKIPPED}
${record}"
            ;;
        REMOVED)
            [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="$record" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${record}"
            ;;
    esac
}

# Track installed apps to avoid duplicates (for dependency resolution)
# Using string-based tracking for bash 3.2 compatibility (macOS default)
INSTALLED_APPS=""

# Install a mise app with dependency resolution
install_mise_app() {
    local app_key="$1"

    # Skip if already processed this session (pipe delimiters prevent partial matches)
    [[ "$INSTALLED_APPS" == *"|$app_key|"* ]] && return 0

    # Check for dependency (install silently if needed)
    local dep=$(get_app_prop "$app_key" "depends_on")
    if [[ -n "$dep" ]]; then
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
    # Use 'mise current' to get the active version (handles multiple installed versions correctly)
    local installed_version=$(mise current "$name" 2>/dev/null)

    if [[ -n "$installed_version" ]]; then
        if [[ "$version" == "latest" ]]; then
            # For "latest", check if there's a newer version available
            local latest_version=$(mise latest "$name" 2>/dev/null)
            if [[ "$installed_version" == "$latest_version" ]]; then
                add_to_summary SKIPPED "$name" "$app_key"
                return 0
            else
                log_info "$name@$installed_version outdated (latest: $latest_version), upgrading..."
            fi
        elif [[ "$version" == "lts" || "$version" == "stable" ]]; then
            # For "lts" or "stable", if any version is installed, consider it good
            # These are moving targets, no need to constantly reinstall
            add_to_summary SKIPPED "$name" "$app_key"
            return 0
        elif [[ "$installed_version" == "$version"* ]]; then
            # Prefix match: "3.14.2" starts with "3.14" → skip
            # Also handles exact matches: "3.14.2" starts with "3.14.2" → skip
            add_to_summary SKIPPED "$name" "$app_key"
            return 0
        else
            log_info "$name@$installed_version installed, but $version requested, installing..."
        fi
    else
        log_success "Installing $name@$version..."
    fi

    # Capture both stdout and stderr to show errors on failure
    local install_output
    if install_output=$(mise install "$name@$version" 2>&1); then
        add_to_summary INSTALLED "$name" "$app_key"
    else
        log_warning "Failed to install $name"
        # Show first line of error to help debugging
        local error_line=$(echo "$install_output" | grep -i "error\|failed\|not found" | head -1)
        [[ -n "$error_line" ]] && echo "      $error_line"
    fi
}

# Generate mise config based on selected profiles
# This creates the config in the dotfiles repo, which then gets symlinked by stow
generate_mise_config() {
    local config_file="$DOTFILES_DIR/mise/.config/mise/config.toml"
    mkdir -p "$(dirname "$config_file")"

    log_info "Generating mise config for selected profiles..."

    # Header
    cat > "$config_file" << 'EOF'
# =============================================================================
# Mise Config - Auto-generated by install.sh
# =============================================================================
# This file is regenerated based on selected profile(s).
# To add tools permanently, edit apps.toml with type = "mise"
# =============================================================================

[tools]
EOF

    # Add tools from apps.toml that match selected profiles and type=mise
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            local type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "mise" ]]; then
                local name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"
                local version=$(get_app_prop "$app_key" "version")
                [[ -z "$version" ]] && version="latest"
                echo "$name = \"$version\"" >> "$config_file"
            fi
        fi
    done

    # Settings
    cat >> "$config_file" << 'EOF'

[settings]
log_level = "info"
experimental = true
EOF

    log_success "Generated mise config with $(grep -c '=' "$config_file" 2>/dev/null || echo 0) tools"
}

# Print summary table using gum
print_summary_table() {
    local data="$1"
    local status_symbol="$2"
    local status_text="$3"

    [[ -z "$data" ]] && return

    local csv_data=""
    while IFS='|' read -r name desc; do
        [[ -z "$name" ]] && continue
        # Escape commas in description for CSV
        desc="${desc//,/;}"
        [[ -z "$csv_data" ]] && csv_data="${name},${status_symbol} ${status_text},${desc}" || csv_data="${csv_data}
${name},${status_symbol} ${status_text},${desc}"
    done <<< "$data"

    echo "$csv_data" | gum table \
        --separator="," \
        --columns="Package,Status,Description" \
        --widths="22,12,40" \
        --print \
        --border="rounded"
    echo ""
}

# =============================================================================
# EXTRAS MODE: Install additional apps interactively
# =============================================================================
if [[ "$EXTRAS_MODE" == true ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Extras Mode: Install Additional Apps"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Scanning for uninstalled apps..."

    # Build list of uninstalled apps (exclude stow packages)
    UNINSTALLED_APPS=()
    for app_key in $(get_all_apps); do
        type=$(get_app_prop "$app_key" "type")
        [[ "$type" == "stow" ]] && continue  # Skip config packages

        if ! is_app_installed "$app_key"; then
            desc=$(get_app_prop "$app_key" "description")
            category=$(get_app_prop "$app_key" "category")
            [[ -z "$desc" ]] && desc="$app_key"
            UNINSTALLED_APPS+=("$app_key|$desc|$category")
        fi
    done

    if [[ ${#UNINSTALLED_APPS[@]} -eq 0 ]]; then
        echo ""
        log_info "All available apps are already installed!"
        exit 0
    fi

    echo ""
    echo "Found ${#UNINSTALLED_APPS[@]} apps available to install:"
    echo ""

    # Format for gum: "app_key - description"
    GUM_OPTIONS=()
    for entry in "${UNINSTALLED_APPS[@]}"; do
        IFS='|' read -r key desc category <<< "$entry"
        GUM_OPTIONS+=("$key - $desc")
    done

    # Multi-select with gum
    SELECTED_EXTRAS=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && SELECTED_EXTRAS+=("${line%% - *}")  # Extract app_key
    done < <(gum choose --no-limit \
        --header "Select apps to install (SPACE to toggle, ENTER to confirm):" \
        --cursor-prefix "[ ] " \
        --selected-prefix "[x] " \
        "${GUM_OPTIONS[@]}")

    if [[ ${#SELECTED_EXTRAS[@]} -eq 0 ]]; then
        echo ""
        log_info "No apps selected. Exiting."
        exit 0
    fi

    echo ""
    echo "Installing ${#SELECTED_EXTRAS[@]} selected app(s)..."
    echo ""

    # Install selected apps by type
    for app_key in "${SELECTED_EXTRAS[@]}"; do
        type=$(get_app_prop "$app_key" "type")
        name=$(get_app_prop "$app_key" "name")
        [[ -z "$name" ]] && name="$app_key"

        case "$type" in
            cask)
                tap=$(get_app_prop "$app_key" "tap")
                [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null
                log_success "Installing $name (cask)..."
                if brew install --cask "$name"; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    # Start service if configured
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                fi
                ;;
            brew)
                tap=$(get_app_prop "$app_key" "tap")
                [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null
                log_success "Installing $name (brew)..."
                if brew install "$name"; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    # Start service if configured
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                fi
                ;;
            mise)
                install_mise_app "$app_key"
                ;;
            curl)
                case "$app_key" in
                    claude-cli)
                        log_success "Installing claude-cli..."
                        curl -fsSL https://claude.ai/install.sh | bash
                        ;;
                    opencode-cli)
                        log_success "Installing opencode-cli..."
                        curl -fsSL https://opencode.ai/install | bash
                        ;;
                esac
                ;;
        esac
    done

    # Show summary and exit
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Extras Installation Complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ -n "$SUMMARY_INSTALLED" ]]; then
        echo ""
        print_summary_table "$SUMMARY_INSTALLED" "✓" "Installed"
    fi
    echo ""
    echo "Press [ENTER] to reload the shell..."
    read
    exec zsh -l
fi

# =============================================================================
# Layer 1: Homebrew (casks and brews from apps.toml)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 1: Homebrew"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Collect and add taps (deduplicated)
echo "Adding taps..."
TAPPED_LIST="|"
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        tap=$(get_app_prop "$app_key" "tap")
        if [[ -n "$tap" && "$TAPPED_LIST" != *"|$tap|"* ]]; then
            echo "   Tapping: $tap"
            brew tap "$tap" 2>/dev/null || true
            TAPPED_LIST="${TAPPED_LIST}${tap}|"
        fi
    fi
done

# Install casks
echo "Installing casks..."
for app_key in $(get_all_apps); do
    type=$(get_app_prop "$app_key" "type")
    if [[ "$type" == "cask" ]]; then
        if app_in_profile "$app_key"; then
            name=$(get_app_prop "$app_key" "name")
            [[ -z "$name" ]] && name="$app_key"

            # Check if already installed (via Homebrew OR in /Applications)
            app_name=$(get_cask_app_name "$name")
            if brew list --cask 2>/dev/null | grep -q "^${name}$" || \
               { [[ -n "$app_name" ]] && [[ -d "/Applications/$app_name" ]]; }; then
                # Check if outdated
                if brew outdated --cask 2>/dev/null | grep -q "^${name}"; then
                    log_info "$name outdated, upgrading..."
                    brew upgrade --cask "$name" || log_warning "Failed to upgrade $name"
                    add_to_summary INSTALLED "$name" "$app_key"
                else
                    add_to_summary SKIPPED "$name" "$app_key"
                fi
                # Ensure service is running if configured
                service=$(get_app_prop "$app_key" "service")
                [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
            else
                log_success "Installing $name..."
                if brew install --cask "$name"; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    # Start service if configured
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                else
                    log_error "Failed to install $name"
                fi
            fi
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
            tap=$(get_app_prop "$app_key" "tap")
            [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null

            # Check if already installed
            if brew list 2>/dev/null | grep -q "^${name}$"; then
                # Check if outdated
                if brew outdated 2>/dev/null | grep -q "^${name}"; then
                    log_info "$name outdated, upgrading..."
                    brew upgrade "$name" || log_warning "Failed to upgrade $name"
                    add_to_summary INSTALLED "$name" "$app_key"
                else
                    add_to_summary SKIPPED "$name" "$app_key"
                fi
                # Ensure service is running if configured
                service=$(get_app_prop "$app_key" "service")
                [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
            else
                log_success "Installing $name..."
                if brew install "$name"; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    # Start service if configured
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                else
                    log_error "Failed to install $name"
                fi
            fi
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Cleaning up unlisted Homebrew packages..."

    # Cache sudo credentials for removing admin apps (Edge, etc.)
    sudo -v

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
                    [[ -n "$tap" ]] && echo "tap \"$tap\"" >> "$TEMP_BREWFILE"
                    echo "brew \"$name\"" >> "$TEMP_BREWFILE"
                    ;;
            esac
        fi
    done

    # Add bootstrap packages (always keep these)
    cat "$DOTFILES_DIR/Brewfile.bootstrap" >> "$TEMP_BREWFILE"

    # Capture packages to remove for summary
    CLEANUP_LIST=$(brew bundle cleanup --file="$TEMP_BREWFILE" 2>/dev/null || true)
    if [[ -n "$CLEANUP_LIST" ]]; then
        echo "   Removing packages not in profile:"
        # Process cleanup list (avoid subshell to preserve SUMMARY_REMOVED)
        while IFS= read -r pkg; do
            if [[ -n "$pkg" ]]; then
                log_warning "Removing $pkg"
                # For removed packages, use the package name as both name and key (no description lookup)
                [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="${pkg}|-" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${pkg}|-"
            fi
        done <<< "$CLEANUP_LIST"
        # Force removal without prompts
        brew bundle cleanup --force --file="$TEMP_BREWFILE" 2>/dev/null || true
    else
        log_info "No Homebrew packages to remove"
    fi

    rm "$TEMP_BREWFILE"
fi

# =============================================================================
# Generate mise config (before stow, so it gets symlinked)
# =============================================================================
generate_mise_config

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
                stow_enforce "$package" || true
            else
                log_warning "Stow package directory not found: $package/"
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
            log_warning "Removing $tool"
            mise uninstall "$tool" --all 2>/dev/null || true
            # For removed tools, use tool name as both name and key (no description lookup)
            [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="${tool}|-" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${tool}|-"
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
                        add_to_summary SKIPPED "claude-cli" "claude-cli"
                    else
                        log_success "Installing claude-cli..."
                        curl -fsSL https://claude.ai/install.sh 2>/dev/null | bash 2>/dev/null || true
                        # Verify installation succeeded by checking if binary exists
                        if command -v claude &> /dev/null; then
                            add_to_summary INSTALLED "claude-cli" "claude-cli"
                        else
                            log_warning "Failed to install claude-cli"
                        fi
                    fi
                    ;;
                opencode-cli)
                    if command -v opencode &> /dev/null; then
                        add_to_summary SKIPPED "opencode-cli" "opencode-cli"
                    else
                        log_success "Installing opencode-cli..."
                        curl -fsSL https://opencode.ai/install 2>/dev/null | bash 2>/dev/null || true
                        # Verify installation succeeded by checking if binary exists
                        if command -v opencode &> /dev/null; then
                            add_to_summary INSTALLED "opencode-cli" "opencode-cli"
                        else
                            log_warning "Failed to install opencode-cli"
                        fi
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
# Installation Summary (Table Display)
# =============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Profiles: ${SELECTED_PROFILES[*]}"
echo ""

if [[ -n "$SUMMARY_INSTALLED" ]]; then
    echo -e "  ${GREEN}Newly Installed${NC}"
    echo ""
    print_summary_table "$SUMMARY_INSTALLED" "✓" "New"
fi

if [[ -n "$SUMMARY_SKIPPED" ]]; then
    echo -e "  ${BLUE}Already Installed${NC}"
    echo ""
    print_summary_table "$SUMMARY_SKIPPED" "ℹ" "Skipped"
fi

if [[ -n "$SUMMARY_REMOVED" ]]; then
    echo -e "  ${YELLOW}Removed${NC}"
    echo ""
    print_summary_table "$SUMMARY_REMOVED" "⚠" "Removed"
fi

if [[ -z "$SUMMARY_INSTALLED" && -z "$SUMMARY_SKIPPED" && -z "$SUMMARY_REMOVED" ]]; then
    echo "  No changes made"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Press [ENTER] to reload the shell..."
read
exec zsh -l
