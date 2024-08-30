#!/usr/bin/env bash
# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/config/dotfiles/backgrounds"

RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set a random wallpaper from the directory using swww
swww img "$RANDOM_WALLPAPER" --transition-type wipe --transition-angle 30 --transition-step 90 --transition-duration 2
