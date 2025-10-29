#!/usr/bin/env bash
#
# install.sh - Modular Dotfiles Installer
#
# A flexible installer that supports multiple installation profiles:
# - quick: Essential tools only (3-5 min)
# - full: Everything including Devbox, Neovim, etc. (15-20 min)
# - custom: Interactive selection of components
#
# Usage:
#   ./install.sh              # Interactive mode - choose profile
#   ./install.sh --quick      # Quick profile
#   ./install.sh --full       # Full profile
#   ./install.sh --custom     # Custom selection
#   ./install.sh --help       # Show help

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/scripts/lib/common.sh"

# Profile scripts directory
PROFILES_DIR="$SCRIPT_DIR/scripts/profiles"

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Modular dotfiles installer with multiple installation profiles.

OPTIONS:
    --quick         Quick installation (essential tools only, 3-5 min)
    --full          Full installation (everything, 15-20 min)
    --custom        Custom installation (choose components)
    --help, -h      Show this help message

PROFILES:
    quick:
        • System base packages
        • Zsh + Starship + Zinit
        • Modern CLI tools (eza, fzf, bat, zoxide)
        • Git configuration
        • GNU Stow
        Time: ~3-5 minutes

    full:
        • Everything from quick profile
        • Neovim with LazyVim
        • Devbox (Nix-based dev environment)
        • Elixir 1.19.1 + Erlang OTP 28 (via Nix flakes)
        • Lazygit
        Time: ~15-20 minutes

    custom:
        • Interactive component selection
        • Choose exactly what you want to install

EXAMPLES:
    $0                  # Interactive mode - choose profile
    $0 --quick          # Quick installation
    $0 --full           # Full installation
    $0 --custom         # Custom component selection

For more information, see: docs/INSTALLATION.md
EOF
}

# Interactive profile selection
select_profile() {
    printf "\n" >&2
    printf "════════════════════════════════════════════════════════\n" >&2
    printf "           Dotfiles Installation\n" >&2
    printf "════════════════════════════════════════════════════════\n" >&2
    printf "\n" >&2
    printf "Choose an installation profile:\n" >&2
    printf "\n" >&2
    printf "  1) QUICK (~5 min)\n" >&2
    printf "     • System base packages\n" >&2
    printf "     • Zsh + Starship + Zinit\n" >&2
    printf "     • Modern CLI tools (eza, fzf, bat, zoxide)\n" >&2
    printf "     • Git + GitHub CLI\n" >&2
    printf "\n" >&2
    printf "  2) FULL (~15 min)\n" >&2
    printf "     • Everything from Quick\n" >&2
    printf "     • Neovim + LazyVim\n" >&2
    printf "     • Devbox (Nix-based dev environment)\n" >&2
    printf "     • Elixir 1.19.1 + Erlang OTP 28\n" >&2
    printf "     • LazyGit\n" >&2
    printf "\n" >&2
    printf "  3) CUSTOM\n" >&2
    printf "     • Interactive component selection\n" >&2
    printf "     • Choose exactly what you want\n" >&2
    printf "\n" >&2
    printf "════════════════════════════════════════════════════════\n" >&2
    printf "\n" >&2

    local choice
    while true; do
        printf "Enter your choice (1-3): " >&2
        read -r choice
        case "$choice" in
            1)
                echo "quick"
                return
                ;;
            2)
                echo "full"
                return
                ;;
            3)
                echo "custom"
                return
                ;;
            *)
                printf "✗ Invalid choice. Please enter 1, 2, or 3.\n" >&2
                ;;
        esac
    done
}

# Run the selected profile
run_profile() {
    local profile="$1"
    local profile_script="$PROFILES_DIR/${profile}.sh"

    if [[ ! -f "$profile_script" ]]; then
        die "Profile script not found: $profile_script"
    fi

    log_info "Running $profile profile..."
    echo

    # Execute the profile script
    bash "$profile_script" || die "Profile installation failed"
}

# Main function
main() {
    local profile=""

    # Parse arguments
    if [[ $# -eq 0 ]]; then
        # Interactive mode
        profile=$(select_profile)
    else
        case "$1" in
            --quick)
                profile="quick"
                ;;
            --full)
                profile="full"
                ;;
            --custom)
                profile="custom"
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo
                show_usage
                exit 1
                ;;
        esac
    fi

    # Validate profile
    if [[ -z "$profile" ]]; then
        die "No profile selected"
    fi

    # Run the profile
    run_profile "$profile"

    echo
    print_header "Installation Complete!"
    echo
    log_success "Profile '$profile' has been installed successfully"
    echo
    log_info "Next steps:"
    log_info "  1. Run './sync.sh' to symlink your dotfiles"
    log_info "  2. Log out and log back in (or run 'exec zsh')"
    log_info "  3. Enjoy your configured environment!"
    echo
}

# Run main with all arguments
main "$@"
