#!/usr/bin/env bash
#
# quick.sh - Quick/Minimal Installation Profile
#
# Installs essential tools for basic shell work:
# - System base packages
# - Zsh with Starship and Zinit
# - Modern CLI tools (eza, fzf, bat, zoxide)
# - Git configuration
# - GNU Stow for config management
#
# Estimated time: 3-5 minutes

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Get components directory
COMPONENTS_DIR="$SCRIPT_DIR/../components"

install_quick_profile() {
    gum_header "Quick Profile Installation"

    if has_gum; then
        gum style --foreground 212 --margin "1 0" --bold "This profile includes:"
        gum style --foreground 246 --margin "0 2" \
            "• System base packages" \
            "• Zsh + Starship + Zinit" \
            "• Modern CLI tools" \
            "• Git configuration" \
            "• GNU Stow"
        echo
        gum style --italic --foreground 208 "⏱️  Estimated time: 3-5 minutes"
        echo
    else
        log_info "This profile includes:"
        log_info "  • System base packages"
        log_info "  • Zsh + Starship + Zinit"
        log_info "  • Modern CLI tools"
        log_info "  • Git configuration"
        log_info "  • GNU Stow"
        echo
        log_info "Estimated time: 3-5 minutes"
        echo
    fi

    # System base
    gum_section "System Base Packages"
    bash "$COMPONENTS_DIR/system-base.sh" || die "Failed to install system base"

    # Shell environment
    gum_section "Shell Environment"
    bash "$COMPONENTS_DIR/shell.sh" || die "Failed to install shell"

    # CLI tools
    gum_section "CLI Tools"
    bash "$COMPONENTS_DIR/cli-tools.sh" || die "Failed to install CLI tools"

    # Git configuration
    gum_section "Git Configuration"
    bash "$COMPONENTS_DIR/git-config.sh" || die "Failed to configure git"

    # Install stow if not already installed
    if ! command_exists stow; then
        gum_section "GNU Stow"
        source "$SCRIPT_DIR/../lib/package-manager.sh"
        pm_install_if_missing stow
    fi

    echo
    gum_header "Quick Profile Installation Complete!"
    echo

    log_success "All components installed successfully"
    echo
    log_info "Next steps:"
    log_info "  1. Run './sync.sh' to symlink your dotfiles"
    log_info "  2. Log out and log back in (or run 'exec zsh')"
    log_info "  3. Enjoy your new shell environment!"
}

# Main execution
main() {
    ensure_not_root
    ensure_sudo
    ensure_internet
    ensure_disk_space 1000  # 1GB minimum

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

    install_quick_profile
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
