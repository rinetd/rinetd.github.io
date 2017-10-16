---
title: Linux命令 iptables
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ip]
---
iptables模块使用示例汇总
========================

Centos/Linux服务器防火墙/iptables简单设置
=========================================

```
#/bin/bash
sshport=`netstat -lnp|awk -F"[ ]+|[:]" '/sshd/{print$5}'`
iptables -F #清除自带规则
iptables -X
iptables -P INPUT DROP #进入本机数据包默认拒绝
iptables -P OUTPUT ACCEPT #本起外出数据包允许
iptables -A INPUT -i lo -j ACCEPT #允许本地环回
iptables -A INPUT -m state --state INVALID  -j LOG --log-prefix "INVALID" --log-ip-options

#记录无效的数据包并丢弃
iptables -A INPUT -m state --state INVALID  -j  DROP

#允许已建立连接与出相关的数据包进入
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#允许目标端口为80的新连接进入
iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT

#允许目标端口为$sshdport的新链接进入
iptables -A INPUT -m state --state NEW -p tcp --dport $sshdport -j ACCEPT

#允许ping回应，每秒5个，最多20个
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s --limit-burst 20 -j ACCEPT

#保存规则，重启iptables服务
service iptables save
```

Iptables处理数据包详细流程图
============================

![](/uploads/blog/image/20131227/417f4ca48e616a78872b0509b8471210.jpg)

Iptables包流程如下：

```
1. 数据包到达网络接口，比如 eth0。
2. 进入 raw 表的 PREROUTING 链，这个链的作用是赶在连接跟踪之前处理数据包。
3. 如果进行了连接跟踪，在此处理。
4. 进入 mangle 表的 PREROUTING 链，在此可以修改数据包，比如 TOS 等。
5. 进入 nat 表的 PREROUTING 链，可以在此做DNAT，但不要做过滤。
6. 决定路由，看是交给本地主机还是转发给其它主机。

到了这里我们就得分两种不同的情况进行讨论了，一种情况就是数据包要转发给其它主机，这时候它会依次经过：
7. 进入 mangle 表的 FORWARD 链，这里也比较特殊，这是在第一次路由决定之后，在进行最后的路由决定之前，我们仍然可以对数据包进行某些修改。
8. 进入 filter 表的 FORWARD 链，在这里我们可以对所有转发的数据包进行过滤。需要注意的是：经过这里的数据包是转发的，方向是双向的。
9. 进入 mangle 表的 POSTROUTING 链，到这里已经做完了所有的路由决定，但数据包仍然在本地主机，我们还可以进行某些修改。
10. 进入 nat 表的 POSTROUTING 链，在这里一般都是用来做 SNAT ，不要在这里进行过滤。
11. 进入出去的网络接口。完毕。

另一种情况是，数据包就是发给本地主机的，那么它会依次穿过：
7. 进入 mangle 表的 INPUT 链，这里是在路由之后，交由本地主机之前，我们也可以进行一些相应的修改。
8. 进入 filter 表的 INPUT 链，在这里我们可以对流入的所有数据包进行过滤，无论它来自哪个网络接口。
9. 交给本地主机的应用程序进行处理。
10. 处理完毕后进行路由决定，看该往那里发出。
11. 进入 raw 表的 OUTPUT 链，这里是在连接跟踪处理本地的数据包之前。
12. 连接跟踪对本地的数据包进行处理。
13. 进入 mangle 表的 OUTPUT 链，在这里我们可以修改数据包，但不要做过滤。
14. 进入 nat 表的 OUTPUT 链，可以对防火墙自己发出的数据做 NAT 。
15. 再次进行路由决定。
16. 进入 filter 表的 OUTPUT 链，可以对本地出去的数据包进行过滤。
17. 进入 mangle 表的 POSTROUTING 链，同上一种情况的第9步。注意，这里不光对经过防火墙的数据包进行处理，还对防火墙自己产生的数据包进行处理。
18. 进入 nat 表的 POSTROUTING 链，同上一种情况的第10步。
19. 进入出去的网络接口，完毕。
```

iptables日记模块LOG使用
=======================

iptables匹配相应规则后会触发一个动作，filter和nat表一般常用的有以下目标操作。

