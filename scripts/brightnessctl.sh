# Makes a tui to change the brightness

#!/usr/bin/env bash

# Function to get current brightness percentage
get_brightness() {
    brightnessctl i | grep -oP '\(\K[^%]*'
}

# Function to display brightness bar
show_brightness_bar() {
    local brightness=$(get_brightness)
    local bar_width=50
    local filled_chars=$((brightness * bar_width / 100))
    local empty_chars=$((bar_width - filled_chars))
    printf "█%.0s" $(seq 1 $filled_chars)
    printf "░%.0s" $(seq 1 $empty_chars)
    printf " %d%%\n" $brightness
}

# Function to read a single keypress
read_key() {
    read -rsn1 input
    echo "$input"
}

# Main loop
while true; do
    clear
    echo "Brightness Control"
    echo "─────────────────"
    echo
    show_brightness_bar
    echo
    echo "Controls: [1-9,0] Set brightness (1-100%)"

    # Get single keypress
    key=$(read_key)

    case $key in
        1) brightnessctl set 1% >/dev/null 2>&1 ;;
        2) brightnessctl set 20% >/dev/null 2>&1 ;;
        3) brightnessctl set 30% >/dev/null 2>&1 ;;
        4) brightnessctl set 40% >/dev/null 2>&1 ;;
        5) brightnessctl set 50% >/dev/null 2>&1 ;;
        6) brightnessctl set 60% >/dev/null 2>&1 ;;
        7) brightnessctl set 70% >/dev/null 2>&1 ;;
        8) brightnessctl set 80% >/dev/null 2>&1 ;;
        9) brightnessctl set 90% >/dev/null 2>&1 ;;
        0) brightnessctl set 100% >/dev/null 2>&1 ;;
    esac
done
