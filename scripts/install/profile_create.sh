# =============================================================================
# Create Profile Mode
# =============================================================================

is_valid_profile_name() {
    local profile_name="$1"
    [[ "$profile_name" =~ ^[a-z0-9][a-z0-9-]*$ ]]
}

confirm_overwrite_profile() {
    local profile_file="$1"

    if command -v gum >/dev/null 2>&1; then
        gum confirm "Profile exists ($profile_file). Overwrite?" && return 0
        return 1
    fi

    read -p "Profile exists ($profile_file). Overwrite? [y/N] " -n 1 -r
    echo
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

append_pipe_token() {
    local var_name="$1"
    local token="$2"
    local current
    current="${!var_name}"
    if [[ "$current" == *"|$token|"* ]]; then
        return 0
    fi
    printf -v "$var_name" '%s%s|' "$current" "$token"
}

format_toml_array_from_lines() {
    local lines="$1"
    if [[ -z "$lines" ]]; then
        echo "[]"
        return 0
    fi

    local output="["
    local first=true
    local item
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        if [[ "$first" == true ]]; then
            output="${output}\"${item}\""
            first=false
        else
            output="${output}, \"${item}\""
        fi
    done <<< "$lines"
    output="${output}]"
    echo "$output"
}

prompt_profile_name() {
    local name=""

    while true; do
        if command -v gum >/dev/null 2>&1; then
            name=$(gum input --placeholder "profile-name (lowercase letters, numbers, hyphens)" || true)
        else
            read -p "Profile name (lowercase letters, numbers, hyphens): " name
        fi

        if [[ -z "$name" ]]; then
            echo "Profile name cannot be empty."
            continue
        fi

        if ! is_valid_profile_name "$name"; then
            echo "Invalid profile name: '$name'. Use lowercase letters, numbers, and hyphens only."
            continue
        fi

        echo "$name"
        return 0
    done
}

run_profile_create_mode() {
    if [[ "$CREATE_PROFILE_MODE" != true ]]; then
        return 0
    fi

    if ! command -v yq >/dev/null 2>&1; then
        echo "yq is required to create a profile. Run bootstrap first (./install.sh)."
        exit 1
    fi

    mkdir -p "$PROFILES_DIR"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Create Profile"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local profile_name
    profile_name=$(prompt_profile_name)

    local profile_file
    profile_file=$(get_profile_file_path "$profile_name")
    if [[ -f "$profile_file" ]]; then
        if ! confirm_overwrite_profile "$profile_file"; then
            echo "Profile creation canceled."
            exit 1
        fi
    fi

    local current_platform
    current_platform=$(get_current_platform)
    local other_platform="linux"
    [[ "$current_platform" == "linux" ]] && other_platform="macos"

    local app_options=()
    local app_key app_desc app_type
    for app_key in $(get_all_apps); do
        if ! is_app_supported "$app_key" "$current_platform"; then
            continue
        fi
        app_desc=$(get_app_prop "$app_key" "description")
        app_type=$(get_app_prop "$app_key" "type")
        [[ -z "$app_desc" ]] && app_desc="-"
        app_options+=("${app_key}|${app_key} (${app_type}) - ${app_desc}")
    done

    local selected_pipe="|"
    local selected_line

    if command -v gum >/dev/null 2>&1; then
        echo "Select apps for profile '$profile_name' on platform '$current_platform':"
        while IFS= read -r selected_line; do
            [[ -z "$selected_line" ]] && continue
            append_pipe_token selected_pipe "$selected_line"
        done < <(gum choose --no-limit \
            --header "Select app keys for $profile_name ($current_platform)" \
            --cursor-prefix "[ ] " \
            --selected-prefix "[x] " \
            --label-delimiter="|" \
            "${app_options[@]}")
    else
        echo "Select app keys for $profile_name ($current_platform):"
        local choice
        local labels=()
        for selected_line in "${app_options[@]}"; do
            labels+=("${selected_line#*|}")
        done
        select choice in "${labels[@]}" "Done"; do
            if [[ "$choice" == "Done" ]]; then
                break
            fi
            if [[ -n "$choice" ]]; then
                local selected_key="${choice%% (*}"
                append_pipe_token selected_pipe "$selected_key"
                echo "Selected: $selected_key"
            fi
        done
    fi

    local selected_apps_lines=""
    for app_key in $(get_all_apps); do
        if [[ "$selected_pipe" == *"|$app_key|"* ]]; then
            if [[ -z "$selected_apps_lines" ]]; then
                selected_apps_lines="$app_key"
            else
                selected_apps_lines="${selected_apps_lines}
$app_key"
            fi
        fi
    done

    local current_apps_array
    current_apps_array=$(format_toml_array_from_lines "$selected_apps_lines")

    {
        echo "version = 1"
        echo ""
        if [[ "$current_platform" == "macos" ]]; then
            echo "[macos]"
            echo "apps = $current_apps_array"
            echo ""
            echo "[linux]"
            echo "apps = []"
        else
            echo "[macos]"
            echo "apps = []"
            echo ""
            echo "[linux]"
            echo "apps = $current_apps_array"
        fi
        echo ""
    } > "$profile_file"

    if ! validate_profile_apps_for_platform "$profile_name" "$current_platform"; then
        echo "Profile creation failed validation: $profile_file"
        exit 1
    fi

    echo ""
    echo "Created profile: $profile_file"
    echo "Platform section populated: $current_platform"
    exit 0
}
