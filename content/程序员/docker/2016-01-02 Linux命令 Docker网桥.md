---
title: Linux命令 Docker
date: 2016-03-05T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [Docker]
---
 Docker：添加自定义网桥

 Docker服务进程在启动的时候会生成一个名为docker0的网桥，容器默认都会挂载到该网桥下，但是我们可以通过添加docker启动参数-b Birdge 或更改docker配置文件来选择使用哪个网桥。

操作系统：centos7

删除docker0网桥

[html] view plain copy
service docker stop //关闭docker服务  
ip link set dev docker0 down //关闭docker0网桥   
ip link del dev docker0       //删除docker0网桥  
自定义网桥设置（/etc/sysconfig/network-scripts/ifcfg-br0文件）
[html] view plain copy
DEVICE="br0"  
ONBOOT="yes"  
TYPE="Bridge"  
BOOTPROTO="static"  
IPADDR="10.10.10.20"  
NETMASK="255.255.255.0"  
GATEWAY="10.10.10.20"  
DEFROUTE="yes"  
NM_CONTROLLED="no"  
重启网络服务

[html] view plain copy
service network restart  
查看网桥

[html] view plain copy
[black@test opt]$ brctl show  
bridge name     bridge id               STP enabled     interfaces  
br0             8000.32e7297502be       no                
virbr0          8000.000000000000       yes  
接下来我们需要重新启动docker，可以在启动docker服务进程时使用以下两种方式：

第一种：-b 参数指定网桥

[html] view plain copy
[root@test opt]# docker -d -b br0  
INFO[0000] Listening for HTTP on unix (/var/run/docker.sock)   
INFO[0000] [graphdriver] using prior storage driver "devicemapper"   
WARN[0000] Running modprobe bridge nf_nat failed with message: , error: exit status 1   
INFO[0000] Loading containers: start.                     
......  
INFO[0000] Loading containers: done.                      
INFO[0000] Daemon has completed initialization            
INFO[0000] Docker daemon      commit=786b29d execdriver=native-0.2 graphdriver=devicemapper version=1.7.1  
不知道为什么这样启动docker 服务进程会阻塞当前终端(︶︿︶)，只好重新开一个终端，然后运行一个容器

[html] view plain copy
[root@test shell]# docker run -ti --rm centos:latest  
[root@3c6874559411 /]# ifconfig  
eth0      Link encap:Ethernet  HWaddr 02:42:0A:0A:0A:01    
        inet addr:10.10.10.1  Bcast:0.0.0.0  Mask:255.255.255.0  
        inet6 addr: fe80::42:aff:fe0a:a01/64 Scope:Link  
        UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1  
        RX packets:5 errors:0 dropped:0 overruns:0 frame:0  
        TX packets:6 errors:0 dropped:0 overruns:0 carrier:0  
        collisions:0 txqueuelen:0   
        RX bytes:418 (418.0 b)  TX bytes:508 (508.0 b)  
容器成功使用br0网桥。

第二种：修改/etc/sysconfig/docker文件
我在进行这种操作的时候遇到了一点问题，我修改了/etc/sysconfig/docker文件

[html] view plain copy
[root@test opt]# vi /etc/sysconfig/docker   
# /etc/sysconfig/docker  
#  
# Other arguments to pass to the docker daemon process  
# These will be parsed by the sysv initscript and appended  
# to the arguments list passed to docker -d  

other_args="-b br0"  
接着使用service docker start启动docker服务，但是other_args并不生效，在centos7下servicer docker start仍然会采用systemctl start docker.service命令来运行，于是我就打开/usr/lib/systemd/system/docker.service查看

[html] view plain copy
[root@test opt]# vi /lib/systemd/system/docker.service   
[Unit]  
Description=Docker Application Container Engine  
Documentation=https://docs.docker.com  
After=network.target docker.socket  
Requires=docker.socket  
[Service]  
ExecStart=/usr/bin/docker -d  -H fd://  
MountFlags=slave  
LimitNOFILE=1048576  
LimitNPROC=1048576  
LimitCORE=infinity  

[Install]  
WantedBy=multi-user.target  
发现ExecStart一项并没有运行参数，于是将ExecStart改为/usr/bin/docker -d -b br0 -H fd://，运行docker服务，启动一个容器发现能够成功使用br0网桥。

-------------------------------------------

在网上看到了一种更好的方法，将docker.service改为如下


[html] view plain copy
[black@test ~]$ vi /usr/lib/systemd/system/docker.service   
[Unit]  
Description=Docker Application Container Engine  
Documentation=https://docs.docker.com  
After=network.target docker.socket  
Requires=docker.socket  
[Service]  
EnvironmentFile=-/etc/sysconfig/docker  
ExecStart=/usr/bin/docker -d $other_args  -H fd://  
MountFlags=slave  
LimitNOFILE=1048576  
LimitNPROC=1048576  
LimitCORE=infinity  

[Install]  
WantedBy=multi-user.target  
这个时候在other_args中添加的参数就有效了。



参考：

http://www.aixchina.net/Question/137833

http://www.tuicool.com/articles/fMnyQzb
http://www.tuicool.com/articles/6Fnyuau

http://my.oschina.net/yang1992/blog/492302
