#/bin/bash
echo "************************************************************************************************"
echo
echo "Change gfwlist to pac.txt that can be used in windows' ssr"
echo
echo "You should first install python, if you not install, please try 'apt-get install python'"
echo 
echo "it will download gfwlist from https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt, please wait"
echo
echo "************************************************************************************************"
python main.py  -f pac.txt -p "SOCKS5 127.0.0.1:1080"
echo
echo "OK, next copy the pac.txt to your ssr's folder"
echo 
