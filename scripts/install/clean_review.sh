# =============================================================================
# Homebrew clean review
# =============================================================================

append_clean_line() {
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

get_bootstrap_brews() {
    if [[ -f "$DOTFILES_DIR/Brewfile.bootstrap" ]]; then
        grep -E '^brew "' "$DOTFILES_DIR/Brewfile.bootstrap" | sed -E 's/^brew "([^"]+)".*/\1/'
    fi
}

get_bootstrap_casks() {
    if [[ -f "$DOTFILES_DIR/Brewfile.bootstrap" ]]; then
        grep -E '^cask "' "$DOTFILES_DIR/Brewfile.bootstrap" | sed -E 's/^cask "([^"]+)".*/\1/'
    fi
}

is_in_newline_set() {
    local value="$1"
    local set_lines="$2"
    echo "$set_lines" | grep -Fxq "$value"
}

collect_clean_candidates() {
    CLEAN_TRACKED_ENTRIES=""
    CLEAN_UNTRACKED_ENTRIES=""
    CLEAN_REMOVE_ENTRIES=""

    local app_key
    for app_key in $(get_all_apps); do
        if app_in_profile "$app_key"; then
            continue
        fi

        local type
        type=$(get_app_prop "$app_key" "type")
        local name
        name=$(get_app_prop "$app_key" "name")
        [[ -z "$name" ]] && name="$app_key"

        case "$type" in
            cask)
                local state
                state=$(get_cask_install_state "$name")
                if [[ "$state" == "managed" || "$state" == "unmanaged" ]]; then
                    append_clean_line CLEAN_TRACKED_ENTRIES "cask|$name|$app_key|$state|tracked"
                fi
                ;;
            brew)
                if brew list 2>/dev/null | grep -q "^${name}$"; then
                    append_clean_line CLEAN_TRACKED_ENTRIES "brew|$name|$app_key|managed|tracked"
                fi
                ;;
        esac
    done

    local tracked_casks=""
    local tracked_brews=""
    for app_key in $(get_all_apps); do
        local type
        type=$(get_app_prop "$app_key" "type")
        local name
        name=$(get_app_prop "$app_key" "name")
        [[ -z "$name" ]] && name="$app_key"
        case "$type" in
            cask)
                append_clean_line tracked_casks "$name"
                ;;
            brew)
                append_clean_line tracked_brews "$name"
                ;;
        esac
    done

    local bootstrap_brews
    bootstrap_brews=$(get_bootstrap_brews)
    local bootstrap_casks
    bootstrap_casks=$(get_bootstrap_casks)

    local cask
    for cask in $(brew list --cask 2>/dev/null); do
        if is_in_newline_set "$cask" "$tracked_casks"; then
            continue
        fi
        if is_in_newline_set "$cask" "$bootstrap_casks"; then
            continue
        fi
        append_clean_line CLEAN_UNTRACKED_ENTRIES "cask|$cask|-|managed|untracked"
    done

    local brew_pkg
    for brew_pkg in $(brew list --formula 2>/dev/null); do
        if is_in_newline_set "$brew_pkg" "$tracked_brews"; then
            continue
        fi
        if is_in_newline_set "$brew_pkg" "$bootstrap_brews"; then
            continue
        fi
        append_clean_line CLEAN_UNTRACKED_ENTRIES "brew|$brew_pkg|-|managed|untracked"
    done
}

prepare_homebrew_clean_selection() {
    if [[ "$CLEAN_MODE" != true || "$CLEAN_SAFE" != true ]]; then
        return 0
    fi

    collect_clean_candidates

    if [[ -z "$CLEAN_TRACKED_ENTRIES" && -z "$CLEAN_UNTRACKED_ENTRIES" ]]; then
        return 0
    fi

    if [[ "$YES_MODE" == true ]]; then
        CLEAN_REMOVE_ENTRIES="$CLEAN_TRACKED_ENTRIES"
        if [[ "$CLEAN_UNTRACKED" == true && -n "$CLEAN_UNTRACKED_ENTRIES" ]]; then
            if [[ -n "$CLEAN_REMOVE_ENTRIES" ]]; then
                CLEAN_REMOVE_ENTRIES="${CLEAN_REMOVE_ENTRIES}
${CLEAN_UNTRACKED_ENTRIES}"
            else
                CLEAN_REMOVE_ENTRIES="$CLEAN_UNTRACKED_ENTRIES"
            fi
        fi
        return 0
    fi

    if ! command -v gum >/dev/null 2>&1; then
        CLEAN_REMOVE_ENTRIES="$CLEAN_TRACKED_ENTRIES"
        if [[ "$CLEAN_UNTRACKED" == true && -n "$CLEAN_UNTRACKED_ENTRIES" ]]; then
            if [[ -n "$CLEAN_REMOVE_ENTRIES" ]]; then
                CLEAN_REMOVE_ENTRIES="${CLEAN_REMOVE_ENTRIES}
${CLEAN_UNTRACKED_ENTRIES}"
            else
                CLEAN_REMOVE_ENTRIES="$CLEAN_UNTRACKED_ENTRIES"
            fi
        fi
        return 0
    fi

    local options=()
    local selected=""
    local line

    options+=("── Managed apps outside current target (preselected) ──|__HEADER__TRACKED")
    while IFS='|' read -r kind name app_key state source; do
        [[ -z "$kind" ]] && continue
        local value
        value="${kind};${name};${app_key};${state};${source}"
        options+=("${name} (${kind}, ${state}, tracked)|${value}")
        if [[ -z "$selected" ]]; then
            selected="$value"
        else
            selected="${selected},${value}"
        fi
    done <<< "$CLEAN_TRACKED_ENTRIES"

    if [[ -n "$CLEAN_UNTRACKED_ENTRIES" ]]; then
        options+=("── Untracked Homebrew installs (optional) ──|__HEADER__UNTRACKED")
        while IFS='|' read -r kind name app_key state source; do
            [[ -z "$kind" ]] && continue
            local value
            value="${kind};${name};${app_key};${state};${source}"
            options+=("${name} (${kind}, untracked)|${value}")
            if [[ "$CLEAN_UNTRACKED" == true ]]; then
                if [[ -z "$selected" ]]; then
                    selected="$value"
                else
                    selected="${selected},${value}"
                fi
            fi
        done <<< "$CLEAN_UNTRACKED_ENTRIES"
    fi

    echo ""
    echo "Select packages to remove (tracked are preselected):"
    local chosen=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && chosen+=("$line")
    done < <(gum choose --no-limit \
        --header "Clean review" \
        --cursor-prefix "  " \
        --selected-prefix "✓ " \
        --unselected-prefix "  " \
        --label-delimiter="|" \
        --selected="$selected" \
        "${options[@]}")

    CLEAN_REMOVE_ENTRIES=""
    for line in "${chosen[@]}"; do
        [[ "$line" == __HEADER__* ]] && continue
        local kind name app_key state source
        IFS=';' read -r kind name app_key state source <<< "$line"
        [[ -z "$kind" || -z "$name" ]] && continue
        append_clean_line CLEAN_REMOVE_ENTRIES "${kind}|${name}|${app_key}|${state}|${source}"
    done
}
