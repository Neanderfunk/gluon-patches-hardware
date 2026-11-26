# Mercusys MR80X v2 / MR3000X v2.0 (qualcommax-ipq50xx)

Backport des OpenWrt-Subtargets `qualcommax/ipq50xx` (Qualcomm IPQ5018) mit
dem Mercusys MR80X v2 auf Gluon v2025.1.x (OpenWrt 24.10, Kernel 6.6).
Gluon 2025.1 kennt ipq50xx nicht; in OpenWrt kam der MR80X v2 am 02.10.2026
nach main (938f67a519, PR #24919), dort mit Kernel 6.18.

**Aktiv seit 17.10.2026 (Testversion):** `openwrt.sh` steht in `apply.sh` unter
pre-update, `targets.sh` unter post-update. Gebaut wird das Gerät erst, wenn
der Neanderfunk-Bau das Target `qualcommax-ipq50xx` in seiner Target-Liste
führt. Die Serie ändert neben dem neuen Target auch Pakete, die andere
Targets mitbauen (mac80211/ath11k, qca-ssdk, qca-nss-dp, rtl8365mb,
ath11k-firmware); ein ipq807x-Bau mit der Serie zeigt, ob dort etwas kippt.

## Gerät

- IPQ5018 (2x Cortex-A53), 256 MiB RAM, 128 MiB SPI-NAND, Switch RTL8367S
  per SGMII, WLAN IPQ5018 (2.4 GHz) und QCN6122 (5 GHz), beide 802.11ax.
- MR3000X v2.0 ist dasselbe Board. Gluon-Name `mercusys-mr80x-v2`, Alias
  `mercusys-mr3000x-v2`. Das factory.bin trägt beide SupportList-Einträge.
- Erstinstallation über die Stock-Weboberfläche (Erweitert > System >
  Firmware-Upgrade > Lokales Upgrade). Die U-Boot-Web-Recovery nimmt nur
  RSA-signierte Herstellerfirmware.

## WLAN-Scan auf 2.4 GHz bleibt auf dem eigenen Kanal

Gemessen am 24.11.2026 an einem MR80X v2 mit Gluon v2025.1.x (Treiber
ath11k, Firmware `WLAN.HK.2.7.0.1-01744`): Ein Scan über das 2.4-GHz-Radio
(IPQ5018, `c000000.wifi`) liefert nur Netze des Kanals, auf dem das Radio
gerade steht, dazu den Nachbarkanal im Abstand von 10 MHz, den es mithört.

- Gleich bei `iw dev <if> scan`, `iw dev <if> scan freq 2412 2437 flush`
  (es kamen trotzdem nur Netze des eigenen Kanals zurück), über das
  Mesh-Interface wie per `ap-force` über das AP-Interface, mit `HE20` wie
  `HT20`. Laut `iw phy` sind die Kanäle 1 bis 11 freigegeben.
- Ein Mesh-Knoten derselben Gegend auf Kanal 6, 1 m entfernt, tauchte in
  keinem Scan auf. Stellt man das Radio selbst auf dessen Kanal (`uci set
  wireless.radio0.channel=…`, `wifi up radio0`), findet der Scan ihn sofort.
- Das 5-GHz-Radio (QCN6122, `b00a040.wifi1`, ebenfalls ath11k, dieselbe
  Firmware) scannt normal über alle Kanäle.
- Zum Vergleich am selben Tag geprüft, alle mit Netzen außerhalb des eigenen
  Kanals: mt7915e, mt7603e, mt76 (mt7628), mt798x-wmac (mt7981/mt7986),
  ath9k.

Woher die Firmware kommt (gemessen am selben Gerät): Der Kernel lädt sie
beim Start per remoteproc aus dem Root-Dateisystem, nicht der Bootloader und
nicht aus einem eigenen Flash-Bereich. `q6_fw.*` und `m3_fw.*` unter
`/lib/firmware/ath11k/IPQ5018/hw1.0/` kommen aus den Paketen
`ath11k-firmware-ipq5018` und `ath11k-firmware-qcn6122`
(`2024.10.14~15f05012-r1`, Quelle laut 0033: das alte QUIC-Repo
`upstream-wifi-fw`, weil QCA für IPQ5018/QCN6122 dort noch nichts Neueres
veröffentlicht hatte). Beide Radios laufen mit demselben Build. Gerätespezifisch
sind die Board-Daten `board-2.bin` (Paket `ipq-wifi-mercusys_mr80x-v2`,
`2025.10.22~ec6831a4-r1`) und die Kalibrierdaten in der Flash-Partition
`0:art`; die liest der Kernel nur.

Zum Protokollieren je Gerät (`dmesg | grep fw_build_id`, `md5sum`):

| Teil | Stand 24.11.2026 |
| --- | --- |
| `fw_build_id` (beide Radios) | `WLAN.HK.2.7.0.1-01744-QCAHKSWPL_SILICONZ-1`, `fw_version 0x270206d0`, Build 2022-08-04 13:28 |
| `q6_fw.mdt` md5 | `67a213db488fa4217351d2e4a109a63f` |
| `m3_fw.mdt` md5 | `4ad7145414e047f71aa75c6171c5d8a3` |
| `board-2.bin` md5 | `4cd72d2fcac767f8d71e01a44c268ddf` |

Ein anderer Firmware-Build ließe sich also über das Image tauschen und
vergleichen, wenn es einen gibt.

ath11k scannt per Firmware (hw_scan); welche Kanäle sie wirklich anhört,
sieht Linux nicht. Der Treiber gibt den Scan mit niedriger Priorität an die
Firmware. **Gegenprobe 25.11.2026:** Mit abgeschalteten AP-Interfaces auf
dem 2.4-GHz-Radio (Mesh bleibt an) findet derselbe Scan Netze auf Kanal 1,
5, 6 und 11; mit nur einem Station-Interface ebenso. Es liegt also am
aktiven AP. Dasselbe Verhalten ist auf einem Xiaomi AX3600 (ipq807x,
Firmware `WLAN.HK.2.9.0.1-02146`) nachgestellt, also nicht nur an diesem
Firmware-Stand. Zum Vergleich ohne den Effekt: mt7915e, mt7603e, mt76
(mt7628), mt798x-wmac (mt7981/mt7986), ath9k.

Andere Firmware-Stände: `WLAN.HK.2.6.0.1.r7-00028` (quic/upstream-wifi-fw,
testing) startet mit diesem Treiber nicht ("failed to receive wmi unified
ready event", QCN6122 "failed to wait qmi memory request"). Neuere Stände
(2.9, 2.12) gibt es nur aus Herstellerfirmware; laut OpenWrt-Forum
(Thread "IPQ5018: GLiNET B3000 info") stürzen sie nach Minuten bis Stunden
ab, 2.7.0.1-01744 gilt dort als der stabilste.

Folge für Werkzeuge, die per Scan Meshes auf anderen Kanälen suchen: Auf
2.4 GHz den AP kurz abschalten. neanderfunk-domainhelper `island` macht das
ab 0.14 (Neanderfunk/packages).

## 802.11s: Unicast fällt aus, Peers bleiben verbunden

Gemessen 25.11.2026 an zwei MR80X v2 im selben Mesh: Die Peers bleiben
`ESTAB`, batman-OGMs und Multicast kommen an, aber ein Unicast-Ping an die
Link-Local-Adresse eines Peers auf dem Mesh-Interface bleibt bei einem Teil
der Peers ohne Antwort, wechselnd und auf beiden Bändern (15 min nach dem
Start: 2.4 GHz 5 von 8 Peers, 5 GHz 2 von 8). Ein Knoten mit mt76 im selben
Mesh erreicht alle Peers, nur die beiden MR80X nicht. linkcheck
(`mesh_unicast`) erkennt das; `wifi` neu starten hilft nicht, nur ein
Neustart des Knotens, und auch der nur eine Zeit lang. Ohne Wirkung:
Modulparameter `ath11k crypto_mode=1`. Der REO-Status-Fix (0017) und das
Abholen im Takt (0025) sind beide drin. Im genannten Forenthread ist
802.11s auf IPQ5018 ebenfalls ungelöst (2.4 GHz tritt nicht bei, 5 GHz
braucht nach 30 bis 40 h einen Neustart). 950/951 (Crash-Recovery auf
AHB) sind schon in 0038 enthalten.

**Behoben mit zwei Patches von Florian Maurer (Test 26.11.2026, Bau
26112601bro):** `kernel/mac80211-mesh-ba-teardown.sh` baut die
Block-Ack-Sitzungen eines Mesh-Peers ab, sobald sein Link `ESTAB` verlässt,
`kernel/ath11k-reo-ssn.sh` verwirft dazu den alten Fensteranfang in der
Hardware-Reorder-Queue von ath11k. Beide sind upstream noch offen. Mit
beiden: 5 Neustarts, danach waren jeweils sofort 959 von 960 Mesh-Strecken
per Unicast erreichbar, anschließend 624 von 624 über 2 h ohne Neustart,
kein Firmware-Absturz, keine REO-Fehler.

Offen bleibt eine einzelne 5-GHz-Strecke von einem MR80X v2 zu einem
Nachbarn mit mt76x2: Sie wird wiederholt stumm, linkcheck löscht die
Station etwa alle 30 min. Ein zweiter MR80X v2 am selben Nachbarn zeigt das
nicht. Weder der REO-Patch noch der A-MSDU-Patch (unten) ändern daran
etwas (gemessen 26.11.2026).

## 802.11s: A-MSDU zu Empfängern mit Hardware-Zerlegung

Die ath11k-Firmware zählt beim Senden auf Mesh-Interfaces die Mesh Control
in die Länge der A-MSDU-Teilrahmen mit. Empfänger, die A-MSDUs in Hardware
zerlegen, verwerfen dann alle Teilrahmen außer dem ersten. Florian Maurer
hat das an einem MT7996 gefunden; `kernel/ath11k-mesh-no-amsdu.sh` (Patch
981, upstream noch offen) begrenzt A-MSDUs auf Mesh-vdevs per WMI auf einen
MSDU. Im Bau seit 26112610bro.

Gemessen 26.11.2026 an zwei MR80X v2: TCP direkt über die
Link-Local-Adresse auf dem Mesh-Interface, je 10 s, Mittel aus 3 Läufen,
5 GHz, vor und nach dem Patch:

| Strecke | vorher | nachher |
| --- | ---: | ---: |
| MR80X v2 → MT7986 (MR90X), erster MR80X | 70 Mbit/s | 159 Mbit/s |
| MR80X v2 → MT7986 (MR90X), zweiter MR80X | 35 Mbit/s | 176 Mbit/s |
| MR80X v2 → MR80X v2 | 97 / 188 Mbit/s | 182 / 163 Mbit/s |
| MR80X v2 → MT7981, MT76x2 | 167 bis 183 Mbit/s | 150 bis 180 Mbit/s |
| Sender ohne ath11k (Kontrolle) | 105 bis 379 Mbit/s | innerhalb ±10 % |

Auf 2.4 GHz verdoppelt sich der Durchsatz zum MT7986 ebenfalls. Zu den
übrigen Empfängern kostet der Patch bis zu 10 %. Die
Firmware nimmt die Begrenzung ohne Fehler an (keine Meldung "failed to
disable A-MSDU").

**Backport aus OpenWrt main, ohne Wirkung (Test 25.11.2026):** Ein
lokaler Bau mit allen ath11k-Fixes aus main, die auf 6.12 passen (102 bis
107, 110 bis 115, 117, 118, 955, 956), dazu zwei auf linux-wireless noch
offene Patches: "Avoid adding the same peer twice to a pdev" (Remi
Pommarel) und "don't send A-MSDUs on mesh interfaces" (Florian Maurer,
22.11.2026). Gebaut und auf einem MR80X v2 geflasht, die Firmware nimmt
die A-MSDU-Begrenzung ohne Fehler an. 15 min nach dem Start erreicht der
Knoten per Unicast 1 von 8 Peers auf 2.4 GHz und 4 von 8 auf 5 GHz, also
nicht besser als ohne die Patches. Nicht übernommen, weil der Code in 6.12
fehlt oder anders aussieht: 101, 108, 109, 116, 954. Gemessen wurde nur der
Unicast-Ausfall, kein Patch einzeln. Die Fixes aus main liegen nicht in
diesem Repo. Der A-MSDU-Patch liegt inzwischen als `kernel/981-*` im Repo
(siehe oben). "Avoid adding the same peer twice to a pdev" ist nicht
übernommen: Das Problem, das er behebt, zeigt sich am MR80X v2 nicht. In
den Kernel-Meldungen zweier MR80X v2 vom 25. und 26.11.2026 (250
ath11k-Zeilen) steht keine einzige zu Peers.

Bei solchen Backports auf 6.12 auf die Platzierung achten: patch setzte
den Hunk von 107 ("fix leak in ath11k_service_ready_ext_event") mit Fuzz
in `ath11k_service_ready_ext2_event()`, deren `err:`-Marke in 6.12 gleich
aussieht. Der Bau brach dann ab; ohne Bauabbruch wäre der Fix still an
der falschen Stelle gelandet. Jeden Hunk ohne Fuzz einspielen und den
Funktionsnamen im Hunk-Kopf mit dem Ergebnis vergleichen.

## Inhalt

`openwrt.sh` (pre-update) legt `0001` bis `0044` als
`patches/openwrt/5700-hw-ipq50xx-*` ab, `targets.sh` (post-update) legt
`targets/qualcommax-ipq50xx` an und trägt es in `targets/targets.mk` ein.

| Nr. | Inhalt |
| --- | --- |
| 0001-0005 | qca-ssdk und qca-nss-dp für IPQ50xx, Subtarget ipq50xx |
| 0006-0011 | QPIC-SPI-NAND-Treiber und Fixes |
| 0012-0018 | base-files, uboot-envtools, Q6-Remoteproc-Fixes, bootconfig |
| 0019, 0022-0029, 0038 | ath11k: QCN6122, IPQ5018-Fixes |
| 0020-0021 | `kmod-dsa-rtl8365mb` und SGMII für den RTL8367S (Upstream 0b577e2fe06c, an 6.6 angepasst) |
| 0030-0032 | `kmod-ath11k-smallbuffers` |
| 0033-0037 | ath11k-Firmware, Board-Dateien |
| 0039-0042 | fwup-Image, MR80X v2, WLAN an, factory.bin auch für MR3000X |
| 0043 | nvmem-Kern: Bit-Offsets über einem Byte (Upstream 7a06ef75107799675ea6e4d73b9df37e18e352a8, v6.15) |
| 0044 | qca-ssdk: UNIPHY-Kanal 0 nach dem Port-Reset erzwungen lassen |

Die Upstream-Commits sind mit Autor und Text übernommen. Was für 6.6
angepasst wurde, steht jeweils in einem `[Neanderfunk: ...]`-Absatz am Ende
der Commit-Nachricht.

### 0043 und 0044: zwei Fehler, die nur unter 6.6 auftreten

- **0043:** Stable 6.6.151 hat schon "nvmem: qfprom: switch to 4-byte aligned
  reads", aber nicht den passenden Fix im nvmem-Kern. Jede qfprom-Zelle, die
  nicht an einer durch 4 teilbaren Adresse beginnt, liest dann 0. Beim
  IPQ5018 trifft das die tsens-Kalibrierung: Sensor 3 meldet über 700 °C,
  der Kernel schaltet 1,5 s nach jedem Start wegen Übertemperatur ab
  (Bootschleife).
- **0044:** qca-ssdk setzt bei `forced-speed` das Force-Bit des UNIPHY-Kanals
  vor einem Port-Reset; danach steht der Kanal wieder auf Autonegotiation.
  Der RTL8367S sendet keine, der Kanal bekommt nie Link, und zwischen eth0
  und Switch geht kein Rahmen durch, obwohl beide Seiten "Link up" melden.

## Stand (Test Neanderfunk, 17.10.2026, MR3000X v2.0)

Startet vom Flash, Ethernet (LAN, WAN per DHCP) und beide Radios laufen,
Mesh und VPN stehen. Gemessen unter Gluon mit vollem Mesh:

| Strecke | Durchsatz |
| --- | ---: |
| 5 GHz Client (80 MHz, VHT-MCS 9, NSS 2), hoch / runter | 340 / 208 Mbit/s |
| 2.4 GHz Client (MCS 15), hoch / runter | 46 / 75 Mbit/s |
| 802.11s direkt zu einem Nachbarn, 5 GHz, senden / empfangen | 141 / 444 Mbit/s |
| 802.11s direkt zu einem Nachbarn, 2.4 GHz, senden / empfangen | 148 / 106 Mbit/s |

Speicher: in Ruhe rund 64 MB verfügbar, unter Volllast 31 bis 34 MB.
**`kmod-ath11k-smallbuffers` ist Pflicht:** Mit dem normalen `kmod-ath11k`
läuft das Gerät nach 96 s in den OOM (Kernel-Panic durch `panic_on_oom`),
schon ohne Last.

Offen:

- batman meldet an der Mesh-on-LAN-Brücke eine MTU von 1500.
- Ein Bau der übrigen qualcommax-Targets (ipq807x) mit dieser Serie steht aus.

## Aktivieren und zurücknehmen

Eingehängt über die beiden Zeilen in `apply.sh`. Zurücknehmen: die Zeilen
entfernen (oder das Verzeichnis wieder nach `parked/` legen) und
`qualcommax-ipq50xx` aus der Target-Liste des Baus nehmen.
