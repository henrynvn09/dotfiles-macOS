#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title toggle monitor
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 💻

# Documentation:
# @raycast.author henry_nguyen
# @raycast.authorURL https://raycast.com/henry_nguyen

# get main display
result=$(brightness -l 2>/dev/null | grep -Eo "display 1:.*ID 0x[0-9a-f]+|display 1: brightness [0-9.]+")
id=$(echo "$result" | grep -Eo "ID 0x[0-9a-f]+" | cut -d'x' -f2)
brightness=$(echo "$result" | grep -Eo "brightness [0-9.]+" | awk '{print $2}')

if [[ "$(echo "$brightness == 0" | bc -l)" -eq 1 ]]; then
  brightness -d $id 0.8
  echo "screen on"
else
  brightness -d $id 0 
  echo "screen off"
fi

