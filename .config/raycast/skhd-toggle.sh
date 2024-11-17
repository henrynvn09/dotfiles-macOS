#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title skhd-toggle
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description enable/disable skhd
# @raycast.author henry_nguyen
# @raycast.authorURL https://raycast.com/henry_nguyen


# Stop the service
skhd --stop-service

# Check the exit status of the previous command
if [ $? -ne 0 ]; then
    echo "start skhd"
    skhd --start-service
else
    echo "stop skhd"
fi

