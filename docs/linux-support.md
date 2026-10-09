# Linux Support

This repository supports Linux (Ubuntu, Debian, Fedora) with native package managers.

## Strategy

- Linux installs use `apt` (Ubuntu/Debian) or `dnf` (Fedora/RHEL/CentOS).
- Linux bootstrap does **not** install or depend on Homebrew/Linuxbrew.
- macOS keeps the existing Homebrew-based flow.

## Supported Platforms

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

Selected Linux apps come from the active profile's `[linux].apps` list in `profiles/*.toml`.

For selected mapped Linux packages, reruns now re-apply package manager installs to pick up newer repository versions.

If a selected mapped package install/upgrade fails, the Linux layer exits non-zero.

`sheldon` is not available in the default Ubuntu/Fedora repositories. It is installed through mise on macOS and Linux by the `sheldon` entry.

## GUI Apps on Linux

- GUI apps are only automated when a native Linux package mapping exists.
- macOS-only GUI apps are marked `platform = ["macos"]` and are skipped on Linux.
- No Flatpak/Snap fallback is configured in this pass.

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

Selected profile tool failures are treated as fatal in strict mode:

- stow link failures
- selected mise tool install failures
- selected mapped Linux package install/upgrade failures

### Linux Shell Finalization

After install summary, Linux flow ensures zsh is the login shell:

- interactive mode prompts before `chsh`
- `--yes` mode performs non-interactive attempt when possible
- failure to set zsh login shell is treated as install failure with manual remediation command

## Validation

Run Linux-focused assertions:

```bash
./scripts/test-linux.sh
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

## Desktop: Screens, Dictation, PaperWM

Part of the `developer` profile on Linux. The commands are stow links into `desktop-linux/`; the shortcuts are `gnome-shortcut` entries in `apps.toml`.

### Screens

Ubuntu cannot detect a monitor's power button: the screen stays "connected", so windows stay on it. The `screens` command chooses the active screens, and windows move to what remains.

| Key | Command | Result |
|---|---|---|
| Super+Alt+1 | `screens monitor` | only the 49-inch monitor (DP-1) |
| Super+Alt+2 | `screens tv` | only the TV (HDMI-1) |
| Super+Alt+3 | `screens both` | both, monitor left of the TV |

The choice is not persistent: after a restart both screens are on. The connector names, modes and scales are written in `desktop-linux/.local/bin/screens`; change them there for other hardware. The command calls GNOME's `gdctl` with `/usr/bin/python3`, because the mise Python has no `gi` module.

### Dictation (Voxtype)

Hold **F9** to talk; on release the text is pasted at the cursor. **Super+/** starts and stops a recording as a toggle. The config is the stow package `voxtype/`.

The installer installs the `.deb`, `ydotool` and `wl-clipboard` and links the config. These steps stay manual, once per machine:

```bash
sudo voxtype setup onnx --enable
sudo voxtype setup gpu --disable
voxtype setup --download --model parakeet-tdt-0.6b-v3-int8 --activate
systemctl --user enable --now voxtype.service ydotool.service
sudo usermod -aG input "$USER"
```

Then **restart the machine**. A logout is not enough when user lingering is on (it is, for the herdr service): the user service manager keeps the old groups. The `input` group lets programs of this user read all keyboard input and type; that is what hold-to-talk and paste need.

Facts behind the config:

- `setup gpu --disable` selects the ONNX AVX-512 build. `setup onnx --enable` alone picks MIGraphX on an AMD graphics chip, which is not meant for integrated graphics.
- Paste mode with `shift+insert`: GNOME has no virtual-keyboard protocol, so `wtype` cannot work; `ydotool` types US keycodes only, so paste is the layout-independent route.
- The OSD (waveform) is off: it needs layer-shell, which GNOME lacks. A notification at recording start replaces it. On Niri the OSD can be switched on.

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
