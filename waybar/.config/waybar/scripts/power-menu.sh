#!/usr/bin/env bash

choice=$(printf '%s\n' Lock Suspend Logout Reboot Shutdown | rofi -dmenu -p "Power" -i)

lock_screen() {
    pidof hyprlock >/dev/null && return 0
    setsid -f hyprlock --immediate-render --no-fade-in >/tmp/hyprlock.log 2>&1
}

case "$choice" in
    Lock) lock_screen ;;
    Suspend) lock_screen; sleep 0.5 && systemctl suspend ;;
    Logout) hyprctl --instance 0 dispatch 'hl.dsp.exit()' ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
