#!/bin/bash
# 此脚本用于生成自动切换桌面壁纸的XML配置文件
# Author: SunriseYDY
# 2018-09-17
#!/bin/bash

showHelp(){
    echo -e "Usage: bash generateBackgroundPicturesXML.sh [options]"
    echo -e "Options:"
    echo -e "\t-p \tOptions. The directory path to pictures,which is used to set wallpapers, if not specified, will use current directory(pwd)."
    echo -e "\t-s \tRequired! The seconds that per pictures will be shown."
    echo -e "\t-h \tShow this help info."
    exit 0
}

generateXML(){
    xml_file_name="wallpaper.xml"
    echo "<background>" > $xml_file_name
    pictures=$1
    second=$2
    if [ ${#pictures[@]} = 1 ];then
        echo "  <static>" >> $xml_file_name
        echo "    <file>${pictures[1]}</file>" >> $xml_file_name
        echo "  </static>" >> $xml_file_name
    else
        index=1
        while (( $index <= ${#pictures[@]}))
        do
            if [ $index = 1 ]
            then
                echo "  <static>" >> $xml_file_name
                echo "    <duration>${second}.00</duration>" >> $xml_file_name
                echo "    <file>${pictures[${index}]}</file>" >> $xml_file_name
                echo "  </static>" >> $xml_file_name
                let index++
            elif [ $index = ${#pictures[@]} ]
            then
                echo "  <transition>" >> $xml_file_name
                echo "    <duration>5.00</duration>" >> $xml_file_name
                echo "    <from>${pictures[$(($index-1))]}</from>" >> $xml_file_name
                echo "    <to>${pictures[${index}]}</to>" >> $xml_file_name
                echo "  </transition>" >> $xml_file_name
                echo "  <static>" >> $xml_file_name
                echo "    <duration>${second}.00</duration>" >> $xml_file_name
                echo "    <file>${pictures[${index}]}</file>" >> $xml_file_name
                echo "  </static>" >> $xml_file_name
                echo "  <transition>" >> $xml_file_name
                echo "    <duration>5.00</duration>" >> $xml_file_name
                echo "    <from>${pictures[${index}]}</from>" >> $xml_file_name
                echo "    <to>${pictures[1]}</to>" >> $xml_file_name
                echo "  </transition>" >> $xml_file_name
                let index++
            else
                echo "  <transition>" >> $xml_file_name
                echo "    <duration>5.00</duration>" >> $xml_file_name
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
    echo "The ${xml_file_name} has been generated in $(pwd)/${xml_file_name}, now go to gnome-control-center to set background picture to this xml"
    current_setting=`gsettings get org.gnome.desktop.background picture-uri`
    new_setting="file://$(pwd)/${xml_file_name}"
    echo -e "Current org.gnome.desktop.background picture-uri is: ${current_setting}, \nwill set it to ${new_setting}"
    gsettings set org.gnome.desktop.background picture-uri ${new_setting}
    echo "OK"
}

if [ $# = 0 ]; then
    showHelp
fi

# https://www.ibm.com/developerworks/cn/linux/l-bash-parameters.html
# echo "OPTIND starts at $OPTIND"
while getopts ":hp:s:" optname
  do
    case "$optname" in
      "p")
        if [ $OPTARG ]; then
            echo -e "Your Pictures directions is ${OPTARG}"
            pictures_path=$OPTARG
            if [ ! -d $pictures_path ]; then
                echo "Error! The ${pictures_path} isn't a directory"
                exit 0
            fi
        else
            echo -e "Option ${optname} has not value.\nWill use pwd: $PWD as your Pictures directory"
            pictures_path=$PWD
        fi
        ;;
      "s")
        echo -e "Per Picture will show ${OPTARG} seconds"
        seconds=$OPTARG
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

if [ ! $pictures_path ]; then
    echo -e "Option p not specified. Will use pwd: ${PWD} as your Pictures directory"
    pictures_path=$PWD
fi

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

if [ ${#pictures[@]} = 0 ];then
    echo "${pictures_path} hasn't any pictures."
    cd $shell_path
fi

generateXML $pictures $seconds
cd $shell_path
exit 0