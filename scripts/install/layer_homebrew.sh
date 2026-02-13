# =============================================================================
# Layer 1: Homebrew (casks and brews from apps.toml)
# =============================================================================

has_cask_conflict_with_office() {
    if [[ "$1" != "onedrive" ]]; then
        return 1
    fi
    app_selected_for_install "microsoft-office"
}

log_unmanaged_cask_paths() {
    local cask="$1"
    local path
    local printed=false
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        if [[ -d "$path" ]]; then
            if [[ "$printed" != true ]]; then
                log_error "Detected unmanaged app path(s) for $cask:"
                printed=true
            fi
            echo "      - $path"
        fi
    done < <(get_cask_candidate_app_paths "$cask")
}

remove_unmanaged_cask_bundle() {
    local cask="$1"
    local removed=false
    local path
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        if [[ -d "$path" ]]; then
            rm -rf "$path" 2>/dev/null || true
            removed=true
        fi
    done < <(get_cask_candidate_app_paths "$cask")
    [[ "$removed" == true ]]
}

run_layer_homebrew() {
    # Check if we should run Homebrew layer (macOS only)
    local platform
    platform=$(detect_platform)

    if [[ "$platform" != "macos" ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Layer 1: Homebrew"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        log_info "Skipping Homebrew layer (not a macOS system)"
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 1: Homebrew"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "Adding taps..."
    TAPPED_LIST="|"
    local app_key
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key"; then
            local tap
            tap=$(get_app_prop "$app_key" "tap")
            if [[ -n "$tap" && "$TAPPED_LIST" != *"|$tap|"* ]]; then
                echo "   Tapping: $tap"
                brew tap "$tap" 2>/dev/null || true
                TAPPED_LIST="${TAPPED_LIST}${tap}|"
            fi
        fi
    done

    echo "Installing casks..."
    local cask_layer_failures=""
    for app_key in $(get_all_apps); do
        local type
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" != "cask" ]]; then
            continue
        fi
        if ! app_selected_for_install "$app_key"; then
            continue
        fi

        local name
        name=$(get_app_prop "$app_key" "name")
        [[ -z "$name" ]] && name="$app_key"

        if has_cask_conflict_with_office "$name"; then
            log_warning "Skipping $name because microsoft-office is selected and conflicts with it"
            add_to_summary SKIPPED "$name" "$app_key"
            continue
        fi

        local state
        state=$(get_cask_install_state "$name")
        case "$state" in
            managed)
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
                local service
                service=$(get_app_prop "$app_key" "service")
                [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                ;;
            unmanaged)
                if [[ "$RECONCILE_CASKS" == true ]]; then
                    if is_cask_brew_managed "$name"; then
                        add_to_summary SKIPPED "$name" "$app_key"
                    else
                        log_error "reconcile failed for $name (token: $name)"
                        log_unmanaged_cask_paths "$name"
                        if [[ -z "$cask_layer_failures" ]]; then
                            cask_layer_failures="$name"
                        else
                            cask_layer_failures="${cask_layer_failures}, $name"
                        fi
                    fi
                else
                    log_warning "$name is present in /Applications but not Homebrew-managed; run with --reconcile-casks"
                    add_to_summary SKIPPED "$name" "$app_key"
                fi
                ;;
            missing|unknown)
                log_success "Installing $name..."
                if [[ "$name" == "stretchly" ]]; then
                    brew install --cask --no-quarantine "$name"
                else
                    brew install --cask "$name"
                fi
                if [[ $? -eq 0 ]]; then
                    add_to_summary INSTALLED "$name" "$app_key"
                    local service
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                else
                    log_error "Failed to install $name"
                fi
                ;;
        esac
    done

    if [[ -n "$cask_layer_failures" ]]; then
        log_error "Homebrew cask layer failed due to unresolved unmanaged casks: $cask_layer_failures"
        return 1
    fi

    echo "Installing brews..."
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key"; then
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "brew" ]]; then
                local name
                name=$(get_app_prop "$app_key" "name")
                [[ -z "$name" ]] && name="$app_key"
                local tap
                tap=$(get_app_prop "$app_key" "tap")
                [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null

                if brew list 2>/dev/null | grep -q "^${name}$"; then
                    if brew outdated 2>/dev/null | grep -q "^${name}"; then
                        log_info "$name outdated, upgrading..."
                        brew upgrade "$name" || log_warning "Failed to upgrade $name"
                        add_to_summary INSTALLED "$name" "$app_key"
                    else
                        add_to_summary SKIPPED "$name" "$app_key"
                    fi
                    local service
                    service=$(get_app_prop "$app_key" "service")
                    [[ "$service" == "true" ]] && brew services start "$name" 2>/dev/null
                else
                    log_success "Installing $name..."
                    if brew install "$name"; then
                        add_to_summary INSTALLED "$name" "$app_key"
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
        echo "Reviewing Homebrew clean candidates..."
        prepare_homebrew_clean_selection

        if [[ -z "$CLEAN_REMOVE_ENTRIES" ]]; then
            log_info "No Homebrew packages selected for removal"
            return 0
        fi

        local entry
        while IFS= read -r entry; do
            [[ -z "$entry" ]] && continue
            local kind name app_key state source
            IFS='|' read -r kind name app_key state source <<< "$entry"
            case "$kind" in
                brew)
                    log_warning "Removing $name"
                    brew uninstall "$name" 2>/dev/null || true
                    [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="${name}|-" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${name}|-"
                    ;;
                cask)
                    if [[ "$state" == "unmanaged" ]]; then
                        log_warning "Removing unmanaged app bundle(s) for $name"
                        if remove_unmanaged_cask_bundle "$name"; then
                            [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="${name}|-" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${name}|-"
                        else
                            log_warning "No app bundle removed for $name"
                        fi
                    else
                        log_warning "Removing $name"
                        brew uninstall --cask "$name" 2>/dev/null || true
                        [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="${name}|-" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${name}|-"
                    fi
                    ;;
            esac
        done <<< "$CLEAN_REMOVE_ENTRIES"
    fi
}
