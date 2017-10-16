---
title: 安全工具 Nmap
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [nmap]
---
[端口扫描之王——nmap入门精讲（一） - 推酷](http://www.tuicool.com/articles/BfQbeif)
[端口扫描之王——nmap入门精讲（二） - 谢灿勇 - 博客园](http://www.cnblogs.com/st-leslie/p/5118112.html)
[渗透测试之Nmap命令（一） - Jeanphorn的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/jeanphorn/article/details/45157737)
[Nmap是用于端口扫描，服务检测，甚至是漏洞扫描等多种功能的强大工具。Nmap从入门到高级覆盖了许多基础的概_hackers_115社区](http://115.com/215441/T47811.html?uid=309770914)
# waf检测
nmap -p 80,443 --script=http-waf-detect www.example.com
nmap -p 80,443 --script=http-waf-fingerprint www.example.com

nmap -sV 115.28.60.222 -p 8554
nmap -sV 139.129.108.163 -p 554,8554
全面扫描：nmap-T4 -A targetip    
1. 主机发现：nmap-T4 -sn targetip   
2. 端口扫描：nmap-T4 targetip
3. 服务扫描：nmap-T4 -sV targetip  
4. 操作系统扫描：nmap -T4 -O targetip  
Nmap包含四项基本功能：

主机发现（Host Discovery）
端口扫描（Port Scanning）
版本侦测（Version Detection）
操作系统侦测（Operating System Detection）

端口扫描之王——nmap入门精讲（一）

端口扫描在百度百科上的定义是：

端口扫描是指某些别有用心的人发送一组端口扫描消息，试图以此侵入某台计算机，并了解其提供的计算机网络服务类型(这些网络服务均与端口号相关)，但是端口扫描不但可以为黑客所利用，同时端口扫描还是网络安全工作者的必备的利器，通过对端口的扫描，了解网站中出现的漏洞以及端口的开放情况，对网站安全方面有着不可或缺的贡献，是你学习网络安全的第一门课程的首选

目前在市面上主要的端口扫描工具是X_Scan、SuperScan、nmap，其中在这里主推的是nmap，因为nmap具有以下的这一些优点：

1、多种多样的参数，丰富的脚本库，满足用户的个人定制需求，其中脚本库还提供了很多强大的功能任你选择

2、强大的可移植性，基本上能在所有的主流系统上运行，而且代码是开源的

3、详细的文档说明，和强大的社区团队进行支持，方面新人上手

Nmap是一款开源免费的网络发现（Network Discovery）和安全审计（Security Auditing）工具，但是nmap也是有一些缺点的，比如说上手较难，但是难上手是相对的，与其他达到这种功能性的软件产品相比，还是比较容易上手的，但是这也不妨碍nmap成为世界千万安全专家列为必备的工具之一，在其中的一些影视作品中《黑客帝国2》、《特警判官》中都有亮相

废话不多说，开始今天的nmap学习：

nmap的安装：直接从百度上下载，然后安装的步骤跟其他的软件一样，最后确认安装成功只需要在命令行中输入nmap回车，有相关的参数输出即为安装成功，安装的具体步骤可以查看：http://jingyan.baidu.com/article/5bbb5a1b1e0a7713eba179cb.html，在此就不多说了

Nmap包含四项基本功能：

    主机发现（Host Discovery）
    端口扫描（Port Scanning）
    版本侦测（Version Detection）
    操作系统侦测（Operating System Detection）

下面就从主机发现一步一步进行探讨

主机发现顾名思义就是发现所要扫描的主机是否是正在运行的状态，接下来就来一个简单例子

例子要求：获取http://nmap.org 的主机是否开启

输入命令：nmap -F -sT -v nmap.org

-F：扫描100个最有可能开放的端口   
-v 获取扫描的信息   
-sT：采用的是TCP扫描 不写也是可以的，默认采用的就是TCP扫描

补充说明：

端口端口一般是有下面这几种状态的
  状态 	          详细的参数说明
 Open 	         端口开启，数据有到达主机，有程序在端口上监控
 Closed 	       端口关闭，数据有到达主机，没有程序在端口上监控
 Filtered 	     数据没有到达主机，返回的结果为空，数据被防火墙或者是IDS过滤
 UnFiltered 	   数据有到达主机，但是不能识别端口的当前状态
 Open|Filtered 	 端口没有返回值，主要发生在UDP、IP、FIN、NULL和Xmas扫描中
 Closed|Filtered 只发生在IP ID idle扫描

图中的4是本次返回的关键信息，其中我们要主要关注的是端口号，端口状态，端口上的服务

那你可能就会要问为什么要关注这些端口呢？那这个问题就要转到探讨为什么要进行扫描？

扫描对于黑客和安全人员来说，主要的流程是这样的

上面的图中的IP写错了，应该改为FTP

从这个图中我们不难发现，我们主要关注的区域就是这些内容

接下来就来讨论下面上面提出来的问题？怎样对URL解析的时间进行优化，在Nmap重提供了不进行解析的参数(-n),这样就不会对域名进行解析了

其中关于域名解析的相关参数还有：

-R 为所有的目标主机进行解析

--system-dns 使用系统域名解析器进行解析，这个解析起来会比较慢

--dns-server 服务器选择DNS解析

说到-R注释的意思你会有所体会，其实nmap的扫描解析不止是对一个目标主机进行解析，还可以对一定范围内的目标主机群进行解析

例如：查找45.33.49.119-120的主机的状态以及端口状态

分析：

1、虽然查找的主机的数量不多，但是这样查找起来也是很浪费时间的， 所有我们可以通过使用快速查找的方法来节约时间

快速查找端口方法的原理如下：

默认的情况下，我们的查找是查找最有可能开放的1000端口，但是使用快速端口查找(参数 -F )会查找最有可能开放的100个端口，这样也就节约了10倍的时间

 2、这里我们需要获取端口的状态，所以就不能使用参数(-sn)，这个参数是可以跳过端口扫描，直接进行主机发现的

输入命令：nmap -F -sT -v -n 45.33.49.119-120      45.33.49.119:nmap.org的IP地址

PS:1、-sn参数只能扫描的主机，不能扫描端口，另一个参数也要特别注意的是（-PE）通过ICMP echo判定主机是否存活

运行情况如下：

图片中的1处指的是，采用sT的扫描方法，这种扫描方法准确，速度快，但是这样的扫描容易被防火墙和IDS发现并记录，所以这种方法，实际中并不多用

由图中的3处我们可以知道在不进行解析的情况下扫描用时为26.92秒，比解析的时候用的时间节约了不少

图中的4说明了扫描了2个主机，然后只有一个主机为开启

 提示：

在nmap运行的时候，如果我们可以像其他编程一样打“断点”，直接按键盘的d键就行了，如果想知道运行的进度可以按下X键

好了，示例也讲完了，下面我们就来分析一下扫描的各种方法：

# 端口扫描

## 1、TCP扫描（-sT）

这是一种最为普通的扫描方法，这种扫描方法的特点是：扫描的速度快，准确性高，对操作者没有权限上的要求，但是容易被防火墙和IDS(防入侵系统)发现

运行的原理：通过建立TCP的三次握手连接来进行信息的传递

① Client端发送SYN；

② Server端返回SYN/ACK，表明端口开放；

③ Client端返回ACK，表明连接已建立；

④ Client端主动断开连接。

SYNC -> SYNC/ACK -> ACK

## 2、SYN扫描（-sS）

这是一种秘密的扫描方式之一，因为在SYN扫描中Client端和Server端没有形成3次握手，所以没有建立一个正常的TCP连接，因此不被防火墙和日志所记录，一般不会再目标主机上留下任何的痕迹，但是这种扫描是需要root权限（对于windows用户来说，是没有root权限这个概念的，root权限是linux的最高权限，对应windows的管理员权限）

运行的原理图如下：

SYNC -> SYNC/ACK -> RST

## 3、NULL扫描

NULL扫描是一种反向的扫描方法，通过发送一个没有任何标志位的数据包给服务器，然后等待服务器的返回内容。这种扫描的方法比前面提及的扫描方法要隐蔽很多，但是这种方法的准确度也是较低的， 主要的用途是用来判断操作系统是否为windows，因为windows不遵守RFC 793标准，不论端口是开启还是关闭的都返回RST包
NULL -> RST

但是虽然NULL具有这样的一些用处，但是本人却认为不宜使用NULL

1、NULL方法的精确度不高，端口的状态返回的不是很准确

2、要获取目标主机的运行系统，可以使用参数(-O),来获取对于一些操作系统无法准确判断的，可以加上参数(-osscan-guess)

3、NULL扫描易被过滤

## 4、FIN扫描

FIN扫描的原理与NULL扫描的原理基本上是一样的在这里就不重复了

## 5、ACK扫描

ACK扫描的原理是发送一个ACK包给目标主机，不论目标主机的端口是否开启，都会返回相应的RST包，通过判断RST包中的TTL来判断端口是否开启

运行原理图：

ACK -> RST (TTL<64)

TTL值小于64端口开启，大于64端口关闭

大致上主要的扫描方法就是这些，除了我们可以按照这样些参数去执行扫描外，还可以自己定义一个TCP扫描包

6、自定义TCP扫描包的参数为（--scanflags）

例如：定制一个包含ACK扫描和SYN扫描的安装包

命令：nmap --scanflags ACKSYN nmap.org

 好了，接下来还有各种扫描方法的端口列表参数

-PS 端口列表用,隔开[tcp80 syn 扫描]
-PA 端口列表用,隔开[ack扫描](PS+PA测试状态包过滤防火墙【非状态的PA可以过】)【默认扫描端口1-1024】
-PU 端口列表用,隔开[udp高端口扫描 穿越只过滤tcp的防火墙]

其他的常见命令

输出命令

-oN 文件名 输出普通文件

-oX 文件名 输出xml文件

错误调试：

--log-errors 输出错误日志

--packet-trace 获取从当前主机到目标主机的所有节点

其他的相关参数可以参考：http://www.2cto.com/Article/201203/125686.html 到时候需要再进行查找

相关资料：

http://www.tuicool.com/articles/ZBvmYrN

http://www.2cto.com/Article/201203/125686.html

在此特别感谢各位前辈为nmap提供了为数不多的宝贵资料










Nmap 7.01 ( https://nmap.org )
Usage: nmap [Scan Type(s)] [Options] {target specification}
1. TARGET SPECIFICATION:
  Can pass hostnames, IP addresses, networks, etc.
  Ex: scanme.nmap.org, microsoft.com/24, 192.168.0.1; 10.0.0-255.1-254
  -iL <inputfilename>: Input from list of hosts/networks
  -iR <num hosts>: Choose random targets
  --exclude <host1[,host2][,host3],...>: Exclude hosts/networks
  --excludefile <exclude_file>: Exclude list from file
HOST DISCOVERY:
  -sL: List Scan - simply list targets to scan
  -sn: Ping Scan - disable port scan
  -Pn: Treat all hosts as online -- skip host discovery
  -PS/PA/PU/PY[portlist]: TCP SYN/ACK, UDP or SCTP discovery to given ports
  -PE/PP/PM: ICMP echo, timestamp, and netmask request discovery probes
  -PO[protocol list]: IP Protocol Ping
  -n/-R: Never do DNS resolution/Always resolve [default: sometimes]
  --dns-servers <serv1[,serv2],...>: Specify custom DNS servers
  --system-dns: Use OS's DNS resolver
  --traceroute: Trace hop path to each host
SCAN TECHNIQUES:
  -sS/sT/sA/sW/sM: TCP SYN/Connect()/ACK/Window/Maimon scans
  -sU: UDP Scan
  -sN/sF/sX: TCP Null, FIN, and Xmas scans
  --scanflags <flags>: Customize TCP scan flags
  -sI <zombie host[:probeport]>: Idle scan
  -sY/sZ: SCTP INIT/COOKIE-ECHO scans
  -sO: IP protocol scan
  -b <FTP relay host>: FTP bounce scan
PORT SPECIFICATION AND SCAN ORDER:
  -p <port ranges>: Only scan specified ports
    Ex: -p22; -p1-65535; -p U:53,111,137,T:21-25,80,139,8080,S:9
  --exclude-ports <port ranges>: Exclude the specified ports from scanning
  -F: Fast mode - Scan fewer ports than the default scan
  -r: Scan ports consecutively - don't randomize
  --top-ports <number>: Scan <number> most common ports
  --port-ratio <ratio>: Scan ports more common than <ratio>
SERVICE/VERSION DETECTION:
  -sV: Probe open ports to determine service/version info
  --version-intensity <level>: Set from 0 (light) to 9 (try all probes)
  --version-light: Limit to most likely probes (intensity 2)
  --version-all: Try every single probe (intensity 9)
  --version-trace: Show detailed version scan activity (for debugging)
SCRIPT SCAN:
  -sC: equivalent to --script=default
  --script=<Lua scripts>: <Lua scripts> is a comma separated list of
           directories, script-files or script-categories
  --script-args=<n1=v1,[n2=v2,...]>: provide arguments to scripts
  --script-args-file=filename: provide NSE script args in a file
  --script-trace: Show all data sent and received
  --script-updatedb: Update the script database.
  --script-help=<Lua scripts>: Show help about scripts.
           <Lua scripts> is a comma-separated list of script-files or
           script-categories.
OS DETECTION:
  -O: Enable OS detection
  --osscan-limit: Limit OS detection to promising targets
  --osscan-guess: Guess OS more aggressively
TIMING AND PERFORMANCE:
  Options which take <time> are in seconds, or append 'ms' (milliseconds),
  's' (seconds), 'm' (minutes), or 'h' (hours) to the value (e.g. 30m).
  -T<0-5>: Set timing template (higher is faster)
  --min-hostgroup/max-hostgroup <size>: Parallel host scan group sizes
  --min-parallelism/max-parallelism <numprobes>: Probe parallelization
  --min-rtt-timeout/max-rtt-timeout/initial-rtt-timeout <time>: Specifies
      probe round trip time.
  --max-retries <tries>: Caps number of port scan probe retransmissions.
  --host-timeout <time>: Give up on target after this long
  --scan-delay/--max-scan-delay <time>: Adjust delay between probes
  --min-rate <number>: Send packets no slower than <number> per second
  --max-rate <number>: Send packets no faster than <number> per second
FIREWALL/IDS EVASION AND SPOOFING:
  -f; --mtu <val>: fragment packets (optionally w/given MTU)
  -D <decoy1,decoy2[,ME],...>: Cloak a scan with decoys
  -S <IP_Address>: Spoof source address
  -e <iface>: Use specified interface
  -g/--source-port <portnum>: Use given port number
  --proxies <url1,[url2],...>: Relay connections through HTTP/SOCKS4 proxies
  --data <hex string>: Append a custom payload to sent packets
  --data-string <string>: Append a custom ASCII string to sent packets
  --data-length <num>: Append random data to sent packets
  --ip-options <options>: Send packets with specified ip options
  --ttl <val>: Set IP time-to-live field
  --spoof-mac <mac address/prefix/vendor name>: Spoof your MAC address
  --badsum: Send packets with a bogus TCP/UDP/SCTP checksum
OUTPUT:
  -oN/-oX/-oS/-oG <file>: Output scan in normal, XML, s|<rIpt kIddi3,
     and Grepable format, respectively, to the given filename.
  -oA <basename>: Output in the three major formats at once
  -v: Increase verbosity level (use -vv or more for greater effect)
  -d: Increase debugging level (use -dd or more for greater effect)
  --reason: Display the reason a port is in a particular state
  --open: Only show open (or possibly open) ports
  --packet-trace: Show all packets sent and received
  --iflist: Print host interfaces and routes (for debugging)
  --append-output: Append to rather than clobber specified output files
  --resume <filename>: Resume an aborted scan
  --stylesheet <path/URL>: XSL stylesheet to transform XML output to HTML
  --webxml: Reference stylesheet from Nmap.Org for more portable XML
  --no-stylesheet: Prevent associating of XSL stylesheet w/XML output
MISC:
  -6: Enable IPv6 scanning
  -A: Enable OS detection, version detection, script scanning, and traceroute
  --datadir <dirname>: Specify custom Nmap data file location
  --send-eth/--send-ip: Send using raw ethernet frames or IP packets
  --privileged: Assume that the user is fully privileged
  --unprivileged: Assume the user lacks raw socket privileges
  -V: Print version number
  -h: Print this help summary page.
EXAMPLES:
  nmap -v -A scanme.nmap.org
  nmap -v -sn 192.168.0.0/16 10.0.0.0/8
  nmap -v -iR 10000 -Pn -p 80
SEE THE MAN PAGE (https://nmap.org/book/man.html) FOR MORE OPTIONS AND EXAMPLES


1.介绍

　　相信很多朋友在这之前已经对nmap有所了解，或者已经使用过nmap了，这里做一下简单的介绍。nmap（Network Mapper）最初由Gordon Fyodor Lyon于1997年创建。nmap可以用来扫描一个网络，监控服务，列出网络主机等 namp还可以提供操作系统的类型、开放端口信息，可用过namp的配置实现。
　　根据官网http://namp.org介绍，nmap包含众多脚本，这些脚本的功能从猜测Apple Filing Protocol密码到确认是否与X-servers建立连接等等。
　　Nmap家族还包括：
　　

ZenMap——Nmap的图形界面版。
Ncat——基于netcat，扩展了一些功能，如：ncat链、SSL支持、支持二进制等。
Ncrack——测试已部署的认证系统和密码强度，支持常用协议。
Ndiff——用于网络基线测试，对比Nmap扫描结果之间的差异。
Nping——允许将自己构造的数据包整合在扫描过程中，并能够对原始数据报进行操控。
2. Nmap常用扫描选项和类型

-g	指定源端口	使用特定源端口发送数据包
–spoofmac	Mac欺骗	创建虚假mac，随机化mac地址
-S	源Ip地址	伪造源IP，或指定源IP
-e	选择网口	选择发送和接受数据的网口
-F	快速扫描	namp-services文件中默认扫描减到100个端口
-p	确定端口范围	选择扫描端口
-N	NDS解析	执行反向lookup
-R	反向lookup	强制反向lookup

-Pn强调不适用ping（默认是使用的）

-A	激进型	启用许多扫描选项，如版本扫描和脚本扫描（慎用）
常用扫描类型：

扫描类型	名称	功能
-sA	ACK扫描	检查端口是否开放，可用于探测防火墙 一个简单的ACK扫描意味着攻击者只有较低的概率检测到受害机，但是有较高的几率发现防火墙
-sP	Ping扫描	快速发现网络
-sR	PRC扫描	定位PRC，对成功扫描的机器记录
-sS	TCP SYN扫描	快速和隐蔽的扫描，半开放扫描
-sU	UDP扫描	确定符合特定UDP端口是否开放
-sX	XMAS扫描	隐蔽扫描，扫描特定配置的防火墙
-sL	列出扫描对象	列出要扫描的IP，使用-n选项确保不向网络中发数据包
-sO	IP协议扫描	寻找使用IP协议的主机
-sM	FIN/ACK	隐蔽扫描，适用于unix系统。查找RST数据包
-sI	闲置扫描	僵尸主机扫描，非常隐蔽

端口端口一般是有下面这几种状态的

状态	详细的参数说明
 Open	 端口开启，数据有到达主机，有程序在端口上监控
 Closed	 端口关闭，数据有到达主机，没有程序在端口上监控
 Filtered	 数据没有到达主机，返回的结果为空，数据被防火墙或者是IDS过滤
 UnFiltered	 数据有到达主机，但是不能识别端口的当前状态
 Open|Filtered	 端口没有返回值，主要发生在UDP、IP、FIN、NULL和Xmas扫描中
Closed|Filtered 只发生在IP ID idle扫描

输出格式：

输出格式	名称	功能
-oA	所有	可检索的、常规的和XML文件
-oG	可检索的	可检索格式
-oX	XML	XML格式
-oN	常规	常规格式，适合人阅读
3. 基本扫描

　　在这里，我开始对上一篇搭建的Ubuntu虚拟主机进行基本扫描，只进行简单的扫描，确定那些端口是开放的，使用-A选项（-A 选项扫描非常易于被发现，不适合在需要隐蔽条件下使用）。
　　# nmap -A 192.168.50.12
　　scan
　　从结果看，可以判定目标主机开放了TCP的80端口，运行了Apache server 2.2.22版本，目标操作系统为Ubuntu Linux 2.6.X|3.X。 此外，-A选项启用了traceroute命令，根据结果显示，距离目标主机只有一条路由。

4. 隐蔽扫描

　　网络扫描的过程包括发送特殊够早的数据包给目标主机和对返回的结果进行基于某种标准的检查。从扫描结果中，我们可以知道那些主机在线，运行了哪些服务以及这些服务的版本信息等。
　　在一个安全的网络中，我们有可能根据需要来对抗IDS的异常行为捕捉。发送数据包的数量和速度，流量是否异常等，防火墙一般都会标记。为减少被检测到的概率，我们可以采取一些措施。
　　控制时间。
　　nmap控制扫描时间选项：
　　

-T（0~5）： 控制扫描进度，避免被检测的最简单形式。0是最温和的，5是最激进的，只能在局域网中使用。
–max_hostgroup： 将扫描的主机数量限制在每次一个。
–max_retries： 一般不需要修改此选项，如果是紧急情况且不在意扫描过程中可能错过一个包含潜在漏洞的主机，可以将这个选项设为0.
max_parallelism 10： 一次仅允许10个探测请求。
scan_delay 两次探测之间停顿。
尝试几个选项：

# nmap -P0 -n -sS --max_hostgroup 1 --max_retries 0 --max_parallelism 10 192.168.50.0/24

　　从结果看，有两个主机在线，其中一个主机开放了80端口。


# 适用所有大小网络最好的 nmap 扫描策略

# 主机发现，生成存活主机列表
$ nmap -sn -T4 -oG Discovery.gnmap 192.168.56.0/24
$ grep "Status: Up" Discovery.gnmap | cut -f 2 -d ' ' > LiveHosts.txt

# 端口发现，发现大部分常用端口
# http://nmap.org/presentations/BHDC08/bhdc08-slides-fyodor.pdf
$ nmap -sS -T4 -Pn -oG TopTCP -iL LiveHosts.txt
$ nmap -sU -T4 -Pn -oN TopUDP -iL LiveHosts.txt
$ nmap -sS -T4 -Pn --top-ports 3674 -oG 3674 -iL LiveHosts.txt

# 端口发现，发现全部端口，但 UDP 端口的扫描会非常慢
$ nmap -sS -T4 -Pn -p 0-65535 -oN FullTCP -iL LiveHosts.txt
$ nmap -sU -T4 -Pn -p 0-65535 -oN FullUDP -iL LiveHosts.txt

# 显示 TCP\UDP 端口
$ grep "open" FullTCP|cut -f 1 -d ' ' | sort -nu | cut -f 1 -d


## TCP扫描类型
# SYN扫描

首先可以利用基本的SYN扫描方式探测其端口开放状态。

nmap -sS -T4 www.91ri.org

# FIN扫描 配合 ACK扫描 绕过防火墙

可以利用FIN扫描方式探测防火墙状态。FIN扫描方式用于识别端口是否关闭，收到RST回复说明该端口关闭，否则说明是open或filtered状态。
nmap -sF -T4 www.91ri.org

然后利用ACK扫描判断端口是否被过滤。针对ACK探测包，未被过滤的端口（无论打开、关闭）会回复RST包。
nmap -sA -T4 www.91ri.org

window扫描原理与ACK类似，发送ACK包探测目标端口，对回复的RST包中的Window size进行解析。在某些TCPIP协议栈实现中，关闭的端口在RST中会将Window size设置为0；而开放的端口将Window size设置成非0的值。
nmap -sW -p- -T4 www.91ri.org

## 定制探测包
Nmap提供–scanflags选项，用户可以对需要发送的TCP探测包的标志位进行完全的控制。可以使用数字或符号指定TCP标志位：URG, ACK, PSH,RST, SYN,and FIN。

例如，

nmap -sX -T4 –scanflags URGACKPSHRSTSYNFIN targetip

此命令设置全部的TCP标志位为1，可以用于某些特殊场景的探测。

另外使用–ip-options可以定制IP包的options字段。

使用-S指定虚假的IP地址，
-D指定一组诱骗IP地址（ME代表真实地址）。
-e指定发送探测包的网络接口，
-g（–source- port）指定源端口，
-f指定使用IP分片方式发送探测包，
--spoof-mac指定使用欺骗的MAC地址。
--ttl指定生存时间。
