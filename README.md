# Pi-hole IPv6 DNS Guard 🛡️

Ein robustes Monitoring-Skript für den Raspberry Pi, das sicherstellt, dass die Fritz!Box weiterhin das Pi-hole als DNS-Server via IPv6 im Netzwerk verteilt.

## 📋 Das Problem
Viele Fritz!Box-Modelle neigen dazu, nach einem IPv6-Präfix-Wechsel (Zwangstrennung) oder einem Firmware-Update die manuellen DNSv6-Einstellungen zu ignorieren und sich selbst als DNS-Server zu bewerben. Dadurch wird das Pi-hole umgangen und Werbung sowie Tracker werden nicht mehr blockiert.

## ✨ Features
- **Erzwungene Aktualisierung:** Führt ein `dhcpcd -n -6` aus, um die neuesten Router-Informationen zu erzwingen.
- **Multicast-Scan:** Nutzt `rdisc6`, um die tatsächlichen Router Advertisements (ICMPv6) im Netzwerk zu sniffen.
- **Intelligenter Abgleich:** Erkennt alle IPv6-Typen des Pi-holes (Global, ULA, Link-Local) und verhindert Fehlalarme bei Adresswechseln.
- **ntfy.sh Integration:** Sendet Push-Benachrichtigungen direkt auf dein Handy.
  - **Priorität Low:** Wenn alles okay ist (Status-Update).
  - **Priorität Urgent:** Wenn eine Fehlkonfiguration erkannt wurde.



## 🚀 Installation

### 1. Voraussetzungen
Installiere die benötigten Netzwerk-Tools auf deinem Raspberry Pi:
```bash
sudo apt update
sudo apt install ndisc6 -y

###2. Repository klonen
Bash

cd /home/raspberry
git clone [https://github.com/sofferl/pi-scripts.git](https://github.com/sofferl/pi-scripts.git)
cd pi-scripts
chmod +x check_dns.sh

###3. Konfiguration

Erstelle eine Datei namens config.env im Verzeichnis /home/raspberry/pi-scripts/. Diese Datei wird von Git ignoriert, um dein ntfy-Thema geheim zu halten:
Bash

echo 'TOPIC="dein_geheimes_ntfy_thema"' > config.env

###🛠️ Automatisierung (Cronjob)

Um das Skript alle 4 Stunden automatisch im Hintergrund laufen zu lassen, füge einen Eintrag in deine Crontab ein:

    crontab -e aufrufen.

    Folgende Zeile am Ende einfügen:

Code-Snippet

0 */4 * * * /bin/bash /home/raspberry/pi-scripts/check_dns.sh >> /home/raspberry/pi-scripts/dns_check.log 2>&1

###🔍 Funktionsweise

    Das Skript löst eine Neukonfiguration der IPv6-Schnittstelle aus.

    Es liest alle aktuell gültigen IPv6-Adressen des Raspberry Pi ein.

    Es scannt das Netzwerk nach dem "Recursive DNS Server"-Eintrag der Fritz!Box.

    Stimmt die beworbene IP mit keiner der lokalen IPs überein, wird ein Alarm via ntfy abgesetzt.

###📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe die LICENSE Datei für Details.
