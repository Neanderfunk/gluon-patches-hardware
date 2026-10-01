#!/bin/bash
#
# Cudy AP3000 Wall v1: Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und traegt dann das Geraet in
# targets/mediatek-filogic ein.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "Cudy AP3000 Wall v1: Gluon-Target"

grep -q 'Device/cudy_ap3000wall-v1' "openwrt/target/linux/mediatek/image/filogic.mk" 2>/dev/null \
  || patch_abort "'Device/cudy_ap3000wall-v1' fehlt in openwrt/target/linux/mediatek/image/filogic.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/$(cd "$PATCH_DIR" && ls targets-*.patch)" \
  "targets/mediatek-filogic" \
  'cudy_ap3000wall-v1'
