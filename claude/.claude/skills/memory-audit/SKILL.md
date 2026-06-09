---
name: memory-audit
description: Scan the current project's auto-memory bucket and recommend which memories should be promoted to which layer (global or xpando-org). Produces a numbered table for user review and bulk action.
---

# /memory-audit

Scans every project-local memory file (no `_layer` frontmatter) in the current bucket, applies heuristic rules, and produces a numbered recommendation table the user can review and approve in bulk.

## Procedure

1. **List project-local files** in `~/.claude/projects/<dashed-cwd>/memory/`. Exclude `MEMORY.md`. Exclude any file already tagged with `_layer:` in frontmatter.

2. **For each file**: read frontmatter (`name`, `description`, `type`) and body. Apply heuristics below to determine recommended tier and reasoning.

3. **Print numbered table**:

   ```
   #  | File                                       | Recommended | Reason
   ---+--------------------------------------------+-------------+------------------------------------
   1  | user_profile.md                            | global      | Personal identity (name, location)
   2  | feedback_use_mise_not_brew.md              | global      | Tooling preference, applies anywhere
   3  | project_xpando_deploy.md                   | xpando-org  | Mentions xpando.ai, CI/CD pipeline
   ...
   ```

4. **Wait for user approval.** User responds with line numbers and overrides:
   - "all yes" — accept every recommendation as-is
   - "1-15 yes, 16 global, 17 skip, 18 yes" — accept specific lines, override or skip others
   - "redo 5" — surface that one for re-discussion before deciding

5. **Execute moves.** For each accepted line, run the equivalent of `/memory-promote <file> --to <tier>` (move file, add frontmatter, update layer index, update project index). Skipped files stay project-local.

6. **Report final state.** Print: count promoted to global, count promoted to xpando-org, count left project-local, any errors.

## Heuristic rules

Token-match against the memory's `name`, `description`, AND body, in priority order. First strong match wins. Ties surface to user with both candidates noted.

### xpando-org tier — recommend if memory mentions:

- **Servers (Xpando fleet)**: hermes, mimir, amaterasu, thor, sun-wu, odin, inari, sun-bin, heimdall
- **Services**: forgejo, infisical, zitadel, grafana, crowdsec, dokploy, tailscale, caddy, ntfy, prometheus, loki, restic
- **Products**: xpando (lowercase, as repo/domain), forge, tweak-ui, xtweak, "xo " (with space, to avoid false matches), "arc " (with space), weave, lingua, nucleus, cortex, tea (in xpando context)
- **Factory / AI infra**: archon, factory, glm, FACTORY_RULES, gate 11, wiki pipeline, livebook, oban, ash (in xpando context)
- **Domains**: xpando.ai, git.xpando, grafana.xpando, dev.xpando
- **Company-operational**: xpando ltd, company formation (operational details, NOT personal employment)
- **Development conventions specific to xpando stack**: ash framework, mix ash.setup, mix ecto.migrate (these are xpando-specific because they're our chosen stack)

### global tier — recommend if memory mentions:

- **Personal identity**: peter, fodurrr, london, uk, hu (citizenship), bitwarden
- **Workplace (employer context)**: jm, employment contract (in personal sense — "JM HR contact"), hr
- **Tooling preferences (cross-project)**: mise (not in xpando context), brew, ghostty, zshrc, zprofile, catppuccin, vscode, zed
- **Claude Code mechanics**: claude code (the tool), settings.json, hooks, permission mode, CLAUDE.md (the convention), sessionend, sessionstart
- **Communication / behavior style**: verify before, listen to user, be precise, no skim, no secrets in chat, never delete, follow through, no bullshit, plan before, system date, autonomous, read docs first, read source

### project-local — fallback:

- No strong match above
- AND content clearly references one repo's local concerns only
- Example: vault migration history, vault-specific entry-point conventions

### Tie-breakers

- **Memory mentions both global AND xpando-org signals**: usually means the rule is general (global) but the example/origin is xpando. Recommend global IF the rule itself is general; recommend xpando-org IF the rule is xpando-specific. Surface as ambiguous to user with reasoning.
- **Memory is purely about communication style**: always global (these are about working with the user, not about a project).
- **Memory references xpando but the rule generalizes** (e.g., "always read official docs first" with a Forgejo example): global. The rule transcends the example.

## Output format

ALWAYS produce a single numbered table covering ALL files. The user wants to scan it once, not walk through entries. The table is the deliverable; the moves wait for user approval.
