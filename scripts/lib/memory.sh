# Optional standalone memory preparation. Never activate capture in the installer.

memory_selection_requested() {
    local app_key
    for app_key in $(yq -p toml -r '.apps | to_entries | .[] | select(.value.type == "memory") | .key' "$APPS_CONFIG" 2>/dev/null); do
        if app_selected_for_install "$app_key"; then
            return 0
        fi
    done
    return 1
}

memory_global_mise_configs() {
    # Include legacy and explicit global locations. Symlinks are normal for Stow.
    printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml" "$HOME/.mise.toml"
    [[ -z "${MISE_CONFIG_DIR:-}" ]] || printf '%s\n' "$MISE_CONFIG_DIR/config.toml"
    [[ -z "${MISE_GLOBAL_CONFIG_FILE:-}" ]] || printf '%s\n' "$MISE_GLOBAL_CONFIG_FILE"
    return 0
}

# Selection needs TOML support. Existing hosts must be inspected before bootstrap.
# Discovery flags already exit inside parse_args and do not reach this function.
memory_prebootstrap_selection() {
    [[ "${CREATE_PROFILE_MODE:-false}" != true ]] || return 0
    if command -v yq >/dev/null 2>&1 && yq -p toml -r '.apps.node.type' "$APPS_CONFIG" >/dev/null 2>&1; then
        run_profile_selection
        check_memory_install_safety || return 1
        MEMORY_PROFILE_SELECTION_DONE=true
        return 0
    fi

    # A missing TOML parser must not authorize destructive cleanup or config changes.
    if [[ "$CLEAN_MODE" == true ]]; then
        log_error "Install TOML-capable yq before --clean; runtime safety cannot be checked"
        return 1
    fi
    local config
    while IFS= read -r config; do
        if [[ -e "$config" || -L "$config" ]]; then
            log_error "Install TOML-capable yq before installation on this configured host; runtime safety cannot be checked"
            return 1
        fi
    done < <(memory_global_mise_configs)
    # Fresh, additive installation may bootstrap yq before its first selection.
}

memory_selected_runtime_keys() {
    # Reuse the real generator, including its mise dependency traversal.
    local preview
    preview=$(mktemp) || return 1
    printf '[tools]\n' > "$preview"
    if ! write_selected_mise_tools "$preview"; then
        rm -f "$preview"
        return 1
    fi
    local keys
    if ! keys=$(yq -p toml -r '.tools | keys | .[]' "$preview" 2>/dev/null); then
        rm -f "$preview"
        return 1
    fi
    rm -f "$preview"
    printf '%s\n' "$keys"
}

check_memory_install_safety() {
    memory_selection_requested || return 0
    if [[ "$CLEAN_MODE" == true ]]; then
        log_error "Memory preparation refuses --clean; use an additive profile selection"
        return 1
    fi
    if [[ "${EXTRAS_MODE:-false}" == true || "${A_LA_CARTE_MODE:-false}" == true ]]; then
        log_error "Memory preparation requires profile selection; extras and a la carte are unsupported"
        return 1
    fi
    if ! app_selected_for_install node; then
        log_error "Memory preparation requires explicit node membership in the selected profiles"
        return 1
    fi

    local addon_only=true app_key
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key"; then
            if [[ "$app_key" != node && "$(get_app_prop "$app_key" type)" != memory ]]; then
                addon_only=false
            fi
        fi
    done

    local wanted
    if ! wanted=$(memory_selected_runtime_keys); then
        log_error "Cannot preview selected mise runtimes; memory preparation refused"
        return 1
    fi
    local config keys key
    while IFS= read -r config; do
        [[ -e "$config" || -L "$config" ]] || continue
        if [[ "$addon_only" == true ]]; then
            log_error "Memory-only profile refused on a configured host; select the complete existing profile set"
            return 1
        fi
        # Do not print configuration contents, parser errors or keys into install.log.
        if ! keys=$(yq -p toml -r '.tools // {} | keys | .[]' "$config" 2>/dev/null); then
            log_error "Existing global mise configuration cannot be read; memory preparation refused"
            return 1
        fi
        while IFS= read -r key; do
            [[ -z "$key" ]] && continue
            if ! printf '%s\n' "$wanted" | grep -Fxq -- "$key"; then
                log_error "Selected profiles would drop an existing mise runtime; memory preparation refused"
                return 1
            fi
        done <<< "$keys"
    done < <(memory_global_mise_configs)
}

memory_validate_result() {
    local result="$1"
    [[ ${#result} -le 8192 ]] || return 1
    # Never echo untrusted CLI output: installer logging persists every line.
    printf '%s' "$result" | jq -e '
        type == "object" and .schema_version == 1 and
        (.installed | type == "boolean") and
        (.configured | type == "boolean") and
        (.active | type == "boolean") and
        (.status == "activation-pending" or .status == "configured" or
         .status == "active" or .status == "partial" or .status == "failed" or
         .status == "missing") and
        ((.configured | not) or .installed) and
        ((.active | not) or (.installed and .configured)) and
        ((.status == "active") == .active) and
        ((.status != "activation-pending") or (.installed and (.active | not))) and
        ((.status != "configured") or (.installed and .configured and (.active | not))) and
        ((.status != "missing") or ((.installed | not) and (.configured | not) and (.active | not)))
    ' >/dev/null 2>&1
}

memory_read_status() {
    MEMORY_STATUS_INSTALLED=false
    MEMORY_STATUS_CONFIGURED=false
    MEMORY_STATUS_ACTIVE=false
    MEMORY_STATUS_LABEL=unavailable
    local launcher="$HOME/.local/bin/hindsight-memory" result
    if [[ ! -e "$launcher" && ! -L "$launcher" ]]; then
        MEMORY_STATUS_LABEL=missing
        return 0
    fi
    [[ -f "$launcher" && -x "$launcher" && -O "$launcher" && ! -L "$launcher" ]] || return 1
    if ! result=$("$launcher" status 2>/dev/null); then
        return 1
    fi
    memory_validate_result "$result" || return 1
    MEMORY_STATUS_INSTALLED=$(printf '%s' "$result" | jq -r .installed)
    MEMORY_STATUS_CONFIGURED=$(printf '%s' "$result" | jq -r .configured)
    MEMORY_STATUS_ACTIVE=$(printf '%s' "$result" | jq -r .active)
    MEMORY_STATUS_LABEL=$(printf '%s' "$result" | jq -r .status)
}
