# Neue Geräte für Gluon v2025.1.x (Teil B, Punkte 5 bis 10)

Basis: Gluon 0ad3ad5, OpenWrt openwrt-24.10 @ a1ea57bd05 (Kernel 6.6.151),
Gluon-Patchstand `patched` = 80e476b848 (a1ea57bd + Gluons 13 Patches),
gluon-patches-hardware @ 8dbae18 (so auch in FirmwareConfigs gepinnt).

Vorbereitet am 01.10.2026, uebernommen in gluon-patches-hardware. Kein Build,
keine Hardware getestet (Stand der Uebernahme).

Markierung: **[geprüft]** = hier nachgestellt oder im Quelltext nachgesehen,
**[abgeleitet]** = geschlossen, nicht nachgestellt.

## Übersicht

| Verzeichnis | Gerät | Target | Gluon-Name | Status |
| --- | --- | --- | --- | --- |
| `aruba-ap-32x/` | Aruba AP-324/325 (+ Siemens W1750D) | ipq806x-generic | `aruba-ap-32x` | bereit; Erstinstallation nur mit Serial und Fremd-Artefakten |
| `zyxel-nwa90ax/` | Zyxel NWA90AX, NWA90AX Pro | ramips-mt7621, mediatek-filogic | Alias von `zyxel-nwa50ax(-pro)` | bereit |
| `cudy-ap3000-wall-v1/` | Cudy AP3000 Wall v1 | mediatek-filogic | `cudy-ap3000-wall-v1` | bereit; Portrollen und PoE-Passthrough offen |
| `cudy-wr3000u-v1/` | Cudy WR3000U v1 (+ WBR3000UAX v1 als Unterbau) | mediatek-filogic | `cudy-wr3000u-v1` | bereit |
| `tplink-eap620-hd-v1/` | TP-Link EAP620 HD v1 | qualcommax-ipq807x | `tp-link-eap620-hd-v1` | bereit; Target qualcommax-ipq807x seit 01.10.2026 in FirmwareConfigs an |
| `cudy-m3000-v2-yt8821/` | Cudy M3000 mit Motorcomm YT8821 | mediatek-filogic | `cudy-m3000-v2-with-motorcomm-yt8821` | bereit; setzt AP3000 Wall voraus |

Jedes Verzeichnis enthält:

* `0*.patch`: OpenWrt-Commits (git format-patch, Autor und Signed-off-by-Kette
  des Originals, `(cherry picked from commit …)`, Zeile `[backport to openwrt-24.10: …]`)
* `targets-*.patch`: Gluon-Geräteeintrag
* `openwrt.sh` (Phase **pre-update**): legt die `0*.patch` als
  `patches/openwrt/<Präfix>-*.patch` ab; `make update` spielt sie per `git am`
  nach Gluons 0001-0013 ein. Entfernt vorher alte Kopien desselben Präfixes
  (der Gluon-Baum wird nur `git reset --hard` gesetzt, nicht gereinigt).
* `targets.sh` (Phase **post-update**): prüft, dass die OpenWrt-Seite im Baum
  steht, dann `apply_patch` (lib-patch.sh, `--fuzz=0`) für den Target-Patch.

Warum pre-update statt `patch` post-update: mehrteilige Serien (Aruba 4,
Zyxel 3, WR3000U 2, M3000 2) lassen sich mit `patch --dry-run -R` nicht auf
"schon angewendet" prüfen, sobald zwei Teile dieselbe Datei ändern (GNU patch
merkt sich im Trockenlauf keinen Zwischenstand) **[geprüft]**; zudem
verschiebt die M3000-Serie den Kontext der AP3000-Wall-Serie. `git am` über
`make update` hat das Problem nicht, und der OpenWrt-Baum wird dabei jedes Mal
frisch aus `base` aufgebaut (scripts/patch.sh: `git clone -s -b base`).

Einbau in gluon-patches-hardware (Skripte erwarten `devices/<gerät>/` und
`lib-patch.sh` zwei Ebenen höher):

