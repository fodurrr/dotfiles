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


# Tailscale is not in the standard Ubuntu/Debian repositories. Keep the same
# app key on macOS; only Linux needs the vendor repository before apt/dnf.
prepare_linux_package_repository() {
    local app_key="$1" pm="$2" repository
    repository=$(get_app_prop "$app_key" "linux_repository")
    [[ -z "$repository" ]] && return 0
    if [[ "$repository" != "tailscale" ]]; then
        log_error "Unknown Linux repository: $repository"
        return 1
    fi
    local distro codename temp_dir base
    distro=$(. /etc/os-release && echo "$ID")
    codename=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
    temp_dir=$(mktemp -d) || return 1
    if [[ "$pm" == apt && ( "$distro" == ubuntu || "$distro" == debian ) && -n "$codename" ]]; then
        base="https://pkgs.tailscale.com/stable/$distro/$codename"
        if ! curl -fsSL "$base.noarmor.gpg" -o "$temp_dir/key" ||
           ! curl -fsSL "$base.tailscale-keyring.list" -o "$temp_dir/list" ||
           ! linux_extra_sudo install -d -m 755 /usr/share/keyrings ||
           ! linux_extra_sudo install -m 644 "$temp_dir/key" /usr/share/keyrings/tailscale-archive-keyring.gpg ||
           ! linux_extra_sudo install -m 644 "$temp_dir/list" /etc/apt/sources.list.d/tailscale.list; then
            rm -rf "$temp_dir"
            return 1
        fi
        rm -rf "$temp_dir"
        linux_extra_sudo apt-get update
        return $?
    elif [[ "$pm" == dnf && "$distro" == fedora ]]; then
        if ! curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o "$temp_dir/tailscale.repo" ||
           ! linux_extra_sudo install -m 644 "$temp_dir/tailscale.repo" /etc/yum.repos.d/tailscale.repo; then
            rm -rf "$temp_dir"
            return 1
        fi
        rm -rf "$temp_dir"
        return 0
    fi
    rm -rf "$temp_dir"
    log_error "Tailscale repository setup is unsupported on $distro with $pm"
    return 1
}

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
    local package_name="$2"
    LINUX_PACKAGE_RESULT=""
    local display_name
    display_name=$(get_app_display_name "$app_key")
    local pre_version
    pre_version=$(pm_get_version "$package_name" 2>/dev/null || true)
    [[ "$pre_version" == "unknown" ]] && pre_version=""

    log_success "Ensuring $display_name ($package_name) is installed and up-to-date..."
    if pm_install "$package_name"; then
        local post_version
        post_version=$(pm_get_version "$package_name" 2>/dev/null || true)
        [[ "$post_version" == "unknown" ]] && post_version=""

        if [[ -z "$pre_version" ]]; then
            add_to_summary INSTALLED "$display_name" "$app_key"
            LINUX_PACKAGE_RESULT="installed"
            return 0
        fi

        if [[ -n "$post_version" && "$pre_version" != "$post_version" ]]; then
            add_to_summary INSTALLED "$display_name" "$app_key"
            LINUX_PACKAGE_RESULT="installed"
            return 0
        fi

        add_to_summary SKIPPED "$display_name" "$app_key"
        LINUX_PACKAGE_RESULT="skipped"
        return 0
    fi

    log_error "Failed to install $display_name ($package_name)"
    record_install_failure "$app_key" "Package installation failed: $package_name"
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
            record_install_failure "$app_key" "No Linux package mapping for $pm"
            failed_count=$((failed_count + 1))
            failed_apps="$failed_apps $app_key"
            continue
        fi

        if ! prepare_linux_package_repository "$app_key" "$pm"; then
            record_install_failure "$app_key" "Could not configure vendor repository"
            failed_count=$((failed_count + 1))
            failed_apps="$failed_apps $app_key"
            continue
        fi

        if ! is_linux_repo_package_available "$pm" "$package_name"; then
            record_install_failure "$app_key" "Package '$package_name' unavailable in $pm repositories"
            failed_count=$((failed_count + 1))
            failed_apps="$failed_apps $app_key"
            continue
        fi

        if install_linux_mapped_brew_app "$app_key" "$package_name"; then
            local service
            service=$(get_app_prop "$app_key" "linux_service")
            if [[ -n "$service" ]] && ! linux_extra_sudo systemctl enable --now "$service"; then
                record_install_failure "$app_key" "Package installed but service $service could not start"
                failed_count=$((failed_count + 1))
                failed_apps="$failed_apps $app_key"
            fi
            if [[ "$LINUX_PACKAGE_RESULT" == "installed" ]]; then
                installed_count=$((installed_count + 1))
            else
                skipped_count=$((skipped_count + 1))
            fi
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
