---
title: Linux 系统优化
date: 2016-01-07T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags:
---

# Sysctl加载配置顺序问题

本地直接测试:
1. 加载所有的sysctl配置 `sysctl --system`
2. `sysctl -p` 默认无参数只加载/etc/sysctl.conf
发现它的顺序是先加载`/etc/sysctl.d/*.conf`, 最后加载`/etc/sysctl.conf`.

查看`man sysctl`加载顺序
``` man
--system
       Load settings from all system configuration files.
       /run/sysctl.d/*.conf
       /etc/sysctl.d/*.conf
       /usr/local/lib/sysctl.d/*.conf
       /usr/lib/sysctl.d/*.conf
       /lib/sysctl.d/*.conf
       /etc/sysctl.conf     # 最后加载
```
继续看/etc/init.d/sysctl:


如果仅仅是想临时改变某个系统参数的值，可以用两种方法来实现,例如想启用IP路由转发功能：
  1) #echo 1 > /proc/sys/net/ipv4/ip_forward
  2) #sysctl -w net.ipv4.ip_forward=1
如果想永久保留配置，可以修改`sudo vi /etc/sysctl.conf`文件
net.ipv4.ip_forward=0改为net.ipv4.ip_forward=1


# elasticsearch 启动失败

sudo sysctl -w vm.max_map_count=262144
sudo sysctl -a|grep vm.max_map_count
`echo vm.max_map_count=262144 |sudo tee /etc/sysctl.d/10-vm.conf`
