# =============================================================================
# A la carte removals
# =============================================================================

remove_alacarte_app() {
    local app_key="$1"
    local type
    type=$(get_app_prop "$app_key" "type")
    local name
    name=$(get_app_display_name "$app_key")

    case "$type" in
        cask)
            log_warning "Removing $name (cask)..."
            brew uninstall --cask "$name" 2>/dev/null || true
            add_to_summary REMOVED "$name" "$app_key"
            ;;
        brew)
            log_warning "Removing $name (brew)..."
            brew uninstall "$name" 2>/dev/null || true
            add_to_summary REMOVED "$name" "$app_key"
            ;;
        mise)
            log_warning "Removing $name (mise)..."
            mise uninstall "$name" --all 2>/dev/null || true
            add_to_summary REMOVED "$name" "$app_key"
            ;;
        curl)
            log_warning "Removing $name (curl)..."
            local bin_name
            case "$app_key" in
                claude-cli) bin_name="claude" ;;
                opencode-cli) bin_name="opencode" ;;
                *) bin_name="$name" ;;
            esac
            local bin_path
            bin_path=$(command -v "$bin_name" 2>/dev/null || true)
            if [[ -n "$bin_path" ]]; then
                rm "$bin_path" 2>/dev/null || true
                add_to_summary REMOVED "$name" "$app_key"
            else
                log_warning "Binary not found for $name; skipping"
            fi
            ;;
    esac
}

remove_alacarte_configs() {
    local parent_app="$1"
    local config_key
    for config_key in $(get_all_apps); do
        local config_for
        config_for=$(get_app_prop "$config_key" "config_for")
        if [[ -n "$config_for" && "$config_for" == "$parent_app" ]]; then
            local type
            type=$(get_app_prop "$config_key" "type")
            case "$type" in
                stow)
                    local package
                    package=$(get_app_prop "$config_key" "package")
                    if [[ -d "$DOTFILES_DIR/$package" ]]; then
                        log_warning "Unlinking $package config..."
                        if stow --help 2>&1 | grep -q -- "--no-folding"; then
                            stow --no-folding -D "$package" 2>/dev/null || true
                        else
                            stow -D "$package" 2>/dev/null || true
                        fi
                        add_to_summary REMOVED "$package" "$config_key"
                    fi
                    ;;
                defaults)
                    log_warning "Defaults for $config_key not reverted (manual reset may be required)"
                    ;;
            esac
        fi
    done
}

run_alacarte_removals() {
    if [[ "$A_LA_CARTE_MODE" != true ]]; then
        return 0
    fi

    if [[ -z "$A_LA_CARTE_REMOVE" ]]; then
        return 0
    fi

    echo ""
    echo "Removing deselected apps..."

    local app_key
    while IFS= read -r app_key; do
        [[ -z "$app_key" ]] && continue
        remove_alacarte_app "$app_key"
        remove_alacarte_configs "$app_key"
    done <<< "$A_LA_CARTE_REMOVE"
}
