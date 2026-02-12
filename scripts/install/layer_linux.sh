#!/bin/bash
# =============================================================================
# Linux Installation Layer
# =============================================================================
# Installs apps on Linux using apt/dnf package managers.
# Package names come from apps.toml metadata (linux_name/linux_apt/linux_dnf).
# =============================================================================

source "$DOTFILES_DIR/scripts/lib/platform.sh"
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"
source "$DOTFILES_DIR/scripts/lib/app_config.sh"
source "$DOTFILES_DIR/scripts/lib/logging.sh"
source "$DOTFILES_DIR/scripts/lib/summary.sh"

is_linux_repo_package_available() {
    local pm="$1"
    local package="$2"

    case "$pm" in
        apt)
            apt-cache show "$package" >/dev/null 2>&1
            ;;
        dnf)
            dnf info "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

install_linux_mapped_brew_app() {
    local app_key="$1"
    local pm="$2"
    local package_name="$3"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    if pm_is_installed "$package_name"; then
        log_info "$display_name already installed ($package_name)"
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    log_success "Installing $display_name ($package_name)..."
    if pm_install "$package_name"; then
        add_to_summary INSTALLED "$display_name" "$app_key"
        return 0
    fi

    log_error "Failed to install $display_name ($package_name)"
    add_to_summary SKIPPED "$display_name" "$app_key"
    return 1
}

run_layer_linux() {
    local platform
    platform=$(detect_platform)

    if [[ "$platform" != "linux" ]]; then
        log_info "Skipping Linux layer (not a Linux system)"
        return 0
    fi

    local pm
    pm=$(pm_get_manager)
    if [[ "$pm" != "apt" && "$pm" != "dnf" ]]; then
        log_warning "Unsupported Linux package manager: $pm"
        return 0
    fi

    local distro
    distro=$(detect_linux_distro)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 1: Linux Packages ($pm)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "Detected Linux distribution: $distro"

    local apps
    apps=$(get_all_apps)

    local installed_count=0
    local skipped_count=0
    local failed_count=0
    local failed_apps=""
    local app_key

    for app_key in $apps; do
        if ! app_selected_for_install "$app_key"; then
            continue
        fi

        local app_type
        app_type=$(get_app_prop "$app_key" "type")
        if [[ "$app_type" != "brew" ]]; then
            continue
        fi

        local package_name
        package_name=$(get_linux_package_name "$app_key" "$pm")
        local display_name
        display_name=$(get_app_display_name "$app_key")

        if [[ -z "$package_name" ]]; then
            log_info "Skipping $display_name (no Linux package mapping for $pm)"
            add_to_summary SKIPPED "$display_name" "$app_key"
            skipped_count=$((skipped_count + 1))
            continue
        fi

        if ! is_linux_repo_package_available "$pm" "$package_name"; then
            log_info "Skipping $display_name (package '$package_name' unavailable in $pm repos)"
            add_to_summary SKIPPED "$display_name" "$app_key"
            skipped_count=$((skipped_count + 1))
            continue
        fi

        if install_linux_mapped_brew_app "$app_key" "$pm" "$package_name"; then
            installed_count=$((installed_count + 1))
        else
            failed_count=$((failed_count + 1))
            if [[ -z "$failed_apps" ]]; then
                failed_apps="$display_name"
            else
                failed_apps="${failed_apps}, $display_name"
            fi
        fi
    done

    echo ""
    if [[ "$failed_count" -gt 0 ]]; then
        log_error "Linux layer failed for selected apps: $failed_apps"
        log_error "Linux layer summary: $installed_count installed, $skipped_count skipped, $failed_count failed"
        return 1
    fi

    log_success "Linux layer complete: $installed_count installed, $skipped_count skipped"
}

export -f run_layer_linux
