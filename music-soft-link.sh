#!/bin/bash
sou="/data/Music/"
des="/home/sunriseydy/Music/soft/"
# rm -rf $des
find "$sou" -type f | while read file; do
    # ln -s "$file" "${des}${file##*/}"
    cp "$file" "${des}${file##*/}"
done
