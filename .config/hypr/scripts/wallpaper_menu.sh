#!/bin/bash

# Define wallpaper directory (must be the expanded path)
WALLPAPER_DIR="$HOME/.config/backgrounds/"

# Define the path to the wallpaper script
WALLPAPER_SCRIPT="$HOME/.config/hypr/scripts/wallpaper.sh"

# Ensure the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR" | wofi -d -p "ERROR"
    exit 1
fi

# 1. Pipe all wallpaper files to wofi for selection
# Use find to list PNG and JPG files and pipe them to wofi
selected_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | wofi --show dmenu -p "Select Wallpaper:")

if [ -n "$selected_wallpaper" ]; then
    bash "$WALLPAPER_SCRIPT" "$selected_wallpaper" &
fi
