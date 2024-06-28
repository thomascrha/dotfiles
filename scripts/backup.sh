#!/bin/sh

USAGE="Usage: $0 <src> <dst>\nWhere <src> is the source directory and <dst> is the destination directory (which can be a remote host)."

if [ $# -ne 2 ]; then
    echo -e $USAGE
    exit 1
fi

SRC=$1
DST=$2

# Check if the source directory exists
if [ ! -d $SRC ]; then
    echo "Source directory $SRC does not exist."
    exit 1
fi

# rsync the source directory to the destination directory using

rsync -avPhz --mkpath $SRC $DST
