#!/bin/bash

# ���������� ������� � ��������� wireguard � curl
sudo apt update && sudo apt install -y wireguard curl

# ��������� ������ �������
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key

# �������� � ��������� ������ ������� (���� ��� ��� �� �������)
if [[ ! -f /etc/wireguard/server_private.key || ! -f /etc/wireguard/server_public.key ]]; then
    wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
    echo "Server keys generated."
else
    echo "Server keys already exist."
fi

# ��������� ��������� ���� �������
SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)

# �������� ����������������� ����� ������� (���� �� ��� �� ����������)
if [[ ! -f /etc/wireguard/wg0.conf ]]; then
    cat <<EOL | sudo tee /etc/wireguard/wg0.conf
[Interface]
PrivateKey = ${SERVER_PRIVATE_KEY}
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOL

    echo "Server configuration file created."
else
    echo "Server configuration file already exists."
fi

# ��������� � ������ ������ WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

echo "WireGuard server setup complete."
