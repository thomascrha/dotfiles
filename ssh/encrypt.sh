#!/bin/bash

FOLDER=$1

if ! [ -d "$FOLDER" ]; then
    echo "No folder specified"
    exit 1
fi

for FILE in $(ls $FOLDER); do
    if [ -f $FOLDER/$FILE ]; then
        # check if extension not .age
        if [[ $FILE == *.age ]]; then
            echo "Skipping $FILE"
            continue
        fi
        echo "Encrypting $FILE"
        age -p $FOLDER/$FILE > $FOLDER/$FILE.age
    fi
done

