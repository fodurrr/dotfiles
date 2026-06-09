---
name: memory-promote
description: Promote a memory file from the current project's auto-memory bucket up to a shared layer (global or xpando-org). Run when a project-specific memory turns out to be relevant across projects.
---

# /memory-promote

Moves a memory file from the current project's auto-memory bucket into a shared layer at `~/.claude/memory-layers/<layer>/`, so future `/memory-sync` runs in matching projects pick it up.

## Usage

User invokes with the filename and target layer:
- `/memory-promote feedback_xyz.md --to global`
- `/memory-promote project_abc.md --to xpando-org`

If args are omitted, ask the user which file and which layer.

## Procedure

1. **Validate inputs.**
   - File must exist in current project's bucket (`~/.claude/projects/<dashed-cwd>/memory/<file>`)
   - Target layer must exist as a directory in `~/.claude/memory-layers/`
   - File must NOT already have `_layer` frontmatter (already promoted) — warn and stop if so

2. **Add `_layer: <name>` to frontmatter** of the file. If frontmatter is missing entirely, add it. If it exists, insert `_layer:` after `type:` (or at end of frontmatter block).

3. **Move the file** from the project bucket to `~/.claude/memory-layers/<layer>/`. Use `mv` not `cp` — single source of truth lives in the layer.

4. **Update the layer's `MEMORY.md` index.** Read the file's `name` and `description` from frontmatter. Append a one-liner to the appropriate type section (Feedback / Reference / User / Project) of the layer's index, format: `- [Title](file.md) — description`. Create the index file with section headers if it doesn't exist.

5. **Update the project bucket's `MEMORY.md`.** Remove the entry from the `## Project-local` section. Add it to the appropriate layer section (e.g., `## Global`) if not already present from a prior sync — easier: just rerun the index regeneration logic from `/memory-sync` step 5.

6. **Report.** Print: file moved, target layer, what was added to layer index, suggestion to run `/memory-sync` in other affected projects if you want them updated immediately.

## Notes

- Promote-only. To demote (e.g., layer file should be project-only), do it manually: edit the layer file out of the layer index and the layer dir; copy it into the project bucket; remove `_layer` frontmatter.
- Promotion never propagates automatically to other project buckets — they'll get the file on their next `/memory-sync`. This is deliberate — keeps each project's bucket explicit.
