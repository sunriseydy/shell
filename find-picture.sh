#!/bin/bash
# 设置目录路径
dir_path="/data/Pictures/ACGN"
# 查找尺寸比例为4:3或3:4的图片
find "$dir_path" -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | while read file; do
    # 获取图片尺寸
    size=$(identify -format "%wx%h" "$file")
    # 判断尺寸比例是否为16:9或9:16
    if [[ "$size" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        width=${BASH_REMATCH[1]}
        height=${BASH_REMATCH[2]}
        ratio=$(echo "scale=2; $width/$height" | bc)
        if (($(echo "$ratio == 1.77 || $ratio == 0.56" | bc -l))); then
            echo "$file"
            cp "$file" "/tmp/t/${file##*/}"
        fi
    fi
done
