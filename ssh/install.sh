#!/bin/bash

HOSTNAME=$(hostname)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Installing SSH on $HOSTNAME"


if ! [ -d $CURRENT_DIR/$HOSTNAME ]; then
    echo "No SSH config file for $HOSTNAME"
    exit 1
fi

if [ -d $HOME/.ssh ]; then
    echo "SSH config file already exists"
else
    if ! [ -d $CURRENT_DIR/.tmp_$HOSTNAME ]; then
        echo "decrypting SSH config files for $HOSTNAME"
        mkdir -p $CURRENT_DIR/.tmp_$HOSTNAME 
        for FILE in $(ls $CURRENT_DIR/$HOSTNAME); do
            # check if extension not .age
            echo $FILE
            if [[ $FILE == *.age ]]; then
                # remove .age extension 
                NEW_FILE=$(echo $FILE | sed 's/.age//')
                # get the old file permissions 
                chmod=$(stat -c %a $CURRENT_DIR/$HOSTNAME/$FILE)
                echo "Decrypting $FILE to $NEW_FILE"
                age -d $CURRENT_DIR/$HOSTNAME/$FILE > $CURRENT_DIR/.tmp_$HOSTNAME/$NEW_FILE
                # apply the old file permissions 
                chmod $chmod $CURRENT_DIR/.tmp_$HOSTNAME/$NEW_FILE
            fi
        done
    fi

    echo "Copying SSH config file"
    cp -rp $CURRENT_DIR/.tmp_$HOSTNAME $HOME/.ssh
fi
