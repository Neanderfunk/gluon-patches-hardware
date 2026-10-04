#!/bin/bash
#
# ath9k: Empfangspuffer 128 statt 256. Aendert OpenWrts eigenen Patch
# 511-ath9k_reduce_rxbuf (512 -> 256) auf 128. Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "ath9k: ATH_RXBUF 128"

enter_dir openwrt

apply_patch "$PATCH_DIR/ath9k-rxbuf-128.patch" \
  "package/kernel/mac80211/patches/ath/511-ath9k_reduce_rxbuf.patch" \
  "ATH_RXBUF               128"