```
ACCEPT      #允许数据包通过
DROP        #丢弃数据包，不对该数据包进一步处理
REFECT      #丢弃数据包，同时发送响应报文
--reject-with tcp-reset #返回tcp重置
--reject-with icmp-net-unreachable    #返回网络不可达
--reject-with icmp-host-unreachable   #返回主机不可达
RETURN        #转到其它链处理
LOG           #将数据包信息记录到syslog
```

本文就记录下LOG规则的使用，示例：进入的tcp端口为80的数据包记录到日记，错误级别err，描述前缀为INPUT，记录IP/TCP相关信息。

```
modprobe ipt_LOG   #加载模块
iptables -A INPUT -p tcp --dport 80 -j LOG --log-level err --log-prefix "INPUT" --log-ip-options --log-tcp-sequence
--log-level           #错误级别
--log-prefix "INPUT"  #描述前缀
--log-ip-options      #记录IP信息
--log-tcp-sequence    #记录TCP序列号
```

然后访问服务器80端口测试，通过dmesg查看记录的信息如下：

```
INPUTIN=eth0 OUT= MAC=00:0c:29:73:e0:19:8c:89:a5:65:3a:4a:08:00 SRC=192.168.1.16 DST=192.168.1.2 \
LEN=522 TOS=0x00 PREC=0x00 TTL=128 ID=27499 DF PROTO=TCP SPT=5430 DPT=80 SEQ=3847892455 \
ACK=3435733082 WINDOW=16344 RES=0x00 ACK PSH URGP=0
```

还可以修改syslog将日志写入到文件，vim /etc/syslog.conf 添加以下内容

```
kern.err   /var/log/iptables #日志文件路径
```

重启syslog服务

```
# /etc/init.d/syslog restart
```

Iptables模块recent应用
======================

recent这个模块很有趣，善加利用可充分保证您服务器安全。

设定常用参数：

```
--name        #设定列表名称，默认DEFAULT。
--rsource   #源地址，此为默认。
--rdest     #目的地址
--seconds   #指定时间内
--hitcount  #命中次数
--set       #将地址添加进列表，并更新信息，包含地址加入的时间戳。
--rcheck    #检查地址是否在列表，以第一个匹配开始计算时间。
--update    #和rcheck类似，以最后一个匹配计算时间。
--remove    #在列表里删除相应地址，后跟列表名称及地址。
```

示例：

1）限制80端口60秒内每个IP只能发起10个新连接，超过记录日记及丢失数据包，可防CC及非伪造IP的syn
flood

```
iptables -A INPUT -p tcp --dport 80 --syn -m recent --name webpool --rcheck --seconds 60 --hitcount 10 -j LOG --log-prefix 'DDOS:' --log-ip-options
iptables -A INPUT -p tcp --dport 80 --syn -m recent --name webpool --rcheck --seconds 60 --hitcount 10 -j DROP
iptables -A INPUT -p tcp --dport 80 --syn -m recent --name webpool --set -j ACCEPT
```

备忘：每个IP目标端口为80的新连接会记录在案，可在/proc/net/xt\_recent/目录内查看，rcheck检查此IP是否在案及请求次数，如果超过规则就丢弃数据包，否则进入下条规则并更新列表信息。

2）发送特定指定执行相应操作，按上例如果自己IP被阻止了，可设置解锁哦

```
#记录日志，前缀WEBOPEN:
iptables -A INPUT -p tcp --dport 5000 --syn -j LOG --log-prefix "WEBOPEN: "

#符合规则即删除webpool列表内的本IP记录
iptables -A INPUT -p tcp --dport 5000 --syn -m recent --remove --name webpool --rsource -j REJECT --reject-with tcp-reset
```

3）芝麻开门，默认封闭SSH端口，为您的SSH服务器设置开门暗语

```
#记录日志，前缀SSHOPEN:
iptables -A INPUT -p tcp --dport 50001 --syn -j LOG --log-prefix "SSHOPEN: "

#目标端口tcp50001的新数据设定列表为sshopen返回TCP重置，并记录源地址
iptables -A INPUT -p tcp --dport 50001 --syn -m recent --set --name sshopen --rsource -j REJECT --reject-with tcp-reset

#开启SSH端口，15秒内允许记录的源地址登录SSH
iptables -A INPUT -p tcp --dport 22 --syn -m recent --rcheck --seconds 15 --name sshopen --rsource -j ACCEPT

#开门钥匙
nc host 50001
telnet host 50001
nmap -sS host 50001
```

