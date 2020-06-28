#!/bin/bash
# 在Linux上根据指定蓝牙设备的信号强弱来自动锁屏和解锁的shell脚本
# Author: SunriseYDY
# 2020-06-20

rssi_limit_default=-70
checkout_fail_limit_default=3
checkout_success_limit_default=3
scan_interval=2

# 打印脚本帮助信息
showHelp(){
    echo -e "Usage: ./bluetooth-lock.sh [options]"
    echo -e "Options:"
    echo -e "\t-m, --mac-address <mac-address> \tRequired! MAC address of the Bluetooth device to be scanned"
    echo -e "\t-r, --rssi-limit <rssi-limit> \t\tnegative integer! The rssi limit to checkout. By default it is -70"
    echo -e "\t--failed-limit <failed-limit> \t\tinteger! The failed checkout limit to lock. By default it is 3"
    echo -e "\t--success-limit <success-limit> \tinteger! The success checkout limit to unlock. By default it is 3"
    echo -e "\t-l, --lock-cmd <lock-cmd> \t\tlock command. Lock screen command executed when the rssi of the Bluetooth device is less than the defined rssi_limit value.\n\t\t\t\t\t\tBy default it is 'loginctl lock-session'"
    echo -e "\t-u, --unlock-cmd <unlock-cmd> \t\tunlock command. Unlock screen command executed when the rssi of the Bluetooth device is greater than the defined rssi_limit value.\n\t\t\t\t\t\tBy default it is 'loginctl unlock-session'"
    echo -e "\t-d, --dry-run \t\t\t\tdry run, not really exec the lock-cmd and unlock-cmd."
    echo -e "\t-s, --scan \t\t\t\tScan for available Bluetooth devices."
    echo -e "\t-h, --help \t\t\t\tShow this help info."
    exit
}


# 处理参数
TEMP=$(getopt -o 'm:r:l:u:hds' --long 'mac-address:,lock-cmd:,unlock-cmd:,rssi-limit:,help,dry-run,scan,success-limit:,failed-limit:' -n 'bluetooth-lock.sh' -- "$@")

if [ $? -ne 0 ]; then
        echo
        showHelp
        exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true; do
    case "$1" in
        '-m'|'--mac-address')
            mac=$2
            echo -e " bluetooth mac address is ${mac}"
            shift 2
            continue
        ;;
        '-l'|'--lock-cmd')
            lock_cmd=$2
            echo -e " lock_cmd is ${lock_cmd}"
            shift 2
            continue
        ;;
        '-u'|'--unlock-cmd')
            unlock_cmd=$2
            echo -e " unlock_cmd is ${unlock_cmd}"
            shift 2
            continue
        ;;
        '--success-limit')
            success_limit=$2
            echo -e " success_limit is ${success_limit}"
            shift 2
            continue
        ;;
        '--failed-limit')
            failed_limit=$2
            echo -e " failed_limit is ${failed_limit}"
            shift 2
            continue
        ;;
        '-r'|'--rssi-limit')
            expr $2 + 0 &>/dev/null
            if [ $? != 0 ]; then
                echo -e " Error! Input a wrong number\n"
                showHelp
            fi
            # 判断参数值是否小于0
            if [ $2 -lt 0 ]; then
                rssi_limit=$2
                echo -e " rssi_limit set to ${rssi_limit}"
            else
                echo -e " Error, rssi must be negative\n"
                showHelp
            fi
            shift 2
            continue
        ;;
        '-d'|'--dry-run')
            dry_run=true
            echo -e " dry_run is ${dry_run}"
            shift
            continue
        ;;
        '-s'|'--scan')
            scan=true
            echo -e " scan is ${scan}"
            shift
            continue
        ;;
        '-h'|'--help')
            showHelp
        ;;
        '--')
            shift
            break
        ;;
        *)
            echo ' Internal error!' >&2
            echo
            showHelp
        ;;
    esac
done

if [[ ! ${scan} && ! $mac ]]; then
    echo " Error! mac address is empty"
    echo
    showHelp
fi

if [ ! $rssi_limit ]; then
    echo " rssi_limit is empty， use $rssi_limit_default"
    rssi_limit=$rssi_limit_default
fi

if [ ! $success_limit ]; then
    echo " success_limit is empty， use $checkout_success_limit_default"
    success_limit=$checkout_success_limit_default
fi

if [ ! $failed_limit ]; then
    echo " failed_limit is empty， use $checkout_fail_limit_default"
    failed_limit=$checkout_fail_limit_default
fi

if [ ! $lock_cmd ]; then
    echo " lock_cmd is empty, use 'loginctl lock-session'"
    lock_cmd='loginctl lock-session'
fi

if [ ! $unlock_cmd ]; then
    echo " unlock_cmd is empty, use 'loginctl unlock-session'"
    unlock_cmd='loginctl unlock-session'
fi

_checkout_fail_limit=0
_checkout_success_limit=0
_mode="unlock"
while true
do
    if [ ${scan} ]
    then
        bluetoothctl --timeout $scan_interval scan on
        sleep 3
    else
        rssi=`bluetoothctl --timeout $scan_interval scan on | grep "$mac" | grep -o "RSSI: -.*" | awk '{ print $2 }'`
        echo " rssi: $rssi"
        if [[ $rssi && $rssi -ge $rssi_limit ]]
        then
            _checkout_fail_limit=0
            _checkout_success_limit=$(($_checkout_success_limit + 1))
            echo -e "\e[32m [`date +'%F %T'`] checkout success $_checkout_success_limit times\e[0m"
        else
            _checkout_success_limit=0
            _checkout_fail_limit=$(($_checkout_fail_limit + 1))
            echo -e "\e[31m [`date +'%F %T'`] checkout failed $_checkout_fail_limit times\e[0m"
        fi

        if [[ $_checkout_success_limit -ge $success_limit && $_mode == "lock" ]]; then
            _checkout_fail_limit=0
            echo -e "\e[33m [`date +'%F %T'`] unlock\e[0m"
            _mode="unlock"
            if [ ! $dry_run ]; then
                `$unlock_cmd`
            fi
        fi

        if [[ $_checkout_fail_limit -ge $failed_limit && $_mode == "unlock" ]]; then
            _checkout_success_limit=0
            echo -e "\e[33m [`date +'%F %T'`] lock\e[0m"
            _mode="lock"
            if [ ! $dry_run ]; then
                `$lock_cmd`
            fi
        fi
    fi

done