---
title: Linux命令 Iproute2
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ip]
---

[iproute2学习笔记](http://www.cnblogs.com/popsuper1982/p/3800532.html)

一、替代arp, ifconfig, route等命令
显示网卡和IP地址

root@openstack:~\# ip link list
1: lo: &lt;LOOPBACK,UP,LOWER\_UP&gt; mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: &lt;BROADCAST,MULTICAST,UP,LOWER\_UP&gt; mtu 1500 qdisc pfifo\_fast state UP qlen 1000
    link/ether 64:31:50:43:57:fa brd ff:ff:ff:ff:ff:ff
4: br-ex: &lt;BROADCAST,UP,LOWER\_UP&gt; mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 64:31:50:43:57:fa brd ff:ff:ff:ff:ff:ff
7: br-int: &lt;BROADCAST,UP,LOWER\_UP&gt; mtu 1500 qdisc noqueue state UNKNOWN
    link/ether a2:99:53:93:1b:47 brd ff:ff:ff:ff:ff:ff
10: virbr0: &lt;BROADCAST,MULTICAST,UP,LOWER\_UP&gt; mtu 1500 qdisc noqueue state UP
    link/ether fe:54:00:68:e0:04 brd ff:ff:ff:ff:ff:ff
35: br-tun: &lt;BROADCAST,UP,LOWER\_UP&gt; mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 42:9b:ec:6c:f6:41 brd ff:ff:ff:ff:ff:ff
71: qbrf38a666d-f5: &lt;BROADCAST,MULTICAST,UP,LOWER\_UP&gt; mtu 1500 qdisc noqueue state UP
    link/ether 96:e0:4d:68:c2:6b brd ff:ff:ff:ff:ff:ff
72: qvof38a666d-f5: &lt;BROADCAST,MULTICAST,PROMISC,UP,LOWER\_UP&gt; mtu 1500 qdisc pfifo\_fast state UP qlen 1000
    link/ether 66:9e:9a:e1:25:37 brd ff:ff:ff:ff:ff:ff
73: qvbf38a666d-f5: &lt;BROADCAST,MULTICAST,PROMISC,UP,LOWER\_UP&gt; mtu 1500 qdisc pfifo\_fast master qbrf38a666d-f5 state UP qlen 1000
    link/ether 96:e0:4d:68:c2:6b brd ff:ff:ff:ff:ff:ff
74: tapf38a666d-f5: &lt;BROADCAST,MULTICAST,UP,LOWER\_UP&gt; mtu 1500 qdisc pfifo\_fast master qbrf38a666d-f5 state UNKNOWN qlen 500
    link/ether fe:16:3e:3d:68:e4 brd ff:ff:ff:ff:ff:ff
root@openstack:~\# ip address show
1: lo: &lt;LOOPBACK,UP,LOWER\_UP&gt; mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid\_lft forever preferred\_lft forever
    inet6 ::1/128 scope host
       valid\_lft forever preferred\_lft forever
2: eth0: &lt;BROADCAST,MULTICAST,UP,LOWER\_UP&gt; mtu 1500 qdisc pfifo\_fast state UP qlen 1000
    link/ether 64:31:50:43:57:fa brd ff:ff:ff:ff:ff:ff
    inet 16.158.165.152/22 brd 16.158.167.255 scope global eth0
       valid\_lft forever preferred\_lft forever
    inet6 fe80::6631:50ff:fe43:57fa/64 scope link
       valid\_lft forever preferred\_lft forever


显示路由

root@openstack:~\# ip route show
default via 16.158.164.1 dev br-ex
16.158.164.0/22 dev br-ex  proto kernel  scope link  src 16.158.165.102
16.158.164.0/22 dev eth0  proto kernel  scope link  src 16.158.165.152
192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1

显示ARP

root@openstack:~\# ip neigh show
16.158.165.47 dev br-ex lladdr e4:11:5b:53:62:00 STALE
192.168.122.61 dev virbr0 lladdr 52:54:00:68:e0:04 STALE
16.158.164.1 dev br-ex lladdr 00:00:5e:00:01:15 DELAY
16.158.166.177 dev br-ex lladdr 00:26:99:d0:12:a9 STALE
16.158.164.3 dev br-ex lladdr 20:fd:f1:e4:c9:e8 STALE
16.158.165.87 dev br-ex lladdr 70:5a:b6:b3:dd:a5 STALE
16.158.166.150 dev br-ex  FAILED
16.158.164.2 dev br-ex lladdr 20:fd:f1:e4:c9:b1 STALE

二、Rules: Routing Policy
=========================

Routing Table其实有三个：local, main, default

root@openstack:~\# ip rule list
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

原来的route命令修改的是main和local表

root@openstack:~\# ip route list table local
broadcast 16.158.164.0 dev br-ex  proto kernel  scope link  src 16.158.165.102
broadcast 16.158.164.0 dev eth0  proto kernel  scope link  src 16.158.165.152
local 16.158.165.102 dev br-ex  proto kernel  scope host  src 16.158.165.102
local 16.158.165.152 dev eth0  proto kernel  scope host  src 16.158.165.152
broadcast 16.158.167.255 dev br-ex  proto kernel  scope link  src 16.158.165.102
broadcast 16.158.167.255 dev eth0  proto kernel  scope link  src 16.158.165.152
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0.1
broadcast 192.168.122.0 dev virbr0  proto kernel  scope link  src 192.168.122.1
local 192.168.122.1 dev virbr0  proto kernel  scope host  src 192.168.122.1
broadcast 192.168.122.255 dev virbr0  proto kernel  scope link  src 192.168.122.1

root@openstack:~\# ip route list table main
default via 16.158.164.1 dev br-ex
16.158.164.0/22 dev br-ex  proto kernel  scope link  src 16.158.165.102
16.158.164.0/22 dev eth0  proto kernel  scope link  src 16.158.165.152
192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1
root@openstack:~\# ip route list table default

Simple source policy routing
----------------------------

我们来考虑下面的场景，我家里接了两个外网，一个到网通(用的光纤)，一个到电信(电话拨号)，这两个Modem都连到我的NAT Router上，我把房子出租出去，有很多的室友，其中有一个室友仅仅访问Email，因而想少付费，我想让他仅仅使用电信的线，那么我应该如何配置我的NAT Router呢？

[<img src="http://images.cnitblog.com/blog/635909/201406/210748159111054.png" title="image" alt="image" width="625" height="573" />](http://images.cnitblog.com/blog/635909/201406/210748154895225.png)

原来的配置是这样的

    [ahu@home ahu]$ ip route list table main
    195.96.98.253 dev ppp2  proto kernel  scope link  src 212.64.78.148
    212.64.94.1 dev ppp0  proto kernel  scope link  src 212.64.94.251
    10.0.0.0/8 dev eth0  proto kernel  scope link  src 10.0.0.1
    127.0.0.0/8 dev lo  scope link
    default via 212.64.94.1 dev ppp0

默认都走快的路由

下面我添加一个Table，名字叫John

    # echo 200 John >> /etc/iproute2/rt_tables
    # ip rule add from 10.0.0.10 table John
    # ip rule ls
    0:  from all lookup local
    32765:  from 10.0.0.10 lookup John
    32766:  from all lookup main
    32767:  from all lookup default

并设定规则从10.0.0.10来的包都查看John这个路由表

在John路由表中添加规则

    # ip route add default via 195.96.98.253 dev ppp2 table John
    # ip route flush cache

默认的路由走慢的，达到了我的需求。

Routing for multiple uplinks/providers
--------------------------------------

[<img src="http://images.cnitblog.com/blog/635909/201406/210748164573154.png" title="image" alt="image" width="598" height="302" />](http://images.cnitblog.com/blog/635909/201406/210748162078610.png)

 

$IF1是第一个Interface，它的IP是$IP1

$IF2是第二个Interface，它的IP是$IP2

$P1是Provider1的Gateway，Provider1的网络$P1\_NET

$P2是Provider2的Gateway，Provider2的网络$P2\_NET

我们要做的第一个事情是Split access.

创建两个routing table, T1和T2，添加到/etc/iproute2/rt\_tables.

         ip route add $P1_NET dev $IF1 src $IP1 table T1
          ip route add default via $P1 table T1
          ip route add $P2_NET dev $IF2 src $IP2 table T2
          ip route add default via $P2 table T2

在T1中设定，如果要到达$P1\_NET，需要从网卡$IF1出去

在T2中设定，如果要到达$P2\_NET，需要从网卡$IF2出去

设置main table

           ip route add $P1_NET dev $IF1 src $IP1
            ip route add $P2_NET dev $IF2 src $IP2

           ip route add default via $P1

     

添加Rules

           ip rule add from $IP1 table T1
            ip rule add from $IP2 table T2

 

第二件事情是Load balancing

default gateway不能总是一个

    ip route add default scope global nexthop via $P1 dev $IF1 weight 1 nexthop via $P2 dev $IF2 weight 1

     

GRE tunneling
=============

[<img src="http://images.cnitblog.com/blog/635909/201406/210748170827511.png" title="image" alt="image" width="258" height="533" />](http://images.cnitblog.com/blog/635909/201406/210748167703184.png)

在Router A上做如下配置：

    ip tunnel add netb mode gre remote 172.19.20.21 local 172.16.17.18 ttl 255
    ip link set netb up
    ip addr add 10.0.1.1 dev netb
    ip route add 10.0.2.0/24 dev netb

创建一个名为netb的tunnel，模式是GRE，远端是172.19.20.21，此端是172.16.17.18

所有向10.0.2.0的包都通过这个Tunnel转发

在Router B上做如下配置：

    ip tunnel add neta mode gre remote 172.16.17.18 local 172.19.20.21 ttl 255
    ip link set neta up
    ip addr add 10.0.2.1 dev neta
    ip route add 10.0.1.0/24 dev neta

Queueing Disciplines for Bandwidth Management
=============================================

With queueing we determine the way in which data is *SENT*. It is important to realise that we can only shape data that we transmit.

With the way the Internet works, we have no direct control of what people send us.

我们只能控制发送，无法控制接收，所以发送叫shaping，我们可以控制我们的输出流的形态，接收只能设置policy，拒绝或者接受。

Simple, classless Queueing Disciplines
--------------------------------------

### pfifo\_fast

First In, First Out

说是先入先出，实际上一个Queue包含三个Band，每个Band都是先入先出，Band 0优先级最高，它不处理完毕，Band 1不处理，其次是Band 2

在IP头里面有TOS (Type of service)，有一个priomap，是一个映射，将不同的TOS映射给不同的Bind。

[<img src="http://images.cnitblog.com/blog/635909/201406/210748177542585.png" title="image" alt="image" width="433" height="301" />](http://images.cnitblog.com/blog/635909/201406/210748173791771.png)

[<img src="http://images.cnitblog.com/blog/635909/201406/210748183171456.png" title="image" alt="image" width="506" height="338" />](http://images.cnitblog.com/blog/635909/201406/210748180511142.png)

root@openstack:~\# tc qdisc show dev eth0
qdisc pfifo\_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

txqueuelen
The length of this queue is gleaned from the interface configuration, which you can see and set with ifconfig and ip.

### Token Bucket Filter

Token按照一定的速度来，每个Token都带走一个Packet，当Packet比Token快的时候，会保证按照Token的速度发送，不至于发送太快。

当Packet的速度比Token慢的时候，Token会累积，但是不会无限累积，累积到Bucket大小为止。如果累积的太多了，忽然来了大量的数据，导致瞬时间有大量的包发送。有了Bucket限制，即便积累满了Bucket，大量数据来的时候，最多带走所有的Bucket的Token，然后又按照Token到来的速度慢慢发送了。

limit or latency
Limit is the number of bytes that can be queued waiting for tokens to become available.

burst/buffer/maxburst
Size of the bucket, in bytes.

rate
The speedknob.

peakrate
If tokens are available, and packets arrive, they are sent out immediately by default.
        That may not be what you want, especially if you have a large bucket.
        The peakrate can be used to specify how quickly the bucket is allowed to be depleted.

    # tc qdisc add dev ppp0 root tbf rate 220kbit latency 50ms burst 1540

### Stochastic Fairness Queueing

随机公平队列

A TCP/IP flow can be uniquely identified by the following parameters within a certain time period:
Source and Destination IP address
Source and Destination Port
Layer 4 Protocol (TCP/UDP/ICMP)

有很多的FIFO的队列，TCP Session或者UDP stream会被分配到某个队列。包会RoundRobin的从各个队列中取出发送。

这样不会一个Session占据所有的流量。

但不是每一个Session都有一个队列，而是有一个Hash算法，将大量的Session分配到有限的队列中。

这样两个Session会共享一个队列，也有可能互相影响。

Hash函数会经常改变，从而session不会总是相互影响。

perturb
Reconfigure hashing once this many seconds.

quantum
Amount of bytes a stream is allowed to dequeue before the next queue gets a turn.

limit
The total number of packets that will be queued by this SFQ

    # tc qdisc add dev ppp0 root sfq perturb 10
    # tc -s -d qdisc ls
    qdisc sfq 800c: dev ppp0 quantum 1514b limit 128p flows 128/1024 perturb 10sec
     Sent 4812 bytes 62 pkts (dropped 0, overlimits 0)

The number 800c: is the automatically assigned handle number, limit means that 128 packets can wait in this queue. There are 1024 hashbuckets available for accounting, of which 128 can be active at a time (no more packets fit in the queue!) Once every 10 seconds, the hashes are reconfigured.

Classful Queueing Disciplines
-----------------------------

When traffic enters a classful qdisc, The filters attached to that qdisc then return with a decision, and the qdisc uses this to enqueue the packet into one of the classes. Each subclass may try other filters to see if further instructions apply. If not, the class enqueues the packet to the qdisc it contains.

#### The qdisc family: roots, handles, siblings and parents:

Each interface has one egress 'root qdisc'.

Each qdisc and class is assigned a handle, which can be used by later configuration statements to refer to that qdisc.

The handles of these qdiscs consist of two parts, a major number and a minor number : &lt;major&gt;:&lt;minor&gt;.

### The PRIO qdisc

它和FIFO Fast很类似，也分多个Band，但是它的每个Band其实是一个Class，而且数目可以改变。默认是三个Band。

每一个Band也不一定是FIFO，而是任何类型的qdisc.

默认也是根据TOS来决定去那个Class，Band是0-2，而Class是1-3.

当然也可以使用filter来决定去哪个Class

ands
Number of bands to create. Each band is in fact a class. If you change this number, you must also change:

priomap
If you do not provide tc filters to classify traffic, the PRIO qdisc looks at the TC\_PRIO priority to decide how to enqueue traffic.

[<img src="http://images.cnitblog.com/blog/635909/201406/210748188178542.png" title="image" alt="image" width="515" height="240" />](http://images.cnitblog.com/blog/635909/201406/210748185518228.png)

    # tc qdisc add dev eth0 root handle 1: prio
    ## This *instantly* creates classes 1:1, 1:2, 1:3

    # tc qdisc add dev eth0 parent 1:1 handle 10: sfq
    # tc qdisc add dev eth0 parent 1:2 handle 20: tbf rate 20kbit buffer 1600 limit 3000
    # tc qdisc add dev eth0 parent 1:3 handle 30: sfq   

    # tc -s qdisc ls dev eth0
    qdisc sfq 30: quantum 1514b
     Sent 0 bytes 0 pkts (dropped 0, overlimits 0)

     qdisc tbf 20: rate 20Kbit burst 1599b lat 667.6ms
     Sent 0 bytes 0 pkts (dropped 0, overlimits 0)

     qdisc sfq 10: quantum 1514b
     Sent 132 bytes 2 pkts (dropped 0, overlimits 0)

     qdisc prio 1: bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
     Sent 174 bytes 3 pkts (dropped 0, overlimits 0)

### Hierarchical Token Bucket

    # tc qdisc add dev eth0 root handle 1: htb default 30

    # tc class add dev eth0 parent 1: classid 1:1 htb rate 6mbit burst 15k

    # tc class add dev eth0 parent 1:1 classid 1:10 htb rate 5mbit burst 15k
    # tc class add dev eth0 parent 1:1 classid 1:20 htb rate 3mbit ceil 6mbit burst 15k
    # tc class add dev eth0 parent 1:1 classid 1:30 htb rate 1kbit ceil 6mbit burst 15k

The author then recommends SFQ for beneath these classes:

    # tc qdisc add dev eth0 parent 1:10 handle 10: sfq perturb 10
    # tc qdisc add dev eth0 parent 1:20 handle 20: sfq perturb 10
    # tc qdisc add dev eth0 parent 1:30 handle 30: sfq perturb 10

Add the filters which direct traffic to the right classes:

    # U32="tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32"
    # $U32 match ip dport 80 0xffff flowid 1:10
    # $U32 match ip sport 25 0xffff flowid 1:20

HTB certainly looks wonderful - if 10: and 20: both have their guaranteed bandwidth, and more is left to divide, they borrow in a 5:3 ratio, just as you would expect.

Unclassified traffic gets routed to 30:, which has little bandwidth of its own but can borrow everything that is left over.

A fundamental part of the HTB qdisc is the borrowing mechanism. Children classes borrow tokens from their parents once they have exceeded [`rate`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-rate). A child class will continue to attempt to borrow until it reaches [`ceil`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-ceil), at which point it will begin to queue packets for transmission until more tokens/ctokens are available. As there are only two primary types of classes which can be created with HTB the following table and diagram identify the various possible states and the behaviour of the borrowing mechanisms.

**Table 2. HTB class states and potential actions taken**

<table>
<colgroup>
<col width="25%" />
<col width="25%" />
<col width="25%" />
<col width="25%" />
</colgroup>
<tbody>
<tr class="odd">
<td align="left"><p><strong>type of class</strong></p></td>
<td align="left"><p><strong>class state</strong></p></td>
<td align="left"><p><strong>HTB internal state</strong></p></td>
<td align="left"><p><strong>action taken</strong></p></td>
</tr>
<tr class="even">
<td align="left"><p>leaf</p></td>
<td align="left"><p>&lt; <code>rate</code></p></td>
<td align="left"><p><code>HTB_CAN_SEND</code></p></td>
<td align="left"><p>Leaf class will dequeue queued bytes up to available tokens (no more than burst packets)</p></td>
</tr>
<tr class="odd">
<td align="left"><p>leaf</p></td>
<td align="left"><p>&gt; <code>rate</code>, &lt; <code>ceil</code></p></td>
<td align="left"><p><code>HTB_MAY_BORROW</code></p></td>
<td align="left"><p>Leaf class will attempt to borrow tokens/ctokens from parent class. If tokens are available, they will be lent in <code>quantum</code> increments and the leaf class will dequeue up to <code>cburst</code> bytes</p></td>
</tr>
<tr class="even">
<td align="left"><p>leaf</p></td>
<td align="left"><p>&gt; <code>ceil</code></p></td>
<td align="left"><p><code>HTB_CANT_SEND</code></p></td>
<td align="left"><p>No packets will be dequeued. This will cause packet delay and will increase latency to meet the desired rate.</p></td>
</tr>
<tr class="odd">
<td align="left"><p>inner, root</p></td>
<td align="left"><p>&lt; <code>rate</code></p></td>
<td align="left"><p><code>HTB_CAN_SEND</code></p></td>
<td align="left"><p>Inner class will lend tokens to children.</p></td>
</tr>
<tr class="even">
<td align="left"><p>inner, root</p></td>
<td align="left"><p>&gt; <code>rate</code>, &lt; <code>ceil</code></p></td>
<td align="left"><p><code>HTB_MAY_BORROW</code></p></td>
<td align="left"><p>Inner class will attempt to borrow tokens/ctokens from parent class, lending them to competing children in <code>quantum</code> increments per request.</p></td>
</tr>
<tr class="odd">
<td align="left"><p>inner, root</p></td>
<td align="left"><p>&gt; <code>ceil</code></p></td>
<td align="left"><p><code>HTB_CANT_SEND</code></p></td>
<td align="left"><p>Inner class will not attempt to borrow from its parent and will not lend tokens/ctokens to children classes.</p></td>
</tr>
</tbody>
</table>

This diagram identifies the flow of borrowed tokens and the manner in which tokens are charged to parent classes. In order for the borrowing model to work, each class must have an accurate count of the number of tokens used by itself and all of its children. For this reason, any token used in a child or leaf class is charged to each parent class until the root class is reached.

Any child class which wishes to borrow a token will request a token from its parent class, which if it is also over its `rate` will request to borrow from its parent class until either a token is located or the root class is reached. So the borrowing of tokens flows toward the leaf classes and the charging of the usage of tokens flows toward the root class.

[<img src="http://images.cnitblog.com/blog/635909/201406/210748207397629.jpg" title="clip_image002" alt="clip_image002" width="519" height="439" />](http://images.cnitblog.com/blog/635909/201406/210748194267129.jpg)

Note in this diagram that there are several HTB root classes. Each of these root classes can simulate a virtual circuit.

###### 7.1.4. HTB class parameters

`default`

An optional parameter with every HTB [`qdisc`](http://linux-ip.net/articles/Traffic-Control-HOWTO/components.html#c-qdisc) object, the default `default` is 0, which cause any unclassified traffic to be dequeued at hardware speed, completely bypassing any of the classes attached to the `root` qdisc.

`rate`

Used to set the minimum desired speed to which to limit transmitted traffic. This can be considered the equivalent of a committed information rate (CIR), or the guaranteed bandwidth for a given leaf class.

`ceil`

Used to set the maximum desired speed to which to limit the transmitted traffic. The borrowing model should illustrate how this parameter is used. This can be considered the equivalent of “burstable bandwidth”.

`burst`

This is the size of the [`rate`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-rate) bucket (see [Tokens and buckets](http://linux-ip.net/articles/Traffic-Control-HOWTO/overview.html#o-buckets)). HTB will dequeue `burst` bytes before awaiting the arrival of more tokens.

`cburst`

This is the size of the [`ceil`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-ceil) bucket (see [Tokens and buckets](http://linux-ip.net/articles/Traffic-Control-HOWTO/overview.html#o-buckets)). HTB will dequeue `cburst` bytes before awaiting the arrival of more ctokens.

`quantum`

This is a key parameter used by HTB to control borrowing. Normally, the correct `quantum` is calculated by HTB, not specified by the user. Tweaking this parameter can have tremendous effects on borrowing and shaping under contention, because it is used both to split traffic between children classes over [`rate`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-rate) (but below [`ceil`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-ceil)) and to transmit packets from these same classes.

`r2q`

Also, usually calculated for the user, `r2q` is a hint to HTB to help determine the optimal [`quantum`](http://linux-ip.net/articles/Traffic-Control-HOWTO/classful-qdiscs.html#vl-qc-htb-params-quantum) for a particular class.

`mtu`

`prio`

 

Netfilter & iproute - marking packets
=====================================

我们可以在iptable中设置mark，然后在route的时候使用mark

this command marks all packets destined for port 25, outgoing mail:

    # iptables -A PREROUTING -i eth0 -t mangle -p tcp --dport 25 \
     -j MARK --set-mark 1

We've already marked the packets with a '1', we now instruct the routing policy database to act on this:

    # echo 201 mail.out >> /etc/iproute2/rt_tables
    # ip rule add fwmark 1 table mail.out
    # ip rule ls
    0:  from all lookup local
    32764:  from all fwmark        1 lookup mail.out
    32766:  from all lookup main
    32767:  from all lookup default

Now we generate a route to the slow but cheap link in the mail.out table:

    # /sbin/ip route add default via 195.96.98.253 dev ppp0 table mail.out

The `u32` classifier
====================

The U32 filter is the most advanced filter available in the current implementation.

    # tc filter add dev eth0 protocol ip parent 1:0 pref 10 u32 \
      match u32 00100000 00ff0000 at 0 flowid 1:10
