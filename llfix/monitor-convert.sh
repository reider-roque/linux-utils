#!/usr/bin/env bash

SELF_PATH=$(readlink -nf ${0})
SELF_DIR=$(dirname $SELF_PATH)
SELF_NAME=$(basename $SELF_PATH)
LOG_NAME="image-resizing.log"

touch "$SELF_DIR/$LOG_NAME"
log () { echo "[$SELF_NAME] $1" | tee -a "$SELF_DIR/$LOG_NAME" ; }

inotifywait -q -m $SELF_DIR -e create -e moved_to |
    while read path action file; do
        FILE_EXT="${file##*.}"
        case $FILE_EXT in
            jpg|jpeg|png)
                log "$file appeared in $path directory. Resizing..."
                log "before: $(identify $file)"
                convert $file -resize 200x200 $file
                log "after: $(identify $file)"
        esac
    done
