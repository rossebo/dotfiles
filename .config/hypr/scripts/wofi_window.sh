#!/usr/bin/env bash

# 1. Generate a clean list with the address safely locked inside brackets at the very end
selection=$(hyprctl -j clients | jq -r '.[] | "[\(.workspace.name)] \(.class) | \(.title) [\(.address)]"' | wofi --show dmenu --prompt "Switch to window:" --width=800 --height=400)

if [ -n "$selection" ]; then
    # 2. Extract the exact hex address from the brackets
    address=$(echo "$selection" | grep -o '\[0x[0-9a-fA-F]*\]$' | tr -d '[]')

    if [ -n "$address" ]; then
        # 3. Focus the target window directly by its unique hex signature
        hyprctl dispatch focuswindow "address:$address"
        
        # 4. 💥 THE BREAKTHROUGH: If it's a stacked fullscreen window (like duplicate WoWs),
        # this forces it to recalculate and yanks it to the absolute front of the screen.
        hyprctl dispatch bringactivetotop
    fi
fi
