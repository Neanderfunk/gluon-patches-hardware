#!/bin/bash
#
# mpc85xx: simpleImage-Loader an der Adresse linken, die der Header nennt
# (Phase pre-update).
#
# Seit OpenWrt 6a8b831593 (in 24.10) bootet das sysupgrade des Enterasys
# WS-AP3715i nicht: Der Loader wird bei 0x1100000 gelinkt, der uImage-Header
# sagt 0x1500000 (openwrt/openwrt#23112, #25302). Das initramfs des
# WS-AP3825i liegt aus demselben Grund daneben (0x1600000 statt 0x1500000).
#
# 0001-0003 sind openwrt/openwrt#25541 (Backport von #23121 und 4afaacdd7f
# nach openwrt-24.10, dort offen), unveraendert. 0004 ist unser Nachbau von
# #25257 fuer 24.10: Loader von BR200-WP, HiveAP-330 und WS-AP3715i nach
# 0x3000000, damit auch ein Gluon-initramfs (RAMpe) dort hineinpasst.
# Siehe README.md in diesem Verzeichnis.
#
# "make update" spielt die Dateien per git am ein. Aufruf aus dem
# Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

PREFIX="5170-hw-mpc85xx-simpleimage-loader"
DEST="patches/openwrt"

echo "mpc85xx: simpleImage-Loader-Adressen nach $DEST"

[ -d "$DEST" ] || patch_abort "$DEST fehlt - laeuft das Skript im Gluon-Verzeichnis? (Arbeitsverzeichnis: $PWD)"

rm -f "$DEST/$PREFIX-"*.patch
n=0
for SRC in "$PATCH_DIR"/0*.patch; do
  [ -f "$SRC" ] || patch_abort "keine Patches in $PATCH_DIR."
  cp "$SRC" "$DEST/$PREFIX-$(basename "$SRC")" || patch_abort "$SRC liess sich nicht kopieren."
  n=$((n + 1))
done
echo "  $n Patch(es) als $DEST/$PREFIX-*.patch abgelegt."
