#!/bin/sh
# Toggle foot terminal transparency between [colors] (opaque) and [colors2] (transparent).
# foot uses SIGUSR1 to switch to [colors] and SIGUSR2 to switch to [colors2].

STATE_FILE="/tmp/foot-transparency-state"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "transparent" ]; then
    pkill -x -SIGUSR1 foot
    echo "opaque" > "$STATE_FILE"
else
    pkill -x -SIGUSR2 foot
    echo "transparent" > "$STATE_FILE"
fi
