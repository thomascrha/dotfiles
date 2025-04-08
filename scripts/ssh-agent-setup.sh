#!/bin/bash

# Start ssh-agent if not already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]]; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
source "$XDG_RUNTIME_DIR/ssh-agent.env" > /dev/null

# Check if key is NOT already added
if ! ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf ~/.ssh/id_ed25519 2>/dev/null | awk '{print $2}')"; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
