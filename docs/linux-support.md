# Linux Support

This repository supports Linux (Ubuntu, Debian, Fedora) with native package managers.

## Strategy

- Linux installs use `apt` (Ubuntu/Debian) or `dnf` (Fedora/RHEL/CentOS).
- Linux bootstrap does **not** install or depend on Homebrew/Linuxbrew.
- macOS keeps the existing Homebrew-based flow.

## Supported Platforms

Host-specific optional setup:

- [GEEKOM PIA and qBittorrent](geekom-pia.md): `geekom-vpn` profile plus explicit local network configuration.
- [SSD-backed temporary storage](linux-temp-storage.md): opt-in host preparation for GEEKOM and Omen.

- Ubuntu 20.04+
- Debian 11+
- Fedora 35+
- RHEL/CentOS (best-effort)

## Installation

```bash
git clone git@github.com:fodurrr/dotfiles.git
cd dotfiles
./install.sh --profile=hacker
```

## Bootstrap Behavior

On Linux, bootstrap installs prerequisites for the remaining layers:

- installer/runtime tools (`yq`, `stow`, `git`, `curl`, etc.)
- build toolchain and common dev headers for clean-machine runtime builds
- `mise` (if not already installed)
- `gum` via distro package when available, with binary fallback

`yq` is validated for TOML support (`-p toml`). If distro `yq` is incompatible, the installer falls back to the mikefarah binary.

`gum` is best-effort on Linux. If package and binary fallback are unavailable, installer output falls back to plain shell formatting.

## Linux Layer Behavior

Linux package installs are driven by `apps.toml` metadata for `type = "brew"` entries:

- `linux_name`: common Linux package name
- `linux_apt`: apt override
- `linux_dnf`: dnf override

If an app is selected for Linux but has no mapping (or the package is unavailable), it is skipped with an explicit message.

Selected Linux apps come from platform/category tables such as `[linux.cli]` in `profiles/*.toml`.

For selected mapped Linux packages, reruns now re-apply package manager installs to pick up newer repository versions.

If a selected mapped package install/upgrade fails, the Linux layer exits non-zero.

`sheldon` is not available in the default Ubuntu/Fedora repositories. It is installed through mise on macOS and Linux by the `sheldon` entry.

## GUI Apps on Linux

- GUI apps are only automated when a native Linux package mapping exists.
- macOS-only GUI apps are marked `platform = ["macos"]` and are skipped on Linux.
- Explicit Linux entries support vendor apt repositories, `.deb` packages, scripts and Snap apps.
- There is no general Flatpak fallback; apt-specific entries do not run on Fedora.

The `developer` profile includes Mailspring through its official GitHub `.deb`
releases. See [email clients](email-clients.md) for account setup, shared mailbox
limits and the separate Outlook setup on Android.

## Platform-Aware Layering

### macOS
1. Bootstrap (Homebrew + `Brewfile.bootstrap`)
2. Homebrew layer
3. Stow layer
4. Mise layer
5. Curl layer

### Linux
1. Bootstrap (`apt`/`dnf` + prerequisites)
2. Linux packages layer (`apt`/`dnf`, mapped from `apps.toml`)
3. Stow layer
4. Mise layer
5. Curl layer

Selected app failures are recorded while the remaining apps and layers continue:

- stow link failures
- selected mise tool install failures
- selected mapped Linux package install/upgrade failures

The final summary lists failed items separately from unchanged or skipped items.
After all independent steps finish, errors produce exit status 1 and the installer
returns to the calling shell without launching a replacement shell. Successful
installs remain in place. Bootstrap prerequisites (sudo, package manager, parser)
are still required before the profile can be interpreted safely.

Tailscale's Linux entry provisions its official Ubuntu/Debian or Fedora repository
before installing the package, then enables `tailscaled`. Account authentication
remains a manual `sudo tailscale up` step. Other distributions report a failure.

GEEKOM's `developer` profile also selects `tailscale-systray-linux`. It stows only
`~/.config/autostart/tailscale-systray.desktop`, equivalent to
`tailscale configure systray --enable-startup=freedesktop`. The applet starts at
desktop login. Start it immediately with `tailscale systray` if it is not already
running. The headless `omen` and `server` profiles do not select this applet.

The `clevo` profile is a saved developer-profile variant for the P170EM laptop.
It omits the GEEKOM monitor commands and shortcuts.
The profile is an explicit snapshot; compare it with `developer` when updating apps.

Agent CLIs Claude, Codex, OpenCode, Pi, Gemini, Grok and herdr are managed by mise.
OpenCode declares Node as an installation dependency; Node uses the `lts` version.
Hermes Agent uses its vendor installer and isolated runtime. `codex-xpando` is a
local launcher copied from `scripts/local-bin`, not a second Codex installation.

### Linux Shell Finalization

After install summary, Linux flow ensures zsh is the login shell:

- interactive mode prompts before `chsh`
- `--yes` mode performs non-interactive attempt when possible
- failure to set zsh login shell is treated as install failure with manual remediation command

## Validation

Run Linux-focused assertions and mocked failure/continuation regressions:

```bash
./scripts/test-linux.sh
./scripts/test-install-results.sh
```

This validates:

- platform filtering (`ghostty` false on Linux, `starship` true)
- Linux package mapping presence
- `sheldon`, `restic` and the Codex CLI are mise apps on both platforms; `btop` is mise on Linux (`btop-linux`) and Homebrew on macOS, because mise has no macOS build
- Linux bootstrap branch behavior (no `brew` calls in Linux bootstrap function)
- macOS-only guardrails for post-install steps
- summary fallback behavior when gum is missing
- strict stow behavior (`stow_enforce` failures are not ignored)

