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

# 2. If a wallpaper was selected (not empty)
if [ -n "$selected_wallpaper" ]; then
    # 3. Execute the main script with the selected path as the argument
    # Use 'sh' to execute the main script, ensuring it's in a subshell
    sh "$WALLPAPER_SCRIPT" "$selected_wallpaper" &
fi
