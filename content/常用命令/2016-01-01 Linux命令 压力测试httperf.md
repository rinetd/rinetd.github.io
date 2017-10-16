---
title: Linux命令 httperf
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [httperf]
---
一、工具下载&&安装
软件获取

ftp://ftp.hpl.hp.com/pub/httperf/
这里使用的是如下的版本
ftp://ftp.hpl.hp.com/pub/httperf/httperf-0.9.0.tar.gz
软件安装
# ls httperf-0.9.0.tar.gz  
httperf-0.9.0.tar.gz
#tar zxvf httperf-0.9.0.tar.gz  && cd httperf-0.9.0 &&./configure  --prefix=/usr/local/tools && make && make install

二、开始压力测试

[root@localhost bin]# ./`httperf --client=0/1 --server www.ethnicity.cn --port80 --uri /index.html --rate 100 --num-conn 300 --num-call 5 --timeout 5`

--client=I/N 指定当前客户端I，是N个客户端中的第几个。用于多个客户端发请求，希望确保每个客户端发的请求不是完全一致。一般不用指定

--server 所测试的的网站名（主机名，域名或者ip地址）

--uri 指定的下载文件

--rate  每秒发送的请求

--num-conn 连接的总数

--num-call 每个连接发送的请求数目

--timeout 超时时间

httperf --timeout=5 --client=0/1--server=www.ethnicity.cn --port=80 --uri=/index.html --rate=100 --send-buffer=4096--recv-buffer=16384 --num-conns=300 --num-calls=5
Maximum connect burst length: 13

最大并发连接数：13

Total: connections 300 requests 1475 replies 1475test-duration 6.204 s

一共300个连接，1475个请求，应答了1475个，测试耗时：6.204秒

Connection rate: 48.4 conn/s (20.7 ms/conn, <=189concurrent connections)

连接速率：48.4个每秒（每个连接耗时20.7 ms, 小于指定的300个并发连接）

Connection time [ms]: min 663.4 avg 1937.6 max 3808.4median 1720.5 stddev 964.7

连接时间（微秒）：最小663.4，平均1937.6，最大3808.4，中位数 1720.5， 标准偏差964.7

Connection time [ms]: connect 1098.4

连接时间（微秒）：连接1098.4

Connection length [replies/conn]: 5.000

连接长度（应答/连接）：5.000

Request rate: 237.7 req/s (4.2 ms/req)

请求速率：237.7(pqs)，每个请求4.2 ms

Request size : 79.0

连接长度（应答/连接）： 79.0

Reply rate [replies/s]: min 268.8 avg 268.8 max 268.8stddev 0.0 (1 samples)

响应速率（响应个数/秒）：最小268.8， 平均268.8，最大268.8，标准偏差 0.0（一个例样）

Reply time [ms]: response 80.7 transfer 87.2

响应时间（微妙）：响应80.7，传输87.2

Reply size : header 283.0 content 21895.0 footer 0.0(total 22178.0)

应包长度（字节）：响应头283.0 内容：21895.0 响应末端 -0.0（总共22178.0）

Reply status: 1xx=0 2xx=1475 3xx=0 4xx=0 5xx=0

响应包状态： 2xx 有1475个，其他没有

CPU time [s]: user 0.45 system 5.48 (user 7.3% system88.3% total 95.6%)

CPU时间（秒）: 用户0.45 系统5.48（用户占了7.3% 系统占88.3% 总共95.6%）

Net I/O: 5167.4 KB/s (42.3*10^6 bps)

网络I/O：5167.4 KB/s

Errors: total 5 client-timo 5 socket-timo 0 connrefused 0connreset 0

错误：总数5 客户端超时5 套接字超时0 连接拒绝0 连接重置0

Errors: fd-unavail 0 addrunavail 0 ftab-full 0 other 0

错误：fd不正确0 地址不正确0 ftab占满0其他0
