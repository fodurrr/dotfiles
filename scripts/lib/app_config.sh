# =============================================================================
# App Config Helpers
# =============================================================================

# Set default config paths if not already set
if [[ -z "${APPS_CONFIG:-}" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    APPS_CONFIG="$DOTFILES_DIR/apps.toml"
fi

if [[ -z "${PROFILES_DIR:-}" ]]; then
    DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    PROFILES_DIR="$DOTFILES_DIR/profiles"
fi

RESOLVED_PROFILE_PLATFORM=""
RESOLVED_PROFILE_SELECTION_KEY=""
RESOLVED_SELECTED_PROFILE_APPS="|"

profile_error() {
    local message="$1"
    if [[ -n "$(type -t log_error)" ]]; then
        log_error "$message"
    else
        echo "ERROR: $message" >&2
    fi
}

get_profile_file_path() {
    local profile="$1"
    echo "$PROFILES_DIR/$profile.toml"
}

profile_exists() {
    local profile="$1"
    local profile_file
    profile_file=$(get_profile_file_path "$profile")
    [[ -f "$profile_file" ]]
}

# Get available profiles from profiles/ in preferred order
get_profiles() {
    local all_profiles=""
    local file base

    for file in "$PROFILES_DIR"/*.toml; do
        [[ -e "$file" ]] || continue
        base="${file##*/}"
        base="${base%.toml}"
        if [[ -z "$all_profiles" ]]; then
            all_profiles="$base"
        else
            all_profiles="${all_profiles}
$base"
        fi
    done

    # Output in preferred order: minimal, standard, developer, hacker, server, then others
    local preferred
    for preferred in minimal standard developer hacker server; do
        echo "$all_profiles" | grep -x "$preferred" 2>/dev/null || true
    done

    echo "$all_profiles" | grep -vxE "minimal|standard|developer|hacker|server" 2>/dev/null | sort -u
}

get_profile_apps_for_platform() {
    local profile="$1"
    local platform="$2"
    local profile_file
    profile_file=$(get_profile_file_path "$profile")

    if [[ ! -f "$profile_file" ]]; then
        return 1
    fi

    local legacy_apps
    legacy_apps=$(yq -p toml -oy ".${platform}.apps[]" "$profile_file" 2>/dev/null || true)
    if [[ -n "$legacy_apps" ]]; then
        echo "$legacy_apps"
        return 0
    fi

    # Category-grouped format:
    # [macos.<group>]
    # apps = ["app-key"]
    yq -p toml -oy ".${platform} | to_entries | map(select(.value.apps != null)) | .[].value.apps[]" "$profile_file" 2>/dev/null || true
}

validate_profile_apps_for_platform() {
    local profile="$1"
    local platform="$2"
    local profile_file
    profile_file=$(get_profile_file_path "$profile")

    if [[ ! -f "$profile_file" ]]; then
        profile_error "Profile '$profile' not found: $profile_file"
        return 1
    fi

    local failed=false
    local app_key
    while IFS= read -r app_key; do
        [[ -z "$app_key" ]] && continue

        local app_exists
        app_exists=$(yq -p toml -oy ".apps.\"$app_key\"" "$APPS_CONFIG" 2>/dev/null || echo "")
        if [[ -z "$app_exists" || "$app_exists" == "null" ]]; then
            profile_error "Invalid profile app reference: '$app_key' in profile '$profile' is not defined in apps.toml"
            failed=true
            continue
        fi

        if ! is_app_supported "$app_key" "$platform"; then
            profile_error "Invalid profile app reference: '$app_key' in profile '$profile' is not supported on platform '$platform'"
            failed=true
        fi
    done < <(get_profile_apps_for_platform "$profile" "$platform")

    [[ "$failed" != true ]]
}

validate_selected_profiles_for_platform() {
    local platform="${1:-}"
    [[ -z "$platform" ]] && platform=$(get_current_platform)

    local failed=false
    local profile
    for profile in "${SELECTED_PROFILES[@]}"; do
        if ! validate_profile_apps_for_platform "$profile" "$platform"; then
            failed=true
        fi
    done

    [[ "$failed" != true ]]
}

resolve_selected_apps_for_platform() {
    local platform="${1:-}"
    [[ -z "$platform" ]] && platform=$(get_current_platform)

    local selection_key
    selection_key=$(printf '%s|' "${SELECTED_PROFILES[@]}")

    if [[ "$RESOLVED_PROFILE_PLATFORM" == "$platform" && "$RESOLVED_PROFILE_SELECTION_KEY" == "$selection_key" ]]; then
        echo "$RESOLVED_SELECTED_PROFILE_APPS" | tr '|' '\n' | sed '/^$/d'
        return 0
    fi

    RESOLVED_SELECTED_PROFILE_APPS="|"
    local profile app_key
    for profile in "${SELECTED_PROFILES[@]}"; do
        while IFS= read -r app_key; do
            [[ -z "$app_key" ]] && continue
            if [[ "$RESOLVED_SELECTED_PROFILE_APPS" == *"|$app_key|"* ]]; then
                continue
            fi
            RESOLVED_SELECTED_PROFILE_APPS="${RESOLVED_SELECTED_PROFILE_APPS}${app_key}|"
        done < <(get_profile_apps_for_platform "$profile" "$platform")
    done

    RESOLVED_PROFILE_PLATFORM="$platform"
    RESOLVED_PROFILE_SELECTION_KEY="$selection_key"

    echo "$RESOLVED_SELECTED_PROFILE_APPS" | tr '|' '\n' | sed '/^$/d'
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

    local platform
    platform=$(get_current_platform)
    resolve_selected_apps_for_platform "$platform" >/dev/null
    [[ "$RESOLVED_SELECTED_PROFILE_APPS" == *"|$app_key|"* ]]
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

    local app_key
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

    local app_key
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
