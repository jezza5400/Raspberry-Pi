# Linux Networking Reference Sheet

Diagnosing connectivity issues + WiFi connection methods (nmcli, iwctl, wpa_supplicant, mmcli)

---

## 1. Diagnostic Flow (top-down, layer by layer)

Always check in this order - it tells you exactly where the break is.

| Step | Command | What you're checking |
| --- | --- | --- |
| 1. Link/association | `ip link show wlan0` (look for `state UP`) | Is the radio even connected to the AP? |
| 2. IP address | `ip addr show wlan0` | Did you get a real IP (not `169.254.x.x`)? |
| 3. Routing table | `ip route show` | Is there exactly ONE `default via ...` line? |
| 4. Gateway reachability | `ping -c3 <gateway>` | Can you reach your own router/AP? |
| 5. External reachability | `ping -c3 1.1.1.1` | Does the gateway route you out to the internet? |
| 6. DNS | `ping -c3 google.com` + `cat /etc/resolv.conf` | Is name resolution broken specifically? |

**Rule of thumb:** each failed step tells you the category of problem (see table below).

---

## 2. Common Issues → Diagnosis → Fix

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| No `inet` line in `ip addr` / only `169.254.x.x` | DHCP failed or nothing is requesting a lease | See §3 "Force a fresh DHCP lease" |
| Multiple/duplicate `default via` routes | Two network managers fighting over the interface (e.g. dhcpcd + NetworkManager, or NM + iwd both writing routes) | `ip route flush dev wlan0`, kill the redundant daemon, re-request lease (see §4) |
| Can ping gateway, not 1.1.1.1 | Gateway not routing you out - captive portal, VLAN not assigned yet, AP hasn't fully authorized MAC | Open a browser (captive portal?), re-auth, check AP/VLAN config |
| Can ping 1.1.1.1, not google.com | DNS broken | Check `/etc/resolv.conf`, try `resolvectl status`, manually set `nameserver 1.1.1.1` |
| Associates but never gets IP at all | iwd is handling L2 but nothing is doing DHCP (iwd doesn't do DHCP itself unless configured to) | Enable iwd's built-in DHCP (`EnableNetworkConfiguration=true` in `/etc/iwd/main.conf`) or run dhcpcd/networkd alongside it |
| `iwctl` connect returns "Not configured" | No matching `.8021x`/`.psk` provisioning file, or SSID name/case mismatch | Check `/var/lib/iwd/<SSID>.8021x` exists and SSID matches exactly (case-sensitive) |
| Wifi connects then drops repeatedly | Power management killing the interface | `iw wlan0 set power_save off` or disable in NM: `nmcli connection modify <conn> 802-11-wireless.powersave 2` |
| Two backends both "managing" wlan0 | NetworkManager and iwd (or wpa_supplicant) both active | Pick ONE. `nmcli device set wlan0 managed no` to hand off to iwd, or stop iwd if using NM |
| Works on ethernet, not wifi | Isolate to wifi-specific issue - check `rfkill list` for a soft/hard block | `rfkill unblock wifi` |

---

## 3. Force a Fresh DHCP Lease

```bash
# dhcpcd
sudo dhcpcd -k wlan0      # kill existing lease
sudo dhcpcd wlan0         # request new one

# systemd-networkd
sudo networkctl reconfigure wlan0

# NetworkManager
sudo nmcli device reapply wlan0
# or nuke it:
sudo nmcli connection down "<conn-name>" && sudo nmcli connection up "<conn-name>"
```

---

## 4. Clearing Duplicate/Broken Routes

```bash
sudo ip route flush dev wlan0

# if duplicates keep coming back, find who's re-adding them:
ps aux | grep -E 'dhcpcd|NetworkManager|networkd|iwd'

# kill the one you don't want managing wlan0, THEN:
sudo ip route flush dev wlan0
sudo dhcpcd wlan0   # or nmcli/networkctl equivalent
```

---

## 5. Ways to Connect to WiFi

### A. `nmcli` (NetworkManager)

```bash
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASSWORD"

# WPA-Enterprise (PEAP/MSCHAPv2):
nmcli connection add type wifi ifname wlan0 con-name "corp" ssid "SSID"
nmcli connection modify "corp" \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap peap \
  802-1x.phase2-auth mschapv2 \
  802-1x.identity "username" \
  802-1x.password "password"
nmcli connection up "corp"
```

Good for: most desktop distros, easiest enterprise auth setup.

### B. `iwctl` (iwd)

```bash
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect "SSID"          # prompts for PSK

# WPA-Enterprise: needs a provisioning file first
# /var/lib/iwd/SSID.8021x
[Security]
EAP-Method=PEAP
EAP-Identity=username@domain
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=username
EAP-PEAP-Phase2-Password=password

iwctl station wlan0 connect SSID
```

Good for: lightweight setups, headless boxes, Arch minimal installs. Note: **doesn't do DHCP on its own** by default - enable `EnableNetworkConfiguration=true` in `/etc/iwd/main.conf`, or pair with dhcpcd/networkd.

### C. `wpa_supplicant` (low-level, manual)

```bash
wpa_passphrase "SSID" "PASSWORD" | sudo tee /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
sudo dhcpcd wlan0
```

Good for: minimal/embedded systems, or when debugging what NM/iwd are doing under the hood (they both use wpa_supplicant/iwd's own supplicant internally).

### D. `mmcli` (ModemManager - mobile broadband)

Used for cellular modems (USB dongles, laptop LTE/5G modems):

```bash
mmcli -L                          # list modems
mmcli -m 0                        # modem details
mmcli -m 0 --simple-connect="apn=your.apn"
```

Only relevant if the "wifi issue" is actually a confused mobile broadband interface.

### E. Network Manager TUI (`nmtui`)

```bash
sudo nmtui
```

Menu-driven wrapper around nmcli - handy for headless boxes over SSH when you don't want to remember flags.

---

## 6. Backend Conflict Rule

**Only one thing should manage wlan0 at a time.** The most common root cause of "connected but broken" is two of these running simultaneously:

- NetworkManager
- iwd (as NM's backend OR standalone)
- wpa_supplicant (standalone)
- dhcpcd / systemd-networkd

Check what's active:

```bash
systemctl status NetworkManager iwd wpa_supplicant systemd-networkd 2>/dev/null | grep -E "●|Active"
```

To let iwd run standalone (NM hands off L2 but not IP config):

```bash
sudo nmcli device set wlan0 managed no
```

Then iwd needs `EnableNetworkConfiguration=true` (or a separate DHCP client) to actually get you an IP - this is the #1 gotcha in that setup.

---

## 7. Quick One-Liners Worth Keeping

```bash
rfkill list                          # check for soft/hard wifi blocks
ip -s link show wlan0                # packet counters - errors/drops?
iw dev wlan0 link                    # signal strength, connected AP
journalctl -u NetworkManager -b      # NM logs since boot
journalctl -u iwd -b                 # iwd logs since boot
nmcli general logging level DEBUG    # verbose NM debugging
```
