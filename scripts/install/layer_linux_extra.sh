#!/bin/bash
# =============================================================================
# Linux Extra Layer: desktop apps, vendor packages and fonts
# =============================================================================
# Handles Linux-only app types that the package, stow, mise and curl layers
# do not cover (Debian/Ubuntu only):
#
#   type = "apt-repo"  vendor apt source plus packages
#       apt_key_url          signing key URL
#       apt_keyring          key file name under /usr/share/keyrings
#       apt_key_dearmor      true = convert an armored key to binary
#       apt_key_fingerprint  optional full fingerprint the key must match
#       apt_source           sources line; {keyring} {arch} {codename} {distro}
#       apt_list             optional list file name (default: app key)
#       linux_apt            packages, space separated
#
#   type = "deb"       vendor .deb file (the package may register its own repo)
#       deb_url              direct URL; {arch} is replaced
#     or
#       github_repo          owner/repo
#       deb_asset_regex      release asset name regex; {arch} is replaced
#       github_tag_regex     optional tag filter (default: newest stable release)
#
#   type = "script"    vendor install script, run as the user
#       install_url, install_args, bin
#
#   type = "snap"      snap_name, snap_classic
#   type = "gsettings" gsettings_schema, gsettings_key, gsettings_value
#
#   type = "font"      nerd_font = release asset name from ryanoasis/nerd-fonts
# =============================================================================

LINUX_EXTRA_APT_UPDATED=false

