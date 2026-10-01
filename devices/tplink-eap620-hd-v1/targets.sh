#!/bin/bash
#
# TP-Link EAP620 HD v1: Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und traegt dann das Geraet in
# targets/qualcommax-ipq807x ein.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "TP-Link EAP620 HD v1: Gluon-Target"

grep -q 'Device/tplink_eap620hd-v1' "openwrt/target/linux/qualcommax/image/ipq807x.mk" 2>/dev/null \
  || patch_abort "'Device/tplink_eap620hd-v1' fehlt in openwrt/target/linux/qualcommax/image/ipq807x.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/$(cd "$PATCH_DIR" && ls targets-*.patch)" \
  "targets/qualcommax-ipq807x" \
  'tplink_eap620hd-v1'
