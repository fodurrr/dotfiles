# =============================================================================
# Layer 3: Mise (tools from apps.toml)
# =============================================================================

run_layer_mise() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 3: Mise"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if command -v mise &> /dev/null; then
        eval "$(mise activate bash)" 2>/dev/null || true
    fi

    echo "Installing mise tools..."
    local app_key
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "mise" ]]; then
                install_mise_app "$app_key"
            fi
        fi
    done

    if [[ "$CLEAN_MODE" == true ]]; then
        echo "Cleaning up mise tools not in selected profiles..."

        # Build list of tools that SHOULD be installed
        WANTED_TOOLS=()
        for app_key in $(get_all_apps); do
            if app_in_profile "$app_key"; then
                local type
                type=$(get_app_prop "$app_key" "type")
                if [[ "$type" == "mise" ]]; then
                    local name
                    name=$(get_app_prop "$app_key" "name")
                    [[ -z "$name" ]] && name="$app_key"
                    WANTED_TOOLS+=("$name")
                fi
            fi
        done

        # Get currently installed tools
        INSTALLED_TOOLS=$(mise list --current 2>/dev/null | awk '{print $1}' | sort -u)

        # Remove tools not in the wanted list
        local tool
        for tool in $INSTALLED_TOOLS; do
            if ! printf '%s\n' "${WANTED_TOOLS[@]}" | grep -qx "$tool"; then
                log_warning "Removing $tool"
                mise uninstall "$tool" --all 2>/dev/null || true
                # For removed tools, use tool name as both name and key (no description lookup)
                [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="${tool}|-" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${tool}|-"
            fi
        done

        # Prune old versions
        echo "Pruning old mise runtimes..."
        mise prune -y
    fi
}
