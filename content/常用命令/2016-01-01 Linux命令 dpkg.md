---
title: Linux命令 dpkg
date: 2016-01-06T16:46:14+08:00
update: 2016-09-27 16:03:53
categories: [linux_base]
tags: [dpkg]
---
sudo dpkg -I ipux.deb#查看iptux.deb软件包的详细信息，包括软件名称、版本以及大小等（其中-I等价于--info）
sudo dpkg -c ipux.deb#查看iptux.deb软件包中包含的文件结构（其中-c等价于--contents）
sudo dpkg -i ipux.deb#安装iptux.deb软件包（其中-i等价于--install）
sudo dpkg -l ipux#查看iptux软件包的信息（软件名称可通过dpkg -I命令查看，其中-l等价于--list）
sudo dpkg -L ipux#查看iptux软件包安装的所有文件（软件名称可通过dpkg -I命令查看，其中-L等价于--listfiles）
sudo dpkg -s ipux#查看iptux软件包的详细信息（软件名称可通过dpkg -I命令查看，其中-s等价于--status）
sudo dpkg -r ipux#卸载iptux软件包（软件名称可通过dpkg -I命令查看，其中-r等价于--remove）
