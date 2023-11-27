#!/bin/bash
# 将release分支转换为release tag
# release 分支的格式为 origin/release/yyyymmdd
# release tag的格式为 release-yyyymmdd

# 从第一个参数获取本地仓库的路径
cd $1

days=30
# 获取指定天数之前的日期
date=`date -d "-${days} day" +%Y%m%d`
# 获取所有的release分支
branches=`git branch -r | grep "origin/release" | awk -F '/' '{print $3}'`
for branch in ${branches}
do
    # 判断release分支是否小于指定天数之前的日期
    if [ ${branch} -lt ${date} ]; then
      echo ${branch}
        # 将release分支转换为release tag
        git tag release-${branch} origin/release/${branch}
        # 将release tag推送到远程仓库
        git push origin release-${branch}
        # 删除本地release分支和tag
        git branch -D release/${branch}
        git tag -d release-${branch}
        # 删除远程release分支
        git push origin :release/${branch}
    fi
done
