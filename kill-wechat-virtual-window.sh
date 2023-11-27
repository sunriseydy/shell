#!/bin/bash
while true 
do
    let WX_WINDOW_ID=$(wmctrl -l -x | grep 'wechat.exe.Wine' | grep '微信' | awk '{print $1}')
    if [[ -n $WX_WINDOW_ID ]]; then
        WIN_ID=`echo "obase=16;${WX_WINDOW_ID} + 17" | bc | awk '{print tolower($0)}'`
        WINDOW_ID=$(wmctrl -l -x | grep 'wechat.exe.Wine' | grep "$WIN_ID" | awk '{print $1}')
        if [[ -n $WINDOW_ID ]]; then
            xdotool windowunmap "$WINDOW_ID"
            echo "kill $WINDOW_ID"
        fi
    fi
    
    sleep 1
done
