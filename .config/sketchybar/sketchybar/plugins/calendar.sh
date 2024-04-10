#!/bin/bash

# Get the current date with timezone offset
datetime=$(date +' %d.%m.%y %H:%M %z')

# Strip off the timezone offset
datetime_without_offset=$(echo $datetime | awk '{print $1,$2}')

# Set the label without the timezone offset
sketchybar --set $NAME label="$datetime_without_offset"

