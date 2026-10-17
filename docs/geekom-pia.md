# GEEKOM: Firefox and qBittorrent through PIA

This setup is opt-in for `geekom-a8-max`. Omen and the server profiles do not
include it. Credentials and live PIA/qBittorrent settings are not stowed.

```bash
cd ~/dev/dotfiles
./install.sh --profile=geekom-vpn
bash scripts/configure-geekom-pia.sh
```

The profile installs native Mozilla Firefox, qBittorrent from Ubuntu, and PIA's
official Linux desktop client. The Firefox repository key fingerprint is verified.
APT must replace Ubuntu's higher-epoch Snap transition package with Mozilla's
native package; only this app entry permits that downgrade. The Snap package and
its profile are preserved, but its unprotected menu entry is hidden.

Sign in through the PIA application. Use **Firefox (PIA VPN)** and
**qBittorrent (PIA VPN)** from the application menu. Their launchers require a
connected PIA VPN. Chrome remains the normal browser; its defaults are not changed.

## Network settings

| Setting | Value |
|---|---|
| PIA protocol | WireGuard, interface `wgpia0` |
| PIA all other apps | Bypass VPN |
| Firefox and qBittorrent | Only VPN |
| PIA DNS | Follow app rules |
| PIA kill switch | Off; qBittorrent's own interface binding prevents torrent fallback |
| qBittorrent interface | `wgpia0`, never any interface |
| LAN exception | `10.0.1.0/24` |
| Tailscale exceptions | `100.64.0.0/10`, `fd7a:115c:a1e0::/48` |

`geekom-pia-tailscale.service` installs priority 40 policy rules for Tailscale's
existing routing table 52. PIA's routing rules otherwise run before Tailscale's
default rule, which broke TCP SSH despite `tailscale ping` succeeding.

No custom DNS firewall exception is installed. The temporary exception used while
investigating PIA's global kill switch was removed. Peter chose qBittorrent's own
binding instead, so normal applications remain usable when PIA is disconnected.
Firefox uses PIA while connected but is not guaranteed to stop existing browsing
when PIA disconnects; Peter explicitly accepted this simpler browser behavior.

The configuration uses PIA's documented unstable `applysettings` interface.
Backups are in `~/.local/state/geekom-pia/`. Recheck behavior after PIA, Firefox,
Tailscale, firewall, or operating-system upgrades. A boot check is still required
after GEEKOM's next reboot, including firewall rule ordering.

## Verification and outstanding check

Verified on 2026-10-17:

- The Snap Firefox IP check showed the ISP address despite matching PIA rules.
- Native Firefox's observed IP matched `curl --interface wgpia0`.
- Ordinary `curl` used the ISP address with PIA connected.
- Native Firefox's disconnected blocking was tested during the abandoned always-on
  kill-switch approach. That result does not apply to the final kill-switch-off setup.
- qBittorrent remained in PIA's VPN-only network cgroup during disconnect and is
  bound to `wgpia0` in its saved configuration.
- SSH to Omen succeeds with PIA connected and disconnected.
- Disconnect checks exposed broken normal DNS with the global kill switch enabled.
  That approach and its temporary resolver firewall exception were removed.

With the final kill-switch-off configuration, a controlled disconnect check passed:
qBittorrent stayed running but had no torrent listeners, ordinary internet access
worked, and SSH to Omen worked. After reconnecting, the torrent TCP/UDP listeners
returned on the VPN address with `%wgpia0`, not the physical Ethernet address.
The PIA disconnect command printed `Timed out after 5.001 sec`; subsequent status
confirmed `Disconnected`, and the final status confirmed `Connected` after recovery.

No torrent transfer was started during setup. A real torrent's stop and resume
behavior has not been verified. No GEEKOM reboot was performed.

## Sources

- [PIA split tunneling](https://helpdesk.privateinternetaccess.com/hc/en-us/articles/46814646791707-How-to-Use-the-Split-Tunneling-Feature-on-Desktop)
- [PIA process namespace restriction](https://github.com/pia-foss/desktop/blob/master/kapps_net/src/linux/proc_tracker.cpp)
- [Mozilla native Firefox installation](https://support.mozilla.org/en-US/kb/install-firefox-linux)
- [Tailscale alongside other VPNs](https://tailscale.com/docs/reference/faq/other-vpns)
- [qBittorrent VPN binding](https://github.com/qbittorrent/wiki/blob/master/How-to-bind-your-vpn-to-prevent-ip-leaks.md)
