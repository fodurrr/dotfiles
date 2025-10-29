#!/usr/bin/env bash
#
# setup.sh - Master Setup Orchestrator
#
# One-command setup script that:
# 1. Clones the dotfiles repo (if needed)
# 2. Runs the installer
# 3. Syncs dotfiles
# 4. Sets up shell
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fodurrr/dotfiles/main/setup.sh | bash
#   OR
#   ./setup.sh [install.sh options]

set -euo pipefail

# Configuration
DOTFILES_REPO="https://github.com/fodurrr/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

# Colors
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RED='\033[0;31m'

log_info() {
    echo -e "${COLOR_BLUE}ℹ${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}✗${COLOR_RESET} $*" >&2
}

die() {
    log_error "$@"
    exit 1
}

command_exists() {
    command -v "$1" &>/dev/null
}

# Clone dotfiles if not already present
clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        log_info "Dotfiles directory already exists at $DOTFILES_DIR"

        # Check if it's a git repo
        if [[ -d "$DOTFILES_DIR/.git" ]]; then
            log_info "Updating existing dotfiles..."
            cd "$DOTFILES_DIR"
            git pull origin "$DOTFILES_BRANCH" || log_error "Failed to update dotfiles"
        else
            log_error "$DOTFILES_DIR exists but is not a git repository"
            die "Please remove or backup $DOTFILES_DIR and try again"
        fi
    else
        log_info "Cloning dotfiles to $DOTFILES_DIR..."

        if ! command_exists git; then
            log_error "Git is not installed"
            die "Please install git first: sudo apt install git (Ubuntu) or sudo dnf install git (Fedora)"
        fi

        git clone -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR" || die "Failed to clone dotfiles"
        log_success "Dotfiles cloned successfully"
    fi
}

# Run the installer
run_installer() {
    cd "$DOTFILES_DIR"

    if [[ ! -f "install-new.sh" ]]; then
        die "install-new.sh not found in $DOTFILES_DIR"
    fi

    log_info "Running installer..."
    bash install-new.sh "$@"
}

# Main execution
main() {
    echo "================================================"
    echo "  Peter's Dotfiles Setup"
    echo "================================================"
    echo

    # Check for internet connection
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        die "No internet connection detected"
    fi

    # Clone or update dotfiles
    clone_dotfiles

    # Run installer with all passed arguments
    run_installer "$@"

    echo
    log_success "Setup complete!"
    echo
    log_info "Dotfiles location: $DOTFILES_DIR"
    log_info "To update in the future, run: cd $DOTFILES_DIR && git pull"
}

# Run main with all arguments
main "$@"