## Adding Cross-Platform Brew Apps

For a `type = "brew"` app that should install on Linux, add package mapping fields:

```toml
[apps.btop]
type = "brew"
platform = ["macos", "linux"]
linux_name = "btop"
```

Use distro overrides only when names differ:

```toml
linux_apt = "package-name-on-apt"
linux_dnf = "package-name-on-dnf"
```

## Desktop: Screens, Clipboard, PaperWM

Part of the `developer` profile on Linux. The commands are stow links into `desktop-linux/`; the shortcuts are `gnome-shortcut` entries in `apps.toml`.

### Screens

Ubuntu cannot detect a monitor's power button: the screen stays "connected", so windows stay on it. The `screens` command chooses the active screens, and windows move to what remains.

| Key | Command | Result |
|---|---|---|
| Ctrl+Alt+M | `screens monitor` | only the 49-inch monitor (DP-1) |
| Ctrl+Alt+T | `screens tv` | only the TV (HDMI-1) |
| Ctrl+Alt+B | `screens both` | both, monitor left of the TV |

Ctrl+Alt+T is Ubuntu's key for opening a terminal. The entry `gnome-terminal-shortcut-off` clears that key so the TV shortcut can use it.

The choice is not persistent: after a restart both screens are on. The connector names, modes and scales are written in `desktop-linux/.local/bin/screens`; change them there for other hardware. The command calls GNOME's `gdctl` with `/usr/bin/python3`, because the mise Python has no `gi` module.

### Keyboard and mouse (Logi Bolt)

A Bluetooth keyboard cannot work in the boot menu, and on a machine that also starts Windows the two systems overwrite each other's Bluetooth pairing. A Logi Bolt USB receiver avoids both: the pairing is stored in the receiver, so one Easy-Switch key works in the boot menu, in Ubuntu and in Windows with no extra software.

The installer installs `solaar`. It is needed only to pair a device, once per receiver:

```bash
solaar pair
```

Hold the Easy-Switch key for 3 seconds, type the shown code on the keyboard and press Enter. `solaar show` lists the paired devices; its `Change Host` field tells which Easy-Switch slot is active.

### Clipboard

The Linux `developer` profile installs `wl-clipboard`, which provides `wl-copy`
and `wl-paste`. Helix uses these commands for the system clipboard on Wayland;
the `tmux-yank` plugin also supports `wl-copy` for copying terminal text.

### PaperWM

Scrolling columns inside GNOME, as a trial before Niri. Install once, then log in again:

```bash
gnome-extensions install --force paperwm@paperwm.github.com.shell-extension.zip
```

The zip comes from <https://extensions.gnome.org/extension/6099/paperwm/>. Switch with `paperwm-toggle on` and `paperwm-toggle off`; `off` re-enables Ubuntu Tiling Assistant. Only one of the two is active at a time.

## herdr Server Service

`systemd/user/herdr.service` runs the herdr server as a systemd user service. It is not a stow package: systemd rejects a unit file that stow links with a relative path. The installer does not enable it. Enable it once per machine with systemd's own link method:

```bash
systemctl --user enable --now "$HOME/dev/dotfiles/systemd/user/herdr.service"
loginctl enable-linger "$USER"
```

Lingering starts the service at boot, before login. Check with `herdr status` and `systemctl --user is-enabled herdr.service`.

## T3 Code Server Service

A host that runs T3 Code as a systemd user service (`t3 service install`, as on Omen) starts its server with the bare system PATH. T3's agent sessions still get the login PATH, but the server's own Forgejo pull request reader cannot start `fj`. `systemd/user/t3code.service.d/path.conf` puts the mise shims first on the service PATH. It is a drop-in for the unit that `t3 service install` writes, so T3 updates keep it. The installer does not install it. Link it once per machine and restart T3 while no thread is running, because a restart stops running turns:

```bash
mkdir -p "$HOME/.config/systemd/user/t3code.service.d"
ln -sf "$HOME/dev/dotfiles/systemd/user/t3code.service.d/path.conf" "$HOME/.config/systemd/user/t3code.service.d/path.conf"
systemctl --user daemon-reload && systemctl --user restart t3code.service
```

Check that the service PATH starts with the mise shims: `systemctl --user show t3code.service -p Environment`. The T3 desktop app on GEEKOM needs no drop-in, because it prepares the login PATH for its own server. That login PATH names fixed mise version folders, so each provider's Binary path must point at its mise shim; see [Agent CLIs: one copy, one updater](../README.md#5-agent-clis-one-copy-one-updater). The Mac mini's T3 service already has the shims on its PATH.

### Forgejo pull requests in T3

T3 reads Forgejo pull requests with the login stored by `fj` (`~/.local/share/forgejo-cli/keys.json`; on macOS `~/Library/Application Support/forgejo-cli.forgejo-cli/keys.json`). It matches the repository's remote host against that login and its `aliases`. Xpando remotes use the SSH name `forgejo`, so the file needs the alias `"forgejo": "git.xpando.ai"`; without it T3 falls back to `tea` and reports "Install Forgejo CLI". The `fj` login on every machine is `lead-agent`, from `~/.config/xpando-agents/lead-agent/forgejo-token`. Check with `fj --host git.xpando.ai whoami`.
