#!/usr/bin/env bash
wl-screenrec -g "$(slurp)"
# Then do:
# ffmpeg -i screenrecord.mp4 -vf "fps=15" screenrecord.gif

