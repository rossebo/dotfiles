#!/bin/zsh

# Define the cache directory and blurred wallpaper path
CACHE_DIR="$HOME/.cache"
BLURRED_WALLPAPER="$CACHE_DIR/blurred_wallpaper.png"

# Create the cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Define the path to the default background
DEFAULT_BACKGROUND="$HOME/.config/backgrounds/shaded.png"

# Check if the default background file exists
if [ ! -f "$DEFAULT_BACKGROUND" ]; then
    echo "Default background not found at: $DEFAULT_BACKGROUND"
    exit 1
fi

# Generate a blurred version of the wallpaper
magick "$DEFAULT_BACKGROUND" -blur 0x8 "$BLURRED_WALLPAPER"

# Check if the blurred image was created successfully
if [ $? -eq 0 ]; then
else
    echo "Failed to create blurred wallpaper."
    exit 1
fi
