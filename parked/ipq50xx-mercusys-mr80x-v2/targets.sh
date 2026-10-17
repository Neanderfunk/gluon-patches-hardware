#!/bin/bash
#
# Mercusys MR80X v2 / MR3000X v2.0: Gluon-Target qualcommax-ipq50xx
# (Phase post-update). Geparkt, steht nicht in apply.sh.
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und legt dann das Target
# targets/qualcommax-ipq50xx samt Eintrag in targets/targets.mk an.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "Mercusys MR80X v2 (ipq50xx): Gluon-Target"

grep -q 'Device/mercusys_mr80x-v2' "openwrt/target/linux/qualcommax/image/ipq50xx.mk" 2>/dev/null \
  || patch_abort "'Device/mercusys_mr80x-v2' fehlt in openwrt/target/linux/qualcommax/image/ipq50xx.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/targets-qualcommax-ipq50xx.patch" \
  "targets/qualcommax-ipq50xx" \
  'mercusys_mr80x-v2'
