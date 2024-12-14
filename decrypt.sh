#!/bin/bash

AGE_FILES=$(fd . ~/.config/ ~/.local/ | grep -e '\.age$')
for FILE in $AGE_FILES; do
    FILENAME=$(echo $FILE | sed 's/.age//')
    if ! [ -f $FILENAME ]; then
        echo "Decrypting $FILE as $FILENAME does not exist"
        age -d $FILE > $FILENAME
    fi
done
