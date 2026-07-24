#!/bin/sh
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 8 silent] firefox --kiosk -P homeassistant --new-instance http://localhost:8123")'
