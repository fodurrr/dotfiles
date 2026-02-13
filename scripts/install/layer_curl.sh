# =============================================================================
# Layer 5: Curl fallback installers (exceptional cases)
# =============================================================================

get_curl_tool_version() {
    local bin_name="$1"
    if command -v "$bin_name" >/dev/null 2>&1; then
        "$bin_name" --version 2>/dev/null | head -1
    fi
}

install_sheldon_linux_binary() {
    if [[ "$(get_current_platform)" != "linux" ]]; then
        log_error "sheldon-linux installer is only supported on Linux"
        return 1
    fi

    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        armv7l) arch="armv7" ;;
        *)
            log_error "Unsupported Linux architecture for sheldon: $(uname -m)"
            return 1
            ;;
    esac

    local api_url="https://api.github.com/repos/rossmacarthur/sheldon/releases/latest"
    local asset_url
    asset_url=$(curl -fsSL "$api_url" 2>/dev/null | grep -Eo "https://[^\\\"]*sheldon-[0-9.]+-${arch}-unknown-linux-musl\\.tar\\.gz" | head -1)
    if [[ -z "$asset_url" ]]; then
        log_error "Could not resolve sheldon release asset for architecture: $arch"
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if [[ ! -d "$tmp_dir" ]]; then
        log_error "Failed to create temp directory for sheldon installation"
        return 1
    fi

    local archive="$tmp_dir/sheldon.tar.gz"
    if ! curl -fsSL "$asset_url" -o "$archive"; then
        rm -rf "$tmp_dir"
        log_error "Failed to download sheldon release archive"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir"; then
        rm -rf "$tmp_dir"
        log_error "Failed to extract sheldon release archive"
        return 1
    fi

    local sheldon_bin
    sheldon_bin=$(find "$tmp_dir" -type f -name sheldon 2>/dev/null | head -1)
    if [[ -z "$sheldon_bin" ]]; then
        rm -rf "$tmp_dir"
        log_error "sheldon binary not found in downloaded archive"
        return 1
    fi

    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    if ! cp "$sheldon_bin" "$bin_dir/sheldon"; then
        rm -rf "$tmp_dir"
        log_error "Failed to copy sheldon binary to $bin_dir"
        return 1
    fi
    chmod +x "$bin_dir/sheldon"
    export PATH="$bin_dir:$PATH"
    rm -rf "$tmp_dir"
    return 0
}

run_curl_installer() {
    local app_key="$1"
    case "$app_key" in
        sheldon-linux)
            install_sheldon_linux_binary
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
                    sheldon-linux)
                        if ! install_or_update_curl_tool "$app_key" "sheldon" "sheldon"; then
                            failed_count=$((failed_count + 1))
                            failed_tools="${failed_tools} sheldon"
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
