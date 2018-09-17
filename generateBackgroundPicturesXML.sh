#!/bin/bash
# 此脚本用于生成自动切换桌面壁纸的XML配置文件
# Author: SunriseYDY
# 2018-09-17

# 打印脚本帮助信息
showHelp(){
    echo -e "Usage: bash generateBackgroundPicturesXML.sh -p path -s seconds"
    echo -e "Options:"
    echo -e "\t-p \tRequired! The directory path to pictures, which is used to set wallpapers, if not specified, will use current directory(pwd)."
    echo -e "\t-s \tRequired! Integer! The seconds that per pictures will be shown. By default it is 600s(10min)"
    echo -e "\t-h \tShow this help info."
    exit
}

# 生成 XML 文件
generateXML(){
    xml_file_name="wallpaper.xml" # 文件名
    echo "<background>" > $xml_file_name # 如果已经存在,直接覆盖
    pictures=$1  # 函数参数1,数组,元素为该目录下所有的图片路径.
    second=$2  # 函数参数2,每张图片显示的时间,单位: 秒
    switch_speen=$3  # 函数参数3,壁纸切换的速度,单位: 秒,最小 0.00
    if [ ${#pictures[@]} = 1 ];then  # 如果只有一张图片
        echo "  <static>" >> $xml_file_name
        echo "    <file>${pictures[0]}</file>" >> $xml_file_name
        echo "  </static>" >> $xml_file_name
    else  # 壁纸自动切换配置
        index=0
        while (( $index < ${#pictures[@]} ))
        do
            if [ $index = 0 ]
            then
                echo "  <static>" >> $xml_file_name
                echo "    <duration>${second}.00</duration>" >> $xml_file_name
                echo "    <file>${pictures[${index}]}</file>" >> $xml_file_name
                echo "  </static>" >> $xml_file_name
                let index++
            elif [ $index = $((${#pictures[@]} - 1)) ]
            then
                echo "  <transition>" >> $xml_file_name
                echo "    <duration>"$switch_speen"</duration>" >> $xml_file_name
                echo "    <from>${pictures[$(($index-1))]}</from>" >> $xml_file_name
                echo "    <to>${pictures[${index}]}</to>" >> $xml_file_name
                echo "  </transition>" >> $xml_file_name
                echo "  <static>" >> $xml_file_name
                echo "    <duration>${second}.00</duration>" >> $xml_file_name
                echo "    <file>${pictures[${index}]}</file>" >> $xml_file_name
                echo "  </static>" >> $xml_file_name
                echo "  <transition>" >> $xml_file_name
                echo "    <duration>"$switch_speen"</duration>" >> $xml_file_name
                echo "    <from>${pictures[${index}]}</from>" >> $xml_file_name
                echo "    <to>${pictures[0]}</to>" >> $xml_file_name
                echo "  </transition>" >> $xml_file_name
                let index++
            else
                echo "  <transition>" >> $xml_file_name
                echo "    <duration>"$switch_speen"</duration>" >> $xml_file_name
                echo "    <from>${pictures[$(($index-1))]}</from>" >> $xml_file_name
                echo "    <to>${pictures[${index}]}</to>" >> $xml_file_name
                echo "  </transition>" >> $xml_file_name
                echo "  <static>" >> $xml_file_name
                echo "    <duration>${second}.00</duration>" >> $xml_file_name
                echo "    <file>${pictures[${index}]}</file>" >> $xml_file_name
                echo "  </static>" >> $xml_file_name
                let index++
            fi
        done
     
    fi

    echo "</background>" >> $xml_file_name
    echo "The ${xml_file_name} has been generated in $(pwd)/${xml_file_name}"

    # 开始设置背景图
    current_setting=`gsettings get org.gnome.desktop.background picture-uri`
    new_setting="file://$(pwd)/${xml_file_name}"
    echo -e "Current org.gnome.desktop.background picture-uri is: ${current_setting}, \nwill set it to ${new_setting}"
    gsettings set org.gnome.desktop.background picture-uri ${new_setting}
    echo "OK"
    echo "Tips: You can run 'gsettings set org.gnome.desktop.background picture-uri file_url' to set wallpaper"
}

if [[ $# = 0 || $# != 4 ]]; then  # 如果参数个数为0或者不是4,显示帮助信息
    echo "OPTIONS IS TOO FEW!"
    showHelp
fi

# https://www.ibm.com/developerworks/cn/linux/l-bash-parameters.html
# echo "OPTIND starts at $OPTIND"
# 处理参数
while getopts ":hp:s:" optname
  do
    case "$optname" in
      "p")
        if [ $OPTARG ]; then
            pictures_path=$OPTARG
            if [ ! -d $pictures_path ]; then
                echo "Error! The ${pictures_path} isn't a directory"
                exit
            fi
            echo -e "Your Pictures' directory is ${OPTARG}"
        else
            echo -e "Option ${optname} has not value.\nWill use pwd: $PWD as your Pictures' directory"
            pictures_path=$PWD
        fi
        ;;
      "s")
        # 判断参数值是否是数字
        expr ${OPTARG} + 0 &>/dev/null
        if [ $? != 0 ]; then
            echo "Error! Input a wrong second option"
            showHelp
        fi
        # 判断参数值是否大于0
        if [ ${OPTARG} -gt 0 ]; then
            echo -e "Per Picture will be shown ${OPTARG} seconds"
            seconds=$OPTARG
        else
            echo "Error, Too few seconds, will be set to 600s"
            seconds=600
        fi
        ;;
      "h")
        showHelp
        ;;
      "?")
        echo "Unknown option ${OPTARG}"
        showHelp
        ;;
      ":")
        echo "No argument value for option ${OPTARG}"
        showHelp
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        showHelp
        ;;
    esac
    # echo "OPTIND is now $OPTIND"
done

# 如果参数 p 未指定,则添加默认值为当前脚本目录路径
if [ ! $pictures_path ]; then
    echo -e "Option p not specified. Will use pwd: ${PWD} as your Pictures' directory"
    pictures_path=$PWD
fi

# 如果参数 s 未指定,则设置默认值为 600 s
if [ ! $seconds ];then
    seconds=600
fi

# 设置切换壁纸的速度,尚未在参数中设置,只能在脚本中修改.
switch_speen="0.50" # 切换壁纸时的速度,单位: 秒

shell_path=$PWD
cd ${pictures_path}

# 去除文件名中的空格,换为'_' https://blog.csdn.net/dliyuedong/article/details/14229121
if [ `command -v rename` ];then
    rename 's/ /_/g' *
else
    for file in $(ls -1 | tr ' ' '^')
    do
        mv "`echo $file | sed "s/\^/ /g"`" "`echo $file | sed "s/\^/_/g"`" 2> /dev/null
    done
fi

pictures_path=`pwd`
pictures=`find ${pictures_path} -maxdepth 1 -iname '*\.jpg'` # 列出所有jpg图片
pictures=(${pictures[@]} `find ${pictures_path} -maxdepth 1 -iname '*\.png'`) # 列出所有png图片
pictures=(${pictures[@]} `find ${pictures_path} -maxdepth 1 -iname '*\.jpeg'`) # 列出所有jpeg图片

# 判断是否有图片,如果有就调用生成XML的函数
if [ ${#pictures[@]} = 0 ];then
    echo "${pictures_path} don't exist any pictures."
    cd $shell_path
else
    generateXML $pictures $seconds $switch_speen
fi

exit