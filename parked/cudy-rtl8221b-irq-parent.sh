#!/bin/bash
#
# mediatek: RTL8221B-Interrupt an GPIO 38 des pio statt am GIC (Cudy TR3000,
# M3000). Backport aus OpenWrt 82b69dfaf6ca; Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/parked/cudy-rtl8221b-irq-parent.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "mediatek: Cudy TR3000/M3000 - interrupt-parent fuer den 2,5G-PHY"

enter_dir openwrt

apply_patch "$PATCH_DIR/cudy-rtl8221b-irq-parent.patch" \
  "target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dts" \
  'interrupt-parent = <&pio>'
