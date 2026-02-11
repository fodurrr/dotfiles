#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
CONFIG_ROOT="$HOME/.config"

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

if [[ ! -d "$CONFIG_ROOT" ]]; then
    echo "No ~/.config directory found; nothing to verify."
    exit 0
fi

echo "Checking for ~/.config directory symlinks pointing into the dotfiles repo..."

found=0

for entry in "$CONFIG_ROOT"/*; do
    [[ -e "$entry" || -L "$entry" ]] || continue
    [[ -L "$entry" ]] || continue
    [[ -d "$entry" ]] || continue

    resolved_target="$(resolve_symlink_target "$entry" 2>/dev/null || true)"
    [[ -n "$resolved_target" ]] || continue

    if [[ "$resolved_target" == "$DOTFILES_DIR"* ]]; then
        found=$((found + 1))
        echo "  - $entry -> $resolved_target"
    fi
done

if [[ "$found" -eq 0 ]]; then
    echo "OK: no repo-pointing directory symlinks found under ~/.config."
    exit 0
fi

echo ""
echo "Found $found repo-pointing ~/.config directory symlink(s)."
echo "These can allow runtime app state to pollute the repo."
echo "Re-run install for your profile to migrate safely:"
echo "  ./install.sh --profile=<profile>"
echo "Then run this check again."
exit 1
