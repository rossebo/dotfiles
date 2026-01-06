#!/bin/bash

# 1. Load colors
source "$CONFIG_DIR/colors.sh"

# 2. Extract the workspace ID (e.g., "space.1" -> "1")
SID="${NAME#*.}"

# 3. Handle the workspace change event
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  
  # 4. Source of Truth: Ask Aerospace directly who is focused
  # (This is safer than relying on variables passed from aerospace.toml)
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
  
  if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    # --- FOCUSED STATE ---
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color=$ACCENT_COLOR \
        label.color=$BAR_COLOR \
        icon.color=$BAR_COLOR
  else
    # --- UNFOCUSED STATE ---
    sketchybar --set "$NAME" \
        background.drawing=off \
        label.color=$ACCENT_COLOR \
        icon.color=$ACCENT_COLOR
  fi
fi
