#!/bin/bash
#
# Xiaomi Redmi AX6S: compat_version 2.0 bei der Erstinstallation setzen, wie es
# OpenWrt fuer den Linksys E8450 (UBI) tut. Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "mediatek-mt7622: Xiaomi Redmi AX6S, compat_version 2.0"

enter_dir openwrt

apply_patch "$PATCH_DIR/fix-xiaomi-ax6s-compat-version.patch" \
  "target/linux/mediatek/mt7622/base-files/etc/board.d/05_compat-version" \
  'xiaomi,redmi-router-ax6s'
