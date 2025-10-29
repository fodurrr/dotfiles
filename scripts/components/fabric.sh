#!/usr/bin/env bash
#
# fabric.sh - Install Fabric AI tool
#
# Installs Fabric using go install and sets up configuration

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

install_go() {
    if command_exists go; then
        log_info "Go is already installed: $(go version)"
        return 0
    fi

    log_step "Installing Go..."

    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            # Remove old go if installed via apt
            if pm_is_installed golang-go; then
                log_warning "Removing old Go from apt..."
                pm_remove golang-go
            fi

            # Install latest Go from official site
            local go_version="1.22.1"
            local go_url="https://go.dev/dl/go${go_version}.linux-amd64.tar.gz"
            local download_file="/tmp/go.tar.gz"

            log_step "Downloading Go $go_version..."
            download_file "$go_url" "$download_file"

            log_step "Installing Go to /usr/local..."
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf "$download_file"

            rm -f "$download_file"
            ;;
        fedora)
            pm_install golang
            ;;
        *)
            die "Unsupported OS for Go installation: $os"
            ;;
    esac

    # Add Go to PATH for current session
    export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"

    log_success "Go installed: $(go version)"
}

install_fabric() {
    # Check if fabric is already installed
    if command_exists fabric || [[ -f "$HOME/go/bin/fabric" ]]; then
        log_success "Fabric is already installed"
        return 0
    fi

    print_header "Installing Fabric AI Tool"

    # Ensure Go is installed
    install_go

    # Ensure GOPATH/bin is in PATH
    export PATH="$HOME/go/bin:$PATH"

    log_step "Installing Fabric via go install..."
    go install github.com/danielmiessler/fabric@latest || die "Failed to install Fabric"

    log_success "Fabric installed to $HOME/go/bin/fabric"
}

setup_fabric_config() {
    local fabric_config_dir="$HOME/.config/fabric"

    if [[ -d "$fabric_config_dir" ]]; then
        log_success "Fabric config already exists at $fabric_config_dir"
        return 0
    fi

    log_info "Fabric config directory not found"
    log_info "Run './sync.sh' to symlink your Fabric configuration"
    log_info "Then run 'fabric --setup' to complete the setup"
}

# Main execution
main() {
    ensure_not_root
    ensure_internet

    install_fabric
    setup_fabric_config

    # Validate
    log_step "Validating Fabric installation..."
    if [[ -f "$HOME/go/bin/fabric" ]]; then
        validate_executable "$HOME/go/bin/fabric"
        log_success "Fabric is installed at $HOME/go/bin/fabric"
    else
        die "Fabric installation failed"
    fi

    log_success "Fabric installation complete!"
    echo
    log_info "Next steps:"
    log_info "  1. Ensure $HOME/go/bin is in your PATH"
    log_info "  2. Run './sync.sh' to symlink config"
    log_info "  3. Add API keys to .config/fabric/.env"
    log_info "  4. Run 'fabric --setup' if needed"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
