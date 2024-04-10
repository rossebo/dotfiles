#!/bin/bash

source "$CONFIG_DIR/colors.sh" 

sketchybar --add item calendar right \
           --set calendar icon=􀧞  \
                          update_freq=5\
                          label.color=$BAR_COLOR \
                          icon.color=$BAR_COLOR \
                          background.color=$ACCENT_COLOR \
                          script="$PLUGIN_DIR/calendar.sh"
