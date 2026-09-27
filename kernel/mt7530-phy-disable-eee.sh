#!/bin/bash
#
# Kernel: EEE am MT7530-PHY (auch Switch des MT7621) abschalten und bei
# Bedarf neu aushandeln. Nachbau von OpenWrt PR #25058 fuer 5.15;
# Einzelheiten im Patchkopf.
#
# Legt den Patch nur ab, und zwar unter 6.6 als Target-Patch von ramips
# (MT7621), nicht mehr generisch: Das Target mediatek organisiert
# mediatek-ge.c mit eigenen Patches (733-01) um, ein generischer Patch davor
# bricht dort den Kernel-Bau. OpenWrt wendet target/linux/ramips/patches-6.6/
# beim Kernel-Bau selbst an.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/kernel/mt7530-phy-disable-eee.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

EEE_PATCH="767-net-phy-mediatek-ge-disable-EEE-on-MT7530-PHY.patch"

echo "Kernel: EEE am MT7530-PHY aus (MT7621-Switch)"

enter_dir openwrt

copy_into_tree "$PATCH_DIR/$EEE_PATCH" \
  "target/linux/ramips/patches-6.6/$EEE_PATCH"
