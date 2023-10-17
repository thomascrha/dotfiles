#!/bin/bash

# sets
dconf write /org/gnome/mutter/dynamic-workspaces false
dconf write /org/gnome/desktop/wm/preferences/num-workspaces 8

# mouse and trackpad
dconf write /org/gnome/desktop/peripherals/mouse/natural-scroll false
dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll true
dconf write /org/gnome/desktop/peripherals/touchpad/two-finger-scrolling-enabled true

# pop os specfic
dconf write /org/gnome/shell/extensions/pop-cosmic/show-applications-button false
dconf write /org/gnome/shell/extensions/pop-cosmic/show-workspaces-button false
dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default true

# wezterm-guake
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding <Primary>grave
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command tdrop wezterm start --class wezterm-guake
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name WezGuake
#
# dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding '<Super>Return'
# dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command 'wezterm start'
# dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name 'Wezterm'
