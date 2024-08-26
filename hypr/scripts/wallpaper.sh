#!/usr/bin/env bash
# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/config/dotfiles/backgrounds"

if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon
fi

RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set a random wallpaper from the directory using swww
swww img "$RANDOM_WALLPAPER" --transition-type wipe --transition-angle 30 --transition-step 255 --transition-fps 120 --transition-duration 3
