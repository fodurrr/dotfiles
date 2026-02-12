# =============================================================================
# Mise Helpers
# =============================================================================

# Track installed apps to avoid duplicates (for dependency resolution)
# Using string-based tracking for bash 3.2 compatibility (macOS default)
INSTALLED_APPS=""
MISE_REGISTRY_KEYS=""
MISE_REGISTRY_LOADED=false

load_mise_registry_keys() {
    if [[ "$MISE_REGISTRY_LOADED" == true ]]; then
        return 0
    fi

    if ! command -v mise >/dev/null 2>&1; then
        return 1
    fi

    MISE_REGISTRY_KEYS=$(mise registry 2>/dev/null | awk '{print $1}')
    MISE_REGISTRY_LOADED=true
    return 0
}

mise_registry_has_tool() {
    local tool_name="$1"
    [[ -z "$tool_name" ]] && return 1

    if ! load_mise_registry_keys; then
        return 1
    fi

    echo "$MISE_REGISTRY_KEYS" | grep -Fxq "$tool_name"
}

get_mise_app_tool_name() {
    local app_key="$1"
    local tool_name
    tool_name=$(get_app_prop "$app_key" "name")
    [[ -z "$tool_name" ]] && tool_name="$app_key"
    echo "$tool_name"
}

get_mise_app_command_name() {
    local app_key="$1"
    local command_name
    command_name=$(get_app_prop "$app_key" "bin")
    if [[ -n "$command_name" ]]; then
        echo "$command_name"
        return 0
    fi

    get_mise_app_tool_name "$app_key"
}

mise_single_source_enforced() {
    local app_key="$1"
    local enforce_single_source
    enforce_single_source=$(get_app_prop "$app_key" "enforce_single_source")
    [[ "$enforce_single_source" == "true" ]]
}

get_mise_installed_version() {
    local tool_name="$1"
    local ls_output

    ls_output=$(mise ls "$tool_name" 2>/dev/null || true)
    if [[ -z "$ls_output" ]] || [[ "$ls_output" == *"(missing)"* ]]; then
        echo ""
        return 0
    fi

    mise current "$tool_name" 2>/dev/null || true
}

collect_unique_command_paths() {
    local command_name="$1"
    [[ -z "$command_name" ]] && return 0

    which -a "$command_name" 2>/dev/null | awk 'NF && !seen[$0]++'
}

record_mise_install_summary() {
    local app_key="$1"
    local tool_name="$2"
    local before_version="$3"
    local after_version="$4"

    # Fallback safety: if version lookup failed, count successful install as installed.
    if [[ -z "$after_version" ]]; then
        add_to_summary INSTALLED "$tool_name" "$app_key"
        return 0
    fi

    if [[ -z "$before_version" ]]; then
        add_to_summary INSTALLED "$tool_name" "$app_key"
        return 0
    fi

    if [[ "$before_version" != "$after_version" ]]; then
        add_to_summary INSTALLED "$tool_name" "$app_key"
    else
        add_to_summary SKIPPED "$tool_name" "$app_key"
    fi
}

