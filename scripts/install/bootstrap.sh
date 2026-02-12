# =============================================================================
# PHASE 1: BOOTSTRAP (runs first, unconditionally)
# =============================================================================

bootstrap_require_sudo() {
    if [[ "$EUID" -eq 0 ]]; then
        return 0
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        log_error "sudo is required for Linux package installation"
        exit 1
    fi

    if ! sudo -v >/dev/null 2>&1; then
        log_error "Failed to obtain sudo credentials"
        exit 1
    fi
}

bootstrap_run_as_root() {
    if [[ "$EUID" -eq 0 ]]; then
        "$@"
        return $?
    fi
    sudo "$@"
}

bootstrap_linux_package_available() {
    local pm="$1"
    local package="$2"

    case "$pm" in
        apt)
            apt-cache show "$package" >/dev/null 2>&1
            ;;
        dnf)
            dnf info "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

bootstrap_install_linux_packages() {
    local pm="$1"
    shift

    local packages_to_install=""
    local package
    for package in "$@"; do
        if bootstrap_linux_package_available "$pm" "$package"; then
            if [[ -z "$packages_to_install" ]]; then
                packages_to_install="$package"
            else
                packages_to_install="$packages_to_install $package"
            fi
        else
            log_warning "Package not available in $pm repositories: $package"
        fi
    done

    [[ -z "$packages_to_install" ]] && return 0

    case "$pm" in
        apt)
            bootstrap_run_as_root apt-get install -y -qq $packages_to_install
            ;;
        dnf)
            bootstrap_run_as_root dnf install -y -q $packages_to_install
            ;;
    esac
}

bootstrap_yq_supports_toml() {
    local tmp_file
    tmp_file=$(mktemp)
    cat > "$tmp_file" << 'EOF_TOML'
[apps.test]
type = "brew"
EOF_TOML

    if yq -p toml -oy '.apps.test.type' "$tmp_file" >/dev/null 2>&1; then
        rm -f "$tmp_file"
        return 0
    fi

    rm -f "$tmp_file"
    return 1
}

bootstrap_install_yq_binary_linux() {
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            log_error "Unsupported Linux architecture for yq binary: $(uname -m)"
            return 1
            ;;
    esac

    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"

    log_info "Installing mikefarah/yq binary for TOML support..."
    if ! curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}" -o "$bin_dir/yq"; then
        log_error "Failed to download yq binary"
        return 1
    fi
    chmod +x "$bin_dir/yq"
    export PATH="$bin_dir:$PATH"
}

bootstrap_install_mise_linux() {
    log_info "Installing mise..."
    if ! curl -fsSL https://mise.jdx.dev/install.sh | sh >/dev/null 2>&1; then
        log_error "Failed to install mise"
        return 1
    fi

    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise not found after installation"
        return 1
    fi
}

bootstrap_install_gum_binary_linux() {
    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            log_warning "Unsupported Linux architecture for gum binary: $(uname -m)"
            return 1
            ;;
    esac

    local api_url="https://api.github.com/repos/charmbracelet/gum/releases/latest"
    local gum_asset_url
    gum_asset_url=$(curl -fsSL "$api_url" 2>/dev/null | grep -Eo "https://[^\\\"]*gum_[0-9.]+_Linux_${arch}\\.tar\\.gz" | head -1)
    if [[ -z "$gum_asset_url" ]]; then
        log_warning "Could not resolve gum release asset URL for Linux ${arch}"
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    if [[ ! -d "$tmp_dir" ]]; then
        log_warning "Failed to create temp directory for gum installation"
        return 1
    fi

    local archive="$tmp_dir/gum.tar.gz"
    if ! curl -fsSL "$gum_asset_url" -o "$archive"; then
        rm -rf "$tmp_dir"
        log_warning "Failed to download gum release archive"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir"; then
        rm -rf "$tmp_dir"
        log_warning "Failed to extract gum release archive"
        return 1
    fi

    local gum_bin
    gum_bin=$(find "$tmp_dir" -type f -name gum 2>/dev/null | head -1)
    if [[ -z "$gum_bin" ]]; then
        rm -rf "$tmp_dir"
        log_warning "gum binary not found in extracted archive"
        return 1
    fi

    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    if ! cp "$gum_bin" "$bin_dir/gum"; then
        rm -rf "$tmp_dir"
        log_warning "Failed to copy gum binary to $bin_dir"
        return 1
    fi
    chmod +x "$bin_dir/gum"
    export PATH="$bin_dir:$PATH"
    rm -rf "$tmp_dir"
    return 0
}

