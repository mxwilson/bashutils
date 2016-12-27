#!/bin/bash

# xfce-dual-monitor.sh - quickly enable non-mirrored dual monitors under XFCE for Thinkpad x201

# (c) 2016 Matthew Wilson
# License GPLv3+: GNU GPL version 3 or later: http://gnu.org/licenses/gpl.html
# No warranty. Software provided as is.


# resoluton
# laptop / left monitor 
xrandr --output LVDS1 --mode 1280x800 --rate 60

# external / right monitor
xrandr --output VGA1 --mode 1024x768 --rate 60

# order of monitors
xrandr --output LVDS1 --left-of VGA1

# primary monitor
xrandr --output LVDS1 --primary
