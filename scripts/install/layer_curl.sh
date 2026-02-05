# =============================================================================
# Layer 5: Curl installers
# =============================================================================

run_layer_curl() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 5: AI Coding Tools (curl)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    CURL_TOOLS_FOUND=false
    local app_key
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "curl" ]]; then
                CURL_TOOLS_FOUND=true
                case "$app_key" in
                    claude-cli)
                        if command -v claude &> /dev/null; then
                            add_to_summary SKIPPED "claude-cli" "claude-cli"
                        else
                            log_success "Installing claude-cli..."
                            curl -fsSL https://claude.ai/install.sh 2>/dev/null | bash 2>/dev/null || true
                            # Verify installation succeeded by checking if binary exists
                            if command -v claude &> /dev/null; then
                                add_to_summary INSTALLED "claude-cli" "claude-cli"
                            else
                                log_warning "Failed to install claude-cli"
                            fi
                        fi
                        ;;
                    opencode-cli)
                        if command -v opencode &> /dev/null; then
                            add_to_summary SKIPPED "opencode-cli" "opencode-cli"
                        else
                            log_success "Installing opencode-cli..."
                            curl -fsSL https://opencode.ai/install 2>/dev/null | bash 2>/dev/null || true
                            # Verify installation succeeded by checking if binary exists
                            if command -v opencode &> /dev/null; then
                                add_to_summary INSTALLED "opencode-cli" "opencode-cli"
                            else
                                log_warning "Failed to install opencode-cli"
                            fi
                        fi
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