```
PRE_UPDATE=(
  devices/aruba-ap-32x/openwrt.sh           # 5100
  devices/zyxel-nwa90ax/openwrt.sh          # 5200
  devices/cudy-ap3000-wall-v1/openwrt.sh    # 5300
  devices/cudy-wr3000u-v1/openwrt.sh        # 5400
  devices/tplink-eap620-hd-v1/openwrt.sh    # 5500
  devices/cudy-m3000-v2-yt8821/openwrt.sh   # 5600, braucht 5300
)
POST_UPDATE=( … bisherige …
  devices/aruba-ap-32x/targets.sh
  devices/zyxel-nwa90ax/targets.sh
  devices/cudy-ap3000-wall-v1/targets.sh
  devices/cudy-wr3000u-v1/targets.sh
  devices/tplink-eap620-hd-v1/targets.sh
  devices/cudy-m3000-v2-yt8821/targets.sh   # nach targets/additionaltargets.sh
)
```

Die Target-Patches sind gegen den Stand **nach** `add-cudy-3000.sh` und
`targets/additionaltargets.sh` (inkl. `targets-mediatek-filogic.patch` und
`targets-qualcommax-ipq807x.patch` aus 8dbae18) erzeugt. Ändert die
Nachbarsession diese Dateien weiter, neu erzeugen.

## Prüfungen

* Alle OpenWrt-Serien: `git am --3way` auf a1ea57bd und `git am` (ohne 3way,
  wie scripts/patch.sh) auf 80e476b848 sauber, alle sechs zusammen in obiger
  Reihenfolge (13 Commits) **[geprüft]**.
* Dieselben Dateien mit `patch -p1 --fuzz=0` auf 80e476b848: sauber, Ergebnis
  bitgleich zum `git am`-Ergebnis **[geprüft]**.
* Zusammen mit den bestehenden OpenWrt-Patches des Repos
  (`dlink-aquila-odm-mac.patch` fasst ebenfalls `11_fix_wifi_mac` an,
  `fix-xiaomi-ax6s-bootflags.patch`), in beiden Reihenfolgen: sauber
  **[geprüft]**.
* `make update` nachgestellt (Gluons 13 Patches aus dem fuzzprobe-Baum +
  abgelegte 5xxx-Dateien, exakt die `git am`-Aufrufe aus scripts/patch.sh auf
  a1ea57bd): 26 Commits sauber; danach alle `targets.sh` zweimal: erster Lauf
  angewendet, zweiter "bereits angewendet" **[geprüft]**.
* Target-Patches: `--fuzz=0` auf 0ad3ad5 + gluon-patches-hardware 8dbae18, in
  beiden Reihenfolgen, Rückwärtsprobe sauber **[geprüft]**.
* Gluons `scripts/target_lib.lua` gegen die gepatchten Targets ausgewertet:
  Image-Namen und Aliase wie unten **[geprüft]**.
* DTS: mit cpp + dtc 1.6.1 gegen einen Kernel 6.6.151 mit allen generic- und
  Target-Patches des gepatchten Baums übersetzt (mediatek, ipq806x,
  qualcommax): alle neuen DTS bauen, nur die Warnungen, die die
  Referenzgeräte (AP3000 v1, AP3935, EAP660 HD) auch haben **[geprüft]**.
* Kernelbau selbst nicht möglich (kein flex/bison, keine Toolchain).

## Weitere Hinweise

* Die Upstream-Kopie `scratchpad/upstream/openwrt` ist ein flacher Klon;
  Branch-Zugehörigkeiten oben erst nach Vertiefen geprüft.
* Hilfsdateien in `partb/`: `ow/` (eigener Klon des OpenWrt-Pins, Branch
  `alle` = alle Serien), `_k/` (Kernel-Headers/DTS-Prüfung), `_g/` und `_sim/`
  (Gluon-Nachstellung), `_ref/` (ffac/ffmuc-Site), `_up/` (Skripte, Zwischenstände).
