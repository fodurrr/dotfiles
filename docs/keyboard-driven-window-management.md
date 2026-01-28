# Keyboard-Driven Window Management

A guide to navigating your Mac using only the keyboard with Aerospace, tmux, and Helix.

## Overview

This setup uses three layers of keyboard navigation:

| Layer | Tool | Purpose | Prefix |
|-------|------|---------|--------|
| Desktop | Aerospace | Manage application windows | `Alt` |
| Terminal | tmux | Manage terminal panes | `Ctrl+a` |
| Editor | Helix | Manage editor splits | `Space` |

## The Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Desktop (Aerospace)                         │
│                         Navigate: Alt + hjkl                        │
│  ┌─────────────────────────┬───────────────────────────────────┐   │
│  │                         │  Browser      │  Slack            │   │
│  │   Ghostty               ├───────────────┼───────────────────┤   │
│  │   ┌─────────────────┐   │  Zed          │  Obsidian         │   │
│  │   │ tmux            │   │               │                   │   │
│  │   │ Ctrl+a + hjkl   │   │               │                   │   │
│  │   │ ┌─────┬───────┐ │   │               │                   │   │
│  │   │ │helix│ shell │ │   │               │                   │   │
│  │   │ │Space│       │ │   │               │                   │   │
│  │   │ │w/b  │       │ │   │               │                   │   │
│  │   │ └─────┴───────┘ │   │               │                   │   │
│  │   └─────────────────┘   │               │                   │   │
│  └─────────────────────────┴───────────────┴───────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Aerospace (Desktop Windows)

### Navigation

| Shortcut | Action |
|----------|--------|
| `Alt + h` | Focus window to the left |
| `Alt + j` | Focus window below |
| `Alt + k` | Focus window above |
| `Alt + l` | Focus window to the right |

### Moving Windows

| Shortcut | Action |
|----------|--------|
| `Alt + Shift + h` | Move window left |
| `Alt + Shift + j` | Move window down |
| `Alt + Shift + k` | Move window up |
| `Alt + Shift + l` | Move window right |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Alt + 1-5` | Switch to workspace 1-5 |
| `Alt + Shift + 1-5` | Move window to workspace 1-5 |

### Layouts

| Shortcut | Action |
|----------|--------|
| `Alt + /` | Toggle layout direction (horizontal ↔ vertical) |
| `Alt + ,` | Toggle accordion layout |
| `Alt + f` | Toggle fullscreen |
| `Alt + Shift + Space` | Toggle floating/tiling |

> **Note:** Aerospace automatically tiles new windows. Use `Alt + /` to change the split direction of the focused container.

### Resizing

| Shortcut | Action |
|----------|--------|
| `Alt + -` | Shrink window |
| `Alt + =` | Grow window |

## tmux (Terminal Panes)

All tmux commands start with the prefix `Ctrl+a`.

### Pane Management

| Shortcut | Action |
|----------|--------|
| `Ctrl+a + v` | Split vertical (new pane right) |
| `Ctrl+a + s` | Split horizontal (new pane below) |
| `Ctrl+a + x` | Close current pane |

### Pane Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+a + h` | Move to pane on left |
| `Ctrl+a + j` | Move to pane below |
| `Ctrl+a + k` | Move to pane above |
| `Ctrl+a + l` | Move to pane on right |

### Pane Resizing

| Shortcut | Action |
|----------|--------|
| `Ctrl+a + H` | Resize pane left |
| `Ctrl+a + J` | Resize pane down |
| `Ctrl+a + K` | Resize pane up |
| `Ctrl+a + L` | Resize pane right |

### Session Management

| Shortcut | Action |
|----------|--------|
| `Ctrl+a + d` | Detach from session |
| `Ctrl+a + r` | Reload config |

### Commands

| Command | Action |
|---------|--------|
| `tmux` | Start new session |
| `tmux ls` | List sessions |
| `tmux a` | Attach to last session |
| `tmux a -t <name>` | Attach to named session |

## Helix (Editor)

Helix uses a selection-first editing model. Press `Space` to open the command palette.

### Navigation

| Shortcut | Action |
|----------|--------|
| `h/j/k/l` | Move cursor left/down/up/right |
| `w/b` | Select next/previous word |
| `gg/ge` | Go to top/bottom of file |
| `Ctrl+d/u` | Page down/up |

### Selection & Editing

| Shortcut | Action |
|----------|--------|
| `x` | Select line (repeat to extend) |
| `v` | Extend selection |
| `d/c/y` | Delete/Change/Yank selection |
| `Space` | Open picker/command palette |

### Buffer Navigation

| Shortcut | Action |
|----------|--------|
| `Shift + h` | Previous buffer |
| `Shift + l` | Next buffer |
| `Shift + q` | Close buffer |

## Common Workflows

### Workflow 1: Coding Session

1. `Alt + 1` - Switch to workspace 1
2. Open Ghostty (terminal)
3. `tmux` - Start tmux session
4. `Ctrl+a + v` - Split for editor
5. `hx .` - Open Helix in left pane
6. Focus right pane for shell commands

### Workflow 2: Research + Coding

1. Open Ghostty (takes full screen)
2. Open browser → automatically tiles side-by-side
3. `Alt + h/l` - Switch between browser and terminal
4. `Alt + /` - Toggle layout direction if needed

### Workflow 3: 3-Column Layout

1. Open first app (full screen)
2. Open second app → auto-tiles 50/50
3. Open third app → auto-tiles into 3 columns
4. Use `Alt + /` to toggle layout direction as needed

### Workflow 4: 1 + 4 Grid

1. Open Ghostty (takes full screen)
2. Open app 2 → now 50/50
3. `Alt + l` - Focus right side
4. Open apps 3, 4, 5 → they tile into the right section
5. Use `Alt + /` on right section to arrange vertically
6. Result: Ghostty on left, 4 apps in grid on right

## Quick Reference Card

```
┌────────────────────────────────────────────────────────────┐
│                   QUICK REFERENCE                          │
├────────────────────────────────────────────────────────────┤
│  AEROSPACE (Desktop)          │  TMUX (Terminal)          │
│  Alt + hjkl    Navigate       │  Ctrl+a hjkl  Navigate    │
│  Alt + Shift   Move window    │  Ctrl+a v/s   Split       │
│  Alt + 1-5     Workspace      │  Ctrl+a d     Detach      │
│  Alt + /       Toggle layout  │  Ctrl+a x     Close pane  │
│  Alt + f       Fullscreen     │  Ctrl+a r     Reload      │
├────────────────────────────────────────────────────────────┤
│  HELIX (Editor)               │  GENERAL                  │
│  hjkl          Navigate       │  Esc          Normal mode │
│  Space         Command menu   │  :w           Save        │
│  Shift + h/l   Prev/Next buf  │  :q           Quit        │
└────────────────────────────────────────────────────────────┘
```

## Tips

1. **Muscle memory**: All navigation uses `hjkl` (vim keys) - learn once, use everywhere
2. **Consistent prefixes**: Desktop=Alt, Terminal=Ctrl+a, Editor=Space
3. **Start with Aerospace**: Master desktop navigation first, then add tmux
4. **Use workspaces**: Keep different projects on different workspaces
5. **tmux sessions**: Name your sessions (`tmux new -s project`) for easy switching
