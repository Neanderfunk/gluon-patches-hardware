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
| `devices/<geraet>/openwrt.sh` | pre-update | OpenWrt-Backports aus 25.12 fuer neue Geraete: Aruba AP-324/325, Zyxel NWA90AX und NWA90AX Pro, Cudy AP3000 Wall v1, Cudy WR3000U v1, TP-Link EAP620 HD v1, Cudy M3000 v2 mit YT8821. Legt die Commits als `patches/openwrt/5x00-hw-<geraet>-*.patch` ab, `make update` spielt sie per `git am` ein | Original-Commits mit Autor und Signed-off-by; Uebersicht `devices/neue-geraete-2026-10.md`, je Geraet `devices/<geraet>/README.md` |
| `kernel/mt7915-ps-aql/openwrt.sh` | pre-update | mt7915/mt798x: Power-Save-/AQL-Satz aus Gluon main (PR #3673, Merge `2bfae3d6`): legt die sechs Gluon-Patches 0013-0018 als `patches/openwrt/5150-hw-mt7915-ps-aql-*.patch` ab und entfernt Gluons `0012-mt7915-detect-and-purge-stuck-PLE-queues.patch` (dort per Revert ersetzt). Gegen openwrt/mt76#1009 (TX-Stillstand bei Clients im Power-Save) | Original-Patches von David Bauer u. a., unveraendert |
| `devices/<geraet>/targets.sh` | post-update | Gluon-Eintrag der Backports darueber; prueft vorher, dass die OpenWrt-Seite im Baum steht | |
| `devices/zbit-zb25vq128.sh` | post-update | Kernel-Patch für den Zbit-ZB25VQ128-Flash (Totolink X5000R ab 2022); das Gerät kennt Gluon 2025.1, die Flash-ID der Kernel nicht | Daniel Palmer 2021, nie gemerged; auf 6.6 portiert, Kompilieren und Gerät ungetestet |
| `devices/add-nanopi-r2c.sh` | post-update | FriendlyElec NanoPi R2C | |
| `devices/add-lantiq-xrx200-devices.sh` | post-update | AVM FRITZ!Box 3390 | |
| `devices/add-cudy-3000.sh` | post-update | Cudy AP3000 v1 und TR3000 256MB v1 (die übrigen kennt Gluon 2025.1) | |
| `devices/remove-dlink-m30-recovery.sh` | post-update | D-Link M30: kein recovery-Image, es installiert nicht | Gluon #3816 |
| `devices/dlink-aquila-odm-mac.sh` | post-update | D-Link AQUILA PRO AI M30 A1 und M60 A1: Basis-MAC aus der Werksdaten-Partition `Odm` per eigenem nvmem-Layout-Parser (Kernel-Patch `451-nvmem-add-layout-for-D-Link-Odm.patch`) statt fester Zelle `0x81`. Geräte aus Mehrfach-Packs (`M60-2`, `M30/CP`) haben den MAC-Eintrag weiter hinten (`0x83`, `0x87`) | eigener Parser, Muster wie OpenWrts Adtran-Layout; OpenWrt PR 23902 (geschlossen), 24967 (offen) |
| `device-fixes/fix-xiaomi-ax6s-bootflags.sh` | post-update | Xiaomi Redmi AX6S: Boot-Flags bestätigen, kein Rückfall auf Stock | |
| `device-fixes/fix-xiaomi-ax6s-compat-version.sh` | post-update | Xiaomi Redmi AX6S: `board.d/05_compat-version` setzt bei der Erstinstallation `compat_version` 2.0 (wie OpenWrt beim E8450 UBI); sonst steht ein per factory.bin umgestellter Knoten auf 1.0 und bekommt kein Update mehr | |
| `targets/additionaltargets.sh` | post-update | zusätzliche Targets und Geräte aus OpenWrt, die Gluon 2025.1 nicht baut; ipq807x heißt jetzt `qualcommax-ipq807x`. Seit 01.10.2026 auch GL-MT6000, RT-AX59U, WR3000P v1 (filogic) und EAP613 v1 (mt7621), seit 10.10.2026 Mercusys MR80X v3 (filogic), deren Profile OpenWrt 24.10 schon hat | |
| `devices/erx-ka-imagename.sh` | post-update | EdgeRouter X und X SFP heißen `ubiquiti-edgerouter-x-ka` bzw. `-x-sfp-ka` (DTS-`model` "… KA", `compatible` unverändert). Ein noch nicht migrierter ERX (2023.2, Flash-Layout alt) findet damit keine Manifestzeile und lädt nichts; migrierte Knoten melden `-ka` und bekommen normale Updates. Muss nach `additionaltargets.sh` laufen (dessen Patch hat die alten Zeilen als Kontext). Rücknahme im Skriptkopf. ERX-Migration: router-werkstatt `docs/erx-migration-howto.md` | aus FirmwareConfigs b209af2 (09.09.2026), beim Umzug 27.09. verloren |
| `targets/x86-mbr-sysupgrade.sh` | post-update | x86-generic, -legacy, -64: zusätzlich das MBR-Image (OpenWrt `-squashfs-combined`, Bootpartition ext4) als `images/other/...-mbr-sysupgrade.img.gz`. Für alte x86-Knoten bis Gluon 2021.1, die beim Sprung auf das EFI-Image ihre Konfiguration verlieren (Gluon #2967); Ablauf in router-werkstatt `docs/howto-x86-altknoten-2025.md` | |
| `devices/add-cellular.sh` | post-update | Mobilfunkgerät ZTE MF286R | |
| `network/interfaces-patch.sh` | post-update | primäre MACs und Schnittstellenzuordnung für die zusätzlichen Geräte | |
| `kernel/rtl8221b-skip-mmd30.sh` | post-update | beim PHY-Scan MMD 30 des RTL8221B nicht lesen; sonst ist der 2,5G-Port tot, wenn beim Booten ein Kabel steckt (Cudy TR3000/WR3000H) | Backport OpenWrt 88dcd8c |
| `kernel/mt7530-phy-disable-eee.sh` | post-update | EEE am MT7530-PHY aus (Switch des MT7621); unter 6.6 als Target-Patch von ramips, weil mediatek die Datei selbst umbaut | Nachbau OpenWrt PR #25058 |
| `kernel/ag71xx-rx-ring-no-bug.sh` | post-update | ag71xx: kein `BUG()` bei leerem RX-Ring (RAM-Druck) | |

Nicht angewendet:

| Pfad | Inhalt |
| --- | --- |
| `parked/squashfs-blocksize-per-device.sh` | squashfs-Blockgröße je Gerät (vorbereitet, nicht aktiv) |
| `parked/cudy-rtl8221b-irq-parent.sh` | TR3000/M3000: `interrupt-parent = <&pio>` für den 2,5G-PHY (Backport OpenWrt 82b69df); geparkt, siehe Patchkopf |

## Abhängigkeiten

* Die Skripte sind voneinander unabhängig. `targets/additionaltargets.sh`
  wendet einige Target-Patches zweimal an und meldet beim zweiten Mal
  „bereits angewendet“, das ist gewollt.

## Entfernt

Gegenüber `v2023.2.x` (27.09.2026):

* `device-fixes/mi4apatch.sh` mit `mi4ag-migration.patch` (Compat-Level des
  Mi Router 4A Gigabit): unter 2025.1 nicht mehr übernommen.
* `devices/add-totolink-x5000r.sh`, `devices/add-mercusys-mr90x.sh`,
  `devices/add-dlink-m30.sh`: Gluon 2025.1 kennt die Geräte selbst; vom M30
  bleibt nur das Entfernen des recovery-Images.
* `486-02-…F50L1G41LC.patch` (SPI-NAND-ID): in OpenWrt 24.10 als Backport
  422-v6.19 enthalten.
* Cudy- und ipq807x-OpenWrt-Patches, `targets-mk.patch`: in OpenWrt 24.10
  bzw. Gluon 2025.1 enthalten.
* `experiments/mips-tlb-arm-e`: Kernel 6.6 bringt die Korrektur mit.

Aus `v2023.2.x`:

* `kernel/revert-mips-tlb-uniquify.sh` mit `999-mips-tlb-r4k-no-uniquify.patch`
  (27.09.2026): nahm den Aufruf von `r4k_tlb_uniquify()` heraus
  (Kaltstart-Hänger MIPS 74Kc). Seit Kernel 5.15.209 ist der Fehler upstream
  behoben, Gluon v2023.2.x bringt seit 22.09.2026 5.15.211 mit; dort passt der
  Patch nicht mehr. Letzter Stand: `845a95f`.

## Herkunft und Lizenz

Herausgelöst aus Neanderfunk/FirmwareConfigs (bis September 2026
Neanderfunk/firmware), Stand `851194f217a7fb165d101ed9c7b12a2597a9029e`,
Verzeichnis `patches/`. Die Geschichte der einzelnen Dateien steht dort.

`lib-patch.sh` ist eine Kopie; jedes Patch-Repo trägt seine eigene, damit es
allein nutzbar bleibt.

Skripte (`apply.sh`, `lib-patch.sh`, `*/*.sh`): BSD-3-Clause, siehe
`LICENSE`. Patchdateien stehen unter der Lizenz des Projekts, das sie
ändern: Gluon BSD-2-Clause, OpenWrt und Linux GPL-2.0.
