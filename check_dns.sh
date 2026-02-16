#!/bin/bash

# --- KONFIGURATION ---
IFACE="eth0"

source "$(dirname "$0")/config.env"
# ---------------------

# 1. DHCPv6 Lease erneuern
sudo dhcpcd -n -6 $IFACE > /dev/null 2>&1
sleep 5

# 2. ALLE eigenen IPv6 Adressen abgreifen
# Wir holen die IPs und machen daraus eine schöne Liste für die Nachricht
MY_IP_LIST=$(ip -6 addr show $IFACE | grep 'inet6' | awk '{print $2}' | cut -d/ -f1)

# Formatierung für die Notification (alle IPs in einer Zeile, mit Komma getrennt)
FORMATTED_IPS=$(echo "$MY_IP_LIST" | tr '\n' ' ' | sed 's/ $//; s/ /, /g')

# 3. Aktuelle DNS-Info von der Fritz!Box abgreifen
ADVERTISED_DNS=$(rdisc6 $IFACE 2>/dev/null | grep 'Recursive DNS server' | awk '{print $5}')

# --- PRÜFUNG ---

if [ -z "$ADVERTISED_DNS" ]; then
    curl -H "Title: DNS Fehler" -H "Priority: high" \
         -d "Kein IPv6 DNS gefunden! Pi-hole IPs: $FORMATTED_IPS" \
         "ntfy.sh/$TOPIC"
    exit 1
fi

# Check: Ist die von der Fritzbox gemeldete IP in unserer Liste?
if echo "$MY_IP_LIST" | grep -q "$ADVERTISED_DNS"; then
    echo "$(date): Alles okay ($ADVERTISED_DNS)."
else
    # Fehlermeldung mit allen Details
    MESSAGE="⚠️ DNS-MISMATCH!
    
Fritz!Box verteilt: $ADVERTISED_DNS
    
Erlaubte Pi-hole IPs:
$FORMATTED_IPS"

    curl -H "Title: DNS Alarm!" \
         -H "Priority: urgent" \
         -H "Tags: alert,dns" \
         -d "$MESSAGE" \
         "ntfy.sh/$TOPIC"
    
    echo "$(date): Alarm gesendet! Fritzbox nutzt $ADVERTISED_DNS"
fi
