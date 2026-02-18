# =============================================================================
# PHASE 2: PROFILE SELECTION / A LA CARTE
# =============================================================================

ALACARTE_DIM=$'\033[2m'
ALACARTE_RED=$'\033[0;31m'
ALACARTE_GREEN=$'\033[0;32m'
ALACARTE_RESET=$'\033[0m'

strip_ansi() {
    printf '%s' "$1" | sed -E $'s/\x1B\\[[0-9;]*[mK]//g'
}

format_app_entry() {
    local app_key="$1"
    local name
    name=$(get_app_display_name "$app_key")
    local type
    type=$(get_app_prop "$app_key" "type")
    echo "${name} (${type})"
}

append_list_line() {
    local var_name="$1"
    local line="$2"
    local current
    current="${!var_name}"
    if [[ -z "$current" ]]; then
        printf -v "$var_name" '%s' "$line"
    else
        printf -v "$var_name" '%s\n%s' "$current" "$line"
    fi
}

confirm_continue() {
    if command -v gum &> /dev/null; then
        gum confirm "Continue?" || exit 0
    else
        read -p "Continue? (y/n) " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    fi
}

build_installed_keys() {
    INSTALLED_KEYS=()
    local app_key
    for app_key in $(get_all_apps); do
        if ! is_installable_app "$app_key"; then
            continue
        fi
        if ! is_app_supported "$app_key"; then
            continue
        fi
        if is_app_installed "$app_key"; then
            INSTALLED_KEYS+=("$app_key")
        fi
    done
}

build_selection_diff() {
    local include_removals="$1"

    SELECTION_ALREADY_INSTALLED=""
    SELECTION_TO_INSTALL=""
    SELECTION_TO_REMOVE=""
    SELECTION_REMOVE_KEYS=""

    local selected_set="|"
    local app_key
    for app_key in "${SELECTED_KEYS[@]}"; do
        if [[ "$selected_set" == *"|$app_key|"* ]]; then
            continue
        fi
        selected_set="${selected_set}${app_key}|"
        if is_app_installed "$app_key"; then
            local line_entry
            line_entry=$(format_app_entry "$app_key")
            line_entry="${ALACARTE_DIM}•${ALACARTE_RESET} ${line_entry}"
            append_list_line SELECTION_ALREADY_INSTALLED "$line_entry"
        else
            local line_entry
            line_entry=$(format_app_entry "$app_key")
            line_entry="${ALACARTE_GREEN}✓${ALACARTE_RESET} ${line_entry}"
            append_list_line SELECTION_TO_INSTALL "$line_entry"
        fi
    done

    if [[ "$include_removals" == "true" ]]; then
        for app_key in "${INSTALLED_KEYS[@]}"; do
            if [[ "$selected_set" != *"|$app_key|"* ]]; then
                local line_entry
                line_entry=$(format_app_entry "$app_key")
                line_entry="${ALACARTE_RED}✗${ALACARTE_RESET} ${line_entry}"
                append_list_line SELECTION_TO_REMOVE "$line_entry"
                append_list_line SELECTION_REMOVE_KEYS "$app_key"
            fi
        done
    fi
}

show_selection_summary() {
    local title="$1"
    local selected_label="$2"
    local show_empty_install="$3"
    local exit_if_no_changes="$4"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ${title}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [[ -n "$selected_label" ]]; then
        echo "$selected_label"
        echo ""
    fi

    if [[ -n "$SELECTION_ALREADY_INSTALLED" ]]; then
        echo "Already installed:"
        echo "$SELECTION_ALREADY_INSTALLED"
        echo ""
    fi

    if [[ -n "$SELECTION_TO_REMOVE" ]]; then
        echo "Will remove:"
        echo "$SELECTION_TO_REMOVE"
        echo ""
    fi

    if [[ -n "$SELECTION_TO_INSTALL" ]]; then
        echo "Will install:"
        echo "$SELECTION_TO_INSTALL"
        echo ""
    elif [[ "$show_empty_install" == "true" ]]; then
        echo "Will install:"
        echo "- (none)"
        echo ""
    fi

    if [[ "$exit_if_no_changes" == "true" && -z "$SELECTION_TO_REMOVE" && -z "$SELECTION_TO_INSTALL" ]]; then
        echo "No changes selected. Exiting."
        exit 0
    fi

    confirm_continue
}

ALACARTE_OPTIONS=()
ALACARTE_SELECTED_VALUES=""
ALACARTE_LABELS=()
ALACARTE_VALUES=()

append_selected_value() {
    local value="$1"
    if [[ -z "$ALACARTE_SELECTED_VALUES" ]]; then
        ALACARTE_SELECTED_VALUES="$value"
    else
        ALACARTE_SELECTED_VALUES="${ALACARTE_SELECTED_VALUES},${value}"
    fi
}

