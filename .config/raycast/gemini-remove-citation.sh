#!/bin/bash
# Remove citation tags from clipboard text (macOS)
# stolen idea from https://bpetrynski.github.io/gemini-citation-remover/
# because of gemini annoyingly adds citations to the response

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title gemini remove citation
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📎

# Documentation:
# @raycast.description clean citation from gemini clipboard response
# @raycast.author henry_nguyen
# @raycast.authorURL https://raycast.com/henry_nguyen

pbpaste | \
sed -E 's/\[cite_start\]//g; s/\[cite_end\]//g; s/\[cite: *[0-9, ]+\]//g' | \
pbcopy

echo "Cleaned citations removed from clipboard."

