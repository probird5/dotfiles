#!/bin/sh
xrandr --output HDMI-0 --mode 3840x2160 --pos 3840x0 --rotate right \
       --output DP-0 --off \
       --output DP-1 --off \
       --output HDMI-1 --off \
       --output DP-2 --primary --mode 3840x2160 --pos 0x0 --rotate normal --rate 144 \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-5 --off
