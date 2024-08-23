#!/usr/bin/env bash
# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/config/dotfiles/backgrounds"

if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon
fi

# Set a random wallpaper from the directory using swww
swww img  "$WALLPAPER_DIR"
