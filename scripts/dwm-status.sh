#!/bin/bash

while true; do
    # Battery
    bat=$(cat /sys/class/power_supply/BAT0/capacity)
    bat_status=$(cat /sys/class/power_supply/BAT0/status)
    if [ "$bat_status" = "Charging" ]; then
        bat_icon="+"
    else
        bat_icon=""
    fi

    # RAM usage (percentage)
    ram=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

    # CPU usage
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)

    # Time
    time=$(date "+%a %b %d %H:%M")

    xsetroot -name "CPU ${cpu}% | RAM ${ram}% | BAT ${bat}%${bat_icon} | ${time}"

    sleep 2
done
