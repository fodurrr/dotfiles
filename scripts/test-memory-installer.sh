#!/bin/bash
# Isolated installer regressions. Never run package managers, live hooks or HTTP.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
if [[ "${MEMORY_TEST_ISOLATED:-}" != 1 ]]; then
    task_home=$(mktemp -d)
    trap 'rm -rf "$task_home"' EXIT
    env HOME="$task_home" XDG_CONFIG_HOME="$task_home/.config" MISE_CONFIG_DIR="$task_home/.mise-config" MISE_GLOBAL_CONFIG_FILE="$task_home/.global-mise.toml" MEMORY_TEST_ISOLATED=1 bash "$0"
    exit $?
fi
DOTFILES_DIR="$ROOT"
APPS_CONFIG="$ROOT/apps.toml"
PROFILES_DIR="$ROOT/profiles"
SELECTED_PROFILES=()
A_LA_CARTE_MODE=false
A_LA_CARTE_SELECTED='|'
A_LA_CARTE_REMOVE=''
EXTRAS_MODE=false
CLEAN_MODE=false
source "$ROOT/scripts/lib/app_config.sh"
source "$ROOT/scripts/lib/app_state.sh"
source "$ROOT/scripts/lib/mise.sh"
source "$ROOT/scripts/lib/memory.sh"
source "$ROOT/scripts/lib/summary.sh"
source "$ROOT/scripts/install/layer_memory.sh"
source "$ROOT/scripts/install/alacarte.sh"
source "$ROOT/scripts/install/interactive.sh"
log_error() { :; }
log_warning() { :; }
log_info() { :; }
pm_get_manager() { echo fixture; }
check() { if "$@"; then printf 'PASS: %s\n' "$*"; else printf 'FAIL: %s\n' "$*"; exit 1; fi; }
reject() { if "$@"; then printf 'FAIL: accepted %s\n' "$*"; exit 1; else printf 'PASS: rejected %s\n' "$*"; fi; }
reset_results() {
    SUMMARY_INSTALLED=''; SUMMARY_SKIPPED=''; SUMMARY_REMOVED=''; SUMMARY_FAILED=''
    FAILED_SUMMARY_KEYS='|'; INSTALL_HAD_ERRORS=false
}
# The real TOML/profile union has only the independent component and Node.
for platform in macos linux; do
    check validate_profile_apps_for_platform hindsight-memory "$platform"
    members=$(get_profile_apps_for_platform hindsight-memory "$platform" | sort)
    check test "$members" = "$(printf 'hindsight-memory\nnode')"
