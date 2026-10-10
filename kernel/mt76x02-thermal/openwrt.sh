#!/bin/bash
#
# mt76x0e/mt76x2e: Chiptemperatur als Thermal-Zone (Phase pre-update). TEST.
#
# Testpin auf v2025.1.x (adorfer 10.10.2026: "ihr koennt gern hinterher
# zurueckrollen"); faellt der Test schlecht aus, wieder herausnehmen. Ob der
# Patch bleibt, entscheidet der Test an C20i (MT7610E) und Mi4A Gigabit
# (MT7612E, Gegenprobe); Auftrag adorfer 10.10.2026 ueber die Packages-Session.
#
# Die Datei 0001 ist ein OpenWrt-Commit, der den Paket-Patch
# package/kernel/mt76/patches/900-wifi-mt76-mt76x02-expose-temperature-as-thermal-zone.patch
# anlegt. "make update" spielt ihn per git am ein. Der Paket-Patch greift laut
# Packages-Session mit --fuzz=0 auf mt76 2025.11.06~eb567bc7 nach 100/200/350
# und beruehrt keine Datei aus kernel/mt7915-ps-aql (800-810).
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

PREFIX="5160-hw-mt76x02-thermal"
DEST="patches/openwrt"

echo "mt76x02: Thermal-Zone (Test) nach $DEST"

[ -d "$DEST" ] || patch_abort "$DEST fehlt - laeuft das Skript im Gluon-Verzeichnis? (Arbeitsverzeichnis: $PWD)"

rm -f "$DEST/$PREFIX-"*.patch
n=0
for SRC in "$PATCH_DIR"/0*.patch; do
  [ -f "$SRC" ] || patch_abort "keine Patches in $PATCH_DIR."
  cp "$SRC" "$DEST/$PREFIX-$(basename "$SRC")" || patch_abort "$SRC liess sich nicht kopieren."
  n=$((n + 1))
done
echo "  $n Patch(es) als $DEST/$PREFIX-*.patch abgelegt."
