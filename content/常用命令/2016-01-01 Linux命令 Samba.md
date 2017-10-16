---
title: Samba
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [Samba]
---
windows 和linux 之间访问 推荐用samba


## samba nfs 区别
1.samba 是windows 和linux共享方式 速度块
2.nfs 在windows下访问慢

如果提示没有权限的问题 chmod o+rwx share


### samba
samba服务器需要两个守护进程：smbd和nmbd。
smbd进程监听TCP139端口，用来管理 SAMBA 主机分享的目录、文件和打印机等，处理到来的SMB数据包;
nmbd进程监听137、138UDP端口，负责名称解析的服务，使其他主机能浏览linux服务器。
NBT(NetBIOS over TCP/IP)
使用137, 138 (UDP) and 139 (TCP）来实现基于TCP/IP的NETBIOS网际互联。
Port 137 (UDP) - NetBIOS 名字服务  nmbd
Port 138 (UDP) - NetBIOS 数据报服务 nmbd
Port 139 (TCP) - 文件和打印共享 ； smbd （基于SMB(Server Message Block)协议，主要在局域网中使用，文件共享协议）
Port 445 (TCP) - 文件和打印机共享服务 不过该端口是基于CIFS协议（通用因特网文件 系统协议）工作的，而139端口是基于SMB协议（服务器协议族）
root@ubuntu-desktop:~# netstat -anptu |grep mb
tcp        0      0 0.0.0.0:445             0.0.0.0:*               LISTEN      3054/smbd       
tcp        0      0 0.0.0.0:139             0.0.0.0:*               LISTEN      3054/smbd       
udp        0      0 0.0.0.0:137             0.0.0.0:*                           3062/nmbd       
udp        0      0 0.0.0.0:138             0.0.0.0:*                           3062/nmbd   

1. 	apt-get install samba
2. 	mkdir share
	chmod o+rw share
	!!不能创建在/root/目录下!!
3.  vi /etc/samba/smb.conf
[share_name]
comment = Shared Folder with username and password
path = /usr/src
public = yes
writable = yes
available = yes
browseable = yes
create mask = 0755
directory mask = 0755
;valid users = ubuntu
;force user = nobody
;force user = nobody
;force group = nogroup
;guest ok = yes
4. 	service smbd restart

##########
要mount的机器上面开启NFS
/etc/init.d/nfs start (service nfs start)

开启mount权限
vi /etc/exports
例如：figure/data 192.168.115.*(insecure,rw,sync,no_root_squash,insecure)

开始mount
[root@localhost /]# mount -t nfs 192.168.115.72:/figure/data /mnt/2

如果mount失败，查看被mount的机器的日志
cat /var/log/messages |grep mount   查看对应的错误

防火墙 和 selinux关掉。命令关。。


fedora12 nfs mount access denied /etc/exports(2012-07-13 16:28:49)转载▼标签： 杂谈  
1、NFS包
-----------
NFS需要5个RPM，分别是：
setup-* : 共享NFS目录在/etc/exports中定义
initscripts-* : 包括引导过程中装载网络目录的基本脚本
nfs-utils-* : 包括基本的NFS命令与监控程序
portmap-* : 支持安全NFS RPC服务的连接
quota-* : 网络上共享的目录配额，包括rpc.rquotad （这个包不是必须的）
、基本监控程序
-------------------
要顺利运行NFS，至少需要五个Linux服务，它们各有不同的功能，有的负责装载服务，有的保证远程命令指向正确的位置。这些服务通过/etc/rc.d/init.d目录中的nfs,nfslock和portmap脚本启动。下面简单介绍每个监控程序：
(1) 基本NFS
rpc.nfsd是NFS服务器监控程序，它通过/etc/rc.d/init.d目录中的nfs脚本启动。NFS监控程序还启动rpc.mountd装载监控程序，并导出共享目录。

(2) RPC装载
可以用mount命令连接本地目录或网络目录，但还需要一个装载NFS目录的特殊监控程序rpc.mountd

(3) 端口映射器
portmap监控程序只是定向RPC通信数据流，但它对于NFS服务很重要。如果不运行portmap，则NFS客户机无法找到从NFS服务器共享的目录。

(4) 重新启动与statd
当NFS服务需要中断或者重新启动时，rpc.statd监控程序和rpc.lockd在服务器重新启动之后使客户机恢复NFS连接。

(5) 锁定
通过共享NFS目录打开文件时，锁定可以使用户不能覆盖同一个文件。锁定通过nfslock脚本并使用rpc.lockd监控程序启动运行。


ro 只读访问
rw 读写访问
sync 所有数据在请求时写入共享
async NFS在写入数据前可以相应请求
secure NFS通过1024以下的安全TCP/IP端口发送
insecure NFS通过1024以上的端口发送
wdelay 如果多个用户要写入NFS目录，则归组写入（默认）
no_wdelay 如果多个用户要写入NFS目录，则立即写入，当使用async时，无需此设置。
hide 在NFS共享目录中不共享其子目录
no_hide 共享NFS目录的子目录
subtree_check 如果共享/usr/bin之类的子目录时，强制NFS检查父目录的权限（默认）
no_subtree_check 和上面相对，不检查父目录权限
all_squash 共享文件的UID和GID映射匿名用户anonymous，适合公用目录。
no_all_squash 保留共享文件的UID和GID（默认）
root_squash root用户的所有请求映射成如anonymous用户一样的权限（默认）
no_root_squas root用户具有根目录的完全管理访问权限
anonuid=xxx 指定NFS服务器/etc/passwd文件中匿名用户的UID
anongid=xxx 指定NFS服务器/etc/passwd文件中匿名用户的GID

vi /etc/exports
/nfsroot 192.168.122.*(rw,insecure,sync,all_squash)


出错：
mount.nfs: access denied by server while mounting 192.168.122.224:/
检查出错信息：
cat /var/log/messages | grep mount
May 19 01:43:41 localhost mountd[1785]: refused mount request from 192.168.122.224 for /nfsroot (/): not exported
执行：
#exportfs -rv
这句话相当于输出nfsroot，让mount端可以看到nfsroot目录。

no_root_squash：登入 NFS 主机使用分享目录的使用者，如果是 root 的话，那么对于这个分享的目录来说，他就具有 root 的权限！这个项目『极不安全』，不建议使用！ root_squash：在登入 NFS 主机使用分享之目录的使用者如果是 root 时，那么这个使用者的权限将被压缩成为匿名使用者，通常他的 UID 与 GID 都会变成 nobody 那个系统账号的身份。

Example:  /etc/export
/rootfs *(sync,rw,insecure,no_root_squash,no_subtree_check)
/tftpboot *(async,rw,insecure,no_root_squash,no_subtree_check)

sync 适用在通信比较频繁且实时性比较高的场合，比如Linux系统的rootfs通过nfs挂载，如果搞成async，当执行大型网络通信程序如 gdbserver与client之类，则系统此时会无响应，报一些“NFS is not responding“之类的错误。

当然并非sync就比async好，如果在远程挂载点处进行大批量数据生成，如解压一个大型tar包，此时速度会非常慢，我对比了一下在nfs server端解压只需半分多钟，在client端则要40来分钟，性能严重受到影响。
当改成async后，在client端解压只需4分多钟，虽然比server端慢一些但性能已得到很大改善。所以当涉及到很多零碎文件操作时，选用async性能更高。
启动NFS
--------------
# service portmap start
# service nfs start
检查NFS的运行级别：
# chkconfig --list portmap
# chkconfig --list nfs
根据需要设置在相应的运行级别自动启动NFS：
# chkconfig --level 235 portmap on
# chkconfig --level 235 nfs on


## 0x01 NFS
服务器PC Linux
ubuntu :
	apt-cache search nfs
	apt-get install nfs-kernel-server

	sudo service portmap start
	sudo service nfs-kernel-server start   
centos 5 :
	yum install nfs-utils portmap
centos 6 :
	yum install nfs-utils rpcbind
	yum search nfs* rpcbind*
	yum list installed nfs*  rpcbind* #查看已安装

	sudo ntsysv      ##启用服务rpcbind nfs
	sudo /etc/init.d/nfs restart     ##重启服务rpcbind nfs
	sudo service nfs restart  

	sudo chkconfig --level 3 nfs on
##添加共享目录
sudo vim /etc/exports
	/home/work/rootfs   *(insecure,rw,sync,no_subtree_check)
sudo exportfs -av
>>exporting  *:/rootfs #共享成功

sudo mount -t nfs 127.0.0.1:/home/work/nfs /mnt

##clnt_create: RPC: Program not registered
sudo rpc.mountd

##配置rpc，nfsd，rquotad，?mountd使用的端口
sudo vim /etc/services
   mountd          48620/tcp               #rpc.mountd
   mountd          48620/udp               #rpc.mountd

##配置防火墙 直接关闭防火墙也可以
sudo  vim /etc/sysconfig/iptables  
       rpcinfo -p 192.168.100.30 #查看端口通过防火墙
 #portmapper
-A INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 111 -j ACCEPT
 #rpc
-A INPUT -m state --state NEW -m tcp -p tcp --dport 121 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 121 -j ACCEPT
#rquotad
-A INPUT -m state --state NEW -m tcp -p tcp --dport 875 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 875 -j ACCEPT
#nfsd
-A INPUT -m state --state NEW -m tcp -p tcp --dport 2049 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 2049 -j ACCEPT
#mountd
-A INPUT -m state --state NEW -m tcp -p tcp --dport 46940 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 50038 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 46280 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 44001 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 41314 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 45740 -j ACCEPT

客户端 Windows
   1. 程序功能 启用 NFS 服务
   2. showmount -e 192.168.100.30
   3. mount \\192.168.100.30\home\lshl\ z:

客户端 ARM开发板
//制作ARM文件系统
gunzip initrd.img.gz -->initrd.img   取得启动映像
sudo mount -t ext2 initrd.img ./swap/
sudo cp -a ./swap/* /home/work/rootfs/ #-a 保留快捷方式 等属性的拷贝
bootargs
   root=/dev/nfs
   nfsroot=192.168.10.110:/home/work/rootfs #服务器ip  
   ip=192.168.10.112 #armIP
   init=/linuxrc
   console=ttySAC0,115200

1、服务查询

	默认情况下，Linux系统在默认安装中已经安装了Samba服务包的一部分 ，为了对整个过程有一个完整的了解，在此先将这部分卸载掉。使用命令

rpm -qa | grep samba ，默认情况下可以查询到两个已经存在的包：

	samba-client-3.0.33-3.7.el5

	samba-common-3.0.33-3.7.el5



2、卸载Samba

	用rpm -e 将两个包卸载掉。对于samba-common-3.0.33-3.7.el5，因为与其它rpm包之间存在依赖关系，所以必须加参数-f和--nodeps，-f是指强制，--nodeps是指不检查依赖关系，具体完整命令为：

 	rpm -e samba-common-3.0.33-3.7.el5 -f --nodeps

	rpm -e samba-client-3.0.33-3.7.el5 -f --nodeps



3、安装Samba

	用以下命令安装：

		rpm -ivh samba-3.0.33-3.29.el5_6.2.i386.rpm -f --nodeps

		rpm -ivh samba-client-3.0.33-3.29.el5_6.2.i386.rpm  -f --nodeps
		rpm -ivh samba-common-3.0.33-3.29.el5_6.2.i386.rpm -f --nodeps
	安装完成后，使用命令rpm -qa | grep samba进行查询，发现搭建samba服务器所依赖的所有服务器都已经安装好了即可。



4、配置smb.conf文件

	Samba的配置文件一般就放在/etc/samba目录中，主配置文件名为smb.conf，文件中记录着大量的规则和共享信息，所以是samba服务非常重要的核心配置文件，完成samba服务器搭建的大部分主要配置都在该文件中进行。

	Samba服务器的工作原理是：客户端向Samba服务器发起请求，请求访问共享目录，Samba服务器接收请求，查询smb.conf文件，查看共享目录是否存在，以及来访者的访问权限，如果来访者具有相应的权限，则允许客户端访问，最后将访问过程中系统的信息以及采集的用户访问行为信息存放在日志文件中。

	第一步：修改配置文件
     首先备份一下samba的配置文件

		cd /etc/samba

		mv smb.conf smb.confbak

	然后重新创建一个smb.conf文件

		touch smb.conf

	然后我们把这段写入smb.conf中

		[global]

		     workgroup = LinuxSir
	    netbios name = LinuxSir05
	    server string = Linux Samba Server TestServer
	    security = share

	 [linuxsir]
            path = /opt/linuxsir
            	writeable = yes
            	    browseable = yes

	   guest ok = yes



	注解：
	[global]这段是全局配置，是必段写的。其中有如下的几行；

		workgroup 就是Windows中显示的工作组；在这里我设置的是LINUXSIR （用大写）；
		netbios name 就是在Windows中显示出来的计算机名；
		server string 就是Samba服务器说明，可以自己来定义；这个不是什么重要的；
		security 这是验证和登录方式，这里我们用了share ；验证方式有好多种，这是其中一种；另外一种常用的是user的验证方式；如果用share呢，就是不用设置用户和密码了；

	[linuxsir] 这个在Windows中显示出来是共享的目录；
		path = 可以设置要共享的目录放在哪里；
		writeable 是否可写，这里我设置为可写；
		browseable 是否可以浏览，可以；可以浏览意味着，我们在工作组下能看到共享文件夹。如果您不想显示出来，那就设置为 browseable=no

		guest ok 匿名用户以guest身份是登录；

	第二步：建立相应目录并授权；

				[root@localhost ~]# mkdir -p /opt/linuxsir

				[root@localhost ~]# id nobody
		uid=99(nobody) gid=99(nobody) groups=99(nobody)
		[root@localhost ~]# chown -R nobody:nobody /opt/linuxsir
	    注释：

		关于授权nobody，我们先用id命令查看了nobody用户的信息，发现他的用户组也是nobody，我们要以这个为准。有些系统nobody用户组并非是nobody ；



		第三步：启动smbd和nmbd服务器；

		     [root@localhost ~]# smbd
		     [root@localhost ~]# nmbd

OS:Red Hat Linux As 5


1.服务器上创建共享目录
mkdir
doc_share
chmod o+rwx doc_share

2.编辑exports文件
vim /etc/exports
写入
/doc_share
192.168.2.131/255.255.255.0(rw,sync)
格式是:
要共享的目录
共享的IP及掩码或者域名(权限,同步更新)


3.启动服务
/etc/init.d/portmap restart
/etc/init.d/nfs restart
chkconfig nfs
on
chkconfig portmap on

然后关闭防火墙以及更改Selinux关于NIS的选项
/etc/init.d/iptables stop (防护墙服务关闭)
chkconfig iptables off
system-config-selinux (设置selinux)


查看共享的东西
[root@rac1
/]# exportfs -rv
exporting 192.168.2.131/255.255.255.0:/doc_share


试着在本机看能否加载
mount
192.168.2.131:/doc_share /mnt

[root@rac1 doc_share]# echo
aa>aa.txt
[root@rac1 doc_share]# ls
aa.txt
[root@rac1 /]# cd
/mnt
[root@rac1 mnt]# ls
aa.txt


4.客户端
手工mount:
mount -o nolock 192.168.2.131:/doc_share
/mnt
这个时候可以看到在节点1上内容了.
[root@rac2
mnt]# cd /mnt
[root@rac2 mnt]# ls
aa.txt

自动mount:
编辑fstab文件，实现开机自动挂载
mount -t nfs IP:/目录 挂载到的目录
(此为临时挂载)
如：mount -t nfs
192.168.0.9:/doce /doc
vim /etc/fstab 添加如下内容
192.168.2.131:/doc_share /mnt nfs defaults 0 0



相关的一些命令:
showmout命令对于NFS的操作和查错有很大的帮助.
showmout

-a:这个参数是一般在NFS SERVER上使用,是用来显示已经mount上本机nfs目录的cline机器.
-e:显示指定的NFS
SERVER上export出来的目录.
例如：
showmount -e 192.168.0.30

Export list for localhost:
/tmp *
/home/linux *.linux.org

/home/public (everyone)
/home/test 192.168.0.100


exportfs命令:
如果我们在启动了NFS之后又修改了/etc/exports,是不是还要重新启动nfs呢？这个时候我们就可以用exportfs命令来使改动立刻生效，该命令格式如下:
exportfs
[-aruv]
-a ：全部mount或者unmount /etc/exports中的内容
-r ：重新mount
/etc/exports中分享出来的目录
-u ：umount 目录
-v ：在 export
的时候,将详细的信息输出到屏幕上.
具体例子:
[root @test root]# exportfs
-rv <==全部重新 export 一次！
exporting
192.168.0.100:/home/test
exporting 192.168.0.*:/home/public
exporting
*.the9.com:/home/linux
exporting *:/home/public
exporting *:/tmp

reexporting 192.168.0.100:/home/test to kernel

exportfs -au
<==全部都卸载了
-------------------------------------------------------------------------------
今天在机器上配置NFS文件系统，在/etc/exports中加入以下信息：
    /testfs 10.0.0.0/8(rw)
    重启NFS服务以后，在客户机通过mount -o rw -t nfs 10.214.54.29:/testfs /rd1命令将网络文件mount到本地。执行完成之后，目录是可以访问了，但无法写入。感觉有点奇怪，明明在命令中指定可以写入了。于是到网上搜索资料，发现exports目录权限中，有这么一个参数no_root_squash。其作用是：登入 NFS 主机使用分享目录的使用者，如果是 root 的话，那么对于这个分享的目录来说，他就具有                      root 的权限！。默认情况使用的是相反参数                     root_squash：在登入 NFS 主机使用分享之目录的使用者如果是 root 时，那么这个使用者的权限将被压缩成为匿名使用者，通常他的                      UID 与 GID 都会变成 nobody 那个身份。
    因为我的客户端是使用root登录的，自然权限被压缩为nobody了，难怪无法写入。将配置信息改为：
    /testfs 10.0.0.0/8(rw,no_root_squash)
    据说有点不安全，但问题是解决了。
    另外，在测试NFS文件系统时，会经常mount和umount文件，但有时会出现device is busy的错误提示。你肯定感到很奇怪，我明明没有使用啊，看看你当前所在的目录，是不是在mount的文件目录中？回退到上层目录重新umount，是不是OK了？

    linux下Samba服务和NFS服务配置
一、Samba服务配置过程
samba的功能很简单，就是为了使linux和windows之间能够实现共享。并且利用samba搭建文件服务器，不仅比windows功能强大，而且访问速度快、安全。首先说明，samba服务器需要两个守护进程：smbd和nmbd。smbd进程监听139TCP端口，处理到来的SMB数据包;nmbd进程监听137、138UDP端口，使其他主机能浏览linux服务器。
1、安装Samba服务
首先用命令测试rpm -qi samba看是否安装了Samba软件包，若没有可以用yum install samba在线安装（fedora 11环境下）。
2、启动Samba服务
安装完成后，使用service smb start 命令启动samba服务。如果想让samba服务开机自动加载，可使用ntsysv命令（或setup命令中的system service选项）打开开机自动加载的服务，并勾选smb，确定后即可实现开机加载samba服务。
3、关闭防火墙
　　默认情况下防火墙关闭了139 TCP端口，也关闭了nmbd进程所需要的137、138端口。所以我们使用命令service iptables stop命令关闭防火墙。也可对防火墙进行修改，放行TCP139 UDP 137、138端口。
4、配置samba服务
　　samba服务的配置文件是 /etc/samba/smb.conf，使用VI编辑器打开vi /etc/samba/smb.conf文件，对samba进行配置
　　smb.conf文件中包括4中结构，【Global】、【Homes】、【printers】、【Userdefined_shareName】，其中：
　　Globa用于定义全局参数和缺省值
　　Homes用于用户的home目录共享
　　Printers用于定义打印机共享
　　Userdefined_ShareName用于自定义共享(可有多个)
　　说明：文件中开头带有“#”为说明文件，不执行。 开头带有“;”为举例文件，不执行(若想让其执行，去掉“;”)。
配置全局参数【Global】
　　◎基本全局参数
　　workgroup＝MYGROUP 设置samba要加入的工作组
　　server string =Samba Service 指定浏览列表里的机器描述
　　netbios name=fedora 设置samba的NetBIOS名字 (需要自己添加)
　　client code page=936 设置客户字符编码 936为简体中文(需要自己添加)
◎日志全局参数
　　log file 指定日志文件的名称
　　max log size＝50 指定日志文件的最大尺寸(KB)
◎安全全局参数
	[security] 定义samba的安装等级
	share--用户不需要用户名和密码即可登陆samba服务器;
	user--由提供samba服务的samba服务器负责检查帐户及口令;
	server--检查帐户及口令的工作指定由另一台WindowsNT/2000或samba服务器负责;
	domain--指定windowsNT/2000域控制器来验证用户帐户、密码
　　encrypt passwords = yes
　　smb passwd file = /etc/samba/smbpasswd
　　这两行用于设定是否对samba密码进行加密,并指定加密文件存放路径.
◎配置自定义共享
　　自定义共享，只需在文件最后加入【share】，名字随便取。其中一的参数我们来依依介绍
　　comment 描述该共享的名称
　　path 定义该共享的目录
　　browseable 指定共享的目录是否可浏览
　　writable 指定共享的目录是否有写入权限
　　read only 指定共享的目录为只读权限
　　public 指定是否可以允许Guest帐户访问
　　guest ok 通public相同，yes为允许guest访问
　　only guest 指定只有guest用户可以访问
　　calid users 指定访问该共享的用户
如：comment ＝my share
path =/home/share
browseable =yes
read only =yes
public =yes
only guest =yes
◎配置完成后的工作
　　在配置完成后，我们只需新建path定义的共享目录mkdir /home/share，
并使用chmod命令设置了其权限为777,chmod 777 /home/share。
　　这样在service smb restart重启smb服务后客户端就可以访问该服务器(我修改了全局参数中的security=share，所以进入服务器不需要输入用户名和密码)。在windows下运行中运行：//192.168.1.6(linux的IP地址)即可。

二、NFS服务配置过程
1、NFS服务器的安装
检查linux系统中是否安装了nfs-utils和portmap两个软件包，#rpm –q nfs-utils（portmap）
2、查看NFS服务器是否启动
#service nfs status
#service portmap status
如果服务器没有启动，则开启服务（默认服务下nfs没有完全开启）
#service nfs start
#service portmap start
也可以在ntsysv命令下关闭iptable和开启nfs让其自启动。
3、指定NFS服务器的配置文件
NFS服务器的配置文件保存“/etc/”目录中，文件名称是“exports”，该文件用于被指NFS服务器提供的目录共享
#vi /etc/exports
配置“exports”文件格式如下
/tftpboot *（sync，ro）
tftp：共享目录名
* 表示所有主机
（sync，ro） 设置选项
exports文件中的“配置选项”字段放置在括号对（“（ ）”）中 ，多个选项间用逗号分隔
sync：设置NFS服务器同步写磁盘，这样不会轻易丢失数据，建议所有的NFS共享目录都使用该选项
ro：设置输出的共享目录只读，与rw不能共同使用
rw：设置输出的共享目录可读写，与ro不能共同使用
4、重新输出共享目录
Exportfs管理工具可以对“exports”文件进行管理
#exportfs –rv 可以让新设置的“exports”文件内容生效
显示当前主机中NFS服务器的输出列表
# showmount -e
显示当前主机NFS服务器中已经被NFS客户机挂载使用的共享目录
# showmount -d
5、使用mount命令挂载NFS文件系统
#mount 192.168.1.6:/tftpboot /home/share
将主机IP地址为192.168.1.6中的/tftpboot目录挂载到/home/share
卸载系统中已挂载的NFS共享目录
# umount /home/share
卸载的时候不能在/home/share目录下卸载，必须注销系统后卸载。
PS:
如果portmap进程停止了运行或异常终止，那么该系统上的所有RPC服务器必须重新启动。首先停止NFS服务器上的所有NFS服务进程，然后启动portmap进程，再启动服务器上的NFS进程。
但portmap只在第一次建立连接的时候起作用，帮助网络应用程序找到正确的通讯端口，但是一旦这个双方正确连接，端口和应用就绑定，portmap也就不起作用了。但对其他任何第一次需要找到端口建立通讯的应用仍然有用。简单的说，portmap就是应用和端口的婚姻介绍人，双方成事了以后，媒婆就没用了。

首先当然是要安装samba了，呵呵：
代码:
sudo apt-get install samba
sudo apt-get install smbfs


下面我们来共享群组可读写文件夹，假设你要共享的文件夹为： /home/ray/share

首先创建这个文件夹
代码:
mkdir /home/ray/share
chmod 777 /home/ray/share


备份并编辑smb.conf允许网络用户访问
代码:
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf_backup
sudo gedit /etc/samba/smb.conf


搜寻这一行文字
代码:
; security = user


用下面这几行取代
代码:
security = user
username map = /etc/samba/smbusers


将下列几行新增到文件的最后面，假设允许访问的用户为：newsfan。而文件夹的共享名为 Share

代码:
[Share]
comment = Shared Folder with username and password
path = /home/ray/share
public = yes
writable = yes
valid users = newsfan
create mask = 0700
directory mask = 0700
force user = nobody
force group = nogroup
available = yes
browseable = yes


然后顺便把这里改一下，找到［global］把 workgroup = MSHOME 改成
代码:
workgroup = WORKGROUP
display charset = UTF-8
unix charset = UTF-8
dos charset = cp936

后面的三行是为了防止出现中文目录乱码的情况。其中根据你的local，UTF-8 有可能需要改成 cp936。自己看着办吧。

现在要添加newsfan这个网络访问帐户。如果系统中当前没有这个帐户，那么
代码:
sudo useradd newsfan

要注意，上面只是增加了newsfan这个用户，却没有给用户赋予本机登录密码。所以这个用户将只能从远程访问，不能从本机登录。而且samba的登录密码可以和本机登录密码不一样。

现在要新增网络使用者的帐号：
代码:
sudo smbpasswd -a newsfan
sudo gedit /etc/samba/smbusers


在新建立的文件内加入下面这一行并保存
代码:
newsfan = "network username"


如果将来需要更改newsfan的网络访问密码，也用这个命令更改
代码:
sudo smbpasswd -a newsfan


删除网络使用者的帐号的命令把上面的 -a 改成 -x
代码:
sudo testparm
sudo /etc/init.d/samba restart

最后退出重新登录或者重新启动一下机器。
