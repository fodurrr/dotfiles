# Agent guide

`AGENTS.md` is the canonical agent guide for this repository.
`CLAUDE.md` contains only `@AGENTS.md`, so Claude loads the same instructions.
Keep implementation details here and in `docs/`; machine inventory belongs in the infrastructure notes vault.

## Start here

1. Read this file, `README.md` and the target profile under `profiles/`.
2. Identify the host, OS, checkout path, branch, working tree and remotes before acting.
3. Fetch upstream when available. Fast-forward a clean branch to its upstream before starting work.
4. Report dirty or diverged branches. Preserve local changes; never reset or force-push them away.
5. Inspect the selected apps in `apps.toml` and the relevant installer layer before editing.
6. Separate repository edits from live installation. Do not run the whole installer merely to update documentation.

## Git workflow

- Use `main` for normal installation. Machine profiles do not require separate long-lived branches.
- Develop on a feature branch from current `main`; use `codex/` for agent-created branches.
- Commit and push a completed change on its feature branch so the user can inspect or try it.
- Merge or push `main` only when the user explicitly approves that action.
- An approved consolidation may fast-forward `main` after checking that it contains every intended branch tip.
- Never delete source branches, rewrite history or change remotes as part of routine consolidation.
- Inspect active Git hooks before work. Do not bypass hooks or copy private keys to fix access.
- After a push, report the commit and provide optional VM or host commands with the actual checkout path and target profile.
- Do not run those installation commands automatically unless host installation is authorized.

## Machine assignments

| Machine | Profiles | Important boundaries |
|---|---|---|
| GEEKOM (`geekom-a8-max`) | `developer`, plus optional `geekom-vpn` | Daily Ubuntu desktop; display shortcuts, dictation and Tailscale tray belong here |
| Omen (`omen`) | `omen` | Headless Ubuntu Server development host, reached using `ssh omen` |
| Retired Clevo | `clevo` | Reference only; no further deployment to the failed laptop |

GEEKOM and Omen use `/home/fodurrr/dev/dotfiles`.
Do not apply GEEKOM desktop preferences or PIA/qBittorrent setup to Omen.
Keep the useful Clevo installer repairs even though the laptop is retired.
For other machines, discover profiles dynamically rather than assuming these assignments apply.

```bash
./install.sh --list-profiles
./install.sh --list-installed
```

### Omen without a Git remote

Omen's personal dotfiles checkout currently has no `origin` remote.
It receives committed changes through a Git bundle from GEEKOM; this does not grant remote hosting access.
Before updating it, inspect `git status`, its branch, HEAD and remotes over SSH.
Stop if it has local edits or diverged commits.

For an approved update from GEEKOM's committed `main`:

1. Create a temporary bundle with `git bundle create <bundle-path> main`.
2. Copy it to a temporary path on Omen using `scp`.
3. On Omen, verify it with `git bundle verify <bundle-path>`.
4. Fetch it with `git fetch <bundle-path> main` and record `FETCH_HEAD` immediately.
5. Verify the current HEAD is an ancestor of the fetched commit.
6. Switch to `main`, or create it at the current HEAD if absent.
7. Fast-forward `main` to the recorded fetched commit. Preserve the old feature branch.
8. Confirm both hosts have the same commit and clean working trees; remove only the temporary bundle files.

Do not copy GEEKOM's private SSH keys or tokens to Omen.
Do not rerun the installer just because the checkout was updated.

## Repository map

| Source | Responsibility |
|---|---|
| `install.sh` | Orchestrates bootstrap, selection, install steps and final summary |
| `apps.toml` | App metadata, ownership, versions, dependencies and platform mappings |
| `profiles/*.toml` | App membership, grouped under platform and category |
| `scripts/lib/` | Shared platform, package, profile, Stow, mise and summary helpers |
| `scripts/install/` | Bootstrap, argument parsing, selection and install layers |
| Top-level configuration packages | Stable files linked with Stow |
| `scripts/local-bin/` | Local launcher sources and explicit host helpers |
| `docs/` | Installation, ownership, host setup and recovery guidance |

## Installation flow and failure handling

Run `./install.sh` as the normal user. Linux package operations request sudo when required.
macOS bootstrap uses Homebrew and `Brewfile.bootstrap`; Linux uses native `apt` or `dnf` prerequisites.
Linuxbrew is not part of Linux installation.

After profile validation, the installer:

1. Installs Homebrew packages on macOS or mapped native packages on Linux.
2. Generates mise configuration and links selected stable configuration with Stow.
3. Installs selected mise tools and local fallback launchers.
4. Applies supported Linux vendor packages, desktop preferences and fonts.
5. Applies remaining platform configuration and prints the final summary.

Keep app and layer failures recorded while later installation steps continue.
Successful installs remain installed. The final summary must list failures and return a nonzero exit status.
Bootstrap failures, missing privileges and invalid input may still stop before app installation begins.
Never turn an install error into a silent success.
Use the actual log path shown by the installer when investigating a failure.

