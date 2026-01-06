#!/bin/bash

# Get connected monitors
MONITORS=($(aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}"))

for monitor in "${MONITORS[@]}"; do
    # Get workspaces specific to this monitor
    WORKSPACE_IDS=($(aerospace list-workspaces --monitor "$monitor" --format "%{id}"))

    # Debugging output to verify monitor and workspace IDs
    echo "Adding spaces for Monitor ID: $monitor"
    echo "Workspace IDs: ${WORKSPACE_IDS[@]}"

    for sid in "${WORKSPACE_IDS[@]}"; do
        sketchybar --add space space.$monitor.$sid left \
            --set space.$monitor.$sid space=$sid \
            icon=$sid \
            label.font="sketchybar-app-font:Regular:16.0" \
            script="$PLUGIN_DIR/space.sh"

        if [ $? -ne 0 ]; then
            echo "Error adding space $sid for monitor $monitor"
            continue
        fi
    done
done