指定端口容易被破解密钥，可以使用ping指定数据包大小为开门钥匙

```
#记录日志，前缀SSHOPEN:
iptables -A INPUT -p icmp --icmp-type 8 -m length --length 78 -j LOG --log-prefix "SSHOPEN: "

#指定数据包78字节，包含IP头部20字节，ICMP头部8字节
iptables -A INPUT -p icmp --icmp-type 8 -m length --length 78 -m recent --set --name sshopen --rsource -j ACCEPT
iptables -A INPUT -p tcp --dport 22 --syn -m recent --rcheck --seconds 15 --name sshopen --rsource -j ACCEPT

ping -s 50 host     #Linux下解锁
ping -l 50 host     #Windows下解锁
```

Iptables限速模块limit应用
=========================

Iptables模块limit用于限制单位时间内通过的数据包数量，限制是全局的，适用于某些不重要的服务，如果限制ICMP数量，HTTP可使用recent模块针对每个IP做限制，精确流量限制可用TC。

Limit可用选项：

```
--limit 单位时间内匹配的数据包数量
--limit-burst 可选，允许最大数据包数量，默认为5
/s /h /m 单位时间
```

应用举例：

每分钟允许通过1个ICMP数据包，最多不超过10个。

```
iptables -A INPUT -p icmp -m limit --limit 1/m --limit-burst 10 -j ACCEPT
iptables -A INPUT -p icmp  -j DROP
```

Iptables之conntrack连接跟踪模块
===============================

Iptables是有状态机制的防火墙，通过conntrack模块跟踪记录每个连接的状态，通过它可制定严密的防火墙规则。

可用状态机制：

```
NEW         #新连接数据包
ESTABLISHED #已连接数据包
RELATED     #和出有送的数据包
INVALID     #无效数据包
```

conntrack默认最大跟踪65536个连接，查看当前系统设置最大连接数：

```
# cat /proc/sys/net/ipv4/ip_conntrack_max
```

查看当前跟踪连接数：

```
# cat /proc/net/ip_conntrack | wc -l
```

当服务器连接多于最大连接数时会出现kernel: ip\_conntrack: table full,
dropping packet的错误。

解决方法，修改conntrack最大跟踪连接数：

vi /etc/sysctl.conf 添加以下内容

```
net.ipv4.ip_conntrack_max = 102400
```

立即生效：

```
# sysctl -p
```

为防止重启Iptables后变为默认，还需修改模块参数：

vi /etc/modprobe.conf 添加以下内容

```
#值为102400/8
options ip_conntrack hashsize=12800
```

一劳永逸的方法，设置Iptables禁止对连接数较大的服务进行跟踪：

```
iptables -A INPUT -m state --state UNTRACKED,ESTABLISHED,RELATED -j ACCEPT
iptables -t raw -A PREROUTING -p tcp --dport 80 -j NOTRACK
iptables -t raw -A OUTPUT -p tcp --sport 80 -j NOTRACK
```

Iptables之connlimit模块针对每个IP限制连接数
===========================================

上面有介绍Iptables下limit模块，此模块应用限制是全局的，connlimit就灵活了许多，针对每个IP做限制。

应用示例，注意不同的默认规则要使用不同的方法。

1）默认规则为DROP的情况下限制每个IP连接不超过10个

```
iptables -P INPUT DROP
iptables -A INPUT -p tcp --dport 80 -m connlimit ! --connlimit-above 10 -j ACCEPT
```

2）默认规则为ACCEPT的情况下限制每个IP连接不超过10个

```
iptables -P INPUT ACCEPT
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 10 -j DROP
```

Iptables模块recent错误iptables: Unknown error 18446744073709551615解决
======================================================================

Iptables的recent用做防CC效果很好，刚刚在调整单个IP跟踪数据包数量时遇到以下错误
:

