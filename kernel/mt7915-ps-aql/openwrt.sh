#!/bin/bash
#
# mt7915/mt798x: Power-Save-/AQL-Satz aus Gluon main (Phase pre-update).
#
# Herkunft: freifunk-gluon/gluon PR #3673 (Merge 2bfae3d6, 13.03.2026, David
# Bauer), damals noch auf OpenWrt 24.10 (5774c8b, gleiches mt76 eb567bc7 wie
# unser Pin a1ea57bd). Die sechs Dateien 0013-0018 sind dort unveraendert
# entnommen. Sie legen im OpenWrt-Baum neue Paket-Patches ab:
#   mt76      800 TXQ nicht zurueckgeben, wenn die Nicht-AQL-Grenze erreicht ist
#             805 mt7915: Power-Save-Zustand mit der WA-Firmware abgleichen
#             810 HW-Flag fuer vom Treiber gepufferte PS-Frames
#   mac80211  950-001..003 Flag fuer Treiber-Pufferung, PS-Airtime bei AQL
#             mitrechnen bzw. aus der Summe nehmen
# Der PR nimmt dafuer Gluons eigenes 0012 (mt7915 PLE-Queues erkennen und
# leeren, #3610) per Revert zurueck; hier wird die Datei vor "make update"
# aus patches/openwrt entfernt.
#
# Wozu: Der Chip puffert Frames fuer schlafende Stationen unbegrenzt; bleibt
# ein Client im Power-Save, laeuft die TX-Queue voll und AQL kommt
# durcheinander (openwrt/mt76#1009, TX-Stillstand). Betroffen: alle
# mt7915-/mt798x-Geraete (AX6S, E8450, U6 LR, NWA55AXE, COVR X1860, M30/M60,
# Cudy TR3000/WR3000*/M3000, MR90X). Eine reine mt76-Fassung (be3aad4c) wurde
# upstream wegen nicht aufwachender PS-Stationen zurueckgenommen
# (openwrt/mt76#1068); die Gluon-Fassung bringt den mac80211-Teil mit.
# Uebernommen auf Ansage adorfer 03.10.2026 (Review U1).
#
# Geprueft 03.10.2026: alle sechs Dateien und die daraus entstehenden
# Paket-Patches greifen ohne Fuzz auf mt76 2025.11.06~eb567bc7 und
# backports 6.12.96 (samt allen bestehenden build/- und subsys/-Patches).
#
# Faellt Gluons 0012 weg oder heisst anders (etwa weil v2025.1.x den Satz
# selbst uebernimmt), bricht das Skript ab: dann ist der Satz neu zu bewerten.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

PREFIX="5150-hw-mt7915-ps-aql"
DEST="patches/openwrt"
GLUON_PLE="$DEST/0012-mt7915-detect-and-purge-stuck-PLE-queues.patch"

echo "mt7915: Power-Save-/AQL-Satz aus Gluon main nach $DEST"

[ -d "$DEST" ] || patch_abort "$DEST fehlt - laeuft das Skript im Gluon-Verzeichnis? (Arbeitsverzeichnis: $PWD)"

# Gluons PLE-Purge raus. Im Gluon-Baum ist die Datei versioniert; build.sh
# setzt den Baum vor jedem Lauf zurueck, sie ist dann wieder da.
if [ -f "$GLUON_PLE" ]; then
  rm -f "$GLUON_PLE" || patch_abort "$GLUON_PLE liess sich nicht entfernen."
  echo "  $GLUON_PLE: entfernt."
elif git ls-files --error-unmatch "$GLUON_PLE" >/dev/null 2>&1; then
  echo "  $GLUON_PLE: schon entfernt."
else
  patch_abort "$GLUON_PLE gibt es in diesem Gluon-Stand nicht - Satz neu bewerten."
fi

# Abgelegte Dateien sind unversioniert und ueberleben "git reset --hard";
# eine alte Fassung erst entfernen.
rm -f "$DEST/$PREFIX-"*.patch
n=0
for SRC in "$PATCH_DIR"/0*.patch; do
  [ -f "$SRC" ] || patch_abort "keine Patches in $PATCH_DIR."
  cp "$SRC" "$DEST/$PREFIX-$(basename "$SRC")" || patch_abort "$SRC liess sich nicht kopieren."
  n=$((n + 1))
done
echo "  $n Patch(es) als $DEST/$PREFIX-*.patch abgelegt."
