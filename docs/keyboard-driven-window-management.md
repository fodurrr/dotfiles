# Keyboard-Driven Window Management

A guide to navigating your Mac using only the keyboard with Aerospace, tmux, and Neovim.

## Overview

This setup uses three layers of keyboard navigation:

| Layer | Tool | Purpose | Prefix |
|-------|------|---------|--------|
| Desktop | Aerospace | Manage application windows | `Alt` |
| Terminal | tmux | Manage terminal panes | `Ctrl+a` |
| Editor | Neovim | Manage editor splits | `Ctrl` |

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
│  │   │ │nvim │ shell │ │   │               │                   │   │
│  │   │ │Ctrl │       │ │   │               │                   │   │
│  │   │ │hjkl │       │ │   │               │                   │   │
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
| `Alt + v` | Split vertical (new window below) |
| `Alt + b` | Split horizontal (new window right) |
| `Alt + f` | Toggle fullscreen |
| `Alt + /` | Toggle between tile layouts |
| `Alt + ,` | Toggle accordion layout |
| `Alt + Shift + Space` | Toggle floating/tiling |

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

## Neovim (Editor Splits)

### Split Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl + h` | Move to split on left |
| `Ctrl + j` | Move to split below |
| `Ctrl + k` | Move to split above |
| `Ctrl + l` | Move to split on right |

### Creating Splits

| Shortcut | Action |
|----------|--------|
| `ss` | Vertical split |
| `sv` | Horizontal split |

### Tab Navigation

| Shortcut | Action |
|----------|--------|
| `Tab` | Next tab |
| `Shift + Tab` | Previous tab |

## Common Workflows

### Workflow 1: Coding Session

1. `Alt + 1` - Switch to workspace 1
2. Open Ghostty (terminal)
3. `tmux` - Start tmux session
4. `Ctrl+a + v` - Split for editor
5. `nvim .` - Open Neovim in left pane
6. Focus right pane for shell commands

### Workflow 2: Research + Coding

1. `Alt + b` - Split desktop horizontally
2. Open browser on right side
3. Keep Ghostty on left
4. `Alt + h/l` - Switch between browser and terminal

### Workflow 3: 3-Column Layout

1. Open first app (full screen)
2. `Alt + b` - Split, open second app
3. `Alt + b` - Split again, open third app
4. Result: 3 equal columns

### Workflow 4: 1 + 4 Grid

1. Open Ghostty (takes full screen)
2. `Alt + b` - Split horizontal
3. Open app 2 (now 50/50)
4. `Alt + l` - Focus right
5. `Alt + v` - Split vertical, open app 3
6. Focus each right pane, `Alt + v` twice more
7. Result: Ghostty on left, 4 apps in grid on right

## Quick Reference Card

```
┌────────────────────────────────────────────────────────────┐
│                   QUICK REFERENCE                          │
├────────────────────────────────────────────────────────────┤
│  AEROSPACE (Desktop)          │  TMUX (Terminal)          │
│  Alt + hjkl    Navigate       │  Ctrl+a hjkl  Navigate    │
│  Alt + Shift   Move window    │  Ctrl+a v/s   Split       │
│  Alt + 1-5     Workspace      │  Ctrl+a d     Detach      │
│  Alt + v/b     Split V/H      │  Ctrl+a x     Close pane  │
│  Alt + f       Fullscreen     │  Ctrl+a r     Reload      │
├────────────────────────────────────────────────────────────┤
│  NEOVIM (Editor)              │  GENERAL                  │
│  Ctrl + hjkl   Navigate       │  Esc          Normal mode │
│  ss / sv       Split V/H      │  :w           Save        │
│  Tab           Next tab       │  :q           Quit        │
└────────────────────────────────────────────────────────────┘
```

## Tips

1. **Muscle memory**: All navigation uses `hjkl` (vim keys) - learn once, use everywhere
2. **Consistent prefixes**: Desktop=Alt, Terminal=Ctrl+a, Editor=Ctrl
3. **Start with Aerospace**: Master desktop navigation first, then add tmux
4. **Use workspaces**: Keep different projects on different workspaces
5. **tmux sessions**: Name your sessions (`tmux new -s project`) for easy switching