bootstrap_install_gum_linux() {
    local pm="$1"

    if command -v gum >/dev/null 2>&1; then
        return 0
    fi

    if bootstrap_linux_package_available "$pm" "gum"; then
        bootstrap_install_linux_packages "$pm" "gum" || true
        if command -v gum >/dev/null 2>&1; then
            return 0
        fi
    fi

    log_info "Installing gum binary fallback..."
    if bootstrap_install_gum_binary_linux; then
        if command -v gum >/dev/null 2>&1; then
            return 0
        fi
    fi

    log_warning "gum is not available; installer will use plain-text fallback output"
    return 0
}

run_bootstrap_macos() {
    # Install Homebrew if missing
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew..."
        echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Setup Homebrew environment
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "Error: Homebrew not found after installation"
        exit 1
    fi

    # Install infrastructure packages
    echo "Installing infrastructure packages..."
    echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"
    if ! brew bundle --file="$DOTFILES_DIR/Brewfile.bootstrap"; then
        echo "Error: brew bundle failed"
        exit 1
    fi
}

run_bootstrap_linux() {
    local pm
    pm=$(pm_get_manager)
    case "$pm" in
        apt|dnf)
            ;;
        *)
            log_error "Unsupported Linux package manager for bootstrap: $pm"
            exit 1
            ;;
    esac

    bootstrap_require_sudo

    echo "Installing Linux bootstrap dependencies via $pm..."
    echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"

    case "$pm" in
        apt)
            bootstrap_run_as_root apt-get update -qq
            bootstrap_install_linux_packages "$pm" \
                ca-certificates curl git jq stow zsh yq \
                build-essential autoconf automake bison pkg-config patch \
                libssl-dev zlib1g-dev libreadline-dev libyaml-dev libffi-dev \
                libgdbm-dev libncurses5-dev libxml2-dev libxslt1-dev \
                libsqlite3-dev tk-dev xz-utils
            ;;
        dnf)
            bootstrap_run_as_root dnf makecache --refresh -q >/dev/null 2>&1 || true
            bootstrap_run_as_root dnf groupinstall -y "Development Tools" >/dev/null 2>&1 || true
            bootstrap_install_linux_packages "$pm" \
                ca-certificates curl git jq stow zsh yq \
                gcc gcc-c++ make patch autoconf automake bison pkgconf-pkg-config \
                openssl-devel zlib-ng-compat-devel readline-devel libyaml-devel \
                libffi-devel gdbm-devel ncurses-devel libxml2-devel \
                libxslt-devel sqlite-devel tk-devel xz
            ;;
    esac

    if ! command -v yq >/dev/null 2>&1 || ! bootstrap_yq_supports_toml; then
        bootstrap_install_yq_binary_linux
    fi

    if ! command -v yq >/dev/null 2>&1 || ! bootstrap_yq_supports_toml; then
        log_error "yq is required and must support TOML parsing"
        exit 1
    fi

    if ! command -v stow >/dev/null 2>&1; then
        log_error "stow is required for configuration linking"
        exit 1
    fi

    if ! command -v mise >/dev/null 2>&1; then
        bootstrap_install_mise_linux
    fi

    bootstrap_install_gum_linux "$pm"
}

run_bootstrap() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Phase 1: Bootstrap"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local platform
    platform=$(detect_platform)

    case "$platform" in
        macos)
            run_bootstrap_macos
            ;;
        linux)
            run_bootstrap_linux
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac

    # Install TPM (Tmux Plugin Manager) if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_success "TPM installed. After tmux starts, press Ctrl+A then Shift+I to install plugins."
    else
        log_info "TPM already installed"
    fi
}
