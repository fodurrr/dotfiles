#!/bin/bash
# =============================================================================
# Linux Support Validation Script
# =============================================================================
# Assertion-based checks for Linux install safety and platform behavior.
# Exits non-zero when any required check fails.
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
APPS_CONFIG="$DOTFILES_DIR/apps.toml"

source "$DOTFILES_DIR/scripts/lib/platform.sh"
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"
source "$DOTFILES_DIR/scripts/lib/app_config.sh"
source "$DOTFILES_DIR/scripts/lib/app_state.sh"

FAILURES=0

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

pass() {
    echo "  ✓ $1"
}

fail() {
    echo "  ✗ $1"
    FAILURES=$((FAILURES + 1))
}

assert_true() {
    local message="$1"
    shift
    if "$@"; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_false() {
    local message="$1"
    shift
    if "$@"; then
        fail "$message"
    else
        pass "$message"
    fi
}

is_grep_match() {
    local pattern="$1"
    local file="$2"
    grep -q "$pattern" "$file"
}

test_platform_filtering() {
    print_header "Platform Filtering"
    assert_false "ghostty should not be supported on Linux" is_app_supported ghostty linux
    assert_true "starship should be supported on Linux" is_app_supported starship linux
    assert_true "btop should be selected for Linux in hacker profile when profile matches" is_app_supported btop linux
}

test_linux_package_mapping() {
    print_header "Linux Package Mapping"
    assert_true "btop should map to Linux package for apt" test -n "$(get_linux_package_name btop apt)"
    assert_true "btop should map to Linux package for dnf" test -n "$(get_linux_package_name btop dnf)"
    assert_true "ncdu should map to Linux package for apt" test -n "$(get_linux_package_name ncdu apt)"
    assert_true "ncdu should map to Linux package for dnf" test -n "$(get_linux_package_name ncdu dnf)"
    assert_false "codex-acp should not be Linux-supported app" is_app_supported codex-acp linux
}

test_sheldon_source_config() {
    print_header "Sheldon Tool Configuration"
    local sheldon_type
    sheldon_type=$(get_app_prop sheldon type)
    if [[ "$sheldon_type" == "brew" ]]; then
        pass "sheldon app should exist in apps.toml as brew tool"
    else
        fail "sheldon app should exist in apps.toml as brew tool"
    fi
    assert_true "sheldon should have Linux package mapping" test -n "$(get_linux_package_name sheldon dnf)"
    assert_true "sheldon should be Linux-supported" is_app_supported sheldon linux
}

test_mise_registry_entries() {
    print_header "Mise Registry Entries"
    if ! command -v mise >/dev/null 2>&1; then
        pass "mise not installed on host; registry validation skipped"
        return 0
    fi

    local registry_keys
    registry_keys=$(mise registry 2>/dev/null | awk '{print $1}')
    if [[ -z "$registry_keys" ]]; then
        fail "mise registry output is empty"
        return 0
    fi

    local app_key
    for app_key in $(get_all_apps); do
        local app_type
        app_type=$(get_app_prop "$app_key" "type")
        if [[ "$app_type" != "mise" ]]; then
            continue
        fi
        local tool_name
        tool_name=$(get_app_prop "$app_key" "name")
        [[ -z "$tool_name" ]] && tool_name="$app_key"

        if echo "$registry_keys" | grep -Fxq "$tool_name"; then
            pass "mise registry contains tool '$tool_name'"
        else
            fail "mise registry is missing tool '$tool_name' (app: $app_key)"
        fi
    done
}

test_bootstrap_linux_path() {
    print_header "Bootstrap Routing"
    local bootstrap_file="$DOTFILES_DIR/scripts/install/bootstrap.sh"

    assert_true "bootstrap should define Linux bootstrap function" is_grep_match '^run_bootstrap_linux()' "$bootstrap_file"
    assert_true "bootstrap should include Linux platform case branch" is_grep_match 'linux)' "$bootstrap_file"
    assert_true "bootstrap should call Linux bootstrap branch" is_grep_match 'run_bootstrap_linux' "$bootstrap_file"
    assert_false "Linux bootstrap function should not invoke brew" bash -c "sed -n '/^run_bootstrap_linux()/,/^}/p' '$bootstrap_file' | grep -q '\\<brew\\>'"
}

test_macos_guards() {
    print_header "macOS-only Guards"
    assert_true "raycast config should guard for macOS" is_grep_match 'get_current_platform' "$DOTFILES_DIR/scripts/install/raycast.sh"
    assert_true "terminal config should guard for macOS" is_grep_match 'get_current_platform' "$DOTFILES_DIR/scripts/install/terminal.sh"
    assert_true "reconcile should be guarded for macOS" is_grep_match 'Skipping cask reconciliation' "$DOTFILES_DIR/scripts/install/reconcile_casks.sh"
}

test_summary_fallback() {
    print_header "Summary Fallback"
    assert_true "summary should support non-gum fallback path" is_grep_match 'command -v gum' "$DOTFILES_DIR/scripts/lib/summary.sh"
    assert_true "summary should print plain table when gum is missing" is_grep_match 'printf "  %-22s %-12s %s\\n" "Package" "Status" "Description"' "$DOTFILES_DIR/scripts/lib/summary.sh"
}

test_stow_strictness() {
    print_header "Stow Strictness"
    assert_false "stow layer should not ignore stow_enforce failures" is_grep_match 'stow_enforce "\\$package" \\|\\| true' "$DOTFILES_DIR/scripts/install/layer_stow.sh"
    assert_true "stow layer should verify zshrc after linking zsh-config" is_grep_match 'zsh config expected but missing' "$DOTFILES_DIR/scripts/install/layer_stow.sh"
}

test_shell_finalization() {
    print_header "Shell Finalization"
    local summary_file="$DOTFILES_DIR/scripts/install/summary.sh"

    assert_true "shell finalization should target original user under sudo" is_grep_match 'SUDO_USER' "$summary_file"
    assert_true "yes mode should attempt non-interactive chsh via sudo" is_grep_match 'sudo -n chsh -s' "$summary_file"
    assert_true "shell switch should be re-verified after chsh" is_grep_match 'Shell change command completed but login shell is still' "$summary_file"
    assert_true "yes mode summary should not block on enter prompt" is_grep_match 'if \[\[ "\$YES_MODE" == true \]\]; then' "$summary_file"
}

test_linux_manager_detection() {
    print_header "Package Manager Detection"
    local platform
    platform=$(detect_platform)
    local pm
    pm=$(pm_get_manager)

    if [[ "$platform" == "linux" ]]; then
        if [[ "$pm" == "apt" || "$pm" == "dnf" ]]; then
            pass "Linux package manager should be apt or dnf (got: $pm)"
        else
            fail "Linux package manager should be apt or dnf (got: $pm)"
        fi
    else
        pass "Host is not Linux (current platform: $platform); Linux manager assertion skipped"
    fi
}

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║  Linux Validation Suite                                            ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"

    test_platform_filtering
    test_linux_package_mapping
    test_sheldon_source_config
    test_mise_registry_entries
    test_bootstrap_linux_path
    test_macos_guards
    test_summary_fallback
    test_stow_strictness
    test_shell_finalization
    test_linux_manager_detection

    echo ""
    echo "Failures: $FAILURES"
    if [[ "$FAILURES" -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
