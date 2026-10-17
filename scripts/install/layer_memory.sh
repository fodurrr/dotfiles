# Cross-platform optional memory artifacts. Activation is a separate host action.

memory_resolve_node() {
    MEMORY_NODE=""
    local candidate
    command -v mise >/dev/null 2>&1 || return 1
    if ! candidate=$(mise which node 2>/dev/null); then
        return 1
    fi
    case "$candidate" in /*) ;; *) return 1 ;; esac
    [[ -f "$candidate" && -x "$candidate" ]] || return 1
    # Verify actual API availability, not the version printed by mise metadata.
    if ! "$candidate" --input-type=module -e '
        const [major, minor] = process.versions.node.split(".").map(Number);
        if (major !== 24 || minor < 15) process.exit(1);
        const { DatabaseSync } = await import("node:sqlite");
        if (typeof DatabaseSync !== "function") process.exit(1);
    ' >/dev/null 2>&1; then
        return 1
    fi
    MEMORY_NODE="$candidate"
}

run_layer_memory() {
    memory_selection_requested || return 0
    local app_key=hindsight-memory result
    if ! memory_resolve_node; then
        record_install_failure "$app_key" "Qualified mise Node >=24.15 and <25 with node:sqlite is unavailable; preparation did not run"
        return 1
    fi
    if [[ ! -f "$DOTFILES_DIR/tools/hindsight-memory/src/cli.mjs" ]]; then
        record_install_failure "$app_key" "Memory component artifacts are missing"
        return 1
    fi
    # Capture and validate output; never forward raw diagnostics to install.log.
    if ! result=$("$MEMORY_NODE" "$DOTFILES_DIR/tools/hindsight-memory/src/cli.mjs" prepare 2>/dev/null); then
        record_install_failure "$app_key" "Memory artifact preparation failed; use the component's safe status diagnostics"
        return 1
    fi
    if ! memory_validate_result "$result"; then
        record_install_failure "$app_key" "Memory preparation returned an invalid result"
        return 1
    fi
    if [[ "$(printf '%s' "$result" | jq -r .installed)" != true ]]; then
        record_install_failure "$app_key" "Memory preparation did not install artifacts"
        return 1
    fi
    local status
    status=$(printf '%s' "$result" | jq -r .status)
    case "$status" in
        activation-pending|configured|active) ;;
        *)
            record_install_failure "$app_key" "Memory preparation is incomplete; use the component's safe status diagnostics"
            return 1
            ;;
    esac
    add_to_summary INSTALLED "hindsight-memory ($status)" "$app_key"
    log_info "Personal memory artifacts prepared; status: $status. Activation is separate."
}
