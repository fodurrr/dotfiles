# =============================================================================
# EXTRAS MODE: Install additional apps interactively
# =============================================================================

run_extras_mode() {
    if [[ "$EXTRAS_MODE" != true ]]; then
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Extras Mode: Install Additional Apps"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Scanning for uninstalled apps..."

    # Build list of uninstalled apps (exclude stow packages)
    UNINSTALLED_APPS=()
    local app_key type desc category
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
    local entry
    for entry in "${UNINSTALLED_APPS[@]}"; do
        IFS='|' read -r app_key desc category <<< "$entry"
        GUM_OPTIONS+=("$app_key - $desc")
    done

    # Multi-select with gum
    SELECTED_EXTRAS=()
    local line
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
        local name
        name=$(get_app_prop "$app_key" "name")
        [[ -z "$name" ]] && name="$app_key"

        case "$type" in
            cask)
                local tap
                tap=$(get_app_prop "$app_key" "tap")
                [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null
                log_success "Installing $name (cask)..."
                if [[ "$name" == "stretchly" ]]; then
                    brew install --cask --no-quarantine "$name"
                else
                    brew install --cask "$name"
                fi
                if [[ $? -eq 0 ]]; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    # Start service if configured
                    local service
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                fi
                ;;
            brew)
                local tap
                tap=$(get_app_prop "$app_key" "tap")
                [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null
                log_success "Installing $name (brew)..."
                if brew install "$name"; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    # Start service if configured
                    local service
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
                        install_or_update_curl_tool "$app_key" "claude" "claude-cli"
                        ;;
                    opencode-cli)
                        install_or_update_curl_tool "$app_key" "opencode" "opencode-cli"
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
}
