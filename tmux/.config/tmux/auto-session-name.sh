#!/bin/bash

socket_path="$1"
session_name="$2"

if [[ -z "$socket_path" || -z "$session_name" ]]; then
    exit 0
fi

tmux_cmd() {
    tmux -S "$socket_path" "$@"
}

# Only rename sessions that tmux created with its default numeric names.
case "$session_name" in
    *[!0-9]*)
        exit 0
        ;;
esac

pane_path=$(tmux_cmd list-panes -t "$session_name" -F '#{pane_current_path}' 2>/dev/null | head -1)
if [[ -z "$pane_path" || ! -d "$pane_path" ]]; then
    exit 0
fi

repo_root=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$repo_root" ]]; then
    base_name=$(basename "$repo_root")
else
    base_name=$(basename "$pane_path")
fi

target_name=$(printf '%s' "$base_name" | tr ' :/' '---')
if [[ -z "$target_name" ]]; then
    exit 0
fi

if [[ "$target_name" == "$session_name" ]]; then
    exit 0
fi

candidate="$target_name"
suffix=2
while tmux_cmd has-session -t "$candidate" 2>/dev/null; do
    candidate="${target_name}-${suffix}"
    suffix=$((suffix + 1))
done

tmux_cmd rename-session -t "$session_name" "$candidate" 2>/dev/null || true
