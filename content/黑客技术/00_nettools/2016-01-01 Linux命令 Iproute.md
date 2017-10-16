---
title: Linux命令 Iproute2
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ip]
---
![Iproute2](http://www.iamle.com/wp-content/uploads/2014/09/wpid-abf17d4f53f3b97cabb69165ef222945_iproute23.png)
![Iproute2](http://s8.51cto.com/wyfs02/M00/2C/45/wKiom1OOgvChGrdiAAdSqx73gOg911.jpg)

/etc/hosts：域名到 IP 地址的映射。
/etc/networks：网络名称到 IP 地址的映射。
/etc/protocols：协议名称到协议编号的映射。
/etc/services：TCP/UDP 服务名称到端口号的映射。

## 1. DNS 域名->IP `vi /etc/resolv.conf`
sudo gedit /etc/resolvconf/resolv.conf.d/base
```
nameserver 114.114.114.114
nameserver 114.114.115.115
```
sudo /etc/init.d/resolvconf restart  
```
nameserver 127.0.1.1
search DHCP HOST
```
## 2. IP->主机名的映射 `/etc/hosts`
```
127.0.0.1 localhost
127.0.1.1 ubuntu-server
10.0.0.11 server1.example.com server1 vpn
10.0.0.12 server2.example.com server2 mail
10.0.0.13 server3.example.com server3 www
10.0.0.14 server4.example.com server4 file
```
## 3. ip配置:`/etc/network/interfaces`
DHCP
```
auto eth0
iface eth0 inet dhcp
```
STATIC
```
auto eth0
iface eth0 inet static
address 10.0.0.100
netmask 255.255.255.0
gateway 10.0.0.1
```
Loopback
```
auto lo
iface lo inet loopback
```
## 3. 网桥配置 `/etc/network/interfaces`
![](https://dn-linuxcn.qbox.me/data/attachment/album/201607/22/145151v0yo6ow2totwu861.jpg)
```
### 使用 DHCP
auto br0
iface br0 inet dhcp
        bridge_ports eth0
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0
### 设置 eth0 并将它映射到 br0
auto br0
iface br0 inet static
      address 10.18.44.26
      netmask 255.255.255.192
      broadcast 10.18.44.63
      dns-nameservers 10.0.80.11 10.0.80.12
      # set static route for LAN
      post-up route add -net 10.0.0.0 netmask 255.0.0.0 gw 10.18.44.1
      post-up route add -net 161.26.0.0 netmask 255.255.0.0 gw 10.18.44.1
      bridge_ports eth0
      bridge_stp off
      bridge_fd 0
      bridge_maxwait 0

### br1 使用静态公网 IP 地址，并以 ISP 的路由器作为网关
auto br1
iface br1 inet static
        address 208.43.222.51
        network 255.255.255.248
        netmask 255.255.255.0
        broadcast 208.43.222.55
        gateway 208.43.222.49
        bridge_ports eth1
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0
```
重启网络服务
```
sudo systemctl restart networking
sudo /etc/init.d/restart networking
```
## 4. eth
centos eth1
vi /etc/sysconfig/network-scripts/ifcfg-eth1
```
DEVICE=eth1
ONBOOT=yes
BOOTPROTO=static
IPADDR=139.129.108.163
NETMASK=255.255.252.0

    TYPE="Ethernet"
    BOOTPROTO="none"
    DEFROUTE="yes"
    IPV4_FAILURE_FATAL="no"
    IPV6INIT="yes"
    IPV6_AUTOCONF="yes"
    IPV6_DEFROUTE="yes"
    IPV6_FAILURE_FATAL="no"
    NAME="enp0s3"
    UUID="e9f9caef-cb9e-4a19-aace-767c6ee6f849"
    ONBOOT="yes"
    HWADDR="08:00:27:80:63:19"
    IPADDR0="192.168.1.150"
    PREFIX0="24"
    GATEWAY0="192.168.1.1"
    DNS1="192.168.1.1"
    IPV6_PEERDNS="yes"
    IPV6_PEERROUTES="yes"
```
--------------------------------------------------------------------------------
ip addr
#清除所有IP配置
ip addr flush eth0
#设置和删除Ip地址
ip addr show enp3s0
sudo ip addr add 192.168.0.100/24 dev enp3s0
sudo ip addr del 192.168.0.193/24 dev enp3s0
#路由
route
netstat -rn
ip route list # 显示核心路由表
ip route show
假设现在你有一个IP地址，你需要知道路由包从哪里来,列出了路由所使用的接口
ip route get 10.42.0.47
要更改默认路由
sudo ip route add default via 192.168.0.196 $gateway
配置一条路由: 发到 10.0.0.0/24 的数据包通过 192.168.0.19 (gw)转发
ip route add 10.0.0.0/24 via 192.168.0.19
#ARP
ip neighbour
ip neigh list # 显示邻居表
#监控netlink消息
sudo ip monitor all
#激活和停止网络接口
sudo ip link set enp3s0 down
sudo ip link set enp3s0 up

# 重启网卡
1. sudo service network-manager restart

2. /etc/init.d/network restart
3.
  ifdown eth0
  ifup eth0
4.
  ifconfig eth0 down
  ifconfig eth0 up

# ----------------- Linux 网桥配置命令:brctl
## 首先，我们先增加一个网桥lxcbr0，模仿docker0
brctl addbr lxcbr0
brctl stp lxcbr0 off
ifconfig lxcbr0 192.168.10.1/24 up #为网桥设置IP地址

## 接下来，我们要创建一个network namespace - ns1

# 增加一个namesapce 命令为 ns1 （使用ip netns add命令）
ip netns add ns1

# 激活namespace中的loopback，即127.0.0.1（使用ip netns exec ns1来操作ns1中的命令）
ip netns exec ns1   ip link set dev lo up

## 然后，我们需要增加一对虚拟网卡

# 增加一个pair虚拟网卡，注意其中的veth类型，其中一个网卡要按进容器中
ip link add veth-ns1 type veth peer name lxcbr0.1

# 把 veth-ns1 按到namespace ns1中，这样容器中就会有一个新的网卡了
ip link set veth-ns1 netns ns1

# 把容器里的 veth-ns1改名为 eth0 （容器外会冲突，容器内就不会了）
ip netns exec ns1  ip link set dev veth-ns1 name eth0

# 为容器中的网卡分配一个IP地址，并激活它
ip netns exec ns1 ifconfig eth0 192.168.10.11/24 up


# 上面我们把veth-ns1这个网卡按到了容器中，然后我们要把lxcbr0.1添加上网桥上
brctl addif lxcbr0 lxcbr0.1

# 为容器增加一个路由规则，让容器可以访问外面的网络
ip netns exec ns1     ip route add default via 192.168.10.1

# 在/etc/netns下创建network namespce名称为ns1的目录，
# 然后为这个namespace设置resolv.conf，这样，容器内就可以访问域名了
mkdir -p /etc/netns/ns1
echo "nameserver 8.8.8.8" > /etc/netns/ns1/resolv.conf

####### 静态路由表

# linux下静态路由修改命令route:
add 增加路由
del 删除路由
-net 设置到某个网段的路由
-host 设置到某台主机的路由
gw 出口网关 IP地址
dev 出口网关 物理设备名

增加默认路由
route add default gw 192.168.0.1

查看路由表
route -n
netstat -rn

方法一：
添加路由
route add -net 192.168.0.0/24 gw 192.168.0.1
route add -host 192.168.1.1 dev 192.168.0.1
删除路由
route del -net 192.168.0.0/24 gw 192.168.0.1

方法二：
添加路由
ip route add 192.168.0.0/24 via 192.168.0.1
ip route add 192.168.1.1 dev 192.168.0.1
删除路由
ip route del 192.168.0.0/24 via 192.168.0.1

add 增加路由
del 删除路由
via 网关出口 IP地址
dev 网关出口 物理设备名

增加默认路由
ip route add default via 192.168.0.1 dev eth0
via 192.168.0.1 是我的默认路由器

查看路由信息
ip route
--------------------------------------------------------------------------------
保存路由设置，使其在网络重启后任然有效
在/etc/sysconfig/network-script/目录下创建名为route- eth0的文件
vi /etc/sysconfig/network-script/route-eth0
在此文件添加如下格式的内容

192.168.1.0/24 via 192.168.0.1

重启网络验证

/etc/rc.d/init.d/network中有这么几行：

# Add non interface-specific static-routes.
if [ -f /etc/sysconfig/static-routes ]; then
grep "^any" /etc/sysconfig/static-routes | while read ignore args ; do
/sbin/route add -$args
done
fi

也就是说，将静态路由加到/etc/sysconfig/static-routes 文件中就行了。

如加入：
route add -net 11.1.1.0 netmask 255.255.255.0 gw 11.1.1.1

则static-routes的格式为
any net 11.1.1.0 netmask 255.255.255.0 gw 11.1.1.1
