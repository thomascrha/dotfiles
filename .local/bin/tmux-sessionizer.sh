#!/usr/bin/env bash

echo "tmux-sessionizer bash"

declare -A projects

projects["$HOME/qbe"]=nested
projects["$HOME/dotfiles"]=single

declare -A folders

# Get list of active tmux sessions
declare -A active_sessions
if tmux list-sessions -F "#{session_name}" 2>/dev/null | while read -r session; do
    active_sessions["$session"]=1
done; then
    while read -r session; do
        active_sessions["$session"]=1
    done < <(tmux list-sessions -F "#{session_name}" 2>/dev/null)
fi

for key in ${!projects[@]}; do

    if [[ ${projects[$key]} == "single" ]]; then
        folders+=([$(basename ${key})]=${key})
    else
        find_folders="$(find ${key} -mindepth 1 -maxdepth 1 -type d)"
        for f in $find_folders; do
            folders+=([$(basename ${f})]=${f})
        done
    fi
done

# Build lists for open and closed sessions
open_names=()
closed_names=()

for name in "${!folders[@]}"; do
    session_name=$(echo "$name" | tr . _)
    if [[ -n ${active_sessions[$session_name]} ]]; then
        open_names+=("$name")
    else
        closed_names+=("$name")
    fi
done

# Sort both arrays alphabetically
IFS=$'\n' open_names=($(sort <<<"${open_names[*]}")); unset IFS
IFS=$'\n' closed_names=($(sort <<<"${closed_names[*]}")); unset IFS

# Build fzf input with prefixes (open at top with green circle)
fzf_input=""
for name in "${open_names[@]}"; do
    fzf_input+="🟢 $name"$'\n'
done
for name in "${closed_names[@]}"; do
    fzf_input+="   $name"$'\n'
done

selected=$(echo -n "$fzf_input" | fzf --layout=reverse --tmux center --ansi)

# Exit if nothing selected
[[ -z $selected ]] && exit 0

# Strip the prefix (green circle or spaces)
selected=$(echo "$selected" | sed 's/^🟢 //; s/^   //')

selected_name=$(basename "$selected" | tr . _)
selected_path=${folders[$selected]}
tmux_running=$(pgrep tmux)
session_exists=$(tmux has-session -t=$selected_name 2>/dev/null && echo "yes")

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c "$selected_path"
    exit 0
fi

if [[ -z $session_exists ]]; then
    tmux new-session -ds $selected_name -c "$selected_path"
fi

if [[ -z $TMUX ]]; then
    tmux attach -t $selected_name
else
    tmux switch-client -t $selected_name
fi
