#!/usr/bin/env bash
# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/config/dotfiles/backgrounds"

if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon
fi

sleep 3

RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set a random wallpaper from the directory using swww
swww img "$RANDOM_WALLPAPER" --transition-type wipe --transition-angle 30 --transition-fps 255 --transition-duration 2
