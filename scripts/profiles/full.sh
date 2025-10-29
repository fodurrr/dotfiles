#!/usr/bin/env bash
#
# full.sh - Full Installation Profile
#
# Installs complete development environment:
# - Everything from Quick profile
# - Neovim + LazyVim
# - Devbox
# - LazyGit
#
# Estimated time: 10-15 minutes

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Get components directory
COMPONENTS_DIR="$SCRIPT_DIR/../components"

install_full_profile() {
    print_header "Full Profile Installation"

    log_info "This profile includes:"
    log_info "  • Everything from Quick profile"
    log_info "  • Neovim + LazyVim configuration"
    log_info "  • Devbox for package management"
    log_info "  • LazyGit"
    echo
    log_info "Estimated time: 10-15 minutes"
    echo

    # System base
    bash "$COMPONENTS_DIR/system-base.sh" || die "Failed to install system base"

    # Shell environment
    bash "$COMPONENTS_DIR/shell.sh" || die "Failed to install shell"

    # CLI tools
    bash "$COMPONENTS_DIR/cli-tools.sh" || die "Failed to install CLI tools"

    # Git configuration
    bash "$COMPONENTS_DIR/git-config.sh" || die "Failed to configure git"

    # Neovim
    bash "$COMPONENTS_DIR/neovim.sh" || die "Failed to install Neovim"

    # LazyGit
    bash "$COMPONENTS_DIR/lazygit.sh" || die "Failed to install LazyGit"

    # Devbox
    bash "$COMPONENTS_DIR/devbox.sh" || die "Failed to install Devbox"

    # Install stow if not already installed
    if ! command_exists stow; then
        log_step "Installing GNU Stow..."
        source "$SCRIPT_DIR/../lib/package-manager.sh"
        pm_install_if_missing stow
    fi

    print_header "Full Profile Installation Complete!"

    log_success "All components installed successfully"
    echo
    log_info "Next steps:"
    log_info "  1. Run './sync.sh' to symlink your dotfiles"
    log_info "  2. Log out and log back in (or run 'exec zsh')"
    log_info "  3. cd to dotfiles directory and run 'devbox shell'"
    log_info "  4. Run 'gh auth login' to authenticate with GitHub"
}

# Main execution
main() {
    ensure_not_root
    ensure_sudo
    ensure_internet
    ensure_disk_space 2000  # 2GB minimum

    # Pre-flight checks
    if ! is_supported_os; then
        log_error "Unsupported operating system"
        log_info "Supported systems: $(get_supported_os_list)"
        die "Please install on a supported OS"
    fi

    local os
    os=$(detect_os)
    log_info "Detected OS: $os"
    echo

    install_full_profile
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
