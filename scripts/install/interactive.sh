# =============================================================================
# PHASE 2: PROFILE SELECTION / A LA CARTE
# =============================================================================

format_app_entry() {
    local app_key="$1"
    local name
    name=$(get_app_display_name "$app_key")
    local type
    type=$(get_app_prop "$app_key" "type")
    echo "- ${name} (${type})"
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

show_profile_summary() {
    local installed_list="$1"
    local to_install_list="$2"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Selected profiles: ${SELECTED_PROFILES[*]}"
    echo ""

    if [[ -n "$installed_list" ]]; then
        echo "Already installed:"
        echo "$installed_list"
        echo ""
    fi

    if [[ -n "$to_install_list" ]]; then
        echo "Will install:"
        echo "$to_install_list"
        echo ""
    else
        echo "Will install:"
        echo "- (none)"
        echo ""
    fi

    confirm_continue
}

show_alacarte_summary() {
    local to_remove_list="$1"
    local to_install_list="$2"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  A la carte Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [[ -n "$to_remove_list" ]]; then
        echo "Will remove:"
        echo "$to_remove_list"
        echo ""
    fi

    if [[ -n "$to_install_list" ]]; then
        echo "Will install:"
        echo "$to_install_list"
        echo ""
    fi

    if [[ -z "$to_remove_list" && -z "$to_install_list" ]]; then
        echo "No changes selected. Exiting."
        exit 0
    fi

    confirm_continue
}

ALACARTE_OPTIONS=()
ALACARTE_SELECTED_VALUES=""

build_alacarte_options() {
    ALACARTE_OPTIONS=()
    ALACARTE_SELECTED_VALUES=""

    local group
    while IFS= read -r group; do
        local group_has_apps=false
        local app_key

        # First pass: detect if group has apps
        for app_key in $(get_all_apps); do
            if ! is_installable_app "$app_key"; then
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
        ALACARTE_OPTIONS+=("── ${group} ──|__HEADER__${group}")

        # Add apps in this group (preserve apps.toml order)
        for app_key in $(get_all_apps); do
            if ! is_installable_app "$app_key"; then
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
                label="${GREEN}${label} (installed)${NC}"
                if [[ -z "$ALACARTE_SELECTED_VALUES" ]]; then
                    ALACARTE_SELECTED_VALUES="$app_key"
                else
                    ALACARTE_SELECTED_VALUES="${ALACARTE_SELECTED_VALUES},${app_key}"
                fi
            fi

            ALACARTE_OPTIONS+=("${label}|${app_key}")
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
        --cursor-prefix "[ ] " \
        --selected-prefix "[x] " \
        --label-delimiter="|" \
        --no-strip-ansi \
        --selected="$ALACARTE_SELECTED_VALUES" \
        "${ALACARTE_OPTIONS[@]}")

    # Build selected list (ignore headers)
    A_LA_CARTE_SELECTED="|"
    local selected_keys=()
    for line in "${SELECTED_ALACARTE[@]}"; do
        if [[ "$line" == __HEADER__* ]]; then
            continue
        fi
        selected_keys+=("$line")
        A_LA_CARTE_SELECTED="${A_LA_CARTE_SELECTED}${line}|"
    done

    # Compute installed set for diff
    local installed_keys=()
    local app_key
    for app_key in $(get_all_apps); do
        if is_installable_app "$app_key"; then
            if is_app_installed "$app_key"; then
                installed_keys+=("$app_key")
            fi
        fi
    done

    # Build to_remove and to_install lists
    local to_remove_list=""
    local to_install_list=""

    for app_key in "${installed_keys[@]}"; do
        if [[ "$A_LA_CARTE_SELECTED" != *"|$app_key|"* ]]; then
            local line_entry
            line_entry=$(format_app_entry "$app_key")
            [[ -z "$to_remove_list" ]] && to_remove_list="$line_entry" || to_remove_list="${to_remove_list}
${line_entry}"
            [[ -z "$A_LA_CARTE_REMOVE" ]] && A_LA_CARTE_REMOVE="$app_key" || A_LA_CARTE_REMOVE="${A_LA_CARTE_REMOVE}
${app_key}"
        fi
    done

    for app_key in "${selected_keys[@]}"; do
        if ! is_app_installed "$app_key"; then
            local line_entry
            line_entry=$(format_app_entry "$app_key")
            [[ -z "$to_install_list" ]] && to_install_list="$line_entry" || to_install_list="${to_install_list}
${line_entry}"
        fi
    done

    show_alacarte_summary "$to_remove_list" "$to_install_list"
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

    # Build profile summary
    local installed_list=""
    local to_install_list=""
    local app_key
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key" && is_installable_app "$app_key"; then
            local line_entry
            line_entry=$(format_app_entry "$app_key")
            if is_app_installed "$app_key"; then
                [[ -z "$installed_list" ]] && installed_list="$line_entry" || installed_list="${installed_list}
${line_entry}"
            else
                [[ -z "$to_install_list" ]] && to_install_list="$line_entry" || to_install_list="${to_install_list}
${line_entry}"
            fi
        fi
    done

    show_profile_summary "$installed_list" "$to_install_list"
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
}
