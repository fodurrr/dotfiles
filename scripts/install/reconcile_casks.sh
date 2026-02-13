# =============================================================================
# Reconcile casks to Homebrew ownership
# =============================================================================

append_reconcile_line() {
    local var_name="$1"
    local line="$2"
    local current
    current="${!var_name}"
    if [[ -z "$current" ]]; then
        printf -v "$var_name" '%s' "$line"
    else
        printf -v "$var_name" '%s\n%s' "$current" "$line"
    fi
}

prompt_reconcile_confirmation() {
    if [[ "$YES_MODE" == true || "$RECONCILE_DRY_RUN" == true ]]; then
        return 0
    fi

    echo ""
    echo "Reconciliation will migrate unmanaged /Applications casks to Homebrew ownership."
    if command -v gum >/dev/null 2>&1; then
        gum confirm "Continue with cask reconciliation?" || exit 0
    else
        read -r -p "Continue with cask reconciliation? (y/n) " reply
        case "$reply" in
            y|Y|yes|YES) ;;
            *) exit 0 ;;
        esac
    fi
}

quit_cask_apps_if_running() {
    local cask="$1"
    local path
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        local app_name
        app_name=$(basename "$path" .app)
        osascript -e "tell application \"$app_name\" to quit" >/dev/null 2>&1 || true
    done < <(get_cask_candidate_app_paths "$cask")
}

reconcile_single_cask() {
    local app_key="$1"
    local cask="$2"

    if [[ "$RECONCILE_DRY_RUN" == true ]]; then
        log_info "[dry-run] Would reconcile $cask"
        return 0
    fi

    quit_cask_apps_if_running "$cask"
    log_info "Reconciling $cask to Homebrew ownership..."
    local install_output=""
    local install_exit=0
    if [[ "$cask" == "stretchly" ]]; then
        if install_output=$(brew install --cask --force --no-quarantine "$cask" 2>&1); then
            install_exit=0
        else
            install_exit=$?
        fi
    else
        if install_output=$(brew install --cask --force "$cask" 2>&1); then
            install_exit=0
        else
            install_exit=$?
        fi
    fi

    if [[ "$install_exit" -ne 0 ]]; then
        local error_line
        error_line=$(echo "$install_output" | grep -Ei 'Error:|failed|permission|conflict|already exists|cannot|denied' | head -1)
        [[ -z "$error_line" ]] && error_line=$(echo "$install_output" | head -1)
        log_error "Reconcile failed for $cask (token: $cask)"
        [[ -n "$error_line" ]] && echo "      $error_line"
    fi

    if is_cask_brew_managed "$cask"; then
        add_to_summary INSTALLED "$cask (reconciled)" "$app_key"
        return 0
    fi

    log_error "Reconcile failed for $cask (token: $cask): still not Homebrew-managed"
    local path
    local printed_path=false
    while IFS= read -r path; do
        [[ -z "$path" ]] && continue
        if [[ -d "$path" ]]; then
            if [[ "$printed_path" != true ]]; then
                log_error "Detected unmanaged app path(s):"
                printed_path=true
            fi
            echo "      - $path"
        fi
    done < <(get_cask_candidate_app_paths "$cask")

    return 1
}

show_reconcile_summary_and_exit() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Reconciliation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [[ -n "$SUMMARY_INSTALLED" ]]; then
        echo -e "  ${GREEN}Reconciled${NC}"
        echo ""
        print_summary_table "$SUMMARY_INSTALLED" "✓" "Reconciled"
    fi

    if [[ -n "$SUMMARY_SKIPPED" ]]; then
        echo -e "  ${BLUE}Skipped${NC}"
        echo ""
        print_summary_table "$SUMMARY_SKIPPED" "ℹ" "Skipped"
    fi

    if [[ -z "$SUMMARY_INSTALLED" && -z "$SUMMARY_SKIPPED" ]]; then
        echo "  No reconciliation changes needed"
    fi

    echo ""
    exit 0
}

run_reconcile_casks() {
    if [[ "$RECONCILE_CASKS" != true ]]; then
        return 0
    fi

    if [[ "$(get_current_platform)" != "macos" ]]; then
        log_info "Skipping cask reconciliation (macOS-only)"
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Cask Reconciliation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local unmanaged_lines=""
    local app_key
    for app_key in $(get_all_apps); do
        if ! app_selected_for_install "$app_key"; then
            continue
        fi
        local type
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" != "cask" ]]; then
            continue
        fi

        local cask
        cask=$(get_app_prop "$app_key" "name")
        [[ -z "$cask" ]] && cask="$app_key"

        local state
        state=$(get_cask_install_state "$cask")
        case "$state" in
            unmanaged)
                append_reconcile_line unmanaged_lines "${app_key}|${cask}"
                ;;
            managed)
                :
                ;;
            missing)
                ;;
            *)
                log_warning "Unable to determine install state for $cask; skipping reconciliation"
                ;;
        esac
    done

    if [[ -z "$unmanaged_lines" ]]; then
        log_info "No unmanaged casks detected for selected apps"
        return 0
    fi

    echo "Unmanaged casks detected:"
    while IFS='|' read -r _ cask; do
        [[ -z "$cask" ]] && continue
        echo "  - $cask"
    done <<< "$unmanaged_lines"

    prompt_reconcile_confirmation

    local failed_reconciliations=""
    while IFS='|' read -r app_key cask; do
        [[ -z "$app_key" || -z "$cask" ]] && continue
        if ! reconcile_single_cask "$app_key" "$cask"; then
            if [[ -z "$failed_reconciliations" ]]; then
                failed_reconciliations="$cask"
            else
                failed_reconciliations="${failed_reconciliations}, $cask"
            fi
        fi
    done <<< "$unmanaged_lines"

    if [[ -n "$failed_reconciliations" ]]; then
        log_error "Cask reconciliation failed for: $failed_reconciliations"
        return 1
    fi
}
