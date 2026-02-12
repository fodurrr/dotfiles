# =============================================================================
# App State Helpers
# =============================================================================

is_cask_brew_managed() {
    local cask="$1"
    brew list --cask 2>/dev/null | grep -q "^${cask}$"
}

get_cask_candidate_app_paths() {
    local cask="$1"
    case "$cask" in
        microsoft-office)
            cat << 'EOF'
/Applications/Microsoft Word.app
/Applications/Microsoft Excel.app
/Applications/Microsoft PowerPoint.app
/Applications/Microsoft Outlook.app
/Applications/Microsoft OneNote.app
/Applications/Microsoft 365 Copilot.app
EOF
            return 0
            ;;
    esac

    local app_name
    app_name=$(get_cask_app_name "$cask")
    if [[ -n "$app_name" ]]; then
        if [[ "$app_name" == */* ]]; then
            app_name=$(basename "$app_name")
        fi
        echo "/Applications/$app_name"
    fi
}

has_existing_cask_app_bundle() {
    local cask="$1"
    local path
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        if [[ -d "$path" ]]; then
            return 0
        fi
    done < <(get_cask_candidate_app_paths "$cask")
    return 1
}

is_cask_unmanaged_present() {
    local cask="$1"
    if is_cask_brew_managed "$cask"; then
        return 1
    fi
    has_existing_cask_app_bundle "$cask"
}

get_cask_install_state() {
    local cask="$1"
    if is_cask_brew_managed "$cask"; then
        echo "managed"
        return 0
    fi

    local paths
    paths=$(get_cask_candidate_app_paths "$cask")
    if [[ -z "$paths" ]]; then
        echo "missing"
        return 0
    fi

    if has_existing_cask_app_bundle "$cask"; then
        echo "unmanaged"
    else
        echo "missing"
    fi
}

# Get the .app name for a cask (checks /Applications for non-Homebrew installs)
get_cask_app_name() {
    local cask="$1"
    local app_name=""
    local json
    json=$(brew info --cask --json=v2 "$cask" 2>/dev/null)

    app_name=$(echo "$json" | yq -r '.casks[0].artifacts[] | select(has("app")) | .app[0]' 2>/dev/null | head -1)
    if [[ -n "$app_name" ]] && [[ "$app_name" != "null" ]]; then
        echo "$app_name"
        return
    fi

    app_name=$(echo "$json" | yq -r '.casks[0].artifacts[].uninstall[].delete[]?' 2>/dev/null | grep -m1 '/Applications/.*\.app$' | sed 's|/Applications/||')
    if [[ -n "$app_name" ]]; then
        echo "$app_name"
        return
    fi

    app_name=$(echo "$json" | yq -r '.casks[0].name[0]' 2>/dev/null)
    if [[ -n "$app_name" ]] && [[ "$app_name" != "null" ]]; then
        echo "${app_name}.app"
        return
    fi
}

# Check if a Linux package is installed via apt/dnf
is_linux_package_installed() {
    local package="$1"
    local platform

    # Detect platform
    if [[ -n "$(type -t detect_platform)" ]]; then
        platform=$(detect_platform)
    else
        case "$(uname -s)" in
            Darwin) platform="macos" ;;
            Linux) platform="linux" ;;
            *) platform="unknown" ;;
        esac
    fi

    # Only relevant for Linux
    if [[ "$platform" != "linux" ]]; then
        return 1
    fi

    # Check using appropriate package manager
    if command -v dpkg &>/dev/null; then
        dpkg -l "$package" 2>/dev/null | grep -q "^ii"
        return $?
    elif command -v rpm &>/dev/null; then
        rpm -q "$package" &>/dev/null
        return $?
    else
        return 1
    fi
}

# Check if an app is currently installed
is_app_installed() {
    local app_key="$1"
    local type
    type=$(get_app_prop "$app_key" "type")
    local name
    name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"

    case "$type" in
        cask)
            local state
            state=$(get_cask_install_state "$name")
            [[ "$state" == "managed" || "$state" == "unmanaged" ]]
            ;;
        brew)
            # On Linux, check via apt/dnf instead
            if is_linux_package_installed "$name"; then
                return 0
            fi
            # Fallback to brew on macOS
            brew list 2>/dev/null | grep -q "^${name}$"
            ;;
        mise)
            local status
            status=$(mise list "$name" 2>/dev/null | head -1)
            [[ -n "$status" ]] && [[ "$status" != *"(missing)"* ]]
            ;;
        curl)
            case "$app_key" in
                claude-cli) command -v claude >/dev/null 2>&1 ;;
                opencode-cli) command -v opencode >/dev/null 2>&1 ;;
                *) return 1 ;;
            esac
            ;;
        stow)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

