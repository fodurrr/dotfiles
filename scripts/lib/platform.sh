#!/bin/bash
# =============================================================================
# Platform Detection Library
# =============================================================================
# Detects operating system, Linux distribution, and architecture
# Provides platform-specific helper functions for the installer
# =============================================================================

# Detect operating system family (macos, linux, etc.)
detect_platform() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Detect Linux distribution (ubuntu, debian, fedora, etc.)
detect_linux_distro() {
    local platform
    platform=$(detect_platform)

    if [[ "$platform" != "linux" ]]; then
        echo ""
        return 1
    fi

    if [[ -f /etc/os-release ]]; then
        # Parse /etc/os-release for distribution ID
        source /etc/os-release
        echo "$ID"
        return 0
    elif [[ -f /etc/lsb-release ]]; then
        # Fallback for older Ubuntu/Debian systems
        source /etc/lsb-release
        if [[ "$DISTRIB_ID" == "Ubuntu" ]]; then
            echo "ubuntu"
            return 0
        elif [[ "$DISTRIB_ID" == "Debian" ]]; then
            echo "debian"
            return 0
        fi
    fi

    # Fallback to generic linux
    echo "linux"
    return 0
}

# Detect architecture (amd64, arm64, etc.)
detect_architecture() {
    case "$(uname -m)" in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l|arm)
            echo "arm"
            ;;
        i386|i686)
            echo "386"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if platform is supported
is_supported_platform() {
    local platform
    platform=$(detect_platform)

    case "$platform" in
        macos|linux)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if Linux distribution is supported
is_supported_linux_distro() {
    local distro
    distro=$(detect_linux_distro)

    case "$distro" in
        ubuntu|debian|fedora|rhel|centos|linux)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get package manager for current platform
get_package_manager() {
    local platform
    platform=$(detect_platform)

    case "$platform" in
        macos)
            echo "brew"
            ;;
        linux)
            local distro
            distro=$(detect_linux_distro)
            case "$distro" in
                ubuntu|debian)
                    echo "apt"
                    ;;
                fedora|rhel|centos)
                    echo "dnf"
                    ;;
                *)
                    echo "unknown"
                    ;;
            esac
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if current platform matches given platform list
platform_matches() {
    local platforms="$1"
    local current
    current=$(detect_platform)
    local distro

    if [[ -z "$platforms" ]]; then
        # No platform specified - assume all platforms supported
        return 0
    fi

    for platform in $platforms; do
        case "$platform" in
            macos|darwin)
                if [[ "$current" == "macos" ]]; then
                    return 0
                fi
                ;;
            linux)
                if [[ "$current" == "linux" ]]; then
                    return 0
                fi
                ;;
            ubuntu|debian|fedora|rhel|centos)
                if [[ "$current" == "linux" ]]; then
                    distro=$(detect_linux_distro)
                    if [[ "$distro" == "$platform" ]]; then
                        return 0
                    fi
                fi
                ;;
        esac
    done

    return 1
}

# Display platform information (for debugging)
show_platform_info() {
    local platform
    local distro
    local arch
    local pm

    platform=$(detect_platform)
    distro=$(detect_linux_distro)
    arch=$(detect_architecture)
    pm=$(get_package_manager)

    echo "Platform Information:"
    echo "  OS Family:  $platform"
    if [[ "$platform" == "linux" ]]; then
        echo "  Distribution: $distro"
    fi
    echo "  Architecture: $arch"
    echo "  Package Manager: $pm"
}

# Export functions for use in other scripts
export -f detect_platform
export -f detect_linux_distro
export -f detect_architecture
export -f is_supported_platform
export -f is_supported_linux_distro
export -f get_package_manager
export -f platform_matches
export -f show_platform_info
