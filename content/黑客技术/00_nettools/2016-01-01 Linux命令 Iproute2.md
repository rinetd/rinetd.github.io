---
title: Linux命令 Iproute2
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ip]
---
![Iproute2](http://www.iamle.com/wp-content/uploads/2014/09/wpid-abf17d4f53f3b97cabb69165ef222945_iproute23.png)
![Iproute2](http://s8.51cto.com/wyfs02/M00/2C/45/wKiom1OOgvChGrdiAAdSqx73gOg911.jpg)

用途 	net-tool（被淘汰） 	iproute2
地址和链路配置 	ifconfig 	ip addr, ip link
路由表 	route 	ip route
邻居 	arp 	ip neigh
VLAN 	vconfig 	ip link
隧道 	iptunnel 	ip tunnel
组播 	ipmaddr 	ip maddr
统计 	netstat 	ss

场景一：我想查看当前服务器的网络连接统计】

$ ss -s
场景二：我想查看所有打开的网络端口】

$ ss -l
场景三：我想查看这台服务器上所有的socket连接】

#ss -a
