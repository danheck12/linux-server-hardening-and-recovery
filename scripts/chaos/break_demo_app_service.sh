#!/usr/bin/env bash
set -e

SERVICE_FILE="/etc/systemd/system/demo-app.service"

echo "[*] Backing up service file..."
sudo cp $SERVICE_FILE ${SERVICE_FILE}.bak.$(date +%F-%T)

echo "[*] Breaking ExecStart..."
sudo sed -i 's|^ExecStart=.*|ExecStart=/opt/demo-app/does-not-exist.sh|' $SERVICE_FILE

echo "[*] Reloading systemd..."
sudo systemctl daemon-reload

echo "[*] Restarting service (expected to fail)..."
sudo systemctl restart demo-app || true

echo "[*] Current status:"
systemctl status demo-app --no-pager