Default profile selection is additive. It keeps existing installed apps.
`--clean` removes managed apps outside the entire selected profile set.
Do not use cleanup on a live host without explicit removal authorization.
On GEEKOM, select both `developer` and `geekom-vpn` if enforcing their combined set.
`--yes` bypasses prompts; it does not make cleanup safe.

```bash
# GEEKOM desktop and VPN app packages
./install.sh -p developer -p geekom-vpn

# Omen server packages
./install.sh --profile=omen

# Interactive selection or individual extras
./install.sh
./install.sh --extras
./install.sh --create-profile
```

## App and runtime ownership

- Prefer mise for runtimes and supported agent CLIs. Each command needs one owner per platform/profile.
- Node LTS is an explicit dependency for tools that require Node, including OpenCode.
- Hermes uses its vendor installer and isolated runtime; do not force it into mise ownership.
- `codex-xpando` is a local launcher, not a separate Codex runtime. The `curl` layer copies its tracked source.
- `brew` metadata maps to native Linux package names; Linux does not run Homebrew for it.
- macOS GUI apps use `cask`. Linux GUI automation uses explicit native mappings and Linux app entries.
- Linux extras support `apt-repo`, `deb`, `script`, `snap`, `gsettings`, `gnome-shortcut` and `font`.
- Vendor package entries that require apt are not portable to Fedora. Read the layer's platform checks.
- `defaults` entries describe macOS preferences; do not apply them on Linux.
- Preserve package signing checks. Use scoped repositories and explicit dependencies.
- Read current `apps.toml` before claiming a tool version. `latest` tools may refresh on installer reruns.

Use mikefarah `yq` with TOML input. Profiles use platform/category tables:

```bash
yq -p toml -oy '.apps."opencode-cli"' apps.toml
yq -p toml -oy '.linux | to_entries | map(select(.value.apps != null)) | .[].value.apps[]' profiles/omen.toml
```

## Configuration and secrets

Only Stow stable, explicitly versioned files. Use `--no-folding`; do not link an entire stateful configuration directory.
Never commit tokens, private keys, provider logins, browser profiles, generated databases or runtime caches.
Preserve machine-local authentication during installation and profile changes.
See [Stow policy](docs/stow-policy.md) and [AI secrets](docs/ai-secrets.md).

Shell initialization order is PATH, mise activation, Sheldon, tool initialization, then aliases/functions.
Do not replace the user's shell session or restart running applications without a task-specific need.

## Separate host operations

- PIA login and `scripts/configure-geekom-pia.sh` are separate from selecting `geekom-vpn`.
- Keep qBittorrent bound to `wgpia0`; PIA's global kill switch is off in the chosen setup.
- Preserve other applications' direct routing and Tailscale connectivity. See [GEEKOM VPN setup](docs/geekom-pia.md).
- `scripts/prepare-ssd-temp-linux.sh --apply` requires sudo and explicit host authorization.
- It stages SSD-backed `/tmp` and extra swap. It does not delete caches or reboot the host.
- See [temporary storage](docs/linux-temp-storage.md) for prerequisites, reboot behavior and rollback.
- SSH, provider logins, database roles, T3 runtime and persistent services need separate host setup.
- Repository presence does not prove a service is configured, authenticated or running.

## Shell compatibility and checks

All shared shell scripts must remain compatible with macOS system Bash 3.2.
Avoid associative arrays, `mapfile`, case-conversion expansions, `&>`, `|&`, `coproc` and Bash-specific regex capture arrays.
Make changes idempotent for fresh hosts, configured hosts and repeated runs.

Before committing shell changes, check the changed scripts and the shared installer:

```bash
bash -n install.sh
for script in scripts/install/*.sh scripts/lib/*.sh; do bash -n "$script" || break; done
```

Before committing documentation changes:

```bash
bash scripts/docs/check-doc-drift.sh
git diff --check
```

The documentation check validates the Claude import, local links, stale references and read-only installer discovery commands.
It does not prove a fresh installation works. Run broader tests or a VM install only when requested.
Report checks actually run and any failures; do not imply unperformed host validation passed.
When researching app behavior, inspect the installed version and prefer current official documentation without year-constrained searches.

## Documentation map

- [README](README.md): machine choices, quick start and normal updates
- [Profile system](docs/profile-system.md): selection and installer architecture
- [Linux support](docs/linux-support.md): native packages and platform limits
- [GEEKOM VPN](docs/geekom-pia.md): application routing and qBittorrent interface binding
- [Temporary storage](docs/linux-temp-storage.md): explicit host preparation
- [VM workflow](docs/vm-testing.md): optional clean-machine validation
- [SSH setup](docs/ssh-github-setup.md): personal repository access
- [Agent sandbox guide](docs/ai-agent-sandbox-guide.md): coding tool sandboxing
