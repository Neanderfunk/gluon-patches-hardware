#!/bin/bash
#
# TP-Link EAP620 HD v1: OpenWrt-Backport (Phase pre-update).
#
# Legt die OpenWrt-Commits dieses Verzeichnisses (0*.patch, git-format-patch)
# unter patches/openwrt im Gluon-Baum ab. "make update" spielt sie dort nach
# Gluons eigenen Patches per "git am" ein (scripts/patch.sh), in der
# Reihenfolge der Dateinamen. Das Praefix 5500-hw-tplink-eap620-hd-v1 legt die Stelle fest.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

PREFIX="5500-hw-tplink-eap620-hd-v1"
DEST="patches/openwrt"

echo "TP-Link EAP620 HD v1: OpenWrt-Patches nach $DEST"

[ -d "$DEST" ] || patch_abort "$DEST fehlt - laeuft das Skript im Gluon-Verzeichnis? (Arbeitsverzeichnis: $PWD)"

# Abgelegte Dateien sind im Gluon-Baum unversioniert und ueberleben
# "git reset --hard". Eine alte Fassung dieser Serie deshalb erst entfernen,
# sonst spielt "make update" alte und neue nebeneinander ein.
rm -f "$DEST/$PREFIX-"*.patch

n=0
for SRC in "$PATCH_DIR"/0*.patch; do
  [ -f "$SRC" ] || patch_abort "keine Patches in $PATCH_DIR."
  cp "$SRC" "$DEST/$PREFIX-$(basename "$SRC")" || patch_abort "$SRC liess sich nicht kopieren."
  n=$((n + 1))
done
echo "  $n Patch(es) als $DEST/$PREFIX-*.patch abgelegt."
