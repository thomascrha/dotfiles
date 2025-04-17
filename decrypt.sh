#!/bin/bash

AGE_FILES="$HOME/.zshenv.secrets.age $HOME/.config/aichat/config.yaml.age"
for FILE in $AGE_FILES; do
    FILENAME=$(echo $FILE | sed 's/.age//')
    if ! [ -f $FILENAME ]; then
        echo "Decrypting $FILE as $FILENAME does not exist"
        age -d $FILE > $FILENAME
        if [ $? -ne 0 ]; then
            echo "Decryption failed"
            rm $FILENAME
            continue
        fi
        echo "Decryption successful"
    else
        echo "$FILENAME already exists"
    fi
done
