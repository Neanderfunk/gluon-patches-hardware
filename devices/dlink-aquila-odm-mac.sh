#!/bin/bash
#
# D-Link AQUILA PRO AI M30 A1 und M60 A1: die Basis-MAC aus der
# Werksdaten-Partition Odm per nvmem-Layout-Parser lesen statt aus einer
# festen Zelle.
#
# OpenWrt liest die MAC fest ab Odm 0x81. Odm ist aber eine Liste von
# Eintraegen unterschiedlicher Laenge; am Testplatz-M60 (29.09.2026) beginnt
# der MAC-Eintrag erst bei 0x83. Der Knoten las 06:00:dc:ea:e7:ae statt
# dc:ea:e7:ae:b4:82, Knoten-ID und Adressen passten nicht zum Aufkleber und
# waeren zwischen Geraeten nicht eindeutig. Ursache: Geraete aus
# Mehrfach-Packs tragen "M60-2" bzw. "M30/CP" statt "M60"/"M30", der
# MAC-Eintrag rutscht (M60-2: 0x83, M30/CP: 0x87; OpenWrt PR 23902/24967).
# Der Parser sucht den Eintrag mit der ID 0x30 und ist damit von der Lage
# unabhaengig.
#
# Zwei Teile:
#   451-nvmem-add-layout-for-D-Link-Odm.patch  Kernel: Treiber dlink-odm
#   dlink-aquila-odm-mac.patch                 Device Tree M30/M60, Kernel-Config
#                                              filogic, WLAN-Hotplug M30
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

KPATCH="451-nvmem-add-layout-for-D-Link-Odm.patch"

echo "D-Link M30/M60: MAC aus Odm per Layout-Parser"

enter_dir openwrt

TARGET="target/linux/mediatek/patches-6.6/$KPATCH"

# Anders als copy_into_tree: eine vorhandene, aber veraltete Kopie (aus einem
# frueheren Lauf, unversioniert, ueberlebt git reset) wird ersetzt.
if [ -f "$TARGET" ] && cmp -s "$PATCH_DIR/$KPATCH" "$TARGET"; then
  echo "  $TARGET: liegt bereits im Baum."
else
  [ -d "$(dirname "$TARGET")" ] \
    || patch_abort "$(dirname "$TARGET") gibt es nicht - passt der Pfad noch zum Baum?"
  cp "$PATCH_DIR/$KPATCH" "$TARGET" || patch_abort "$KPATCH liess sich nicht kopieren."
  echo "  $TARGET: kopiert."
fi

apply_patch "$PATCH_DIR/dlink-aquila-odm-mac.patch" \
  "target/linux/mediatek/dts/mt7986a-dlink-aquila-pro-ai-m60-a1.dts" \
  'dlink,odm-layout'
