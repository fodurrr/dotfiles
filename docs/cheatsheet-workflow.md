# Cheatsheet Workflow

This document describes the current cheatsheet flow only.

## Current State

What works:
- Floating WezTerm window for the cheatsheet
- Correct cheatsheet selection (`hacker` when AeroSpace is configured, otherwise `developer`)
- Fast self-focus from inside the cheatsheet window
- Scrollable rendering via `less -R`
- Reliable quit with `q`
- Triggered from both Aerospace and SketchyBar

Current limitation:
- Window positioning is whatever WezTerm and Aerospace currently produce; there is no custom centering logic anymore

## Flow

When you trigger the cheatsheet:

```text
1. Aerospace keybinding or SketchyBar click runs `launch-cheatsheet.sh`
2. `launch-cheatsheet.sh`:
   - decides `hacker` vs `developer`
   - starts a new WezTerm window with the cheatsheet command
3. Aerospace `on-window-detected` matches `wezterm-gui` and makes the window floating
4. `render-cheatsheet.sh` runs inside that WezTerm window:
   - finds its own parent `wezterm-gui` PID
   - polls briefly until Aerospace can resolve the window ID
   - focuses that window
   - selects the correct cheatsheet markdown file
   - renders it through `less -R`
5. Press `q` to quit; the window closes when `less` exits
```

## Files

| File | Purpose |
|------|---------|
| `cheatsheet/.config/cheatsheet/launch-cheatsheet.sh` | Launch the WezTerm cheatsheet window and choose mode |
| `cheatsheet/.config/cheatsheet/render-cheatsheet.sh` | Focus the window, choose the cheatsheet file, and render it |
| `cheatsheet/.config/cheatsheet/keybinds-hacker.md` | Hacker cheatsheet content |
| `cheatsheet/.config/cheatsheet/keybinds-developer.md` | Developer cheatsheet content |
| `aerospace/.config/aerospace/aerospace.toml` | Keyboard shortcut and auto-float rule |
| `sketchybar/.config/sketchybar/items/help.sh` | SketchyBar help icon click handler |

## Design Notes

- `wezterm start` is used so the cheatsheet window is identified as `wezterm-gui`, which the Aerospace float rule can match cleanly.
- Mode selection happens in `launch-cheatsheet.sh`, not inside the renderer.
- Window focus happens in `render-cheatsheet.sh`, inside the new WezTerm process.
- The renderer uses `less -R` because the cheatsheet does not fit on one screen and needs scrolling.

## Removed From This Flow

These are not part of the current cheatsheet workflow anymore:
- AppleScript-based centering
- External before/after window ID diffing
- Old `show-cheatsheet.sh` / `display-cheatsheet.sh` naming
- `pgrep AeroSpace`-based cheatsheet selection
