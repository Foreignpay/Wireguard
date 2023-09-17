#!/bin/bash

CLIENT_NAME="$1"
LIFETIME_MONTHS="$2"

# Ãåíåðàöèÿ êëþ÷åé
wg genkey | tee /etc/wireguard/${CLIENT_NAME}_private.key | wg pubkey > /etc/wireguard/${CLIENT_NAME}_public.key

# Íàçíà÷åíèå IP
if [[ ! -f /home/wireguard/assigned_ips.txt ]]; then
    # Åñëè ôàéëà íåò, íà÷íåì ñ 10.0.0.2
    NEXT_IP="10.0.0.2"
else
    LAST_IP=$(tail -1 /home/wireguard/assigned_ips.txt)
    if [[ -z "$LAST_IP" ]]; then
        NEXT_IP="10.0.0.2"
    else
        NEXT_IP=$(echo $LAST_IP | awk -F. '{print $1"."$2"."$3"."$4+1}')
    fi
fi
echo $NEXT_IP >> /home/wireguard/assigned_ips.txt

# Äîáàâëåíèå êëèåíòà â êîíôèãóðàöèþ ñåðâåðà
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "PublicKey = $(cat /etc/wireguard/${CLIENT_NAME}_public.key)" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = ${NEXT_IP}/32" >> /etc/wireguard/wg0.conf

# Çàïèñü äàòû èñòå÷åíèÿ ñðîêà äåéñòâèÿ
EXPIRY_DATE=$(date -d "+${LIFETIME_MONTHS} month" "+%Y-%m-%d")
echo "${CLIENT_NAME},${EXPIRY_DATE},${NEXT_IP}" >> /home/wireguard/client_expiry.txt

SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/${CLIENT_NAME}_private.key)
EXTERNAL_IP=$(curl -s ifconfig.me)

echo "[Interface]" > /home/wireguard/${CLIENT_NAME}.conf
echo "PrivateKey = ${CLIENT_PRIVATE_KEY}" >> /home/wireguard/${CLIENT_NAME}.conf
echo "Address = ${NEXT_IP}/32" >> /home/wireguard/${CLIENT_NAME}.conf
echo "DNS = 1.1.1.1" >> /home/wireguard/${CLIENT_NAME}.conf
echo "" >> /home/wireguard/${CLIENT_NAME}.conf
echo "[Peer]" >> /home/wireguard/${CLIENT_NAME}.conf
echo "PublicKey = ${SERVER_PUBLIC_KEY}" >> /home/wireguard/${CLIENT_NAME}.conf
echo "Endpoint = ${EXTERNAL_IP}:51820" >> /home/wireguard/${CLIENT_NAME}.conf
echo "AllowedIPs = 0.0.0.0/0, ::/0" >> /home/wireguard/${CLIENT_NAME}.conf

cat /home/wireguard/${CLIENT_NAME}.conf