```
iptables: Unknown error 18446744073709551615
iptables: Unknown error 18446744073709551615
iptables: Unknown error 4294967295
iptables: Unknown error 4294967295
```

查看recent模块已正常加载：

```
lsmod | grep recent
ipt_recent      42969  3
x_tables        50505  7 ipt_recent,xt_state,ip_tables,ipt_LOG,ipt_REJECT,xt_tcpudp,ip6_tables
```

使用modinfo命令，<span>查看recent模块信息：</span>

```
# modinfo     ipt_recent
```

得到如下信息：

```
filename:       /lib/modules/2.6.18-348.16.1.el5xen/kernel/net/ipv4/netfilter/ipt_recent.ko
license:        GPL
description:    IP tables recently seen matching module
author:         Patrick McHardy <kaber@trash.net>
srcversion:     98489C441E24A457
depends:        x_tables
vermagic:       2.6.18-348.16.1.el5xen SMP mod_unload 686 REGPARM 4KSTACKS gcc-4.1
parm:           ip_list_tot:number of IPs to remember per list (uint)
parm:           ip_pkt_list_tot:number of packets per IP to remember (max. 255) (uint)
parm:           ip_list_hash_size:size of hash table used to look up IPs (uint)
parm:           ip_list_perms:permissions on /proc/net/ipt_recent/* files (uint)
module_sig: 89811280930a09a91aef1b8885b4e5f21b61320a08694f06cde9625301f4ea4289a
```

可见recent最大跟踪IP及数据包数量可以调整的，设置最大跟踪数据包为100：

```
# cat >> /etc/modprobe.conf <<EOF
options ip_pkt_list_tot=100
EOF
```

重新加载recent模块：

```
/etc/init.d/iptables stop
modprobe -r ipt_recent
modprobe  ipt_recent
/etc/init.d/iptables start
```

再次调整参数，一切正常。

LVS+Keepalived下Iptables配置
============================

```
iptables -I INPUT -d 224.0.0.0/8 -j ACCEPT
iptables -I INPUT -p vrrp -j ACCEPT
```

Iptables拒绝指定国家的IP访问
============================

有些服务器需拒绝特定国家的IP访问，可使用Iptables配合ipdeny提供的各个国家IP段为源进行过滤操作，由于数目较多会影响iptables性能，也可使用高效率Iptables
geoip模块进行匹配操作。

应用示例，以拒绝美国IP为例：

```
#/bin/bash
wget -O /tmp/us.zone http://www.ipdeny.com/ipblocks/data/countries/us.zone
for ip in `cat /tmp/us.zone`
do
Blocking $ip
iptables -I INPUT -s $ip -j DROP
done
```

Iptables数据包大小匹配模块length应用
====================================

Iptables下length模块可对数据包的大小进行匹配操作，拒绝非必要的数据进入。

length使用参数：

```
-m length --length num       #匹配指定大小的数据
-m length ! --length num     #匹配非指定大小数据
-m length --length num:      #匹配大于或等于
-m length --length :92       #匹配小于或等于
-m length --length num:num   #匹配指定区间
```

length应用示例：

```
#仅允许数据包小于或等于60字节的ping请求数据进入
iptables -I INPUT -p icmp --icmp-type 8 -m length --length :60 -j ACCEPT
```

PING测试Wwindows下ping默认发送32字节数据，包含IP、ICMP头28字节，共60字节。

```
ping www.qixing318.com
正在 Ping www.qixing318.com [184.164.141.188] 具有 32 字节的数据:
来自 184.164.141.188 的回复: 字节=32 时间=183ms TTL=51
来自 184.164.141.188 的回复: 字节=32 时间=212ms TTL=51
来自 184.164.141.188 的回复: 字节=32 时间=185ms TTL=51
来自 184.164.141.188 的回复: 字节=32 时间=178ms TTL=51
```

默认可以PING通过，然后自定义数据大小PING

```
ping -l 40 www.qixing318.com
正在 Ping www.qixing318.com 具有 40 字节的数据:
请求超时。
请求超时。
请求超时。
请求超时。
```

可见如果PING发送数据超过系统限制会拒绝数据包进入

Iptables下MSS数据调整模块TCPMSS使用
===================================

