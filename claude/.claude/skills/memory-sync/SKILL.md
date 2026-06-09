---
name: memory-sync
description: Materialize memory layers (global, xpando-org, etc.) into the current project's auto-memory bucket. Run when starting fresh in a project, or after promoting a memory to a layer. Idempotent.
---

# /memory-sync

Materializes layered memories defined in `~/.claude/memory-layers/config.yaml` into the current project's auto-memory bucket so Claude Code's auto-memory system loads them at session start.

## How it works

Auto-memory in Claude Code is keyed to cwd: `~/.claude/projects/<dashed-cwd>/memory/`. There is no native layering. This skill physically copies layer files into the project bucket and rebuilds the bucket's `MEMORY.md` index with section headers.

## Procedure

1. **Determine current project bucket.** The path is `~/.claude/projects/<dashed-cwd>/memory/` where `<dashed-cwd>` is the absolute cwd with `/` replaced by `-` (leading dash kept). Example: cwd `/Users/fodurrr/dev/xpando/xpando` → `-Users-fodurrr-dev-xpando-xpando`. Create the bucket directory if missing.

2. **Read `~/.claude/memory-layers/config.yaml`.** For each layer, expand `~` in `applies_to` patterns and check whether current cwd matches any pattern (glob-style; `*` matches any path tail). Collect the matching layer names in declaration order.

3. **Identify project-local files.** In the existing bucket, files are project-local if their frontmatter has no `_layer` field. Read all `*.md` filenames (excluding `MEMORY.md`); for each, check frontmatter for `_layer:`. Files lacking it are project-local.

4. **For each matching layer (in declaration order — earlier layers are less specific, later layers override):**
   - Copy every `*.md` file (except the layer's own `MEMORY.md`) from `~/.claude/memory-layers/<name>/` into the project bucket
   - Skip the copy if a project-local file (no `_layer` frontmatter) exists with the same name; report a collision warning
   - Overwrite if an existing file has matching `_layer` frontmatter (it's a refresh)

5. **Regenerate `MEMORY.md`** in the project bucket. Format:

   ```markdown
   # Memory Index

   ## Global

   <copy of ~/.claude/memory-layers/global/MEMORY.md body, minus its top-level # heading>

   ## Xpando Org

   <copy of ~/.claude/memory-layers/xpando-org/MEMORY.md body, if matched>

   ## Project-local

   <previously-existing project-local index entries, preserved>
   ```

   Each layer section is only included if that layer matched. Layer sections come first; project-local entries come last (they're rarer).

6. **Report.** Print: layers materialized, count of files copied, count of project-local files preserved, any collisions.

## Frontmatter convention

Layer files MUST have `_layer: <name>` in frontmatter. `/memory-promote` adds this when promoting a file. Project-local files MUST NOT have `_layer`.

## Failure modes

- **Collision** (project-local file with same name as layer file): skip the layer copy, warn the user, suggest using `/memory-promote` to convert the local file or rename it.
- **Layer dir missing**: warn and continue with other layers.
- **Bucket dir missing**: create it.

## When to run

- First time entering a new project that should have layered memories.
- After running `/memory-promote` if you want sibling projects to see the change immediately.
- After editing layer files manually.

Not needed during normal sessions — once a bucket is synced, it stays correct until layers change.
