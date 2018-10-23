#!/bin/bash
# 此脚本是为了方便我编辑PAC文件，即添加、删除某一个网址
# 同时作为 sed 命令的练习
# Author: SunriseYDY
# Version: 1.0

PAC_PATH="pac.txt" # PAC 文件的路径，默认为当前目录下的 pac.txt
# 获取参数，参数为 PAC 文件路径
if [ $1 ]; then
    PAC_PATH=$1
fi
if [ ! -f $PAC_PATH ]; then
    echo "PAC 文件不存在"
    exit 0
fi

# echo `ls $PAC_PATH`
flag=9
until [ $flag == 0 ]
do
    echo -e "\n\tPAC 文件编辑器"
    echo "1. 添加代理域名"
    echo "2. 删除代理域名"
    echo "0. 退出"
    read -p "请输入功能序号： " -n 2 flag
    case $flag in
        1)  
            echo " "
            echo -e '\t添加代理域名'
            read -p "请输入你要添加的域名，例如 google.com： " add_url
            if [ $add_url ]
            then
                add_item="\""$add_url"\": 1," # 最终要添加到 pac 文件中的字符串
                sed -n "/var domains = {/a $add_item" $PAC_PATH
                sed -i "/var domains = {/a $add_item" $PAC_PATH # 在域名数组的第一行添加该域名
                echo "添加成功"
            fi
            ;;
        2)  
            echo " "
            echo -e '\t删除代理域名'
            read -p "请输入你要删除的域名，例如 google.com : " delete_url
            if [ $delete_url ]
            then
                sed -n "/\s*\"${delete_url}\":\s*1,\s*/p" $PAC_PATH
                sed -i "/\s*\"${delete_url}\":\s*1,\s*/d" $PAC_PATH
                echo "删除成功"
            fi
            ;;
        0)  
            echo " "
            break
            ;;
        *)  
            echo " "
            echo '输入错误'
            flag=9
            ;;
    esac
done