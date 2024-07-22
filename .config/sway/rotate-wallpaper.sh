#!/bin/sh

# set -x
IFS="
"
wallpaper_directory=$1
duration=$2

[ -z "$wallpaper_directory" ] && echo "Usage: $(basename $0) [DIRECTORY] [DURATION]" && exit 1
[ ! -d "$wallpaper_directory" ] && echo "Directory \'$wallpaper_directory\' does not exist" && exit 1
[ -z "$duration" ] && echo "Usage: $(basename $0) [DIRECTORY] [DURATION]" && exit 1

while true; do
    for file in $(ls "$wallpaper_directory" | shuf); do
        current_swaybg_pid=$(pgrep -x swaybg)
        wallpaper="$wallpaper_directory/$file"
        format=$(file "$wallpaper" | cut -d" " -f 3)
        echo "Current swaybg pid: $current_swaybg_pid"
        echo "Wallpaper: $wallpaper"
        echo "Format: $format"
        [ "$format" = "PNG" ] || [ "$format" = "JPEG" ]\
            && echo "Setting wallpaper $wallpaper, format $format, sleeping $duration." \
            && sh -c "swaybg -o \"*\" -i \"$wallpaper\" -m fill -c \"#000000\" > /dev/null 2>&1 &" \
            && sleep 0.5 \
            && kill $current_swaybg_pid
        echo "Sleeping $duration"
        sleep $duration
    done
done
