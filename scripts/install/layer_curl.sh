# =============================================================================
# Layer 5: Curl installers
# =============================================================================

get_curl_tool_version() {
    local bin_name="$1"
    if command -v "$bin_name" >/dev/null 2>&1; then
        "$bin_name" --version 2>/dev/null | head -1
    fi
}

run_curl_installer() {
    local app_key="$1"
    case "$app_key" in
        claude-cli)
            curl -fsSL https://claude.ai/install.sh 2>/dev/null | bash 2>/dev/null
            ;;
        opencode-cli)
            curl -fsSL https://opencode.ai/install 2>/dev/null | bash 2>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

install_or_update_curl_tool() {
    local app_key="$1"
    local bin_name="$2"
    local summary_name="$3"

    local before_version
    before_version=$(get_curl_tool_version "$bin_name")

    log_success "Installing/updating $summary_name..."
    if ! run_curl_installer "$app_key"; then
        log_warning "Unknown curl installer: $app_key"
        return 0
    fi

    if ! command -v "$bin_name" >/dev/null 2>&1; then
        log_warning "Failed to install $summary_name"
        return 0
    fi

    local after_version
    after_version=$(get_curl_tool_version "$bin_name")

    if [[ -z "$before_version" || "$before_version" != "$after_version" ]]; then
        add_to_summary INSTALLED "$summary_name" "$app_key"
    else
        add_to_summary SKIPPED "$summary_name" "$app_key"
    fi
}

run_layer_curl() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 5: AI Coding Tools (curl)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    CURL_TOOLS_FOUND=false
    local app_key
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key"; then
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "curl" ]]; then
                CURL_TOOLS_FOUND=true
                case "$app_key" in
                    claude-cli)
                        install_or_update_curl_tool "$app_key" "claude" "claude-cli"
                        ;;
                    opencode-cli)
                        install_or_update_curl_tool "$app_key" "opencode" "opencode-cli"
                        ;;
                    *)
                        log_warning "Unknown curl installer: $app_key"
                        ;;
                esac
            fi
        fi
    done

    if [[ "$CURL_TOOLS_FOUND" == false ]]; then
        log_info "No curl-based tools in selected profiles"
    fi
}
