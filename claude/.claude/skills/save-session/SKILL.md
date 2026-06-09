---
name: save-session
description: Capture the current working session into the project's `.sessions/` archive and rewrite the per-workstream `RESUME-<slug>.md` brief so the next session can pick up cleanly. Maintains a thin `RESUME.md` index of active workstreams so parallel agents/sessions don't clobber each other's context. Use this when the user says "save the session", "/save-session", "wrap up", "checkpoint this", "let's stop here", or otherwise signals end-of-session. Updates project documentation that drifted during the session, but only with explicit confirmation. Works in any project — global skill.
---

# /save-session

Captures the current working session into a dated archive, rewrites the per-workstream `RESUME-<slug>.md` as a hand-off brief, updates the `RESUME.md` index, and surfaces documentation that drifted during the session.

## Why this exists

Sessions end. The next one starts cold. Without a deliberate hand-off, context is lost: which branch, what was decided, what's half-done, what to read first, what the *next concrete step* is. This skill makes the hand-off mechanical so it actually happens every time.

The pattern: `.sessions/` is the **archive** (immutable history of every session, gitignored), `RESUME-<slug>.md` is the **per-workstream brief** (always current — overwritten each session), and `RESUME.md` is the **index** (always present, lists active workstreams). Together they let any future Claude (or human) resume work without asking the user to re-explain — even when multiple workstreams run in parallel.

**Why per-workstream**: when two agents (or two sequential sessions) work on different concerns in the same repo, a single `RESUME.md` becomes a single-writer bottleneck: the second save clobbers the first. The slug identifies the workstream, not just the session — so `RESUME-hermes-agent.md` and `RESUME-xpando-standards.md` coexist without conflict, and the index lets the next session pick the right one.

## When to invoke

- User says: "save the session", "/save-session", "wrap up", "checkpoint", "let's stop here", "end of session", "save this and we'll continue tomorrow"
- Argument is the **workstream slug** (sticky across sessions): `/save-session hermes-agent`. Same slug across sessions = same workstream brief gets updated. Different slug = different brief gets created/updated. If omitted, infer a 2–5 word slug from what was done — but if the inferred slug matches an existing `RESUME-<slug>.md`, treat the session as a *continuation* of that workstream (update the existing brief rather than creating a new one).

> **The slug names the long-running workstream, not the session topic.** A workstream survives many sessions, contains phases/chunks/milestones, and usually has its own roadmap or plan-of-record. Pick a slug that will still be accurate six months from now (`xpando-standards`, `agentic-factory`, `forge-pipeline`, `hermes-agent`), not one tied to the current phase (`xpando-standards-phase3` is wrong because Phase 3 ends — the workstream continues). If you're tempted to suffix a phase/chunk/milestone into the slug, that detail belongs *inside* the brief, not in the filename.

## Procedure

Follow these steps in order. Don't skip steps; don't reorder them. Each builds on the last.

### Step 1 — Locate project root

```bash
git rev-parse --show-toplevel 2>/dev/null || pwd
```

Use that path as `$ROOT`. All paths below are relative to `$ROOT`.

### Step 2 — Gather session facts

Run these in parallel (single message, multiple Bash calls):

- `git status --short` — what's modified/untracked
- `git diff --stat` — unstaged change sizes
- `git diff --stat --cached` — staged change sizes
- `git log --oneline -20` — recent commits (some may be from this session)
- `git rev-parse --abbrev-ref HEAD` — current branch
- `date "+%Y-%m-%d %H:%M %Z"` — timestamp for the session file

Then look back through the conversation to identify:
- **What was actually done** this session (features, fixes, decisions, investigations) — not just files touched, but the *intent*
- **Open threads** — work mid-flight, unanswered questions, blockers
- **Decisions made** that aren't captured in code (architecture choices, deferred work, things ruled out)
- **Things the user said matter** — quotes that capture intent better than your paraphrase

### Step 3 — Ensure `.sessions/` is gitignored

