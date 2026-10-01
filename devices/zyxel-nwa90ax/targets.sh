#!/bin/bash
#
# Zyxel NWA90AX / NWA90AX Pro: Gluon-Geraeteeintrag (Phase post-update).
#
# Prueft zuerst, dass "make update" die OpenWrt-Seite (openwrt.sh, Phase
# pre-update) wirklich eingespielt hat, und traegt dann das Geraet in
# targets/ramips-mt7621 ein.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib-patch.sh"

echo "Zyxel NWA90AX / NWA90AX Pro: Gluon-Target"

grep -q '77 e1' "openwrt/target/linux/ramips/image/mt7621.mk" 2>/dev/null \
  || patch_abort "'77 e1' fehlt in openwrt/target/linux/ramips/image/mt7621.mk - lief openwrt.sh vor make update?"

grep -q '81 e1' "openwrt/target/linux/mediatek/image/filogic.mk" 2>/dev/null \
  || patch_abort "'81 e1' fehlt in openwrt/target/linux/mediatek/image/filogic.mk - lief openwrt.sh vor make update?"

apply_patch "$PATCH_DIR/$(cd "$PATCH_DIR" && ls targets-*.patch)" \
  "targets/ramips-mt7621" \
  'zyxel-nwa90ax'
