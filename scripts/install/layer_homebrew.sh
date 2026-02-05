# =============================================================================
# Layer 1: Homebrew (casks and brews from apps.toml)
# =============================================================================

run_layer_homebrew() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 1: Homebrew"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Collect and add taps (deduplicated)
    echo "Adding taps..."
    TAPPED_LIST="|"
    local app_key
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            local tap
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
        local type
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "cask" ]]; then
            if app_in_profile "$app_key"; then
                local name
                name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"

                # Check if already installed (via Homebrew OR in /Applications)
                local app_name
                app_name=$(get_cask_app_name "$name")
                if brew list --cask 2>/dev/null | grep -q "^${name}$" || \
                   { [[ -n "$app_name" ]] && [[ -d "/Applications/$app_name" ]]; }; then
                    # Check if outdated
                    if brew outdated --cask 2>/dev/null | grep -q "^${name}"; then
                        log_info "$name outdated, upgrading..."
                        if [[ "$name" == "stretchly" ]]; then
                            brew upgrade --cask --no-quarantine "$name" || log_warning "Failed to upgrade $name"
                        else
                            brew upgrade --cask "$name" || log_warning "Failed to upgrade $name"
                        fi
                        add_to_summary INSTALLED "$name" "$app_key"
                    else
                        add_to_summary SKIPPED "$name" "$app_key"
                    fi
                    # Ensure service is running if configured
                    local service
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                else
                    log_success "Installing $name..."
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
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "brew" ]]; then
                local name
                name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"
                local tap
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
                    local service
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                else
                    log_success "Installing $name..."
                    if brew install "$name"; then
                        add_to_summary INSTALLED "$name" "$app_key"
                        # Start service if configured
                        local service
                        service=$(get_app_prop "$app_key" "service")
                        [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                    else
                        log_error "Failed to install $name"
                    fi
                fi
            fi
        fi
    done

    if [[ "$CLEAN_MODE" == true && "$CLEAN_SAFE" == true ]]; then
        echo "Cleaning up unlisted Homebrew packages..."

        # Cache sudo credentials for removing admin apps (Edge, etc.)
        sudo -v

        # Generate temporary Brewfile from apps.toml for selected profiles
        TEMP_BREWFILE=$(mktemp)

        for app_key in $(get_all_apps); do
            if app_in_profile "$app_key"; then
                local type
                type=$(get_app_prop "$app_key" "type")
                local name
                name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"
                local tap
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
            local pkg
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
}
