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
    if has_gum; then
        gum style --foreground 212 --margin "1 0" --bold "Select components to install"
        gum style --foreground 246 --margin "0 2" --italic "Use Space to select, Enter to confirm"
        echo
    else
        log_step "Select components to install..."
        echo
    fi

    # Create options for gum
    local options=()
    for component in shell cli-tools git-config neovim lazygit devbox elixir-erlang; do
        options+=("${COMPONENTS[$component]}")
    done

    # Use gum to select
    local selected
    selected=$(printf '%s\n' "${options[@]}" | gum choose --no-limit --header "Components:" --cursor-prefix "[ ] " --selected-prefix "[✓] " --height 12) || true

    # Convert selections back to component names
    local -a selected_components=()
    selected_components+=("${REQUIRED_COMPONENTS[@]}")

    for component in shell cli-tools git-config neovim lazygit devbox elixir-erlang; do
        if echo "$selected" | grep -q "${COMPONENTS[$component]}"; then
            selected_components+=("$component")
        fi
    done

    echo "${selected_components[@]}"
}

select_components_fallback() {
    log_step "Select components to install..."
    echo
    log_info "Required: ${COMPONENTS[system-base]}"
    echo

    local -a selected_components=()
    selected_components+=("${REQUIRED_COMPONENTS[@]}")

    for component in shell cli-tools git-config neovim lazygit devbox elixir-erlang; do
        if ask_yes_no "Install ${COMPONENTS[$component]}?" "y"; then
            selected_components+=("$component")
        fi
    done

    echo "${selected_components[@]}"
}

select_components() {
    if has_gum; then
        select_components_with_gum
    else
        select_components_fallback
    fi
}

install_custom_profile() {
    gum_header "Custom Profile Installation"

    # Select components
    local selected_components
    read -ra selected_components <<< "$(select_components)"

    if [[ ${#selected_components[@]} -eq 0 ]]; then
        die "No components selected"
    fi

    echo
    if has_gum; then
        gum style --foreground 212 --margin "1 0" --bold "Selected components:"
        for component in "${selected_components[@]}"; do
            gum style --foreground 246 --margin "0 2" "• ${COMPONENTS[$component]}"
        done
        echo
    else
        log_info "Selected components:"
        for component in "${selected_components[@]}"; do
            log_info "  • ${COMPONENTS[$component]}"
        done
        echo
    fi

    if ! is_ci; then
        if ! gum_confirm "Proceed with installation?" "y"; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    # Install selected components
    local installed=0
    local failed=0

    for component in "${selected_components[@]}"; do
        echo
        gum_section "${COMPONENTS[$component]}"
        if bash "$COMPONENTS_DIR/$component.sh"; then
            ((installed++))
        else
            log_error "Failed to install $component"
            ((failed++))
        fi
    done

    # Install stow if needed and not already installed
    if ! command_exists stow; then
        gum_section "GNU Stow"
        source "$SCRIPT_DIR/../lib/package-manager.sh"
        pm_install_if_missing stow
    fi

    echo
    gum_header "Custom Profile Installation Complete!"
    echo

    log_success "Installed $installed component(s)"
    if [[ $failed -gt 0 ]]; then
        log_warning "Failed to install $failed component(s)"
    fi

    echo
    log_info "Next steps:"
    log_info "  1. Run './sync.sh' to symlink your dotfiles"
    log_info "  2. Log out and log back in (or run 'exec zsh')"
    if [[ " ${selected_components[*]} " =~ " devbox " ]]; then
        log_info "  3. cd to dotfiles directory and run 'devbox shell'"
    fi
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
