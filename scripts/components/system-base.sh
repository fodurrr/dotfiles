#!/usr/bin/env bash
#
# system-base.sh - Install base system packages
#
# Installs essential system utilities and development tools required for
# a functional development environment.

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

install_system_base() {
    gum_header "Installing Base System Packages"

    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            install_system_base_debian
            ;;
        fedora)
            install_system_base_fedora
            ;;
        *)
            die "Unsupported operating system: $os"
            ;;
    esac

    log_success "Base system packages installed"
}

install_system_base_debian() {
    log_step "Installing base packages for Ubuntu/Debian..."

    local packages=(
        # Essential utilities
        curl
        wget
        git
        build-essential

        # Compression tools
        unzip
        zip
        tar
        gzip

        # Security and GPG
        gpg
        ca-certificates

        # Clipboard utilities
        xclip
        xsel

        # System utilities
        xdg-utils
        software-properties-common
        apt-transport-https

        # Development tools
        pkg-config
        libssl-dev

        # Network tools
        net-tools
        dnsutils
    )

    pm_install_packages "${packages[@]}"
}

install_system_base_fedora() {
    log_step "Installing base packages for Fedora..."

    # Install Development Tools group if not already installed
    if ! pm_is_group_installed "Development Tools"; then
        log_step "Installing Development Tools group..."
        pm_install_group "Development Tools"
    else
        log_info "Development Tools group already installed"
    fi

    local packages=(
        # Essential utilities
        curl
        wget
        git

        # Compression tools
        unzip
        zip
        tar
        gzip

        # Security and GPG
        gpg
        gnupg2
        ca-certificates

        # Clipboard utilities
        xclip
        xsel

        # System utilities
        xdg-utils

        # Development tools
        pkg-config
        openssl-devel

        # Network tools
        net-tools
        bind-utils
    )

    pm_install_packages "${packages[@]}"
}

# Main execution
main() {
    ensure_not_root
    ensure_sudo
    ensure_internet

    install_system_base

    # Validate installation
    log_step "Validating base system installation..."
    validate_command git "Git is not installed"
    validate_command curl "curl is not installed"
    validate_command wget "wget is not installed"

    log_success "System base installation complete!"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
