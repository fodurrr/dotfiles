# =============================================================================
# The Enforcer: Link with Backup Logic
# =============================================================================

# Global Configuration
IGNORE_LIST=(
    ".git"
    ".DS_Store"
    ".gitkeep"
    "install.sh"
    "Brewfile.bootstrap"
    "apps.toml"
    "README.md"
    "CLAUDE.md"
    "LICENSE"
    ".gitignore"
    "docs"
)

stow_enforce() {
    local package="$1"

    # Build Ignore Flags for Stow
    local stow_opts=()
    local ignore_item
    for ignore_item in "${IGNORE_LIST[@]}"; do
        stow_opts+=("--ignore=$ignore_item")
    done
    stow_opts+=("--ignore=\.bak$")
    if stow --help 2>&1 | grep -q -- "--no-folding"; then
        # Prevent directory folding so runtime data does not end up in the repo.
        stow_opts+=("--no-folding")
    fi

    # Helper: Check if symlink points to this dotfiles repo
    resolve_path() {
        local path="$1"
        local dir base abs_dir
        dir="$(dirname "$path")"
        base="$(basename "$path")"
        abs_dir="$(cd "$dir" 2>/dev/null && pwd -P)" || return 1
        echo "$abs_dir/$base"
    }

    resolve_symlink_target() {
        local link="$1"
        local target link_dir
        target="$(readlink "$link" 2>/dev/null)" || return 1
        if [[ "$target" == /* ]]; then
            resolve_path "$target"
        else
            link_dir="$(cd "$(dirname "$link")" 2>/dev/null && pwd -P)" || return 1
            resolve_path "$link_dir/$target"
        fi
    }

    is_our_symlink() {
        local resolved_target
        resolved_target="$(resolve_symlink_target "$1")" || return 1
        [[ "$resolved_target" == "$DOTFILES_DIR_REAL"* ]]
    }

    # Convert repo-pointing ~/.config/<app> symlinks into real directories.
    # This preserves existing data while allowing per-file symlinks only.
    unfold_config_symlink() {
        local target_path="$1"
        local tmp_dir

        if [[ ! -L "$target_path" ]] || ! is_our_symlink "$target_path"; then
            return 0
        fi

        tmp_dir="${target_path}.unfold.$$"
        mkdir -p "$tmp_dir"
        cp -R "$target_path"/. "$tmp_dir"/ 2>/dev/null || true
        rm "$target_path"
        mkdir -p "$target_path"
        cp -R "$tmp_dir"/. "$target_path"/ 2>/dev/null || true
        rm -rf "$tmp_dir"
        log_info "Unfolded symlink at $target_path to keep runtime data out of repo"
    }

    # Prepare .config/* targets and back up only conflicting managed files.
    local top_dir
    for top_dir in "$package"/.config/*/; do
        if [[ -d "$top_dir" ]]; then
            local dir_name
            dir_name="${top_dir#$package/.config/}"
            dir_name="${dir_name%/}"
            local target_path="$HOME/.config/$dir_name"

            if [[ -L "$target_path" ]]; then
                # Unfold our own symlink, or remove foreign symlink.
                if is_our_symlink "$target_path"; then
                    unfold_config_symlink "$target_path"
                else
                    echo "      Removing old symlink: $target_path"
                    rm "$target_path"
                fi
            fi

            [[ -d "$target_path" ]] || mkdir -p "$target_path"

            # Only back up files that Stow will manage for this package.
            local managed_file
            while IFS= read -r managed_file; do
                local rel_path target_file
                rel_path="${managed_file#$package/}"
                target_file="$HOME/$rel_path"

                if [[ -L "$target_file" ]]; then
                    if ! is_our_symlink "$target_file"; then
                        echo "      Removing old symlink: $target_file"
                        rm "$target_file"
                    fi
                elif [[ -e "$target_file" ]]; then
                    echo "      Backing up: $target_file"
                    mv "$target_file" "${target_file}.bak"
                fi
            done < <(find "$top_dir" \( -type f -o -type l \))

            # Also handle managed directories that are currently symlinked elsewhere.
            local managed_dir
            while IFS= read -r managed_dir; do
                local rel_dir target_dir
                rel_dir="${managed_dir#$package/}"
                target_dir="$HOME/$rel_dir"

                if [[ -L "$target_dir" ]] && ! is_our_symlink "$target_dir"; then
                    echo "      Removing old symlink: $target_dir"
                    rm "$target_dir"
                fi
            done < <(find "$top_dir" -type d)

            # Ensure parents exist after any cleanup.
            while IFS= read -r managed_file; do
                local rel_path target_file target_parent
                rel_path="${managed_file#$package/}"
                target_file="$HOME/$rel_path"
                target_parent="$(dirname "$target_file")"
                [[ -d "$target_parent" ]] || mkdir -p "$target_parent"
            done < <(find "$top_dir" \( -type f -o -type l \))
            while IFS= read -r managed_dir; do
                local rel_dir target_dir
                rel_dir="${managed_dir#$package/}"
                target_dir="$HOME/$rel_dir"
                [[ -d "$target_dir" ]] || mkdir -p "$target_dir"
            done < <(find "$top_dir" -type d)
        fi
    done

    # Back up home directory dotfiles (e.g., .gitconfig, .zshrc)
    # Skip .config - it's handled above
    local top_file
    for top_file in "$package"/.[!.]*; do
        if [[ -e "$top_file" ]]; then
            local file_name="${top_file##*/}"
            # Skip .config directory - handled by the loop above
            [[ "$file_name" == ".config" ]] && continue

            local target_path="$HOME/$file_name"

            if [[ -L "$target_path" ]]; then
                # Symlink exists - remove if it points elsewhere
                if ! is_our_symlink "$target_path"; then
                    echo "      Removing old symlink: $target_path"
                    rm "$target_path"
                fi
            elif [[ -e "$target_path" ]]; then
                # Real file - back it up
                echo "      Backing up: $target_path"
                mv "$target_path" "${target_path}.bak"
            fi
        fi
    done

    # Create Links - stow will succeed now that conflicts are handled
    local stow_output
    if ! stow_output=$(stow --restow --target="$HOME" "${stow_opts[@]}" "$package" 2>&1); then
        log_error "Failed to link $package"
        echo "$stow_output" | head -3 | sed 's/^/      /'
        return 1
    fi
}