validate_mise_single_source() {
    local app_key="$1"

    if ! mise_single_source_enforced "$app_key"; then
        return 0
    fi

    local tool_name
    tool_name=$(get_mise_app_tool_name "$app_key")
    local command_name
    command_name=$(get_mise_app_command_name "$app_key")

    if [[ -z "$command_name" ]]; then
        log_error "Single-source enforcement failed for $tool_name: command name is empty"
        return 1
    fi

    local command_paths
    command_paths=$(collect_unique_command_paths "$command_name")
    if [[ -z "$command_paths" ]]; then
        log_error "Single-source enforcement failed for $tool_name: '$command_name' not found on PATH"
        return 1
    fi

    local first_path
    first_path=$(echo "$command_paths" | head -1)
    local path_count
    path_count=$(echo "$command_paths" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
    local expected_prefix="$HOME/.local/share/mise/installs/$tool_name/"
    local validation_failed=false

    if [[ "$path_count" -gt 1 ]]; then
        log_error "Single-source enforcement failed for $tool_name: multiple '$command_name' binaries found"
        validation_failed=true
    fi

    if [[ "$first_path" != "$expected_prefix"* ]]; then
        log_error "Single-source enforcement failed for $tool_name: '$command_name' resolves outside $expected_prefix"
        validation_failed=true
    fi

    if [[ "$validation_failed" == true ]]; then
        log_error "Detected paths for '$command_name':"
        while IFS= read -r path; do
            [[ -z "$path" ]] && continue
            echo "      - $path"
        done <<< "$command_paths"
        log_error "Resolve duplicate command sources and rerun install"
        return 1
    fi

    return 0
}

# Install a mise app with dependency resolution
install_mise_app() {
    local app_key="$1"

    # Skip if already processed this session (pipe delimiters prevent partial matches)
    [[ "$INSTALLED_APPS" == *"|$app_key|"* ]] && return 0

    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise is not installed but required for $app_key"
        return 1
    fi

    # Check for dependency (install silently if needed)
    local dep
    dep=$(get_app_prop "$app_key" "depends_on")
    if [[ -n "$dep" ]]; then
        if ! install_mise_app "$dep"; then
            log_error "Failed dependency '$dep' required by '$app_key'"
            return 1
        fi
    fi

    # Mark as processed
    INSTALLED_APPS="${INSTALLED_APPS}|${app_key}|"

    # Get app details
    local name
    name=$(get_mise_app_tool_name "$app_key")
    local version
    version=$(get_app_prop "$app_key" "version")
    [[ -z "$version" ]] && version="latest"

    if ! mise_registry_has_tool "$name"; then
        log_error "Mise registry does not contain tool: $name (app: $app_key)"
        log_error "Choose a package-manager install source for this app instead of type=mise"
        return 1
    fi

    local installed_version
    installed_version=$(get_mise_installed_version "$name")
    local should_install=false

    if [[ -n "$installed_version" ]]; then
        if [[ "$version" == "latest" ]]; then
            log_info "Refreshing $name@latest (currently $installed_version)..."
            should_install=true
        elif [[ "$version" == "lts" || "$version" == "stable" ]]; then
            # For "lts" or "stable", if any version is installed, keep current behavior.
            add_to_summary SKIPPED "$name" "$app_key"
            return 0
        elif [[ "$installed_version" == "$version"* ]]; then
            # Prefix match: "3.14.2" starts with "3.14" -> skip.
            add_to_summary SKIPPED "$name" "$app_key"
            return 0
        else
            log_info "$name@$installed_version installed, but $version requested, installing..."
            should_install=true
        fi
    else
        log_success "Installing $name@$version..."
        should_install=true
    fi

    if [[ "$should_install" != true ]]; then
        return 0
    fi

    # Capture both stdout and stderr to show errors on failure.
    local install_output
    if install_output=$(mise install "$name@$version" 2>&1); then
        local post_install_version
        post_install_version=$(get_mise_installed_version "$name")
        record_mise_install_summary "$app_key" "$name" "$installed_version" "$post_install_version"
        return 0
    else
        log_error "Failed to install $name"
        # Show first line of error to help debugging.
        local error_line
        error_line=$(echo "$install_output" | grep -i "error\|failed\|not found" | head -1)
        [[ -n "$error_line" ]] && echo "      $error_line"
        return 1
    fi
}

# Generate mise config based on selected profiles
# This creates the config in the dotfiles repo, which then gets symlinked by stow
generate_mise_config() {
    local config_file="$DOTFILES_DIR/mise/.config/mise/config.toml"
    mkdir -p "$(dirname "$config_file")"

    log_info "Generating mise config for selected profiles..."

    # Header
    cat > "$config_file" << 'EOF_MISE'
# =============================================================================
# Mise Config - Auto-generated by install.sh
# =============================================================================
# This file is regenerated based on selected profile(s).
# To add tools permanently, edit apps.toml with type = "mise"
# =============================================================================

[tools]
EOF_MISE

    # Add tools from apps.toml that match selected profiles and type=mise
    local app_key
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key"; then
            local type
            type=$(get_app_prop "$app_key" "type")
            if [[ "$type" == "mise" ]]; then
                local name
                name=$(get_mise_app_tool_name "$app_key")
                local version
                version=$(get_app_prop "$app_key" "version")
                [[ -z "$version" ]] && version="latest"
                echo "$name = \"$version\"" >> "$config_file"
            fi
        fi
    done

    # Settings
    cat >> "$config_file" << 'EOF_MISE'

[settings]
log_level = "info"
experimental = true
EOF_MISE

    log_success "Generated mise config with $(grep -c '=' "$config_file" 2>/dev/null || echo 0) tools"
}
