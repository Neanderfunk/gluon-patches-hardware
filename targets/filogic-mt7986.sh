#!/bin/bash
#
# MT7986-Geraete aus OpenWrt 24.10, die Gluon 2025.1 nicht fuehrt (Phase
# post-update). Nur Gluon-Eintraege: die Profile hat OpenWrt 24.10 schon.
# Bei uns ungetestet; deshalb nur auf dem Zweig v2025.1.x-next.
#
# Der Patch haengt einen Block ans Ende von targets/mediatek-filogic und hat
# als Kontext den Eintrag zyxel-nwa50ax-pro samt Alias aus
# devices/zyxel-nwa90ax/targets.sh; muss also danach laufen.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "MT7986-Geraete aus OpenWrt 24.10 (filogic)"

apply_patch "$PATCH_DIR/targets-mediatek-filogic-mt7986.patch" \
  "targets/mediatek-filogic" \
  'xiaomi_redmi-router-ax6000-ubootmod'
