#!/bin/sh
# Toggle foot terminal transparency between opaque and transparent.
# Foot reloads its config on SIGUSR1.

CONFIG="$HOME/.config/foot/foot.ini"
OPAQUE="alpha=1.0"
TRANSPARENT="alpha=0.85"

current=$(grep "^alpha=" "$CONFIG")

if [ "$current" = "$OPAQUE" ]; then
    sed -i "s/^alpha=.*/$TRANSPARENT/" "$CONFIG"
else
    sed -i "s/^alpha=.*/$OPAQUE/" "$CONFIG"
fi

pkill -SIGUSR1 foot
