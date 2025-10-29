#!/usr/bin/env bash
#
# elixir-erlang.sh - Install Elixir and Erlang via Nix Flakes
#
# Installs Elixir 1.19.1 and Erlang OTP 28 using a custom Nix flake
# integrated with Devbox for package management.
#
# This component requires Devbox to be installed first.

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=scripts/lib/validation.sh
source "$SCRIPT_DIR/../lib/validation.sh"

readonly FLAKES_DIR="$HOME/.devbox-flakes/elixir"
readonly REPO_FLAKE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/flakes/elixir"

install_elixir_erlang() {
    # Check if already installed
    if skip_if_installed elixir "Elixir" && skip_if_installed erl "Erlang"; then
        local elixir_version
        local erlang_version
        elixir_version=$(elixir --version 2>/dev/null | head -n1 || echo "unknown")
        erlang_version=$(erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell 2>/dev/null || echo "unknown")
        log_info "Elixir version: $elixir_version"
        log_info "Erlang version: OTP $erlang_version"
        return 0
    fi

    gum_header "Installing Elixir & Erlang via Nix Flakes"

    # Verify devbox is installed
    if ! command_exists devbox; then
        die "Devbox is required but not installed. Please install Devbox first."
    fi

    log_step "Setting up Nix flake for Elixir/Erlang..."

    # Create flakes directory
    if [[ ! -d "$FLAKES_DIR" ]]; then
        log_info "Creating flakes directory at $FLAKES_DIR"
        mkdir -p "$FLAKES_DIR"
    fi

    # Copy flake.nix from repository
    if [[ -f "$REPO_FLAKE_DIR/flake.nix" ]]; then
        log_info "Copying flake.nix from repository..."
        cp "$REPO_FLAKE_DIR/flake.nix" "$FLAKES_DIR/flake.nix"
        log_success "Flake configuration copied"
    else
        die "Flake source not found at $REPO_FLAKE_DIR/flake.nix"
    fi

    # Initialize flake if needed
    if [[ ! -f "$FLAKES_DIR/flake.lock" ]]; then
        log_step "Initializing Nix flake..."
        cd "$FLAKES_DIR"
        nix flake update || die "Failed to initialize flake"
        log_success "Flake initialized"
    fi

    log_step "Adding Elixir and Erlang to devbox..."

    # Get the dotfiles directory
    local dotfiles_dir
    dotfiles_dir="$(cd "$SCRIPT_DIR/../.." && pwd)"

    # Add packages to devbox.json
    cd "$dotfiles_dir"

    # Check if packages are already in devbox.json
    if ! grep -q "path:$FLAKES_DIR#elixir" devbox.json 2>/dev/null; then
        log_info "Adding Elixir to devbox configuration..."
        # Use devbox add to add the package
        devbox add "path:$FLAKES_DIR#elixir" || log_warning "Could not add via devbox add, may need manual configuration"
    fi

    if ! grep -q "path:$FLAKES_DIR#erlang" devbox.json 2>/dev/null; then
        log_info "Adding Erlang to devbox configuration..."
        devbox add "path:$FLAKES_DIR#erlang" || log_warning "Could not add via devbox add, may need manual configuration"
    fi

    log_success "Elixir and Erlang configured in devbox"

    gum_header "Elixir & Erlang Installation Complete!"

    log_success "Elixir 1.19.1 and Erlang OTP 28 are now available via Devbox"
    echo
    log_info "To use Elixir and Erlang:"
    log_info "  1. cd to the dotfiles directory: cd ~/dotfiles"
    log_info "  2. Enter devbox shell: devbox shell"
    log_info "  3. Verify installation: elixir --version && erl -version"
    echo
    log_info "Flake location: $FLAKES_DIR"
    log_info "Flake source: $REPO_FLAKE_DIR"
}

# Validate installation
validate_installation() {
    log_step "Validating Elixir/Erlang installation..."

    # Check flake exists
    validate_file "$FLAKES_DIR/flake.nix" "Nix flake configuration"

    log_success "Validation complete"
}

# Main execution
main() {
    ensure_not_root
    ensure_internet

    install_elixir_erlang
    validate_installation
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
