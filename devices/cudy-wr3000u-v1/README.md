# Cudy WR3000U v1

Backport aus OpenWrt 25.12 fuer Gluon v2025.1.x (OpenWrt 24.10). openwrt.sh
(pre-update) legt die OpenWrt-Commits unter patches/openwrt ab, targets.sh
(post-update) traegt das Geraet in Gluon ein. Uebersicht und Pruefungen:
../neue-geraete-2026-10.md.


**Quellen** **[geprüft]**: b9d7b448c (main), 95dec97d08 (25.12, noch in keinem Release-Tag). Die DTS
bindet `mt7981b-cudy-wbr3000uax-v1.dtsi` ein, die es in 24.10 nicht gibt.
Deshalb als 0001 der WBR3000UAX v1 (d7d6faf26f, main; 2a78fc851c, 25.12):
bringt die .dtsi und das Label `ubi:` in `mt7981b-cudy-wr3000-nand.dtsi`.
Die ubootmod-Variante (15df98f3b5) und ed40153753 (NMBM nur bei ubootmod)
bleiben draußen. Die WR3000U-DTS setzt die NMBM-Properties selbst, dieselben
Werte wie die 24.10-nand.dtsi, also doppelt aber gleich **[geprüft]** (dtb).

Angepasst: Kontexte in 01_leds, 11_fix_wifi_mac, filogic.mk; die .dtsi aus
main (dort ohne Leerzeichen am Zeilenende). Inhalt sonst gleich upstream
**[geprüft]**.

Gluon: `cudy-wr3000u-v1`, `factory = false`. Kein Eintrag für den WBR3000UAX
(Russland-OEM, nicht gewünscht). Ports: board.d-Default `lan1-4` / `wan`.

**Flashen** (Commit-Text): Cudy-Zwischenfirmware über die Stock-Oberfläche,
dann sysupgrade; oder UART + TFTP. Rückweg per TFTP `recovery.bin`,
192.168.1.88.

