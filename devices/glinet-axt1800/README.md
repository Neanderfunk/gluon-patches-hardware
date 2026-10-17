# GL.iNet GL-AX1800 / GL-AXT1800 (qualcommax-ipq60xx)

Backport der GL.iNet-Geräte des OpenWrt-Subtargets `qualcommax/ipq60xx`
(Qualcomm IPQ6000) auf Gluon v2025.1.x (OpenWrt 24.10, Kernel 6.6). Das
Subtarget gibt es in 24.10 schon (Mango-DVK, XE3-4, WAX214, FAP650), die
GL.iNet-Geräte nicht: Der Commit c3f2bb7afc (PR #14950) kam erst am
24.03.2025 nach main, nach dem Abzweig von 24.10, und steht seit 25.12 im
Release. Gluon hat kein Target `qualcommax-ipq60xx`, auch auf main nicht.

**Nur Zweig v2025.1.x-next (18.10.2026).** Ein GL-AXT1800 liegt bei adorfer,
der GL-AX1800 ist ungetestet.

## Gerät

- IPQ6000, 512 MiB RAM, 128 MiB NAND, QCA8075, WLAN 2x2 2.4 GHz und
  2x2 5 GHz (802.11ax, ath11k IPQ6018), USB 3.0.
- GL-AXT1800 (Slate AX): Reiserouter mit Lüfter (`kmod-hwmon-pwmfan`),
  SD-Slot, 2x LAN und WAN. GL-AX1800 (Flint): 4x LAN und WAN.
- Installation laut OpenWrt-Commit: `factory.bin` über die Upgrade-Seite der
  GL.iNet-Firmware, Einstellungen nicht behalten. Oder U-Boot-Web-Failsafe:
  Reset 5 Sekunden halten, http://192.168.1.1, dort `factory.ubi`.

## Inhalt

`openwrt.sh` (pre-update) legt die Commits als
`patches/openwrt/6000-hw-glinet-axt1800-*` ab, `targets.sh` (post-update) legt
`targets/qualcommax-ipq60xx` an und trägt es in `targets/targets.mk` ein (nach
`qualcommax-ipq50xx`, daher nach `devices/mercusys-mr80x-v2/targets.sh`).

| Nr. | Inhalt |
| --- | --- |
| 0001 | `append-gl-metadata` aus filogic.mk nach `include/image-commands.mk` (OpenWrt ddc4f216c6) |
| 0002 | PWM-Knoten für IPQ6018, `CONFIG_PWM_IPQ` (227222f357); Treiber und Binding kamen schon mit der ipq50xx-Serie |
| 0003 | DTS-Labels klein, CPU-dtsi von ipq6018 und **ipq8074** aufgefrischt (eb9e0f2cff); Kernelpatch 0084 ohne den ipq5018-Teil, den die ipq50xx-Serie schon als 0082 mitbringt |
| 0004 | SDHCI für IPQ6018 aus v6.11, sdcc-Takt (af6cf5d8c0) |
| 0005 | cpufreq für die IPQ60xx-Varianten, mp5496-Regler (0b33bbc0e6) |
| 0006 | GL-AX1800/AXT1800 (OpenWrt c3f2bb7afc), an 24.10 angepasst |

0001 bis 0006 sind der ganze OpenWrt-PR #14950, in der Reihenfolge von main.
0003 ändert auch Device Trees von `qualcommax-ipq807x`, ein ipq807x-Bau mit
der Serie zeigt, ob dort etwas kippt.

Anpassungen in 0006 (Absatz `[Neanderfunk: ...]` in der Commit-Nachricht):
uboot-envtools liegt in 24.10 unter `package/boot/uboot-envtools` und nutzt
`ubootenv_add_uci_config`; das Caldata-Skript heißt dort `11-ath11-caldata`;
die Hunks für Linksys MR7350, Qihoo 360V6 und TP-Link EAP610, die es in 24.10
nicht gibt, sind weggelassen.

Nicht übernommen, weil nur für neuere Kernel nötig:
- 5feee05dbb (PWM-Periode, sonst läuft der Lüfter nicht): Der pwm-ipq-Treiber
  aus `patches-6.6/0141` sucht pre_div/pwm_div schon selbst, der Fehler steckt
  erst in der späteren Treiberfassung.
- ceb6a77792 (SD-Pinctrl unter 6.18), 5805d638ad, f50435627d u. a.
  (Umbauten auf PPE-Netzwerk und DTS-Verzeichnis).

## Offen, am Gerät zu prüfen

- Lüfter dreht und regelt (pwm-fan, Trips 50/75/100 °C).
- WLAN-MACs: Das Caldata-Skript setzt sie aus `get_mac_label`; das DTS hat
  kein `label-mac-device`. Welche MAC Gluon als primäre nimmt, und ob die
  WLAN-MACs eindeutig sind.
- 11s-Mesh auf beiden Bändern, Durchsatz.
