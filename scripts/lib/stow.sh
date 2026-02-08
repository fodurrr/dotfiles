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
    "scripts"
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

    # Back up .config/* subdirectories that would conflict with stow
    local top_dir
    for top_dir in "$package"/.config/*/; do
        if [[ -d "$top_dir" ]]; then
            local dir_name
            dir_name="${top_dir#$package/.config/}"
            dir_name="${dir_name%/}"
            local target_path="$HOME/.config/$dir_name"

            if [[ -L "$target_path" ]]; then
                # Symlink exists - remove if it points elsewhere
                if ! is_our_symlink "$target_path"; then
                    echo "      Removing old symlink: $target_path"
                    rm "$target_path"
                fi
            elif [[ -d "$target_path" ]]; then
                # Real directory - back it up
                echo "      Backing up: $target_path"
                mv "$target_path" "${target_path}.bak"
            fi
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
