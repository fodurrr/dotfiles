#!/usr/bin/env bash
#
# package-manager.sh - Package manager abstraction layer
#
# Provides a unified interface for package management across different OS distributions.
# Supports: apt (Ubuntu/Debian), dnf (Fedora), and future package managers.

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/common.sh"

# Package manager globals
PM_UPDATE_DONE=false

# Detect package manager
detect_package_manager() {
    local os
    os=$(detect_os)

    case "$os" in
        ubuntu|debian)
            echo "apt"
            ;;
        fedora)
            echo "dnf"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Update package manager cache
pm_update() {
    local pm
    pm=$(detect_package_manager)

    # Only update once per session
    if [[ "$PM_UPDATE_DONE" == "true" ]]; then
        return 0
    fi

    log_step "Updating package manager cache..."

    case "$pm" in
        apt)
            sudo apt-get update -qq || die "Failed to update apt cache"
            ;;
        dnf)
            sudo dnf check-update -q || true  # dnf returns 100 if updates available
            ;;
        *)
            die "Unsupported package manager: $pm"
            ;;
    esac

    PM_UPDATE_DONE=true
    log_success "Package cache updated"
}

# Install packages
pm_install() {
    local pm
    pm=$(detect_package_manager)

    # Ensure cache is updated first
    pm_update

    case "$pm" in
        apt)
            sudo apt-get install -y -qq "$@" || die "Failed to install packages: $*"
            ;;
        dnf)
            sudo dnf install -y -q "$@" || die "Failed to install packages: $*"
            ;;
        *)
            die "Unsupported package manager: $pm"
            ;;
    esac
}

# Remove packages
pm_remove() {
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            sudo apt-get remove -y -qq "$@" || die "Failed to remove packages: $*"
            ;;
        dnf)
            sudo dnf remove -y -q "$@" || die "Failed to remove packages: $*"
            ;;
        *)
            die "Unsupported package manager: $pm"
            ;;
    esac
}

# Check if package is installed
pm_is_installed() {
    local package="$1"
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        dnf)
            rpm -q "$package" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Install package if not already installed
pm_install_if_missing() {
    local package="$1"

    if pm_is_installed "$package"; then
        log_info "$package is already installed"
        return 0
    fi

    log_step "Installing $package..."
    pm_install "$package"
    log_success "$package installed"
}

# Install multiple packages if missing
pm_install_packages() {
    local packages=("$@")
    local to_install=()

    # Check which packages need to be installed
    for package in "${packages[@]}"; do
        if pm_is_installed "$package"; then
            log_info "$package is already installed"
        else
            to_install+=("$package")
        fi
    done

    # Install missing packages
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_step "Installing ${#to_install[@]} package(s): ${to_install[*]}"
        pm_install "${to_install[@]}"
        log_success "Packages installed successfully"
    else
        log_success "All packages already installed"
    fi
}

# Add repository (OS-specific)
pm_add_repository() {
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            # Usage: pm_add_repository "ppa:user/repo" OR "deb [options] url dist component"
            local repo="$1"
            if [[ "$repo" == ppa:* ]]; then
                sudo add-apt-repository -y "$repo" || die "Failed to add repository: $repo"
            else
                echo "$repo" | sudo tee /etc/apt/sources.list.d/custom.list >/dev/null
            fi
            PM_UPDATE_DONE=false  # Force update after adding repo
            ;;
        dnf)
            # Usage: pm_add_repository "url"
            local repo_url="$1"
            sudo dnf config-manager --add-repo "$repo_url" || die "Failed to add repository: $repo_url"
            PM_UPDATE_DONE=false
            ;;
        *)
            die "Unsupported package manager: $pm"
            ;;
    esac
}

# Enable COPR repository (Fedora)
pm_enable_copr() {
    local copr="$1"
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" != "dnf" ]]; then
        log_warning "COPR repositories are only supported on Fedora"
        return 1
    fi

    log_step "Enabling COPR repository: $copr"
    sudo dnf copr enable -y "$copr" || die "Failed to enable COPR: $copr"
    PM_UPDATE_DONE=false
    log_success "COPR repository enabled"
}

# Install group of packages (Fedora)
pm_install_group() {
    local group="$1"
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" != "dnf" ]]; then
        log_warning "Package groups are only supported on Fedora"
        return 1
    fi

    log_step "Installing package group: $group"
    sudo dnf groupinstall -y "$group" || die "Failed to install group: $group"
    log_success "Package group installed"
}

# Check if group is installed (Fedora)
pm_is_group_installed() {
    local group="$1"
    local pm
    pm=$(detect_package_manager)

    if [[ "$pm" != "dnf" ]]; then
        return 1
    fi

    dnf group list --installed | grep -q "$group"
}

# Install group if not already installed (Fedora)
pm_install_group_if_missing() {
    local group="$1"

    if pm_is_group_installed "$group"; then
        log_info "Package group '$group' is already installed"
        return 0
    fi

    pm_install_group "$group"
}

# Add GPG key for repository
pm_add_gpg_key() {
    local key_url="$1"
    local keyring_path="${2:-/usr/share/keyrings/custom.gpg}"
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            log_step "Adding GPG key from $key_url"
            curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_path"
            log_success "GPG key added"
            ;;
        dnf)
            log_step "Adding GPG key from $key_url"
            sudo rpm --import "$key_url" || die "Failed to import GPG key"
            log_success "GPG key added"
            ;;
        *)
            die "Unsupported package manager: $pm"
            ;;
    esac
}

# Clean package manager cache
pm_clean() {
    local pm
    pm=$(detect_package_manager)

    log_step "Cleaning package manager cache..."

    case "$pm" in
        apt)
            sudo apt-get clean
            sudo apt-get autoclean
            sudo apt-get autoremove -y
            ;;
        dnf)
            sudo dnf clean all
            sudo dnf autoremove -y
            ;;
        *)
            log_warning "Cache cleaning not supported for: $pm"
            ;;
    esac

    log_success "Cache cleaned"
}

# Get package version
pm_get_version() {
    local package="$1"
    local pm
    pm=$(detect_package_manager)

    case "$pm" in
        apt)
            dpkg -l "$package" 2>/dev/null | grep "^ii" | awk '{print $3}'
            ;;
        dnf)
            rpm -q --qf "%{VERSION}-%{RELEASE}\n" "$package" 2>/dev/null
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Export functions for use in other scripts
export -f detect_package_manager pm_update pm_install pm_remove
export -f pm_is_installed pm_install_if_missing pm_install_packages
export -f pm_add_repository pm_enable_copr
export -f pm_install_group pm_is_group_installed pm_install_group_if_missing
export -f pm_add_gpg_key pm_clean pm_get_version