done
check is_installable_app hindsight-memory
reject is_alacarte_app hindsight-memory
check is_alacarte_app node
check test "$(get_app_prop hindsight-memory depends_on)" = node
# The guard and the generator share recursive tool selection (for example pnpm).
SELECTED_PROFILES=(hindsight-memory)
check memory_selection_requested
check test "$(memory_selected_runtime_keys)" = node
check check_memory_install_safety
CLEAN_MODE=true
reject check_memory_install_safety
CLEAN_MODE=false
mkdir -p "$HOME/.config/mise"
printf '[tools]\nnode="24.22.0"\n' > "$HOME/.config/mise/config.toml"
reject check_memory_install_safety
# Small custom base profile proves runtime keys, rather than profile names, matter.
fixture_profiles="$HOME/profiles"
mkdir -p "$fixture_profiles"
cp "$ROOT/profiles/hindsight-memory.toml" "$fixture_profiles/hindsight-memory.toml"
cat > "$fixture_profiles/base.toml" <<'TOML'
version=1
[linux.runtimes]
apps=["pnpm"]
[linux.cli]
apps=["jq"]
TOML
PROFILES_DIR="$fixture_profiles"
SELECTED_PROFILES=(base hindsight-memory)
check check_memory_install_safety
printf '[tools]\nnode="24.22.0"\npython="3.14"\n' > "$HOME/.config/mise/config.toml"
reject check_memory_install_safety
# Missing or invalid global config never permits overwrite/prune.
printf 'bad = [' > "$HOME/.config/mise/config.toml"
reject check_memory_install_safety
rm "$HOME/.config/mise/config.toml"
ln -s "$HOME/absent-config.toml" "$HOME/.config/mise/config.toml"
reject check_memory_install_safety
rm "$HOME/.config/mise/config.toml"
SELECTED_PROFILES=(base)
check check_memory_install_safety
# Pre-bootstrap safety: a missing parser cannot change a configured host.
# Replacing yq with a failing function is scoped to this isolated test shell.
yq() { return 127; }
printf '[tools]\nnode="24.22.0"\n' > "$HOME/.config/mise/config.toml"
reject memory_prebootstrap_selection
rm "$HOME/.config/mise/config.toml"
CLEAN_MODE=true
reject memory_prebootstrap_selection
CLEAN_MODE=false
check memory_prebootstrap_selection
unset -f yq
# Real installer entrypoint, with bootstrap replaced by a forbidden-mutation marker.
# This also verifies that custom profile names cannot bypass the early guard.
entry_fixture="$HOME/entrypoint"
mkdir -p "$entry_fixture/scripts" "$entry_fixture/profiles"
cp "$ROOT/install.sh" "$ROOT/apps.toml" "$entry_fixture/"
cp -R "$ROOT/scripts/lib" "$ROOT/scripts/install" "$entry_fixture/scripts/"
cp "$ROOT/profiles/hindsight-memory.toml" "$entry_fixture/profiles/custom-memory.toml"
cat > "$entry_fixture/scripts/install/bootstrap.sh" <<'SH'
run_bootstrap() { touch "$HOME/bootstrap-was-called"; return 99; }
SH
reject bash "$entry_fixture/install.sh" --profile=custom-memory --clean --yes
check test ! -e "$HOME/bootstrap-was-called"
reject bash "$entry_fixture/install.sh" --profile=custom-memory --yes
# A fresh additive profile may reach bootstrap; configured addon-only must not.
check test -e "$HOME/bootstrap-was-called"
rm "$HOME/bootstrap-was-called"
printf '[tools]\nnode="24.22.0"\n' > "$HOME/.config/mise/config.toml"
reject bash "$entry_fixture/install.sh" --profile=custom-memory --yes
check test ! -e "$HOME/bootstrap-was-called"
rm "$HOME/.config/mise/config.toml"
# Result contracts must reject string booleans and active/configured contradictions.
valid='{"schema_version":1,"status":"activation-pending","installed":true,"configured":false,"active":false}'
check memory_validate_result "$valid"
reject memory_validate_result '{"schema_version":1,"status":"active","installed":true,"configured":false,"active":true}'
reject memory_validate_result '{"schema_version":1,"status":"active","installed":true,"configured":true,"active":false}'
reject memory_validate_result '{"schema_version":1,"status":"activation-pending","installed":"true","configured":false,"active":false}'
reject memory_validate_result '{"schema_version":2,"status":"active","installed":true,"configured":true,"active":true}'
reject memory_validate_result '{"schema_version":1,"status":"partial","installed":true,"configured":true,"active":true}'
check memory_read_status
check test "$MEMORY_STATUS_LABEL" = missing
# Always inspect the owned absolute launcher path, never a command from PATH.
mkdir -p "$HOME/.local/bin" "$HOME/path-bin"
cat > "$HOME/path-bin/hindsight-memory" <<'SH'
#!/bin/bash
exit 99
SH
chmod +x "$HOME/path-bin/hindsight-memory"
PATH="$HOME/path-bin:$PATH"
check memory_read_status
check test "$MEMORY_STATUS_INSTALLED" = false
cat > "$HOME/.local/bin/hindsight-memory" <<'SH'
#!/bin/bash
[[ "$1" == status ]] || exit 1
printf '%s\n' '{"schema_version":1,"status":"activation-pending","installed":true,"configured":false,"active":false}'
SH
chmod +x "$HOME/.local/bin/hindsight-memory"
check memory_read_status
check test "$MEMORY_STATUS_LABEL" = activation-pending
check is_app_installed hindsight-memory
# A binary on disk without a valid status is not readiness.
printf '#!/bin/bash\necho "sensitive diagnostic"\n' > "$HOME/.local/bin/hindsight-memory"
reject memory_read_status
reject is_app_installed hindsight-memory
# A la carte removal refuses memory and leaves owned files and config intact.
reset_results
reject remove_alacarte_app hindsight-memory
check test -f "$HOME/.local/bin/hindsight-memory"
check test "$INSTALL_HAD_ERRORS" = true
# Preparation tests use an absolute fake mise-owned Node and never resolve PATH Node.
fixture_node="$HOME/fake-node"
cat > "$fixture_node" <<'SH'
#!/bin/bash
if [[ "$1" == --input-type=module ]]; then exit "${MEMORY_PROBE_EXIT:-0}"; fi
[[ "$2" == prepare ]] || exit 1
printf '%s\n' "${MEMORY_PREPARE_RESULT}"
exit "${MEMORY_PREPARE_EXIT:-0}"
SH
chmod +x "$fixture_node"
mise() { [[ "$1:$2" == 'which:node' ]] && printf '%s\n' "$fixture_node"; }
export MEMORY_PREPARE_RESULT="$valid"
export MEMORY_PREPARE_EXIT=0 MEMORY_PROBE_EXIT=0
check memory_resolve_node
MEMORY_PROBE_EXIT=1
reject memory_resolve_node
MEMORY_PROBE_EXIT=0
mise() { echo node; }
reject memory_resolve_node
mise() { printf '%s\n' "$fixture_node"; }
# Build an artifact sentinel; the fake runtime never executes its contents.
fixture_checkout="$HOME/checkout"
mkdir -p "$fixture_checkout/tools/hindsight-memory/src"
printf 'not executable test fixture\n' > "$fixture_checkout/tools/hindsight-memory/src/cli.mjs"
DOTFILES_DIR="$fixture_checkout"
PROFILES_DIR="$fixture_profiles"
SELECTED_PROFILES=(hindsight-memory)
reset_results
check run_layer_memory
check test "$INSTALL_HAD_ERRORS" = false
case "$SUMMARY_INSTALLED" in *'activation-pending'*) ;; *) exit 1 ;; esac
reset_results
MEMORY_PREPARE_RESULT='{"schema_version":1,"status":"partial","installed":true,"configured":false,"active":false}'
reject run_layer_memory
check test "$INSTALL_HAD_ERRORS" = true
reset_results
MEMORY_PREPARE_RESULT='sensitive diagnostic'
output=$(run_install_step memory run_layer_memory)
case "$output:$SUMMARY_FAILED" in *'sensitive diagnostic'*) echo 'FAIL: raw result leaked'; exit 1;; esac
# Parent failure state is retained and later independent phases still run.
LATER_RAN=false
later() { LATER_RAN=true; }
run_install_step memory run_layer_memory
run_install_step later later
check test "$LATER_RAN" = true
check test "$INSTALL_HAD_ERRORS" = true
reset_results
MEMORY_PREPARE_RESULT="$valid"
MEMORY_PREPARE_EXIT=1
reject run_layer_memory
check test "$INSTALL_HAD_ERRORS" = true
# Verify real orchestration places guards before removal/config/prune and prepares later.
python3 - "$ROOT/install.sh" <<'PY'
import sys
s=open(sys.argv[1]).read()
assert s.index('\nmemory_prebootstrap_selection\n') < s.index('\nrun_bootstrap\n')
assert s.index('\ncheck_memory_install_safety\n') < s.index('\nrun_alacarte_removals\n')
assert s.index('\ncheck_memory_install_safety\n') < s.index('run_install_step "Mise configuration"')
assert s.index('run_install_step "Mise tools"') < s.index('run_install_step "Personal memory preparation"')
assert s.index('run_install_step "Linux desktop apps"') < s.index('run_install_step "Personal memory preparation"')
print('PASS: guard and preparation ordering')
PY
printf 'All isolated memory installer checks passed.\n'
