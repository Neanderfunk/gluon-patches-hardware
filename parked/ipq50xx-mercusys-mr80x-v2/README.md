# Mercusys MR80X v2 / MR3000X v2.0 (qualcommax-ipq50xx), geparkt

Backport des OpenWrt-Subtargets `qualcommax/ipq50xx` (Qualcomm IPQ5018) mit
dem Mercusys MR80X v2 auf Gluon v2025.1.x (OpenWrt 24.10, Kernel 6.6).
Gluon 2025.1 kennt ipq50xx nicht; in OpenWrt kam der MR80X v2 am 02.10.2026
nach main (938f67a519, PR #24919), dort mit Kernel 6.18.

**Geparkt:** Die Serie steht nicht in `apply.sh` und wirkt auf keinen Bau.
Sie ändert neben dem neuen Target auch Pakete, die andere Targets mitbauen
(mac80211/ath11k, qca-ssdk, qca-nss-dp, rtl8365mb, ath11k-firmware). Vor dem
Aktivieren muss ein Bau der übrigen qualcommax-Targets (ipq807x) zeigen, dass
dort nichts kippt.

## Gerät

- IPQ5018 (2x Cortex-A53), 256 MiB RAM, 128 MiB SPI-NAND, Switch RTL8367S
  per SGMII, WLAN IPQ5018 (2.4 GHz) und QCN6122 (5 GHz), beide 802.11ax.
- MR3000X v2.0 ist dasselbe Board. Gluon-Name `mercusys-mr80x-v2`, Alias
  `mercusys-mr3000x-v2`. Das factory.bin trägt beide SupportList-Einträge.
- Erstinstallation über die Stock-Weboberfläche (Erweitert > System >
  Firmware-Upgrade > Lokales Upgrade). Die U-Boot-Web-Recovery nimmt nur
  RSA-signierte Herstellerfirmware.

## Inhalt

`openwrt.sh` (pre-update) legt `0001` bis `0044` als
`patches/openwrt/5700-hw-ipq50xx-*` ab, `targets.sh` (post-update) legt
`targets/qualcommax-ipq50xx` an und trägt es in `targets/targets.mk` ein.

| Nr. | Inhalt |
| --- | --- |
| 0001-0005 | qca-ssdk und qca-nss-dp für IPQ50xx, Subtarget ipq50xx |
| 0006-0011 | QPIC-SPI-NAND-Treiber und Fixes |
| 0012-0018 | base-files, uboot-envtools, Q6-Remoteproc-Fixes, bootconfig |
| 0019, 0022-0029, 0038 | ath11k: QCN6122, IPQ5018-Fixes |
| 0020-0021 | `kmod-dsa-rtl8365mb` und SGMII für den RTL8367S (Upstream 0b577e2fe06c, an 6.6 angepasst) |
| 0030-0032 | `kmod-ath11k-smallbuffers` |
| 0033-0037 | ath11k-Firmware, Board-Dateien |
| 0039-0042 | fwup-Image, MR80X v2, WLAN an, factory.bin auch für MR3000X |
| 0043 | nvmem-Kern: Bit-Offsets über einem Byte (Upstream 7a06ef75107799675ea6e4d73b9df37e18e352a8, v6.15) |
| 0044 | qca-ssdk: UNIPHY-Kanal 0 nach dem Port-Reset erzwungen lassen |

Die Upstream-Commits sind mit Autor und Text übernommen. Was für 6.6
angepasst wurde, steht jeweils in einem `[Neanderfunk: ...]`-Absatz am Ende
der Commit-Nachricht.

### 0043 und 0044: zwei Fehler, die nur unter 6.6 auftreten

- **0043:** Stable 6.6.151 hat schon "nvmem: qfprom: switch to 4-byte aligned
  reads", aber nicht den passenden Fix im nvmem-Kern. Jede qfprom-Zelle, die
  nicht an einer durch 4 teilbaren Adresse beginnt, liest dann 0. Beim
  IPQ5018 trifft das die tsens-Kalibrierung: Sensor 3 meldet über 700 °C,
  der Kernel schaltet 1,5 s nach jedem Start wegen Übertemperatur ab
  (Bootschleife).
- **0044:** qca-ssdk setzt bei `forced-speed` das Force-Bit des UNIPHY-Kanals
  vor einem Port-Reset; danach steht der Kanal wieder auf Autonegotiation.
  Der RTL8367S sendet keine, der Kanal bekommt nie Link, und zwischen eth0
  und Switch geht kein Rahmen durch, obwohl beide Seiten "Link up" melden.

## Stand (Test Neanderfunk, 17.10.2026, MR3000X v2.0)

Startet vom Flash, Ethernet (LAN, WAN per DHCP) und beide Radios laufen,
Mesh und VPN stehen. Gemessen unter Gluon mit vollem Mesh:

| Strecke | Durchsatz |
| --- | ---: |
| 5 GHz Client (80 MHz, VHT-MCS 9, NSS 2), hoch / runter | 340 / 208 Mbit/s |
| 2.4 GHz Client (MCS 15), hoch / runter | 46 / 75 Mbit/s |
| 802.11s direkt zu einem Nachbarn, 5 GHz, senden / empfangen | 141 / 444 Mbit/s |
| 802.11s direkt zu einem Nachbarn, 2.4 GHz, senden / empfangen | 148 / 106 Mbit/s |

Speicher: in Ruhe rund 64 MB verfügbar, unter Volllast 31 bis 34 MB.
**`kmod-ath11k-smallbuffers` ist Pflicht:** Mit dem normalen `kmod-ath11k`
läuft das Gerät nach 96 s in den OOM (Kernel-Panic durch `panic_on_oom`),
schon ohne Last.

Offen:

- batman meldet an der Mesh-on-LAN-Brücke eine MTU von 1500.
- Ein Bau der übrigen qualcommax-Targets mit dieser Serie steht aus.

## Aktivieren

1. In `apply.sh` `parked/ipq50xx-mercusys-mr80x-v2/openwrt.sh` unter
   `PRE_UPDATE` und `parked/ipq50xx-mercusys-mr80x-v2/targets.sh` unter
   `POST_UPDATE` eintragen (oder das Verzeichnis nach `devices/` ziehen).
2. Im Neanderfunk-Bau das Target `qualcommax-ipq50xx` aufnehmen.
