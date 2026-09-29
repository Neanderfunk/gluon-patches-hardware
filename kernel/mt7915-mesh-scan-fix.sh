#!/bin/bash
#
# mt7915 (MT7915/7916/7981/7986): Mesh ueberlebt einen WLAN-Scan.
#
# OPTIONAL, nicht in apply.sh: Backport zum Testen angeboten, am Geraet noch
# nicht verifiziert. Aufruf von Hand nach "make update", aus dem
# Gluon-Verzeichnis.
#
# Unter Gluon 2023.2 (mt76 2024-04-03) loescht der Treiber beim Scan BSS- und
# Stations-Eintrag des Mesh-Interfaces in der Firmware; danach ist Unicast
# ueber das Mesh tot, bis das WLAN neu startet. mt76 e3e6d490 behebt das
# (in Gluon 2025.1 enthalten). Einzelheiten im Patchkopf.
#
# Der Patch gehoert zum OpenWrt-Paket mt76 (package/kernel/mt76/patches/),
# das die Quellen erst beim Bau holt; geprueft ist er gegen mt76 1e336a8.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

KPATCH="360-wifi-mt76-mt7915-fix-mesh-scan.patch"
TARGET="package/kernel/mt76/patches/$KPATCH"
MT76_VERSION="1e336a8582dce2ef32ddd440d423e9afef961e71"

echo "mt7915: Mesh ueberlebt WLAN-Scan (mt76 e3e6d490, optional)"

enter_dir openwrt

grep -q "^PKG_SOURCE_VERSION:=$MT76_VERSION" package/kernel/mt76/Makefile \
  || patch_abort "mt76 ist nicht mehr $MT76_VERSION - Patch neu pruefen (steckt der Fix schon drin?)."

if [ -f "$TARGET" ] && cmp -s "$PATCH_DIR/$KPATCH" "$TARGET"; then
  echo "  $TARGET: liegt bereits im Baum."
else
  mkdir -p "$(dirname "$TARGET")" || patch_abort "$(dirname "$TARGET") liess sich nicht anlegen."
  cp "$PATCH_DIR/$KPATCH" "$TARGET" || patch_abort "$KPATCH liess sich nicht kopieren."
  echo "  $TARGET: kopiert."
fi
