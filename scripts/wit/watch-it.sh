#!/bin/bash
directory=$1
node=$2
remote_directory=$3
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rsync -avzPh $directory $node:$remote_directory --exclude-from=$SCRIPT_DIR/exclude_sync --delete
while inotifywait -r -e modify,create,delete,move --exclude '*postgres*' --exclude '*geodata_src*' --exclude '*/.idea*' --exclude '*__pycache__*' --exclude '*.git*' --exclude '*venv*' --exclude '.pytest*' $directory; do
    sleep 1
    rsync -avzPh $directory $node:$remote_directory --exclude-from=$SCRIPT_DIR/exclude_sync --delete
done
