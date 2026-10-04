#!/bin/bash
#
# Sicherheits-Backports fuer Kernel 4.14.275 und mac80211 (backports 4.19.237)
# der Sackgasse (Gluon 2021.1, OpenWrt 19.07, ar71xx). Recherche:
# router-werkstatt docs/recherche-19.07/ (04.10.2026).
#
#   mac80211/subsys 900-903  Mesh-CSA: NULL-Deref ueber Funk (CVE-2026-23279,
#                            CVE-2026-23396), CSA nur von der eigenen Mesh,
#                            PREQ-Queue-Leak (CVE-2024-40942). 900 nie ohne 903.
#   generic/backport-4.14    zsmalloc-Race (CVE-2022-49554)
#   generic/pending-4.14     l2tp: skb-Control-Buffer beim Senden leeren
#                            (wie Gluon v2025.1.x Patch 0011)
#   ar71xx/patches-4.14 961  ag71xx: NAPI-Interrupts waehrend probe aus
#
# Die Patchdateien liegen unter kernel-backports/ in derselben Pfadstruktur wie
# im OpenWrt-Baum und werden dorthin kopiert; OpenWrt spielt sie beim Bau ein.
# Jede Datei traegt Original-Commit und Backport-Vermerk im Kopf. Geprueft am
# 04.10.2026: patch --fuzz=0 in OpenWrt-Reihenfolge, Kompilierprobe mit gcc
# 7.5.0/musl (Nachweise in scratch/fixes-2021/kernel/).
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC="$PATCH_DIR/kernel-backports"

echo "Sicherheits-Backports Kernel 4.14 / mac80211 4.19"

enter_dir openwrt

while read -r rel; do
  dir="$(dirname "$rel")"
  [ -d "$dir" ] || patch_abort "$dir gibt es nicht - passt der Pfad noch zum Baum?"
  if [ -f "$rel" ] && cmp -s "$SRC/$rel" "$rel"; then
    echo "  $rel: liegt bereits im Baum."
  else
    cp "$SRC/$rel" "$rel" || patch_abort "$rel liess sich nicht kopieren."
    echo "  $rel: kopiert."
  fi
done < <(cd "$SRC" && find . -type f -name '*.patch' | sed 's|^\./||' | sort)
