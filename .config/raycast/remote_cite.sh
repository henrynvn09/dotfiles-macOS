#!/bin/bash
# Remove citation tags from clipboard text (macOS)
# stolen idea from https://bpetrynski.github.io/gemini-citation-remover/
# because of gemini annoyingly adds citations to the response

pbpaste | \
sed -E 's/\[cite_start\]//g; s/\[cite_end\]//g; s/\[cite: *[0-9, ]+\]//g' | \
pbcopy

echo "Cleaned citations removed from clipboard."

