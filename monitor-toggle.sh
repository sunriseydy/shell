#!/bin/bash 
# 参数:单显示器or双显示器
mode=$1
if [ "$mode" == "single" ]; then
  # 单显示器
  xrandr --output HDMI-A-0 --off --output DisplayPort-0 --off --output HDMI-A-1 --mode 1920x1080 --rotate normal --primary
elif [ "$mode" == "dual" ]; then
  # 双显示器
  xrandr --output HDMI-A-1 --off --output HDMI-A-0 --mode 2560x1440 --pos 0x0 --rotate normal --primary --output DisplayPort-0 --mode 1920x1080 --pos 0x0 --rotate left --left-of HDMI-A-0
fi