# =============================================================================
# App State Helpers
# =============================================================================

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
    type=$(get_app_prop "$app_key" "type")
    local name
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