为达到最佳的传输效能TCP在建立连接时会协商MSS（最大分段长度，一般为1460字节）值，即MTU（最大传输单元，不超过1500字节）减去IP数据包包头20字节和TCP数据包头20字节，取最小的MSS值为本次连接的最大MSS值，Iptables下TCPMSS模块即用来调整TCP数据包中MSS数值。

在ADSL拨号环境中由于PPP包头占用8字节，MTU为1492字节，MSS为1452字节，如不能正确设置会导致网络不正常，可以通过TCPMSS模块调整MSS大小。

TCPMSS使用参数：

```
--set-mss value #设置特定MSS值
--clamp-mss-to-pmtu #根据MTU自动调整MSS
```

应用示例：

```
#自动调整经pppoe-wan接口发出的TCP数据MSS
iptables -t mangle -I POSTROUTING -o pppoe-wan -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

Linux下用arptables防arp攻击
===========================

Linux下网络层防火墙iptables很强大，链路层也有类似的防火墙arptables，可针对arp地址进行限制，防止ARP网关欺骗攻击，再配合静态绑定MAC和向网关报告正确的本机MAC地址，有效解决ARP攻击问题。

Centos5安装：

```
wget http://superb-sea2.dl.sourceforge.net/project/ebtables/arptables/arptables-v0.0.3/arptables-v0.0.3-4.tar.gz
tar zxvf arptables-v0.0.3-4.tar.gz
cd arptables-v0.0.3-4
make
make install
```

arptables规则设置：

```
arptables -F

#默认策略
arptables -P INPUT ACCEPT

#允许本网段特定MAC可进入，且IP与MAC相符
arptables -A INPUT --src-ip 192.168.1.1 --src-mac 7A:31:14:42:10:01 -j ACCEPT

#拒绝非网关MAC
arptables -A INPUT --src-mac ! 74:8E:F8:53:DC:C0 -j DROP

#拒绝非网关IP
arptables -A INPUT --src-ip ! 192.168.1.1 -j DROP
```

保存规则并开机加载：

```
iptables-save > /etc/sysconfig/arptables
/etc/init.d/arptables save
chkconfig arptables on
```

规则保存后重新加载会出错，去除以下文件内-o any字段。

```
# /etc/sysconfig/arptables
```

Iptables模块TTL应用禁止二级路由及禁止tracert被跟踪
==================================================

TTL即Time To
Live，用来描述数据包的生存时间，防止数据包在互联网上一直游荡，每过一个路由减1，TTL为1时丢弃数据包并返回不可达信息。

Iptables
TTL模块可以修改收到、发送数据的TTL值，这模块很有趣，可以实现很多妙用。

TTL使用参数：

```
--ttl-set     #设置TTL的值
--ttl-dec     #设置TTL减去的值
--ttl-inc     #设置TTL增加的值
```

应用示例：
禁止被tracert跟踪到，traceroute跟踪时首先向目标发送TTL为1的IP数据，路由收到后丢弃数据包并返回不可达信息，以此递增直到目标主机为止。

```
#禁止TTL为1的数据包进入
iptables -A INPUT -m ttl --ttl-eq 1 -j DROP

#禁止转发TTL为1的数据
iptables -A FORWARD -m ttl --ttl-eq 1 -j DROP
```

禁止二级路由：

```
#进入路由数据包TTL设置为2，二级路由可接收数据不转发。
iptables -t mangle -A PREROUTING -i pppoe-wan -j TTL --ttl-set 2
```

Centos编译IPID模块配置TTL防网络尖兵
===================================

Centos自带iptables
TTL模块，IPID源码下载地址：http://bbs.chinaunix.net/thread-2102211-1-1.html

```
yum -y install kernel-devel
wget http://ftp.netfilter.org/pub/iptables/iptables-1.3.5.tar.bz2
tar jxvf iptables-1.3.5.tar.bz2
ln -s iptables-1.3.5 /usr/src/iptables
```

编译安装IPID：

```
cd iptables-ipid-2.1
sed -i 's/new_ipid\[i\]/new_ipid\[id\]/g' ipt_IPID.c
make
cp ipt_IPID.ko /lib/modules/2.6.18-308.11.1.el5/kernel/net/ipv4/netfilter/
chmod 744 /lib/modules/2.6.18-308.11.1.el5/kernel/net/ipv4/netfilter/ipt_IPID.ko
cp libipt_IPID.so /lib/iptables/
depmod -a
modprobe ipt_IPID
```

使用参数：

```
--ipid-pace [number] 设置每次增加的步调值，如果为0，则数据包的IPID字段应该为一个固定的值。
--ipid-choatic 0     设置随机IPID。0仅仅是填充参数作用。
```

应用示例：

```
#限制2级路由
iptables -t mangle -A PREROUTING  -i pppoe-wan -j TTL --ttl-inc 1

