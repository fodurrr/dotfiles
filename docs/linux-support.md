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

`yq` is validated for TOML support (`-p toml`). If distro `yq` is incompatible, the installer falls back to the mikefarah binary.

## Linux Layer Behavior

Linux package installs are driven by `apps.toml` metadata for `type = "brew"` entries:

- `linux_name`: common Linux package name
- `linux_apt`: apt override
- `linux_dnf`: dnf override

If an app is selected for Linux but has no mapping (or the package is unavailable), it is skipped with an explicit message.

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

## Validation

Run Linux-focused assertions:

```bash
./scripts/test-linux.sh
```

This validates:

- platform filtering (`ghostty` false on Linux, `starship` true)
- Linux package mapping presence
- Linux bootstrap branch behavior (no `brew` calls in Linux bootstrap function)
- macOS-only guardrails for post-install steps

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
