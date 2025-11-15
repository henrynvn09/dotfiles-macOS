#!/bin/bash

# Required parameters
# @raycast.schemaVersion 1
# @raycast.title Set Dell Monitor Brightness  
# @raycast.mode compact
# @raycast.packageName System
# @raycast.icon 🔆
# @raycast.argument1 { "type": "text", "placeholder": "0-10 or empty to toggle", "optional": true }

arg="$1"

# If no argument provided, toggle between 0.5 and 0.8
if [ -z "$arg" ]; then
    # Get current brightness (simplified - just toggle)
    current_file="/tmp/raycast_brightness_state"
    if [ -f "$current_file" ] && [ "$(cat "$current_file")" = "0.8" ]; then
        brightness="0.5"
    else
        brightness="0.8"
    fi
    echo "$brightness" > "$current_file"
else
    # Convert argument (0-10) to brightness (0.0-1.0)
    brightness=$(echo "scale=1; $arg / 10" | bc)
fi

# Execute BetterDisplay command
/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay set -name="DELL U2723QE" -brightness="$brightness"

echo "Set brightness to $brightness"