linux_extra_sudo() {
    if [[ "$EUID" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

linux_extra_apt() {
    linux_extra_sudo env DEBIAN_FRONTEND=noninteractive apt-get -y -qq "$@"
}

linux_extra_expand() {
    local text="$1"
    local arch codename distro
    arch=$(dpkg --print-architecture 2>/dev/null)
    # shellcheck disable=SC1091
    codename=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
    # shellcheck disable=SC1091
    distro=$(. /etc/os-release && echo "${ID:-}")
    text="${text//\{arch\}/$arch}"
    text="${text//\{codename\}/$codename}"
    text="${text//\{distro\}/$distro}"
    echo "$text"
}

linux_extra_require_apt() {
    if [[ "$(pm_get_manager)" != "apt" ]]; then
        log_info "Skipping $1 (type $2 supports apt-based distributions only)"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# apt-repo
# -----------------------------------------------------------------------------
install_linux_apt_repo_app() {
    local app_key="$1"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    local key_url keyring dearmor fingerprint source_line list_name packages
    key_url=$(get_app_prop "$app_key" "apt_key_url")
    keyring=$(get_app_prop "$app_key" "apt_keyring")
    dearmor=$(get_app_prop "$app_key" "apt_key_dearmor")
    fingerprint=$(get_app_prop "$app_key" "apt_key_fingerprint")
    source_line=$(get_app_prop "$app_key" "apt_source")
    list_name=$(get_app_prop "$app_key" "apt_list")
    packages=$(get_app_prop "$app_key" "linux_apt")
    [[ -z "$list_name" ]] && list_name="$app_key"
    key_url=$(linux_extra_expand "$key_url")

    if [[ -z "$key_url" || -z "$keyring" || -z "$source_line" || -z "$packages" ]]; then
        log_error "apt-repo app '$app_key' needs apt_key_url, apt_keyring, apt_source and linux_apt"
        return 1
    fi

    local keyring_path="/usr/share/keyrings/$keyring"
    local list_path="/etc/apt/sources.list.d/${list_name}.list"

    local missing=false package
    for package in $packages; do
        dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed" || missing=true
    done

    if [[ ! -s "$keyring_path" ]]; then
        local tmp_key
        tmp_key=$(mktemp) || return 1
        if ! curl -fsSL "$key_url" -o "$tmp_key"; then
            rm -f "$tmp_key"
            log_error "Failed to download signing key for $display_name"
            return 1
        fi
        if [[ -n "$fingerprint" ]]; then
            local actual
            actual=$(gpg --show-keys --with-colons "$tmp_key" 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')
            if [[ "$actual" != "$fingerprint" ]]; then
                rm -f "$tmp_key"
                log_error "Signing key for $display_name has fingerprint '${actual:-none}', expected $fingerprint"
                return 1
            fi
        fi
        if [[ "$dearmor" == "true" ]]; then
            if ! gpg --dearmor < "$tmp_key" > "${tmp_key}.gpg" 2>/dev/null; then
                rm -f "$tmp_key" "${tmp_key}.gpg"
                log_error "Failed to convert signing key for $display_name"
                return 1
            fi
            mv "${tmp_key}.gpg" "$tmp_key"
        fi
        linux_extra_sudo install -m 644 "$tmp_key" "$keyring_path"
        rm -f "$tmp_key"
    fi

    local wanted
    wanted=$(linux_extra_expand "${source_line//\{keyring\}/$keyring_path}")
    if [[ "$(cat "$list_path" 2>/dev/null)" != "$wanted" ]]; then
        echo "$wanted" | linux_extra_sudo tee "$list_path" >/dev/null
        LINUX_EXTRA_APT_UPDATED=false
    fi

    if [[ "$LINUX_EXTRA_APT_UPDATED" != true ]]; then
        linux_extra_apt update || true
        LINUX_EXTRA_APT_UPDATED=true
    fi

    log_success "Ensuring $display_name is installed and up-to-date..."
    # shellcheck disable=SC2086
    if ! linux_extra_apt install $packages; then
        log_error "Failed to install $display_name ($packages)"
        return 1
    fi

    if [[ "$missing" == true ]]; then
        add_to_summary INSTALLED "$display_name" "$app_key"
    else
        add_to_summary SKIPPED "$display_name" "$app_key"
    fi
}

# -----------------------------------------------------------------------------
# deb
# -----------------------------------------------------------------------------
linux_extra_github_deb_url() {
    local repo="$1" asset_regex="$2" tag_regex="$3"
    local releases
    releases=$(curl -fsSL "https://api.github.com/repos/${repo}/releases?per_page=40" 2>/dev/null) || return 1

    if [[ -n "$tag_regex" ]]; then
        echo "$releases" | jq -r --arg tag "$tag_regex" --arg asset "$asset_regex" \
            '[.[] | select(.tag_name | test($tag))][0].assets[]? | select(.name | test($asset)) | .browser_download_url' | head -1
    else
        echo "$releases" | jq -r --arg asset "$asset_regex" \
            '[.[] | select(.prerelease == false and .draft == false)][0].assets[]? | select(.name | test($asset)) | .browser_download_url' | head -1
    fi
}

install_linux_deb_app() {
    local app_key="$1"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    local url repo asset_regex tag_regex
    url=$(get_app_prop "$app_key" "deb_url")
    repo=$(get_app_prop "$app_key" "github_repo")
    asset_regex=$(get_app_prop "$app_key" "deb_asset_regex")
    tag_regex=$(get_app_prop "$app_key" "github_tag_regex")

    if [[ -n "$url" ]]; then
        url=$(linux_extra_expand "$url")
    elif [[ -n "$repo" && -n "$asset_regex" ]]; then
        url=$(linux_extra_github_deb_url "$repo" "$(linux_extra_expand "$asset_regex")" "$tag_regex")
    fi
    if [[ -z "$url" || "$url" == "null" ]]; then
        log_error "Could not resolve a .deb download for $display_name"
        return 1
    fi

    local tmp_dir deb
    tmp_dir=$(mktemp -d) || return 1
    chmod 755 "$tmp_dir"
    deb="$tmp_dir/package.deb"
    if ! curl -fsSL "$url" -o "$deb"; then
        rm -rf "$tmp_dir"
        log_error "Failed to download $url"
        return 1
    fi

    local package new_version current_version
    package=$(dpkg-deb -f "$deb" Package 2>/dev/null)
    new_version=$(dpkg-deb -f "$deb" Version 2>/dev/null)
    if [[ -z "$package" ]]; then
        rm -rf "$tmp_dir"
        log_error "Downloaded file for $display_name is not a Debian package"
        return 1
    fi
    current_version=$(dpkg-query -W -f='${Version}' "$package" 2>/dev/null || true)

    if [[ -n "$current_version" && "$current_version" == "$new_version" ]]; then
        rm -rf "$tmp_dir"
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    log_success "Installing $display_name ($package $new_version)..."
    if ! linux_extra_apt install "$deb"; then
        rm -rf "$tmp_dir"
        log_error "Failed to install $display_name"
        return 1
    fi
    rm -rf "$tmp_dir"
    LINUX_EXTRA_APT_UPDATED=false
    add_to_summary INSTALLED "$display_name" "$app_key"
}

# -----------------------------------------------------------------------------
# script
# -----------------------------------------------------------------------------
install_linux_script_app() {
    local app_key="$1"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    local url args bin
    url=$(get_app_prop "$app_key" "install_url")
    args=$(get_app_prop "$app_key" "install_args")
    bin=$(get_app_prop "$app_key" "bin")

    if [[ -z "$url" || -z "$bin" ]]; then
        log_error "script app '$app_key' needs install_url and bin"
        return 1
    fi
    if command -v "$bin" >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/$bin" ]]; then
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    local tmp_script
    tmp_script=$(mktemp) || return 1
    if ! curl -fsSL "$url" -o "$tmp_script"; then
        rm -f "$tmp_script"
        log_error "Failed to download installer for $display_name"
        return 1
    fi

    log_success "Installing $display_name..."
    # shellcheck disable=SC2086
    if ! bash "$tmp_script" $args < /dev/null; then
        rm -f "$tmp_script"
        log_error "Installer for $display_name failed"
        return 1
    fi
    rm -f "$tmp_script"

    if ! command -v "$bin" >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/$bin" ]]; then
        log_error "$display_name installer finished but '$bin' was not found"
        return 1
    fi
    add_to_summary INSTALLED "$display_name" "$app_key"
}

# -----------------------------------------------------------------------------
# snap
# -----------------------------------------------------------------------------
install_linux_snap_app() {
    local app_key="$1"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    if ! command -v snap >/dev/null 2>&1; then
        log_info "Skipping $display_name (snap is not available)"
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    local snap_name classic
    snap_name=$(get_app_prop "$app_key" "snap_name")
    classic=$(get_app_prop "$app_key" "snap_classic")
    [[ -z "$snap_name" ]] && snap_name="$app_key"

    if snap list "$snap_name" >/dev/null 2>&1; then
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    log_success "Installing $display_name (snap $snap_name)..."
    local snap_args=("$snap_name")
    [[ "$classic" == "true" ]] && snap_args+=("--classic")
    if ! linux_extra_sudo snap install "${snap_args[@]}" >/dev/null 2>&1; then
        log_error "Failed to install snap $snap_name"
        return 1
    fi
    add_to_summary INSTALLED "$display_name" "$app_key"
}

# -----------------------------------------------------------------------------
# gsettings (GNOME desktop preferences)
# -----------------------------------------------------------------------------
install_linux_gsettings_app() {
    local app_key="$1"
    local display_name
    display_name=$(get_app_display_name "$app_key")

    local schema key value
    schema=$(get_app_prop "$app_key" "gsettings_schema")
    key=$(get_app_prop "$app_key" "gsettings_key")
    value=$(get_app_prop "$app_key" "gsettings_value")
    if [[ -z "$schema" || -z "$key" || -z "$value" ]]; then
        log_error "$display_name needs gsettings_schema, gsettings_key and gsettings_value"
        return 1
    fi

    # Not a GNOME desktop, or the schema is absent: nothing to set.
    if ! command -v gsettings >/dev/null 2>&1 || ! gsettings list-keys "$schema" 2>/dev/null | grep -qx "$key"; then
        log_info "Skipping $display_name (gsettings key $schema $key is not available)"
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    if [[ "$(gsettings get "$schema" "$key" 2>/dev/null)" == "$value" ]]; then
        add_to_summary SKIPPED "$display_name" "$app_key"
        return 0
    fi

    log_success "Setting $display_name..."
    if ! gsettings set "$schema" "$key" "$value"; then
        log_error "Failed to set $schema $key"
        return 1
    fi
    add_to_summary INSTALLED "$display_name" "$app_key"
}

# -----------------------------------------------------------------------------
# font
# -----------------------------------------------------------------------------
install_linux_nerd_font() {
    local app_key="$1"
    local font_name
    font_name=$(get_app_prop "$app_key" "nerd_font")
    if [[ -z "$font_name" ]]; then
        log_error "Font app '$app_key' has no nerd_font property"
        return 1
    fi

    local font_dir="$HOME/.local/share/fonts/${font_name}NerdFont"
    if [[ -d "$font_dir" ]] && compgen -G "$font_dir/*.ttf" >/dev/null; then
        add_to_summary SKIPPED "$font_name Nerd Font" "$app_key"
        return 0
    fi

    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"
    local tmp_dir
    tmp_dir=$(mktemp -d) || return 1

    log_success "Installing $font_name Nerd Font..."
    if ! curl -fsSL "$url" -o "$tmp_dir/font.tar.xz"; then
        rm -rf "$tmp_dir"
        log_error "Failed to download $url"
        return 1
    fi

    mkdir -p "$font_dir"
    if ! tar -xJf "$tmp_dir/font.tar.xz" -C "$font_dir"; then
        rm -rf "$tmp_dir"
        log_error "Failed to extract $font_name Nerd Font"
        return 1
    fi
    rm -rf "$tmp_dir"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
    fi
    add_to_summary INSTALLED "$font_name Nerd Font" "$app_key"
}

# -----------------------------------------------------------------------------
# Layer entry point
# -----------------------------------------------------------------------------
run_layer_linux_extra() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Layer 6: Linux Desktop Apps and Fonts"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local failed="" app_key type
    for app_key in $(get_all_apps); do
        app_selected_for_install "$app_key" || continue
        type=$(get_app_prop "$app_key" "type")
        case "$type" in
            apt-repo)
                linux_extra_require_apt "$app_key" "$type" || continue
                install_linux_apt_repo_app "$app_key" || failed="$failed $app_key"
                ;;
            deb)
                linux_extra_require_apt "$app_key" "$type" || continue
                install_linux_deb_app "$app_key" || failed="$failed $app_key"
                ;;
            script) install_linux_script_app "$app_key" || failed="$failed $app_key" ;;
            snap)   install_linux_snap_app "$app_key" || failed="$failed $app_key" ;;
            gsettings) install_linux_gsettings_app "$app_key" || failed="$failed $app_key" ;;
            font)   install_linux_nerd_font "$app_key" || failed="$failed $app_key" ;;
        esac
    done

    if [[ -n "$failed" ]]; then
        log_error "Linux extra layer failed for:$failed"
        return 1
    fi
    log_success "Linux extra layer complete"
}

export -f run_layer_linux_extra
