#!/bin/bash
#
# Legt den Kernel-Patch fuer den Zbit-ZB25VQ128-Flash (Totolink X5000R ab
# Baujahr 2022) im OpenWrt-Baum ab. Das Geraet selbst kennt Gluon 2025.1.
#
# Unter Kernel 6.6 wuerde der generische SFDP-Rueckfall (spi-nor-generic) den
# Chip vermutlich auch ohne Eintrag erkennen. Mangels Geraet ist das nicht
# pruefbar; der explizite Eintrag haelt das Verhalten bei, das unter 5.15 im
# Feld lief (Entscheidung adorfer 27.09.2026). Portierung auf 6.6 siehe
# Patchkopf.
#
# Legt den Patch nur ab: OpenWrt wendet target/linux/ramips/patches-6.6/ beim
# Kernel-Bau selbst an. Faellt das Verzeichnis beim naechsten Kernel-Sprung
# weg, bricht copy_into_tree hoerbar ab - genau so ist es gemeint.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/devices/zbit-zb25vq128.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

ZBIT_PATCH="412-mtd-spi-nor-add-support-for-zbit-zb25vq128.patch"

echo "ramips: Zbit-ZB25VQ128-Flash (Totolink X5000R)"

enter_dir openwrt

copy_into_tree "$PATCH_DIR/$ZBIT_PATCH" \
  "target/linux/ramips/patches-6.6/$ZBIT_PATCH"
