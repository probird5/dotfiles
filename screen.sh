#!/bin/sh

xrandr --output HDMI-0 --mode 3840x2160 --rate 60 --pos 7680x0 --rotate right \
       --output DP-0 --off \
       --output DP-1 --off \
       --output HDMI-1 --off \
       --output DP-2 --primary --mode 3840x2160 --rate 144 --pos 3840x673 --rotate normal \
       --output DP-3 --off \
       --output DP-4 --mode 3840x2160 --rate 240 --pos 0x673 --rotate normal \
       --output DP-5 --off

