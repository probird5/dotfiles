#!/bin/sh

# Auto-detect compositor and launch waybar with the correct config
CONFIG_DIR="$HOME/.config/waybar"

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || pgrep -x Hyprland > /dev/null 2>&1; then
    CONFIG="$CONFIG_DIR/config-hyprland.jsonc"
elif pgrep -x mangowc > /dev/null 2>&1; then
    CONFIG="$CONFIG_DIR/config-mangowc.jsonc"
else
    # Fallback to Hyprland config
    CONFIG="$CONFIG_DIR/config-hyprland.jsonc"
fi

exec waybar -c "$CONFIG" -s "$CONFIG_DIR/style.css"
