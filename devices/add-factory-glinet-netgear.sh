#!/bin/bash
#
# Gibt GL.iNet GL-E750, GL.iNet GL-XE300 und NETGEAR WNDR3700 v5 ein
# Gluon-factory-Image (OpenWrt: squashfs-factory.img).
#
# Gluon fuehrt alle drei mit "factory = false", ohne Grund im Eintrag. OpenWrt
# baut das factory.img fuer alle drei; der RAMpe-Installer baut es fuer genau
# diese Geraete seit 15.11.2026 mit (als Zwischenschritt ueber die
# Hersteller-Oberflaeche bzw. die U-Boot-Weboberflaeche). Mit einem Gluon-
# factory entfaellt dieser Zwischenschritt: dasselbe Format, gleich die
# Community-Firmware.
#
# Rueckbau: Skript aus apply.sh nehmen, dann steht wieder "factory = false".
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/devices/add-factory-glinet-netgear.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "ath79-nand/ramips-mt7621: factory fuer GL-E750, GL-XE300, WNDR3700 v5"

apply_patch "$PATCH_DIR/add-factory-glinet-netgear.patch"
