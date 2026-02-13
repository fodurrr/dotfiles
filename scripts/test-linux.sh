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

list_has_token() {
    local list="$1"
    local token="$2"
    local item
    for item in $list; do
        if [[ "$item" == "$token" ]]; then
            return 0
        fi
    done
    return 1
}

lists_overlap() {
    local first="$1"
    local second="$2"
    local item
    for item in $first; do
        if list_has_token "$second" "$item"; then
            return 0
        fi
    done
    return 1
}

get_app_profiles_list() {
    local app_key="$1"
    normalize_app_list_tokens "$(get_app_prop "$app_key" "profiles")"
}

get_app_bin_or_name() {
    local app_key="$1"
    local command_name
    command_name=$(get_app_prop "$app_key" "bin")
    if [[ -n "$command_name" ]]; then
        echo "$command_name"
        return 0
    fi

    command_name=$(get_app_prop "$app_key" "name")
    [[ -z "$command_name" ]] && command_name="$app_key"
    echo "$command_name"
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

test_linux_layer_upgrade_behavior() {
    print_header "Linux Layer Upgrade Behavior"
    local layer_file="$DOTFILES_DIR/scripts/install/layer_linux.sh"

    assert_true "linux layer should call pm_install for selected mapped packages" is_grep_match 'pm_install "\$package_name"' "$layer_file"
    assert_true "linux layer should classify installs with pre/post version checks" is_grep_match 'pre_version=' "$layer_file"
    assert_true "linux layer should classify installs with pre/post version checks" is_grep_match 'post_version=' "$layer_file"
    assert_false "linux layer should not short-circuit on already installed packages" is_grep_match 'already installed \\(\\$package_name\\)' "$layer_file"
}

test_ai_cli_single_source_fields() {
    print_header "AI CLI Single-Source Fields"
    local app_key
    for app_key in claude-cli opencode-cli codex-cli gemini-cli; do
        local app_type app_bin app_enforce
        app_type=$(get_app_prop "$app_key" "type")
        app_bin=$(get_app_prop "$app_key" "bin")
        app_enforce=$(get_app_prop "$app_key" "enforce_single_source")

        if [[ "$app_type" == "mise" ]]; then
            pass "$app_key should remain a mise app"
        else
            fail "$app_key should remain a mise app"
        fi

        if [[ -n "$app_bin" ]]; then
            pass "$app_key should define bin"
        else
            fail "$app_key should define bin"
        fi

        if [[ "$app_enforce" == "true" ]]; then
            pass "$app_key should enforce single-source command ownership"
        else
            fail "$app_key should enforce single-source command ownership"
        fi
    done
}

test_codex_owner_split() {
    print_header "Codex Owner Split"

    local codex_desktop_name codex_desktop_kind codex_cli_platform codex_cli_macos_type codex_cli_macos_kind codex_cli_macos_platform
    codex_desktop_name=$(get_app_prop codex-desktop name)
    codex_desktop_kind=$(get_app_prop codex-desktop kind)
    codex_cli_platform=$(get_app_platform codex-cli)
    codex_cli_macos_type=$(get_app_prop codex-cli-macos type)
    codex_cli_macos_kind=$(get_app_prop codex-cli-macos kind)
    codex_cli_macos_platform=$(get_app_platform codex-cli-macos)

    if [[ "$codex_desktop_name" == "codex-app" ]]; then
        pass "codex-desktop should target codex-app cask"
    else
        fail "codex-desktop should target codex-app cask"
    fi

    if [[ "$codex_desktop_kind" == "desktop" ]]; then
        pass "codex-desktop should be marked kind=desktop"
    else
        fail "codex-desktop should be marked kind=desktop"
    fi

    if list_has_token "$codex_cli_platform" "linux" && ! list_has_token "$codex_cli_platform" "macos"; then
        pass "codex-cli should be Linux-only mise"
    else
        fail "codex-cli should be Linux-only mise"
    fi

    if [[ "$codex_cli_macos_type" == "cask" && "$codex_cli_macos_kind" == "cli" && "$codex_cli_macos_platform" == "macos" ]]; then
        pass "codex-cli-macos should be macOS cask CLI owner"
    else
        fail "codex-cli-macos should be macOS cask CLI owner"
    fi
}

test_keymapp_profiles() {
    print_header "Keymapp Profiles"
    local keymapp_profiles
    keymapp_profiles=$(get_app_profiles_list keymapp)

    if list_has_token "$keymapp_profiles" "developer" && list_has_token "$keymapp_profiles" "hacker"; then
        pass "keymapp should be assigned to developer and hacker profiles"
    else
        fail "keymapp should be assigned to developer and hacker profiles"
    fi
}

test_cask_kind_metadata() {
    print_header "Cask Kind Metadata"
    local app_key
    local failures_before="$FAILURES"

    for app_key in $(get_all_apps); do
        case "$app_key" in
            *-desktop)
                local app_type app_kind
                app_type=$(get_app_prop "$app_key" "type")
                app_kind=$(get_app_prop "$app_key" "kind")
                if [[ "$app_type" != "cask" ]]; then
                    fail "$app_key should be a cask app"
                fi
                if [[ "$app_kind" != "desktop" ]]; then
                    fail "$app_key should set kind=desktop"
                fi
                ;;
        esac
    done

    if [[ "$FAILURES" == "$failures_before" ]]; then
        pass "desktop app keys should be typed and classified consistently"
    fi
}

