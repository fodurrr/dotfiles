#!/usr/bin/env bash
#
# shell.sh - Install and configure zsh with starship and zinit
#
# Installs:
# - Zsh shell
# - Starship prompt
# - Zinit plugin manager

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

install_zsh() {
    if skip_if_installed zsh "Zsh"; then
        return 0
    fi

    log_step "Installing Zsh..."
    pm_install_if_missing zsh

    log_success "Zsh installed: $(zsh --version)"
}

install_starship() {
    if skip_if_installed starship "Starship prompt"; then
        return 0
    fi

    log_step "Installing Starship prompt..."

    # Install using official installer
    local install_script="/tmp/starship_install.sh"
    download_file "https://starship.rs/install.sh" "$install_script"
    chmod +x "$install_script"

    # Run installer with -y flag for non-interactive install
    if sudo "$install_script" -y; then
        log_success "Starship installed: $(starship --version)"
    else
        die "Failed to install Starship"
    fi

    rm -f "$install_script"
}

install_zinit() {
    local zinit_dir="${HOME}/.local/share/zinit"

    if [[ -d "$zinit_dir" ]]; then
        log_success "Zinit is already installed"
        return 0
    fi

    log_step "Installing Zinit plugin manager..."

    # Create directory
    mkdir -p "$zinit_dir"

    # Clone zinit repository
    git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir/zinit.git" || die "Failed to clone Zinit"

    log_success "Zinit installed to $zinit_dir"
}

configure_default_shell() {
    local current_shell
    current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "zsh" ]]; then
        log_success "Default shell is already zsh"
        return 0
    fi

    log_step "Changing default shell to zsh..."

    local zsh_path
    zsh_path=$(which zsh)

    # Check if zsh is in /etc/shells
    if ! grep -q "^${zsh_path}$" /etc/shells; then
        log_info "Adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change shell
    if chsh -s "$zsh_path"; then
        log_success "Default shell changed to zsh"
        log_warning "You need to log out and log back in for the change to take effect"
    else
        log_warning "Failed to change default shell. You can manually run: chsh -s $zsh_path"
    fi
}

# Main execution
main() {
    print_header "Installing Shell Environment"

    ensure_not_root
    ensure_sudo
    ensure_internet

    install_zsh
    install_starship
    install_zinit
    configure_default_shell

    # Validate installation
    log_step "Validating shell installation..."
    validate_command zsh
    validate_command starship
    validate_directory "${HOME}/.local/share/zinit"

    log_success "Shell environment installation complete!"
    echo
    log_info "Next steps:"
    log_info "  1. Run './sync.sh' to symlink .zshrc configuration"
    log_info "  2. Log out and log back in (or run 'exec zsh')"
    log_info "  3. Zinit will auto-install plugins on first zsh launch"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
