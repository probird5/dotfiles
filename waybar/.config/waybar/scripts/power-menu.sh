#!/usr/bin/env bash

options="Lock\nSuspend\nLogout\nReboot\nShutdown"

choice=$(echo -e "$options" | rofi -dmenu -p "Power" -i)

case "$choice" in
    Lock) hyprlock ;;
    Suspend) hyprlock & sleep 0.5 && systemctl suspend ;;
    Logout) hyprctl dispatch exit ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
