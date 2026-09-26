#!/bin/bash
#
# Ergaenzt das Target mediatek-filogic um den MERCUSYS MR90X.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/devices/add-mercusys-mr90x.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "mediatek-filogic: MERCUSYS MR90X"

apply_patch "$PATCH_DIR/add-mercusys-mr90x-gluon.patch" \
  "targets/mediatek-filogic" \
  'mercusys_mr90x-v1'
