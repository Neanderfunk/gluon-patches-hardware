# Cudy AP3000 Wall v1

Backport aus OpenWrt 25.12 fuer Gluon v2025.1.x (OpenWrt 24.10). openwrt.sh
(pre-update) legt die OpenWrt-Commits unter patches/openwrt ab, targets.sh
(post-update) traegt das Geraet in Gluon ein. Uebersicht und Pruefungen:
../neue-geraete-2026-10.md.


**Quelle**: afad4c71f (main), 45788a48c7 (25.12, ab v25.12.0-rc5 in den Releases) **[geprüft]**. Einzige
Anpassung: `#include "mt7981.dtsi"` statt `mt7981b.dtsi` (24.10-Name)
**[geprüft]**.

Gluon: `cudy-ap3000-wall-v1` (Modell "Cudy AP3000 Wall v1"), `factory = false`.

**Flashen** (Commit-Text): Cudy-Zwischenfirmware über die Stock-Weboberfläche,
danach sysupgrade. Rückweg: TFTP-Server 192.168.1.88, `recovery.bin`, Reset
beim Einschalten halten.

**Offen**:
* board.d setzt nur `lan1 … lan5` ohne WAN. Gluon macht daraus eine
  `single`-Schnittstelle mit Rolle uplink auf allen fünf Ports **[abgeleitet]**
  aus 020-interfaces. Welcher Port PoE-In ist, steht nicht im Commit. Wenn
  bekannt: 020-interfaces-Eintrag wie beim EAP615-Wall (wan = PoE-In, lan =
  Rest).
* PoE-Passthrough: DTS exportiert GPIO 12 als `poe-passthrough` mit Startwert 0,
  aber ohne `03_gpio_switches`-Eintrag gibt es kein `system.poe_passthrough`,
  Gluons `poe_passthrough = true` wirkt also nicht (Passthrough bleibt aus)
  **[abgeleitet]**; upstream ebenso (main hat keinen Eintrag) **[geprüft]**.

