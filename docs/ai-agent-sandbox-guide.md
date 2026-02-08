# AI Agent Sandbox Guide

A guide to running AI coding agents safely in isolation on macOS.
Profile/app membership is managed in `apps.toml`; use `./install.sh --list-installed` to verify local state.

---

## Why Sandbox AI Agents?

AI coding agents are powerful but can cause damage if unconstrained:
- Deleting files outside the project
- Accessing SSH keys or credentials
- Force-pushing to protected branches
- Running destructive commands

**Solution:** Run agents in an isolated environment where they can only access the project directory.

---

## Two Sandboxing Options

| Feature | SandVault (Recommended) | Docker Sandbox |
|---------|-------------------------|----------------|
| Startup time | Instant | ~2-5 seconds |
| Resource usage | Native | Container overhead |
| macOS integration | Full | Limited |
| Setup complexity | `brew install sandvault` | Build image first |
| Use case | Daily development | Specific dependencies |

**Recommendation:** Use SandVault for daily work, Docker for reproducible environments.

---

## Option 1: SandVault (Recommended)

### Setup (one-time)

```bash
# Install via Homebrew
brew install sandvault

# Create the isolated user account
sv build
```

### Daily Usage

```bash
# Navigate to your project
cd ~/dev/my-project

# Run Claude in sandbox (interactive mode)
sandbox-claude

# Run Claude in autonomous mode
sandbox-claude --dangerously-skip-permissions

# Run other AI tools
sandbox-codex    # Codex CLI
sandbox-gemini   # Gemini CLI

# Shorthand aliases
svc    # = sandbox-claude
svx    # = sandbox-codex
svg    # = sandbox-gemini
```

### What SandVault Protects

| Access | Status |
|--------|--------|
| Project directory | ✓ Read/Write |
| `/Users/Shared/sv-$USER` | ✓ Read/Write |
| System binaries | ✓ Read Only |
| Your home directory (`~/`) | ❌ BLOCKED |
| SSH keys (`~/.ssh`) | ❌ BLOCKED |
| Other user directories | ❌ BLOCKED |

---

## Option 2: Docker Sandbox

Use this when you need specific dependencies or exact reproducibility.

### Setup

```bash
# Build the sandbox image (one-time)
docker build -t agent-sandbox ~/dev/agent-sandbox
```

### Usage

```bash
# Run in current directory
~/dev/agent-sandbox/docker-sandbox.sh

# Run in specific project
~/dev/agent-sandbox/docker-sandbox.sh ~/dev/my-project

# Run specific command
~/dev/agent-sandbox/docker-sandbox.sh ~/dev/my-project claude
```

### Container Capabilities

- Node.js 22
- Python 3
- Git (generic identity)
- Non-root user (`agent`)
- Project mounted at `/workspace`

---

## Recommended Workflow

```bash
# 1. Navigate to project
cd ~/dev/my-project

# 2. Create feature branch (protect main)
git checkout -b feature/new-feature

# 3. Run agent in sandbox with autonomous mode
sandbox-claude --dangerously-skip-permissions

# Agent works freely but:
# - Can't access your personal files (SandVault)
# - Can't commit to main (git hooks)
# - Can't push to main (GitHub protection)
# - Only works in the project directory

# 4. Review changes and push
git push -u origin feature/new-feature
gh pr create

# 5. Review and merge via GitHub
```

---

## Git Safety Layers

SandVault is Layer 2 of a 3-layer defense model:

```
Layer 1: GitHub Branch Protection
├── Blocks direct push to main
├── Requires PR + approval
└── Works even if local fails

Layer 2: SandVault (This Guide)
├── Isolated macOS user
├── Can't access ~/.ssh
└── Only sees project directory

Layer 3: Git Pre-commit Hooks
├── Blocks commits to main locally
├── Forces feature branches
└── Quick feedback loop
```

---

## Troubleshooting

### SandVault Won't Build

**Error:** `sudo: a terminal is required to read the password`

**Solution:** Run `sv build` in a real terminal, not through an automated script.

### Sandbox Can't Access Project

**Solution:** Make sure you're running from within the project directory:
```bash
cd ~/dev/my-project
sandbox-claude    # ✓ Correct
```

### Docker Image Not Found

**Solution:** Build the image first:
```bash
docker build -t agent-sandbox ~/dev/agent-sandbox
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `sandbox-claude` | Claude Code in sandbox |
| `sandbox-codex` | Codex CLI in sandbox |
| `sandbox-gemini` | Gemini CLI in sandbox |
| `svc` | Shorthand for sandbox-claude |
| `svx` | Shorthand for sandbox-codex |
| `svg` | Shorthand for sandbox-gemini |
| `sv build` | Create sandbox user (one-time) |
| `sv shell` | Enter sandbox shell |
