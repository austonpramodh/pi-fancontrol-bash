#!/bin/sh

echo "Stopping the service"

systemctl stop pi-fancontrol-bash.service

echo "Uninstalling the service"

systemctl disable pi-fancontrol-bash.service
rm -f /etc/systemd/system/pi-fancontrol-bash.service
systemctl daemon-reload

rm -rf /etc/pi-fancontrol-bash

echo "Service uninstalled successfully"