alacarte_value_for_label() {
    local label="$1"
    local i
    for ((i=0; i<${#ALACARTE_LABELS[@]}; i++)); do
        if [[ "${ALACARTE_LABELS[$i]}" == "$label" ]]; then
            echo "${ALACARTE_VALUES[$i]}"
            return 0
        fi
    done
    return 1
}

alacarte_value_exists() {
    local value="$1"
    local i
    for ((i=0; i<${#ALACARTE_VALUES[@]}; i++)); do
        if [[ "${ALACARTE_VALUES[$i]}" == "$value" ]]; then
            return 0
        fi
    done
    return 1
}

build_alacarte_options() {
    ALACARTE_OPTIONS=()
    ALACARTE_SELECTED_VALUES=""
    ALACARTE_LABELS=()
    ALACARTE_VALUES=()

    local group
    while IFS= read -r group; do
        local group_has_apps=false
        local app_key

        # First pass: detect if group has apps
        for app_key in $(get_all_apps); do
            if ! is_installable_app "$app_key"; then
                continue
            fi
            if ! is_app_supported "$app_key"; then
                continue
            fi
            local category
            category=$(get_app_category "$app_key")
            local app_group
            app_group=$(get_app_group "$category")
            if [[ "$app_group" == "$group" ]]; then
                group_has_apps=true
                break
            fi
        done

        [[ "$group_has_apps" != true ]] && continue

        # Add group header
        local header_label="${ALACARTE_DIM}── ${group} ──${ALACARTE_RESET}"
        local header_value="__HEADER__${group}"
        ALACARTE_OPTIONS+=("${header_label}|${header_value}")
        ALACARTE_LABELS+=("$header_label")
        ALACARTE_VALUES+=("$header_value")
        local header_label_stripped
        header_label_stripped=$(strip_ansi "$header_label")
        if [[ "$header_label_stripped" != "$header_label" ]]; then
            ALACARTE_LABELS+=("$header_label_stripped")
            ALACARTE_VALUES+=("$header_value")
        fi

        # Add apps in this group (preserve apps.toml order)
        for app_key in $(get_all_apps); do
            if ! is_installable_app "$app_key"; then
                continue
            fi
            if ! is_app_supported "$app_key"; then
                continue
            fi
            local category
            category=$(get_app_category "$app_key")
            local app_group
            app_group=$(get_app_group "$category")
            if [[ "$app_group" != "$group" ]]; then
                continue
            fi

            local name
            name=$(get_app_display_name "$app_key")
            local desc
            desc=$(get_app_prop "$app_key" "description")
            [[ -z "$desc" ]] && desc="-"

            local label="  ${name} — ${desc}"
            if is_app_installed "$app_key"; then
                label="${label} ${ALACARTE_DIM}(installed)${ALACARTE_RESET}"
                append_selected_value "$app_key"
                append_selected_value "$label"
                local label_stripped
                label_stripped=$(strip_ansi "$label")
                if [[ "$label_stripped" != "$label" ]]; then
                    append_selected_value "$label_stripped"
                fi
            fi

            ALACARTE_OPTIONS+=("${label}|${app_key}")
            ALACARTE_LABELS+=("$label")
            ALACARTE_VALUES+=("$app_key")
            local label_stripped
            label_stripped=$(strip_ansi "$label")
            if [[ "$label_stripped" != "$label" ]]; then
                ALACARTE_LABELS+=("$label_stripped")
                ALACARTE_VALUES+=("$app_key")
            fi
        done
    done < <(get_group_order)
}

run_alacarte_selection() {
    A_LA_CARTE_MODE=true
    if [[ "$CLEAN_MODE" == true ]]; then
        log_warning "Clean mode ignored in a la carte selection"
        CLEAN_MODE=false
    fi

    if ! command -v gum &> /dev/null; then
        echo "gum is required for a la carte mode. Please run bootstrap first."
        exit 1
    fi

    echo ""
    echo "Scanning installed apps (this may take a minute)..."

    A_LA_CARTE_REMOVE=""
    build_alacarte_options

    echo ""
    echo "Select apps to install/remove (SPACE to toggle, ENTER to confirm):"
    echo ""

    SELECTED_ALACARTE=()
    local line
    while IFS= read -r line; do
        [[ -n "$line" ]] && SELECTED_ALACARTE+=("$line")
    done < <(gum choose --no-limit \
        --header "A la carte selection" \
        --cursor-prefix "  " \
        --selected-prefix "${ALACARTE_GREEN}✓${ALACARTE_RESET} " \
        --unselected-prefix "  " \
        --label-delimiter="|" \
        --no-strip-ansi \
        --selected="$ALACARTE_SELECTED_VALUES" \
        "${ALACARTE_OPTIONS[@]}")

    echo ""
    echo "Preparing selection summary..."

    # Build selected list (ignore headers)
    A_LA_CARTE_SELECTED="|"
    SELECTED_KEYS=()
    for line in "${SELECTED_ALACARTE[@]}"; do
        local value="$line"
        if [[ "$value" == __HEADER__* ]]; then
            continue
        fi
        if ! alacarte_value_exists "$value"; then
            value=$(alacarte_value_for_label "$line" || true)
        fi
        if [[ -z "$value" || "$value" == __HEADER__* ]]; then
            continue
        fi
        if [[ "$A_LA_CARTE_SELECTED" == *"|$value|"* ]]; then
            continue
        fi
        SELECTED_KEYS+=("$value")
        A_LA_CARTE_SELECTED="${A_LA_CARTE_SELECTED}${value}|"
    done

    # Compute installed set for diff
    build_installed_keys
    build_selection_diff "true"
    A_LA_CARTE_REMOVE="$SELECTION_REMOVE_KEYS"

    show_selection_summary "A la carte Summary" "" "false" "true"
}

run_profiles_selection() {
    # Get profiles into array (compatible with bash 3.x)
    AVAILABLE_PROFILES=()
    local line
    while IFS= read -r line; do
        AVAILABLE_PROFILES+=("$line")
    done < <(get_profiles)

    if command -v gum &> /dev/null; then
        while IFS= read -r line; do
            [[ -n "$line" ]] && SELECTED_PROFILES+=("$line")
        done < <(gum choose --no-limit \
            --header "Which profiles do you want to install? (SPACE to toggle, ENTER to confirm)" \
            --cursor-prefix "[ ] " \
            --selected-prefix "[x] " \
            --selected="minimal" \
            "${AVAILABLE_PROFILES[@]}")
    else
        echo "Available profiles:"
        select profile in "${AVAILABLE_PROFILES[@]}" "Done"; do
            if [[ "$profile" == "Done" ]]; then
                break
            fi
            SELECTED_PROFILES+=("$profile")
            echo "Selected: ${SELECTED_PROFILES[*]}"
        done
    fi

    if [[ ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
        echo "No profiles selected. Using default: minimal"
        SELECTED_PROFILES=("minimal")
    fi

    if ! validate_selected_profiles_for_platform; then
        echo ""
        log_error "Profile validation failed. Fix profile definitions and rerun."
        exit 1
    fi

    echo ""
    echo "Scanning installed apps (this may take a minute)..."
    build_installed_keys

    # Build profile-based selection list (preserve apps.toml order)
    SELECTED_KEYS=()
    local app_key
    for app_key in $(get_all_apps); do
        if app_selected_for_install "$app_key" && is_installable_app "$app_key"; then
            SELECTED_KEYS+=("$app_key")
        fi
    done

    echo ""
    echo "Preparing selection summary..."
    build_selection_diff "$CLEAN_MODE"

    local selected_label="Selected profiles: ${SELECTED_PROFILES[*]}"
    show_selection_summary "Installation Summary" "$selected_label" "true" "false"
}

run_profile_selection() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Phase 2: Profile Selection"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Skip interactive selection if extras mode is explicitly requested
    if [[ "$EXTRAS_MODE" == true ]]; then
        return 0
    fi

    if [[ "$INTERACTIVE" == true && ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
        local mode
        if command -v gum &> /dev/null; then
            mode=$(gum choose --limit=1 \
                --header "Choose installation mode:" \
                --cursor-prefix "○ " \
                --selected-prefix "● " \
                --selected="Profiles (Recommended)" \
                "Profiles (Recommended)" \
                "A la carte")
        else
            echo "Choose installation mode:"
            select mode in "Profiles" "A la carte"; do
                break
            done
            [[ "$mode" == "Profiles" ]] && mode="Profiles (Recommended)"
        fi

        if [[ "$mode" == "A la carte" ]]; then
            run_alacarte_selection
        else
            run_profiles_selection
        fi
    fi

    # Default to minimal if nothing selected (skip for a la carte mode)
    if [[ "$A_LA_CARTE_MODE" != true && ${#SELECTED_PROFILES[@]} -eq 0 && "$EXTRAS_MODE" != true ]]; then
        SELECTED_PROFILES=("minimal")
    fi

    if [[ "$A_LA_CARTE_MODE" != true && "$EXTRAS_MODE" != true ]]; then
        if ! validate_selected_profiles_for_platform; then
            echo ""
            log_error "Profile validation failed. Fix profile definitions and rerun."
            exit 1
        fi
        resolve_selected_apps_for_platform >/dev/null
    fi
}
