# TP-Link EAP620 HD v1

Backport aus OpenWrt 25.12 fuer Gluon v2025.1.x (OpenWrt 24.10). openwrt.sh
(pre-update) legt die OpenWrt-Commits unter patches/openwrt ab, targets.sh
(post-update) traegt das Geraet in Gluon ein. Uebersicht und Pruefungen:
../neue-geraete-2026-10.md.


**Quelle**: 4b6e7da0f (main und 25.12, vor dem 25.12-Abzweig, aber nach dem
24.10-Abzweig) **[geprüft]**. Einzige Kontextanpassung in ipq-wifi. DTS aus
openwrt-25.12, also mit af021c1285 (`#size-cells` in `&mdio` raus, dtc-Warnung)
und a238170e57 (Leerzeichen) **[geprüft]**.

* ipq-wifi: Paket `ipq-wifi-tplink_eap620hd-v1` wird angelegt; die BDF
  `board-tplink_eap620hd-v1.ipq8074` liegt in qca-wireless seit 4b84921
  (11.12.2024) und damit im 24.10-Pin ec6831a43f (2025-10-22), kein
  Versionssprung nötig **[geprüft]**.
* ath11k: 24.10 führt den baugleichen EAP660 HD v1 mit gleicher
  Firmware-/Caldata-Logik (factory_data-UBI, `caldata_from_file`)
  **[geprüft]**; AR8031 per `CONFIG_AT803X_PHY=y` **[geprüft]**.

Gluon: `tp-link-eap620-hd-v1` (Modell "TP-Link EAP620 HD v1") in
qualcommax-ipq807x, `factory = false`; einziger Port wird `single`
**[abgeleitet]**. MAC per `ucidef_set_label_macaddr` aus factory_data, Gluons
label_mac greift **[geprüft]**.

**Target**: qualcommax-ipq807x ist in Gluons targets.mk aktiv und in
unserer targets.conf seit 01.10.2026 eingeschaltet (FirmwareConfigs 17c319e,
adorfer).

**Flashen** (Commit-Text): Serial (JP1, R58 und R62 brücken), U-Boot mit
Ctrl+B anhalten, Initramfs `…-initramfs-uImage.itb` per TFTP nach 0x44000000,
`bootm`, dann `sysupgrade -n`. Gluon baut kein Initramfs. Ohne Serial: 25.12
hat mit 8a15a75e94 ein `web-ui-factory.bin` (Stock-UI, vorher per SSH
`cliclientd stopcs`); das braucht `tplink-image-2022`, das 24.10 nicht hat,
deshalb nicht rückportiert. Weg: OpenWrt-25.12-web-ui-factory, danach
`sysupgrade -n` auf Gluon **[abgeleitet]**; 8a15a75e94 liegt vor dem
25.12-Abzweig, ist also in allen 25.12-Releases **[geprüft]**.

**Risiko**: Commit-Text nennt "5GHz radio instability".

