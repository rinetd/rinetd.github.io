---
title: Tcpdump的详细用法
date: 2016-01-12T15:30:01+08:00
update: 2017-01-01
categories: [linux_base]
tags: [Tcpdump]
---
[聊聊tcpdump与Wireshark抓包分析 - 简书](http://www.jianshu.com/p/a62ed1bb5b20)
# 列出所有可用的网络接口
tcpdump -D
# 抓包指定端口：
tcpdump -nn -i any port 1234
## 抓指定主机
tcpdump -i eth1 -n host 123.132.226.66 or host 123.132.252.42 and tcp port 9011
tcpdump -i eth1 -n src 123.132.226.66 or src 123.132.252.42 and  port 9011
# 显示抓包数据
` tcpdump -i eth1 -l -s 0 -w - dst port 80 | strings | grep -i User-Agent`  显示 User-Agent 信息
    -s 0 输出全部data内容
    -w - 将报文写入到当前缓冲区
` tcpdump -i eth1 -l -s 0 -w - dst port 80 | strings | grep -i user-agent | grep -i -E 'bot|crawler|slurp|spider`

` tcpdump -i any  -l -w - dst port 80 | strings ` 仅显示[GET POST]请求
` tcpdump -i any  -l -A dst port 80 | strings `   显示更详细的连接建立过程
` tcpdump -i any  -l -A src 123.132.226.66 or src 123.132.252.42 and dst port 80 | strings `   显示更详细的连接建立过程

tcpdump -i any -nn port 80 -c 100|awk '{print $3}'|sort|uniq -c|sort -rn

#多级括号()
` tcpdump -nvvv -i any -c 20 '((port 80 or port 443) and (host 10.0.3.169 or host 10.0.3.1)) and dst host 10.0.3.246'`

##
 sudo tcpdump -i any -s 0 -l -w - dst port 3306 -w tcpdump.out
cat tcpdump.out | strings | grep -iE '^(UPDATE|DELETE|INSERT|SET|COMMIT|ROLLBACK|CREATE|DROP|ALTER)' | sed 's/$/;/g' >tcpdump.sql

1. TCPDump介绍     

  TcpDump可以将网络中传送的数据包的“头”完全截获下来提供分析。它支持针对网络层、协议、主机、网络或端口的过滤,并提供and、or、not等逻辑语句来帮助你去掉无用的信息。tcpdump就是一种免费的网络分析工具,尤其其提供了源代码,公开了接口,因此具备很强的可扩展性,对于网络维护和入侵者都是非常有用的工具。tcpdump存在于基本的FreeBSD系统中,由于它需要将网络界面设置为混杂模式,普通用户不能正常执行,但具备root权限的用户可以直接执行它来获取网络上的信息。因此系统中存在网络分析工具主要不是对本机安全的威胁,而是对网络上的其他计算机的安全存在威胁。

   我们用尽量简单的话来定义tcpdump,就是：dump the traffice on anetwork.,根据使用者的定义对网络上的数据包进行截获的包分析工具。作为互联网上经典的的系统管理员必备工具,tcpdump以其强大的功能,灵活的截取策略,成为每个高级的系统管理员分析网络,排查问题等所必备的东西之一。tcpdump提供了源代码,公开了接口,因此具备很强的可扩展性,对于网络维护和入侵者都是非常有用的工具。tcpdump存在于基本的FreeBSD系统中,由于它需要将网络界面设置为混杂模式,普通用户不能正常执行,但具备root权限的用户可以直接执行它来获取网络上的信息。因此系统中存在网络分析工具主要不是对本机安全的威胁,而是对网络上的其他计算机的安全存在威胁。  

2. TcpDump的使用

tcpdump采用命令行方式,它的命令格式为：
tcpdump [ -adeflnNOpqStvx ] [ -c 数量 ] [ -F 文件名 ] [ -i 网络接口 ] [ -r 文件名] [ -s snaplen ] [ -T 类型 ] [ -w 文件名 ] [表达式 ]

(1). tcpdump的选项介绍
-D      列出所有可用的网络接口。

-a 　　　将网络地址和广播地址转变成名字；
-d 　　　将匹配信息包的代码以人们能够理解的汇编格式给出；
-dd 　　 将匹配信息包的代码以c语言程序段的格式给出；
-ddd 　　将匹配信息包的代码以十进制的形式给出；
-f 　　　将外部的Internet地址以数字的形式打印出来；
-l 　　　使标准输出变为 *行缓冲* 形式；如果不加-l选项，那么只有全缓冲区满，才会输出一次
-n 　　　不把网络地址转换成名字；
-nn     不进行端口名称的转换。
-v 　　　输出一个稍微详细的信息,例如在ip包中可以包括ttl和服务类型的信息；
-vv 　　 输出详细的报文信息；

-nn：指定将每个监听到的数据包中的域名转换成IP、端口从应用名称转换成端口号后显示
-p：将网卡设置为非混杂模式,不能与host或broadcast一起使用
-F 　　　从指定的文件中读取表达式,忽略其它的表达式；

-e      指定将监听到的数据包链路层的信息-包括源和目的 **mac地址** ,以及网络层的协议 **IPv4/6**
-t 　　　不输出时间信息；`-t`
-c 　　　指定要监听的数据包数量,达到指定数量后自动停止抓包； `-c 1000`
-i 　　　指定监听的网络接口； `-i any` **抓取所有网卡**
-s      指定要监听数据包的长度 `-s 0` **输出全部data内容**
-r 　　　从指定的文件中读取包(这些包一般通过-w选项产生)； `-r dump.cap`
-w 　　　直接将包写入文件中,并不分析和打印出来； `-w dump.cap d.pcap 写入到文件` `-w - 写入到当前缓冲区`
-A      参数使返回值人类可读格式  `-A` 不与 -w 混用
-X XX   十六禁止显示输出内容
-T      强制tcpdump按type指定的协议所描述的包结构来分析收到的数据包.  目前已知的type 可取的协议为:
        aodv (Ad-hoc On-demand Distance Vector protocol, 按需距离向量路由协议, 在Ad hoc(点对点模式)网络中使用),
        cnfp (Cisco  NetFlow  protocol),  
        rpc(Remote Procedure Call),
        rtp (Real-Time Applications protocol),
        rtcp (Real-Time Applications con-trol protocol),
        snmp (Simple Network Management Protocol),
        tftp (Trivial File Transfer Protocol, 碎文件协议),
        vat (Visual Audio Tool, 可用于在internet 上进行电视电话会议的应用层协议)
        wb (distributed White Board, 可用于网络会议的应用层协议).

~~ -A,数据包的内容以 ASCII 显示,通常用来捉取 WWW 的网页数据包资料。~~
-c 在收到指定的数量的分组后,tcpdump就会停止。
-C 在将一个原始分组写入文件之前,检查文件当前的大小是否超过了参数file_size 中指定的大小。如果超过了指定大小,则关闭当前文件,然后在打开一个新的文件。参数 file_size 的单位是兆字节（是1,000,000字节,而不是1,048,576字节）。
-d 将匹配信息包的代码以人们能够理解的汇编格式给出。
-dd 将匹配信息包的代码以C语言程序段的格式给出。
-ddd 将匹配信息包的代码以十进制的形式给出。

-e 在输出行打印出数据链路层的头部信息。
-E 用spi@ipaddr algo:secret解密那些以addr作为地址,并且包含了安全参数索引值spi的IPsec ESP分组。
-f 将外部的Internet地址以数字的形式打印出来。
-F 从指定的文件中读取表达式,忽略命令行中给出的表达式。
-i 指定监听的网络接口。
-l 使标准输出变为缓冲行形式,可以把数据导出到文件。
-L 列出网络接口的已知数据链路。
-m 从文件module中导入SMI MIB模块定义。该参数可以被使用多次,以导入多个MIB模块。
-M 如果tcp报文中存在TCP-MD5选项,则需要用secret作为共享的验证码用于验证TCP-MD5选选项摘要（详情可参考RFC 2385）。
-b 在数据-链路层上选择协议,包括ip、arp、rarp、ipx都是这一层的。
-n 不把网络地址转换成名字。
-nn 不进行端口名称的转换。
-N 不输出主机名中的域名部分。例如,‘nic.ddn.mil‘只输出’nic‘。
-t 在输出的每一行不打印时间戳。
-O 不运行分组分组匹配（packet-matching）代码优化程序。
-P 不将网络接口设置成混杂模式。
-q 快速输出。只输出较少的协议信息。
-r 从指定的文件中读取包(这些包一般通过-w选项产生)。
-S 将tcp的序列号以绝对值形式输出,而不是相对值。
-s 从每个分组中读取最开始的snaplen个字节,而不是默认的68个字节。
-T 将监听到的包直接解释为指定的类型的报文,常见的类型有rpc远程过程调用）和snmp（简单网络管理协议；）。
-t 不在每一行中输出时间戳。
-tt 在每一行中输出非格式化的时间戳。
-ttt 输出本行和前面一行之间的时间差。
-tttt 在每一行中输出由date处理的默认格式的时间戳。
-u 输出未解码的NFS句柄。
-v 输出一个稍微详细的信息,例如在ip包中可以包括ttl和服务类型的信息。
-vv 输出详细的报文信息。
-w 直接将分组写入文件中,而不是不分析并打印出来。

-S：指定打印每个监听到的数据包的TCP绝对序列号而非相对序列号

tcpdump -i eth0 -s 1400 -nn host 192.168.0.250 and ! 192.168.0.74 and icmp -e

抓取网口eth0上192.168.0.250与除192.168.0.74外的其他主机之间的icmp报文

tcpdump -i eth0 -s 1400 -nn tcp and \(host 192.168.0.250 and ! 192.168.0.74\)

抓取网口eth0上192.168.0.250与除192.168.0.74外的所有tcp数据包,这里用到了括号,注意,在tcpdump中使用括号时必须用转义 。

`tcpdump -i eth0 ether src or dst 00:21:85:6C:D9:A3`

抓取网口eth0上源mac地址或目的mac地址为00:21:85:6C:D9:A3的所有数据包,注意,这里的mac地址格式必须以':'分隔。

#用tcpdump嗅探80端口的访问看看谁最高
`tcpdump  -i any -tnn dst port 80 -c 1000 | awk -F"." '{print  $1"."$2"."$3"."$4}' | sort | uniq -c | sort -nr  |head -20`

(2). tcpdump的表达式[过滤器(BPF语言)]的使用
主要介绍在tcpdump中的过滤器使用,因为懂了这个就可以得心应手的使用wireshark了。
         从最简单的开始,BPF语言主要有一个标志或者数字和限定词组成,限定词有三种：
          第一种：指定类型 默认是`host`
          host, 定义抓取哪个IP地址（也可以给它mac地址,格式是00:00:00:00:00:00）的数据包,比如我想抓有关192.168.0.148这个IP地址的数据包,那么就写成tcpdump host 192.168.0.148, host是限定词,192.168.0.148就是标志。这条命令会抓取从发出或者向192.168.0.148发送的数据包。
          `host 3sd.me` 特定主机
          net, 定义抓取某个网络的数据包,给出网络号就行了,它根据给的网络号字节数是1,2,3来判断A类地址,B类地址或者C类地址,比如tcpdump net 10.1.1 ,它就认为这是一个C类地址。
          `net 123.132` 网路地址段

          port,指定端口,比如tcpdump host and port 22, 这是抓端口为22的数据包,不管是TCP还是UDP的,这里我稍微早一点的给出了逻辑操作,and J,如果只想抓TCP的,那么可以写tcpdump host 192.168.0.148 and tcp port 22

          portrange,顾名思义,这个是指定端口范围的,用连字符”-”指定范围,
          `portrange 1025-8080`

         第二种：指定方向 默认是`src or dst`
          我们之前的命令都是说“这条命令会抓取从192.168.0.148发出或者向192.168.0.148发送”,所以,如果指向抓从发出的数据包可以使用限定词src, 命令：tcpdump src host 192.168.0.148,反过来,想抓发向192.168.0.148的数据包,使用限定词dst,命令：tcpdump dst host 192.168.0.148。

        第三种：指定协议
        我们知道网络协议有N种。。。我列一下常用的几种,其他的可以去google一下
        ether和fddi, 以太网协议
        tr, TR协议
        ip, IP协议
        ip6, IPv6协议
        arp,  ARP协议
        好了,最后还需要注意的是逻辑运算,and, or, not（与,或,非）,上面已经有一个例子了,和普通的编程语言没有什么不同。

除此之外,还有更加牛X的功能,比如指定TCP中的某个标识位是什么,这种应用我一般很少用。
##第一种是关于类型的关键字,主要包括
[host,net,port,portrange]
   例如
   `host 210.27.48.2`    指明210.27.48.2是一台主机,
   `net 123.132`         指明 123.132.0.0/16是一段网络地址,
   `port 23`             指明端口号是23。
   `portrange 1025-8080` 指明端口范围
   如果没有指定类型,缺省的类型是host

##第二种是确定传输方向的关键字,主要包括
[src , dst ,dst or src, dst and src],这些关键字指明了传输的方向。举例说明,src 210.27.48.2 ,指明ip包中源地址是210.27.48.2 , dst net202.0.0.0 指明目的网络地址是202.0.0.0 。如果没有指明方向关键字,则缺省是src or dst关键字。

##第三种是协议的关键字,主要包括
[tcp,udp,arp,rarp,ip,ip6,fddi,]等类型。Fddi指明是在FDDI(分布式光纤数据接口网络)上的特定的网络协议,实际上它是"ether"的别名,fddi和ether具有类似的源地址和目的地址,所以可以将fddi协议包当作ether的包进行处理和分析。其他的几个关键字就是指明了监听的包的协议内容。如果没有指定任何协议,则tcpdump将会监听所有协议的信息包。

##除了这三种类型的关键字之外,其他重要的关键字如下：
gateway,broadcast,less,greater,还有三种逻辑运算,取非运算是 'not ' '! ',与运算是'and','&&';或运算 是'or','││'；这些关键字可以组合起来构成强大的组合条件来满足人们的需要,

proto [ expr : size ]
　　proto表示该问的报文，expr的结果表示该报文的偏移，size为可选的，表示从expr偏移量起的szie个字节，整个表达式为proto报文 中,expr起的szie字节的内容（无符号整数）
　　下面是expr relop expr这种形式primitive的例子：
　　'ether[0] & 1 !=0' ether报文中第0个bit为1，即以太网广播或组播的primtive。
　　通过这种方式，我们可以对报文的任何一个字节进行匹配了，因此它的功能是十分强大的。
　　‘ip[0] = 4’ ip报文中的第一个字节为version，即匹配IPv4的报文，
　　如果我们想匹配一个syn报文，可以使用：'tcp[13] = 2'，因为tcp的标志位为TCP报文的第13个字节，而syn在这个字节的低1位，故匹配只有syn标志的报文,上述条件是可满要求的，并且比较严格。
　　如果想匹配ping命令的请求报文，可以使用'icmp[0]=8'，因为icmp报文的第0字符表示类型，当类型值为8时表示为回显示请求。
　　对于TCP和ICMP中常用的字节，如TCP中的标志位，ICMP中的类型，这个些偏移量有时会忘记。不过tcpdump为你提供更方便的用法，你不用记位这些数字，用字符就可以代替了.
## ICMP
    icmptype:表示icmp报文中类弄字节的偏移量
    icmpcode:表示icmp报文中编码字节的偏移量
icmp-echoreply, icmp-unreach, icmp-sourcequench, icmp-redi‐rect, icmp-echo, icmp-routeradvert, icmp-routersolicit,icmp-timxceed, icmp-paramprob, icmp-tstamp, icmp-tstam‐preply, icmp-ireq, icmp-ireqreply, icmp-maskreq, icmp-maskreply.

'icmp[icmptype] =8',如果8也记不住怎么办？tcpdump还为该字节的值也提供了字符表示,如'icmp[icmptype] = icmp-echo'。
下面是tcpdump提供的字符偏移量：


There are 8 bits in the control bits section of the TCP header:
        | CWR | ECE | URG | ACK | PSH | RST | SYN | FIN |
        |  7  |  6  |  5  |  4  |  3  |  2  |  2  |  0  |

      URG—为1表示高优先级数据包，紧急指针字段有效。
      ACK—为1表示确认号字段有效
      PSH—为1表示是带有PUSH标志的数据，指示接收方应该尽快将这个报文段交给应用层而不用等待缓冲区装满。
      RST—为1表示出现严重差错。可能需要重现创建TCP连接。还可以用于拒绝非法的报文段和拒绝连接请求。
      SYN—为1表示这是连接请求或是连接接受请求，用于创建连接和使顺序号同步
      FIN—为1表示发送方没有数据要传输了，要求释放连接。

Recall the structure of a TCP header without options:

      0             7|             15|             23|             31
     -----------------------------------------------------------------
0    |        source port            |       destination port        |
     -----------------------------------------------------------------
32   |                        sequence number                        |
     -----------------------------------------------------------------
64   |                     acknowledgment number                     |
     -----------------------------------------------------------------
96   |  HLEN | rsvd  |C|E|U|A|P|R|S|F|        window size            |
     -----------------------------------------------------------------
128  |         TCP checksum          |       urgent pointer          |
     -----------------------------------------------------------------
160  |                        Options                                |
     -----------------------------------------------------------------
     	报头长度 	保留 	标志符 	窗口大小
选项字段—最多40字节。每个选项的开始是1字节的kind字段，说明选项的类型。
0：选项表结束（1字节）
1：无操作（1字节）用于选项字段之间的字边界对齐。
2：最大报文段长度（4字节，Maximum Segment Size，MSS）通常在创建连接而设置SYN标志的数据包中指明这个选项，指明本端所能接收的最大长度的报文段。通常将MSS设置为（MTU-40）字节，携带TCP报文段的IP数据报的长度就不会超过MTU，从而避免本机发生IP分片。只能出现在同步报文段中，否则将被忽略。
3：窗口扩大因子（4字节，wscale），取值0-14。用来把TCP的窗口的值左移的位数。只能出现在同步报文段中，否则将被忽略。这是因为现在的TCP接收数据缓冲区（接收窗口）的长度通常大于65535字节。
4：sackOK—发送端支持并同意使用SACK选项。
5：SACK实际工作的选项。
8：时间戳（10字节，TCP Timestamps Option，TSopt）
    发送端的时间戳（Timestamp Value field，TSval，4字节）
    时间戳回显应答（Timestamp Echo Reply field，TSecr，4字节）


0                   1                   2                   3   
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+


## TCP中的某个标识位
tcpflags:表示TCP报文中标志位字节的偏移量
tcp[tcpflags] tcp-fin, tcp-syn, tcp-rst, tcp-push, tcp-act, tcp-urg
    'tcp[tcpflags] = tcp-syn' 匹配只有syn标志设置为1的 tcp报文
    'tcp[tcpflags] & (tcp-syn |tcp-ack |tcp-fin) !=0' 匹配含有syn,或ack或fin标志位的TCP报文


# TCP包的输出信息
src > dst: flags data-seqno ack window urgent options

用TCPDUMP捕获的TCP包的一般输出信息是：
10:38:31.551891 IP 123.132.226.66.48198 > aliyun.232: Flags [P.], seq 324:360, ack 506173, win 65535, options [nop,nop,TS val 2144208 ecr 700285683], length 36
10:38:31.551907 IP aliyun.232 > 123.132.226.66.48198: Flags [P.], seq 550909:551113, ack 360, win 24048, options [nop,nop,TS val 700285728 ecr 2144208], length 204

src> dst:表明从源地址到目的地址,
flags是TCP包中的标志信息,S 是SYN标志, F (FIN), P (PUSH) , R(RST) "." (没有标记);
data-seqno是数据包中的数据的顺序号,
ack是下次期望的顺序号,
window是接收缓存的窗口大小,
urgent表明数据包中是否有紧急指针.
Options是选项.


################################################################################
(3). tcpdump的输出结果介绍

http://anheng.com.cn/news/24/586.html    下面我们介绍几种典型的tcpdump命令的输出信息

# 数据链路层头信息
使用命令: #tcpdump --e host ice
    ice 是一台装有linux的主机,她的MAC地址是0:90:27:58:af:1a
    H219是一台装有SOLARIC的SUN工作站,它的MAC地址是8:0:20:79:5b:46；上一条命令的输出结果如下所示：
    21:50:12.847509 eth0 < 8:0:20:79:5b:46 0:90:27:58:af:1a ip 60: h219.33357 > ice.telnet 0:0(0) ack 22535 win 8760 (DF)

   分析：
   21：50：12是显示的时间,
   847509是ID号,
   eth0 <表示从网络接口eth0 接受该数据包,eth0>表示从网络接口设备发送数据包,
   8:0:20:79:5b:46是主机H219的MAC地址,它表明是从源地址H219发来的数据包.
   0:90:27:58:af:1a是主机ICE的MAC地址,表示该数据包的目的地址是ICE .
   ip 是表明该数据包是IP数据包,
   60是数据包的长度,
   h219.33357 > ice.telnet表明该数据包是从主机H219的33357端口发往主机ICE的TELNET(23)端口.
   ack 22535表明对序列号是222535的包进行响应.
   win 8760表明发送窗口的大小是8760.

# ARP包的TCPDUMP输出信息

使用命令:#tcpdump arp
得到的输出结果是：
22:32:42.802509 eth0 > arp who-has route tell ice (0:90:27:58:af:1a)
22:32:42.802902 eth0 < arp reply route is-at 0:90:27:12:10:66 (0:90:27:58:af:1a)
分析:
22:32:42是时间戳,
802509是ID号,
eth0 >表明从主机发出该数据包,
arp表明是ARP请求包,
who-has route tell ice表明是主机ICE请求主机ROUTE的MAC地址。
0:90:27:58:af:1a是主机ICE的MAC地址。


# UDP包的输出信息

   用TCPDUMP捕获的UDP包的一般输出信息是：

route.port1 > ice.port2: udp lenth
UDP十分简单,上面的输出行表明从主机ROUTE的port1端口发出的一个UDP数据包到主机ICE的port2端口,类型是UDP, 包的长度是lenth

下面举几个例子来说明。

A想要截获所有210.27.48.1 的主机收到的和发出的所有的数据包：
#tcpdump host 210.27.48.1

B想要截获主机210.27.48.1 和主机210.27.48.2 或210.27.48.3的通信,使用命令：(在命令行中使用括号时,一定要添加'\')

#tcpdump host 210.27.48.1 and \ (210.27.48.2 or 210.27.48.3 \)

C如果想要获取主机210.27.48.1除了和主机210.27.48.2之外所有主机通信的ip包,使用命令：

#tcpdump ip host 210.27.48.1 and ! 210.27.48.2

D如果想要获取主机210.27.48.1接收或发出的telnet包,使用如下命令：

#`tcpdump tcp port 23 host 210.27.48.1`

E 对本机的udp 123 端口进行监视 123 为ntp的服务端口

# tcpdump udp port 123

F 系统将只对名为hostname的主机的通信数据包进行监视。主机名可以是本地主机,也可以是网络上的任何一台计算机。下面的命令可以读取主机hostname发送的所有数据：

#tcpdump -i eth0 src host hostname
G 下面的命令可以监视所有送到主机hostname的数据包：

#tcpdump -i eth0 dst host hostname

H 我们还可以监视通过指定网关的数据包：

#tcpdump -i eth0 gateway Gatewayname

I 如果你还想监视编址到指定端口的TCP或UDP数据包,那么执行以下命令：

#tcpdump -i eth0 host hostname and port 80

J 如果想要获取主机210.27.48.1除了和主机210.27.48.2之外所有主机通信的ip包,使用命令：

#tcpdump ip host 210.27.48.1 and ! 210.27.48.2

K 想要截获主机210.27.48.1 和主机210.27.48.2 或210.27.48.3的通信,使用命令：

#tcpdump host 210.27.48.1 and \ (210.27.48.2 or 210.27.48.3 \)

L 如果想要获取主机210.27.48.1除了和主机210.27.48.2之外所有主机通信的ip包,使用命令：

#tcpdump ip host 210.27.48.1 and ! 210.27.48.2

M 如果想要获取主机210.27.48.1接收或发出的telnet包,使用如下命令：

#tcpdump tcp port 23 host 210.27.48.1


3. 辅助工具

(1) 想查看TCP或者UDP端口使用情况,使用 netstat -anp
    如果有些进程看不见,如只显示”-”,可以尝试
sudo netstat -anp
    如果想看某个端口的信息,使用lsof命令,如：
sudo lsof -i :631

-bash-3.00# netstat -tln

    netstat -tln 命令是用来查看linux的端口使用情况

/etc/init.d/vsftp start 是用来启动ftp端口~！

   看文件/etc/services

netstat

   查看已经连接的服务端口（ESTABLISHED）

netstat -a

   查看所有的服务端口（LISTEN,ESTABLISHED）

sudo netstat -ap

   查看所有 的服务端口并显示对应的服务程序名

nmap ＜扫描类型＞＜扫描参数＞

例如：

nmap localhost

nmap -p 1024-65535 localhost

nmap -PT 192.168.1.127-245

    当我们使用　netstat -apn　查看网络连接的时候,会发现很多类似下面的内容：

Proto Recv-Q Send-Q Local Address Foreign Address State PID/Program name

tcp 0 52 218.104.81.152：7710 211.100.39.250：29488 ESTABLISHED 6111/1

    显示这台服务器开放了7710端口,那么 这个端口属于哪个程序呢？我们可以使用　lsof -i ：7710　命令来查询：

COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME

sshd 1990 root 3u IPv4 4836 TCP * ：7710 （LISTEN）

    这样,我们就知道了7710端口是属于sshd程序的。

(2) 运行tcpdump命令出现错误信息排除

tcpdump: no suitable device found
tcpdump: no devices found /dev/bpf4: A file or directory in the path name does not exist.
解决方案 2种原因：
1.权限不够,一般不经过处理,只用root用户能使用tcpdump
2.缺省只能同时使用4个tcpdump,如用完,则报此类错。需要停掉多余的tcpdump

第一种是关于类型的关键字，主要包括host，net，port, 例如 host 210.27.48.2，指明 210.27.48.2是一台主机，net 202.0.0.0 指明 202.0.0.0是一个网络地址，port 23 指明端口号是23。如果没有指定类型，缺省的类型是host.
第二种是确定传输方向的关键字，主要包括src , dst ,dst or src, dst and src ,这些关键字指明了传输的方向。举例说明，src 210.27.48.2 ,指明ip包中源地址是210.27.48.2 , dst net 202.0.0.0 指明目的网络地址是202.0.0.0 。如果没有指明方向关键字，则缺省是src or dst关键字。
第三种是协议的关键字，主要包括fddi,ip,arp,rarp,tcp,udp等类型。Fddi指明是在FDDI(分布式光纤数据接口网络)上的特定 的网络协议，实际上它是"ether"的别名，fddi和ether具有类似的源地址和目的地址，所以可以将fddi协议包当作ether的包进行处理和 分析。其他的几个关键字就是指明了监听的包的协议内容。如果没有指定任何协议，则tcpdump将会监听所有协议的信息包。
  除了这三种类型的关键字之外，其他重要的关键字如下：gateway, broadcast,less,greater,还有三种逻辑运算，取非运算是 'not ' '! ', 与运算是'and','&&';或运算 是'or' ,'││'；这些关键字可以组合起来构成强大的组合条件来满足人们的需要，下面举几个例子来说明。
  普通情况下，直接启动tcpdump将监视第一个网络界面上所有流过的数据包。
# tcpdump
tcpdump: listening on fxp0
11:58:47.873028 202.102.245.40.netbios-ns > 202.102.245.127.netbios-ns: udp 50
11:58:47.974331 0:10:7b:8:3a:56 > 1:80:c2:0:0:0 802.1d ui/C len=43
                       0000 0000 0080 0000 1007 cf08 0900 0000
                       0e80 0000 902b 4695 0980 8701 0014 0002
                       000f 0000 902b 4695 0008 00
11:58:48.373134 0:0:e8:5b:6d:85 > Broadcast sap e0 ui/C len=97
                       ffff 0060 0004 ffff ffff ffff ffff ffff
                       0452 ffff ffff 0000 e85b 6d85 4008 0002
                       0640 4d41 5354 4552 5f57 4542 0000 0000
                       0000 00
使用-i参数指定tcpdump监听的网络界面，这在计算机具有多个网络界面时非常有用，
使用-c参数指定要监听的数据包数量，
使用-w参数指定将监听到的数据包写入文件中保存
 A想要截获所有210.27.48.1 的主机收到的和发出的所有的数据包：
#tcpdump host 210.27.48.1
B想要截获主机210.27.48.1 和主机210.27.48.2 或210.27.48.3的通信，使用命令：（在命令行中适用　括号时，一定要
#tcpdump host 210.27.48.1 and \ (210.27.48.2 or 210.27.48.3 \)
C如果想要获取主机210.27.48.1除了和主机210.27.48.2之外所有主机通信的ip包，使用命令：
#tcpdump ip host 210.27.48.1 and ! 210.27.48.2
D如果想要获取主机210.27.48.1接收或发出的telnet包，使用如下命令：
#tcpdump tcp port 23 host 210.27.48.1
E 对本机的udp 123 端口进行监视 123 为ntp的服务端口
# tcpdump udp port 123

F 系统将只对名为hostname的主机的通信数据包进行监视。主机名可以是本地主机，也可以是网络上的任何一台计算机。下面的命令可以读取主机hostname发送的所有数据：
#tcpdump -i eth0 src host hostname
G 下面的命令可以监视所有送到主机hostname的数据包：
#tcpdump -i eth0 dst host hostname
H  我们还可以监视通过指定网关的数据包：
#tcpdump -i eth0 gateway Gatewayname
I 如果你还想监视编址到指定端口的TCP或UDP数据包，那么执行以下命令：
#tcpdump -i eth0 host hostname and port 80
J 如果想要获取主机210.27.48.1除了和主机210.27.48.2之外所有主机通信的ip包
，使用命令：
#tcpdump ip host 210.27.48.1 and ! 210.27.48.2
K 想要截获主机210.27.48.1 和主机210.27.48.2 或210.27.48.3的通信，使用命令
：（在命令行中适用　括号时，一定要
#tcpdump host 210.27.48.1 and \ (210.27.48.2 or 210.27.48.3 \)
L 如果想要获取主机210.27.48.1除了和主机210.27.48.2之外所有主机通信的ip包，使用命令：
　#tcpdump ip host 210.27.48.1 and ! 210.27.48.2
M 如果想要获取主机210.27.48.1接收或发出的telnet包，使用如下命令：
　#tcpdump tcp port 23 host 210.27.48.1
第三种是协议的关键字，主要包括fddi,ip ,arp,rarp,tcp,udp等类型
除了这三种类型的关键字之外，其他重要的关键字如下：gateway, broadcast,less,
greater,还有三种逻辑运算，取非运算是 'not ' '! ', 与运算是'and','&&';或运算 是'o
r' ,'||'；
第二种是确定传输方向的关键字，主要包括src , dst ,dst or src, dst and src ,
如果我们只需要列出送到80端口的数据包，用dst port；如果我们只希望看到返回80端口的数据包，用src port。
#tcpdump –i eth0 host hostname and dst port 80  目的端口是80
或者
#tcpdump –i eth0 host hostname and src port 80  源端口是80  一般是提供http的服务的主机
如果条件很多的话  要在条件之前加and 或 or 或 not
#tcpdump -i eth0 host ! 211.161.223.70 and ! 211.161.223.71 and dst port 80
如果在ethernet 使用混杂模式 系统的日志将会记录
May  7 20:03:46 localhost kernel: eth0: Promiscuous mode enabled.
May  7 20:03:46 localhost kernel: device eth0 entered promiscuous mode
May  7 20:03:57 localhost kernel: device eth0 left promiscuous mode
tcpdump对截获的数据并没有进行彻底解码，数据包内的大部分内容是使用十六进制的形式直接打印输出的。显然这不利于分析网络故障，通常的解决办法是先使用带-w参数的tcpdump 截获数据并保存到文件中，然后再使用其他程序进行解码分析。当然也应该定义过滤规则，以避免捕获的数据包填满整个硬盘。

#tcpdump入门：分析一次完整HTTP请求（原创）

为简单明了起见，我截获了一段“干净”的数据包，显示了本机对某URL发起的一次请求的全过程：

23:30:01.828266 IP 192.168.0.251.34245 > li527-105.members.linode.com.http: Flags [S], seq 2340440979, win 14600, options [mss 1460,sackOK,TS val 237397584 ecr 0,nop,wscale 7], length 0
23:30:01.931109 IP li527-105.members.linode.com.http > 192.168.0.251.34245: Flags [S.], seq 64288983, ack 2340440980, win 14480, options [mss 1440,sackOK,TS val 3220226885 ecr 237397584,nop,wscale 7], length 0
23:30:01.931221 IP 192.168.0.251.34245 > li527-105.members.linode.com.http: Flags [.], ack 1, win 115, options [nop,nop,TS val 237397594 ecr 3220226885], length 0
23:30:01.931544 IP 192.168.0.251.34245 > li527-105.members.linode.com.http: Flags [P.], seq 1:133, ack 1, win 115, options [nop,nop,TS val 237397594 ecr 3220226885], length 132
23:30:02.031923 IP li527-105.members.linode.com.http > 192.168.0.251.34245: Flags [.], ack 133, win 122, options [nop,nop,TS val 3220226987 ecr 237397594], length 0
23:30:02.032171 IP li527-105.members.linode.com.http > 192.168.0.251.34245: Flags [P.], seq 1:323, ack 133, win 122, options [nop,nop,TS val 3220226988 ecr 237397594], length 322
23:30:02.032233 IP 192.168.0.251.34245 > li527-105.members.linode.com.http: Flags [.], ack 323, win 123, options [nop,nop,TS val 237397604 ecr 3220226988], length 0
23:30:02.034852 IP 192.168.0.251.34245 > li527-105.members.linode.com.http: Flags [F.], seq 133, ack 323, win 123, options [nop,nop,TS val 237397605 ecr 3220226988], length 0
23:30:02.139101 IP li527-105.members.linode.com.http > 192.168.0.251.34245: Flags [F.], seq 323, ack 134, win 122, options [nop,nop,TS val 3220227091 ecr 237397605], length 0
23:30:02.139233 IP 192.168.0.251.34245 > li527-105.members.linode.com.http: Flags [.], ack 324, win 123, options [nop,nop,TS val 237397615 ecr 3220227091], length 0

TCP协议要建立连接要经过3次“握手”，截取的数据包也是从3次握手开始，可以看到前三个包的状态（Flags）分别是：

 [S]、[S.]、[.]

首先是客户端向服务端发送一个10位的序号给服务端；服务端收到后把它+1再返回回去；客户端检查返回来的序号是对的，就返回给服务端一个1。根据上面的描述，知道这三个包满足：第一个包的seq+1=第二个包的ack；第三个包的ack=1

连接建立了之后就是具体的数据交互了，tcpdump脚本加-X参数可以通过十六进制和ASCII方式显示出具体的数据内容，这里略过。

TCP协议要断开连接要经过4次“挥手”，上面数据包的最后3条就是挥手的过程。细心的朋友会发现前面说的4次挥手，却只有3个包，这不是笔误。

最后三个包的状态分别是：

[F.]、[F.]、[.]

首先是客户端发一个序号告诉服务器我要断开，服务器说行，服务器发回一个序号，说断开吧，客户端说：“断！”

四次挥手之所以只能看到3个数据包是因为：ACK延迟发送机制。为了提高性能，TCP在收到ACK之后会攒起来而不是立即发送的，在几种情况下才会发送：

1 超过MSS（可以理解为攒得太多了，放不下了）
2 有FIN
3 系统设置为禁用延迟（TCP_NODELAY）

倒数第二条的前面应该还有一个ACK，因为不符合上述3条，所以被延迟（一般是40ms或者200ms）了，等到倒数第二条发出时符合条件了（有FIN）就一块发出来了，所以4次挥手只能看到3个包。如果系统禁用了延迟发送，就会看到4个包了。