test_no_cli_owner_overlap() {
    print_header "CLI Owner Overlap Guard"

    local overlap_count=0
    local strict_app
    for strict_app in $(get_all_apps); do
        local strict_type strict_enforce
        strict_type=$(get_app_prop "$strict_app" "type")
        strict_enforce=$(get_app_prop "$strict_app" "enforce_single_source")
        if [[ "$strict_type" != "mise" || "$strict_enforce" != "true" ]]; then
            continue
        fi

        local strict_cmd strict_profiles strict_platforms
        strict_cmd=$(get_app_bin_or_name "$strict_app")
        strict_profiles=$(get_app_profiles_list "$strict_app")
        strict_platforms=$(get_app_platform "$strict_app")

        local cask_app
        for cask_app in $(get_all_apps); do
            local cask_type cask_kind
            cask_type=$(get_app_prop "$cask_app" "type")
            cask_kind=$(get_app_prop "$cask_app" "kind")
            if [[ "$cask_type" != "cask" || "$cask_kind" != "cli" ]]; then
                continue
            fi

            local cask_cmd cask_profiles cask_platforms
            cask_cmd=$(get_app_bin_or_name "$cask_app")
            cask_profiles=$(get_app_profiles_list "$cask_app")
            cask_platforms=$(get_app_platform "$cask_app")

            if [[ "$strict_cmd" != "$cask_cmd" ]]; then
                continue
            fi
            if ! lists_overlap "$strict_profiles" "$cask_profiles"; then
                continue
            fi
            if ! lists_overlap "$strict_platforms" "$cask_platforms"; then
                continue
            fi

            fail "CLI owner overlap: $strict_app (mise) conflicts with $cask_app (cask) for command '$strict_cmd'"
            overlap_count=$((overlap_count + 1))
        done
    done

    if [[ "$overlap_count" -eq 0 ]]; then
        pass "no strict mise command should overlap with cask CLI owner on same platform/profile"
    fi
}

