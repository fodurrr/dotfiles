#!/usr/bin/env bash
#
# custom.sh - Custom Installation Profile
#
# Allows user to select which components to install interactively.
# Uses gum for a nice TUI experience, falls back to simple prompts if gum is not available.

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Get components directory
COMPONENTS_DIR="$SCRIPT_DIR/../components"

# Component definitions
declare -A COMPONENTS=(
    ["system-base"]="System Base Packages (required)"
    ["shell"]="Zsh + Starship + Zinit"
    ["cli-tools"]="Modern CLI Tools (eza, fzf, bat, zoxide)"
    ["git-config"]="Git Configuration + GitHub CLI"
    ["neovim"]="Neovim + LazyVim"
    ["lazygit"]="LazyGit"
    ["devbox"]="Devbox"
    ["elixir-erlang"]="Elixir 1.19.1 + Erlang OTP 28 (requires Devbox)"
)

# Required components (always installed)
REQUIRED_COMPONENTS=("system-base")

select_components_with_gum() {
    # Create display options for gum choose
    local -a display_options=()
    local -a component_keys=(shell cli-tools git-config neovim lazygit devbox elixir-erlang)

    for key in "${component_keys[@]}"; do
        display_options+=("${COMPONENTS[$key]}")
    done

    # Use gum choose with display names as arguments (not piped)
    local selected
    selected=$(gum choose \
        --no-limit \
        --header "Select components to install (Space to select, Enter to confirm):" \
        --cursor-prefix "[ ] " \
        --selected-prefix "[✓] " \
        --height 12 \
        "${display_options[@]}") || true

    # Build array starting with required components
    local -a selected_components=("${REQUIRED_COMPONENTS[@]}")

    # Convert selected display names back to component keys
    if [[ -n "$selected" ]]; then
        while IFS= read -r display_name; do
            if [[ -n "$display_name" ]]; then
                # Find the key for this display name
                for key in "${component_keys[@]}"; do
                    if [[ "${COMPONENTS[$key]}" == "$display_name" ]]; then
                        selected_components+=("$key")
                        break
                    fi
                done
            fi
        done <<< "$selected"
    fi

    # Return the space-separated list
    echo "${selected_components[@]}"
}


install_custom_profile() {
    gum_header "Custom Profile Installation"

    # Select components
    local selected_components
    read -ra selected_components <<< "$(select_components_with_gum)"

    # Debug output
    log_info "DEBUG: Number of selected components: ${#selected_components[@]}"
    log_info "DEBUG: Components array: [${selected_components[*]}]"

    if [[ ${#selected_components[@]} -eq 0 ]]; then
        die "No components selected"
    fi

    echo
    # Show installation details
    gum style --foreground 212 --margin "1 0" --bold "Selected components:"
    for component in "${selected_components[@]}"; do
        log_info "DEBUG: Processing component: [$component]"
        if [[ -n "${COMPONENTS[$component]:-}" ]]; then
            gum style --foreground 246 --margin "0 2" "• ${COMPONENTS[$component]}"
        else
            log_error "DEBUG: No display name found for component: [$component]"
        fi
    done
    echo

    if ! is_ci; then
        if ! gum_confirm "Proceed with installation?" "y"; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    # Install selected components
    local installed=0
    local failed=0

    log_info "DEBUG: About to install ${#selected_components[@]} components"

    for component in "${selected_components[@]}"; do
        log_info "DEBUG: Loop iteration - component=[$component]"
        echo
        gum_section "Installing: ${COMPONENTS[$component]}"

        if [[ ! -f "$COMPONENTS_DIR/$component.sh" ]]; then
            log_error "Component script not found: $COMPONENTS_DIR/$component.sh"
            ((failed++))
            continue
        fi

        log_info "DEBUG: Executing: bash $COMPONENTS_DIR/$component.sh"
        if bash "$COMPONENTS_DIR/$component.sh"; then
            log_success "${COMPONENTS[$component]} installed successfully"
            ((installed++))
        else
            local exit_code=$?
            log_error "Failed to install ${COMPONENTS[$component]} (exit code: $exit_code)"
            ((failed++))
        fi
        log_info "DEBUG: After component - installed=$installed, failed=$failed"
    done

    log_info "DEBUG: Loop complete - installed=$installed, failed=$failed"

    # Install stow if needed and not already installed
    log_info "DEBUG: Checking for stow..."
    if ! command_exists stow; then
        log_info "DEBUG: stow not found, installing..."
        gum_section "GNU Stow"
        source "$SCRIPT_DIR/../lib/package-manager.sh"
        pm_install_if_missing stow
    else
        log_info "DEBUG: stow already installed"
    fi

    log_info "DEBUG: About to show completion header"
    echo
    gum_header "Custom Profile Installation Complete!"
    echo

    log_info "DEBUG: Showing results"
    log_success "Installed $installed component(s)"
    if [[ $failed -gt 0 ]]; then
        log_warning "Failed to install $failed component(s)"
    fi

    log_info "DEBUG: Showing next steps"
    echo
    log_info "Next steps:"
    log_info "  1. Run './sync.sh' to symlink your dotfiles"
    log_info "  2. Log out and log back in (or run 'exec zsh')"
    if [[ " ${selected_components[*]} " =~ " devbox " ]]; then
        log_info "  3. cd to dotfiles directory and run 'devbox shell'"
    fi

    log_info "DEBUG: install_custom_profile function ending"
}

# Main execution
main() {
    ensure_not_root
    ensure_sudo
    ensure_internet
    ensure_disk_space 1000  # 1GB minimum

    # Pre-flight checks
    if ! is_supported_os; then
        log_error "Unsupported operating system"
        log_info "Supported systems: $(get_supported_os_list)"
        die "Please install on a supported OS"
    fi

    local os
    os=$(detect_os)
    log_info "Detected OS: $os"
    echo

    install_custom_profile
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
