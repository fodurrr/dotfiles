# Stow Policy (Must Follow)

We only stow **stable config files**. We never stow runtime/state directories.

## Rules
- **Only include files we explicitly want versioned** in each stow package.
- **Never symlink an app’s entire config directory** if it also stores runtime data there.
- **Do not include empty directories** in a stow package unless they are required by the app and are stable.
- If an app writes runtime data into a directory, **only stow the stable subpaths** (e.g., `scripts/`), not the parent directory.

## Example (Raycast)
- ✅ Stow: `raycast/.config/raycast/scripts/*`
- ❌ Do not stow: `raycast/.config/raycast/extensions/`, `raycast/.config/raycast/ai/`

## Why
If we symlink a directory that apps write into, they will write into the repo. That pollutes git history and makes the repo non‑portable.
