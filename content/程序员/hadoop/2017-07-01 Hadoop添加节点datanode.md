---
title: hadoop添加datanode
date: 2016-03-24T14:55:34+08:00
update: 2016-01-01
categories: [程序员]
tags:
---
配置新节点上的hosts
修改namenode节点上conf/slaves文件，增加新节点域名
在新节点上启动服务
[hadoop@slave4 hadoop-1.0.4]# ./bin/hadoop-daemon.sh start datanode
[hadoop@slave4 hadoop-1.0.4]# ./bin/hadoop-daemon.sh start tasktracker
复制代码

均衡block
这个会非常耗时
1) 如果不balance，那么cluster会把新的数据都存放在新的node上，这样会降低mapred的工作效率
2) 设置平衡阈值，默认是10%，值越低各节点越平衡，但消耗时间也更长
[hadoop@slave4 hadoop-1.0.4]# ./bin/start-balancer.sh -threshold 5
复制代码
3）设置balance的带宽，默认只有1M/s
<property>
<name>dfs.balance.bandwidthPerSec</name>
<value>1048576</value>
</property>
复制代码

注意：
1. 必须确保slave的firewall已关闭;
2. 确保新的slave的ip已经添加到master及其他slaves的/etc/hosts中，反之也要将master及其他slave的ip添加到新的slave的/etc/hosts中
