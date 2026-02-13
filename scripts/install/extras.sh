# =============================================================================
# EXTRAS MODE: Install additional apps interactively
# =============================================================================

is_extra_linux_package_available() {
    local pm="$1"
    local package="$2"
    case "$pm" in
        apt) apt-cache show "$package" >/dev/null 2>&1 ;;
        dnf) dnf info "$package" >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
}

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
        if ! is_app_supported "$app_key"; then
            continue
        fi

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

    local current_platform
    current_platform=$(get_current_platform)
    local current_pm
    current_pm=$(pm_get_manager)

    # Install selected apps by type
    for app_key in "${SELECTED_EXTRAS[@]}"; do
        type=$(get_app_prop "$app_key" "type")
        local name
        name=$(get_app_prop "$app_key" "name")
        [[ -z "$name" ]] && name="$app_key"

        case "$type" in
            cask)
                if [[ "$current_platform" != "macos" ]]; then
                    log_info "Skipping $name (cask installs are macOS-only)"
                    add_to_summary SKIPPED "$name" "$app_key"
                    continue
                fi
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
                if [[ "$current_platform" == "linux" ]]; then
                    local linux_package
                    linux_package=$(get_linux_package_name "$app_key" "$current_pm")
                    if [[ -z "$linux_package" ]]; then
                        log_info "Skipping $name (no Linux package mapping for $current_pm)"
                        add_to_summary SKIPPED "$name" "$app_key"
                        continue
                    fi
                    if ! is_extra_linux_package_available "$current_pm" "$linux_package"; then
                        log_info "Skipping $name (package '$linux_package' unavailable in $current_pm repos)"
                        add_to_summary SKIPPED "$name" "$app_key"
                        continue
                    fi

                    log_success "Installing $name ($linux_package)..."
                    if pm_install "$linux_package"; then
                        add_to_summary INSTALLED "$name" "$app_key"
                    else
                        log_warning "Failed to install $name ($linux_package)"
                    fi
                else
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
                fi
                ;;
            mise)
                install_mise_app "$app_key"
                ;;
            curl)
                case "$app_key" in
                    sheldon-linux)
                        install_or_update_curl_tool "$app_key" "sheldon" "sheldon"
                        ;;
                    *)
                        log_warning "Unknown curl installer selected in extras mode: $app_key"
                        add_to_summary SKIPPED "$name" "$app_key"
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
