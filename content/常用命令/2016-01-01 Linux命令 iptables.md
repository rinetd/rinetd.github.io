---
title: Linux命令 Iptables
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [iptables]
---
# 1. ipset
[使用 dnsmasq 和 ipset 的策略路由 | K.I.S.S](https://bigeagle.me/2016/02/ipset-policy-routing/)

apt-get install ipset
ipset create banthis hash:net maxelem 1000000
iptables -I INPUT -m set --match-set banthis src -p tcp --destination-port 80 -j DROP
iptables -I INPUT -m set --match-set banthis src -p tcp --destination-port 443 -j DROP

# 2. nftables


[*****Lesca技术宅](http://lesca.me/?s=iptables)
[*****Iptables入门教程](http://drops.wooyun.org/tips/1424)
[linux下IPTABLES配置详解](http://www.cnblogs.com/JemBai/archive/2009/03/19/1416364.html)
[iptables的基本语法格式](http://www.cnblogs.com/ggjucheng/archive/2012/08/19/2646476.html)
[超级详细的Iptables指南](http://man.chinaunix.net/network/iptables-tutorial-cn-1.1.19.html)
[iptables 详解及7层过滤](http://freeloda.blog.51cto.com/2033581/1241545)
[iptables防火墙原理详解](http://seanlook.com/2014/02/23/iptables-understand/)
[洞悉linux下的Netfilter&iptables：内核中的ip_tables小觑](http://blog.chinaunix.net/uid-23069658-id-3162264.html)
################################################################################
/etc/rc.d/init.d/iptables save
service iptables save   # 将配置保存
service iptables restart

systemctl restart iptables.service #最后重启防火墙使配置生效
systemctl enable iptables.service #设置防火墙开机启动

[国家代码编制好的 IP 地址列表IPdeny ](http://www.ipdeny.com/ipblocks/)
[APNIC是管理亚太地区IP地址分配的机构](http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest)
################################################################################
# DOCKER 给运行中的容器添加映射端口
`docker inspect -f '{{.NetworkSettings.IPAddress}}' mariadb`
1. DNAT主机30006 => 指定容器3306端口实现转发
  `iptables -t nat -A DOCKER ! -i docker0 -p tcp --dport 30006 -j DNAT --to-destination 192.168.0.2:3306`

2. filter 容器端口 3306
  `iptables -A DOCKER -d 192.168.0.2/32 ! -i docker0 -o docker0 -p tcp --dport 3306 -j ACCEPT`
  `iptables -t nat -A POSTROUTING -s 192.168.0.2/32 -d 192.168.0.2/32 -p tcp -m tcp --dport 3306 -j MASQUERADE`
3.
端口转发跳板

    单网卡通过 192.168.1.100:8081 访问 192.168.1.101:3306

    iptables -t nat -A PREROUTING -d 192.168.1.100 -p tcp --dport 8081 -j DNAT --to-destination 192.168.1.101:3306
    iptables -t nat -A PREROUTING -d 118.190.83.129 -p tcp --dport 22 -j DNAT --to-destination 10.30.216.58:22
    iptables -t nat -A POSTROUTING -d 10.30.216.58 -p tcp --dport 22 -j SNAT --to 10.30.183.164

# 本机端口转发 8000 3306
`iptables -t nat -A PREROUTING -p tcp --dport 8000 -j REDIRECT --to-ports 3306`
`iptables -t nat -D PREROUTING -p tcp --dport 8000 -j REDIRECT --to-ports 3306`
等价
`iptables -t nat -A PREROUTING -p tcp -i eth1 --dport 8000 -j DNAT --to-destination :3306`
```
iptables -t nat -A PREROUTING -p tcp -i eth1 --dport 8000 -j DNAT --to-destination 127.0.0.1:3306
# iptables -A INPUT -i eth1 -p tcp --dport 8000 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth1 -p tcp --sport 8000 -m state --state ESTABLISHED -j ACCEPT
```
################################################################################
##linux_base filter nat mangle raw
-S,--line-numbers
`sudo iptables -t nat -nL --line-numbers`
##删除INPUT链的第一条规则
`iptables -D INPUT 1`
##统计链中规则的包和流量计数,嘿嘿,看看哪些小子用的流量那么多,用tc限了他。
`iptables -t nat -L -vn`
##查看指定链规则
`sudo iptables -t nat --list-rules`

iptables [ -t 表名] 命令选项 [链名] [条件匹配] [-j 目标动作或跳转]
-t 表名：[Filter], NAT, Mangle, Raw 默认为Filter
-p 协议 all,tcp, udp, icmp, udplite, icmpv6,esp, ah, sctp, mh
-m 对规则进行匹配(match)说明,常常跟在被追加(-A)、插入(-I)、替换(-R)的链(chain)之后

# 删除 nat表 PREROUTING 链
`sudo iptables -t nat -nL --line-numbers`
`sudo iptables -t nat -D PREROUTING 2`

1.规则管理
iptables -A    添加一条新规则
iptables -I    插入一条新规则 -I 后面加一数字表示插入到哪行
iptables -D INPUT 1   删除一条新规则 -D 后面加一数字表示删除哪行
iptables -R INPUT 1   替换一条新规则 -R 后面加一数字表示替换哪行

2.链管理
iptables -F    清空链中的所有规则
iptables -N    新建一个链
iptables -X    删除一个自定义链,删除之前要保证次链是空的,而且没有被引用
iptables -E    重命名链

3.默认规则管理

iptables -P    设置默认规则

4.查看
iptables -L    查看规则 –L 还有几个子选项如下
iptables -L -n 以数字的方式显示
iptables -L -v 显示详细信息
iptables -L -x 显示精确信息
iptables -L --line-numbers 显示行号

## 5.条件匹配
! 用在接口名、协议名等前面,使规则的作用相反
### (1).基本匹配
条件匹配也可以使用 ! 取反
-s    源地址
-d    目标地址
-i    从哪个网络接口进入,比如 -i eth0
-o    从哪个网络接口出去,比如 -o eth0
-p    协议{tcp|udp|icmp}

### (2).扩展匹配 man iptables-extensions
隐含扩展匹配
-p tcp
  --sport PORT[first:last] 源端口
  --dport PORT[first:last] 目标端口
  --tcp-flags mask comp: [mask为1的位必须匹配]
    有6种标示：SYN(synchronous建立联机) ACK(acknowledgement 确认) PSH(push传送) FIN(finish结束) RST(reset重置) URG(urgent紧急)Sequence number(顺序号码) Acknowledge number(确认号码)
    tcp的标志位,只检查mask指定的标志位,是逗号分隔的标志位列表：SYN ACK FIN RST URG PSH ALL NONE
    comp：此表中出现的标志位必须为1,comp中没出现,而mask中出现的,必须为0
    --tcp-flags SYN,FIN,ACK,RST    SYN      第一次握手 SYN=1,FIN=0,RST=0,ACK=0 等价于 --syn
    --tcp-flags SYN,FIN,ACK,RST    SYN,ACK  第二次握手 SYN=1,FIN=0,RST=0,ACK=1
    --tcp-flags SYN,FIN,ACK,RST    ACK      第三次握手 SYN=0,FIN=0,RST=0,ACK=1
-p udp
    --sport
    --dport
-p icmp:
    --icmp-type：报文协议的类型
    0:echo-replay回显应答（ping应答）
    8:echo-request回显请求（ping请求）ping出去的是8

    自己ping别人：出去的是8,回来的是0  8-> <-0
    别人ping自己：进来的是8,出去的是0  8<- ->0

显示扩展匹配

-m 对规则进行匹配(match)说明,常常跟在被追加(-A)、插入(-I)、替换(-R)的链(chain)之后

-m multiport 离散多端口匹配扩展(最多使用15个）
     [!] --ports port[,port|,port:port]...
     [!] --source-ports,--sports port[,port|,port:port]...
     [!] --destination-ports,--dports port[,port|,port:port]...
     -m multiport --sports 53,1024:65535 would therefore match ports 53 and all from 1024 through 65535.

-m iprange指定IP地址段（指定地址池），也可以取反“！”
     --src-range
     --dst-range

-m connlimit:连接数限定
    ！--connmilit-above n: 将单IP的并发设置为6；会误杀使用NAT上网的用户，可以根据实际情况增大该值；

-m limit
    --limit 3/minute   每三分种一次 RATE控制单位时间内的流量上限  --limit rate[/second|/minute|/hour|/day]
    --limit-burst  5   只匹配5个数据包 一批可以同时涌进多少个请求  --limit-burst number
    limit-burst是个初始值..匹配次数过了这个初始值，之后的就由limit xxx/s来控制了
-m lenth 匹配数据包的长度
    `-m length --length 1139 `
    `ping -c 1 -s 1111 192.168.33.78` 向目标发送一个长度为 1111 的 ICMP 数据包（加上包头28，总长度实际为1139）
-m string 限定用户访问的字符串
    --algo:字符算法{bm|kmp} bm 后查法 优于 kmp算法
    --string：匹配哪个字符串
    `-m string --algo bm --string "passwd"`  匹配字符串

-m recent
```
    # 端口复用链
    iptables -t nat -N SSH
    # 端口复用规则
    iptables -t nat  -A SSH -p tcp -j REDIRECT --to-port 22

    # 开启开关
    iptables -A INPUT -p tcp -m string --string 'coming' --algo bm -m recent --set --name letmein --rsource -j ACCEPT
    # 关闭开关
    iptables -A INPUT -p tcp -m string --string 'leaving' --algo bm -m recent --name letmein --remove -j ACCEPT

    # let's do it
    iptables -t nat -A PREROUTING -p tcp --dport 80 --syn -m recent --rcheck --seconds 3600 --name letmein --rsource -j LETMEIN

    开启复用，开启后本机到目标 80 端口的流量将转发至目标的 SSH，80 将无法再被本机访问：
    echo threathuntercoming | socat - tcp:192.168.33.78:80
```

-m mac --mac-source xx:xx:xx:xx:xx:xx 匹配源MAC地址为

-m time --timestart 8:00 --timestop 12:00  表示从哪个时间到哪个时间段
-m time --days    表示那天
-m layer7 --l7proto qq   表示匹配腾讯qq的 当然也支持很多协议,这个默认是没有的,需要我们给内核打补丁并重新编译内核及iptables才可以使用
-m conntrack：对下列连接通信与当前的包/连接进行匹配。 conntrack模块可以根据先前的连接来确定数据包之间的关系
  -ctstate ESTABLISHED, RELATED：规则将应用到的连接状态。
  在本例中，ESTABLISHED 连接代表能够看到两个方向数据包的连接，
  而 RELATED 类型代表，数据包开启一个新连接，但是与现有连接相关联。
`iptables -m conntrack --help` conntrack模块会在以后的版本中取代state,state是简化版
-m state --state   匹配状态的，结合ip_conntrack追踪会话的状态，ip状态有四种
        NEW：          新连接请求
        ESTABLISHED：  已建立的连接
        RELATED：      相关联的
        INVALID：      非法连接
    -m state --state NEW -j ACCEPT 状态为NEW的放行
    -m state --state NEW,ESTABLISHED -j ACCEPT 状态为NEW、ESTABLISHED的都放行

## IPTABLES的几个状态
这个模块在iptables下的使用叫做state,而在Netfilter机制中是以xt_state.ko文件存在。在TCP/IP规范中连接状态共划分为十二种,但在state模块的描述下却只有四种,分别是ESTABLISHED、NEW、RELATED及INVALID,这两个分类是两个不相干的定义。例如在TCP/IP标准描述下UDP及ICMP数据包是没有连接状态的,但在state模块的描述下,任何数据包都有连接状态。

1. NEW          [新连接请求]
当你在使用UDP、TCP、ICMP等协议时,发出的第一个包的状态就是“NEW”,NEW与协议无关
首先我们知道,NEW与协议无关,其所指的是每一条连接中的第一个数据包,

2. ESTABLISHED  [已建立的连接]
(1)与TCP数据包的关系：首先在防火墙主机上执行SSH Client,并且对网络上的SSH服务器提出服务请求,而这时送出的第一个数据包就是服务请求的数据包,如果这个数据包能够成功的穿越防火墙,那么接下来SSH Server与SSH Client之间的所有SSH数据包的状态都会是ESTABLISHED。

(2)与UDP数据包的关系：假设我们在防火墙主机上用firefox应用程序来浏览网页（通过域名方式）,而浏览网页的动作需要DNS服务器的帮助才能完成,因此firefox会送出一个UDP数据包给DNS Server,以请求名称解析服务,如果这个数据包能够成功的穿越防火墙,那么接下来DNS Server与firefox之间的所有数据包的状态都会是ESTABLISHED。
(3)与ICMP数据包的关系：假设我们在防火墙主机ping指令来检测网络上的其他主机时,ping指令所送出的第一个ICMP数据包如果能够成功的穿越防火墙,那么接下来刚才ping的那个主机与防火墙主机之间的所有ICMP数据包的状态都会是ESTABLISHED。
由以上的解释可知,只要数据包能够成功的穿越防火墙,那么之后的所有数据包（包含反向的所有数据包）状态都会是ESTABLISHED。

3. RELATED     [相关联的]
RELATED状态的数据包是指被动产生的数据包。而且这个连接是不属于现在任何连接的。RELATED状态的数据包与协议无关,只要回应回来的数据包是因为本机送出一个数据包导致另一个连接的产生,而这一条新连接上的所有数据包都是属于RELATED状态的数据包。

4. INVALID    [非法连接]
INVALID状态是指状态不明的数据包,也就是不属于以上三种状态的封包。这类包一般会被视为恶意包而被丢弃。凡是属于INVALID状态的数据包都视为恶意的数据包,因此所有INVALID状态的数据包都应丢弃掉,匹配INVALID状态的数据包的方法如下：
iptables -A INPUT -p all -m state INVALID -j DROP
我们应将INVALID状态的数据包放在第一条。

## 6.处理动作

-j ACCEPT     允许
-j REJECT     拒绝
-j DROP       拒绝并提示信息
-j SNAT       源地址转换
-j DNAT       目标地址转换
-j REDIRECT   重定向
-j MASQUERAED  地址伪装
-j LOG --log-prefix "说明信息,自己随便定义"      记录日志

常用的处理动作：
-j 参数用来指定要进行的处理动作,常用的处理动作包括：ACCEPT、REJECT、DROP、REDIRECT、MASQUERADE、LOG、DNAT、SNAT、MIRROR、QUEUE、RETURN、MARK。
1. ACCEPT 将数据包放行,进行完此处理动作后,将不再比对其它规则,直接跳往下一个规则链（natostrouting）。
2. REJECT 拦阻该数据包,并传送数据包通知对方,可以传送的数据包有几个选择：ICMP port-unreachable、ICMP echo-reply 或是tcp-reset（这个数据包会要求对方关闭联机）,进行完此处理动作后,将不再比对其它规则,直接 中断过滤程序。 范例如下：
`iptables -A FORWARD -p TCP --dport 22 -j REJECT --reject-with tcp-reset`
3. DROP 丢弃包不予处理,进行完此处理动作后,将不再比对其它规则,直接中断过滤程序。
4. LOG 将封包相关讯息纪录在 /var/log 中,详细位置请查阅 /etc/syslog.conf 配置文件,进行完此处理动作后,将会继续比对其规则。例如：
`iptables -A INPUT -p tcp -j LOG --log-prefix "INPUT packets"`

5. SNAT 改写封包来源 IP 为某特定 IP 或 IP 范围,可以指定 port 对应的范围,进行完此处理动作后,将直接跳往下一个规则（mangleostrouting）。范例如下：
    --to-source [ipaddr[-ipaddr]][:port[-port]]
    --random
    --random-fully
    --persistent
`iptables -t nat -A POSTROUTING -p tcp-o eth0 -j SNAT --to-source 194.236.50.155-194.236.50.160:1024-32000`

6. MASQUERADE 改写数据包来源 IP为防火墙 NIC IP,可以指定 port 对应的范围,进行完此处理动作后,直接跳往下一个规则（mangleostrouting）。这个功能与 SNAT 略有不同,当进行 IP 伪装时,不需指定要伪装成哪个 IP,IP 会从网卡直接读取,当使用拨号连接时,IP 通常是由 ISP 公司的 DHCP 服务器指派的,这个时候 MASQUERADE 特别有用。算是snat中的一种特例，可以实现自动化的snat
    --to-ports port[-port]
    --random
`iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE --to-ports 1024-31000`
`iptables -t nat -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE`
修改源ip地址的目的一般都是为了让这个包能再回到自己这里，所以在iptables中，SNAT是在出口，也即POSTROUTING链发挥作用。

修改目的ip地址的原因一般就是为了改变包发送的目的地，让包走出去，所以在iptables中，DNAT是在入口，也即PREROUTING链中发挥作用，以便让包进入FORWARD表。
7. DNAT 改写封包目的地 IP 为某特定 IP 或 IP 范围,可以指定 port 对应的范围,进行完此处理动作后,将会直接跳往下一个规炼（filter:input 或 filter:forward）。范例如下：
    --to-destination [ipaddr[-ipaddr]][:port[-port]]
    --persistent
    --random
`iptables -t nat -A PREROUTING -p tcp -d 15.45.23.67 --dport 80 -j DNAT --to-destination 192.168.1.1-192.168.1.10:80-100`
每个流都会被随机分配一个要转发到的地址，但同一个流总是使用同一个地址

8. REDIRECT 将包重新导向到另一个端口（PNAT）,进行完此处理动作后,将会继续比对其它规则。 这个功能可以用来实作通透式porxy 或用来保护 web 服务器。例如：DNAT的一种特殊形式,将网络包转发到本地host上（不管IP头部指定的目标地址是啥）[端口转发]
    --to-ports port[-port]
    --random
`iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080`

9. MIRROR 镜像数据包,也就是将来源 IP 与目的地 IP 对调后,将数据包送回,进行完此处理动作后,将会中断过滤程序。

10. QUEUE 中断过滤程序,将数据包放入队列,交给其它程序处理。透过自行开发的处理程序,可以进行其它应用,例如：计算联机费.......等。
    --queue-num value
    --queue-balance value:value
    --queue-bypass
    --queue-cpu-fanout
11. RETURN 结束在目前规则链中的过滤程序,返回主规则链继续过滤,如果把自订规则链看成是一个子程序,那么这个动作,就相当提早结束子程序并返回到主程序中。
MARK 将数据包标上某个代号,以便提供作为后续过滤的条件判断依据,进行完此处理动作后,将会继续比对其它规则。范例如下：
`iptables -t mangle -A PREROUTING -p tcp --dport 22 -j MARK --set-mark 2`

1.1 filter、nat、mangle等规则表

filter表

主要用于对数据包进行过滤，根据具体的规则决定是否放行该数据包（如DROP、ACCEPT、REJECT、LOG）。filter 表对应的内核模块为iptable_filter，包含三个规则链：

    INPUT链：INPUT针对那些目的地是本地的包
    FORWARD链：FORWARD过滤所有不是本地产生的并且目的地不是本地(即本机只是负责转发)的包
    OUTPUT链：OUTPUT是用来过滤所有本地生成的包

nat表

主要用于修改数据包的IP地址、端口号等信息（网络地址转换，如SNAT、DNAT、MASQUERADE、REDIRECT）。属于一个流的包(因为包
的大小限制导致数据可能会被分成多个数据包)只会经过这个表一次。如果第一个包被允许做NAT或Masqueraded，那么余下的包都会自动地被做相同的操作，也就是说，余下的包不会再通过这个表。表对应的内核模块为 iptable_nat，包含三个链：

    PREROUTING链：作用是在包刚刚到达防火墙时改变它的目的地址
    OUTPUT链：改变本地产生的包的目的地址
    POSTROUTING链：在包就要离开防火墙之前改变其源地址

mangle表

主要用于修改数据包的TOS（Type Of Service，服务类型）、TTL（Time To Live，生存周期）指以及为数据包设置Mark标记，以实现Qos(Quality Of Service，服务质量)调整以及策略路由等应用，由于需要相应的路由设备支持，因此应用并不广泛。包含五个规则链——PREROUTING，POSTROUTING，INPUT，OUTPUT，FORWARD。

raw表

是自1.2.9以后版本的iptables新增的表，主要用于决定数据包是否被状态跟踪机制处理。在匹配数据包时，raw表的规则要优先于其他表。包含两条规则链——OUTPUT、PREROUTING

iptables中数据包和4种被跟踪连接的4种不同状态：

    NEW：该包想要开始一个连接（重新连接或将连接重定向）
    RELATED：该包是属于某个已经建立的连接所建立的新连接。例如：FTP的数据传输连接就是控制连接所 RELATED出来的连接。--icmp-type 0 ( ping 应答) 就是--icmp-type 8 (ping 请求)所RELATED出来的。
    ESTABLISHED ：只要发送并接到应答，一个数据连接从NEW变为ESTABLISHED,而且该状态会继续匹配这个连接的后续数据包。
    INVALID：数据包不能被识别属于哪个连接或没有任何状态比如内存溢出，收到不知属于哪个连接的ICMP错误信息，一般应该DROP这个状态的任何数据。

1.2 INPUT、FORWARD等规则链和规则

在处理各种数据包时，根据防火墙规则的不同介入时机，iptables供涉及5种默认规则链，从应用时间点的角度理解这些链：

    INPUT链：当接收到防火墙本机地址的数据包（入站）时，应用此链中的规则。
    OUTPUT链：当防火墙本机向外发送数据包（出站）时，应用此链中的规则。
    FORWARD链：当接收到需要通过防火墙发送给其他地址的数据包（转发）时，应用此链中的规则。
    PREROUTING链：在对数据包作路由选择之前，应用此链中的规则，如DNAT。
    POSTROUTING链：在对数据包作路由选择之后，应用此链中的规则，如SNAT。

-->PREROUTING-->[ROUTE]-->FORWARD-->POSTROUTING-->
     mangle        |       mangle        ^ mangle
      nat          |       filter        |  nat
                   |                     |
                   |                     |
                   v                     |
                 INPUT                 OUTPUT
                   | mangle              ^ mangle
                   | filter              |  nat
                   v ------>local------->| filter

其中中INPUT、OUTPUT链更多的应用在“主机防火墙”中，即主要针对服务器本机进出数据的安全控制；而FORWARD、PREROUTING、POSTROUTING链更多的应用在“网络防火墙”中，特别是防火墙服务器作为网关使用时的情况。

################################################################################
![数据包过滤匹配流程](http://img1.51cto.com/attachment/201307/173142806.png)
四表:优先级高->低 表遍历先后顺序为:[raw-->mangle-->nat-->filter]
五链：
# -t nat -I PREROUTING
  raw     ->PREROUTING
  mangle  ->PREROUTING
-  nat     ->PREROUTING [常用]
此处有入口路由选择[Route Table]
# -I INPUT
  mangle  ->INPUT
-  filter  ->INPUT
# -I FORWARD
  mangle  ->FORWARD
-  filter  ->FORWARD
此处有出口路由选择[Route Table]
# -I OUTPUT     
  raw     ->OUTPUT
  mangle  ->OUTPUT
  nat     ->OUTPUT
-  filter  ->OUTPUT
# -t nat -I POSTROUTING
  mangle ->POSTROUTING
-  nat    ->POSTROUTING

INPUT链 – 处理来自外部的数据。
OUTPUT链 – 处理向外发送的数据。
FORWARD链 – 将数据转发到本机的其他网卡设备上。

#数据包过滤匹配流程
Chains 发生的时机:
PREROUTING  数据包进入本机后,进入Route Table前
INPUT       数据包通过Route Table后,目地为本机
OUTPUT      由本机发出,进入Route Table前
FORWARD     通过Route Table后,目地不是本机时
POSTROUTING 通过Route Table后,送到网卡前

![数据报流](http://i.stack.imgur.com/YkwUi.png)
![数据报流](http://hi.csdn.net/attachment/201112/13/0_1323742526q6XX.gif)
################################################################################
#清空 filter table
[root@localhost]# iptables -F
[root@localhost]# iptables -X
[root@localhost]# iptables -Z

#配置(filter)表默认链策略
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#允许回环接口(lo),默认accept
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p ALL -i lo -j ACCEPT
#允许所有已经建立的和相关的连接
iptables-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#drop非法连接
iptables -A INPUT     -m state --state INVALID -j DROP
iptables -A OUTPUT    -m state --state INVALID -j DROP
iptables-A FORWARD -m state --state INVALID -j DROP

#允许ICMP接受ping
/sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
################################ RAW ##########################################
## iptables raw表
  RAW表作用:Raw表的引入可以分离出不需要被conntrack的流量
4个表的优先级由高到低的顺序为:raw-->mangle-->nat-->filter
举例来说:如果PRROUTING链上,即有mangle表,也有nat表,那么先由mangle处理,然后由nat表处理

RAW表只使用在PREROUTING链和OUTPUT链上,因为优先级最高,从而可以对收到的数据包在连接跟踪前进行处理。一但用户使用了RAW表,在某个链上,RAW表处理完后,将跳过NAT表和 ip_conntrack处理,即不再做地址转换和数据包的链接跟踪处理了.

RAW表可以应用在那些不需要做nat的情况下,以提高性能。如大量访问的web服务器,可以让80端口不再让iptables做数据包的链接跟踪处理,以提高用户的访问速度。

################################ NAT ##########################################
# iptables的NAT表
    SNAT - Source NAT,扮演网关角色的机器和其他机器共享一个网络连接时使用,
    MASQUERADE - SNAT的一种特殊形式,适用于像adsl这种临时会变的ip上
    DNAT - Destination NAT,将网络内部服务细节掩藏起来
    REDIRECT - DNAT的一种特殊形式,将网络包转发到本地host上（不管IP头部指定的目标地址是啥）

##  sysctl开启ip_forward

### 查看开启状态
`sysctl net.ipv4.ip_forward`
cat /proc/sys/net/ipv4/ip_forward
### 永久生效
  vi /etc/sysctl.conf
    `net.ipv4.ip_forward = 1`
  sysctl -p /etc/sysctl.conf
#### 临时生效
  sysctl net.ipv4.ip_forward=1
  sysctl -w net.ipv4.ip_forward=1
  echo 1 > /proc/sys/net/ipv4/ip_forward


+ SNAT最主要是用在本地机器作为网关时,和其他机器共享网络连接是使用。比如,我们常见的pptp或者openvpn服务器:
SNAT的目的是IP包经过route之后、出本地的网络栈之前,将源地址改成本机的（否则192.168.0.2机器响应请求的返回地址就不对）, 所以在POSTROUTING链。
假设vpn网段是192.168.0.1/24
本地机器外网ip是a.d.c.d
vpn网口为tun0. 那么需要:
```bash
# 将来自于192.168.0.1/24 网段的流量通过外网a.b.c.d出口出去
iptables -t nat -A POSTROUTING -s 192.168.0.1/24 SNAT --to-destination a.b.c.d
如果是动态ip,则第一句话需要改成：
`iptables -t nat -A POSTROUTING -s 192.168.0.1/24 MASQUERADE`

# FORWARD链相应设置打开
iptables -A FORWARD -i eth0 -o tun0 -m state -state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
```


+ DNAT主要用在网络内部的机器提供服务,但是又不想暴露在网络上,那么需要在一台足够安全、可以暴露在互联网上的机器来提供NAT服务。
比如本地机器有公网ip：1.1.1.1, 内网ip：192.168.0.1
内网另一台机器192.168.0.2:8080 提供了web服务。
我们可以做DNAT使得看起来访问1.1.1.1:80的时候,就跟访问192.168.0.1:8080一样：

```bash
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.2:8080
# 关键一步,需要加上SNAT
iptables -t nat -A POSTROUTING -d 192.168.0.2 --dport 8080 -j SNAT --to-source 1.1.1.1
```
这里面其实就是做了端口转发, 将本机1.1.1.1:80端口转发到192.168.0.2:8080端口
DNAT是在进入路由层面的route之前,将IP包中的目的地址改掉,所以是PREROUTING链起作用


+ MASQUERADE  适用场景 网关IP动态变化。
假如当前系统用的是ADSL/3G/4G动态拨号方式,那么每次拨号,出口IP都会改变,SNAT就会有局限性。
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
重点在那个『 MASQUERADE 』！这个设定值就是『IP伪装成为封包出去(-o)的那块装置上的IP』！不管现在eth0的出口获得了怎样的动态ip,MASQUERADE会自动读取eth0现在的ip地址然后做SNAT出去,这样就实现了很好的动态SNAT地址转换。

+ REDIRECT是DNAT的一个特例。方便在本机做端口转发。
  比如你有一个Squid这样的HTTP代理,监听网关的8888端口。那么你可以如下设置将它做成一个透明代理：
iptables -t nat -A PREROUTING -i eth0(假设从eth0进流量)  -p tcp --dport 80 -j REDIRECT  --to-port 8888
这么做相当于将80端口的流量劫持到8888,并且不会被用户察觉


## Linux 网关
## 共享上网(nat)

目标：使局域网的用户都可以通过Iptables网关访问外网的服务器

  [root@localhost]# echo 1 > /proc/sys/net/ipv4/ip_forward
  [root@localhost]# iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

说明: SNAT 和 MASQUERADE 区别
SNAT : 不管是几个地址,必须明确的指定要SNAT的ip,适合网关服务器有固定地址或者是固定地址范围.
MASQUERADE : PNAT是针对ADSL动态拨号这种场景而设计,从服务器的网络接口上,自动获取当前ip地址来做NAT,这样就实现了动态SNAT地址转换

3.3. 内网的服务器对外服务(端口映射)

目标：使外网用户可以访问到局域网192.168.138.21这台HTTP服务

  [root@localhost]# echo 1 > /proc/sys/net/ipv4/ip_forward
  [root@localhost]# iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j DNAT --to-destination 192.168.138.21
  [root@localhost]# iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

3.4. 在网关服务器进行透明代理

目标: 使局域网用户,访问外网web服务时,自动使用squid作web透明代理服务器。
  [root@localhost]# echo 1 > /proc/sys/net/ipv4/ip_forward
  [root@localhost]# iptables -t nat -A PREROUTING -s 192.168.138.0/24 -p tcp --dport 80 -i eth0 -j DNAT --to 192.168.138.1
  [root@localhost]# iptables -t nat -A PREROUTING -s 192.168.138.0/24 -p tcp --dport 80 -i eth0 -j REDIRECT --to 3128
  [root@localhost]# iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

# 在服务端拦截响应：
iptables -A OUTPUT -d 10.16.15.109 -j DROP
# 禁止与211.101.46.253的所有连接
iptables -t nat -A PREROUTING -d 211.101.46.253 -j DROP

eth2 外网网卡
wlan2 是内网网卡 我们要使用 iptables 从 eth2 转发数据包的接口
# FORWARD wlan2 --> eth2
iptables -A FORWARD -i wlan2 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o wlan2 -m state --state ESTABLISHED,RELATED  -j ACCEPT

# NAT 修改发送到互联网的数据包的源地址为 eth2
iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE

#
代理服务器WAN IP：111.**.**.219,LAN IP：192.168.0.219
内网服务器IP：192.168.0.41
iptables -t nat -A PREROUTING -d 111.**.**.219 -p tcp --dport 9999 -j DNAT --to-destination 192.168.0.41:9999

iptables -t nat -A POSTROUTING -d 192.168.0.41 -p tcp --dport 9999 -j SNAT --to-source 192.168.0.219


## VPN PPTP IPSEC NAT 策略

iptables -t nat -A PREROUTING -p tcp --dport 80 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:80
iptables -t nat -A PREROUTING -p tcp --dport 1723 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:1723
iptables -t nat -A PREROUTING -p udp --dport 1723 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:1723
iptables -t nat -A PREROUTING -p udp --dport 500 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:500
iptables -t nat -A PREROUTING -p udp --dport 4500 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:4500


FTP服务器的NAT
iptables -I PFWanPriv -p tcp --dport 21 -d 192.168.100.200 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 21 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.200:21
############################### 服务 ###########################################
---
SSH=22
FTP=20,21
DNS=53
SMTP=25,465,587
POP3=110,995
IMAP=143,993
HTTP=80,443
IDENT=113
NTP=123
MYSQL=3306
NET_BIOS=135,137,138,139,445
DHCP=67,68
---
## ssh 端口

#只对内网用户开放sshd服务
[root@localhost]# iptables -A INPUT -p tcp -s 192.168.138.0/24 --dport 22 -j ACCEPT

# 3.允许远程主机进行SSH连接
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# 4.允许本地主机进行SSH连接
iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# 5.允许HTTP请求
iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

# # Load FTP Kernel modules
# /sbin/modprobe ip_conntrack_ftp
# /sbin/modprobe ip_nat_ftp
# # FTP Service
# /sbin/iptables -A INPUT -p tcp --dport 21 -j ACCEPT

###recent模块阻止SSH字典攻击
```
# Prevent SSH Attack
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --name SSH -j DROP
# Enable Normal SSH Connection
iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT
```
允许所有SSH连接请求

本规则允许所有来自外部的SSH连接请求,也就是说,只允许进入eth0接口,并且目的端口为22的数据包

iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

允许从本地发起的SSH连接

本规则和上述规则有所不同,本规则意在允许本机发起SSH连接,上面的规则与此正好相反。

iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

仅允许来自指定网络的SSH连接请求

以下规则仅允许来自192.168.100.0/24的网络：

iptables -A INPUT -i eth0 -p tcp -s 192.168.100.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

上例中,你也可以使用-s 192.168.100.0/255.255.255.0作为网络地址。当然使用上面的CIDR地址更容易让人明白。
仅允许从本地发起到指定网络的SSH连接请求

以下规则仅允许从本地主机连接到192.168.100.0/24的网络：

iptables -A OUTPUT -o eth0 -p tcp -d 192.168.100.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT


7、使用iptables允许特定的主机连接
 `iptables -A INPUT -p tcp -m state --state NEW --source 123.132.252.42,123.132.226.66 --dport 22 -j ACCEPT`
 `iptables -A INPUT -p tcp --dport 22 -j DROP`
 并确保没有其他的主机可以访问SSH服务：

8、SSH时间锁定技巧
你可以使用不同的iptables参数来限制到SSH服务的连接,让其在一个特定的时间范围内可以连接,其他时间不能连接。你可以在下面的任何例子中使用/second、/minute、/hour或/day开关。
第一个例子,如果一个用户输入了错误的密码,锁定一分钟内不允许在访问SSH服务,这样每个用户在一分钟内只能尝试一次登陆：
 `iptables -A INPUT -p tcp -m state --syn --state NEW --dport 22 -m limit --limit 1/minute --limit-burst 1 -j ACCEPT`
 `iptables -A INPUT -p tcp -m state --syn --state NEW --dport 22 -j DROP`
第二个例子,设置iptables只允许主机193.180.177.13连接到SSH服务,在尝试三次失败登陆后,iptables允许该主机每分钟尝试一次登陆：
 `iptables -A INPUT -p tcp -s 193.180.177.13 -m state --syn --state NEW --dport 22 -m limit --limit 1/minute --limit-burst 1 -j ACCEPT`
`iptables -A INPUT -p tcp -s 193.180.177.13 -m state --syn --state NEW --dport 22 -j DROP`

## iptables使用multiport 添加多个不连续端口
iptables -A INPUT -p tcp -m multiport --dports 21:25,135:139 -j DROP
iptables -A INPUT -p tcp -m multiport --dports 110,80,25,445,1863,5222 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m multiport --sports 22,80,443 -m state --state ESTABLISHED -j ACCEPT

如果不使用multiport参数,只能是添加连续的端口。
如:
iptables -A INPUT -p tcp –dport 21:25 -j DROP

而不能写成21:25,135:139

#squid代理的配置

  # 允许接收相关应答
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

  # 仅允许以下入站协议
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  iptables -A INPUT -p tcp --dport 3128 -j ACCEPT
  iptables -A INPUT -p tcp --dport 3129 -j ACCEPT
  iptables -A INPUT -p udp --dport 53 -j ACCEPT

  # 将HTTP服务重定向到3129端口,交给squid,这是透明代理的关键
  iptables -t nat -A PREROUTING -p tcp -s 192.168.10.0/24 --dport 80 -j REDIRECT --to-ports 3129

  # 仅允许以下协议转发给默认路由（即外网路由器）
  iptables -A FORWARD -p tcp --dport 443 -j ACCEPT

  # 默认策略
  iptables -P INPUT DROP
  iptables -P FORWARD DROP


#######################################################

```sh
#!/bin/bash
##	    https://github.com/BenjyOC/firewall.git
## http://www.thegeekstuff.com/2011/06/iptables-rules-examples/
# 清空iptables规则
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -t nat -F
iptables -t nat -X
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P INPUT ACCEPT
iptables -t mangle -P FORWARD ACCEPT
iptables -t mangle -P OUTPUT ACCEPT
iptables -t mangle -P POSTROUTING ACCEPT

iptables -t raw -F
iptables -t raw -X
iptables -t raw -P PREROUTING ACCEPT
iptables -t raw -P OUTPUT ACCEPT

# NAT


iptables -t nat -A PREROUTING -p udp -d 94.23.213.216 --dport 443 -j DNAT --to-destination 172.16.10.10
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 51413 -j DNAT --to-destination 172.16.10.10
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 9190 -j DNAT --to-destination 172.16.10.10
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 2224 -j DNAT --to-destination 172.16.10.10:22
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 80 -j DNAT --to-destination 172.16.10.20
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 443 -j DNAT --to-destination 172.16.10.20
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 53 -j DNAT --to-destination 172.16.10.2
iptables -t nat -A PREROUTING -p udp -d 94.23.213.216 --dport 53 -j DNAT --to-destination 172.16.10.2
iptables -t nat -A PREROUTING -p tcp -d 94.23.213.216 --dport 8080 -j DNAT --to-destination 172.16.10.201:80

iptables -t nat -A POSTROUTING -s 192.168.1.1/24 -j SNAT --to 94.23.213.216
iptables -t nat -A POSTROUTING -s 172.16.10.1/24 -j SNAT --to 94.23.213.216
iptables -t nat -A POSTROUTING -s 192.168.10.1/24 -j SNAT --to 94.23.213.216
iptables -t nat -A POSTROUTING -s 192.168.20.1/24 -j SNAT --to 94.23.213.216

GEN="DROP"

# Default DROP
iptables -P INPUT $GEN
iptables -P FORWARD $GEN
iptables -P OUTPUT $GEN

# Keep establish connections
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Autoriser loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ICMP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# SSH
iptables -A INPUT  -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Mail SMTP:25
iptables -A INPUT  -p tcp --dport 25 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
# DNS :53
iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT

# Rsync :873
iptables -A INPUT -i eth0 -p tcp -s 192.168.101.0/24 --dport 873 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 873 -m state --state ESTABLISHED -j ACCEPT

# MySQL :3306
iptables -A INPUT -i eth0 -p tcp -s 192.168.100.0/24 --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT

#  Sendmail or Postfix Traffic
iptables -A INPUT -i eth0 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT

#Allow IMAP and IMAPS
# IMAP/IMAP2 traffic.
iptables -A INPUT  -p tcp --dport 143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -m state --state ESTABLISHED -j ACCEPT

# IMAPS traffic.
iptables -A INPUT  -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT

# POP3 :110
iptables -A INPUT  -p tcp --dport 110 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 110 -m state --state ESTABLISHED -j ACCEPT

# POP3S:995
iptables -A INPUT  -p tcp --dport 995 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 995 -m state --state ESTABLISHED -j ACCEPT

# GUI Proxmox
iptables -A INPUT -s 127.0.0.1 -p tcp --dport 8006 -j ACCEPT

iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 4949 -j ACCEPT

# Forward pour les VMs
iptables -A FORWARD -d 172.16.10.0/24 -p all -j ACCEPT
iptables -A FORWARD -s 172.16.10.0/24 -p all -j ACCEPT

iptables -A FORWARD -d 192.168.10.0/24 -p all -j ACCEPT
iptables -A FORWARD -s 192.168.10.0/24 -p all -j ACCEPT

# Monitoring OVH
iptables -A OUTPUT -p udp --dport 6100:6200 -j ACCEPT

#DDOS
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

exit 0

```
## 实战 Linux网关
生产环境中，Public IP 经常比较有限，Linux GateWay可以充分利用有限IP为更多的机器提供网络服务，也可以有意识地将某些服务器隐藏在后面，即可以主动获取网络资源，又避免被动访问，更加安全

开启内核转发
-

调整内核参数 **net.ipv4.ip_forward** 开启转发

~~~
[root@linux-gateway ~]# grep  forward  /etc/sysctl.conf
# Controls IP packet forwarding
net.ipv4.ip_forward = 1
[root@linux-gateway ~]#
~~~

**sysctl -p** 使其生效，然后使用 **sysctl -a** 来进行确认

~~~
[root@linux-gateway ~]# sysctl  -a | grep  forwarding
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.all.mc_forwarding = 0
net.ipv4.conf.default.forwarding = 1
net.ipv4.conf.default.mc_forwarding = 0
net.ipv4.conf.lo.forwarding = 1
net.ipv4.conf.lo.mc_forwarding = 0
net.ipv4.conf.em4.forwarding = 1
net.ipv4.conf.em4.mc_forwarding = 0
net.ipv4.conf.em2.forwarding = 1
net.ipv4.conf.em2.mc_forwarding = 0
net.ipv4.conf.em3.forwarding = 1
net.ipv4.conf.em3.mc_forwarding = 0
net.ipv4.conf.em1.forwarding = 1
net.ipv4.conf.em1.mc_forwarding = 0
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.all.mc_forwarding = 0
net.ipv6.conf.default.forwarding = 0
net.ipv6.conf.default.mc_forwarding = 0
net.ipv6.conf.lo.forwarding = 0
net.ipv6.conf.lo.mc_forwarding = 0
net.ipv6.conf.em1.forwarding = 0
net.ipv6.conf.em1.mc_forwarding = 0
net.ipv6.conf.em2.forwarding = 0
net.ipv6.conf.em2.mc_forwarding = 0
net.ipv6.conf.em3.forwarding = 0
net.ipv6.conf.em3.mc_forwarding = 0
net.ipv6.conf.em4.forwarding = 0
net.ipv6.conf.em4.mc_forwarding = 0
[root@linux-gateway ~]#
~~~


---

开启iptables转发
-

查看内网网卡

~~~
[root@linux-gateway ~]# ip a | grep 168
    inet 192.168.1.254/24 brd 192.168.1.255 scope global em1
[root@linux-gateway ~]#
~~~

内网网卡为 **em1**

查看默认路由，与出口网卡

~~~
[root@linux-gateway ~]# ip route | grep default
default via 180.140.110.123 dev em2
[root@linux-gateway ~]#
~~~

出口网卡为 **em2**

方法一：直接在命令行配置

* **filter** 表上接受来自 **em1** 的 **FORWARD** 请求
* **nat** 表的 **POSTROUTING** 链上打开来自内网出口为 **em2** 的地址伪装，即 **SNAT**

~~~
[root@linux-gateway ~]# iptables -A FORWARD -i em1 -j ACCEPT
[root@linux-gateway ~]# iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o em2 -j MASQUERADE
~~~

方法二：通过配置文件修改

可以在 **/etc/sysconfig/iptables** 中的 **filter** 和 **nat** 部分进行配置


~~~
*nat
:PREROUTING ACCEPT [3370:177472]
:POSTROUTING ACCEPT [32:1664]
:OUTPUT ACCEPT [42:2288]
...
...
-A POSTROUTING -s 192.168.1.0/24 -o em2 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [65295:28838004]
...
...
#-A FORWARD -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -i em1 -j ACCEPT
COMMIT
~~~

使用 **/etc/init.d/iptables  reload** 重新加载 **iptables**

---

配置主机默认路由
-

在想要连接外网的服务器上删除原有路由，添加新路由

~~~
[root@db-server ~]# ip route | grep default
default via 192.168.1.1 dev em1
[root@db-server ~]# ip route del default
[root@db-server ~]# ip route add default via 192.168.1.254 dev em1
~~~

测试连接

~~~
[root@db-server ~]# ping www.baidu.com
PING www.a.shifen.com (58.217.200.13) 56(84) bytes of data.
64 bytes from 58.217.200.13: icmp_seq=1 ttl=51 time=7.59 ms
64 bytes from 58.217.200.13: icmp_seq=2 ttl=51 time=7.60 ms
64 bytes from 58.217.200.13: icmp_seq=3 ttl=51 time=7.65 ms
64 bytes from 58.217.200.13: icmp_seq=4 ttl=51 time=7.58 ms
64 bytes from 58.217.200.13: icmp_seq=5 ttl=51 time=7.64 ms
^C
--- www.a.shifen.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4621ms
rtt min/avg/max/mdev = 7.585/7.615/7.653/0.113 ms
[root@db-server ~]#
~~~

---

总结
=

* **`net.ipv4.ip_forward = 1`**
* **`grep  forward  /etc/sysctl.conf`**
* **`sysctl  -a | grep  forwarding`**
* **`ip route | grep default`**
* **`iptables -A FORWARD -i em1 -j ACCEPT`**
* **`iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o em2 -j MASQUERADE`**
* **`-A POSTROUTING -s 192.168.1.0/24 -o em2 -j MASQUERADE`**
* **`-A FORWARD -i em1 -j ACCEPT`**
* **`/etc/init.d/iptables  reload`**
* **`ip route del default`**
* **`ip route add default via 192.168.1.254 dev em1`**

总体分三部
-

* 1.打开内核参数 **net.ipv4.ip_forward** 允许转发
* 2.打开 **filter** 表 **FORWARD** 链内网端口的转发
* 3.打开 **nat** 表 **POSTROUTING** 链的定向地址伪装

---


# iptables -I INPUT -p tcp --dport 80 -j DROP
# iptables -I INPUT -s 192.168.1.0/24 -p tcp --dport 80 -j ACCEPT
# iptables -I INPUT -s 211.123.16.123/24 -p tcp --dport 80 -j ACCEPT

iptables -I INPUT -p tcp --dport 9889 -j DROP
iptables -I INPUT -s 192.168.1.0/24 -p tcp --dport 9889 -j ACCEPT
如果用了NAT转发记得配合以下才能生效

iptables -I FORWARD -p tcp --dport 80 -j DROP
iptables -I FORWARD -s 192.168.1.0/24 -p tcp --dport 80 -j ACCEPT
常用的IPTABLES规则如下：

只能收发邮件，别的都关闭
iptables -I Filter -m mac --mac-source 00:0F:EA:25:51:37 -j DROP
iptables -I Filter -m mac --mac-source 00:0F:EA:25:51:37 -p udp --dport 53 -j ACCEPT
iptables -I Filter -m mac --mac-source 00:0F:EA:25:51:37 -p tcp --dport 25 -j ACCEPT
iptables -I Filter -m mac --mac-source 00:0F:EA:25:51:37 -p tcp --dport 110 -j ACCEPT


IPSEC NAT 策略
iptables -I PFWanPriv -d 192.168.100.2 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:80

iptables -t nat -A PREROUTING -p tcp --dport 1723 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:1723

iptables -t nat -A PREROUTING -p udp --dport 1723 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:1723

iptables -t nat -A PREROUTING -p udp --dport 500 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:500

iptables -t nat -A PREROUTING -p udp --dport 4500 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.2:4500


FTP服务器的NAT
iptables -I PFWanPriv -p tcp --dport 21 -d 192.168.100.200 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 21 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.200:21


只允许访问指定网址
iptables -A Filter -p udp --dport 53 -j ACCEPT
iptables -A Filter -p tcp --dport 53 -j ACCEPT
iptables -A Filter -d www.3322.org -j ACCEPT
iptables -A Filter -d img.cn99.com -j ACCEPT
iptables -A Filter -j DROP


开放一个IP的一些端口，其它都封闭
iptables -A Filter -p tcp --dport 80 -s 192.168.100.200 -d www.pconline.com.cn -j ACCEPT
iptables -A Filter -p tcp --dport 25 -s 192.168.100.200 -j ACCEPT
iptables -A Filter -p tcp --dport 109 -s 192.168.100.200 -j ACCEPT
iptables -A Filter -p tcp --dport 110 -s 192.168.100.200 -j ACCEPT
iptables -A Filter -p tcp --dport 53 -j ACCEPT
iptables -A Filter -p udp --dport 53 -j ACCEPT
iptables -A Filter -j DROP


多个端口
iptables -A Filter -p tcp -m multiport --destination-port 22,53,80,110 -s 192.168.20.3 -j REJECT


连续端口
iptables -A Filter -p tcp -m multiport --source-port 22,53,80,110 -s 192.168.20.3 -j REJECT iptables -A Filter -p tcp --source-port 2:80 -s 192.168.20.3 -j REJECT


指定时间上网
iptables -A Filter -s 10.10.10.253 -m time --timestart 6:00 --timestop 11:00 --days Mon,Tue,Wed,Thu,Fri,Sat,Sun -j DROP
iptables -A Filter -m time --timestart 12:00 --timestop 13:00 --days Mon,Tue,Wed,Thu,Fri,Sat,Sun -j ACCEPT
iptables -A Filter -m time --timestart 17:30 --timestop 8:30 --days Mon,Tue,Wed,Thu,Fri,Sat,Sun -j ACCEPT

禁止多个端口服务
iptables -A Filter -m multiport -p tcp --dport 21,23,80 -j ACCEPT


将WAN 口NAT到PC
iptables -t nat -A PREROUTING -i $INTERNET_IF -d $INTERNET_ADDR -j DNAT --to-destination 192.168.0.1


将WAN口8000端口NAT到192。168。100。200的80端口
iptables -t nat -A PREROUTING -p tcp --dport 8000 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.200:80


MAIL服务器要转的端口
iptables -t nat -A PREROUTING -p tcp --dport 110 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.200:110
iptables -t nat -A PREROUTING -p tcp --dport 25 -d $INTERNET_ADDR -j DNAT --to-destination 192.168.100.200:25


只允许PING 202。96。134。133,别的服务都禁止
iptables -A Filter -p icmp -s 192.168.100.200 -d 202.96.134.133 -j ACCEPT
iptables -A Filter -j DROP

禁用BT配置
iptables –A Filter –p tcp –dport 6000:20000 –j DROP

禁用QQ防火墙配置
iptables -A Filter -p udp --dport ! 53 -j DROP
iptables -A Filter -d 218.17.209.0/24 -j DROP
iptables -A Filter -d 218.18.95.0/24 -j DROP
iptables -A Filter -d 219.133.40.177 -j DROP

基于MAC，只能收发邮件，其它都拒绝
iptables -I Filter -m mac --mac-source 00:0A:EB:97:79:A1 -j DROP
iptables -I Filter -m mac --mac-source 00:0A:EB:97:79:A1 -p tcp --dport 25 -j ACCEPT
iptables -I Filter -m mac --mac-source 00:0A:EB:97:79:A1 -p tcp --dport 110 -j ACCEPT

禁用MSN配置
iptables -A Filter -p udp --dport 9 -j DROP
iptables -A Filter -p tcp --dport 1863 -j DROP
iptables -A Filter -p tcp --dport 80 -d 207.68.178.238 -j DROP
iptables -A Filter -p tcp --dport 80 -d 207.46.110.0/24 -j DROP

只允许PING 202。96。134。133 其它公网IP都不许PING
iptables -A Filter -p icmp -s 192.168.100.200 -d 202.96.134.133 -j ACCEPT
iptables -A Filter -p icmp -j DROP

禁止某个MAC地址访问internet:
iptables -I Filter -m mac --mac-source 00:20:18:8F:72:F8 -j DROP

禁止某个IP地址的PING:
iptables –A Filter –p icmp –s 192.168.0.1 –j DROP

禁止某个IP地址服务：
iptables –A Filter -p tcp -s 192.168.0.1 --dport 80 -j DROP
iptables –A Filter -p udp -s 192.168.0.1 --dport 53 -j DROP

只允许某些服务，其他都拒绝(2条规则)
iptables -A Filter -p tcp -s 192.168.0.1 --dport 1000 -j ACCEPT
iptables -A Filter -j DROP

禁止某个IP地址的某个端口服务
iptables -A Filter -p tcp -s 10.10.10.253 --dport 80 -j ACCEPT
iptables -A Filter -p tcp -s 10.10.10.253 --dport 80 -j DROP

禁止某个MAC地址的某个端口服务

iptables -I Filter -p tcp -m mac --mac-source 00:20:18:8F:72:F8 --dport 80 -j DROP

禁止某个MAC地址访问internet:
iptables -I Filter -m mac --mac-source 00:11:22:33:44:55 -j DROP
禁止某个IP地址的PING:
iptables –A Filter –p icmp –s 192.168.0.1 –j DROP
