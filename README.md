# Gluon-Patches: Hardware

*Patches for Gluon v2025.1.x / OpenWrt 24.10 that add devices and targets or
fix single devices and their drivers. Used by Freifunk im Neanderland
(Neanderfunk). Each script can be used on its own; `apply.sh` applies all of
them in order.*

Zusätzliche Geräte und Targets für Gluon, Korrekturen an einzelnen Geräten
und an Treibern bestimmter Chips. Nichts davon hängt an den Paketen oder der
Site-Konfiguration von Neanderfunk.

Die Zweige folgen Gluon: dieser Zweig `v2025.1.x` passt zu Gluon v2025.1.x
(OpenWrt 24.10, Kernel 6.6); `v2023.2.x` zu Gluon v2023.2.x (OpenWrt 23.05,
Kernel 5.15).

## Zweig v2021.1.x

Dieser Zweig passt zu **Gluon v2021.1.x (OpenWrt 19.07, Kernel 4.14)** und
dient der Sackgasse für 4/32-Geräte (FirmwareConfigs `v2021.x`, Plan dort in
`docs/ueberarbeitung-2026.md`). Aus `v2025.1.x` ist nur übernommen, was auf
ar71xx passt.

| Skript | Phase | Zweck | Herkunft |
| --- | --- | --- | --- |
| `kernel/ag71xx-rx-ring-no-bug.sh` | post-update | ag71xx im ar71xx-Treiber: kein `BUG()`, wenn der RX-Ring unter RAM-Druck leerläuft; der Treiber nimmt seinen OOM-Rückweg (oom_timer) | Port von `v2025.1.x` `kernel/950-…` (Befund Archer C25); 19.07 hat dieselbe Assertion (`ag71xx_main.c:1094`), fuzz 0 gegen OpenWrt `1da2e82c11`, kein Gluon-Patch berührt die Datei |
| `kernel/ath9k-rxbuf-128.sh` | post-update | ath9k: `ATH_RXBUF` 128 statt 256 (ändert OpenWrts `511-ath9k_reduce_rxbuf`). Am WR841N v9 belegt ath9k ~1,55 MB schon beim Laden; spart grob 0,7 MB. Risiko: früher RX-Überlauf bei Spitzen | Messung Packages-Session, Entscheidung adorfer (WLAN-Puffer kleiner) |
| `security/kernel-backports.sh` | post-update | Sicherheits-Backports, kopiert nach `openwrt/`: mac80211 900-903 (Mesh-CSA-NULL-Deref über Funk CVE-2026-23279/-23396, CSA nur von der eigenen Mesh, PREQ-Leak CVE-2024-40942; 900 nie ohne 903), zsmalloc-Race (CVE-2022-49554), l2tp Control-Buffer beim Senden leeren, ag71xx NAPI-Interrupts während probe aus. Zusammen etwa +0,3 KiB | Recherche router-werkstatt `docs/recherche-19.07/`; Backports mit Original-Commit im Kopf, fuzz 0 in OpenWrt-Reihenfolge, Kompilierprobe gcc 7.5.0 |

Geplant: WR841N/ND 8M/16M (bisher `patches/0001-…` in FirmwareConfigs
`v2021.x`).
