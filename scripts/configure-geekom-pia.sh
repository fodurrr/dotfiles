#!/bin/bash
# Explicit local configuration, after installing the geekom-vpn profile.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
if [[ "$(hostname)" != geekom-a8-max ]]; then
    echo 'This configuration is for geekom-a8-max only.' >&2
    exit 1
fi
if [[ ! -x /usr/lib/firefox/firefox-bin || ! -x /usr/bin/qbittorrent || ! -x /opt/piavpn/bin/piactl ]]; then
    echo 'Install the geekom-vpn profile first.' >&2
    exit 1
fi
if pgrep -x qbittorrent >/dev/null; then
    echo 'Close qBittorrent before changing its binding.' >&2
    exit 1
fi
state="$HOME/.local/state/geekom-pia"
mkdir -p "$state" "$HOME/.local/bin" "$HOME/.local/share/applications"
chmod 700 "$state"
stamp=$(date +%Y%m%dT%H%M%S)
umask 077
/opt/piavpn/bin/piactl -u dump daemon-settings > "$state/settings.$stamp.json"
jq '{allowLAN:true,defaultRoute:false,routedPacketsOnVPN:false,method:"wireguard",killswitch:"off",splitTunnelEnabled:true,splitTunnelDNS:true,
splitTunnelRules: ((.splitTunnelRules | map(select(.path | startswith("/snap/firefox/") | not))) +
[{path:"/usr/lib/firefox/firefox",mode:"include"},{path:"/usr/lib/firefox/firefox-bin",mode:"include"},{path:"/usr/bin/qbittorrent",mode:"include"},{path:"/usr/sbin/tailscaled",mode:"exclude"}] | reverse | unique_by(.path)),
bypassSubnets: ((.bypassSubnets + [{subnet:"100.64.0.0/10",mode:"exclude"},{subnet:"fd7a:115c:a1e0::/48",mode:"exclude"},{subnet:"10.0.1.0/24",mode:"exclude"}]) | unique_by(.subnet))}' \
    "$state/settings.$stamp.json" > "$state/desired.json"
/opt/piavpn/bin/piactl -u applysettings "$(cat "$state/desired.json")"
/opt/piavpn/bin/piactl background enable

config="$HOME/.config/qBittorrent/qBittorrent.conf"
mkdir -p "$(dirname "$config")"
if [[ -f "$config" ]]; then cp -p "$config" "$state/qBittorrent.$stamp.conf"; fi
python3 - "$config" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = p.read_text().splitlines() if p.exists() else []
for section, values in {
    '[BitTorrent]': {'Session\\Interface':'wgpia0', 'Session\\InterfaceName':'wgpia0'},
}.items():
    if section not in lines:
        lines += ['', section]
    start = lines.index(section) + 1
    end = next((i for i in range(start, len(lines)) if lines[i].startswith('[')), len(lines))
    for key, value in values.items():
        index = next((i for i in range(start, end) if lines[i].startswith(key+'=')), None)
        if index is None:
            lines.insert(end, key+'='+value)
            end += 1
        else:
            lines[index] = key+'='+value
p.write_text('\n'.join(lines).strip()+'\n')
PY

for name in firefox-pia qbittorrent-pia; do
    install -m 755 "$root/scripts/local-bin/$name" "$HOME/.local/bin/$name"
done
write_launcher() {
    local file="$1" name="$2" binary="$3" icon="$4" mimetypes="$5"
    if [[ -e "$file" ]]; then cp -p "$file" "$state/$(basename "$file").$stamp"; fi
    printf '[Desktop Entry]\nType=Application\nName=%s\nExec="%s" %%U\nIcon=%s\nTerminal=false\nCategories=Network;\nMimeType=%s\n' \
        "$name" "$HOME/.local/bin/$binary" "$icon" "$mimetypes" > "$file"
    chmod 644 "$file"
}
write_launcher "$HOME/.local/share/applications/firefox.desktop" 'Firefox (PIA VPN)' firefox-pia firefox 'text/html;x-scheme-handler/http;x-scheme-handler/https;'
write_launcher "$HOME/.local/share/applications/org.qbittorrent.qBittorrent.desktop" 'qBittorrent (PIA VPN)' qbittorrent-pia qbittorrent 'application/x-bittorrent;x-scheme-handler/magnet;'
# Hide the unprotected Snap menu entry. Its package and profile remain intact.
snap_entry="$HOME/.local/share/applications/firefox_firefox.desktop"
if [[ -e "$snap_entry" ]]; then cp -p "$snap_entry" "$state/firefox_firefox.desktop.$stamp"; fi
printf '[Desktop Entry]\nType=Application\nName=Firefox\nHidden=true\n' > "$snap_entry"
chmod 644 "$snap_entry"
update-desktop-database "$HOME/.local/share/applications"
xdg-mime default org.qbittorrent.qBittorrent.desktop application/x-bittorrent
xdg-mime default org.qbittorrent.qBittorrent.desktop x-scheme-handler/magnet

sudo install -m 755 "$root/scripts/local-bin/pia-tailscale-routes" /usr/local/sbin/pia-tailscale-routes
sudo install -m 644 "$root/systemd/system/geekom-pia-tailscale.service" /etc/systemd/system/geekom-pia-tailscale.service
sudo systemctl daemon-reload
sudo systemctl enable --now geekom-pia-tailscale.service
echo 'Firefox and qBittorrent are configured for PIA; Tailscale routes have a persistent exception.'
echo "Settings backups: $state. Verify VPN-connected and disconnected behavior after updates."
