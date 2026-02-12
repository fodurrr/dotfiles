#!/bin/bash
# =============================================================================
# Linux Installation Layer
# =============================================================================
# Installs applications on Linux using apt or dnf package managers
# Runs after bootstrap, before stow/mise layers
# =============================================================================

# Source libraries
source "$DOTFILES_DIR/scripts/lib/platform.sh"
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"
source "$DOTFILES_DIR/scripts/lib/app_config.sh"
source "$DOTFILES_DIR/scripts/lib/app_state.sh"
source "$DOTFILES_DIR/scripts/lib/logging.sh"

# =============================================================================
# Helper Functions
# =============================================================================

# Convert Homebrew package name to Linux equivalent
# Maps brew package names to apt/dnf equivalents
map_brew_to_linux_package() {
    local brew_name="$1"
    local distro
    distro=$(detect_linux_distro)

    # Common mappings
    case "$brew_name" in
        # Shell and CLI tools (usually same name)
        bash|zsh|fish)
            echo "$brew_name"
            ;;
        # Version managers
        node|node@*)
            echo "nodejs"
            ;;
        python|python@*)
            echo "python3"
            ;;
        ruby|ruby@*)
            echo "ruby"
            ;;
        go|golang)
            echo "golang"
            ;;
        rust)
            echo "rustc"
            ;;
        # CLI tools (usually same name)
        git|curl|wget|ripgrep|rg|fd|fzf|bat|exa|eza)
            echo "$brew_name"
            ;;
        yazi)
            echo "$brew_name"
            ;;
        jq)
            echo "jq"
            ;;
        delta)
            echo "git-delta"
            ;;
        lazygit)
            echo "$brew_name"
            ;;
        gh)
            echo "gh"
            ;;
        zoxide)
            echo "$brew_name"
            ;;
        tldr)
            echo "tldr"
            ;;
        # Development tools
        docker|docker-compose)
            echo "$brew_name"
            ;;
        # Text editors
        neovim|vim|emacs)
            echo "$brew_name"
            ;;
        # Terminal emulators (GUI - skip)
        ghostty|warp|wezterm|alacritty|kitty|iterm2)
            echo ""
            ;;
        # Browsers (GUI - skip)
        firefox|google-chrome|chrome|microsoft-edge|edge)
            echo ""
            ;;
        # Editors (GUI - skip)
        zed|vscode|visual-studio-code|cursor)
            echo ""
            ;;
        # Other GUI apps (skip)
        raycast|hammerspoon|sketchybar|aerospace)
            echo ""
            ;;
        # AI tools (GUI - skip)
        claude|claude-desktop|opencode)
            echo ""
            ;;
        # Default: try same name
        *)
            echo "$brew_name"
            ;;
    esac
}

# Check if package is available in repository
is_package_available() {
    local package="$1"
    local pm
    pm=$(pm_get_manager)

    case "$pm" in
        apt)
            apt-cache show "$package" &>/dev/null
            return $?
            ;;
        dnf)
            dnf info "$package" &>/dev/null
            return $?
            ;;
        *)
            return 1
            ;;
    esac
}

