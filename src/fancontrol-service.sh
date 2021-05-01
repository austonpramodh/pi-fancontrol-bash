#!/bin/sh

set -e

# Defaults
INTERVAL=30
THRESHOLD=60
GPIO=14

. /etc/pi-fancontrol-bash/config.cfg

echo "INTERVAL=$INTERVAL"
echo "THRESHOLD=$THRESHOLD"
echo "GPIO=$GPIO"

# Check if the gpio pin has been initialized
if [ ! -d "/sys/class/gpio/gpio${GPIO}" ]; then
  echo "${GPIO}" >/sys/class/gpio/export
fi

# Wait for gpio pin to be available
while [ ! -f /sys/class/gpio/gpio${GPIO}/value ]; do
  sleep 1
  echo "fancontrol: sleeping while waiting for file /sys/class/gpio/gpio${GPIO}/value"
done

if [ "$(cat /sys/class/gpio/gpio${GPIO}/direction)" != "out" ]; then
  echo out >/sys/class/gpio/gpio${GPIO}/direction
fi

get_temp() {
  local THERMAL="$(($(cat /sys/devices/virtual/thermal/thermal_zone0/temp) / 1000))"
  echo "$THERMAL"
}

get_status() {
  local STATUS="$(cat /sys/class/gpio/gpio${GPIO}/value)"
  echo "$STATUS"
}

echo "starting at $(date +%d.%m.%Y-%H:%M:%S)"

if [ "$(get_status)" = "1" ]; then
  echo "startup: fan is on at $(get_temp) °C"
else
  echo "startup: fan is off at $(get_temp) °C"
fi

while true; do
  current_temp="$(get_temp)"
  current_status="$(get_status)"
  if [ "$current_temp" -gt "$THRESHOLD" ]; then
    if [ "$current_status" = "0" ]; then
      echo "1" >/sys/class/gpio/gpio${GPIO}/value
      echo "$(date +%d.%m.%Y-%H:%M:%S): fan on at $current_temp °C"
    fi
  else
    # Turn off fan when the temperature is 5 °C less than the threshold
    if [ "$current_temp" -lt "$((THRESHOLD - 5))" ] && [ "$current_status" = "1" ]; then
      echo "0" >/sys/class/gpio/gpio${GPIO}/value
      echo "$(date +%d.%m.%Y-%H:%M:%S): fan off at $current_temp °C"
    fi
  fi
  sleep ${INTERVAL}
done
