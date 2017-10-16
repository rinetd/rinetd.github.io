---
title: Linux命令 sudo
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [sudo]
---

有很多朋友可能在使用sudo时会出现sudo echo ‘xxx’ > /path/file 重定向时 Permission denied错误，下面我来给各位介绍解决办法

例

1 sudo "echo '[yaf]' > /usr/local/php/etc/include/yaf.ini"

2 #Permission denied 权限不够

使用sudo echo ‘xxx’ > /path/file 时，其实sudo只用在了 echo 上，而重定向没有用到sudo的权限，所以会出现“Permission denied”的情况，解决的方法也很简单，就是一个参数而已。加一个“ sh -c ”就可以把权限指定到整条shell了。

sudo sh -c "echo '[yaf]' > /usr/local/php/etc/include/yaf.ini"

另一种方法是利用管道和 tee 命令，该命令可以从标准输入中读入信息并将其写入标准输出或文件中，具体用法如下：

`echo “xxxx” | sudo tee -a test.txt`

tee 命令的 “-a” 选项的作用等同于 “>>” 命令，如果去除该选项，那么 tee 命令的作用就等同于 “>” 命令。
