#!/bin/bash
#
# ath11k: auf Mesh-Interfaces keine A-MSDUs senden (Florian Maurer, ath-next,
# eingereicht 22.11.2026, upstream noch offen).
#
# Die Firmware zaehlt die Mesh Control im Laengenfeld eines Mesh-A-MSDU-
# Teilrahmens mit, was 802.11-2020 ausschliesst. mac80211 erkennt beide
# Formate, ein Empfaenger, der A-MSDUs in Hardware zerlegt, nur das
# standardgemaesse: er verwirft alle Teilrahmen ausser dem ersten. Der Patch
# begrenzt A-MSDUs auf Mesh-vdevs per WMI_VDEV_SET_CUSTOM_AGGR_SIZE_CMDID auf
# einen MSDU; das RX-Aggregationsfenster bleibt unveraendert.
#
# Anlass (21_dias, 26.11.2026): Auf dem MR80X v2 ede0 (IPQ5018) meldet
# linkcheck (mesh_peer_unicast) die 2.4-GHz-Strecke zum Xiaomi 4A Gigabit
# (mt76) seit dem 25.11. durchgehend als stumm, mit und ohne
# ath11k-reo-ssn.sh; Einzelpings gehen durch, waehrend des linkcheck-Laufs
# fehlen 3 s. Florian hat auf diesen Patch verwiesen. Ob er das behebt, ist
# noch zu messen.
#
# Legt den Patch nur ab: das mac80211-Paket wendet patches/ath11k/ beim Bau
# selbst an. Geprueft 26.11.2026: greift ohne Fuzz (nur Zeilenversatz) auf
# backports 6.12.96 nach allen Patches aus build/, subsys/, ath/ und ath11k/
# des Gluon-Pins ac283dfb (mit devices/mercusys-mr80x-v2 und
# ath11k-reo-ssn.sh). Befehl, TLV-Tag und WMI_VDEV_SUBTYPE_MESH_11S sind in
# 6.12.96 schon definiert, neu sind nur Struktur und Bits. Nicht gebaut.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

KPATCH="981-wifi-ath11k-don-t-send-A-MSDUs-on-mesh-interfaces.patch"
PKGDIR="package/kernel/mac80211"
TARGET="$PKGDIR/patches/ath11k/$KPATCH"
BACKPORTS="6.12.96"

echo "ath11k: auf Mesh-Interfaces keine A-MSDUs senden"

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
