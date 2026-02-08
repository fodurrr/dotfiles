# Terminal Workflow Recommendations

This document focuses on terminal-centric workflows and operational patterns.
It does not define profile app membership; profile/app truth lives in `apps.toml`.

## Scope

Use this doc for:
- keyboard-first window and terminal habits
- tmux/Helix workflow examples
- practical CLI replacements for common GUI tasks

Use these for source-of-truth app membership:

```bash
./install.sh --list-profiles
./install.sh --list-installed
```

## Recommended Profile Paths

- `developer` (Recommended): GUI-forward development with terminal tooling.
- `hacker`: terminal-first workflow with tiling/window tooling.
- `server`: headless terminal-only workflow.

## Terminal-First Workflow Stack

- Window manager: AeroSpace (hacker profile)
- Terminal multiplexer: tmux
- Editor: Helix
- Shell utilities: `eza`, `bat`, `fzf`, `ripgrep`, `jq`, `gh`

## Practical Alternatives to GUI Tasks

### Clipboard history and quick reuse

Use tmux buffers and system clipboard integration:

```bash
# tmux copy mode
# Ctrl+a then [
# Select text, yank, then paste via system clipboard
```

### System and process monitoring

```bash
btop
```

### Disk usage analysis

```bash
ncdu ~
```

### File navigation

```bash
yazi
```

### Git workflow

```bash
lazygit
```

## Core Workflow Examples

### Coding session (single machine)

1. Start window manager layout.
2. Open tmux session.
3. Split panes by task (editor, tests, logs, git).
4. Keep one shell for install/reconcile commands.

### Research + implementation

1. Left pane: browser or notes.
2. Right pane: editor + terminal.
3. Bottom pane: tests/lint/install output.

### Multi-project context switching

1. Use one tmux session per project.
2. Keep branch naming consistent (`codex/<topic>`).
3. Use profile-based install to converge toolchain across machines.

## Safe Operations

Before major install changes:

```bash
./install.sh --help
./install.sh --list-profiles
./install.sh --list-installed
```

For strict profile convergence:

```bash
./install.sh --profile=hacker --clean
```

For GUI app ownership reconciliation:

```bash
./install.sh --profile=hacker --reconcile-casks --reconcile-dry-run
```

## Adding or Changing Tools

Use this decision path:

1. Runtime or CLI: prefer `mise`.
2. GUI app: use Homebrew `cask`.
3. Rare vendor-only CLI: `curl` fallback.

Then update `apps.toml` and run:

```bash
./install.sh --profile=hacker
```

## Validation Checklist

- Commands resolve:

```bash
which -a tmux helix yazi lazygit
```

- Shell config is loaded:

```bash
source ~/.zshrc
```

- Mise tool state is healthy:

```bash
mise install
mise ls
```

## Related Docs

- [`docs/profile-system.md`](profile-system.md)
- [`docs/stow-policy.md`](stow-policy.md)
- [`docs/keyboard-driven-window-management.md`](keyboard-driven-window-management.md)
- [`docs/vm-testing.md`](vm-testing.md)
