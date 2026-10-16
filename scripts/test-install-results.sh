#!/bin/bash
# Behavioural regressions. All package, network and shell changes are mocked.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DOTFILES_DIR="$ROOT"
source "$ROOT/scripts/lib/summary.sh"
source "$ROOT/scripts/install/summary.sh"
log_warning() { :; }
log_error() { :; }
log_info() { :; }
log_success() { echo "package log output"; }
check() { if "$@"; then echo "PASS: $*"; else echo "FAIL: $*"; exit 1; fi; }
reset_results() {
    SUMMARY_INSTALLED=''; SUMMARY_SKIPPED=''; SUMMARY_REMOVED=''; SUMMARY_FAILED=''
    FAILED_SUMMARY_KEYS='|'; INSTALL_HAD_ERRORS=false; INSTALL_SUMMARY_SHOWN=false
}
reset_results
first_failed() { record_install_failure first 'deliberate failure'; return 1; }
later_succeeded() { LATER_RAN=true; }
LATER_RAN=false
run_install_step first first_failed
run_install_step later later_succeeded
check test "$LATER_RAN" = true
check test "$INSTALL_HAD_ERRORS" = true
check test "$SUMMARY_FAILED" = 'first|deliberate failure'
record_install_failure first duplicate
check test "$SUMMARY_FAILED" = 'first|deliberate failure'
# Failed finalization must return nonzero, not replace the process with a shell.
ensure_linux_zsh_default_shell() { return 0; }
print_summary_table() { printf '%s\n' "$1"; }
SELECTED_PROFILES=(clevo); A_LA_CARTE_MODE=false; YES_MODE=true
GREEN=''; BLUE=''; YELLOW=''; NC=''
if output=$(show_summary_and_reload </dev/null); then
    echo 'FAIL: failed install returned success'; exit 1
fi
check test "$output" != ''
case "$output" in *'first|deliberate failure'*) ;; *) exit 1 ;; esac
case "$output" in *'Reloading shell'*) exit 1 ;; esac
reset_results
show_summary_and_reload </dev/null >/dev/null
# Native package results must survive in the parent despite logging on stdout.
source "$ROOT/scripts/install/layer_linux.sh"
log_warning() { :; }; log_error() { :; }; log_info() { :; }
log_success() { echo 'package log output'; }
get_app_display_name() { echo "$1"; }
get_app_prop() { [[ "$2" == description ]] && echo 'mock package'; return 0; }
pm_get_version() { echo unknown; }
pm_install() { echo 'apt progress output'; return 0; }
install_linux_mapped_brew_app good good >/dev/null
check test "$LINUX_PACKAGE_RESULT" = installed
check test "$SUMMARY_INSTALLED" = 'good|mock package'
# A missing package must be reported and must not prevent a later install.
reset_results
get_all_apps() { printf '%s\n' missing good; }
app_selected_for_install() { return 0; }
detect_platform() { echo linux; }; pm_get_manager() { echo apt; }
detect_linux_distro() { echo ubuntu; }
get_linux_package_name() { echo "$1"; }
get_app_prop() { case "$2" in type) echo brew;; description) echo 'mock package';; esac; }
prepare_linux_package_repository() { return 0; }
is_linux_repo_package_available() { [[ "$2" != missing ]]; }
if run_layer_linux >/dev/null; then echo 'FAIL: missing package reported success'; exit 1; fi
check test "$SUMMARY_INSTALLED" = 'good|mock package'
case "$SUMMARY_FAILED" in *"missing|Package 'missing' unavailable"*) ;; *) exit 1 ;; esac
# Dependencies must execute before their consumers on a fresh installation.
source "$ROOT/scripts/lib/mise.sh"
reset_results
INSTALLED_APPS=''; FAILED_APPS=''; ORDER=''
get_app_prop() {
    case "$1:$2" in
        opencode-cli:depends_on) echo node;;
        node:version) echo lts;;
        opencode-cli:version) echo latest;;
        opencode-cli:name) echo opencode;;
        node:name) echo node;;
    esac
    return 0
}
get_mise_installed_version() { :; }
mise_registry_has_tool() { return 0; }
# install_mise_app captures mise output, so observe order via a temporary file.
order_file=$(mktemp)
trap 'rm -f "$order_file"' EXIT
mise() {
    case "$1" in install) echo "$2" >> "$order_file";; hook-env) :;; esac
}
install_mise_app opencode-cli >/dev/null
check test "$(cat "$order_file")" = "$(printf 'node@lts\nopencode@latest')"
check test "$(yq -p toml -oy '.apps."opencode-cli".depends_on' "$ROOT/apps.toml")" = node
check test "$(yq -p toml -oy '.apps.tailscale.linux_repository' "$ROOT/apps.toml")" = tailscale
check test "$(yq -p toml -oy '.apps.tailscale.linux_service' "$ROOT/apps.toml")" = tailscaled
printf 'All installer result regressions passed.\n'
