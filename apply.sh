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

PRE_UPDATE=(
  devices/add-lantiq-xrx200-devices.sh        # AVM FRITZ!Box 7430 und 3390
)

# Reihenfolge wie im Neanderfunk-Bau. Abhaengig sind nur die Geraete in
# mediatek-filogic (add-dlink-m30 setzt auf add-mercusys-mr90x auf).
POST_UPDATE=(
  device-fixes/mi4apatch.sh                   # Mi Router 4A Gigabit sysupgrade-faehig
  devices/add-totolink-x5000r.sh              # Totolink X5000R
  devices/add-mercusys-mr90x.sh               # MERCUSYS MR90X
  devices/add-dlink-m30.sh                    # D-Link AQUILA PRO AI M30 A1 (nach MR90X)
  device-fixes/fix-xiaomi-ax6s-bootflags.sh   # Xiaomi Redmi AX6S: Boot-Flags bestaetigen
  devices/add-nanopi-r2c.sh                   # FriendlyElec NanoPi R2C
  devices/add-cudy-3000.sh                    # Cudy-3000-Serie (mediatek-filogic)
  targets/additionaltargets.sh                # zusaetzliche Targets und Geraete aus OpenWrt
  devices/add-cellular.sh                     # ZTE MF286R
  network/interfaces-patch.sh                 # primaere MACs und Schnittstellen der zusaetzlichen Geraete
  kernel/revert-mips-tlb-uniquify.sh          # MIPS 74Kc Kaltstart-Haenger (entfaellt ab Kernel 5.15.209)
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