#这样路由本机和下级电脑发的数据都修改TTL和IPID信息，修改TTL会导致tracert跟踪不正常。
#如需不影响路由本机tracert可在FORWARD链修改数据包信息
iptables -t mangle -A POSTROUTING -o pppoe-wan -j TTL --ttl-set 128
iptables -t mangle -A POSTROUTING -o pppoe-wan -j IPID --ipid-pace 1
```

Centos5.7不编译内核安装Iptables Layer7模块
==========================================

Centos查看当前内核、Iptables版本并下载相应源码：

```
uname -r
2.6.18-274.el5
cd /usr/src/kernels/
wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.18.tar.gz
iptables -V
iptables v1.3.5
wget http://ftp.netfilter.org/pub/iptables/iptables-1.3.5.tar.bz2
```

或下载Centos官方内核源码：

```
useradd test
su -l test
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
yum install rpm-build redhat-rpm-config unifdef
rpm -i http://vault.centos.org/5.7/os/SRPMS/kernel-2.6.18-274.el5.src.rpm
cd ~/rpmbuild/SPECS
rpmbuild -bp --target=$(uname -m) kernel.spec
cd ~/rpmbuild/BUILD/kernel*/linux*/ #源码所在目录
```

下载Layer7模块和规则文件：

```
wget http://sourceforge.net/projects/l7-filter/files/l7-filter%20kernel%20version/2.18/netfilter-layer7-v2.18.tar.gz
wget http://sourceforge.net/projects/l7-filter/files/Protocol%20definitions/2009-05-28/l7-protocols-2009-05-28.tar.gz
```

给内核打上Layer7补丁并编译模块：

查看READ文件根据内核版本选择相应的补丁

```
tar zxvf linux-2.6.18.tar.gz
tar zxvf netfilter-layer7-v2.18.tar.gz
cd linux-2.6.18
patch -p1 < ../netfilter-layer7-v2.18/for_older_kernels/kernel-2.6.18-2.6.19-layer7-2.9.patch
```

安装ncurses库，编译内核需要

```
# yum install -y ncurses-devel
```

备份配置文件

```
# make oldconfig
```

进入内核编译选项

```
# make menuconfig
```

在以下菜单处理选择将layer7编译为模块：

```
Networking——Networking options--->Network packet filtering (replaces ipchains)--->Layer 7 match support (EXPERIMENTAL)
```

编译内核模块：

```
make prepare
#创建外部模块所需文件，后续可直接编译指定模块
make modules_prepare

#仅编译防火墙相关模块
make M=net/ipv4/netfilter/
```

复制编译的layer7.ko模块至系统：

```
strip --strip-debug net/ipv4/netfilter/ipt_layer7.ko
cp net/ipv4/netfilter/ipt_layer7.ko /lib/modules/2.6.18-274.el5/kernel/net/ipv4/netfilter/
chmod 744 /lib/modules/2.6.18-274.el5/kernel/net/ipv4/netfilter/ipt_layer7.ko
depmod -a
```

编译安装Iptables layer7模块：

```
tar jxvf iptables-1.3.5.tar.bz2
cd iptables-1.3.5

#给iptables打上layer7补丁，阅读README根据内核及Iptables版本选择相应的补丁
patch -p1 < ../netfilter-layer7-v2.18/iptables-1.3-for-kernel-pre2.6.20-layer7-2.18.patch

