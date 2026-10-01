# Aruba AP-32x

Backport aus OpenWrt 25.12 fuer Gluon v2025.1.x (OpenWrt 24.10). openwrt.sh
(pre-update) legt die OpenWrt-Commits unter patches/openwrt ab, targets.sh
(post-update) traegt das Geraet in Gluon ein. Uebersicht und Pruefungen:
../neue-geraete-2026-10.md.


**Quellen** **[geprüft]**: main e912d6aeb (falsche Signed-off-Zeile
"Test Dev", deshalb revertiert b85b7fd14c und neu als d2a75029a5), in
openwrt-25.12 als 65f01eb357. Braucht drei Vorgänger: 6ebb080d8c
(rootfs_data auf eigener Partition), 32841c3ed2 (Namenskollision
Kernel-UBI-Volume/MTD), c1096e0e8b (CONFIG_GPIO_WATCHDOG). Optional 4e545bf51e
(Paket `apboot-aruba-ipq806x`). Keiner davon in einem 25.12-Release-Tag (bis
v25.12.5) **[geprüft]**.

**Grundlage**: ffmuc (0014-0018) ist näher an upstream als ffac (0019-0022,
älterer PR-Stand: `reg = <0x00010000 …>` im DTS, kein apboot) **[geprüft]**.
Übernommen: ffmucs 24.10-Diffs mit den Commit-Texten und der vollständigen
Signed-off-by-Kette aus openwrt-25.12. Gegenüber ffmuc geändert:

* uboot-envtools: ffmuc fügt `ignitenet,ss-w2-ac2600` hinzu (gibt es in 24.10
  nicht) und lässt den alten `ap148/db149`-Zweig doppelt stehen. Hier: der
  Zweig wird wie upstream nach oben verschoben, nur `aruba,ap-32x` kommt dazu.
* apboot-Paket (0005) liegt unter `optional/` und wird nicht abgelegt: es holt
  und baut beim Build einen Vendor-U-Boot von GitHub, und Gluon kopiert das
  Artefakt `apboot.mbn` ohnehin nicht. Ohne 0005 fehlen im Device nur
  `UBOOT_PATH`/`ARTIFACTS` und das Paket, das Image ist sonst gleich.

Unterschiede zu upstream: DTS unter `files-6.6/…/qcom/` statt `files-6.12`,
PCIe-Knoten ausgeschrieben statt `&pcie_bridge0/1` (die Labels gibt es in der
6.6-dtsi nicht), `config-6.6`, ipq50xx-Hunk entfällt.

Gluon: `device('aruba-ap-32x', 'aruba_ap-32x', { packages = QCA9980_PACKAGES,
factory = false })` wie Gluon-PR #3829 (3ca558c8, gegen main) **[geprüft]**.
Keine 010/020-Einträge nötig: `label-mac-device = &gmac2`, board.d setzt lan
eth1 / wan eth0 **[geprüft]**.

**Flashen** (Commit-Text): Serial über RJ45 (Cisco-Pinout). Gepatchtes APBoot
per `netget` laden und mit `sf write` nach 0x220000 schreiben; NAND löschen,
`ubi create ubifs 1` und `ubi create rootfs_data`; Initramfs `.ari` per
`tftpboot` booten; dann sysupgrade. Gluon baut nur das sysupgrade-Image, weder
APBoot noch Initramfs (ipq806x ohne `TARGET_ROOTFS_INITRAMFS`) **[geprüft]**.
Beides muss aus einem OpenWrt-25.12-Build kommen (Branch-Snapshot oder selbst
gebaut); von dessen Initramfs aus `sysupgrade -n` auf Gluon **[abgeleitet]**.

**Risiken**:
* QCA9990 (QCA99X0-Familie): laut Gluon-Kommentar in `targets/ipq806x-generic`
  kein 802.11s in der Firmware. Das Gerät meshed also nicht per WLAN, nur
  Client-AP mit Uplink per Kabel/VPN (wie AP3935) **[geprüft]** (Kommentar),
  Auswirkung **[abgeleitet]**.
* 0001/0002 ändern `nand.sh` für **alle** NAND-Geräte. Alle 24.10-Geräte mit
  `CI_ROOT_UBIPART` bekommen `CI_DATA_UBIPART` (filogic AX6000-stock, mvebu
  cortexa9, qualcommax ipq807x ×3); Vollständigkeit per `git grep`
  **[geprüft]**. Bei allen übrigen gilt weiter `CI_UBIPART` wie bisher
  **[abgeleitet]**.

**dwmac1000-Patch von ffmuc** (Zero-UDP6-Checksumme, Gluon #3783): **nicht
nötig**. Betrifft nur VXLAN über IPv6. `mesh.vxlan = false` in allen 87
site.conf **[geprüft]**; der Tunneldigger-Client öffnet nur AF_INET-Sockets
(upstream-Quelle `client/l2tp_client.c`) **[geprüft]**, für die gepinnte
Version **[abgeleitet]**. Wired mesh ohne VXLAN ist batman direkt auf Ethernet,
kein UDP. Der Patch würde zudem jeden stmmac-dwmac1000 treffen (auch Rockchip
R2S/R2C) **[abgeleitet]**.

**Target**: ipq806x-generic steht in targets.conf aktiv, in Gluons
targets.mk außerhalb des BROKEN-Blocks **[geprüft]**.

