# Temporary storage on Linux development hosts

Ubuntu's systemd configuration can mount `/tmp` as tmpfs, limited by RAM and a
per-user quota. Large dependency builds can exhaust that quota while the SSD has
plenty of free space. Icon loaders and other desktop processes also need `/tmp`.

For GEEKOM and Omen, use the root SSD for `/tmp` after a reboot:

```bash
cd ~/dev/dotfiles
sudo bash scripts/prepare-ssd-temp-linux.sh --apply
```

This explicit host action is separate from application profiles. It:

- Adds `/swap-extra.img`, a 32 GiB swap file, and registers it in `/etc/fstab`.
- Preserves the existing swap file.
- Backs up `/etc/fstab` under `/var/lib/local-temp-setup/`.
- Sets the underlying `/tmp` directory to mode `1777`.
- Masks `tmp.mount` without stopping its current mount.
- Leaves applications and temporary files running until the operator reboots.

After reboot, `findmnt -T /tmp` should report the SSD root filesystem rather than
tmpfs. `/tmp` then shares the root filesystem's free space; it has no separate
tmpfs user quota. Swap remains available for memory pressure. Large files are
written directly to the SSD instead of competing with applications for RAM.

Do not unmount a live desktop's `/tmp`, clear it wholesale, or replace it during a
session. Applications can hold sockets and open files there. The script does not
reboot the host. Review `findmnt --verify` warnings before arranging a reboot.

To restore RAM-backed `/tmp` at a future reboot, run `sudo systemctl unmask
tmp.mount` and inspect the distribution's unit. Removing swap requires a separate
memory-capacity check before `swapoff`; it is not part of this script.
