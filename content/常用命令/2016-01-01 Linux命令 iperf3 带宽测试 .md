---
title: iperf3
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [iptables]
---
sudo apt install iperf3
perf的主要功能：
1）TCP方面
测试网络带宽
支持多线程，在客户端和服务端支持多重连接
报告MSS/MTU值的大小
支持TCP窗口值自定义并可通过套接字缓冲
2)UDP方面
可设置指定带宽的UDP数据流
可以测试网络抖动值、丢包数
支持多播 测试
支持多线程，在客户端和服务端支持多重连接
安装：
tar -xzvf iperf-3.1b3.tar.gz
cd iperf-3.1b3/
./configure
make
make install
应用实例：
1）测试TCP吞吐量 [带宽测试]
服务端：
`iperf3 -s`
客户端：
`iperf3 -c 192.168.17.142`

iperf默认运行时间10s，每隔1s输出一次传输状态，同时还可以看到每秒传输的数据量在50~80M之间（我的是虚拟机环境）
刚好与Bandwidth列的值对应起来，网卡的带宽平均速率维持在500Mbits/sec
# 改变iperf运行时间和输出频率：-t 和-i 参数来实现
`iperf3 -c 192.168.17.142 -t 20 -i 5`

# 模拟大量数据传输：-n指定传输的数据量
`iperf3 -c 192.168.17.142 -i 10 -n 5000000000`

# 模拟TCP一个特定文件发送数据：-F
`iperf3 -c 192.168.17.142 -F test.dbf -i 5 -t 40`

# 将结果输出都以MBytes/sec来显示： -f M
`iperf3 -c 192.168.17.142 -n 2000000000 -i 5 -f M`

# 多线程：-P
`iperf3 -c 192.168.17.142 -n 2000000000 -i 5 -f M -P 2`

# 测试UDP丢包和延迟
SUSE01:/soft # `iperf3 -c 192.168.17.142 -u -b 100M -f M -i 3`
