#!/bin/bash
# 在Linux上根据指定蓝牙设备的信号强弱来自动锁屏和解锁的shell脚本
# Author: SunriseYDY
# 2020-06-20

rssi_limit_default=-70
checkout_fail_limit=3
scan_interval=2

# 打印脚本帮助信息
showHelp(){
    echo -e "Usage: ./bluetooth-lock.sh -m mac_address -r rssi_limit -l lock_cmd -u unlock_cmd"
    echo -e "Options:"
    echo -e "\t-m \tRequired! MAC address of the Bluetooth device to be scanned"
    echo -e "\t-r \tnegative integer! The rssi limit to checkout. By default it is -70"
    echo -e "\t-l \tlock command. Lock screen command executed when the rssi of the Bluetooth device is less than the defined rssi_limit value.\n\t\tBy default it is 'loginctl lock-session'"
    echo -e "\t-u \tunlock command. Unlock screen command executed when the rssi of the Bluetooth device is greater than the defined rssi_limit value.\n\t\tBy default it is 'loginctl unlock-session'"
    echo -e "\t-h \tShow this help info."
    exit
}


# https://www.ibm.com/developerworks/cn/linux/l-bash-parameters.html
# echo "OPTIND starts at $OPTIND"
# 处理参数
while getopts ":m:r:l:u:h" optname
  do
    case "$optname" in
    "m")
        if [ $OPTARG ]; then
            mac=$OPTARG
            echo -e "bluetooth mac address is ${OPTARG}"
        else
            echo -e "Option ${optname} has not value.\n"
            showHelp
        fi
        ;;
    "l")
        if [ $OPTARG ]; then
            lock_cmd=$OPTARG
            echo -e "lock_cmd is ${OPTARG}"
        else
            echo -e "lock_cmd is empty, use 'loginctl lock-session'\n"
            showHelp
        fi
        ;;
    "u")
        if [ $OPTARG ]; then
            unlock_cmd=$OPTARG
            echo -e "unlock_cmd is ${OPTARG}"
        else
            echo -e "unlock_cmd is empty, use 'loginctl unlock-session'\n"
            showHelp
        fi
        ;;
    "r")
        # 判断参数值是否是数字
        expr ${OPTARG} + 0 &>/dev/null
        if [ $? != 0 ]; then
            echo "Error! Input a wrong number"
            showHelp
        fi
        # 判断参数值是否小于0
        if [ ${OPTARG} -lt 0 ]; then
            echo -e "rssi_limit set to ${OPTARG}"
            rssi_limit=$OPTARG
        else
            echo "Error, rssi must be negative"
            showHelp
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

if [ ! $mac ]; then
    echo "Error! mac address is empty"
    showHelp
fi

if [ ! $rssi_limit ]; then
    echo "rssi_limit is empty， use $rssi_limit_default"
    rssi_limit=$rssi_limit_default
fi

if [ ! $lock_cmd ]; then
    echo "lock_cmd is empty, use 'loginctl lock-session'"
    lock_cmd='loginctl lock-session'
fi

if [ ! $unlock_cmd ]; then
    echo "unlock_cmd is empty, use 'loginctl unlock-session'"
    unlock_cmd='loginctl unlock-session'
fi

_checkout_fail_limit=0
_mode="unlock"
while true
do
    rssi=`bluetoothctl --timeout $scan_interval scan on | grep "$mac" | awk '{ print $5 }'`
    echo "rssi: $rssi"
    if [[ $rssi && $rssi -ge $rssi_limit ]]
    then
        _checkout_fail_limit=0
        echo -e "\e[32mcheckout success\e[0m"
        if [[ $_mode == "lock" ]]; then
            echo "unlock"
            _mode="unlock"
            `$unlock_cmd`
        fi
    else
        _checkout_fail_limit=$(($_checkout_fail_limit + 1))
        echo -e "\e[31mcheckout failed $_checkout_fail_limit times\e[0m"
    fi
    if [[ $_checkout_fail_limit -ge $checkout_fail_limit && $_mode == "unlock" ]]; then
        echo "lock"
        _mode="lock"
        `$lock_cmd`
    fi

done