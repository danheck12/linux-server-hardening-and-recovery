#!/usr/bin/env bash
set -e

TARGET_DIR="/var/log/demo-app"

echo "[*] Creating log directory if missing..."
sudo mkdir -p $TARGET_DIR

echo "[*] Breaking permissions (root:root, 700)..."
sudo chown root:root $TARGET_DIR
sudo chmod 700 $TARGET_DIR

echo "[*] Current state:"
ls -ld $TARGET_DIR

echo "[*] Permissions incident injected."
