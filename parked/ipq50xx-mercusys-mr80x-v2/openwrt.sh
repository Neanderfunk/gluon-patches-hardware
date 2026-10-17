#!/bin/bash
#
# Mercusys MR80X v2 / MR3000X v2.0 (qualcommax-ipq50xx): OpenWrt-Backport
# (Phase pre-update). Geparkt, steht nicht in apply.sh.
#
# Legt die OpenWrt-Commits dieses Verzeichnisses (0*.patch, git-format-patch)
# unter patches/openwrt im Gluon-Baum ab. "make update" spielt sie dort nach
# Gluons eigenen Patches per "git am" ein (scripts/patch.sh), in der
# Reihenfolge der Dateinamen. Das Praefix 5700-hw-ipq50xx legt die Stelle fest.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

PREFIX="5700-hw-ipq50xx"
DEST="patches/openwrt"

echo "Mercusys MR80X v2 (ipq50xx): OpenWrt-Patches nach $DEST"

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
