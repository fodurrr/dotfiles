# =============================================================================
# List Installed Apps (from apps.toml)
# =============================================================================

list_installed_and_exit() {
    if ! command -v yq >/dev/null 2>&1; then
        echo "yq not found. Run bootstrap first (./install.sh) to install dependencies."
        exit 1
    fi

    if [[ ! -f "$APPS_CONFIG" ]]; then
        echo "apps.toml not found: $APPS_CONFIG"
        exit 1
    fi

    local has_brew=true
    local has_mise=true

    command -v brew >/dev/null 2>&1 || has_brew=false
    command -v mise >/dev/null 2>&1 || has_mise=false

    if [[ "$has_brew" != true ]]; then
        echo "Note: Homebrew not found; cask/brew checks will be skipped."
    fi
    if [[ "$has_mise" != true ]]; then
        echo "Note: Mise not found; mise checks will be skipped."
    fi

    local installed_list=""
    local app_key
    for app_key in $(get_all_apps); do
        if ! is_installable_app "$app_key"; then
            continue
        fi
        local type
        type=$(get_app_prop "$app_key" "type")
        case "$type" in
            cask|brew)
                [[ "$has_brew" != true ]] && continue
                ;;
            mise)
                [[ "$has_mise" != true ]] && continue
                ;;
        esac

        if [[ "$type" == "cask" ]]; then
            local cask
            cask=$(get_app_prop "$app_key" "name")
            [[ -z "$cask" ]] && cask="$app_key"
            local state
            state=$(get_cask_install_state "$cask")
            if [[ "$state" == "managed" || "$state" == "unmanaged" ]]; then
                local name
                name=$(get_app_display_name "$app_key")
                local line="- ${name} (${type}, ${state})"
                [[ -z "$installed_list" ]] && installed_list="$line" || installed_list="${installed_list}
${line}"
            fi
            continue
        fi

        if is_app_installed "$app_key"; then
            local name
            name=$(get_app_display_name "$app_key")
            local line="- ${name} (${type})"
            [[ -z "$installed_list" ]] && installed_list="$line" || installed_list="${installed_list}
${line}"
        fi
    done

    echo ""
    echo "Installed apps (from apps.toml):"
    if [[ -n "$installed_list" ]]; then
        echo "$installed_list"
    else
        echo "- (none found)"
    fi

    exit 0
}
