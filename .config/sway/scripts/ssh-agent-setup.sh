#!/bin/bash

# Start ssh-agent if not already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]]; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
source "$XDG_RUNTIME_DIR/ssh-agent.env" > /dev/null

# Add your key(s)
ssh-add ~/.ssh/id_ed25519 2>/dev/null
