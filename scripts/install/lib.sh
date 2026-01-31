#!/bin/bash

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

    # Helper: Check if symlink points to this dotfiles repo
    is_our_symlink() {
        local link_target
        link_target="$(readlink "$1" 2>/dev/null)"
        # Check if it points to this dotfiles directory (absolute or relative)
        [[ "$link_target" == *"$DOTFILES_DIR"* ]] || [[ "$link_target" == *"/dev/dotfiles/"* ]]
    }

    # Back up .config/* subdirectories that would conflict with stow
    for top_dir in "$package"/.config/*/; do
        if [[ -d "$top_dir" ]]; then
            local dir_name
            dir_name="${top_dir#$package/.config/}"
            dir_name="${dir_name%/}"
            local target_path="$HOME/.config/$dir_name"

            if [[ -L "$target_path" ]]; then
                # Symlink exists - remove if it points elsewhere
                if ! is_our_symlink "$target_path"; then
                    echo "      Removing old symlink: $target_path"
                    rm "$target_path"
                fi
            elif [[ -d "$target_path" ]]; then
                # Real directory - back it up
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

            if [[ -L "$target_path" ]]; then
                # Symlink exists - remove if it points elsewhere
                if ! is_our_symlink "$target_path"; then
                    echo "      Removing old symlink: $target_path"
                    rm "$target_path"
                fi
            elif [[ -e "$target_path" ]]; then
                # Real file - back it up
                echo "      Backing up: $target_path"
                mv "$target_path" "${target_path}.bak"
            fi
        fi
    done

    # Use stow with built ignore list
    stow "${stow_opts[@]}" "$package"
}

# =============================================================================
# Profile Helpers
# =============================================================================
get_profiles() {
    # Extract all unique profiles
    local all_profiles
    all_profiles=$(grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u)

    # Output in preferred order: minimal, standard, developer, hacker, server, then others
    for preferred in minimal standard developer hacker server; do
        echo "$all_profiles" | grep -x "$preferred" 2>/dev/null || true
    done
    # Then any others not in the preferred list
    echo "$all_profiles" | grep -vxE "minimal|standard|developer|hacker|server" 2>/dev/null || true
}

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
    local json
    json=$(brew info --cask --json=v2 "$cask" 2>/dev/null)

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
    local type
    local name
    type=$(get_app_prop "$app_key" "type")
    name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"

    case "$type" in
        cask)
            # Check if installed via Homebrew
            if brew list --cask 2>/dev/null | grep -q "^${name}$"; then
                return 0
            fi
            # Check if app exists in /Applications (installed by other means)
            local app_name
            app_name=$(get_cask_app_name "$name")
            if [[ -n "$app_name" ]] && [[ -d "/Applications/$app_name" ]]; then
                return 0
            fi
            return 1
            ;;
        brew)
            brew list 2>/dev/null | grep -q "^${name}$"
            ;;
        mise)
            local status
            status=$(mise list "$name" 2>/dev/null | head -1)
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

    local desc
    desc=$(get_app_prop "$app_key" "description")
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
    local dep
    dep=$(get_app_prop "$app_key" "depends_on")
    if [[ -n "$dep" ]]; then
        install_mise_app "$dep"
    fi

    # Mark as processed
    INSTALLED_APPS="${INSTALLED_APPS}|${app_key}|"

    # Get app details
    local name
    local version
    name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"
    version=$(get_app_prop "$app_key" "version")
    [[ -z "$version" ]] && version="latest"

    # Check if already installed with correct version
    # IMPORTANT: mise current returns configured version even if not installed!
    # We must check mise ls for "(missing)" to detect actual installation state
    local installed_version=""
    local ls_output
    ls_output=$(mise ls "$name" 2>/dev/null)
    # Only trust mise current if tool exists AND is not marked as missing
    if [[ -n "$ls_output" ]]; then
        if [[ "$ls_output" == *"(missing)"* ]]; then
            : # Tool is in config but not installed - leave installed_version empty
        else
            installed_version=$(mise current "$name" 2>/dev/null)
        fi
    fi

    if [[ -n "$installed_version" ]]; then
        if [[ "$version" == "latest" ]]; then
            # For "latest", check if there's a newer version available
            local latest_version
            latest_version=$(mise latest "$name" 2>/dev/null)
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
        local error_line
        error_line=$(echo "$install_output" | grep -i "error\|failed\|not found" | head -1)
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
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "mise" ]]; then
                local name
                local version
                name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"
                version=$(get_app_prop "$app_key" "version")
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
