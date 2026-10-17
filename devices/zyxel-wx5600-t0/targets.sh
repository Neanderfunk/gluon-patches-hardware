#!/bin/bash
#
# Zyxel WX5600-T0: Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und haengt dann das Geraet ans Ende von
# targets/mediatek-filogic (nach targets/filogic-mt7986.sh).
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "Zyxel WX5600-T0: Gluon-Target"

grep -q 'Device/zyxel_wx5600-t0-ubootmod' "openwrt/target/linux/mediatek/image/filogic.mk" 2>/dev/null \
  || patch_abort "'Device/zyxel_wx5600-t0-ubootmod' fehlt in openwrt/target/linux/mediatek/image/filogic.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/targets-mediatek-filogic-wx5600.patch" \
  "targets/mediatek-filogic" \
  'zyxel_wx5600-t0-ubootmod'
