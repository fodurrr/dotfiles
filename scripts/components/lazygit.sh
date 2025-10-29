#!/usr/bin/env bash
#
# lazygit.sh - Install LazyGit from GitHub releases
#
# Installs the latest LazyGit release

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

install_lazygit() {
    if skip_if_installed lazygit "LazyGit"; then
        return 0
    fi

    print_header "Installing LazyGit"

    log_step "Fetching latest LazyGit release..."

    # Get latest version
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | \
        grep "browser_download_url.*Linux_x86_64.tar.gz" | \
        cut -d '"' -f 4) || die "Failed to fetch LazyGit release info"

    if [[ -z "$latest_url" ]]; then
        die "Could not find LazyGit download URL"
    fi

    log_step "Downloading LazyGit..."
    local download_file="/tmp/lazygit.tar.gz"
    download_file "$latest_url" "$download_file" || die "Failed to download LazyGit"

    # Extract to /tmp and install
    log_step "Installing LazyGit..."
    tar -C /tmp -xzf "$download_file" lazygit || die "Failed to extract LazyGit"
    sudo install /tmp/lazygit /usr/local/bin/lazygit || die "Failed to install LazyGit"

    # Clean up
    rm -f "$download_file" /tmp/lazygit

    log_success "LazyGit installed: $(lazygit --version)"
}

# Main execution
main() {
    ensure_not_root
    ensure_sudo
    ensure_internet

    install_lazygit

    # Validate
    log_step "Validating LazyGit installation..."
    validate_command lazygit
    validate_executable /usr/local/bin/lazygit

    log_success "LazyGit installation complete!"
    echo
    log_info "Run 'lazygit' or use the 'lg' alias in zsh"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
