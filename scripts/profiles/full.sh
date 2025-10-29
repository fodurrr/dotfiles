#!/usr/bin/env bash
#
# full.sh - Full Installation Profile
#
# Installs complete development environment:
# - Everything from Quick profile
# - Neovim + LazyVim
# - Devbox
# - Elixir + Erlang (via Nix flakes)
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
    gum_header "Full Profile Installation"

    if has_gum; then
        gum style --foreground 212 --margin "1 0" --bold "This profile includes:"
        gum style --foreground 246 --margin "0 2" \
            "• Everything from Quick profile" \
            "• Neovim + LazyVim configuration" \
            "• Devbox for package management" \
            "• Elixir 1.19.1 + Erlang OTP 28 (via Nix flakes)" \
            "• LazyGit"
        echo
        gum style --italic --foreground 208 "⏱️  Estimated time: 10-15 minutes"
        echo
    else
        log_info "This profile includes:"
        log_info "  • Everything from Quick profile"
        log_info "  • Neovim + LazyVim configuration"
        log_info "  • Devbox for package management"
        log_info "  • Elixir 1.19.1 + Erlang OTP 28 (via Nix flakes)"
        log_info "  • LazyGit"
        echo
        log_info "Estimated time: 10-15 minutes"
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

    # Neovim
    gum_section "Neovim + LazyVim"
    bash "$COMPONENTS_DIR/neovim.sh" || die "Failed to install Neovim"

    # LazyGit
    gum_section "LazyGit"
    bash "$COMPONENTS_DIR/lazygit.sh" || die "Failed to install LazyGit"

    # Devbox
    gum_section "Devbox"
    bash "$COMPONENTS_DIR/devbox.sh" || die "Failed to install Devbox"

    # Elixir & Erlang (requires Devbox)
    gum_section "Elixir & Erlang"
    bash "$COMPONENTS_DIR/elixir-erlang.sh" || die "Failed to install Elixir/Erlang"

    # Install stow if not already installed
    if ! command_exists stow; then
        gum_section "GNU Stow"
        source "$SCRIPT_DIR/../lib/package-manager.sh"
        pm_install_if_missing stow
    fi

    echo
    gum_header "Full Profile Installation Complete!"
    echo

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
