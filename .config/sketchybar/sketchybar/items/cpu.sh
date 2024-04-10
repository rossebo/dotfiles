#!/bin/bash

sketchybar --add item cpu right \
	--set cpu update_freq=5\
		background.drawing=off \
		icon=􀧓 \
		script="$PLUGIN_DIR/cpu.sh"