# Install single package (with error handling)
install_package() {
    local app_key="$1"
    local package_name="$2"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    log_step "Installing $display_name..."

    if pm_is_installed "$package_name"; then
        log_info "$display_name already installed"
        SUMMARY_SKIPPED="${SUMMARY_SKIPPED}${display_name}|"
        return 0
    fi

    if pm_install "$package_name"; then
        log_success "$display_name installed"
        SUMMARY_INSTALLED="${SUMMARY_INSTALLED}${display_name}|"
        return 0
    else
        log_error "Failed to install $display_name"
        return 1
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

# Install apt packages (Ubuntu/Debian)
install_apt_packages() {
    local platform
    platform=$(detect_platform)

    if [[ "$platform" != "linux" ]]; then
        return 0
    fi

    local distro
    distro=$(detect_linux_distro)

    if [[ "$distro" != "ubuntu" ]] && [[ "$distro" != "debian" ]]; then
        log_info "Skipping apt packages (not Ubuntu/Debian)"
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Linux Layer: Installing apt packages"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Get all installable apps for current profile
    local apps
    apps=$(get_all_installable_apps)

    local installed_count=0
    local skipped_count=0

    for app_key in $apps; do
        # Check if app is supported on current platform
        if ! is_app_supported "$app_key"; then
            continue
        fi

        # Get app type
        local app_type
        app_type=$(get_app_prop "$app_key" "type")

        # Skip non-brew types (handled by other layers)
        if [[ "$app_type" != "brew" ]]; then
            continue
        fi

        # Map brew package to Linux package
        local linux_package
        linux_package=$(map_brew_to_linux_package "$app_key")

        # Skip empty packages (GUI apps not available in repos)
        if [[ -z "$linux_package" ]]; then
            continue
        fi

        # Check if package is available in apt
        if ! is_package_available "$linux_package"; then
            log_info "Skipping $app_key (package not available in apt)"
            continue
        fi

        # Install package
        if install_package "$app_key" "$linux_package"; then
            ((installed_count++))
        else
            ((skipped_count++))
        fi
    done

    echo ""
    log_success "Linux layer complete: $installed_count installed, $skipped_count skipped"
}

# Install dnf packages (Fedora/RHEL)
install_dnf_packages() {
    local platform
    platform=$(detect_platform)

    if [[ "$platform" != "linux" ]]; then
        return 0
    fi

    local distro
    distro=$(detect_linux_distro)

    if [[ "$distro" != "fedora" ]] && [[ "$distro" != "rhel" ]] && [[ "$distro" != "centos" ]]; then
        log_info "Skipping dnf packages (not Fedora/RHEL/CentOS)"
        return 0
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Linux Layer: Installing dnf packages"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Get all installable apps for current profile
    local apps
    apps=$(get_all_installable_apps)

    local installed_count=0
    local skipped_count=0

    for app_key in $apps; do
        # Check if app is supported on current platform
        if ! is_app_supported "$app_key"; then
            continue
        fi

        # Get app type
        local app_type
        app_type=$(get_app_prop "$app_key" "type")

        # Skip non-brew types (handled by other layers)
        if [[ "$app_type" != "brew" ]]; then
            continue
        fi

        # Map brew package to Linux package
        local linux_package
        linux_package=$(map_brew_to_linux_package "$app_key")

        # Skip empty packages (GUI apps not available in repos)
        if [[ -z "$linux_package" ]]; then
            continue
        fi

        # Check if package is available in dnf
        if ! is_package_available "$linux_package"; then
            log_info "Skipping $app_key (package not available in dnf)"
            continue
        fi

        # Install package
        if install_package "$app_key" "$linux_package"; then
            ((installed_count++))
        else
            ((skipped_count++))
        fi
    done

    echo ""
    log_success "Linux layer complete: $installed_count installed, $skipped_count skipped"
}

# =============================================================================
# Main Entry Point
# =============================================================================

run_layer_linux() {
    local platform
    platform=$(detect_platform)

    # Only run on Linux
    if [[ "$platform" != "linux" ]]; then
        log_info "Skipping Linux layer (not a Linux system)"
        return 0
    fi

    local distro
    distro=$(detect_linux_distro)

    log_info "Detected Linux distribution: $distro"

    # Install packages based on distribution
    case "$distro" in
        ubuntu|debian)
            install_apt_packages
            ;;
        fedora|rhel|centos)
            install_dnf_packages
            ;;
        linux)
            log_warning "Generic Linux detected, skipping package installation"
            ;;
        *)
            log_warning "Unsupported Linux distribution: $distro"
            ;;
    esac
}

# Export main function
export -f run_layer_linux
