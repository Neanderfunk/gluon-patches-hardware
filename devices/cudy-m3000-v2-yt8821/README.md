# Cudy M3000 v2 mit Motorcomm YT8821

Backport aus OpenWrt 25.12 fuer Gluon v2025.1.x (OpenWrt 24.10). openwrt.sh
(pre-update) legt die OpenWrt-Commits unter patches/openwrt ab, targets.sh
(post-update) traegt das Geraet in Gluon ein. Uebersicht und Pruefungen:
../neue-geraete-2026-10.md.


**Quellen** **[geprüft]**: 8ef564bcda (Kernel-Hack, hack-6.12) und 45b51ebaff
(Gerät), in 25.12 als 4d66f702c9 und ca825537fb (ab v25.12.1 in den Releases). **Nicht** übernommen:
51abd131d/b2d1e03c83 (Umbenennung "v1" in "v1/v2") und die ubootmod-Variante
(395252be08/be51f9a895).

* YT8821-Treiber in 24.10: backport-6.6/750-02 und 750-03 plus
  pending-6.6/740, Paket `kmod-phy-motorcomm`; AP3000 v1 und WR3000H nutzen ihn
  im Pin schon **[geprüft]**.
* Kernel-Hack nach `hack-6.6/755-…` (Nummer frei). Er passt auf das
  6.6-`motorcomm.c` nach den Backports mit identischen Zeilennummern
  **[geprüft]**; `ytphy_modify_ext` nimmt den MDIO-Lock nicht selbst, kein
  Deadlock **[geprüft]**. Kompiliert **nicht** geprüft.
* `mt7981b-cudy-m3000.dtsi` aus der 24.10-`m3000-v1.dts` so abgeleitet wie
  upstream aus main. Die v1-dtb ist vor und nach der Aufteilung **bitgleich**
  **[geprüft]**.
* Die Serie setzt AP3000 Wall voraus (11_fix_wifi_mac-Kontext wie upstream);
  Präfix 5600 nach 5300.

**Wie die beiden Images auseinandergehalten werden**:

| | v1 (RTL8221B) | v2 YT8821 |
| --- | --- | --- |
| compatible = board_name | `cudy,m3000-v1` | `cudy,m3000-v2-yt8821` |
| Modell (DTS) | `Cudy M3000 v1` | `Cudy M3000 v2 with Motorcomm YT8821` |
| Gluon-Image-/Manifestname | `cudy-m3000-v1` | `cudy-m3000-v2-with-motorcomm-yt8821` |
| sysupgrade supported_devices | `cudy,m3000-v1 R37` | `cudy,m3000-v2-yt8821 R37` |

Alles **[geprüft]** (DTS, filogic.mk, `SUPPORTED_DEVICES := $(subst _,$(comma),$(1))`
in include/image.mk, target_lib-Ausgabe). Der Knoten sucht im Manifest seinen
aus dem Modell gebildeten Namen (libplatforminfo `sanitize_image_name`), und
der Autoupdater ruft sysupgrade ohne `-F` auf, das prüft board_name gegen
supported_devices **[geprüft]**. Ein installiertes Gerät bekommt also nie das
andere Image. Überschneidung nur bei `R37` (Stock-/Zwischenfirmware): bei der
Erstinstallation entscheidet der Mensch, laut Commit per Systemlog der
Cudy-Firmware ("rtl8221b" oder "yt8821") **[geprüft]** (Commit-Text).
Ein YT8821-Gerät, das früher per v1-Image installiert wurde, bleibt auf v1;
Wechsel nur per `sysupgrade -F` mit dem v2-Image **[abgeleitet]**.

**Achtung für später** **[abgeleitet]**: Mit der Umbenennung (51abd131d, in
openwrt-25.12) heißt das v1-Modell "Cudy M3000 v1/v2", der Image-Name wird
`cudy-m3000-v1-v2`. Gluon main (auf 25.12) führt nur `cudy-m3000-v1` ohne
`manifest_aliases` **[geprüft]**; beim Sprung auf eine 25.12-Basis braucht
unser Manifest einen Alias, sonst finden M3000-v1-Knoten kein Update.

Gluon: `cudy-m3000-v2-with-motorcomm-yt8821`, `factory = false`. Die
site-Liste für `ethtool` (image-customization.lua, RTL8221B-Diagnose) enthält
das neue Gerät nicht; ob gewollt, entscheidet die Site.

**Flashen** (Commit-Text): Cudy-Zwischenfirmware über die Stock-Oberfläche, am
"1Gbps LAN"-Port 192.168.1.1, dann Image über LuCI/sysupgrade; oder UART
(Gehäuse zerlegen), U-Boot, Initramfs per TFTP nach 0x46000000, `bootm`,
`sysupgrade -n`.

**Risiko**: Der Kernel-Hack wirkt auf **jeden** YT8821, also auch auf
AP3000 v1 und WR3000H im Feld (Adresse 0 wird abgeschaltet; ein PHY-Reset nur,
wenn `reset-gpios` am PHY-Knoten hängt). Upstream identisch; vor dem Rollout
an einem YT8821-AP3000/WR3000H gegenprüfen **[abgeleitet]**.

