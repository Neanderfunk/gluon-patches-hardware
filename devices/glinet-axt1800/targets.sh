#!/bin/bash
#
# GL.iNet GL-AX1800/GL-AXT1800: Gluon-Target qualcommax-ipq60xx
# (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und legt dann das Target
# targets/qualcommax-ipq60xx samt Eintrag in targets/targets.mk an. Muss nach
# devices/mercusys-mr80x-v2/targets.sh laufen (Kontextzeile qualcommax-ipq50xx).
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "GL.iNet GL-AX1800/AXT1800 (ipq60xx): Gluon-Target"

grep -q 'Device/glinet_gl-axt1800' "openwrt/target/linux/qualcommax/image/ipq60xx.mk" 2>/dev/null \
  || patch_abort "'Device/glinet_gl-axt1800' fehlt in openwrt/target/linux/qualcommax/image/ipq60xx.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/targets-qualcommax-ipq60xx.patch" \
  "targets/qualcommax-ipq60xx" \
  'glinet_gl-axt1800'
