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

# Run command with sudo when needed
_pm_run() {
    if [[ "$EUID" -eq 0 ]]; then
        "$@"
        return $?
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
        return $?
    fi

    return 1
}

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
            command -v apt-get >/dev/null 2>&1 || return 1
            _pm_run apt-get update -qq || return 1
            ;;
        dnf)
            command -v dnf >/dev/null 2>&1 || return 1
            _pm_run dnf check-update -q >/dev/null 2>&1 || true
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew update --quiet || true
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

    pm_update || return 1

    case "$_CACHED_PM" in
        apt)
            command -v apt-get >/dev/null 2>&1 || return 1
            _pm_run apt-get install -y -qq "$@" || return 1
            ;;
        dnf)
            command -v dnf >/dev/null 2>&1 || return 1
            _pm_run dnf install -y -q "$@" || return 1
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew install --quiet "$@" || return 1
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
            command -v dpkg >/dev/null 2>&1 || return 1
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            return $?
            ;;
        dnf)
            command -v rpm >/dev/null 2>&1 || return 1
            rpm -q "$package" >/dev/null 2>&1
            return $?
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew list "$package" >/dev/null 2>&1
            return $?
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
            command -v apt-get >/dev/null 2>&1 || return 1
            _pm_run apt-get remove -y -qq "$@" || return 1
            ;;
        dnf)
            command -v dnf >/dev/null 2>&1 || return 1
            _pm_run dnf remove -y -q "$@" || return 1
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew uninstall --quiet "$@" || return 1
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
            command -v add-apt-repository >/dev/null 2>&1 || return 1
            if [[ "$repo" == ppa:* ]]; then
                _pm_run add-apt-repository -y "$repo" || return 1
            else
                echo "$repo" | _pm_run tee /etc/apt/sources.list.d/custom.list >/dev/null || return 1
            fi
            _PM_UPDATE_DONE=false
            ;;
        dnf)
            command -v dnf >/dev/null 2>&1 || return 1
            _pm_run dnf config-manager --add-repo "$repo" || return 1
            _PM_UPDATE_DONE=false
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew tap "$repo" || return 1
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

    command -v dnf >/dev/null 2>&1 || return 1
    _pm_run dnf copr enable -y "$copr" || return 1

    _PM_UPDATE_DONE=false
}

# Add GPG key
pm_add_gpg_key() {
    local key_url="$1"
    local keyring_path="${2:-/usr/share/keyrings/custom.gpg}"

    case "$_CACHED_PM" in
        apt)
            command -v gpg >/dev/null 2>&1 || return 1
            curl -fsSL "$key_url" | _pm_run gpg --dearmor -o "$keyring_path" || return 1
            ;;
        dnf)
            command -v rpm >/dev/null 2>&1 || return 1
            _pm_run rpm --import "$key_url" || return 1
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
            command -v apt-get >/dev/null 2>&1 || return 1
            _pm_run apt-get clean
            _pm_run apt-get autoclean
            _pm_run apt-get autoremove -y
            ;;
        dnf)
            command -v dnf >/dev/null 2>&1 || return 1
            _pm_run dnf clean all
            _pm_run dnf autoremove -y
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew cleanup --quiet
            ;;
    esac
}

# Get installed package version
pm_get_version() {
    local package="$1"

    case "$_CACHED_PM" in
        apt)
            command -v dpkg >/dev/null 2>&1 || return 1
            dpkg -l "$package" 2>/dev/null | grep "^ii" | awk '{print $3}'
            ;;
        dnf)
            command -v rpm >/dev/null 2>&1 || return 1
            rpm -q --qf "%{VERSION}-%{RELEASE}\n" "$package" 2>/dev/null
            ;;
        brew)
            command -v brew >/dev/null 2>&1 || return 1
            brew list --versions "$package" 2>/dev/null | awk '{print $2}'
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if we have sudo access (for package operations)
pm_has_sudo() {
    if [[ "$EUID" -eq 0 ]]; then
        return 0
    fi

    if command -v sudo >/dev/null 2>&1; then
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
