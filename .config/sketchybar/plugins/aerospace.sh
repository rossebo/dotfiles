#!/usr/bin/env bash

echo $FOCUSED_WORKSPACE
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.color=0xff003547  label.shadow.drawing=on icon.shadow.drawing=on background.border_width=2
# background.color=0x88FF00FF
else
  sketchybar --set $NAME label.shadow.drawing=off icon.shadow.drawing=off background.border_width=0
fi
