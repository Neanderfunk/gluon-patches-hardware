#!/bin/bash
#
# mac80211: Block-Ack-Sitzungen eines Mesh-Peers abbauen, sobald sein Link
# ESTAB verlaesst (Florian Maurer, upstream noch offen, wireless-next,
# patchwork 15005879).
#
# Fehlerbild im Feld (25.11.2026, MR80X v2 im 21_dias-Labor): Ein Knoten
# startet neu, sein Nachbar behaelt den alten Stationseintrag (Plink bleibt
# ESTAB) und damit die alte RX-Reorder-Sitzung. Der neu gestartete Knoten
# zaehlt seine Sequenznummern ab 0, der Nachbar verwirft dessen Unicast auf
# der TID als "alt", bis zu 2047 Rahmen lang. OGMs und Multicast laufen ohne
# Block-Ack und kommen weiter an; linkcheck sieht "mesh_unicast" auf dem
# neu gestarteten Knoten und startet ihn erneut, was die naechsten veralteten
# Sitzungen bei den Nachbarn erzeugt. Nachgewiesen an einer D-Link M60, die
# einen 8 h alten Eintrag fuer einen vor 24 min neu gestarteten MR80X mit
# aktiver RX-Sitzung auf TID 0 und 7 hielt; Loeschen des Eintrags heilte
# den Link sofort.
#
# Der Patch wirkt auf der Seite, die den Eintrag haelt, also auf allen
# Knoten, nicht nur auf dem neu gestarteten: deshalb fuer alle Targets.
# ath11k braucht fuer die haltende Seite zusaetzlich "wifi: ath11k:
# invalidate the REO queue SSN when RX aggregation stops", siehe
# ath11k-reo-ssn.sh.
#
# Legt den Patch nur ab: das mac80211-Paket wendet patches/subsys/ beim Bau
# selbst an. Geprueft 25.11.2026: greift ohne Fuzz auf backports 6.12.96
# samt allen build/- und subsys/-Patches des Pins, alle Hunks in den Funktionen
# des Originals (sta_apply_mesh_params, mesh_plink_block,
# mesh_process_plink_frame).
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

KPATCH="980-wifi-mac80211-mesh-tear-down-BA-sessions-when-the-peer-link-goes-down.patch"
PKGDIR="package/kernel/mac80211"
TARGET="$PKGDIR/patches/subsys/$KPATCH"
BACKPORTS="6.12.96"

echo "mac80211: BA-Sitzungen abbauen, wenn ein Mesh-Link ESTAB verlaesst"

enter_dir openwrt

# Geprueft ist der Patch nur gegen diese backports-Version; bei einem anderen
# Stand neu pruefen statt blind ablegen.
grep -q "^PKG_VERSION:=$BACKPORTS\$" "$PKGDIR/Makefile" \
  || patch_abort "$PKGDIR/Makefile hat nicht PKG_VERSION:=$BACKPORTS - $KPATCH neu pruefen."

# Eine veraltete Kopie aus einem frueheren Lauf (unversioniert, ueberlebt
# git reset) wird ersetzt.
if [ -f "$TARGET" ] && cmp -s "$PATCH_DIR/$KPATCH" "$TARGET"; then
  echo "  $TARGET: liegt bereits im Baum."
else
  [ -d "$(dirname "$TARGET")" ] \
    || patch_abort "$(dirname "$TARGET") gibt es nicht - passt der Pfad noch zum Baum?"
  cp "$PATCH_DIR/$KPATCH" "$TARGET" || patch_abort "$KPATCH liess sich nicht kopieren."
  echo "  $TARGET: kopiert."
fi
