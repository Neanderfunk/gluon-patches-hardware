#!/bin/bash
#
# Kernel: mtk_eth_soc prueft kleine Fragmente (< 16 Byte) jetzt auf allen
# Netsys-Versionen, nicht nur auf v1. TEST.
#
# OpenWrts generic/pending-6.6/732-01 (Felix Fietkau) segmentiert bzw.
# linearisiert solche Pakete, weil der TX-DMA daran haengen bleibt - aber nur
# bei mtk_is_netsys_v1 (MT7621/MT7622/MT7623/MT7629). Laut MediaTek
# (mtk-openwrt-feeds 241d864218630c9cb380a3657c89f8fc3bdc3434, 02.10.2026)
# betrifft die Grenze alle Netsys-Versionen, also auch MT7981/MT7986/MT7988
# (Cudy TR3000/WR3000*, M30/M60, MR90X, ...). Kandidat gegen die TX-Timeouts
# "transmit queue 0 timed out" auf MT7981 (openwrt#21319, unser TR3000-Fall
# openwrt#17505); dass es die Ursache ist, ist nicht belegt.
# Testpin auf v2025.1.x (adorfer 13.10.2026); Validierung ueber eth_tx_stall
# und Remote-Syslog, bei Problemen wieder herausnehmen.
#
# Legt den Patch nur ab: OpenWrt wendet target/linux/generic/hack-6.6/ beim
# Kernel-Bau selbst an, nach pending-6.6/732-01.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/kernel/mtk-eth-small-frag.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SMALLFRAG_PATCH="792-net-ethernet-mtk_eth_soc-remove-netsys-v1-restriction-for-small-frag.patch"

echo "Kernel: mtk_eth_soc-Pruefung auf kleine Fragmente fuer alle Netsys-Versionen"

enter_dir openwrt

copy_into_tree "$PATCH_DIR/$SMALLFRAG_PATCH" \
  "target/linux/generic/hack-6.6/$SMALLFRAG_PATCH"
