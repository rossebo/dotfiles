#!/bin/bash

# Get connected monitors
MONITORS=($(aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}"))

for monitor in "${MONITORS[@]}"; do
    # Get workspaces specific to this monitor
    WORKSPACE_IDS=($(aerospace list-workspaces --monitor "$monitor" --format "%{id}"))

    for sid in "${WORKSPACE_IDS[@]}"; do
        sketchybar --add space space.$monitor.$sid left \
            --set space.$monitor.$sid space=$sid \
            icon=$sid \
            label.font="sketchybar-app-font:Regular:16.0" \
            label.padding_right=20 \
            label.y_offset=1 \
            script="$PLUGIN_DIR/space.sh"

        if [ $? -ne 0 ]; then
            echo "Error adding space $sid for monitor $monitor"
            continue
        fi
    done

    # Adding a space separator for each monitor if desired
    sketchybar --add item space_separator.$monitor left \
        --set space_separator.$monitor icon="􀆊" \
        icon.color=$ACCENT_COLOR \
        icon.padding_left=4 \
        label.drawing=off \
        background.drawing=off \
        script="$PLUGIN_DIR/space_windows.sh" \
        --subscribe space_separator.$monitor space_windows_change
done
