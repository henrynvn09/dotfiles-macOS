#!/usr/bin/env bash

window_pid=$(yabai -m query --windows --window | jq -r '.pid') 
count_pid=$(yabai -m query --windows | jq "[.[] | select(.pid == ${window_pid})] | length")

app_name=$(yabai -m query --windows --window | jq -r '.app') 

if [ "$app_name" = "Finder"]; then
	yabai -m window --minimize
  exit
fi

if [ "$count_pid" -gt 1 ]; then
	yabai -m window --close
else
	# kill "${window_pid}"
  osascript -e "tell application \"Finder\" to set p to item 1 of (get file of (processes whose frontmost = true)) as text" -e "tell application p to quit"
fi
