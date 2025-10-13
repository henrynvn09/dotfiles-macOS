#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title resume rename
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝

# Documentation:
# @raycast.description rename latest "unified resume" downloaded to Henry Nguyen Resume
# @raycast.author henry_nguyen
# @raycast.authorURL https://raycast.com/henry_nguyen
downloads="/Users/henry/Downloads"
latest_file=$(find "$downloads" -name "unified_resume*.pdf" -mtime -5m -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)

if [ -n "$latest_file" ]; then
    mv "$latest_file" "$downloads/Henry Nguyen Resume.pdf"
    echo "Renamed $latest_file to Henry Nguyen Resume.pdf"
else
    echo "No unified_resume*.pdf files found"
fi

