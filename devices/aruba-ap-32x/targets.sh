#!/bin/bash
#
# Aruba AP-32x: Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und traegt dann das Geraet in
# targets/ipq806x-generic ein.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "Aruba AP-32x: Gluon-Target"

grep -q 'Device/aruba_ap-32x' "openwrt/target/linux/ipq806x/image/generic.mk" 2>/dev/null \
  || patch_abort "'Device/aruba_ap-32x' fehlt in openwrt/target/linux/ipq806x/image/generic.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/$(cd "$PATCH_DIR" && ls targets-*.patch)" \
  "targets/ipq806x-generic" \
  'aruba_ap-32x'
