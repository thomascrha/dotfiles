#!/usr/bin/env bash
text=$(curl -s "https://wttr.in/$1?format=1")
# check if Unkonwn location in text
if [[ $text == *"Unknown location"* ]]
then
    echo "{\"text\":\"error\", \"tooltip\":\"error\"}"
    exit 1
fi
text=$(echo "$text" | sed -E "s/\s+/ /g")
tooltip=$(curl -s "https://wttr.in/$1?format=4")
tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g")
echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
