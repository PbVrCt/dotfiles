#!/usr/bin/env bash
MAIN_DISPLAY='eDP-1'
SECONDARY_DISPLAY='DP-1'

MAIN_STATE=$(wlr-randr | grep -A10 "$MAIN_DISPLAY" | grep "Enabled:" | awk '{print $2}')

if [ "$MAIN_STATE" = "yes" ]; then
    # If the main display is on, switch to secondary-only 
    pkill wl-mirror
    wlr-randr --output $SECONDARY_DISPLAY --pos 3000,3000
    riverctl focus-output $SECONDARY_DISPLAY
    wl-mirror --fullscreen $MAIN_DISPLAY &
    sleep 1
    wlr-randr --output $MAIN_DISPLAY --off
    riverctl focus-output $SECONDARY_DISPLAY
else
    # If secondary display is off, switch back to normal
    wlr-randr --output $MAIN_DISPLAY --on
    riverctl focus-output $MAIN_DISPLAY
    pkill wl-mirror
fi

# Switch back to normal before disconecting the secondary display
