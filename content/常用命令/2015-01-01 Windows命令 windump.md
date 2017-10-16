---
title: Windump的详细用法
date: 2016-01-12T15:30:01+08:00
update: 2016-09-27 16:50:44
categories: [linux_base]
tags: [windump]
---
Npcap[nmap/npcap: Nmap Project's packet sniffing library for Windows, based on WinPcap/Libpcap improved with NDIS 6 and LWF.](https://github.com/nmap/npcap)

"WinDump 3.9.5.exe" -D
"WinDump 3.9.5.exe" -i 1 -s 1024 -B 4096-w windump.pcap

REM -v	输出一个稍微详细的信息，例如在ip包中可以包括ttl和服务类型的信息；
REM -vv	输出详细的报文信息；
REM -c	在收到指定的包的数目后，Windump就会停止；
REM -T	将监听到的包直接解释为指定的类型的报文，常见的类型有rpc	（远程过程调用）和snmp（简单网络管理协议；）

REM -n	不把网络地址转换成名字
REM –D  列出本机可供抓包的全部接口 -D
REM -i	指定监听的网络接口；-i 1
REM -r	从指定的文件中读取包(这些包一般通过-w选项产生)；-r windump.pcap
REM -w	直接将包写入文件中，并不分析和打印出来； -w windump.pcap
REM -s  不使用默认的68个字节，更改从每个包中获取数据的字节数量 -s 1024  -S 0 后可以抓到完整的数据包
REM （SunOS系统实际最小为96）。对于IP，ICMP，TCP和UDP包68个字节已足够，但是对命名服务和NFS包，他们的协议会被截断（见下面）。包被截断是因为在使用参数“[│proto]”输出时指定受限制的快照，proto是被截断协议层的名称。注意如果使用大的快照会增加处理包的时间，并且明显地减少包的缓存数量。也许会导致包的丢失。你应该将snaplen 设置成你感兴趣协议的最小数。当snaplen 为0时接收整个包。
REM -B 以千字节为单位设置驱动缓存。默认缓存为1M（即1000） -B 4096
REM 如果在获取数据包时有数据丢失，建议使用该参数增大核心缓存大小，因为驱动缓存大小对数据捕获性能有很大影响。

REM -f 不用符号而用数字方式输出外部英特网地址 -F 使用文件作为过滤表达式的输入。命令行的其他部分会被忽略。
REM -i 在接口上监听。如果没有指定，TCPDUMP将搜索系统接口列表中最小，被配置激活的接口（LOOPBACK接口除外）。可用最先匹配替换这种关系。在 WINDOWS中接口可以是网卡的名称，或是网卡的号码（-D参数可显示该号码）。内核为2。2或其后的LINUX系统，参数“ANY”可以获取所有接口的数据。应注意的是在混乱模式下不能使用“ANY”参数。
REM -l 标准输出行缓存。如果你想在捕获数据时查看的话，这个参数很有用。
REM 例如：“tcpdump -l │ tee dat” or “tcpdump -l > dat & tail -f dat”.” n 不要将地址（如主机地址，端口号）转换为名称 -N 不要打印主机名称的域名限定。如：如果你使用该参数，TCPDUMP会输出“NIC”而不是“NIC。DDN。MIL”。
REM -m 从文件模块中载入SMI MIB 模块定义。这个选项可以为TCPDUMP载入多个MIB模块
REM -O 不要运行包匹配代码优化器。只有在你怀疑优化器有问题时可以使用这个参数。
REM -p 不要让接口处于“混乱”模式。注意接口可能由于其他原因处于“混乱”模式；因此“-p”不能用作以太网络主机或广播的缩写。
REM -q 快速（安静？）输出。打印较少的协议信息，因此输出行更短。
REM -r 从文件中读取包（与参数据-W一起使用）。如果文件是“-”就使用标准输入。
REM -T 根据表达式将选中的数据包表达成指定的类型。当前已有的类型有CNFP（Cisco的网络流量协议），rpc（远端程序调用），rtp（实时程序协议）， rtcp（实时程序控制协议），snmp（简单网络管理协议），vat（可视单频工具），和wb（分布式白板）。 -R 假设ESP/AH包遵守旧的说明（RFC1825到RFC1829）。如果该参数被指定，TCPDUMP不打输出域。因为在ESP/AH说明中没有协议版本，TCPDUMP就无法推断出其版本号。 -S 输出绝对TCP序列号，而不是相对号。
REM -t 每个捕获行不要显示时间戳。 -tt 每个捕获行显示非格式化的时间时间戳。
REM -v 详细输出。例如，显示生存时间TTL，标识符，总长度和IP数据包的选项。也进行额外的包完整性较验，如验证IP和ICMP的头标较验值。
REM -vv 更为详细的输出。例如，显示NFS中继包中的其他域。
REM -vvv 很详细的输出。如，完全输出TELNET SB… SE选项。带-X参数的TELNET，打印并以十六进制输出。
REM -w 不对原始数据包解析打印而是转到文件中去。以后可用-r选项打印。当文件名为“-”表示标准输出。 -x 以十六进制（去除链路层头标）输出每个数据包。输出整个包的小部分或snaplen 个字节。
REM -X 输出十六进制同时，输出ASCII码。如果-x也被设置，数据包会以十六制/ASCII码显示。这对于分析新协议非常方便。如果-x也没有设置，一些数据包的部分会以十六制/ASCII码显示。 Win32特殊扩展
REM -D 显示系统上可用的网卡列表。该参数将返回每块网卡的号码，名称和描述。

REM 1、windump –D  列出本机可供抓包的全部接口。

	REM windump –i 2(网卡序号) 指定要抓第二块网卡的包

REM 2、windump –n 不解析主机名，直接显示抓包的主机IP地址。

REM 3、windump –n host 192.168.1.2  只抓关于192.168.1.2主机的包（不管包的方向）。

REM 4、windump –n host 192.168.1.2 and udp port 514 只抓关于主机192.168.1.2上udp协议端口为514的包。

REM 同理，我也可以抓所有tcp协议23端口的包，命令如下：

REM windump –n host 192.168.1.2 and tcp port 23

REM 或者，我只抓udp 514端口的包，不管ip是多少，命令如下：

REM windump –n udp port 514

REM 5、windump –n net 133.160 抓133.160网段的包，不管包的方向。

REM 同理，我也可以抓所有133.160网段的且tcp端口为3389的包，命令如下：

REM windump –n net 133.160 and tcp port 3389

REM 6、windump –n host ! 133.191.1.1 抓所有非133.191.1.1有关的包。

REM 同理，我要抓除了133.191.1.1之外的所有机器的tcp端口为3389的包，命令如下：

REM windump –n host ! 133.191.1.1 and tcp port 3389

REM 7、windump –n dst host 133.191.1.1 抓所有发送到133.191.1.1的包。

REM 同理，可以用and 或or参数，如：

REM windump –n dst host 133.191.1.1 ort src host 101.1.1.1
