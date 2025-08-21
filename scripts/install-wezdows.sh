#!/bin/bash

USER=${1:-226960}

cp -v $HOME/dotfiles/.config/wezterm/wezterm.lua /mnt/c/Users/$USER/WezTerm/wezterm.lua
cp -v $HOME/dotfiles/.config/wezterm/tabline.lua /mnt/c/Users/$USER/WezTerm/tabline.lua
