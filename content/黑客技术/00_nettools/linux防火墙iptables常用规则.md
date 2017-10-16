---
title: Linux命令 iptables
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ip]
---
linux防火墙iptables常用规则(屏蔽IP地址、禁用ping、协议设置、NAT与转发、负载平衡、自定义链)
==========================================================================================

新客网 XKER.COM 时间:2012-09-26 00:31:29来源:lesca.me  [评论:](#plshow)

条

<span style="text-align: left; line-height: 20px; font-family: 'WenQuanYi Micro Hei Mono', 'WenQuanYi Micro Hei', 'Microsoft Yahei Mono', 'Microsoft Yahei', sans-serif; color: rgb(51,51,51); font-size: 15px">本文介绍25个常用的iptables用法。如果你对iptables还不甚了解，可以参考上一篇</span>[iptables详细教程：基础、架构、清空规则、追加规则、应用实例](http://www.xker.com/page/e2012/0926/120759.html)<span style="text-align: left; line-height: 20px; font-family: 'WenQuanYi Micro Hei Mono', 'WenQuanYi Micro Hei', 'Microsoft Yahei Mono', 'Microsoft Yahei', sans-serif; color: rgb(51,51,51); font-size: 15px">，看完这篇文章，你就能明白iptables的用法和本文提到的基本术语。</span>

 

一、iptables：从这里开始
------------------------

### 删除现有规则

```
iptables -F
(OR)
iptables --flush
```

### 设置默认链策略

iptables的filter表中有三种链：INPUT, FORWARD和OUTPUT。默认的链策略是ACCEPT，你可以将它们设置成DROP。

```
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
```

你需要明白，这样做会屏蔽所有输入、输出网卡的数据包，除非你明确指定哪些数据包可以通过网卡。

### 屏蔽指定的IP地址

以下规则将屏蔽BLOCK\_THIS\_IP所指定的IP地址访问本地主机：

```
BLOCK_THIS_IP="x.x.x.x"
iptables -A INPUT -i eth0 -s "$BLOCK_THIS_IP" -j DROP
(或者仅屏蔽来自该IP的TCP数据包）
iptables -A INPUT -i eth0 -p tcp -s "$BLOCK_THIS_IP" -j DROP
```

### 允许来自外部的ping测试

```
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
```

### 允许从本机ping外部主机

```
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
```

### 允许环回(loopback)访问

```
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
```

二、iptables：协议与端口设定
----------------------------

### 允许所有SSH连接请求

本规则允许所有来自外部的SSH连接请求，也就是说，只允许**进入eth0接口，并且目的端口为22的数据包**

```
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

### 允许从本地发起的SSH连接

本规则和上述规则有所不同，本规则意在允许本机发起SSH连接，上面的规则与此正好相反。

```
iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

### 仅允许来自指定网络的SSH连接请求

以下规则仅允许来自192.168.100.0/24的网络：

```
iptables -A INPUT -i eth0 -p tcp -s 192.168.100.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

上例中，你也可以使用**-s 192.168.100.0/255.255.255.0**作为网络地址。当然使用上面的CIDR地址更容易让人明白。

### 仅允许从本地发起到指定网络的SSH连接请求

以下规则仅允许从本地主机连接到**192.168.100.0/24**的网络：

```
iptables -A OUTPUT -o eth0 -p tcp -d 192.168.100.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

### 允许HTTP/HTTPS连接请求

```
# 1.允许HTTP连接：80端口
iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

# 2.允许HTTPS连接：443端口
iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
```

### 允许从本地发起HTTPS连接

本规则可以允许用户从本地主机发起HTTPS连接，从而访问Internet。

```
iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
```

类似的，你可以设置允许HTTP协议（80端口）。

### -m multiport：指定多个端口

通过指定**-m multiport**选项，可以在一条规则中同时允许SSH、HTTP、HTTPS连接：

```
iptables -A INPUT -i eth0 -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m multiport --sports 22,80,443 -m state --state ESTABLISHED -j ACCEPT
```

### 允许出站DNS连接

```
iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT
```

### 允许NIS连接

如果你在使用NIS管理你的用户账户，你需要允许NIS连接。即使你已允许SSH连接，你仍需允许NIS相关的ypbind连接，否则用户将无法登陆。NIS端口是动态的，当ypbind启动的时候，它会自动分配端口。因此，首先我们需要获取端口号，本例中使用的端口是853和850：

```
rpcinfo -p | grep ypbind
```

然后，允许连接到111端口的请求数据包，以及ypbind使用到的端口：

```
iptables -A INPUT -p tcp --dport 111 -j ACCEPT
iptables -A INPUT -p udp --dport 111 -j ACCEPT
iptables -A INPUT -p tcp --dport 853 -j ACCEPT
iptables -A INPUT -p udp --dport 853 -j ACCEPT
iptables -A INPUT -p tcp --dport 850 -j ACCEPT
iptables -A INPUT -p udp --dport 850 -j ACCEPT
```

以上做法在你重启系统后将失效，因为ypbind会重新指派端口。我们有两种解决方法：
1.为NIS使用静态IP地址
2.每次系统启动时调用脚本获得NIS相关端口，并根据上述iptables规则添加到filter表中去。

### 允许来自指定网络的rsync连接请求

你可能启用了rsync服务，但是又不想让rsync暴露在外，只希望能够从内部网络（192.168.101.0/24）访问即可：

```
iptables -A INPUT -i eth0 -p tcp -s 192.168.101.0/24 --dport 873 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 873 -m state --state ESTABLISHED -j ACCEPT
```

### 允许来自指定网络的MySQL连接请求

你可能启用了MySQL服务，但只希望DBA与相关开发人员能够从内部网络（192.168.100.0/24）直接登录数据库：

```
iptables -A INPUT -i eth0 -p tcp -s 192.168.100.0/24 --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
```

### 允许Sendmail, Postfix邮件服务

邮件服务都使用了25端口，我们只需要允许来自25端口的连接请求即可。

```
iptables -A INPUT -i eth0 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
```

### 允许IMAP与IMAPS

```
# IMAP：143
iptables -A INPUT -i eth0 -p tcp --dport 143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 143 -m state --state ESTABLISHED -j ACCEPT

# IMAPS：993
iptables -A INPUT -i eth0 -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
```

### 允许POP3与POP3S

```
# POP3：110
iptables -A INPUT -i eth0 -p tcp --dport 110 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 110 -m state --state ESTABLISHED -j ACCEPT

# POP3S：995
iptables -A INPUT -i eth0 -p tcp --dport 995 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 995 -m state --state ESTABLISHED -j ACCEPT
```

### 防止DoS攻击

```
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
```

-   **-m limit:** 启用limit扩展
-   **–limit 25/minute:** 允许最多每分钟25个连接
-   **–limit-burst 100:** 当达到100个连接后，才启用上述25/minute限制

三、转发与NAT
-------------

### 允许路由

如果本地主机有两块网卡，一块连接内网(eth0)，一块连接外网(eth1)，那么可以使用下面的规则将eth0的数据路由到eht1：

```
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
```

### DNAT与端口转发

以下规则将会把来自422端口的流量转发到22端口。这意味着来自422端口的SSH连接请求与来自22端口的请求等效。

```
# 1.启用DNAT转发
iptables -t nat -A PREROUTING -p tcp -d 192.168.102.37 --dport 422 -j DNAT --to-destination 192.168.102.37:22

# 2.允许连接到422端口的请求
iptables -A INPUT -i eth0 -p tcp --dport 422 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 422 -m state --state ESTABLISHED -j ACCEPT
```

假设现在外网网关是xxx.xxx.xxx.xxx，那么如果我们希望把HTTP请求转发到内部的某一台计算机，应该怎么做呢？

```
iptables -t nat -A PREROUTING -p tcp -i eth0 -d xxx.xxx.xxx.xxx --dport 8888 -j DNAT --to 192.168.0.2:80
iptables -A FORWARD -p tcp -i eth0 -d 192.168.0.2 --dport 80 -j ACCEPT
```

当该数据包到达xxx.xxx.xxx.xxx后，需要将该数据包转发给192.168.0.2的80端口，事实上NAT所做的是**修改**该数据包的目的地址和目的端口号。然后再将该数据包**路由**给对应的主机。
但是iptables会接受这样的需要路由的包么？这就由FORWARD链决定。我们通过第二条命令告诉iptables可以转发目的地址为192.168.0.2:80的数据包。再看一下上例中422端口转22端口，这是同一IP，因此不需要设置FORWARD链。

### SNAT与MASQUERADE

如下命令表示把所有10.8.0.0网段的数据包SNAT成192.168.5.3的ip然后发出去：

```
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j snat --to-source 192.168.5.3
```

对于snat，不管是几个地址，必须明确的指定要snat的IP。假如我们的计算机使用ADSL拨号方式上网，那么外网IP是动态的，这时候我们可以考虑使用MASQUERADE

```
iptables -t nat -A POSTROUTING -s 10.8.0.0/255.255.255.0 -o eth0 -j MASQUERADE
```

### 负载平衡

可以利用iptables的**-m nth**扩展，及其参数（–counter 0 –every 3 –packet x），进行DNAT路由设置（-A PREROUTING -j DNAT –to-destination），从而将负载平均分配给3台服务器：

```
iptables -A PREROUTING -i eth0 -p tcp --dport 443 -m state --state NEW -m nth --counter 0 --every 3 --packet 0 -j DNAT --to-destination 192.168.1.101:443
iptables -A PREROUTING -i eth0 -p tcp --dport 443 -m state --state NEW -m nth --counter 0 --every 3 --packet 1 -j DNAT --to-destination 192.168.1.102:443
iptables -A PREROUTING -i eth0 -p tcp --dport 443 -m state --state NEW -m nth --counter 0 --every 3 --packet 2 -j DNAT --to-destination 192.168.1.103:443
```

自定义的链
----------

### 记录丢弃的数据包

```
# 1.新建名为LOGGING的链
iptables -N LOGGING

# 2.将所有来自INPUT链中的数据包跳转到LOGGING链中
iptables -A INPUT -j LOGGING

# 3.指定自定义的日志前缀"IPTables Packet Dropped: "
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7

# 4.丢弃这些数据包
iptables -A LOGGING -j DROP
```

本文来源:lesca.me

如果您喜欢本文请分享给您的好友，谢谢！如想浏览更多更好的[Linux教程](http://www.xker.com/edu/os/5/index.html)内容，请登录：<http://www.xker.com/edu/os/5/index.html>

### 相关文章:

-   [戴尔SuperMassive 9800防火墙带来企业级安全保护](http://www.xker.com/page/e2014/1030/141022.html "戴尔SuperMassive 9800防火墙带来企业级安全保护")
-   [安全新战略：下一代防火墙的革新之道](http://www.xker.com/page/e2014/1030/140936.html "安全新战略：下一代防火墙的革新之道")
-   [下一代防火墙采购须知](http://www.xker.com/page/e2014/1027/140469.html "下一代防火墙采购须知")
-   [在CentOS或RHEL上如何为LAMP服务器保驾护航](http://www.xker.com/page/e2014/1027/140453.html "在CentOS或RHEL上如何为LAMP服务器保驾护航")
-   [安全厂商纷纷升级下一代防火墙产品组合](http://www.xker.com/page/e2014/1027/140435.html "安全厂商纷纷升级下一代防火墙产品组合")
-   [云端自助管理让防火墙实现高效运维](http://www.xker.com/page/e2014/1026/140274.html "云端自助管理让防火墙实现高效运维")
-   [运维老鸟教你安装centos6.5如何选择安装包](http://www.xker.com/page/e2014/1026/140219.html "运维老鸟教你安装centos6.5如何选择安装包")
-   [下一代防火墙正当时](http://www.xker.com/page/e2014/1025/139984.html "下一代防火墙正当时")
-   [华为防火墙保障甘肃广电飞天云平台安全](http://www.xker.com/page/e2014/1025/139970.html "华为防火墙保障甘肃广电飞天云平台安全")
-   [CentOS Linux系统下安装Redis过程和配置参数说明](http://www.xker.com/page/e2014/1024/139812.html "CentOS Linux系统下安装Redis过程和配置参数说明")

相关内容标签:[Linux教程](http://www.xker.com/edu/os/5/index.html) [CentOS](http://www.xker.com/tag.php?/CentOS/)[防火墙](http://www.xker.com/tag.php?/%B7%C0%BB%F0%C7%BD/)[IPtables](http://www.xker.com/tag.php?/IPtables/)

-   上一篇：[CentOS 6.2 防火墙开启端口时注意事项](http://www.xker.com/page/e2012/0926/120757.html)
-   下一篇：[iptables详细教程：基础、架构、清空规则、追加规则、应用实例](http://www.xker.com/page/e2012/0926/120759.html)

 **评论列表（网友评论仅供网友表达个人看法，并不表明本站同意其观点或证实其描述）**   
-   

**栏目最新**  
-   [Linux 重启命令](http://www.xker.com/page/e2014/0925/135483.html)
-   [linux中文文件名乱码的解决办法（安装中文支持](http://www.xker.com/page/e2014/0902/133866.html)
-   [利用WGET下载文件，并保存到指定目录](http://www.xker.com/page/e2014/0808/133071.html)
-   [wget下载网站并且下载到指定目录](http://www.xker.com/page/e2014/0808/133070.html)
-   [php保护神Suhosin](http://www.xker.com/page/e2014/0708/132800.html)
-   [Linux Mariadb/MySQL数据库进阶优化参数](http://www.xker.com/page/e2014/0708/132799.html)
-   [linux系统修改远程连接端口号和关闭远程链接](http://www.xker.com/page/e2014/0708/132798.html)
-   [Linux下修改root密码](http://www.xker.com/page/e2014/0708/132797.html)
-   [LINUX安全加固](http://www.xker.com/page/e2014/0708/132796.html)
-   [linux Tengine/Nginx的配置优化](http://www.xker.com/page/e2014/0708/132793.html)
-   [linux内核参数调整优化](http://www.xker.com/page/e2014/0708/132792.html)
-   [Linux新装系统优化](http://www.xker.com/page/e2014/0708/132791.html)

**热点内容**  
-   [linux vi保存退出命令](http://www.xker.com/page/e2012/0114/106423.html)
-   [Linux运行.sh文件](http://www.xker.com/page/e2010/0409/95919.html)
-   [linux df命令参数详解](http://www.xker.com/page/e2009/0811/75606.html)
-   [linux命令行修改IP的2个方法](http://www.xker.com/page/e2009/0811/75607.html)
-   [fstab文件详解](http://www.xker.com/page/e2008/0627/54091.html)
-   [linux修改系统时间详解](http://www.xker.com/page/e2009/0326/70618.html)
-   [Ubuntu系统5大看图软件](http://www.xker.com/page/e2011/0322/100612.html)
-   [Linux常用基本命令及应用技巧](http://www.xker.com/page/e2007/0103/471.html)
-   [详细讲解Ubuntu Server安装过程](http://www.xker.com/page/e2007/0711/27650.html)
-   [Ubuntu校园网环境用mentohust完美替代锐捷联网成功](http://www.xker.com/page/e2010/0628/97055.html)
-   [如何进入linux命令行？](http://www.xker.com/page/e2009/0804/74999.html)
-   [linux开机启动项及启动项设置](http://www.xker.com/page/e2012/1015/121465.html)
-   [如何用Sysctl 调整Linux操作系统的性能](http://www.xker.com/page/e2007/1023/36677.html)
-   [在32位Ubuntu 10.04上编译Android 2.3](http://www.xker.com/page/e2011/0217/100213.html)
-   [centos 5.5 配置vnc，开启linux远程桌面教程（完整正确版）](http://www.xker.com/page/e2012/0114/106422.html)

**系统推荐**  
-   [轻便简单搞定 通过U盘安装Ubuntu Linux](http://www.xker.com/page/e2007/0727/28272.html)
-   [Linux 指令篇：文件传输--ftpwho](http://www.xker.com/page/e2007/0702/27218.html)
-   [七嘴八舌 Linux系统的优势到底在哪里？](http://www.xker.com/page/e2007/0719/27929.html)
-   [VMware Workstation实战](http://www.xker.com/page/e2007/0103/434.html)
-   [Linux下Makefile文件简单概念](http://www.xker.com/page/e2008/1028/63568.html)
-   [Linux系统开启TELNET服务的方法](http://www.xker.com/page/e2008/0619/53888.html)
-   [Linux显示中文文件名](http://www.xker.com/page/e2013/0829/129042.html)
-   [编译安装与RPM安装的区别](http://www.xker.com/page/e2012/1124/122008.html)
-   [Linux 指令篇：文档编辑--egrep](http://www.xker.com/page/e2007/0702/27252.html)
-   [利用U盘加载控制器驱动来安装Linux系统](http://www.xker.com/page/e2008/0128/46501.html)
-   [实例解析 Linux操作系统NFS配置部署过程](http://www.xker.com/page/e2007/0906/33653.html)
-   [Debian Linux LVM配置手册](http://www.xker.com/page/e2009/0907/77756.html)

Copyright © 2004-2014 [新客网](http://www.xker.com/) 版权所有. [最新更新](http://www.xker.com/newrolls/)
