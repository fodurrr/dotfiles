#!/bin/bash

# =============================================================================
# Layer 2: Stow (configs from apps.toml)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Layer 2: Stow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$DOTFILES_DIR"

for app_key in $(get_all_apps); do
    if app_in_profile "$app_key"; then
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "stow" ]]; then
            package=$(get_app_prop "$app_key" "package")
            if [[ -d "$package" ]]; then
                log_success "Linking $package config..."
                stow_enforce "$package" || true
            else
                log_warning "Stow package directory not found: $package/"
            fi
        fi
    fi
done

if [[ "$CLEAN_MODE" == true ]]; then
    echo "Removing stow packages not in selected profiles..."

    for app_key in $(get_all_apps); do
        type=$(get_app_prop "$app_key" "type")
        if [[ "$type" == "stow" ]]; then
            if ! app_in_profile "$app_key"; then
                package=$(get_app_prop "$app_key" "package")
                if [[ -d "$DOTFILES_DIR/$package" ]]; then
                    log_warning "Unlinking $package config..."
                    stow -D "$package" 2>/dev/null || true
                fi
            fi
        fi
    done
fi
