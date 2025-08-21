#!/bin/bash

# Accepts one windows path as arguments
# e.g. C:\Users\226960\WezTerm\somefile.lua
# and converts it to a WSL linux paths
# e.g. /mnt/c/Users/226960/WezTerm/somefile.lua

if [ $# -eq 0 ]; then
    echo "Usage: $0 <windows_path>"
    exit 1
fi

WINDOWS_PATH="$1"
WSL_PATH=$(echo "$WINDOWS_PATH" | sed -e 's|\\|/|g' -e 's|^C:|/mnt/c|')

/bin/nvim $WSL_PATH




