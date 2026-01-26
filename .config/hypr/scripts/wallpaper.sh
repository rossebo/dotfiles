#!/bin/bash

# --- 1. SETUP VARIABLES ---
# Define directory and find monitor
WALLPAPER_DIR="$HOME/.config/backgrounds/"
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Fallback if jq fails
if [ -z "$MONITOR" ]; then
    MONITOR=$(hyprctl monitors | awk '/^Monitor/ {print $2}' | head -n 1)
fi

# --- 2. SELECT WALLPAPER ---
if [ -n "$1" ] && [ -f "$1" ]; then
    # If argument provided (from menu), use it
    WALLPAPER="$1"
else
    # Otherwise pick random
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
fi

echo "Setting $WALLPAPER on $MONITOR"

# --- 3. GENERATE COLORS (Pywal) ---
# Check if wal exists before running to avoid errors
if command -v wal &> /dev/null; then
    wal -i "$WALLPAPER" -n -q -t
    pkill -SIGUSR2 waybar
fi

# --- 4. APPLY WALLPAPER (The Fix) ---
# Hyprpaper now STRICTLY requires 'preload' then 'wallpaper'

# 1. Unload everything to free RAM (Optional but recommended)
hyprctl hyprpaper unload all

# 2. Preload the new image into memory
hyprctl hyprpaper preload "$WALLPAPER"

# 3. Apply the image to the monitor
# Syntax: hyprctl hyprpaper wallpaper "monitor,path"
hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"

# --- 5. UPDATE LOCKSCREEN ---
export WALLPAPER="$WALLPAPER"
if [ -f "$HOME/.config/hypr/scripts/blurred_wallpaper.sh" ]; then
    bash "$HOME/.config/hypr/scripts/blurred_wallpaper.sh" &
fi
