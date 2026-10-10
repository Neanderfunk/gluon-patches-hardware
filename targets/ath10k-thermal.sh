#!/bin/bash
#
# ath10k: CONFIG_ATH10K_THERMAL fuer alle Targets einschalten. TEST.
#
# Testpin auf v2025.1.x (adorfer 10.10.2026: "ihr koennt gern hinterher
# zurueckrollen"); faellt der Test schlecht aus, wieder herausnehmen. Meldet die
# Temperatur der ath10k-Karten ueber hwmon/thermal und zieht dafuer
# kmod-hwmon-core und kmod-thermal ins Image (package/kernel/mac80211/ath.mk).
# Zu pruefen im Test: Flash beim Archer C25, RAM auf 64-MB-Geraeten.
# try_config, weil Targets ohne ath10k die Option nicht kennen.
#
# Aufruf aus dem Gluon-Verzeichnis, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "ath10k: ATH10K_THERMAL (Test)"

apply_patch "$PATCH_DIR/ath10k-thermal.patch" \
  "targets/generic" \
  "try_config('ATH10K_THERMAL', true)"
