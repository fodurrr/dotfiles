#!/usr/bin/env bash
#
# git-config.sh - Configure git with user details and GitHub CLI
#
# Sets up:
# - Git global configuration
# - GitHub CLI (gh)

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/package-manager.sh
source "$SCRIPT_DIR/../lib/package-manager.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

configure_git() {
    print_header "Configuring Git"

    # Set default branch to main
    if [[ $(git config --global init.defaultBranch 2>/dev/null || echo "") != "main" ]]; then
        log_step "Setting default branch to 'main'..."
        git config --global init.defaultBranch main
    else
        log_info "Default branch already set to 'main'"
    fi

    # Set user name and email
    local current_name
    local current_email
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -z "$current_name" ]]; then
        log_step "Setting git user name..."
        git config --global user.name "Peter Fodor"
    else
        log_info "Git user name already set: $current_name"
    fi

    if [[ -z "$current_email" ]]; then
        log_step "Setting git user email..."
        git config --global user.email "fodurrr@gmail.com"
    else
        log_info "Git user email already set: $current_email"
    fi

    log_success "Git configuration complete"
}

install_github_cli() {
    if skip_if_installed gh "GitHub CLI"; then
        return 0
    fi

    log_step "Installing GitHub CLI (gh)..."

    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            # Add GitHub CLI repository
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
                sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null

            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
                sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

            PM_UPDATE_DONE=false
            pm_install gh
            ;;
        fedora)
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            PM_UPDATE_DONE=false
            pm_install gh
            ;;
        *)
            die "Unsupported OS for GitHub CLI installation: $os"
            ;;
    esac

    log_success "GitHub CLI installed: $(gh --version | head -n1)"
}

# Main execution
main() {
    ensure_not_root

    configure_git

    ensure_sudo
    ensure_internet
    install_github_cli

    # Validate
    log_step "Validating git configuration..."
    validate_command gh
    validate_git_config "init.defaultBranch" "main"
    validate_git_config "user.name"
    validate_git_config "user.email"

    log_success "Git and GitHub CLI setup complete!"
    echo
    log_info "To authenticate with GitHub, run: gh auth login"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
