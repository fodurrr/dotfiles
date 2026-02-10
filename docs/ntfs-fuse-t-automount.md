# NTFS FUSE-T Automount (Optional Manual Step)

This capability is intentionally kept outside the dotfiles install flow.
Use it as an optional manual setup when you want robust NTFS read/write behavior on macOS with FUSE-T + ntfs-3g.

## Upstream companion repository

Local path:

- `~/dev/ntfs3g-fuse-t-automount`

That repository contains:
- LaunchDaemon template and installer
- Runtime scripts (`ntfs3g-automount.sh`, `ntfs3g-safe-eject.sh`)
- Operations and troubleshooting docs
- Optional ntfs-3g build patch context

## Why this is docs-only in dotfiles

- It requires root/system launchd changes.
- It is storage-device specific and not needed on every machine.
- Keeping it outside `install.sh` avoids surprising disk/mount side effects.

## Minimal operational commands

```bash
# one-shot run
sudo /usr/local/sbin/ntfs3g-automount.sh

# service status (default label)
sudo launchctl print system/com.ntfs3g.automount | head -n 40

# mount state
mount | grep -E "fuse-t|ntfs" || true
```

## Recommended onboarding flow

1. Set up dotfiles as usual.
2. Clone/use the companion NTFS automount repo.
3. Install and verify there.
4. Keep dotfiles as reference-only for this capability.
