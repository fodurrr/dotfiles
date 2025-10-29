#!/usr/bin/env bash
#
# cli-tools.sh - Install modern CLI tools
#
# Installs:
# - eza (modern ls replacement)
# - fzf (fuzzy finder)
# - bat (modern cat with syntax highlighting)
# - zoxide (smarter cd command)

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

install_eza() {
    if skip_if_installed eza "eza"; then
        return 0
    fi

    log_step "Installing eza..."

    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            # Add eza repository and GPG key
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
                sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg || die "Failed to add eza GPG key"

            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
                sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null

            PM_UPDATE_DONE=false  # Force update
            pm_install eza
            ;;
        fedora)
            # Enable COPR repository for eza
            pm_enable_copr atim/eza
            pm_install eza
            ;;
        *)
            die "Unsupported OS for eza installation: $os"
            ;;
    esac

    log_success "eza installed: $(eza --version | head -n1)"
}

install_fzf() {
    if skip_if_installed fzf "fzf"; then
        return 0
    fi

    log_step "Installing fzf..."

    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            pm_install fzf
            ;;
        fedora)
            pm_install fzf
            ;;
        *)
            die "Unsupported OS for fzf installation: $os"
            ;;
    esac

    log_success "fzf installed: $(fzf --version)"
}

install_bat() {
    # Check for both bat and batcat (Ubuntu uses batcat)
    if command_exists bat || command_exists batcat; then
        log_success "bat is already installed"
        return 0
    fi

    log_step "Installing bat..."

    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            pm_install bat

            # Ubuntu names it batcat, create symlink if needed
            if command_exists batcat && ! command_exists bat; then
                log_info "Creating symlink: bat -> batcat"
                mkdir -p "${HOME}/.local/bin"
                ln -sf "$(which batcat)" "${HOME}/.local/bin/bat"
            fi
            ;;
        fedora)
            pm_install bat
            ;;
        *)
            die "Unsupported OS for bat installation: $os"
            ;;
    esac

    # Verify installation
    if command_exists bat; then
        log_success "bat installed: $(bat --version)"
    elif command_exists batcat; then
        log_success "batcat installed: $(batcat --version)"
    else
        die "bat installation failed"
    fi
}

install_zoxide() {
    if skip_if_installed zoxide "zoxide"; then
        return 0
    fi

    log_step "Installing zoxide..."

    # Use official installer
    local install_script="/tmp/zoxide_install.sh"
    download_file "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" "$install_script"
    chmod +x "$install_script"

    if bash "$install_script"; then
        log_success "zoxide installed: $(zoxide --version 2>&1 || echo 'version check failed')"
    else
        die "Failed to install zoxide"
    fi

    rm -f "$install_script"
}

# Main execution
main() {
    print_header "Installing Modern CLI Tools"

    ensure_not_root
    ensure_sudo
    ensure_internet

    install_eza
    install_fzf
    install_bat
    install_zoxide

    # Validate installation
    log_step "Validating CLI tools installation..."
    validate_command eza
    validate_command fzf
    if ! validate_command bat 2>/dev/null; then
        validate_command batcat "bat/batcat is not installed"
    fi
    validate_command zoxide

    log_success "Modern CLI tools installation complete!"
    echo
    log_info "These tools will be aliased in your .zshrc:"
    log_info "  ls  -> eza"
    log_info "  cat -> bat"
    log_info "  cd  -> zoxide (via 'z' command)"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
