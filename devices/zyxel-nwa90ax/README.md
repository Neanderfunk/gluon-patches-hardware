# Zyxel NWA90AX und NWA90AX Pro

Backport aus OpenWrt 25.12 fuer Gluon v2025.1.x (OpenWrt 24.10). openwrt.sh
(pre-update) legt die OpenWrt-Commits unter patches/openwrt ab, targets.sh
(post-update) traegt das Geraet in Gluon ein. Uebersicht und Pruefungen:
../neue-geraete-2026-10.md.


**Quellen** **[geprüft]**: 419342237 (ramips, `77 e1` in `compat-models` des
Factory-FIT, `DEVICE_ALT0 NWA90AX`), e34e874a1 (filogic, nur ALT0-Name),
2cc8d3e382 (filogic, `81 e1` für den Pro, "Fixes: e34e874a11f0"). Alle drei in
main und openwrt-25.12, unverändert anwendbar.

Gluon: kein eigenes Gerät, weil dieselbe DTS (Modell "Zyxel NWA50AX" /
"Zyxel NWA50AX Pro") und damit derselbe Image-Name im Manifest. Nur
`aliases = {'zyxel-nwa90ax'}` bzw. `{'zyxel-nwa90ax-pro'}`, wie Gluon es für
Aruba AP-303/Instant On AP11 macht. Ergebnis laut target_lib: zusätzliche
Dateien `…-zyxel-nwa90ax.bin` / `…-zyxel-nwa90ax-sysupgrade.bin` und
`…-zyxel-nwa90ax-pro(.bin|-sysupgrade.bin)` **[geprüft]**.

**Flashen**: Factory-Image über die Zyxel-Weboberfläche; laut Commit-Text
(Wiki NWA50AX) muss der Slot "current image" 1 sein, sonst "errno -25007
Firmware content error". Pro: wie NWA50AX Pro **[abgeleitet]**.

**Risiko**: `zyxel-nwa-fit` gilt für alle ramips-NWA-Geräte; die Liste wird
nur länger (zusätzlich akzeptiert) **[abgeleitet]**.

