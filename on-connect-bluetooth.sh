#!/bin/sh

# This script checks if a a2dp bluetooth device is connected and if so, create the file /tmp/bluetooth-a2dp-connected.
# Otherwise, it removes the file. To be used with i3status.

# For the script to run on connect/disconnect of bluetooth devices, enable the following udev rules:
# cat > /etc/udev/rules.d/42-bluetooth-i3status.rules
# ACTION=="add", SUBSYSTEM=="bluetooth", RUN+="/bin/sh -c '/home/jedi/sh/on-connect-bluetooth.sh > /tmp/on-connect-bluetooth.log 2>&1'"
# ACTION=="remove", SUBSYSTEM=="bluetooth", RUN+="/bin/sh -c '/home/jedi/sh/on-connect-bluetooth.sh > /tmp/on-connect-bluetooth.log 2>&1'"

echo "Executing bluetooth script...|$ACTION|"

ACTION=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")
if [ "$ACTION" = "add" -o "$ACTION" = "remove" ]
then
  sleep 1
  CONFIRM=`bluetoothctl info | grep 00001108-0000-1000-8000-00805f9b34fb`
  if [ ! -z "$CONFIRM" ]
  then
    touch /tmp/bluetooth-a2dp-connected
  else
    rm -f /tmp/bluetooth-a2dp-connected        
  fi
fi

