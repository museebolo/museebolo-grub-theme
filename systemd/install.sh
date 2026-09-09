#!/usr/bin/env bash

set -euo pipefail

SERVICE_FILE="/etc/systemd/system/museebolo-poweroff.service"
TIMER_FILE="/etc/systemd/system/museebolo-poweroff.timer"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: this script must be run as root."
    exit 1
fi

echo
echo "============================================================"
echo " Musée Bolo - Automatic poweroff installation"
echo "============================================================"
echo

cat > "${SERVICE_FILE}" <<'EOF'
[Unit]
Description=Musée Bolo automatic poweroff

[Service]
Type=oneshot
ExecStart=/usr/sbin/poweroff
EOF

cat > "${TIMER_FILE}" <<'EOF'
[Unit]
Description=Musée Bolo automatic poweroff timer

[Timer]
OnCalendar=*-*-* 00:30:00
Persistent=false

[Install]
WantedBy=timers.target
EOF

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling automatic poweroff timer..."
systemctl enable --now museebolo-poweroff.timer

echo
echo "Installation completed."
echo
echo "Next scheduled poweroff:"
systemctl list-timers museebolo-poweroff.timer
echo
