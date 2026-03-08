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
│ 1. Aerospace: exec-and-forget launch-cheatsheet.sh       │
│    └── Runs the launcher script in a detached process    │
│                                                          │
│ 2. launch-cheatsheet.sh:                                 │
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
│ 4. render-cheatsheet.sh (inside the WezTerm window):     │
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
| `cheatsheet/.config/cheatsheet/launch-cheatsheet.sh` | Launcher: start the cheatsheet window and choose mode |
| `cheatsheet/.config/cheatsheet/render-cheatsheet.sh` | Content: focus, choose cheatsheet file, render via less |
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

---

## Redesigned Version: Self-Focusing (Simplified)

**Status:** Tested and verified manually. Not yet implemented in config files.

### Key Discovery

The render script running INSIDE the WezTerm window can find its own Aerospace window ID using its parent PID, then focus itself. This eliminates the need for `launch-cheatsheet.sh` entirely.

### How It Works

```bash
# From inside the WezTerm window:
PPID_VAL=$(ps -o ppid= -p $$ | tr -d " ")
WIN_ID=$(aerospace list-windows --monitor all --pid $PPID_VAL | head -1 | awk -F'|' '{gsub(/ /,"",$1); print $1}')
aerospace focus --window-id $WIN_ID
```

- `$$` is the shell PID (bash running the script)
- `ps -o ppid=` gets the parent PID (the `wezterm-gui` process)
- `aerospace list-windows --pid` finds the Aerospace window ID for that process
- `aerospace focus --window-id` brings the window to front

### Simplified Flow

```
┌──────────────────────────────────────────────────────────┐
│ 1. Aerospace binding (alt+?):                            │
│    exec-and-forget wezterm --config 'initial_cols=109'   │
│      --config 'initial_rows=50' start --                 │
│      ~/.config/cheatsheet/render-cheatsheet.sh           │
│                                                          │
│ 2. Aerospace on-window-detected rule:                    │
│    Matches "wezterm-gui" → layout floating               │
│    (window is floating from birth, correct size)         │
│                                                          │
│ 3. render-cheatsheet.sh (inside the window):             │
│    a. sleep 1 (wait for window to be ready)              │
│    b. Find own Aerospace window ID via parent PID        │
│    c. aerospace focus --window-id (bring to front)       │
│    d. Detect profile, render cheatsheet, less -R         │
│                                                          │
│ 4. User presses q → less exits → window closes           │
└──────────────────────────────────────────────────────────┘
```

### What Changes

| Component | Old (Current) | New (Simplified) |
|-----------|--------------|-----------------|
| `launch-cheatsheet.sh` | 70+ lines: window ID detection loop, AppleScript centering | **Not needed** — inline WezTerm launch in Aerospace binding |
| `render-cheatsheet.sh` | Just renders content | Adds 4 lines: find own window ID, focus self |
| Aerospace `alt+?` binding | `exec-and-forget launch-cheatsheet.sh` | `exec-and-forget wezterm ... start -- render-cheatsheet.sh` |
| SketchyBar click | `launch-cheatsheet.sh` | Same inline wezterm command (or tiny wrapper) |
| Aerospace rule | `layout floating` | `layout floating` (unchanged) |
| AppleScript | Used for centering (unreliable) | **Removed entirely** |
| Vertical centering | Broken | Not solved yet, but no longer blocked by AppleScript issues |

### Files Affected

- **Remove:** `cheatsheet/.config/cheatsheet/launch-cheatsheet.sh` (no longer needed)
- **Modify:** `cheatsheet/.config/cheatsheet/render-cheatsheet.sh` (add self-focus)
- **Modify:** `aerospace/.config/aerospace/aerospace.toml` (inline wezterm launch in binding)
- **Modify:** `sketchybar/.config/sketchybar/items/help.sh` (inline wezterm launch in click_script)

### Note on SketchyBar

SketchyBar `click_script` can run the same inline command, or we keep a minimal `launch-cheatsheet.sh` as a one-liner wrapper so both Aerospace and SketchyBar call the same thing. Wrapper approach is cleaner to avoid duplicating the wezterm command.
