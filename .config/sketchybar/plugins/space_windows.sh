#!/bin/bash

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Get all visible workspaces
  mapfile -t workspaces < <(aerospace list-workspaces --format "%{id} %{workspace-is-focused} %{workspace-is-visible}")

  for workspace_info in "${workspaces[@]}"; do
    workspace=$(echo "$workspace_info" | awk '{print $1}')
    is_visible=$(echo "$workspace_info" | awk '{print $3}')

    if [ "$is_visible" = "true" ]; then
      apps=$(aerospace list-windows --workspace "$workspace" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
      sketchybar --set space.$workspace drawing=on

      if [ "${apps}" != "" ]; then
        icon_strip=" "
        while read -r app; do
          icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
        done <<<"${apps}"
        sketchybar --set space.$workspace label="$icon_strip"
      else
        sketchybar --set space.$workspace label="No apps"
      fi
    fi
  done
fi
