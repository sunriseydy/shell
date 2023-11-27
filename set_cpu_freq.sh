#!/bin/bash

# 获取第一个参数作为频率策略
governor=$1

# 如果没有参数,则设置为performance  
if [ -z $governor ]; then
  governor="performance"
fi

echo "Setting CPU frequency to $governor"

# 获取CPU的数量
cpu_count=$(grep -c '^processor' /proc/cpuinfo)

# 设置频率策略
for ((cpu=0; cpu<$cpu_count; cpu++))
do
  cpufreq-set -c $cpu -g $governor  
done