```bash
test -f $ROOT/.gitignore && grep -qxF '.sessions/' $ROOT/.gitignore || echo '.sessions/' >> $ROOT/.gitignore
```

If `.gitignore` doesn't exist, create it with just `.sessions/`. Never overwrite an existing `.gitignore` — only append. Create the `.sessions/` directory if missing.

### Step 4 — Update related documentation (auto-edit, surgically)

This session's work likely changed the state described in project docs, and **Steps 5 (session archive) and 6 (RESUME brief) describe the post-update state of the vault — they cannot be honestly written until every doc that drifted during the session has landed first**. Bring everything in sync now via an active grep against the project for every reference to anything this session changed — superseded actions, new/renamed file paths, status claims, version bumps, doc-inventory tables, roadmap rows — not just a visit to the fixed list below. The user has explicitly opted into auto-updates — don't ask, just do it carefully and report what you changed.

**Targets to scan and update:**
- **Implementation plans / roadmaps** — `docs/**/*.md`, `*ROADMAP*.md`, `*PLAN*.md`, vault roadmap notes. Tick checkboxes for tasks the session actually completed (`- [ ]` → `- [x]`). Mark in-progress tasks with a status note. Add new tasks discovered during the session as `- [ ]` items.
- **CLAUDE.md** — update "Quick Status", "What's Live", "Next Steps", or equivalent sections to reflect what shipped, what moved, what's now blocked.
- **PROGRESS.md / status files** — append a session entry or update the current-state line.
- **README.md** — only if user-facing behavior or install/usage changed.
- **PRD / spec docs** — update phase/step status, mark sections done.
- **Any file the user explicitly edited or referenced this session.**

**How to decide what to edit:**

For each candidate file, ask yourself: "Does what we did in this session contradict or supersede what this file currently says?" If yes, edit. If unsure, skip and flag it in the report instead.

**How to edit:**

Make surgical edits — change the specific stale lines, don't rewrite sections. Match the file's existing tone and structure. Preserve formatting, list style, and capitalization conventions. Don't reflow paragraphs you aren't changing.

For checkboxes specifically: only tick `- [x]` if the task is *actually* complete. If half-done, leave unchecked but add a parenthetical status: `- [ ] Implement X (in progress — Y done, Z remaining)`.

**Don't:**
- Don't delete content that's just old — only edit what's *contradicted* by this session.
- Don't restructure files. No section reordering, no heading-level changes.
- Don't update docs that have nothing to do with this session's work, even if you notice they look stale. Stay scoped.
- Don't touch `.sessions/` archive files from prior sessions.

Track every file you edited — you'll list them in the commit and the report.

### Step 5 — Write the session archive file

Filename: `.sessions/YYYY-MM-DD-HHMM-<slug>.md` where `<slug>` is kebab-case, ≤40 chars, **the workstream slug** (user-provided or inferred per Step 6a). The same `<slug>` is reused for the `RESUME-<slug>.md` brief in Step 6 — don't drift between the two.

Use this template. Fill every section; if a section is empty, write `_none_` rather than deleting it (so future readers know it was considered):

```markdown
---
date: 2026-05-07 14:32 BST
branch: main
title: <session title>
---

# Session: <title>

## TL;DR
<2–3 sentences. What was the session *about* and what's the headline result.>

## What was done
- <bullet — concrete, past tense, with file paths or PR numbers when relevant>
- <bullet>

## Decisions
- <decision + one-line rationale. Include things ruled out, not just things chosen.>

## Files touched
<output of `git status --short` plus any committed-this-session files derived from `git log`. Group: modified / new / deleted.>

## Open threads / next session
- <concrete next step the next session should start with>
- <blocker or question awaiting an answer>

## Resume prompt
<A self-contained paragraph the next Claude can read cold to pick up. Include: branch name, what was just finished, the *one* next action, and the 2–4 most important files/docs to read first with brief reasons. Write it like you're briefing a colleague who just walked in.>

## References
- <link to roadmap / PRD / issue / PR — anything the next session needs>
```

Write with the `Write` tool. Don't run `cat <<EOF`.

