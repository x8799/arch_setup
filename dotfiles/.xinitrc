#!/bin/sh

# Start the compositor
picom &

# Start the hotkey daemon
sxhkd &

# Set wallpaper
$HOME/arch_setup/scripts/wallpaper_randomizer.sh &

# Launch polybar
polybar main &

# Launch BSPWM
exec bspwm
