#!/bin/sh
# Toggle foot terminal transparency between [colors-dark] (opaque) and [colors-light] (transparent).
# foot uses SIGUSR1 to switch to [colors-dark] and SIGUSR2 to switch to [colors-light].

STATE_FILE="/tmp/foot-transparency-state"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "transparent" ]; then
    pkill -x -SIGUSR1 foot
    echo "opaque" > "$STATE_FILE"
else
    pkill -x -SIGUSR2 foot
    echo "transparent" > "$STATE_FILE"
fi
