#! /bin/sh

echo "Installing the config file"
mkdir -p /etc/pi-fancontrol-bash
cp ./config.cfg /etc/pi-fancontrol-bash/config.cfg

echo "Installing the service"

cp ./src/fancontrol-service.sh /etc/pi-fancontrol-bash/fancontrol-service.sh
chmod +x /etc/pi-fancontrol-bash/fancontrol-service.sh

cp ./src/pi-fancontrol-bash.service /etc/systemd/system/pi-fancontrol-bash.service

echo "Starting the service"

systemctl daemon-reload
systemctl start pi-fancontrol-bash.service

echo "Service installed successfully"
