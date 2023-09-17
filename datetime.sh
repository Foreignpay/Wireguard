#!/bin/bash

TODAY=$(date "+%Y-%m-%d")

while IFS=, read -r CLIENT_NAME EXPIRY_DATE CLIENT_IP; do
    if [[ "$TODAY" > "$EXPIRY_DATE" ]]; then
        # Удаление из конфигурации сервера
        sed -i "/\[Peer\]/,/${CLIENT_NAME}_public.key/d" /etc/wireguard/wg0.conf

        # Удаление файлов ключей
        rm /etc/wireguard/${CLIENT_NAME}_private.key
        rm /etc/wireguard/${CLIENT_NAME}_public.key

        # Удаление из файла истечения срока
        sed -i "/${CLIENT_NAME},${EXPIRY_DATE},${CLIENT_IP}/d" /home/wireguard/client_expiry.txt

        # Удаление IP из assigned_ips
        sed -i "/^${CLIENT_IP}$/d" /home/wireguard/assigned_ips.txt
    fi
done < /home/wireguard/client_expiry.txt