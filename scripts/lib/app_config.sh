# =============================================================================
# App Config Helpers
# =============================================================================

# Get available profiles from apps.toml in preferred order
get_profiles() {
    # Extract all unique profiles
    local all_profiles
    all_profiles=$(grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u)

    # Output in preferred order: minimal, standard, developer, hacker, server, then others
    for preferred in minimal standard developer hacker server; do
        echo "$all_profiles" | grep -x "$preferred" 2>/dev/null || true
    done
    # Then any others not in the preferred list
    echo "$all_profiles" | grep -vxE "minimal|standard|developer|hacker|server" 2>/dev/null || true
}

# Check if app belongs to current selection
app_in_profile() {
    local app_key="$1"

    if [[ "$A_LA_CARTE_MODE" == true ]]; then
        if app_in_alacarte_selection "$app_key"; then
            return 0
        fi
        local config_for
        config_for=$(get_app_prop "$app_key" "config_for")
        if [[ -n "$config_for" ]] && app_in_alacarte_selection "$config_for"; then
            return 0
        fi
        return 1
    fi

    local profiles
    profiles=$(yq -p toml -oy ".apps.\"$app_key\".profiles" "$APPS_CONFIG" 2>/dev/null || echo "")
    for profile in "${SELECTED_PROFILES[@]}"; do
        if echo "$profiles" | grep -q "$profile"; then
            return 0
        fi
    done
    return 1
}

# Check if app key is selected in a la carte mode
app_in_alacarte_selection() {
    local app_key="$1"
    [[ "$A_LA_CARTE_SELECTED" == *"|$app_key|"* ]]
}

# Get app property (returns empty string if property doesn't exist)
get_app_prop() {
    local app_key="$1"
    local prop="$2"
    local result
    result=$(yq -p toml -oy ".apps.\"$app_key\".$prop" "$APPS_CONFIG" 2>/dev/null || echo "")
    # yq returns literal "null" for missing properties, convert to empty string
    [[ "$result" == "null" ]] && result=""
    echo "$result"
}

# Get all app keys (extract [apps.X] sections)
get_all_apps() {
    grep -oE '^\[apps\.[^]]+\]' "$APPS_CONFIG" | sed 's/\[apps\.//;s/\]//'
}

# Get app category
get_app_category() {
    get_app_prop "$1" "category"
}

# Get app display name
get_app_display_name() {
    local app_key="$1"
    local name
    name=$(get_app_prop "$app_key" "name")
    [[ -z "$name" ]] && name="$app_key"
    echo "$name"
}

# Check if app is installable (exclude stow/defaults)
is_installable_app() {
    local app_key="$1"
    local type
    type=$(get_app_prop "$app_key" "type")
    case "$type" in
        cask|brew|mise|curl) return 0 ;;
        *) return 1 ;;
    esac
}

# Map category to one of 7 display groups
get_app_group() {
    local category="$1"
    case "$category" in
        browsers|fonts)
            echo "Core & Browsing"
            ;;
        terminals|editors)
            echo "Terminals & Editors"
            ;;
        ai)
            echo "AI & Automation"
            ;;
        productivity|communication|office|cloud-storage)
            echo "Productivity & Communication"
            ;;
        media)
            echo "Media & Creativity"
            ;;
        window-management|status-bar|display|security|utilities)
            echo "System & Window Management"
            ;;
        cli|runtimes|database|virtualization)
            echo "Developer Platforms"
            ;;
        *)
            echo "Other"
            ;;
    esac
}

# Output group order (one per line)
get_group_order() {
    cat << 'EOF'
Core & Browsing
Terminals & Editors
AI & Automation
Productivity & Communication
Media & Creativity
System & Window Management
Developer Platforms
Other
EOF
}
