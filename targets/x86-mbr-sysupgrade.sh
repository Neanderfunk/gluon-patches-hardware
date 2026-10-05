#!/bin/bash
#
# x86-generic, x86-legacy, x86-64: zusaetzlich das MBR-Image ausgeben
# (OpenWrt "-squashfs-combined", Bootpartition ext4) als
# images/other/gluon-<site>-<release>-<target>-mbr-sysupgrade.img.gz.
#
# Grund: Gluon baut fuer x86 seit 2023.2 nur noch "-squashfs-combined-efi"
# (Bootpartition FAT). OpenWrt bis 19.07, also Gluon bis 2021.1, legt beim
# sysupgrade die gesicherte Konfiguration mit "mount -t ext4" auf Partition 1
# ab; auf FAT scheitert das, und der Knoten startet ohne Konfiguration im
# Setup-Mode (Gluon #2967, Labortest router-werkstatt
# docs/gluon-migrationspfade.md "x86: Labortest"). Alte x86-Knoten bekommen
# deshalb ueber ihr eigenes Manifest dieses Image; Ablauf in router-werkstatt
# docs/howto-x86-altknoten-2025.md.
#
# OpenWrt baut das Image ohnehin (CONFIG_GRUB_IMAGES ist Vorgabe), Gluon
# kopiert es nur nicht heraus. x86-geode braucht den Patch nicht: dort ist
# "-squashfs-combined" schon factory und sysupgrade.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/targets/x86-mbr-sysupgrade.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "x86: zusaetzliches MBR-Image fuer alte Knoten (-mbr-sysupgrade)"

apply_patch "$PATCH_DIR/x86-mbr-sysupgrade.patch" \
  "targets/x86-64" \
  "'-squashfs-combined', '-mbr-sysupgrade'"
