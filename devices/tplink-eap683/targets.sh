#!/bin/bash
#
# TP-Link EAP683-LR/-UR: Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und haengt dann das Geraet ans Ende von
# targets/mediatek-filogic (nach targets/filogic-mt7986.sh).
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "TP-Link EAP683-LR/-UR: Gluon-Target"

grep -q 'Device/tplink_eap683-lr' "openwrt/target/linux/mediatek/image/filogic.mk" 2>/dev/null \
  || patch_abort "'Device/tplink_eap683-lr' fehlt in openwrt/target/linux/mediatek/image/filogic.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/targets-mediatek-filogic-eap683.patch" \
  "targets/mediatek-filogic" \
  'tplink_eap683-lr'
