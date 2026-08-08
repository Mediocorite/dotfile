#!/usr/bin/env bash
# Start one polybar per connected monitor, replacing any previous instance.
#
# Guarded on i3 actually running: without this, a polybar left over from an i3
# session keeps drawing over whatever desktop you log into next.
set -u

if ! pgrep -x i3 >/dev/null 2>&1; then
    echo "launch.sh: i3 is not running, refusing to start polybar" >&2
    exit 0
fi

killall -q polybar 2>/dev/null
for _ in $(seq 20); do
    pgrep -x polybar >/dev/null || break
    sleep 0.1
done

if type xrandr >/dev/null 2>&1; then
    for m in $(xrandr --query | awk '/ connected/ {print $1}'); do
        MONITOR=$m polybar --reload main >"/tmp/polybar-${m}.log" 2>&1 &
    done
else
    polybar --reload main >/tmp/polybar.log 2>&1 &
fi
