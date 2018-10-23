# SunriseYDY 的 shell 项目集合

此项目主要存放了我个人写的一些小的 shell 脚本

## 文件信息

### [GFWList2PAC](GFWList2PAC)

通过 Python 来生成 pac.txt 文件的脚本， fork 自破娃酱的 [GFWList2PAC](https://github.com/breakwa11/GFWList2PAC) 项目，目录内有一个 RUN-ME.sh ，在Linux下运行 `RUN-ME.sh` 可以自动更新 GFWList2PAC 文件夹中的 GFWList 并转换为 pac.txt

在我的下载站中有每周更新的 pac.txt 文件，地址：[https://dl.sunriseydy.top/pac/](https://dl.sunriseydy.top/pac/)

### [editpac.sh](editpac.sh)

用来编辑 pac.txt 文件的 shell 脚本。由于使用了 sed 命令来匹配文本内容，目前就适配了上面所生成的 pac.txt 文件。

使用方法：

    bash editpac.sh [path/to/pac.txt]

参数为pac.txt 文件所在的路径，不过不加参数则默认为当前脚本目录下的 pac.txt 文件。

### [generateBackgroundPicturesXML.sh](generateBackgroundPicturesXML.sh)

用来生成 gnome 桌面环境下自动更换桌面壁纸的 xml 配置文件的脚本

已在 Ubuntu 16.04 18.04 上测试成功

使用方法：

    bash generateBackgroundPicturesXML.sh -p path -s seconds

具体的选项说明如下：

    Options:
    -p Required! The directory path to pictures, which is used to set wallpapers, if not specified, will use current directory(pwd).
    -s Required! Integer! The seconds that per pictures will be shown. By default it is 600s(10min)
    -h Show this help info.

生成的 xml 配置文件，无法直接在 gnome 的设置-背景 中找到(因为没有移动到系统目录下)，所以只能使用 `gsettings` 命令来设置(已在脚本中自动执行)，或者手动在"优化"应用中选中生成的 xml 文件。