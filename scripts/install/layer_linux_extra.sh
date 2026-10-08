#!/bin/bash
# =============================================================================
# Linux Extra Layer: fonts
# =============================================================================
# Handles Linux-only app types that the package, stow, mise and curl layers
# do not cover:
#   type = "font"    Nerd Font into the user font directory
# =============================================================================

install_linux_nerd_font() {
    local app_key="$1"
    local font_name
    font_name=$(get_app_prop "$app_key" "nerd_font")
    if [[ -z "$font_name" ]]; then
        log_error "Font app '$app_key' has no nerd_font property"
        return 1
    fi

    local font_dir="$HOME/.local/share/fonts/${font_name}NerdFont"
    if [[ -d "$font_dir" ]] && compgen -G "$font_dir/*.ttf" >/dev/null; then
        add_to_summary SKIPPED "$font_name Nerd Font" "$app_key"
        return 0
    fi

    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"
    local tmp_dir
    tmp_dir=$(mktemp -d) || return 1

    log_success "Installing $font_name Nerd Font..."
    if ! curl -fsSL "$url" -o "$tmp_dir/font.tar.xz"; then
        rm -rf "$tmp_dir"
        log_error "Failed to download $url"
        return 1
    fi

    mkdir -p "$font_dir"
    if ! tar -xJf "$tmp_dir/font.tar.xz" -C "$font_dir"; then
        rm -rf "$tmp_dir"
        log_error "Failed to extract $font_name Nerd Font"
        return 1
    fi
    rm -rf "$tmp_dir"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
    fi
    add_to_summary INSTALLED "$font_name Nerd Font" "$app_key"
}

run_layer_linux_extra() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 6: Linux Fonts"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local failed="" app_key type
    for app_key in $(get_all_apps); do
        app_selected_for_install "$app_key" || continue
        type=$(get_app_prop "$app_key" "type")
        case "$type" in
            font) install_linux_nerd_font "$app_key" || failed="$failed $app_key" ;;
        esac
    done

    if [[ -n "$failed" ]]; then
        log_error "Linux extra layer failed for:$failed"
        return 1
    fi
    log_success "Linux extra layer complete"
}

export -f run_layer_linux_extra
