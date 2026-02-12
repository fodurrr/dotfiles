# =============================================================================
# App Config Helpers
# =============================================================================

# Set default apps.toml path if not already set
if [[ -z "$APPS_CONFIG" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    APPS_CONFIG="$DOTFILES_DIR/apps.toml"
fi

# Get available profiles from apps.toml in preferred order
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

# Check if app belongs to current selection
app_in_profile() {
    local app_key="$1"

    if [[ "$A_LA_CARTE_MODE" == true ]]; then
        if app_in_alacarte_selection "$app_key"; then
            return 0
        fi
        local config_for
        config_for=$(get_app_prop "$app_key" "config_for")
        if [[ -n "$config_for" ]] && app_in_alacarte_selection "$config_for"; then
            return 0
        fi
        return 1
    fi

    local profiles
    profiles=$(yq -p toml -oy ".apps.\"$app_key\".profiles" "$APPS_CONFIG" 2>/dev/null || echo "")
    for profile in "${SELECTED_PROFILES[@]}"; do
        if echo "$profiles" | grep -q "$profile"; then
            return 0
        fi
    done
    return 1
}

# Check if app key is selected in a la carte mode
app_in_alacarte_selection() {
    local app_key="$1"
    [[ "$A_LA_CARTE_SELECTED" == *"|$app_key|"* ]]
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

# Get app category
get_app_category() {
    get_app_prop "$1" "category"
}

# Get app display name
get_app_display_name() {
    local app_key="$1"
    local name
    name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"
    echo "$name"
}

# Check if app is installable (exclude stow/defaults)
is_installable_app() {
    local app_key="$1"
    local type
    type=$(get_app_prop "$app_key" "type")
    case "$type" in
        cask|brew|mise|curl) return 0 ;;
        *) return 1 ;;
    esac
}

# Map category to one of 7 display groups
get_app_group() {
    local category="$1"
    case "$category" in
        browsers|fonts)
            echo "Core & Browsing"
            ;;
        terminals|editors)
            echo "Terminals & Editors"
            ;;
        ai)
            echo "AI & Automation"
            ;;
        productivity|communication|office|cloud-storage)
            echo "Productivity & Communication"
            ;;
        media)
            echo "Media & Creativity"
            ;;
        window-management|status-bar|display|security|utilities)
            echo "System & Window Management"
            ;;
        cli|runtimes|database|virtualization)
            echo "Developer Platforms"
            ;;
        *)
            echo "Other"
            ;;
    esac
}

# Output group order (one per line)
get_group_order() {
    cat << 'EOF'
Core & Browsing
Terminals & Editors
AI & Automation
Productivity & Communication
Media & Creativity
System & Window Management
Developer Platforms
Other
EOF
}

# =============================================================================
# Platform Filtering Functions
# =============================================================================

# Get current platform without requiring platform.sh to be sourced
get_current_platform() {
    if [[ -n "$(type -t detect_platform)" ]]; then
        detect_platform
        return 0
    fi

    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

# Normalize yq list/string output to space-separated tokens
normalize_app_list_tokens() {
    echo "$1" \
        | sed 's/^- *//' \
        | sed 's/\[//g' \
        | sed 's/\]//g' \
        | sed 's/,/ /g' \
        | sed 's/"//g' \
        | tr '\n' ' ' \
        | tr -s ' ' \
        | sed 's/^ //;s/ $//'
}

# Get platform list for an app (comma-separated or array)
get_app_platform() {
    local app_key="$1"
    local result
    result=$(get_app_prop "$app_key" "platform")

    [[ "$result" == "null" ]] && result=""
    normalize_app_list_tokens "$result"
}

# Check if app is supported on current platform
is_app_supported() {
    local app_key="$1"
    local platform="${2:-}"

    if [[ -z "$platform" ]]; then
        platform=$(get_current_platform)
    fi

    local app_platforms
    app_platforms=$(get_app_platform "$app_key")

    if [[ -z "$app_platforms" ]]; then
        return 0
    fi

    local distro=""
    if [[ "$platform" == "linux" && -n "$(type -t detect_linux_distro)" ]]; then
        distro=$(detect_linux_distro)
    fi

    local sup_platform
    for sup_platform in $app_platforms; do
        case "$sup_platform" in
            macos|darwin)
                [[ "$platform" == "macos" ]] && return 0
                ;;
            linux)
                [[ "$platform" == "linux" ]] && return 0
                ;;
            ubuntu|debian|fedora|rhel|centos)
                if [[ "$platform" == "linux" && "$distro" == "$sup_platform" ]]; then
                    return 0
                fi
                ;;
        esac
    done

    return 1
}

# Canonical helper: selected in profile + supported on current platform
app_selected_for_install() {
    local app_key="$1"
    local platform="${2:-}"

    if ! app_in_profile "$app_key"; then
        return 1
    fi

    is_app_supported "$app_key" "$platform"
}

# Resolve Linux package name for a brew app from apps.toml metadata
get_linux_package_name() {
    local app_key="$1"
    local pm="${2:-}"
    local app_type
    app_type=$(get_app_prop "$app_key" "type")
    if [[ "$app_type" != "brew" ]]; then
        echo ""
        return 0
    fi

    local generic_name
    generic_name=$(get_app_prop "$app_key" "linux_name")
    local distro_name=""

    case "$pm" in
        apt)
            distro_name=$(get_app_prop "$app_key" "linux_apt")
            ;;
        dnf)
            distro_name=$(get_app_prop "$app_key" "linux_dnf")
            ;;
    esac

    if [[ -n "$distro_name" ]]; then
        echo "$distro_name"
        return 0
    fi

    echo "$generic_name"
}

# Get all apps for current profile, filtered by platform
get_apps_for_profile() {
    local apps
    apps=$(get_all_apps)

    for app_key in $apps; do
        if app_selected_for_install "$app_key"; then
            echo "$app_key"
        fi
    done
}

# Get all installable apps (filtered by platform)
get_all_installable_apps() {
    local apps
    apps=$(get_all_apps)

    for app_key in $apps; do
        if is_installable_app "$app_key"; then
            if is_app_supported "$app_key"; then
                echo "$app_key"
            fi
        fi
    done
}

# Check if app is GUI-only (not available in Linux package repos)
is_gui_only_app() {
    local app_key="$1"
    local app_type
    app_type=$(get_app_prop "$app_key" "type")

    case "$app_type" in
        cask)
            # GUI apps are typically cask on macOS
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
