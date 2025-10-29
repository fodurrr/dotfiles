#!/usr/bin/env bash
#
# install.sh - Main installer for Peter's dotfiles
#
# Interactive installer with profile support:
# - Quick: Essential tools only (~5 min)
# - Full: Complete dev environment (~15 min)
# - Custom: Choose specific components
#
# Usage:
#   ./install.sh                    # Interactive mode
#   ./install.sh --profile quick    # Quick profile
#   ./install.sh --profile full     # Full profile
#   ./install.sh --profile custom   # Custom profile
#   ./install.sh --yes              # Skip confirmations
#   ./install.sh --help             # Show help

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common libraries
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/scripts/lib/common.sh"

# Configuration
PROFILE=""
SILENT_MODE=false
SKIP_SYNC=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --yes|-y)
                SILENT_MODE=true
                shift
                ;;
            --no-sync)
                SKIP_SYNC=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Interactive installer for Peter's dotfiles with modular profiles.

OPTIONS:
    --profile PROFILE    Installation profile (quick/full/custom)
    --yes, -y            Skip all confirmations
    --no-sync            Skip running sync.sh after installation
    --help, -h           Show this help message

PROFILES:
    quick      Essential tools only (zsh, starship, cli tools)
               Estimated time: ~5 minutes

    full       Complete development environment
               Includes: Neovim, Devbox, Fabric, LazyGit, and more
               Estimated time: ~15 minutes

    custom     Interactive component selection
               Choose exactly what you want to install

EXAMPLES:
    $0                           # Interactive mode
    $0 --profile quick           # Quick install
    $0 --profile full --yes      # Full install, no prompts
    $0 --profile custom          # Custom selection

For more information, see docs/INSTALLATION.md

EOF
}

show_welcome() {
    if command_exists gum; then
        gum style \
            --border double \
            --border-foreground 212 \
            --padding "1 2" \
            --margin "1" \
            "Welcome to Peter's Dotfiles Installer" \
            "" \
            "Modern development environment setup" \
            "Supports: Ubuntu, Debian, Fedora"
    else
        print_header "Peter's Dotfiles Installer"
        echo
        log_info "Modern development environment setup"
        log_info "Supports: Ubuntu, Debian, Fedora"
        echo
    fi
}

select_profile_with_gum() {
    log_step "Select installation profile..."
    echo

    local choice
    choice=$(gum choose \
        "Quick - Essential tools (~5 min)" \
        "Full - Complete environment (~15 min)" \
        "Custom - Choose components")

    case "$choice" in
        "Quick"*)
            echo "quick"
            ;;
        "Full"*)
            echo "full"
            ;;
        "Custom"*)
            echo "custom"
            ;;
        *)
            die "Invalid selection"
            ;;
    esac
}

select_profile_fallback() {
    log_step "Select installation profile..."
    echo
    log_info "1) Quick - Essential tools (~5 min)"
    log_info "2) Full - Complete environment (~15 min)"
    log_info "3) Custom - Choose components"
    echo

    while true; do
        read -rp "Enter your choice (1-3): " choice
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
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

select_profile() {
    if [[ -n "$PROFILE" ]]; then
        echo "$PROFILE"
        return
    fi

    if command_exists gum && [[ "$SILENT_MODE" == "false" ]]; then
        select_profile_with_gum
    else
        select_profile_fallback
    fi
}

confirm_installation() {
    local profile="$1"

    if [[ "$SILENT_MODE" == "true" ]] || is_ci; then
        return 0
    fi

    echo
    print_separator "─"
    log_info "Profile: $profile"
    log_info "OS: $(detect_os)"
    log_info "Location: $SCRIPT_DIR"
    print_separator "─"
    echo

    if command_exists gum; then
        gum confirm "Start installation?" || return 1
    else
        ask_yes_no "Start installation?" "y" || return 1
    fi
}

run_profile() {
    local profile="$1"
    local profile_script="$SCRIPT_DIR/scripts/profiles/$profile.sh"

    if [[ ! -f "$profile_script" ]]; then
        die "Profile script not found: $profile_script"
    fi

    log_step "Running $profile profile..."
    echo

    if bash "$profile_script"; then
        return 0
    else
        die "Profile installation failed"
    fi
}

run_sync() {
    if [[ "$SKIP_SYNC" == "true" ]]; then
        log_info "Skipping sync (--no-sync specified)"
        return 0
    fi

    local sync_script="$SCRIPT_DIR/sync.sh"

    if [[ ! -f "$sync_script" ]]; then
        log_warning "sync.sh not found, skipping dotfile sync"
        return 0
    fi

    echo
    log_step "Syncing dotfiles..."

    if [[ "$SILENT_MODE" == "true" ]] || is_ci; then
        bash "$sync_script" --yes 2>/dev/null || bash "$sync_script"
    else
        if command_exists gum; then
            if gum confirm "Sync dotfiles now?"; then
                bash "$sync_script"
            fi
        else
            if ask_yes_no "Sync dotfiles now?" "y"; then
                bash "$sync_script"
            fi
        fi
    fi
}

show_completion_summary() {
    echo
    if command_exists gum; then
        gum style \
            --border double \
            --border-foreground 82 \
            --padding "1 2" \
            --margin "1" \
            "✓ Installation Complete!" \
            "" \
            "Your development environment is ready."
    else
        print_header "✓ Installation Complete!"
        log_success "Your development environment is ready"
    fi

    echo
    log_info "Next steps:"
    log_info "  1. Log out and log back in (or run 'exec zsh')"
    log_info "  2. Your shell and tools will be ready to use"

    if [[ -d "$SCRIPT_DIR/devbox.json" ]]; then
        log_info "  3. Run 'devbox shell' in the dotfiles directory"
    fi

    echo
    log_info "Documentation: $SCRIPT_DIR/docs/"
    log_info "Issues: https://github.com/fodurrr/dotfiles/issues"
}

# Main execution
main() {
    parse_args "$@"

    # Show welcome screen
    show_welcome

    # Pre-flight checks
    ensure_not_root
    ensure_internet

    if ! is_supported_os; then
        log_error "Unsupported operating system: $(detect_os)"
        log_info "Supported systems: $(get_supported_os_list)"
        die "Please install on a supported OS"
    fi

    # Select profile
    local profile
    profile=$(select_profile)

    if [[ ! "$profile" =~ ^(quick|full|custom)$ ]]; then
        die "Invalid profile: $profile"
    fi

    # Confirm installation
    if ! confirm_installation "$profile"; then
        log_info "Installation cancelled"
        exit 0
    fi

    # Run profile installation
    run_profile "$profile"

    # Sync dotfiles
    run_sync

    # Show completion summary
    show_completion_summary
}

# Run main
main "$@"
