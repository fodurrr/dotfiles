#!/usr/bin/env bash
#
# devbox.sh - Install Devbox from Jetify
#
# Installs Devbox for Nix-based development environment management

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

install_devbox() {
    if skip_if_installed devbox "Devbox"; then
        return 0
    fi

    print_header "Installing Devbox"

    log_step "Downloading Devbox installer..."

    # Use official Devbox installer
    curl -fsSL https://get.jetpack.io/devbox | bash || die "Failed to install Devbox"

    log_success "Devbox installed: $(devbox version)"
}

setup_devbox_config() {
    local dotfiles_root
    dotfiles_root=$(get_dotfiles_root)

    if [[ ! -f "$dotfiles_root/devbox.json" ]]; then
        log_warning "devbox.json not found in $dotfiles_root"
        return 1
    fi

    log_info "Devbox configuration found at $dotfiles_root/devbox.json"
    log_info "To use Devbox environment, run: cd $dotfiles_root && devbox shell"
}

# Main execution
main() {
    ensure_not_root
    ensure_internet

    install_devbox
    setup_devbox_config

    # Validate
    log_step "Validating Devbox installation..."
    validate_command devbox
    validate_executable "$(which devbox)"

    log_success "Devbox installation complete!"
    echo
    log_info "Next steps:"
    log_info "  1. cd to your dotfiles directory"
    log_info "  2. Run 'devbox shell' to enter the dev environment"
    log_info "  3. All devbox packages will be available inside the shell"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
