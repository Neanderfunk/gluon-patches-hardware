# Gluon-Patches: Hardware

*Patches for Gluon v2023.2.x / OpenWrt 23.05 that add devices and targets or
fix single devices and their drivers. Used by Freifunk im Neanderland
(Neanderfunk). Each script can be used on its own; `apply.sh` applies all of
them in order.*

Zusätzliche Geräte und Targets für Gluon, Korrekturen an einzelnen Geräten
und an Treibern bestimmter Chips. Nichts davon hängt an den Paketen oder der
Site-Konfiguration von Neanderfunk.

Die Zweige folgen Gluon: `v2023.2.x` passt zu Gluon v2023.2.x (OpenWrt 23.05,
Kernel 5.15).

## Anwenden

Alles auf einmal, aus dem Gluon-Verzeichnis:

```
cd gluon
<dieses Repo>/apply.sh pre-update
make update
<dieses Repo>/apply.sh post-update
```

`pre-update` legt Dateien unter `patches/openwrt` bzw. `patches/packages` im
Gluon-Baum ab, die `make update` einspielt. Alles andere läuft danach, weil
`make update` die Module neu aufsetzt.

Einzeln: das Skript samt seiner Patchdateien und `lib-patch.sh` kopieren,
Struktur `<gruppe>/…` und `lib-patch.sh` eine Ebene darüber beibehalten, und
aus dem Gluon-Verzeichnis aufrufen, etwa `cd gluon && <repo>/kernel/ag71xx-rx-ring-no-bug.sh`.
Die Skripte sind idempotent: Ist ein Patch schon drin, melden sie das und
machen weiter. Scheitert einer, brechen sie mit Fehler ab.

## Inhalt

| Skript | Phase | Zweck | Herkunft, Ende |
| --- | --- | --- | --- |
| `devices/add-lantiq-xrx200-devices.sh` | pre-update | AVM FRITZ!Box 7430 und 3390, mit OpenWrt-Patch (ath9k-Kalibrierdaten 7430) | |
| `device-fixes/mi4apatch.sh` | post-update | Mi Router 4A Gigabit sysupgrade-fähig | |
| `devices/add-totolink-x5000r.sh` | post-update | Totolink X5000R | |
| `devices/add-mercusys-mr90x.sh` | post-update | MERCUSYS MR90X | |
| `devices/add-dlink-m30.sh` | post-update | D-Link AQUILA PRO AI M30 A1, ohne Recovery-Image | Gluon 2025.1 kennt das Gerät |
| `device-fixes/fix-xiaomi-ax6s-bootflags.sh` | post-update | Xiaomi Redmi AX6S: Boot-Flags bestätigen, kein Rückfall auf Stock | |
| `devices/add-nanopi-r2c.sh` | post-update | FriendlyElec NanoPi R2C | |
| `devices/add-cudy-3000.sh` | post-update | Cudy-3000-Serie im Target mediatek-filogic | |
| `targets/additionaltargets.sh` | post-update | zusätzliche Targets und Geräte aus OpenWrt, die Gluon 2023.2 nicht baut | |
| `devices/add-cellular.sh` | post-update | Mobilfunkgerät ZTE MF286R | |
| `network/interfaces-patch.sh` | post-update | primäre MACs und Schnittstellenzuordnung für die zusätzlichen Geräte | |
| `kernel/revert-mips-tlb-uniquify.sh` | post-update | MIPS: `r4k_tlb_uniquify()` zurücknehmen (Kaltstart-Hänger 74Kc) | entfällt ab Kernel 5.15.209, Gluon v2023.2.x seit 22.09.2026 |
| `kernel/rtl8221b-skip-mmd30.sh` | post-update | beim PHY-Scan MMD 30 des RTL8221B nicht lesen; sonst ist der 2,5G-Port tot, wenn beim Booten ein Kabel steckt (Cudy TR3000/WR3000H) | Backport OpenWrt 88dcd8c |
| `kernel/mt7530-phy-disable-eee.sh` | post-update | EEE am MT7530-PHY aus (Switch des MT7621): sonst Link-Schleifen an 2-paarigen Kabeln und instabile 100-Mbit-Links | Nachbau OpenWrt PR #25058 für 5.15 |
| `kernel/ag71xx-rx-ring-no-bug.sh` | post-update | ag71xx: kein `BUG()` bei leerem RX-Ring (RAM-Druck) | |

Nicht angewendet:

| Pfad | Inhalt |
| --- | --- |
| `parked/squashfs-blocksize-per-device.sh` | squashfs-Blockgröße je Gerät (vorbereitet, nicht aktiv) |
| `parked/cudy-rtl8221b-irq-parent.sh` | TR3000/M3000: `interrupt-parent = <&pio>` für den 2,5G-PHY (Backport OpenWrt 82b69df); geparkt, siehe Patchkopf |
| `experiments/mips-tlb-arm-e/` | Backport der TLB-Korrektur aus 5.15.209 als Alternative zu `revert-mips-tlb-uniquify.sh`; Messergebnis in der README dort |

## Abhängigkeiten

* `devices/add-dlink-m30.sh` setzt auf `devices/add-mercusys-mr90x.sh` auf
  (derselbe Block in `targets/mediatek-filogic`).
* `devices/add-totolink-x5000r.sh` und `targets/additionaltargets.sh` fassen
  beide `targets/ramips-mt7621` an; `apply.sh` hält die Reihenfolge ein.
* `experiments/mips-tlb-arm-e` und `kernel/revert-mips-tlb-uniquify.sh`
  schließen sich aus.
* Die übrigen Skripte sind voneinander unabhängig.

## Herkunft und Lizenz

Herausgelöst aus Neanderfunk/FirmwareConfigs (bis September 2026
Neanderfunk/firmware), Stand `851194f217a7fb165d101ed9c7b12a2597a9029e`,
Verzeichnis `patches/`. Die Geschichte der einzelnen Dateien steht dort.

`lib-patch.sh` ist eine Kopie; jedes Patch-Repo trägt seine eigene, damit es
allein nutzbar bleibt.

Skripte (`apply.sh`, `lib-patch.sh`, `*/*.sh`): BSD-3-Clause, siehe
`LICENSE`. Patchdateien stehen unter der Lizenz des Projekts, das sie
ändern: Gluon BSD-2-Clause, OpenWrt und Linux GPL-2.0.
