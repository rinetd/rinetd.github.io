---
title: Linux命令 iptables
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ip]
---
iptables的recent模块
http://www.cnblogs.com/silenceli/p/3416175.html

看到文章中用recent模块控制对主机的访问。

配置方法如下：

`iptables -A INPUT -p icmp --icmp-``type` `8 -m length --length 78 -j LOG --log-prefix ``"SSHOPEN: "`

`#记录日志，前缀SSHOPEN:`

`iptables -A INPUT -p icmp --icmp-``type` `8 -m length --length 78 -m recent --``set` `--name sshopen --rsource -j ACCEPT`

`#指定数据包78字节，包含IP头部20字节，ICMP头部8字节。`

`iptables -A INPUT -p tcp --dport 22 --syn -m recent --rcheck --seconds 15 --name sshopen --rsource -j ACCEPT`

`ping` `-s 50 host ``#Linux下解锁`

`ping` `-l 50 host ``#Windows下解锁`

 

在配置的过程中我按照这样配置无法ssh到指定主机。

仔细研究了下，需要一个前提即：

iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

且该条规则需要放在上面第三条之前。

 

整理后的配置规则：

1.  iptables -F
2.  iptables -X
3.  iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
4.  iptables -A INPUT -p icmp --icmp-type 8 -m length --length 78 -j LOG --log-prefix 'SSH\_OPEN\_KEY'
5.  iptables -A INPUT -p icmp --icmp-type 8 -m length --length 78 -m recent --name openssh --set --rsource -j ACCEPT
6.  iptables -A INPUT -p tcp --dport 22 --syn -m state --name openssh --rcheck --seconds 60 --rsource -j ACCEPT
7.  iptables -P INPUT DROP
8.  在客户侧，如果需要ssh到主机，需要先ping -l 50 ip(windows), ping -s 50 ip (linux)，并在一分钟之内ssh到主机，这样在/proc/net/xt\_recent/目录下生成openssh文件
    文件内容如下：
    src=112.1x3.2x7.24 ttl: 53 last\_seen: 42963x6778 oldest\_pkt: 1 4296376778, 4295806644, 4295806895, 4295807146, 4295826619, 4295826870, 4295827122, 4295827372, 4295833120, 4295833369, 4295834525, 4295834777, 4295872016, 4295872267, 4295872519, 4295872769, 4295889154, 4295889406, 4295889658, 4295889910

解释：

1,2清空原有的iptables规则

3，表明已经建立成功的连接和与主机发送出去的包相关的数据包都接受，如果没有这一步，后面的tcp连接无法建立起来

4，出现长度为78字节icmp回响包在/var/log/syslog生成log，log以SSH\_OPEN\_KEY开头

5，出现长度为78字节icmp回响包，将源地址信息记录在openssh文件中，并接受

6，对于openssh文件中的源地址60s以内发送的ssh连接SYN请求予以接受

7，将INPUT链的默认策略设置为drop

调试过程：没有设置3，则无法建立ssh连接

在没有3的情况下，设置6如果不加--syn，则可以ssh连接一会儿，过一会儿又自动断线，除非ping一下目的地址，原理是：ping目的地址，则会更新openssh的时间，这样ssh连接还在60s之内，所以可以通信，过一会儿，60s超时，则就会断开ssh连接。如果加了--syn，只能进行开始的syn，无法正常连接（具体过程不熟悉，有待进一步学习）。

 

给一个参考：

<http://blog.onovps.com/archives/iptables-recent.html>
