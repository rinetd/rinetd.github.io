---
title: Linux网络命令
date: 2016-01-07T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags:
---

实时监控网络状态：

`watch -n 1 netstat -ant` 


![网络状态迁移](http://img.blog.csdn.net/20130724204201656?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2VudGluZ2hl/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
![网络状态转换](http://img.blog.csdn.net/20130724204539609?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2VudGluZ2hl/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

CLOSED 	没有使用这个套接字[netstat 无法显示closed状态]
LISTEN 	套接字正在监听连接[调用listen后]
SYN_SENT 	套接字正在试图主动建立连接[发送SYN后还没有收到ACK]
SYN_RECEIVED 	正在处于连接的初始同步状态[收到对方的SYN，但还没收到自己发过去的SYN的ACK]
ESTABLISHED 	连接已建立
CLOSE_WAIT 	远程套接字已经关闭：正在等待关闭这个套接字[被动关闭的一方收到FIN]
FIN_WAIT_1 	套接字已关闭，正在关闭连接[发送FIN，没有收到ACK也没有收到FIN]
CLOSING 	套接字已关闭，远程套接字正在关闭，暂时挂起关闭确认[在FIN_WAIT_1状态下收到被动方的FIN]
LAST_ACK 	远程套接字已关闭，正在等待本地套接字的关闭确认[被动方在CLOSE_WAIT状态下发送FIN]
FIN_WAIT_2 	套接字已关闭，正在等待远程套接字关闭[在FIN_WAIT_1状态下收到发过去FIN对应的ACK]
TIME_WAIT 	这个套接字已经关闭，正在等待远程套接字的关闭传送[FIN、ACK、FIN、ACK都完毕，这是主动方的最后一个状态，在过了2MSL时间后变为CLOSED状态]

Linux 基础网络命令列表

我在计算机网络课程上使用 FreeBSD，不过这些 UNIX 命令应该也能在 Linux 上同样工作。
连通性

    ping <host>：发送 ICMP echo 消息（一个包）到主机。这可能会不停地发送直到你按下 Control-C。Ping 的通意味着一个包从你的机器通过 ICMP 发送出去，并在 IP 层回显。Ping 告诉你另一个主机是否在运行。
    telnet <host> [port]：与主机在指定的端口通信。默认的 telnet 端口是 23。按 Control-] 以退出 telnet。其它一些常用的端口是：
        7 —— echo 端口
        25 —— SMTP，用于发送邮件
        79 —— Finger (LCTT 译注：维基百科 - Finger protocal，不过举例 Finger 恐怕不合时宜，倒不如试试 80？），提供该网络下其它用户的信息。

ARP

ARP 用于将 IP 地址转换为以太网地址。root 用户可以添加和删除 ARP 记录。当 ARP 记录被污染或者错误时，删除它们会有用。root 显式添加的 ARP 记录是永久的 —— 代理设置的也是。ARP 表保存在内核中，动态地被操作。ARP 记录会被缓存，通常在 20 分钟后失效并被删除。

    arp -a：打印 ARP 表。
    arp -s <ip_address> <mac_address> [pub]：添加一条记录到表中。
    arp -a -d：删除 ARP 表中的所有记录。

路由

    netstat -r：打印路由表。路由表保存在内核中，用于 IP 层把包路由到非本地网络。
    route add：route 命令用于向路由表添加静态（手动指定而非动态）路由路径。所有从该 PC 到那个 IP/子网的流量都会经由指定的网关 IP。它也可以用来设置一个默认路由。例如，在 IP/子网处使用 0.0.0.0，就可以发送所有包到特定的网关。
    routed：控制动态路由的 BSD 守护程序。开机时启动。它运行 RIP 路由协议。只有 root 用户可用。没有 root 权限你不能运行它。
    gated：gated 是另一个使用 RIP 协议的路由守护进程。它同时支持 OSPF、EGP 和 RIP 协议。只有 root 用户可用。
    traceroute：用于跟踪 IP 包的路由。它每次发送包时都把跳数加 1，从而使得从源地址到目的地之间的所有网关都会返回消息。
    netstat -rnf inet：显示 IPv4 的路由表。
    sysctl net.inet.ip.forwarding=1：启用包转发（把主机变为路由器）。
    route add|delete [-net|-host] <destination> <gateway>：（如 route add 192.168.20.0/24 192.168.30.4）添加一条路由。
    route flush：删除所有路由。
    route add -net 0.0.0.0 192.168.10.2：添加一条默认路由。
    routed -Pripv2 -Pno_rdisc -d [-s|-q]：运行 routed 守护进程，使用 RIPv2 协议，不启用 ICMP 自动发现，在前台运行，供给模式或安静模式。
    route add 224.0.0.0/4 127.0.0.1：为本地地址定义多播路由。（LCTT 译注：原文存疑）
    rtquery -n <host>（LCTT 译注：增加了 host 参数）：查询指定主机上的 RIP 守护进程（手动更新路由表）。

其它

    nslookup：向 DNS 服务器查询，将 IP 转为名称，或反之。例如，nslookup facebook.com 会给出 facebook.com 的 IP。
    ftp <host> [port]（LCTT 译注：原文中 water 应是笔误）：传输文件到指定主机。通常可以使用 登录名 "anonymous" , 密码 "guest" 来登录。
    rlogin -l <host>（LCTT 译注：添加了 host 参数）：使用类似 telnet 的虚拟终端登录到主机。

重要文件

    /etc/hosts：域名到 IP 地址的映射。
    /etc/networks：网络名称到 IP 地址的映射。
    /etc/protocols：协议名称到协议编号的映射。
    /etc/services：TCP/UDP 服务名称到端口号的映射。

工具和网络性能分析

    ifconfig <interface> <address> [up]：启动接口。
    ifconfig <interface> [down|delete]：停止接口。
    ethereal &：在后台打开 ethereal 而非前台。
    tcpdump -i -vvv：抓取和分析包的工具。
    netstat -w [seconds] -I [interface]：显示网络设置和统计信息。
    udpmt -p [port] -s [bytes] target_host：发送 UDP 流量。
    udptarget -p [port]：接收 UDP 流量。
    tcpmt -p [port] -s [bytes] target_host：发送 TCP 流量。
    tcptarget -p [port]：接收 TCP 流量。

交换机

    ifconfig sl0 srcIP dstIP：配置一个串行接口（在此前先执行 slattach -l /dev/ttyd0，此后执行 sysctl net.inet.ip.forwarding=1）
    telnet 192.168.0.254：从子网中的一台主机访问交换机。
    sh ru 或 show running-configuration：查看当前配置。
    configure terminal：进入配置模式。
    exit：退出当前模式。（LCTT 译注：原文存疑）

VLAN

    vlan n：创建一个 ID 为 n 的 VLAN。
    no vlan N：删除 ID 为 n 的 VLAN。
    untagged Y：添加端口 Y 到 VLAN n。
    ifconfig vlan0 create：创建 vlan0 接口。
    ifconfig vlan0 vlan_ID vlandev em0：把 em0 加入到 vlan0 接口（LCTT 译注：原文存疑），并设置标记为 ID。
    ifconfig vlan0 [up]：启用虚拟接口。
    tagged Y：为当前 VLAN 的端口 Y 添加标记帧支持。

UDP/TCP

    socklab udp：使用 UDP 协议运行 socklab。
    sock：创建一个 UDP 套接字，等效于输入 sock udp 和 bind。
    sendto <Socket ID> <hostname> <port #>：发送数据包。
    recvfrom <Socket ID> <byte #>：从套接字接收数据。
    socklab tcp：使用 TCP 协议运行 socklab。
    passive：创建一个被动模式的套接字，等效于 socklab，sock tcp，bind，listen。
    accept：接受进来的连接（可以在发起进来的连接之前或之后执行）。
    connect <hostname> <port #>：等效于 socklab，sock tcp，bind，connect。
    close：关闭连接。
    read <byte #>：从套接字中读取 n 字节。
    write：（例如，write ciao、write #10）向套接字写入 "ciao" 或 10 个字节。

NAT/防火墙

    rm /etc/resolv.conf：禁止地址解析，保证你的过滤和防火墙规则正确工作。
    ipnat -f file_name：将过滤规则写入文件。
    ipnat -l：显示活动的规则列表。
    ipnat -C -F：重新初始化规则表。
    map em0 192.168.1.0/24 -> 195.221.227.57/32 em0：将 IP 地址映射到接口。
    map em0 192.168.1.0/24 -> 195.221.227.57/32 portmap tcp/udp 20000:50000：带端口号的映射。
    ipf -f file_name：将过滤规则写入文件。
    ipf -F -a：重置规则表。
    ipfstat -I：当与 -s 选项合用时列出活动的状态条目（LCTT 译注：原文存疑）。
