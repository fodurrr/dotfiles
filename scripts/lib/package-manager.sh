#!/bin/bash
# =============================================================================
# Package Manager Abstraction Layer
# =============================================================================
# Provides a unified interface for package management across different platforms
# Supports: apt (Ubuntu/Debian), dnf (Fedora), brew (macOS)
# =============================================================================

# Source platform library if not already loaded
if [[ -z "$(type -t detect_platform)" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/platform.sh"
fi

# Cached globals - detected ONCE at load time
_CACHED_OS=""
_CACHED_PM=""
_PM_UPDATE_DONE=false

# Initialize cache
_init_pm_cache() {
    if [[ -z "$_CACHED_OS" ]]; then
        _CACHED_OS=$(detect_platform)
    fi
    if [[ -z "$_CACHED_PM" ]]; then
        _CACHED_PM=$(get_package_manager)
    fi
}

# Initialize cache immediately
_init_pm_cache

# Get current operating system
pm_get_os() {
    echo "$_CACHED_OS"
}

# Get current package manager
pm_get_manager() {
    echo "$_CACHED_PM"
}

# Update package cache
pm_update() {
    if [[ "$_PM_UPDATE_DONE" == "true" ]]; then
        return 0
    fi

    case "$_CACHED_PM" in
        apt)
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -qq || return 1
            fi
            ;;
        dnf)
            if command -v dnf &>/dev/null; then
                sudo dnf check-update -q || true
            fi
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew update --quiet || true
            fi
            ;;
        *)
            return 1
            ;;
    esac

    _PM_UPDATE_DONE=true
    return 0
}

# Install packages
pm_install() {
    [[ $# -eq 0 ]] && return 0

    pm_update

    case "$_CACHED_PM" in
        apt)
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y -qq "$@" || return 1
            fi
            ;;
        dnf)
            if command -v dnf &>/dev/null; then
                sudo dnf install -y -q "$@" || return 1
            fi
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew install --quiet "$@" || return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if package is installed
pm_is_installed() {
    local package="$1"

    case "$_CACHED_PM" in
        apt)
            if command -v dpkg &>/dev/null; then
                dpkg -l "$package" 2>/dev/null | grep -q "^ii"
                return $?
            fi
            ;;
        dnf)
            if command -v rpm &>/dev/null; then
                rpm -q "$package" &>/dev/null
                return $?
            fi
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew list "$package" &>/dev/null
                return $?
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Remove packages
pm_remove() {
    [[ $# -eq 0 ]] && return 0

    case "$_CACHED_PM" in
        apt)
            if command -v apt-get &>/dev/null; then
                sudo apt-get remove -y -qq "$@" || return 1
            fi
            ;;
        dnf)
            if command -v dnf &>/dev/null; then
                sudo dnf remove -y -q "$@" || return 1
            fi
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew uninstall --quiet "$@" || return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Add repository (for apt/dnf) or tap (for brew)
pm_add_repository() {
    local repo="$1"

    case "$_CACHED_PM" in
        apt)
            if command -v add-apt-repository &>/dev/null; then
                if [[ "$repo" == ppa:* ]]; then
                    sudo add-apt-repository -y "$repo" || return 1
                else
                    echo "$repo" | sudo tee /etc/apt/sources.list.d/custom.list >/dev/null || return 1
                fi
            fi
            _PM_UPDATE_DONE=false
            ;;
        dnf)
            if command -v dnf &>/dev/null; then
                sudo dnf config-manager --add-repo "$repo" || return 1
            fi
            _PM_UPDATE_DONE=false
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew tap "$repo" || return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Enable COPR repository (dnf only)
pm_enable_copr() {
    local copr="$1"

    if [[ "$_CACHED_PM" != "dnf" ]]; then
        return 1
    fi

    if command -v dnf &>/dev/null; then
        sudo dnf copr enable -y "$copr" || return 1
    fi

    _PM_UPDATE_DONE=false
}

# Add GPG key
pm_add_gpg_key() {
    local key_url="$1"
    local keyring_path="${2:-/usr/share/keyrings/custom.gpg}"

    case "$_CACHED_PM" in
        apt)
            if command -v gpg &>/dev/null; then
                curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_path" || return 1
            fi
            ;;
        dnf)
            if command -v rpm &>/dev/null; then
                sudo rpm --import "$key_url" || return 1
            fi
            ;;
        brew)
            # brew handles keys automatically
            :
            ;;
        *)
            return 1
            ;;
    esac
}

# Clean package cache
pm_clean() {
    case "$_CACHED_PM" in
        apt)
            if command -v apt-get &>/dev/null; then
                sudo apt-get clean
                sudo apt-get autoclean
                sudo apt-get autoremove -y
            fi
            ;;
        dnf)
            if command -v dnf &>/dev/null; then
                sudo dnf clean all
                sudo dnf autoremove -y
            fi
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew cleanup --quiet
            fi
            ;;
    esac
}

# Get installed package version
pm_get_version() {
    local package="$1"

    case "$_CACHED_PM" in
        apt)
            if command -v dpkg &>/dev/null; then
                dpkg -l "$package" 2>/dev/null | grep "^ii" | awk '{print $3}'
            fi
            ;;
        dnf)
            if command -v rpm &>/dev/null; then
                rpm -q --qf "%{VERSION}-%{RELEASE}\n" "$package" 2>/dev/null
            fi
            ;;
        brew)
            if command -v brew &>/dev/null; then
                brew list --versions "$package" 2>/dev/null | awk '{print $2}'
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if we have sudo access (for package operations)
pm_has_sudo() {
    if command -v sudo &>/dev/null; then
        if sudo -n true 2>/dev/null; then
            return 0
        elif sudo -v 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Export functions for use in other scripts
export -f pm_get_os
export -f pm_get_manager
export -f pm_update
export -f pm_install
export -f pm_is_installed
export -f pm_remove
export -f pm_add_repository
export -f pm_enable_copr
export -f pm_add_gpg_key
export -f pm_clean
export -f pm_get_version
export -f pm_has_sudo
