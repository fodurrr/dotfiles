# =============================================================================
# Layer 5: Curl fallback installers (exceptional cases)
# =============================================================================

get_curl_tool_version() {
    local bin_name="$1"
    if command -v "$bin_name" >/dev/null 2>&1; then
        "$bin_name" --version 2>/dev/null | head -1
    fi
}

install_codex_xpando_launcher() {
    local source_file="$DOTFILES_DIR/scripts/local-bin/codex-xpando"
    local bin_dir="$HOME/.local/bin"

    if [[ ! -f "$source_file" ]]; then
        log_error "codex-xpando launcher source missing: $source_file"
        return 1
    fi

    mkdir -p "$bin_dir"
    if ! cp "$source_file" "$bin_dir/codex-xpando"; then
        log_error "Failed to copy codex-xpando launcher to $bin_dir"
        return 1
    fi
    chmod +x "$bin_dir/codex-xpando"
    export PATH="$bin_dir:$PATH"
}

run_curl_installer() {
    local app_key="$1"
    case "$app_key" in
        codex-xpando)
            install_codex_xpando_launcher
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
        log_error "Failed curl installer for $summary_name ($app_key)"
        return 1
    fi

    if ! command -v "$bin_name" >/dev/null 2>&1; then
        log_error "Failed to install $summary_name"
        return 1
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
    echo "  Layer 5: Curl Fallback (Exceptional)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    CURL_TOOLS_FOUND=false
    local failed_count=0
    local failed_tools=""
    local app_key
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key"; then
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "curl" ]]; then
                CURL_TOOLS_FOUND=true
                case "$app_key" in
                    codex-xpando)
                        if ! install_or_update_curl_tool "$app_key" "codex-xpando" "codex-xpando"; then
                            failed_count=$((failed_count + 1))
                            failed_tools="${failed_tools} codex-xpando"
                        fi
                        ;;
                    *)
                        log_error "Unknown curl installer: $app_key"
                        failed_count=$((failed_count + 1))
                        failed_tools="${failed_tools} $app_key"
                        ;;
                esac
            fi
        fi
    done

    if [[ "$CURL_TOOLS_FOUND" == false ]]; then
        log_info "No curl-based tools in selected profiles"
        return 0
    fi

    if [[ "$failed_count" -gt 0 ]]; then
        log_error "Curl layer failed for selected tools:${failed_tools}"
        return 1
    fi
}
