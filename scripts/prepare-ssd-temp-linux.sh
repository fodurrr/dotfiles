#!/bin/bash
# Opt-in host storage preparation. Never unmount a running desktop's /tmp.
set -euo pipefail

if [[ "${1:-}" != "--apply" || "$#" -ne 1 ]]; then
    echo "Usage: sudo bash $0 --apply"
    echo "Adds 32 GiB of swap and makes /tmp use the root SSD after a reboot."
    exit 2
fi
if [[ "$EUID" -ne 0 || "$(uname -s)" != Linux ]]; then
    echo "Run this command as root on Linux." >&2
    exit 1
fi

state=/var/lib/local-temp-setup
swap=/swap-extra.img
swap_bytes=34359738368
install -d -m 700 "$state"
backup="$state/fstab.$(date +%Y%m%dT%H%M%S)"
cp -a /etc/fstab "$backup"

if [[ -e "$swap" ]]; then
    if [[ ! -f "$swap" || -L "$swap" || "$(stat -c %s "$swap")" != "$swap_bytes" ]]; then
        echo "Existing $swap is not the expected 32 GiB file; leaving it untouched." >&2
        exit 1
    fi
else
    available_kib=$(df -Pk / | awk 'END {print $4}')
    if [[ "$available_kib" -lt 54525952 ]]; then
        echo "At least 52 GiB free on / is required before adding swap." >&2
        exit 1
    fi
    (umask 077; fallocate -l "$swap_bytes" "$swap")
    chmod 600 "$swap"
    mkswap "$swap"
fi
if ! awk -v path="$swap" '$1 == path {found=1} END {exit !found}' /proc/swaps; then
    swapon "$swap"
fi
if ! awk -v path="$swap" '$1 == path {found=1} END {exit !found}' /etc/fstab; then
    printf '\n%s none swap sw 0 0\n' "$swap" >> /etc/fstab
fi

# A non-recursive bind exposes the root filesystem's /tmp beneath its live mount.
view=$(mktemp -d "$state/root-view.XXXXXX")
mounted=false
cleanup() {
    if [[ "$mounted" == true ]]; then
        umount "$view"
    fi
    rmdir "$view"
}
trap cleanup EXIT
mount --bind / "$view"
mounted=true
chmod 1777 "$view/tmp"
umount "$view"
mounted=false

# Do not use --now: stopping tmp.mount would disrupt existing processes.
systemctl mask tmp.mount
systemctl daemon-reload
findmnt --verify --tab-file /etc/fstab
swapon --show
findmnt -T /tmp -o TARGET,FSTYPE,OPTIONS
echo "Storage preparation complete. Reboot when convenient to use SSD-backed /tmp."
echo "Existing processes and temporary files were preserved. Backup: $backup"