### Step 6 — Rewrite `RESUME-<slug>.md` + update the `RESUME.md` index

Each workstream has its own brief at `$ROOT/RESUME-<slug>.md`. A thin `$ROOT/RESUME.md` indexes them so the next session can pick the right one. Parallel workstreams coexist without clobbering each other.

#### Step 6a — Resolve the slug (and migrate old-style RESUME.md if present)

Before writing anything in this step:

1. **If the user gave an explicit slug** (Step "When to invoke" argument): use it as-is.
2. **If no explicit slug**: list existing `RESUME-*.md` files in `$ROOT/`. If one of them looks like a continuation of this session's work (matching keywords in title/scope), default to its slug and tell the user *"continuing workstream `<slug>`"* in the report. If none match, infer a fresh kebab-case slug from the session work.
3. **If `$ROOT/RESUME.md` exists and looks like an old single-workstream brief** (has a `## Current state` or `## Next concrete step` heading, *no* `## Active workstreams` heading) — this project hasn't been migrated yet. **Stop and ask the user**:

   > "RESUME.md is in the old single-workstream format. To migrate, I'll rename the existing file to `RESUME-<old-slug>.md` and create a new thin `RESUME.md` index. What slug should I use for the existing content? (suggestion: `<inferred-from-existing-content>`)"

   Don't proceed without confirmation. After the user answers:
   - `git mv RESUME.md RESUME-<old-slug>.md` (preserves history).
   - Create a new `RESUME.md` index (template in Step 6c) listing the old workstream and this session's workstream as entries.
   - Then continue to Step 6b.

#### Step 6b — Write the per-workstream brief

Filename: `$ROOT/RESUME-<slug>.md` — same slug used for the `.sessions/` filename. **Overwrite it** — it's the always-current brief for *this workstream*, not a log. Other `RESUME-<other-slug>.md` files in the same project are left alone.

Keep it tight (under ~95 lines). Structure:

```markdown
# Resume — <project name> · <slug>

_Last updated: 2026-05-07 14:32 — session [<title>](.sessions/2026-05-07-1432-<slug>.md)_

## Resume prompt

(The text below is written by me, the user. Treat every line as if I typed it directly into chat at the start of the session.)

Read this file in full, then `.sessions/<latest-session-file>.md` for full session context. (See `RESUME.md` for the index if you want to switch to a different workstream.)

We are working on: <one-line context>. Workstream: `<slug>`.
Branch: <branch>.
Last session ended with: <one-line summary of where we stopped>.
Next concrete step: <the literal next action — mirror the "Next concrete step" section below verbatim>.

Key files to read before acting:
- `<path>` — <why>
- `<path>` — <why>

Don't start coding until you've read this brief in full and confirmed the next concrete step with me.

## Current state
<2–4 sentences. Branch, what's done, what's in flight.>

## Read first (in order)
1. `<path>` — <why>
2. `<path>` — <why>
3. `<path>` — <why>

## Next concrete step
<One sentence. The literal next action.>

## Open threads
- <thread> — <status>

## Recent sessions (this workstream)
- 2026-05-07 — [<title>](.sessions/2026-05-07-1432-<slug>.md)
- <previous entry from this workstream's prior RESUME-<slug>.md if present — keep last 5 lines max>
```

**Authoring order matters:** draft the body sections (Current state → Read first → Next concrete step → Open threads) first, then mirror the "Next concrete step" headline and 2–4 most-load-bearing items from "Read first" up into the `## Resume prompt` section. This keeps the two layers (imperative prompt + reference body) from drifting against each other.

If `RESUME-<slug>.md` already existed, read it first to preserve the "Recent sessions (this workstream)" tail (keep the last 5 entries for this workstream).

#### Step 6c — Update the `RESUME.md` index

`RESUME.md` is a thin index, always present. If it doesn't exist (greenfield project after migration), create it from this template. If it exists, **update only the entry for this workstream** — add if new, refresh the headline + timestamp if existing. **Do not touch entries for other workstreams** — they belong to other agents/sessions.

