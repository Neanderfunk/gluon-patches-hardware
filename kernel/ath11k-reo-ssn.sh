#!/bin/bash
#
# ath11k: beim Stoppen der RX-Aggregation das SSN-valid-Bit der REO-Queue
# loeschen (Florian Maurer, ath-next, eingereicht 25.11.2026, upstream noch
# offen).
#
# Gegenstueck zu mac80211-mesh-ba-teardown.sh: mac80211 baut die
# RX-Sitzungen eines Mesh-Peers jetzt ab, wenn sein Link ESTAB verlaesst.
# ath11k loescht dabei aber die Hardware-Reorder-Queue nicht, sondern
# schrumpft sie nur auf Fenster 1 und behaelt Fensteranfang und SSN-valid.
# Faengt der Peer danach ohne neues ADDBA wieder bei Sequenznummer 0 an,
# verwirft REO seine Rahmen als "alt", bis zu 2047 Rahmen lang. Betrifft die
# Seite, die den Eintrag haelt, wenn sie ath11k hat (bei uns MR80X v2,
# IPQ5018), und Peers, die ohne HT neu beitreten.
#
# Im Labor (21_dias, 25./26.11.2026) verlor der MR80X v2 ede0 auch mit dem
# mac80211-Patch immer wieder den Unicast zu Nachbarn; linkcheck
# (mesh_peer_unicast) loeschte den Stationseintrag, und der Peer blieb danach
# oft weiter stumm. Ob dieser Patch das behebt, ist noch zu messen.
#
# Legt den Patch nur ab: das mac80211-Paket wendet patches/ath11k/ beim Bau
# selbst an. Geprueft 26.11.2026: greift ohne Fuzz (nur Zeilenversatz) auf
# backports 6.12.96 pur und auf den fertig gepatchten ipq50xx-Baeumen
# (mac80211-regular und -smallbuffers, mit devices/mercusys-mr80x-v2). Einziger Aufrufer mit
# update_ssn=false ist ath11k_dp_rx_ampdu_stop(); der Wert fuer SVLD in upd2
# bleibt 0, die Queue steht damit wie nach ath11k_hal_reo_qdesc_setup().
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

KPATCH="980-wifi-ath11k-invalidate-the-REO-queue-SSN-when-RX-aggregation-stops.patch"
PKGDIR="package/kernel/mac80211"
TARGET="$PKGDIR/patches/ath11k/$KPATCH"
BACKPORTS="6.12.96"

echo "ath11k: SSN der REO-Queue beim Stoppen der RX-Aggregation verwerfen"

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
