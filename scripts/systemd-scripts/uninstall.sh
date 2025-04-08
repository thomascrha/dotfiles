#!/bin/bash

# Function to uninstall a service or timer
uninstall_unit() {
    local unit_name=$1
    local unit_type=$2

    echo "Stopping $unit_name $unit_type..."
    systemctl --user stop $unit_name

    echo "Disabling $unit_name $unit_type..."
    systemctl --user disable $unit_name

    echo "Removing $unit_name.$unit_type file..."
    sudo rm -f "/usr/lib/systemd/user/$unit_name.$unit_type"

    # If there's a start script, remove it too
    if [ -f "/usr/lib/systemd/user/$unit_name-start.sh" ]; then
        echo "Removing $unit_name-start.sh..."
        sudo rm -f "/usr/lib/systemd/user/$unit_name-start.sh"
    fi
}

# Loop through all service files in the current directory
echo "Uninstalling services..."
for file in *.service; do
    # Skip if no service files exist (*.service expands to itself)
    [ ! -f "$file" ] && continue

    service_name=$(basename $file .service)
    if systemctl --user list-unit-files | grep -q $service_name; then
        echo "Uninstalling service: $service_name"
        uninstall_unit $service_name "service"
    else
        echo "Service $service_name is not installed. Skipping."
    fi
done

# Loop through all timer files in the current directory
echo "Uninstalling timers..."
for file in *.timer; do
    # Skip if no timer files exist (*.timer expands to itself)
    [ ! -f "$file" ] && continue

    timer_name=$(basename $file .timer)
    if systemctl --user list-unit-files | grep -q $timer_name; then
        echo "Uninstalling timer: $timer_name"
        uninstall_unit $timer_name "timer"
    else
        echo "Timer $timer_name is not installed. Skipping."
    fi
done

# Reload systemd daemon to apply changes
echo "Reloading systemd daemon..."
systemctl --user daemon-reload

echo "Uninstallation complete!"

