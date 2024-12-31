#!/usr/env/bin bash
while true; do
    WID=$(xdotool getwindowfocus)
    xdotool mousemove --window $WID 10 10
    sleep 0.1
done