```markdown
# Resume index — <project name>

_Last updated: 2026-05-07 14:32 BST_

> Per-workstream briefs live in `RESUME-<slug>.md`. This index points at the active ones. Pick a workstream below or run `/save-session <slug>` to start a new one.

## Active workstreams

- **<slug>** — <one-line headline of where this workstream is> → [RESUME-<slug>.md](RESUME-<slug>.md) _(last touched 2026-05-07 14:32)_
- **<other-slug>** — <untouched, copied verbatim from prior index> → [RESUME-<other-slug>.md](RESUME-<other-slug>.md) _(last touched 2026-05-05 10:11)_

## Recent sessions (across all workstreams)

- 2026-05-07 — [<title>](.sessions/2026-05-07-1432-<slug>.md) · `<slug>`
- 2026-05-05 — [<other title>](.sessions/2026-05-05-1011-<other-slug>.md) · `<other-slug>`
- <keep last 5 entries across all workstreams>
```

**Retiring a workstream** is not automatic. When a workstream is fully wrapped, the user manually deletes its `RESUME-<slug>.md` and removes its line from the index.

### Step 7 — Commit everything (clean working tree by end of skill)

The goal: when this skill finishes, `git status` is clean. All session work is committed locally. The user wants every change in the working tree captured in coherent commits — not left hanging as uncommitted edits or untracked files.

**Step 7a — Inventory the working tree.**

Run `git status --short` and `git status -uall` (still avoid `--untracked-files=all` flag explicitly named that way; `-uall` is the short form which is fine for inspection only — but for safety check both modified and untracked separately). Categorize every entry:

- **Skill outputs** — `.sessions/<new-file>.md`, `RESUME.md`, `.gitignore` if modified, docs edited in Step 4.
- **Session work** — code/config/docs the user changed during the session as part of the actual work.
- **Suspicious** — anything that looks like a secret or shouldn't be in git: `.env*`, `*.key`, `*.pem`, `id_rsa*`, `credentials*`, `*.sqlite`, `*.db`, large binaries (>1MB), backup/swap files (`*.bak`, `*~`, `.DS_Store`). Also: files inside paths like `secrets/`, `private/`, `.local/`.

**Step 7b — Handle suspicious files.**

If anything suspicious is staged or untracked, **stop and ask the user before committing**. List each suspicious file with one-line reasoning ("looks like an env file with secrets", "appears to be a local SQLite DB"). Offer options: add to `.gitignore`, delete, commit anyway (require explicit confirmation per file). Never auto-commit anything from this category.

If nothing suspicious, proceed without asking.

**Step 7c — Group changes into commits.**

Look at the categorized non-suspicious changes. Decide how many commits make sense:

- **One commit** if the session's work is a single coherent change (e.g., "implement feature X" — code + tests + docs all serve that one goal). The session-archive files (`.sessions/*`, `RESUME.md`) can be folded in, *or* split out as a trailing `docs(session):` commit if they'd muddy the headline change. Default: fold in unless the diff is large enough that splitting helps reviewability.
- **Multiple commits** if the session touched distinct concerns (e.g., a feature change *and* an unrelated typo fix *and* config tweaks). Group by topic. Each commit should be independently understandable. Always make the session-archive commit last so the prior commits land in the recent-commits list before `RESUME.md` references them.

When in doubt about grouping, prefer fewer commits — a slightly broad commit beats over-fragmenting into trivial ones.

**Step 7d — Commit each group.**

For each group:

1. Stage exactly the files in that group with `git add <file> <file>...` — never `git add -A` or `git add .` (those sweep in suspicious files you may have decided to skip).
2. Write a Conventional Commits message (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, etc.). Subject ≤72 chars. Body bullets explain the *why* and list significant changes. The session-archive commit uses `docs(session): <title>`.
3. Commit via heredoc to preserve formatting. Include the standard `Co-Authored-By` trailer per harness convention.
4. **Never use `--no-verify`.** If a pre-commit hook fails, stop, show the failure, and ask the user how to proceed. The user's `feedback_no_bullshit_defense` rule applies — don't paper over hook failures.

