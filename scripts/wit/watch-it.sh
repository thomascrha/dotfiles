#!/bin/bash

# usage and check for no of arugs
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <local_directory> <remote-host> <remote_directory>"
    exit 1
fi


directory=$1
node=$2
remote_directory=$3
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rsync -avzPh $directory $node:$remote_directory --exclude-from=$SCRIPT_DIR/exclude_sync --delete
while inotifywait -r -e modify,create,delete,move --exclude '*postgres*' --exclude '*geodata_src*' --exclude '*/.idea*' --exclude '*__pycache__*' --exclude '*.git*' --exclude '*venv*' --exclude '.pytest*' $directory; do
    sleep 1
    rsync -avzPh $directory $node:$remote_directory --exclude-from=$SCRIPT_DIR/exclude_sync --delete
done
