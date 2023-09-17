#!/bin/bash

TODAY=$(date "+%Y-%m-%d")

while IFS=, read -r CLIENT_NAME EXPIRY_DATE CLIENT_IP; do
    if [[ "$TODAY" > "$EXPIRY_DATE" ]]; then
        # �������� �� ������������ �������
        sed -i "/\[Peer\]/,/${CLIENT_NAME}_public.key/d" /etc/wireguard/wg0.conf

        # �������� ������ ������
        rm /etc/wireguard/${CLIENT_NAME}_private.key
        rm /etc/wireguard/${CLIENT_NAME}_public.key

        # �������� �� ����� ��������� �����
        sed -i "/${CLIENT_NAME},${EXPIRY_DATE},${CLIENT_IP}/d" /home/wireguard/client_expiry.txt

        # �������� IP �� assigned_ips
        sed -i "/^${CLIENT_IP}$/d" /home/wireguard/assigned_ips.txt
    fi
done < /home/wireguard/client_expiry.txt