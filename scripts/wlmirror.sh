#!/usr/bin/env bash
wlr-randr --output DP-1 --pos 3000,3000
riverctl focus-output DP-1
wl-mirror --fullscreen eDP-1 &
sleep 1
riverctl focus-output eDP-1
