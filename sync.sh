#!/usr/bin/env bash
#
# sync.sh - Sync dotfiles using GNU Stow
#
# Creates symlinks from this repository to $HOME using GNU Stow
#
# Usage:
#   ./sync.sh           # Normal sync
#   ./sync.sh --dry-run # Show what would be done
#   ./sync.sh --backup  # Backup existing files before syncing
#   ./sync.sh --yes     # Skip confirmation prompts

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common libraries if available
if [[ -f "$SCRIPT_DIR/scripts/lib/common.sh" ]]; then
    # shellcheck source=scripts/lib/common.sh
    source "$SCRIPT_DIR/scripts/lib/common.sh"
else
    # Fallback logging functions
    log_info() { echo "ℹ $*"; }
    log_success() { echo "✓ $*"; }
    log_warning() { echo "⚠ $*"; }
    log_error() { echo "✗ $*" >&2; }
    log_step() { echo "→ $*"; }
    die() { log_error "$@"; exit 1; }
    command_exists() { command -v "$1" &>/dev/null; }
fi

# Configuration
DRY_RUN=false
BACKUP=false
SKIP_CONFIRM=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --backup|-b)
                BACKUP=true
                shift
                ;;
            --yes|-y)
                SKIP_CONFIRM=true
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

Sync dotfiles from this repository to \$HOME using GNU Stow.

OPTIONS:
    --dry-run, -n     Show what would be done without making changes
    --backup, -b      Backup existing files before creating symlinks
    --yes, -y         Skip confirmation prompts
    --help, -h        Show this help message

EXAMPLES:
    $0                    # Normal sync
    $0 --dry-run          # Preview changes
    $0 --backup           # Backup and sync
    $0 --backup --yes     # Backup and sync without prompts

NOTES:
    - Uses GNU Stow to create symlinks
    - Existing files will be backed up if --backup is specified
    - Conflicting files will prevent syncing (use --backup to resolve)

EOF
}

check_stow() {
    if ! command_exists stow; then
        die "GNU Stow is not installed. Please install it first."
    fi
}

backup_conflicting_files() {
    log_step "Checking for conflicting files..."

    local conflicts=()
    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d_%H%M%S)

    # Check for common dotfiles that might conflict
    local dotfiles=(
        ".zshrc"
        ".wezterm.lua"
        ".config/nvim"
        ".config/starship.toml"
        ".config/fabric"
    )

    for file in "${dotfiles[@]}"; do
        local target="$HOME/$file"
        local source="$SCRIPT_DIR/$file"

        # Skip if source doesn't exist in repo
        if [[ ! -e "$source" ]]; then
            continue
        fi

        # Check if target exists and is not a symlink
        if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
            conflicts+=("$target")
        fi
    done

    if [[ ${#conflicts[@]} -eq 0 ]]; then
        log_success "No conflicting files found"
        return 0
    fi

    log_warning "Found ${#conflicts[@]} conflicting file(s):"
    for file in "${conflicts[@]}"; do
        echo "  - $file"
    done

    if [[ "$BACKUP" == "true" ]]; then
        echo
        log_step "Backing up conflicting files..."

        for file in "${conflicts[@]}"; do
            local backup="${file}.backup.${backup_timestamp}"
            if [[ -f "$file" ]]; then
                cp "$file" "$backup"
                log_info "Backed up: $file -> $backup"
            elif [[ -d "$file" ]]; then
                cp -r "$file" "$backup"
                log_info "Backed up: $file -> $backup"
            fi

            # Remove the conflicting file
            rm -rf "$file"
        done

        log_success "Backup complete"
    else
        echo
        log_warning "Use --backup to automatically backup these files"
        log_warning "Or manually remove/backup them before running sync"
        return 1
    fi
}

run_stow() {
    cd "$SCRIPT_DIR" || die "Failed to cd to $SCRIPT_DIR"

    local stow_args=()

    if [[ "$DRY_RUN" == "true" ]]; then
        stow_args+=("--simulate" "--verbose")
        log_step "Running stow in dry-run mode..."
    else
        log_step "Syncing dotfiles with GNU Stow..."
    fi

    # Run stow
    if stow "${stow_args[@]}" .; then
        if [[ "$DRY_RUN" == "false" ]]; then
            log_success "Dotfiles synced successfully!"
        fi
    else
        log_error "Stow failed"
        log_info "Common issues:"
        log_info "  - Conflicting files exist (use --backup)"
        log_info "  - Permissions issues"
        log_info "  - Run with --dry-run to see what would change"
        return 1
    fi
}

show_next_steps() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo
        log_info "This was a dry-run. Run without --dry-run to actually sync."
        return
    fi

    echo
    log_success "Dotfiles are now symlinked!"
    echo
    log_info "Next steps:"
    log_info "  1. Source your new configuration: source ~/.zshrc"
    log_info "  2. Or start a new shell session: exec zsh"

    if [[ -d "$SCRIPT_DIR/.config/nvim" ]]; then
        echo
        log_info "Neovim configuration available:"
        log_info "  - Launch nvim to auto-install plugins"
    fi

    if [[ -f "$SCRIPT_DIR/devbox.json" ]]; then
        echo
        log_info "Devbox environment available:"
        log_info "  - cd $SCRIPT_DIR && devbox shell"
    fi
}

# Main execution
main() {
    parse_args "$@"

    check_stow

    # Show current directory
    log_info "Dotfiles directory: $SCRIPT_DIR"
    log_info "Target directory: $HOME"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Mode: Dry-run (no changes will be made)"
    fi

    echo

    # Check for conflicts and backup if needed
    if ! backup_conflicting_files; then
        die "Please resolve conflicts before syncing"
    fi

    # Confirm if not in silent mode
    if [[ "$SKIP_CONFIRM" == "false" ]] && [[ "$DRY_RUN" == "false" ]] && [[ -t 0 ]]; then
        echo
        read -rp "Proceed with syncing dotfiles? [Y/n] " response
        response=${response:-y}
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Sync cancelled"
            exit 0
        fi
    fi

    # Run stow
    if ! run_stow; then
        die "Sync failed"
    fi

    # Show next steps
    show_next_steps
}

# Run main
main "$@"
