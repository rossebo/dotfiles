#!/bin/bash

# --- 1. ENVIRONMENT & MONITOR SETUP ---

# This line is primarily for debugging; make sure $WALLPAPER_DIR is exported externally.
echo "Wallpaper Dir: $WALLPAPER_DIR" 

# Use jq to get the currently focused monitor for robustness (requires 'jq')
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Fallback in case jq or focus detection fails (gets the first listed monitor)
if [ -z "$MONITOR" ]; then
    MONITOR=$(hyprctl monitors | awk '/^Monitor/ {print $2}' | head -n 1)
fi

# Critical check: Exit gracefully if no monitor is found
if [ -z "$MONITOR" ]; then
    echo "ERROR: Could not determine active monitor. Aborting script."
    exit 1
fi

echo "Monitor: $MONITOR"

# --- 2. SELECT WALLPAPER ---

# Safer parsing for current wallpaper, assuming hyprpaper is now working.
CURRENT_WALL_PATH=$(hyprctl hyprpaper listactive | awk -F ' = ' '{print $2}' | head -n 1)

# Find a random wallpaper that is not the current one.
WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -path "$CURRENT_WALL_PATH" | shuf -n 1)

# Fallback in case the directory only contains the current wallpaper
if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
fi

echo "Selected Wallpaper: $WALLPAPER"

if [ -z "$WALLPAPER" ]; then
    echo "ERROR: No wallpapers found in $WALLPAPER_DIR. Aborting."
    exit 1
fi

# --- 3. APPLY COLORS (WAL) & RELOAD WAYBAR ---

# 1. Run pywal FIRST to extract colors and generate templates
wal -i "$WALLPAPER" -q -s -t 

echo "Restarting waybar to apply new colors"
# Use pkill -USR2 for cross-compatibility
pkill -SIGUSR2 waybar

# --- 4. APPLY WALLPAPER (HYPRPAPER) ---

# 2. Tell hyprpaper to reload/set the new wallpaper
hyprctl hyprpaper reload "$MONITOR,$WALLPAPER"
