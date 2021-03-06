GFWList2PAC
===========

Generate O(1) PAC file from gfwlist.

fork from [breakwa11](https://github.com/breakwa11/GFWList2PAC)

Add a shell script to execute `python main.py  -f pac.txt -p "SOCKS5 127.0.0.1:1080"` in `RUN-ME.sh`.

Here is the content of breakwa11's readme file

### Usage

    usage: main.py [-h] [-i GFWLIST] -f PAC -p PROXY [--user-rule USER_RULE]

    optional arguments:
      -h, --help            show this help message and exit
      -i GFWLIST, --input GFWLIST
                            path to gfwlist
      -f PAC, --file PAC    path to output pac
      -p PROXY, --proxy PROXY
                            the proxy parameter in the pac file, for example,
                            "SOCKS5 127.0.0.1:1080;"
      --user-rule USER_RULE
                            user rule file, which will be appended to gfwlist

### Example

    main.py -i gfwlist.txt -f proxy.pac -p "PROXY 127.0.0.1:8087"

    you can download gfwlist.txt yourself

    you can add a custom list into gfwlist2pac/resources/custom.txt

    and add a ban list which you want a direct connection into gfwlist2pac\resources\ban.txt


fork from [clowwindy](https://github.com/clowwindy/gfwlist2pac)