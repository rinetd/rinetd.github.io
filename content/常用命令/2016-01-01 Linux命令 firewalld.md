---
title: Linux命令 firewall
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [firewall]
---
[不可不知的centos7 firewalld 防火墙的使用](https://segmentfault.com/a/1190000003931716)
[CentOS 7 firewalld使用简介](http://www.centoscn.com/CentOS/help/2015/0208/4667.html)
[Red_Hat Using_Firewalls](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Using_Firewalls.html)
[CentOS7下Firewall防火墙配置用法详解](http://www.centoscn.com/CentOS/Intermediate/2015/0313/4879.html)
---
yum install firewalld firewall-config

  systemctl start firewalld
  systemctl disable firewalld
  systemctl stop firewalld
  systemctl status firewalld     # firewall-cmd --state

Centos升级到7之后，发现无法使用iptables控制Linuxs的端口，google之后发现Centos 7使用firewalld代替了原来的iptables。下面记录如何使用firewalld开放Linux端口：

  开启端口

  `firewall-cmd --zone=public --add-port=80/tcp --permanent`

  命令含义：
  --zone #作用域
  --add-port=80/tcp #添加端口，格式为：端口/通讯协议
  --permanent #永久生效，没有此参数重启后失效

  重启防火墙
  firewall-cmd --reload

  允许 http 服务通过防火墙(永久)
      # firewall-cmd --add-service=http
firewall-cmd --add-service=mysql
firewall-cmd --add-port=21/tcp

  允许 3221 号端口通过防火墙(永久)。
      # firewall-cmd --permanent --add-port=3221/tcp
##########################################################
[](https://www.zhaokeli.com/article/6321.html)
开启80端口

出现success表明添加成功


命令含义：

--zone #作用域

--add-port=80/tcp  #添加端口，格式为：端口/通讯协议

--permanent   #永久生效，没有此参数重启后失效

重启防火墙

1、运行、停止、禁用firewalld

启动：# systemctl start  firewalld

查看状态：# systemctl status firewalld 或者 firewall-cmd --state

停止：# systemctl disable firewalld

禁用：# systemctl stop firewalld



2、配置firewalld

查看版本：$ firewall-cmd --version

查看帮助：$ firewall-cmd --help

查看设置：

显示状态：$ firewall-cmd --state

查看区域信息: $ firewall-cmd --get-active-zones

查看指定接口所属区域：$ firewall-cmd --get-zone-of-interface=eth0

拒绝所有包：# firewall-cmd --panic-on

取消拒绝状态：# firewall-cmd --panic-off

查看是否拒绝：$ firewall-cmd --query-panic



更新防火墙规则：# firewall-cmd --reload

# firewall-cmd --complete-reload

两者的区别就是第一个无需断开连接，就是firewalld特性之一动态添加规则，第二个需要断开连接，类似重启服务



将接口添加到区域，默认接口都在public

# firewall-cmd --zone=public --add-interface=eth0

永久生效再加上 --permanent 然后reload防火墙



设置默认接口区域

# firewall-cmd --set-default-zone=public

立即生效无需重启



打开端口（貌似这个才最常用）

查看所有打开的端口：

# firewall-cmd --zone=dmz --list-ports

加入一个端口到区域：

# firewall-cmd --zone=dmz --add-port=8080/tcp

若要永久生效方法同上



打开一个服务，类似于将端口可视化，服务需要在配置文件中添加，/etc/firewalld 目录下有services文件夹，这个不详细说了，详情参考文档

# firewall-cmd --zone=work --add-service=smtp



移除服务

# firewall-cmd --zone=work --remove-service=smtp
