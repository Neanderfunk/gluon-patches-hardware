#!/bin/bash
#
# Cudy M3000 v2 (YT8821): Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und traegt dann das Geraet in
# targets/mediatek-filogic ein.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "Cudy M3000 v2 (YT8821): Gluon-Target"

grep -q 'Device/cudy_m3000-v2-yt8821' "openwrt/target/linux/mediatek/image/filogic.mk" 2>/dev/null \
  || patch_abort "'Device/cudy_m3000-v2-yt8821' fehlt in openwrt/target/linux/mediatek/image/filogic.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/$(cd "$PATCH_DIR" && ls targets-*.patch)" \
  "targets/mediatek-filogic" \
  'cudy_m3000-v2-yt8821'
