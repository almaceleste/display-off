#!/bin/bash

# script to turn off/on individual (or all) monitors in the multihead setup
# GNU Affero GPL 3.0 (ɔ) 2020 almaceleste
# https://github.com/almaceleste/display-off

# some part of this code is taken from the alex cabal script
# https://alexcabal.com/turn-your-laptop-screen-off-with-a-keyboard-shortcut-in-ubuntu-karmic

# dependencies:
#   xrandr
#   xset

scriptname='display-off'
version=0.1.0

# parse argument passed to the script
case $1 in
    --help | '')
        read -r -d '' help << EOM
usage:  display-off.sh [option]
turn off/on a display (one in multihead setup or all in the system)

options:
    --all      turn off/on the displays of the all monitors
    --help     show this help and exit
    --version  show version info and exit
    <output>   turn off/on the display of the individual monitor, connected to the <output>

you could get the <output> by 'xrandr --query' command. 
usually it looks like smth as HDMI-0 or DP-1

repo: <https://github.com/almaceleste/display-off>
EOM
        echo "$help"
    ;;
    --version)
        read -r -d '' version << EOM
$scriptname v$version

Copyleft (ɔ) 2020 almaceleste
License: GNU Affero GPL 3.0 <https://gnu.org/licenses/agpl-3.0.html>.
This is free software: you are free to change and redistribute it under the same license.
There is NO WARRANTY, to the extent permitted by law.

Written by almaceleste.
EOM
        echo "$version"
    ;;
    --all)
        display='Screen'
    ;;
    *)
        display=$1
    ;;
esac

if [ $display ]; then
    # lockfile path
    displayOffLock=/tmp/$display-off.lock

    # if lockfile exists turn display on and remove lockfile
    if [ -f $displayOffLock ]; then
        notify-send "$display on." -i /usr/share/icons/gnome/48x48/devices/display.png
        # if the individual output was passed read brightness of the monitor, connected to it, from the lockfile and set brightness to the saved value
        if [ $display != 'Screen' ]; then
            brightness=$(cat $displayOffLock)
            xrandr --output $display --brightness $brightness
        fi
        rm $displayOffLock
    # if lockfile does not exists turn display off and create lockfile
    else
        touch $displayOffLock
        sleep .5
        # if --all option was passed turn off all the displays in the system
        if [ $display == 'Screen' ]; then
            # while lockfile exists forcibly set Energy Star (DPMS) to turn off all monitors
            while [ -f  $displayOffLock ]
            do
                xset dpms force off
                sleep 2
            done
            # when lockfile removed forcibly set Energy Star (DPMS) to turn on all monitors
            xset dpms force on
        else
            # if the individual output was passed save brightness of the monitor, connected to it, to the lockfile and set brightness to 0
            xrandr --verbose | grep -A5 "^$display" | awk '/Brightness:/ {print $2}' > $displayOffLock
            xrandr --output $display --brightness 0
        fi
        notify-send "$display off." -i /usr/share/icons/gnome/48x48/devices/display.png
    fi
fi
