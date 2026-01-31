#!/bin/bash

# =============================================================================
# Doctor Mode: Read-only checks for selected profiles
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Doctor Mode"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Selected profiles: ${SELECTED_PROFILES[*]}"

if [[ ! -f "$APPS_CONFIG" ]]; then
    log_error "apps.toml not found: $APPS_CONFIG"
    exit 1
fi

echo ""
echo "Core tools:"
for tool in brew stow mise yq; do
    if command -v "$tool" >/dev/null 2>&1; then
        log_success "$tool found"
    else
        log_warning "$tool missing"
    fi
done

echo ""
echo "Profile health:"

MISSING_APPS=""
MISSING_CASKS=""
MISSING_BREWS=""
MISSING_MISE=""
MISSING_STOW=""

TOTAL_APPS=0

for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        TOTAL_APPS=$((TOTAL_APPS + 1))
        type=$(get_app_prop "$app_key" "type")
        case "$type" in
            cask|brew|mise|stow)
                if ! is_app_installed "$app_key"; then
                    case "$type" in
                        cask)
                            MISSING_CASKS="${MISSING_CASKS}${app_key}\n"
                            ;;
                        brew)
                            MISSING_BREWS="${MISSING_BREWS}${app_key}\n"
                            ;;
                        mise)
                            MISSING_MISE="${MISSING_MISE}${app_key}\n"
                            ;;
                        stow)
                            MISSING_STOW="${MISSING_STOW}${app_key}\n"
                            ;;
                    esac
                    MISSING_APPS="${MISSING_APPS}${app_key}\n"
                fi
                ;;
            curl)
                # curl tools are checked by binary presence in is_app_installed
                if ! is_app_installed "$app_key"; then
                    MISSING_APPS="${MISSING_APPS}${app_key}\n"
                fi
                ;;
        esac
    fi
done

if [[ -z "$MISSING_APPS" ]]; then
    log_success "All profile apps appear installed"
else
    log_warning "Missing apps detected"
    if [[ -n "$MISSING_CASKS" ]]; then
        echo ""
        echo "Missing casks:"
        echo -e "$MISSING_CASKS" | sed '/^$/d' | sed 's/^/  - /'
    fi
    if [[ -n "$MISSING_BREWS" ]]; then
        echo ""
        echo "Missing brews:"
        echo -e "$MISSING_BREWS" | sed '/^$/d' | sed 's/^/  - /'
    fi
    if [[ -n "$MISSING_MISE" ]]; then
        echo ""
        echo "Missing mise tools:"
        echo -e "$MISSING_MISE" | sed '/^$/d' | sed 's/^/  - /'
    fi
    if [[ -n "$MISSING_STOW" ]]; then
        echo ""
        echo "Missing stow packages (not linked or not detected):"
        echo -e "$MISSING_STOW" | sed '/^$/d' | sed 's/^/  - /'
    fi
fi

echo ""
echo "Dependency checks:"
DEPENDENCY_WARN=false
for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        dep=$(get_app_prop "$app_key" "depends_on")
        if [[ -n "$dep" ]]; then
            if ! app_in_profile "$dep"; then
                log_warning "$app_key depends_on $dep (not in selected profiles)"
                DEPENDENCY_WARN=true
            fi
        fi
    fi
done
if [[ "$DEPENDENCY_WARN" == false ]]; then
    log_success "No missing profile dependencies"
fi

echo ""
echo "Doctor completed."
exit 0
