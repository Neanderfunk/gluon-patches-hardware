#!/bin/bash
#
# Ergaenzt die Gluon-Targetdateien um Geraete, die Gluon selbst nicht fuehrt,
# und um zwei zusaetzliche Targets.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/targets/additionaltargets.sh
#
# Welcher Patch beim Sprung auf Gluon 2025.1 entfaellt und welcher bleibt,
# steht in docs/migration-2025.1-targets.md, Kapitel 3.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "Zusaetzliche Targets und Geraete"

# Merkmal ist zyxel_nbg6616: eap225-outdoor-v3, neben dem der EAP225 Wall v2
# eingefuegt wird, steht auch im unveraenderten Baum und taugt nicht zur
# Unterscheidung.
echo "- TP-Link EAP225 Wall v2 und Zyxel NBG6616"
apply_patch "$PATCH_DIR/targets-ath79-generic.patch" \
  "targets/ath79-generic" \
  'zyxel_nbg6616'

echo "- Mikrotik RB951Ui-2nD"
apply_patch "$PATCH_DIR/targets-ath79-mikrotik.patch" \
  "targets/ath79-mikrotik" \
  'mikrotik_routerboard-mapl-2nd'

echo "- ZTE MF286R"
apply_patch "$PATCH_DIR/targets-ath79-nand.patch" \
  "targets/ath79-nand" \
  'zte_mf286r'

# Den MR8300 und die Pakettabelle ATH10K_PACKAGES_IPQ40XX_QCA9984 fuehrt
# Gluon 2025.1 selbst; der Patch legte beide ein zweites Mal an (doppeltes
# device() mit anderem Paketsatz). Merkmal deshalb linksys_ea8300.
echo "- AVM FRITZ!Repeater 3000, Linksys EA8300, Pakete MR33 und MF289F"
apply_patch "$PATCH_DIR/targets-ipq40xx-generic.patch" \
  "targets/ipq40xx-generic" \
  'linksys_ea8300'

# targets-mk.patch entfaellt unter 2025.1: ipq40xx,chromium steht upstream im
# BROKEN-Block von targets/targets.mk, und ipq807x,generic gibt es nicht mehr -
# OpenWrt 24.10 hat das Target nach qualcommax/ipq807x umbenannt, Gluon fuehrt
# es als qualcommax,ipq807x im aktiven Teil.

echo "- Google Wifi"
apply_patch "$PATCH_DIR/targets-ipq40xx-chromium.patch" \
  "targets/ipq40xx-chromium" \
  'ATH10K_PACKAGES_IPQ40XX'

# Traegt ausserdem beide Mikrotik-wAP als Outdoor-Geraete in platform.lua ein,
# jeweils im Block ihres Targets (wAP G-5HacT2HnD: ath79/mikrotik, wAP ac:
# ipq40xx/mikrotik). Bis 01.10.2026 standen beide im Block ath79/generic und
# wirkten nie.
echo "- Mikrotik wAP ac, Outdoor-Liste fuer wAP ac und wAP G-5HacT2HnD"
apply_patch "$PATCH_DIR/targets-ipq40xx-mikrotik.patch" \
  "targets/ipq40xx-mikrotik" \
  'mikrotik_wap-ac'

# Nur noch die WAX218: den AX3600 fuehrt Gluon 2025.1 selbst in
# targets/qualcommax-ipq807x, mit denselben Paketausschluessen wie unser
# alter Patch. Die Datei heisst nicht mehr ipq807x-generic.
echo "- Netgear WAX218"
apply_patch "$PATCH_DIR/targets-qualcommax-ipq807x.patch" \
  "targets/qualcommax-ipq807x" \
  'netgear_wax218'

# targets-mediatek-mt7622.patch entfaellt: UniFi 6 LR v2/v3 und WAX206 fuehrt
# Gluon 2025.1 selbst.

# AVM FRITZ!Box 7430 und 3390 stehen nicht mehr hier, sondern in
# add-lantiq-xrx200-devices.sh: derselbe Patch legt einen OpenWrt-Patch im
# Gluon-Baum ab und muss deshalb vor "make update" laufen.

# echo "- Edimax BR6478ACv2"
# apply_patch "$PATCH_DIR/targets-ramips-mt7620.patch" \
#   "targets/ramips-mt7620" \
#   'edimax_br-6478ac-v2'

# Archer AX23 v1 und UniFi nanoHD fuehrt Gluon 2025.1 selbst.
echo "- Cudy M1800, Mikrotik RB750Gr3, TP-Link EAP613 v1"
apply_patch "$PATCH_DIR/targets-ramips-mt7621.patch" \
  "targets/ramips-mt7621" \
  'cudy_m1800'

# Profile, die OpenWrt 24.10 schon hat; hier fehlt nur die Gluon-Zeile.
# Laeuft nach devices/add-cudy-3000.sh, der Patch ist gegen dessen Stand
# erzeugt. Upstream-Namen, damit der Patch entfaellt, sobald Gluon die Geraete
# selbst fuehrt.
echo "- ASUS RT-AX59U, Cudy WR3000P v1, GL.iNet GL-MT6000"
apply_patch "$PATCH_DIR/targets-mediatek-filogic.patch" \
  "targets/mediatek-filogic" \
  'glinet_gl-mt6000'
