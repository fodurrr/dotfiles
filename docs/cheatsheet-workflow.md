# Cheatsheet Floating Window — Workflow Guide

## Status: ~95% Working

**What works:**
- Floating window (not tiled, doesn't rearrange other windows)
- Correct width (109 cols fits the table perfectly)
- Correct cheatsheet content (hacker vs developer profile detection)
- Horizontal centering
- Press `q` to quit
- Works from both `alt+?` (Aerospace) and SketchyBar icon click

**Known issue:**
- Vertical centering may not work reliably — window tends to stick to the top below SketchyBar

---

## Flow: What Happens When You Press `alt+?`

```
┌──────────────────────────────────────────────────────────┐
│ 1. Aerospace: exec-and-forget show-cheatsheet.sh         │
│    └── Runs the launcher script in a detached process    │
│                                                          │
│ 2. show-cheatsheet.sh:                                   │
│    a. Snapshots existing wezterm-gui window IDs          │
│    b. Launches WezTerm with initial_cols=109, rows=50    │
│    c. Polls for new wezterm-gui window ID (before/after) │
│    d. aerospace focus --window-id <new_id>               │
│    e. AppleScript: centers window on active monitor      │
│                                                          │
│ 3. Aerospace on-window-detected rule:                    │
│    └── Matches app-name "wezterm-gui" → layout floating  │
│    (fires automatically when the new window appears)     │
│                                                          │
│ 4. display-cheatsheet.sh (inside the WezTerm window):    │
│    a. Sets window title to "Cheatsheet"                  │
│    b. Detects profile (pgrep AeroSpace → hacker/dev)     │
│    c. Renders cheatsheet with ANSI colors via sed        │
│    d. Displays in less -R (scrollable, q to quit)        │
│                                                          │
│ 5. User presses q → less exits → window closes           │
└──────────────────────────────────────────────────────────┘
```

## Key Files

| File | Purpose |
|------|---------|
| `cheatsheet/.config/cheatsheet/show-cheatsheet.sh` | Launcher: window detection, focus, centering |
| `cheatsheet/.config/cheatsheet/display-cheatsheet.sh` | Content: profile detection, render, less viewer |
| `cheatsheet/.config/cheatsheet/keybinds-hacker.md` | Hacker profile cheatsheet (Aerospace, Yazi, Tmux) |
| `cheatsheet/.config/cheatsheet/keybinds-developer.md` | Developer profile cheatsheet (simpler) |
| `aerospace/.config/aerospace/aerospace.toml` | `alt+?` binding + auto-float rule for wezterm-gui |
| `sketchybar/.config/sketchybar/items/help.sh` | SketchyBar book icon → click triggers launcher |

## Key Design Decisions

1. **`wezterm start` vs `open -a WezTerm`**: We use `wezterm start` which registers as `wezterm-gui` (not `WezTerm`). This lets us auto-float only cheatsheet windows without affecting the main terminal.

2. **Auto-float via `on-window-detected` rule**: Aerospace floats the window at creation time, before tiling. This preserves WezTerm's `initial_cols/rows` sizing.

3. **Window ID detection (before/after diff)**: The launcher snapshots wezterm-gui window IDs before and after launch to find the new window's ID, then uses `aerospace focus --window-id` to bring it to front.

4. **AppleScript for centering**: Aerospace has no native floating window positioning. AppleScript can reposition (but not resize) floating windows. We detect which screen the window is on and calculate centered coordinates.

5. **PATH in scripts**: Aerospace `exec-and-forget` runs with minimal PATH. Scripts explicitly include `/opt/homebrew/bin`, `/usr/bin`, `/bin` to ensure `pgrep`, `aerospace`, `wezterm`, `sed`, `less` are all found.

## Vertical Centering Issue

The AppleScript centering calculates correct coordinates but the position change doesn't always take effect. Aerospace may be intercepting the position change for floating windows in some cases. The horizontal centering works, but vertical position tends to remain at `y=55` (right below SketchyBar).

Potential fixes to investigate:
- Longer delay before AppleScript runs
- Running AppleScript from inside the window instead of the launcher
- Using `wezterm start --position active:X,Y` (didn't stick in testing)