test_sheldon_source_config() {
    print_header "Sheldon Tool Configuration"
    local sheldon_type sheldon_platform sheldon_linux_type
    sheldon_type=$(get_app_prop sheldon type)
    sheldon_platform=$(get_app_prop sheldon platform)
    sheldon_linux_type=$(get_app_prop sheldon-linux type)

    if [[ "$sheldon_type" == "brew" ]]; then
        pass "sheldon app should exist in apps.toml as brew tool"
    else
        fail "sheldon app should exist in apps.toml as brew tool"
    fi

    if echo "$sheldon_platform" | grep -q "macos" && ! echo "$sheldon_platform" | grep -q "linux"; then
        pass "brew sheldon should be macOS-only"
    else
        fail "brew sheldon should be macOS-only"
    fi

    if [[ "$sheldon_linux_type" == "curl" ]]; then
        pass "sheldon-linux app should exist as curl tool"
    else
        fail "sheldon-linux app should exist as curl tool"
    fi

    assert_true "sheldon-linux should be Linux-supported" is_app_supported sheldon-linux linux
}

test_curl_registry_scope() {
    print_header "Curl Registry Scope"

    local curl_keys=""
    local curl_count=0
    local app_key
    for app_key in $(get_all_apps); do
        local app_type
        app_type=$(get_app_prop "$app_key" "type")
        if [[ "$app_type" != "curl" ]]; then
            continue
        fi

        curl_count=$((curl_count + 1))
        if [[ -z "$curl_keys" ]]; then
            curl_keys="$app_key"
        else
            curl_keys="$curl_keys, $app_key"
        fi
    done

    if [[ "$curl_count" -eq 1 && "$curl_keys" == "sheldon-linux" ]]; then
        pass "only sheldon-linux should be configured as curl app"
    else
        fail "only sheldon-linux should be configured as curl app (found: ${curl_keys:-none})"
    fi
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
    assert_true "Fedora bootstrap should use zlib-ng-compat-devel" is_grep_match 'zlib-ng-compat-devel' "$bootstrap_file"
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

test_curl_layer_linux_tools() {
    print_header "Curl Layer Linux Tools"
    local curl_layer_file="$DOTFILES_DIR/scripts/install/layer_curl.sh"
    assert_false "curl layer should not include claude-cli installer path" is_grep_match 'claude-cli)' "$curl_layer_file"
    assert_false "curl layer should not include opencode-cli installer path" is_grep_match 'opencode-cli)' "$curl_layer_file"
    assert_true "curl layer should support sheldon-linux installer" is_grep_match 'sheldon-linux' "$curl_layer_file"
    assert_true "curl layer should include sheldon binary installer" is_grep_match 'install_sheldon_linux_binary' "$curl_layer_file"
    assert_true "curl layer should fail when selected curl tools fail" is_grep_match 'Curl layer failed for selected tools' "$curl_layer_file"
}

test_reconcile_fail_fast_guards() {
    print_header "Reconcile Fail-Fast Guards"
    local reconcile_file="$DOTFILES_DIR/scripts/install/reconcile_casks.sh"
    local homebrew_layer_file="$DOTFILES_DIR/scripts/install/layer_homebrew.sh"

    assert_true "reconcile should aggregate failures and return non-zero" is_grep_match 'Cask reconciliation failed for:' "$reconcile_file"
    assert_true "homebrew layer should fail on unresolved unmanaged casks after reconcile" is_grep_match 'Homebrew cask layer failed due to unresolved unmanaged casks:' "$homebrew_layer_file"
    assert_false "reconcile should not swallow brew install failures with || true" bash -c "sed -n '/reconcile_single_cask()/,/^}/p' '$reconcile_file' | grep -q 'brew install --cask .*|| true'"
    assert_false "reconcile should not use inverted install capture that masks exit code" is_grep_match 'if ! install_output=' "$reconcile_file"
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
    test_linux_layer_upgrade_behavior
    test_ai_cli_single_source_fields
    test_codex_owner_split
    test_keymapp_profiles
    test_cask_kind_metadata
    test_no_cli_owner_overlap
    test_sheldon_source_config
    test_curl_registry_scope
    test_mise_registry_entries
    test_bootstrap_linux_path
    test_macos_guards
    test_summary_fallback
    test_curl_layer_linux_tools
    test_reconcile_fail_fast_guards
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
