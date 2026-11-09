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

# Put T3's own `t3` command on PATH, the way T3 installs it.
# The desktop app keeps a wrapper at ~/.t3/bin/t3 that follows app updates;
# a headless T3 service keeps runtimes under ~/.t3/runtime/versions/<v>/t3,
# and `t3 install` links ~/.local/bin/t3 to the one it runs from.
install_t3_cli_link() {
    local bin_dir="$HOME/.local/bin"
    local desktop_wrapper="$HOME/.t3/bin/t3"
    mkdir -p "$bin_dir"

    if [[ -x "$desktop_wrapper" ]]; then
        if ! ln -sfn "$desktop_wrapper" "$bin_dir/t3"; then
            log_error "Failed to link $bin_dir/t3 to $desktop_wrapper"
            return 1
        fi
        export PATH="$bin_dir:$PATH"
        return 0
    fi

    local runtime=""
    local state="$HOME/.t3/runtime/service-state.json"
    if [[ -f "$state" ]] && command -v jq >/dev/null 2>&1; then
        local active
        active=$(jq -r '.activeVersion // ""' "$state" 2>/dev/null)
        [[ -n "$active" && -x "$HOME/.t3/runtime/versions/$active/t3" ]] && runtime="$HOME/.t3/runtime/versions/$active/t3"
    fi
    if [[ -z "$runtime" ]]; then
        runtime=$(ls -d "$HOME"/.t3/runtime/versions/*/t3 2>/dev/null | sort -V | tail -1)
    fi
    if [[ -z "$runtime" || ! -x "$runtime" ]]; then
        log_error "No T3 found: neither the desktop wrapper $desktop_wrapper nor a runtime under ~/.t3/runtime/versions"
        return 1
    fi
    if ! "$runtime" install; then
        log_error "t3 install failed for $runtime"
        return 1
    fi
    export PATH="$bin_dir:$PATH"
}

run_curl_installer() {
    local app_key="$1"
    case "$app_key" in
        codex-xpando)
            install_codex_xpando_launcher
            ;;
        t3-cli)
            install_t3_cli_link
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
                    t3-cli)
                        if ! install_or_update_curl_tool "$app_key" "t3" "t3"; then
                            failed_count=$((failed_count + 1))
                            failed_tools="${failed_tools} t3-cli"
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
        for app_key in $failed_tools; do
            record_install_failure "$app_key" "Local launcher installation failed; see log"
        done
        log_error "Curl layer failed for selected tools:${failed_tools}"
        return 1
    fi
}
