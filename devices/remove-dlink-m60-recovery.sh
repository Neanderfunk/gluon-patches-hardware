#!/bin/bash
#
# Nimmt beim D-Link AQUILA PRO AI M60 A1 das recovery-Image heraus.
#
# Das recovery-Image von Gluon ist ein initramfs mit D-Link-Header. Als
# fertige Firmware taugt es nicht: ohne squashfs und Overlay liegt alles
# Beschreibbare nur im RAM, die Konfiguration ist nach jedem Neustart weg, und
# Gluon bricht im initramfs den Config-Mode ohnehin ab. Beim M30 hat Gluon das
# gleiche Image deshalb entfernt (#3816, siehe remove-dlink-m30-recovery.sh).
#
# Installation stattdessen: ein initramfs fuer die Erstinstallation (OpenWrt-
# recovery-Image oder ein eigener Installer) ueber die D-Link-Recovery, danach
# das Gluon-sysupgrade-Image.
#
# Setzt auf remove-dlink-m30-recovery.patch auf (dessen Ergebnis ist der
# Kontext), muss also danach laufen.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/devices/remove-dlink-m60-recovery.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "mediatek-filogic: D-Link M60 ohne recovery-Image"

apply_patch "$PATCH_DIR/remove-dlink-m60-recovery.patch"
