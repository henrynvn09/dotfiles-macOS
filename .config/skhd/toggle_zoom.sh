#!/usr/bin/env bash

function window_is_float
    set layout $(yabai -m query --spaces --space | jq '.type')
    [ "$layout" = "\"float\"" ] && echo true
    echo $(yabai -m query --windows --window | jq '."is-floating"')
end

function toggle_zoom
    set float $(window_is_float)

    if $float
        mkdir -p /tmp/yabai/zoom_cache
        cd /tmp/yabai/zoom_cache
        set window_id $(yabai -m query --windows --window | jq '.id')

        if [ -e $window_id ]
            cat $window_id | read x y w h
            yabai -m window --resize abs:$w:$h
            yabai -m window --move abs:$x:$y
            rm -rf $window_id
        else
            yabai -m query --windows --window | jq '.frame.x, .frame.y, .frame.w, .frame.h' | tr '\n' ' ' > $window_id
            yabai -m window --grid 1:1:0:0:1:1
        end

    else
        yabai -m window --toggle zoom-fullscreen
    end
end