chmod +x extensions/.layer7-test
make KERNEL_DIR=/usr/src/kernels/linux-2.6.18
make install KERNEL_DIR=/usr/src/kernels/linux-2.6.18
```

安装Layer7示例脚本：

```
tar -zxvf l7-protocols-2009-05-28.tar.gz
cd l7-protocols-2009-05-28
make install
```

应用示例：

```
modprobe ipt_layer7
/usr/local/sbin/iptables -A FORWARD -m layer7 --l7proto qq -j DROP
```

Iptables实现公网IP DNAT/SNAT
============================

Iptables实现NAT是最基本的功能，大部分家用路由都是基于其SNAT方式上网，使用Iptables实现外网DNAT也很简单，不过经常会出现不能正常NAT的现象。

以下命令将客户端访问1.1.1.1的HTTP数据DNAT到2.2.2.2，很多人往往只做这一步，然后测试不能正常连接。

```
iptables -t nat -A PREROUTING -p tcp -d 1.1.1.1 --dport 80 -j DNAT --to 2.2.2.2:80
```

想像一下此时客户端访问1.1.1.1的数据流程：

```
客户端访问1.1.1.1
1.1.1.1根据Iptables DNA将数据包发往2.2.2.2，此时源IP为客户端IP
2.2.2.2处理后根据源IP直接向客户端返回数据，要知道此时客户端是直接和1.1.1.1连接的
然后呢，客户端不知所云，不能正常连接
```

最后还要添加一条SNAT规则，将发到2.2.2.2的数据包SNAT，1.1.1.1充当代理服务器的角色。

```
iptables -t nat -A POSTROUTING -d 2.2.2.2 -j SNAT --to-source 1.1.1.1
```

Iptables下TCP标志tcp-flags匹配模块使用
======================================

Iptables可通过匹配TCP的特定标志而设定更加严谨的防火墙规则，tcp-flags参数使用如下：

```
#匹配指定的TCP标记，有两个参数列表，列表内部用逗号为分隔符，两个列表之间用空格分开。
#第一个列表用作参数检查，第二个列表用作参数匹配。
-p tcp --tcp-flags

#可用以下标志：
#ALL是指选定所有的标记，NONE是指未选定任何标记。
SYN、ACK、FIN、RST 、URG、PSH、ALL、NONE

--syn
#SYN标志设置为1，其它标志未设置，相当于：
-p tcp --tcp-flags ALL SYN
```

很多人在使用tcp-flags匹配时遇到以下错误：

```
iptables v1.4.6: --tcp-flags requires two args.
```

原因是只定义了参数检查，未设置参数匹配，ROS下使用一组参数就可以了，正确使用tcp-flags应用示例：

防止Xmas扫描：

```
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
```

防止TCP Null扫描：

```
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
```

拒绝TCP标记为SYN/ACK但连接状态为NEW的数据包，防止ACK欺骗。

```
iptables -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
```

Iptables数据包、连接标记模块MARK/CONNMARK使用
=============================================

MARK标记用于将特定的数据包打上标签，供Iptables配合TC做QOS流量限制或应用策略路由。

看看和MARK相关的有哪些模块：

```
ls /usr/lib/iptables/|grep -i mark
libxt_CONNMARK.so
libxt_MARK.so
libxt_connmark.so
libxt_mark.so
```

其中大写的为标记模块，小写的为匹配模块，它们之间是相辅相成的，分别作用如下：

```
iptables -j MARK --help
--set-mark     #标记数据包

#所有TCP数据标记1
iptables -t mangle -A PREROUTING -p tcp -j MARK --set-mark 1

iptables -m mark --help
--mark value     #匹配数据包的MARK标记

#匹配标记1的数据并保存数据包中的MARK到连接中
iptables -t mangle -A PREROUTING -p tcp -m mark --mark 1 -j CONNMARK --save-mark

iptables -j CONNMARK --help
--set-mark      #标记连接
--save-mark     #保存数据包中的MARK到连接中
--restore-mark  #将连接中的MARK设置到同一连接的其它数据包中
iptables -t mangle -A PREROUTING -p tcp -j CONNMARK --set-mark 1

iptables -m connmark --help
--mark value     #匹配连接的MARK的标记

#匹配连接标记1并将连接中的标记设置到数据包中
iptables -t mangle -A PREROUTING -p tcp -m connmark --mark 1 -j CONNMARK --restore-mark
```
