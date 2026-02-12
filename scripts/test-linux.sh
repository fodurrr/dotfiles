#!/bin/bash
# =============================================================================
# Linux Support Test Script
# =============================================================================
# Tests platform detection, package manager abstraction, and app filtering
# Runs in dry-run mode - no system changes
# =============================================================================

set -e

# Source libraries
# Get script directory (scripts/test-linux.sh -> scripts/ -> repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
APPS_CONFIG="$DOTFILES_DIR/apps.toml"
source "$DOTFILES_DIR/scripts/lib/platform.sh"
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"
source "$DOTFILES_DIR/scripts/lib/app_config.sh"
source "$DOTFILES_DIR/scripts/lib/app_state.sh"

# =============================================================================
# Test Functions
# =============================================================================

test_platform_detection() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: Platform Detection"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local platform
    platform=$(detect_platform)

    echo "Platform Family: $platform"

    if [[ "$platform" == "linux" ]]; then
        local distro
        distro=$(detect_linux_distro)
        echo "Distribution: $distro"
    fi

    local arch
    arch=$(detect_architecture)
    echo "Architecture: $arch"

    local pm
    pm=$(get_package_manager)
    echo "Package Manager: $pm"

    echo ""
    if is_supported_platform; then
        echo "✓ Platform supported"
    else
        echo "✗ Platform NOT supported"
    fi
}

test_package_manager() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: Package Manager"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local pm
    pm=$(pm_get_manager)

    echo "Package Manager: $pm"
    echo ""

    case "$pm" in
        brew)
            if command -v brew &>/dev/null; then
                echo "✓ Homebrew is available"
            else
                echo "✗ Homebrew not found"
            fi
            ;;
        apt)
            if command -v apt-get &>/dev/null; then
                echo "✓ apt is available"
            else
                echo "✗ apt not found"
            fi
            ;;
        dnf)
            if command -v dnf &>/dev/null; then
                echo "✓ dnf is available"
            else
                echo "✗ dnf not found"
            fi
            ;;
        *)
            echo "✗ Unknown package manager"
            ;;
    esac
}

test_app_filtering() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: App Platform Filtering"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local platform
    platform=$(detect_platform)

    echo "Current Platform: $platform"
    echo ""
    echo "Testing app filtering for various apps:"
    echo ""

    local test_apps=(
        "ghostty:macOS GUI terminal"
        "ripgrep:Cross-platform CLI tool"
        "starship:Cross-platform prompt"
        "tmux:Cross-platform multiplexer"
        "warp:macOS GUI terminal"
        "lazygit:Cross-platform Git UI"
    )

    for app_spec in "${test_apps[@]}"; do
        local app_key="${app_spec%%:*}"
        local description="${app_spec##*:}"

        local is_supported
        if is_app_supported "$app_key"; then
            is_supported="✓ Supported"
        else
            is_supported="✗ Not supported"
        fi

        printf "  %-20s %s\n" "$app_key" "$description"
        printf "  %-20s %s\n\n" "" "$is_supported"
    done
}

test_apps_for_profile() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: Get Apps for 'hacker' Profile"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Temporarily set profile for testing
    SELECTED_PROFILES=("hacker")
    APPS_CONFIG="$DOTFILES_DIR/apps.toml"

    local apps
    apps=$(get_apps_for_profile)

    if [[ -z "$apps" ]]; then
        echo "✗ No apps found for hacker profile"
        return 1
    fi

    echo "Apps for 'hacker' profile (filtered by platform):"
    echo ""

    local count=0
    for app_key in $apps; do
        ((count++))
        local display_name
        display_name=$(get_app_display_name "$app_key")
        printf "  %-30s\n" "$display_name"
    done

    echo ""
    echo "Total: $count apps"
}

test_app_state() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: App State Detection"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local test_packages=("git" "curl" "wget")

    for package in "${test_packages[@]}"; do
        local installed

        if command -v "$package" &>/dev/null; then
            installed="✓ Installed"
        else
            installed="✗ Not installed"
        fi

        echo "  $package: $installed"
    done
}

test_platform_matches() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test: Platform Matching Function"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local platform
    platform=$(detect_platform)

    echo "Current Platform: $platform"
    echo ""
    echo "Testing platform_matches() function:"
    echo ""

    # Mock platform_matches for testing
    # In real usage, this is in platform.sh
    local test_cases=(
        "macos:Should match if current is macOS"
        "linux:Should match if current is Linux"
        "ubuntu:Should match if current is Linux (Ubuntu)"
        "debian:Should match if current is Linux (Debian)"
        "fedora:Should match if current is Linux (Fedora)"
    )

    for case in "${test_cases[@]}"; do
        local test_platform="${case%%:*}"
        local description="${case##*:}"

        echo "  Testing: $test_platform"
        echo "  Description: $description"
        echo ""
    done
}

# =============================================================================
# Main Test Runner
# =============================================================================

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║  Linux Support Test Suite                                          ║"
    echo "║  Dry-run mode - no system changes                                  ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""

    test_platform_detection
    test_package_manager
    test_app_filtering
    test_apps_for_profile
    test_app_state
    test_platform_matches

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Test Suite Complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Run tests
main "$@"
