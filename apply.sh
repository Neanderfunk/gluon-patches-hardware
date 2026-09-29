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

PRE_UPDATE=()

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