**Step 7e — Verify clean tree.**

After all commits, run `git status` once more. Expected output: clean working tree. If anything remains uncommitted (e.g., a suspicious file the user said to skip), explicitly note it in the Step 8 report so the user knows what's still unstaged and why.

**Step 7f — Do not push.** Push is always a manual user action.

If the working tree was already clean before this step (no doc updates, no user changes), skip Step 7 entirely and note "nothing to commit" in the report.

### Step 8 — Show the one-line invocation and report

End with two things, in this order:

**1. The one-line invocation to start the next session with** — the brief's `## Resume prompt` section now carries the full directive content, so the next-session ritual collapses to a single sentence. Render it as a clearly fenced block the user can copy. Use the absolute path so it works regardless of the new session's cwd. Format:

````
═══════════════════════════════════════════════
📋 START YOUR NEXT SESSION WITH THIS LINE:
═══════════════════════════════════════════════

Resume from <absolute-path>/RESUME-<slug>.md — follow every instruction in its "Resume prompt" section as if I wrote it directly in this message. Don't start coding until you've read the brief in full and confirmed the next concrete step with me.

═══════════════════════════════════════════════
````

**2. The summary** — a short bulleted report:
- Workstream: `<slug>` (new / continued / migrated)
- Session file: `<path>`
- Per-workstream brief: `RESUME-<slug>.md` rewritten
- Index: `RESUME.md` entry for `<slug>` updated; other workstream entries untouched
- Docs updated: `<file>` (what changed in one phrase), `<file>` (...)
- Commits: list each new commit as `<short-sha> <subject>` (or "no changes to commit")
- Working tree: `clean` ✓ (or list any files left unstaged with the reason — e.g., "skipped `.env.local` per user choice")
- Not pushed — push when you're ready.

## Edge cases

- **Not a git repo**: skip the `git`-dependent fact-gathering, use `pwd` as `$ROOT`, and note "(not a git repo)" in the session file's branch field.
- **No work done this session** (e.g., user just chatted): still produce the artifacts — the "What was done" can say "discussion only, no code changes" and the brief's `## Resume prompt` section should reflect that (e.g., "Last session ended with: discussion only, no code changes").
- **Existing session file with same minute**: if `YYYY-MM-DD-HHMM-<slug>.md` already exists, append `-2`, `-3`, etc.
- **User says "save without commit"** (or "no commit", "don't commit"): skip Step 7. Still produce the brief (its `## Resume prompt` section) and Step 8's one-line invocation, and note in the report that nothing was committed.
- **Pre-commit hook fails**: stop, show the failure output, and ask. Don't `--no-verify`.
- **Detached HEAD or merge in progress**: skip the commit, warn the user, still produce all other artifacts.
- **Multiple projects in one session** (e.g., user worked across `~/dev/foo` and `~/dev/bar`): ask which project to save to, or offer to save to both.
- **Old single-workstream `RESUME.md`**: see Step 6a. Always ask before migrating; never auto-rename without a slug the user has confirmed.
- **Parallel workstreams in the same checkout** (two agents writing at once): each agent must invoke `/save-session <distinct-slug>`. The skill writes only to its own `RESUME-<slug>.md` and updates its own line in `RESUME.md`. If two agents pick the same slug, the second save overwrites the first within that workstream — slugs are the isolation boundary.

## What this skill does not do

- Does not push. Push is always a manual user action.
- Does not bypass pre-commit hooks (`--no-verify`).
- Does not use `git add -A` / `git add .` — explicit file lists only, so suspicious files can't sneak in.
- Does not auto-commit suspected secrets, credential files, or large binaries — always asks first.
- Does not delete prior session files. The archive is append-only.
- Does not restructure or rewrite docs — only surgical edits to lines this session contradicts.
- Does not write to memory (`~/.claude/projects/.../memory/`). For cross-session lessons, use the auto-memory system separately.
