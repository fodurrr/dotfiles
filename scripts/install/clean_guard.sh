# =============================================================================
# Clean Mode Safety Guards
# =============================================================================

check_clean_safety() {
    CLEAN_SAFE=true
    if [[ "$CLEAN_MODE" == true && "$CLEAN_SAFE" == true ]]; then
        if ! command -v yq &> /dev/null; then
            log_warning "yq not found; skipping clean mode to avoid accidental removals"
            CLEAN_SAFE=false
        elif [[ ! -s "$APPS_CONFIG" ]]; then
            log_warning "apps.toml missing or empty; skipping clean mode to avoid accidental removals"
            CLEAN_SAFE=false
        else
            # Ensure profile resolution yields at least one match
            local profile_match=false
            local app_key
            for app_key in $(get_all_apps); do
                if app_in_profile "$app_key"; then
                    profile_match=true
                    break
                fi
            done
            if [[ "$profile_match" != true ]]; then
                log_warning "No apps matched selected profiles; skipping clean mode to avoid accidental removals"
                CLEAN_SAFE=false
            fi
        fi
    fi
}
