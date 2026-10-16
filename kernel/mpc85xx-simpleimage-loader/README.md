# mpc85xx: simpleImage-Loader an der richtigen Adresse

Backport fuer Gluon v2025.1.x (OpenWrt 24.10, Kernel 6.6). Analyse mit
Messwerten: router-werkstatt `docs/mpc85xx-simpleimage-loader.md`.

**Fehler:** Vor dem Kernel liegt auf mpc85xx ein kleiner Loader
(simpleImage). Der Kernel wird ab Adresse 0 entpackt, der Loader muss
darueber sitzen. Der Kernel-Wrapper schiebt den Loader automatisch hoeher,
wenn der Kernel die feste Loader-Adresse ueberschreitet; der uImage-Header
erfaehrt davon nichts. OpenWrt 6a8b831593 (08.03.2024, in 24.10) hat den
Header der simpleImage-Geraete auf 0x1500000 gesetzt, die feste Link-Adresse
aber nur bei TL-WDR4900 v1 und WS-AP3825i eingetragen. Folge: Das sysupgrade
des WS-AP3715i wird bei 0x1100000 gelinkt und bleibt nach "Uncompressing
Kernel Image ... OK" stehen (openwrt/openwrt#23112); das initramfs des
WS-AP3825i liegt bei 0x1600000 (#25302).

| Datei | Herkunft | Inhalt |
| --- | --- | --- |
| 0001 | #25541, cherry-pick 4afaacdd7f (David Bauer) | WS-AP3825i: Loader und Header auf 0x3000000 |
| 0002 | #25541, cherry-pick 15fb19cdb3 | 110-br200-wp: Kontext aufgefrischt |
| 0003 | #25541, cherry-pick 9836f7ca13 (Edward Chow, #23121) | neuer Kernelpatch 099: `link_address='0x1500000'` fuer alle `simpleboot-*`; die Einzeleintraege in 100/101/106/110 entfallen |
| 0004 | Neanderfunk, Nachbau von #25257 (grische) fuer 24.10 | BR200-WP, HiveAP-330, WS-AP3715i: Loader und Header auf 0x3000000 |

Nach 0001-0003 waere der WS-AP3715i repariert, sein initramfs haette aber
nur 0,2 MiB Luft unter 0x1500000; ein Gluon-initramfs (RAMpe) passt da nicht
hinein. 0004 verschiebt deshalb die drei verbliebenen Geraete auf 0x3000000,
wie es auf main fuer WS-AP3710i und WS-AP3825i schon gilt. TL-WDR4900 v1
bleibt bei 0x1500000 (4,1 MiB Luft, 5 Geraete im Feld). Alle Geraete haben
mindestens 128 MiB RAM; 0x3000000 = 48 MiB liegt im RAM.

**Geprueft** (16.10.2026, Packages-Session): 0001-0004 per `git am` sauber
auf dem Gluon-Pin a1ea57bd; die Wrapper-Hunks von 010/099/107 per
`git apply` ohne Fuzz auf den unveraenderten `arch/powerpc/boot/wrapper` von
Linux 6.6.151, Ergebnis: Faelle `simpleboot-br200-wp|hiveap-330|ws-ap3715i`
und `simpleboot-ws-ap3825i` je 0x3000000, `simpleboot-*` 0x1500000. Die
Kernel-Builds von #25541 (p1010, p1020, p2020) sind in der OpenWrt-CI gruen.

**Nicht geprueft:** Hardware. Kein WS-AP3715i, HiveAP-330 oder BR200-WP
vorhanden. Belegt ist, dass ein Loader bei 0x1500000 auf dem WS-AP3715i
bootet (24.10-initramfs, Hardwaretest in #23121) und dass 0x3000000 auf
WS-AP3710i/WS-AP3825i (24.10/25.12) und laut #25257 auf dem WS-AP3715i
(25.12) laeuft. **Nach jedem Bau pruefen**, am Image, ohne Geraet:
`router-werkstatt/werkzeug/mpc85xx-ladeadresse.py <sysupgrade.bin|initramfs>`
muss fuer alle mpc85xx-Images "OK" melden (Header = Linkadresse), bei
den AP3825i-Images im Feld also 0x3000000 statt bisher 0x1500000.

**Rueckweg:** `openwrt.sh` aus `apply.sh` nehmen; die Images sind dann wieder
wie vor dem Patch (AP3825i-sysupgrade bei 0x1500000, bootet).
