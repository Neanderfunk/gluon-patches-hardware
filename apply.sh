#!/bin/bash
#
# apply.sh <pre-update|post-update>
#
# Wendet die Patches dieses Repos auf einen Gluon-Baum an, in fester
# Reihenfolge. Aufruf aus dem Gluon-Verzeichnis, einmal je Phase:
#
#   cd gluon
#   <dieses Repo>/apply.sh pre-update     vor  "make update"
#   make update
#   <dieses Repo>/apply.sh post-update    nach "make update"
#
# pre-update legt Dateien unter patches/openwrt oder patches/packages im
# Gluon-Baum ab, die "make update" per "git am" auf die Module einspielt.
# Alles andere, insbesondere jeder Patch am OpenWrt-Baum, gehoert nach
# post-update: "make update" setzt die Module neu auf.
#
# Bricht beim ersten fehlgeschlagenen Skript ab. Einzelne Skripte lassen sich
# genauso allein aufrufen; die Reihenfolge unten ist nur dort wichtig, wo die
# README eine Abhaengigkeit nennt.

set -o errexit -o nounset -o pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# OpenWrt-Backports neuer Geraete (01.10.2026): legen ihre Commits unter
# patches/openwrt ab, "make update" spielt sie per git am ein. Praefixe 5100 bis
# 5600 legen die Reihenfolge fest (M3000 v2 setzt auf AP3000 Wall auf).
PRE_UPDATE=(
  devices/aruba-ap-32x/openwrt.sh             # Aruba AP-324/325 (ipq806x, aus 25.12)
  devices/zyxel-nwa90ax/openwrt.sh            # Zyxel NWA90AX und NWA90AX Pro (aus 25.12)
  devices/cudy-ap3000-wall-v1/openwrt.sh      # Cudy AP3000 Wall v1 (aus 25.12)
  devices/cudy-wr3000u-v1/openwrt.sh          # Cudy WR3000U v1 (aus 25.12)
  devices/tplink-eap620-hd-v1/openwrt.sh      # TP-Link EAP620 HD v1 (qualcommax, aus 25.12)
  devices/cudy-m3000-v2-yt8821/openwrt.sh     # Cudy M3000 v2 mit YT8821 (aus 25.12)
  kernel/mt7915-ps-aql/openwrt.sh             # mt7915/mt798x Power-Save/AQL aus Gluon main (#3673), ersetzt Gluons 0012
)

# Reihenfolge wie im Neanderfunk-Bau. Die Skripte sind voneinander
# unabhaengig.
POST_UPDATE=(
  devices/zbit-zb25vq128.sh                   # Zbit-Flash des Totolink X5000R (Kernel-Patch)
  devices/add-nanopi-r2c.sh                   # FriendlyElec NanoPi R2C
  devices/add-lantiq-xrx200-devices.sh        # AVM FRITZ!Box 3390
  devices/add-cudy-3000.sh                    # Cudy AP3000 v1, TR3000 256MB v1
  devices/remove-dlink-m30-recovery.sh        # D-Link M30: kein recovery-Image (Gluon #3816)
  devices/dlink-aquila-odm-mac.sh             # D-Link M30/M60: MAC aus Odm per Layout-Parser
  device-fixes/fix-xiaomi-ax6s-bootflags.sh   # Xiaomi Redmi AX6S: Boot-Flags bestaetigen
  targets/additionaltargets.sh                # zusaetzliche Targets und Geraete aus OpenWrt
  devices/aruba-ap-32x/targets.sh             # Gluon-Eintraege der OpenWrt-Backports oben
  devices/zyxel-nwa90ax/targets.sh
  devices/cudy-ap3000-wall-v1/targets.sh
  devices/cudy-wr3000u-v1/targets.sh
  devices/tplink-eap620-hd-v1/targets.sh
  devices/cudy-m3000-v2-yt8821/targets.sh
  devices/add-cellular.sh                     # ZTE MF286R
  network/interfaces-patch.sh                 # primaere MACs und Schnittstellen der zusaetzlichen Geraete
  kernel/rtl8221b-skip-mmd30.sh               # RTL8221B: MMD 30 beim PHY-Scan auslassen
  kernel/mt7530-phy-disable-eee.sh            # MT7530-PHY: EEE aus
  kernel/ag71xx-rx-ring-no-bug.sh             # ag71xx: kein BUG() bei leerem RX-Ring
)

PHASE="${1:-}"
case "$PHASE" in
  pre-update)  LISTE=( "${PRE_UPDATE[@]}" ) ;;
  post-update) LISTE=( "${POST_UPDATE[@]}" ) ;;
  *)
    echo "Aufruf: $0 pre-update|post-update (aus dem Gluon-Verzeichnis)" >&2
    exit 2
    ;;
esac

if [ ! -f Makefile ] || [ ! -f modules ] || [ ! -d package ]; then
  echo "apply.sh: $(pwd) sieht nicht nach einem Gluon-Verzeichnis aus." >&2
  exit 2
fi

echo "$(basename "$REPO_DIR"): Phase $PHASE, ${#LISTE[@]} Skript(e)"
for SKRIPT in "${LISTE[@]}"; do
  [ -x "$REPO_DIR/$SKRIPT" ] || { echo "apply.sh: $SKRIPT fehlt oder ist nicht ausfuehrbar." >&2; exit 1; }
  echo "== $SKRIPT"
  # Subshell: ein cd im Skript (etwa nach openwrt) betrifft das naechste nicht.
  ( "$REPO_DIR/$SKRIPT" ) || { echo "apply.sh: $SKRIPT fehlgeschlagen." >&2; exit 1; }
done
