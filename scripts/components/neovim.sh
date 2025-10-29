#!/usr/bin/env bash
#
# neovim.sh - Install Neovim from GitHub releases
#
# Installs the latest stable Neovim release to /opt/nvim-linux64
# and creates a symlink in /usr/local/bin

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

readonly NVIM_INSTALL_DIR="/opt/nvim-linux64"
readonly NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"

install_neovim() {
    if skip_if_installed nvim "Neovim"; then
        local current_version
        current_version=$(nvim --version | head -n1)
        log_info "Current version: $current_version"

        # Ensure symlink exists even if nvim is already installed
        if [[ ! -L "/usr/local/bin/nvim" ]]; then
            log_step "Creating missing symlink in /usr/local/bin..."
            sudo ln -sf "$NVIM_INSTALL_DIR/bin/nvim" /usr/local/bin/nvim
            log_success "Symlink created"
        fi

        return 0
    fi

    print_header "Installing Neovim"

    log_step "Downloading latest Neovim release..."

    # Backup existing installation if it exists
    if [[ -d "$NVIM_INSTALL_DIR" ]]; then
        log_info "Backing up existing Neovim installation..."
        sudo mv "$NVIM_INSTALL_DIR" "${NVIM_INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Download Neovim
    local download_file="/tmp/nvim-linux64.tar.gz"
    download_file "$NVIM_DOWNLOAD_URL" "$download_file" || die "Failed to download Neovim"

    # Extract to /opt
    log_step "Extracting Neovim to /opt..."
    sudo tar -C /opt -xzf "$download_file" || die "Failed to extract Neovim"

    # Create symlink
    log_step "Creating symlink in /usr/local/bin..."
    sudo ln -sf "$NVIM_INSTALL_DIR/bin/nvim" /usr/local/bin/nvim

    # Clean up
    rm -f "$download_file"

    log_success "Neovim installed: $(nvim --version | head -n1)"
}

setup_lazyvim_config() {
    local nvim_config_dir="$HOME/.config/nvim"

    if [[ -d "$nvim_config_dir" ]]; then
        log_success "Neovim config already exists at $nvim_config_dir"
        return 0
    fi

    log_warning "Neovim config directory not found at $nvim_config_dir"
    log_info "Run './sync.sh' to symlink your LazyVim configuration"
}

# Main execution
main() {
    ensure_not_root
    ensure_sudo
    ensure_internet

    install_neovim
    setup_lazyvim_config

    # Validate installation
    log_step "Validating Neovim installation..."
    validate_command nvim
    validate_directory "$NVIM_INSTALL_DIR"
    validate_symlink /usr/local/bin/nvim "$NVIM_INSTALL_DIR/bin/nvim"

    log_success "Neovim installation complete!"
    echo
    log_info "Your LazyVim configuration will be available after running './sync.sh'"
    log_info "First launch will auto-install plugins (may take a few minutes)"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
