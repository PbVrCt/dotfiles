#!/usr/bin/env bash
MAIN_DISPLAY='eDP-1'
SECONDARY_DISPLAY='DP-1'

# Go back to normal in case you are in secondary-only...
wlr-randr --output $MAIN_DISPLAY --on
riverctl focus-output $MAIN_DISPLAY
pkill wl-mirror

# ...then mirror
wlr-randr --output $SECONDARY_DISPLAY --pos 3000,3000
riverctl focus-output $SECONDARY_DISPLAY
wl-mirror --fullscreen $MAIN_DISPLAY &
sleep 1
riverctl focus-output $MAIN_DISPLAY
