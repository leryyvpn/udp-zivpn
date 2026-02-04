#!/bin/bash
# ZIVPN UDP Installer
# Author: leryyvpn

set -e

VERSION="udp-zivpn_1.4.9"
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
  BIN_NAME="udp-zivpn-linux-amd64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  BIN_NAME="udp-zivpn-linux-arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

PRIMARY_URL="https://github.com/leryyvpn/udp-zivpn/releases/download/${VERSION}/${BIN_NAME}"
FALLBACK_URL="https://github.com/roodyzain99/udp-zivpn/releases/download/${VERSION}/${BIN_NAME}"

echo "▶ Installing dependencies..."
apt update -y
apt install -y curl wget jq ufw openssl

echo "▶ Downloading ZIVPN binary..."
if ! wget -O /usr/local/bin/zivpn-bin "$PRIMARY_URL"; then
  echo "⚠ Primary source failed, using fallback..."
  wget -O /usr/local/bin/zivpn-bin "$FALLBACK_URL"
fi

chmod +x /usr/local/bin/zivpn-bin

echo "▶ Preparing config..."
mkdir -p /etc/zivpn
wget -qO /etc/zivpn/config.json https://raw.githubusercontent.com/leryyvpn/udp-zivpn/main/config.json

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/zivpn/zivpn.key \
  -out /etc/zivpn/zivpn.crt \
  -subj "/CN=zivpn" >/dev/null 2>&1

echo "▶ Creating service..."
cat >/etc/systemd/system/zivpn.service <<EOF
[Unit]
Description=ZIVPN UDP Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/zivpn-bin server -c /etc/zivpn/config.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable zivpn
systemctl start zivpn

ufw allow 5667/udp
ufw allow 6000:19999/udp

echo "✅ ZIVPN UDP installed successfully"
echo "▶ Type: zivpn (after menu script installed)"