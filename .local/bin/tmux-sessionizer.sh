#!/usr/bin/env bash

declare -A projects

projects["$HOME/qbe"]=nested
projects["$HOME/dotfiles"]=single

declare -A folders

for key in ${!projects[@]}; do
    # check if value is single - then just add it to the selected
    if [[ ${projects[$key]} == "single" ]]; then
        folders+=([$(basename ${key})]=${key})
    else
        find_folders="$(find ${key} -mindepth 1 -maxdepth 1 -type d)"
        for f in $find_folders; do
            folders+=([$(basename ${f})]=${f})
        done
    fi
done

selected=$(echo ${!folders[@]} | sed 's/ /\n/g' | fzf --layout=reverse --tmux center --ansi)

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c ${folders[$selected]}
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c ${folders[$selected]}
fi

if [[ -z $TMUX ]]; then
    tmux attach -t $selected_name
else
    tmux switch-client -t $selected_name
fi
