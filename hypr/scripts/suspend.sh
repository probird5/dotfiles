#!/usr/bin/env bash

#!/bin/bash

# Set idle times in seconds
IDLE_TIME_LOCK=300        # Time in seconds before the screen locks
IDLE_TIME_MONITOR_OFF=600 # Time in seconds before turning off the monitors
IDLE_TIME_SUSPEND=900     # Time in seconds before system suspends

# Function to lock the screen
lock_screen() {
    hyprlock &
}

# Function to turn off the monitors
turn_off_monitors() {
    hyprctl dispatch dpms off
}

# Function to suspend the system
suspend_system() {
    systemctl suspend
}

# Function to turn monitors back on after wake
wake_monitors() {
    hyprctl dispatch dpms on
}

# Monitor idle time using hypridle
while true; do
    # Get idle time in milliseconds
    idle_time=$(hypridle -j | jq '.idle' | awk '{print $1/1000}')

    if (( idle_time >= IDLE_TIME_SUSPEND )); then
        # Suspend the system if idle time exceeds suspend threshold
        suspend_system
        sleep 1
    elif (( idle_time >= IDLE_TIME_MONITOR_OFF )); then
        # Turn off the monitors if idle time exceeds monitor off threshold
        turn_off_monitors
    elif (( idle_time >= IDLE_TIME_LOCK )); then
        # Lock the screen if idle time exceeds lock threshold
        lock_screen
    else
        # If system wakes up, turn monitors back on
        wake_monitors
    fi

    # Sleep for a short interval to reduce CPU usage
    sleep 5
done
