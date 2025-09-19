#!/usr/bin/env bash

WALLPAPER_DIR="$WALLPAPER_DIR"

CURRENT_WALL_PATH=$(hyprctl hyprpaper listactive | grep 'Wallpaper' | awk -F ' ' '{print $2}')

WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -path "$CURRENT_WALL_PATH" | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
fi

wal -i "$WALLPAPER" -q -s -t

MONITOR=$(hyprctl monitors | awk '/^Monitor/ {print $2}')
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"

echo "Restart waybar"
killall -SIGUSR2 waybar
