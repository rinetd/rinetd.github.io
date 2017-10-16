---
title: Linux 资源限制ulimit
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [linux_base]
tags: [ulimit]
---
先来说说ulimit的硬限制和软限制
硬限制用-H参数,软限制用-S参数.
ulimit -a看到的是软限制,通过ulimit -a -H可以看到硬限制.
如果ulimit不限定使用-H或-S,此时它会同时把两类限制都改掉的.
软限制可以限制用户/组对资源的使用,硬限制的作用是控制软限制.
超级用户和普通用户都可以扩大硬限制,但超级用户可以缩小硬限制,普通用户则不能缩小硬限制.
硬限制设定后,设定软限制时只能是小于或等于硬限制.
1)软限制不能超过硬限制
2)硬限制不能小于软限制
3)普通用户只能缩小硬限制,超级用户可以扩大硬限制
4)硬限制控制软限制,软限制来限制用户对资源的使用

二)关于进程优先级的限制(scheduling priority)
这里的优先级指NICE值
这个值只对普通用户起作用,对超级用户不起作用,这个问题是由于CAP_SYS_NICE造成的.
例如调整普通用户可以使用的nice值为-10到20之间.
硬限制nice的限制为-15到20之间.
ulimit -H -e 35

软限制nice的限制为-10到20之间
ulimit -S -e 30

用nice命令,使执行ls的nice值为-10
nice -n -10 ls /tmp
ssh-BossiP2810  ssh-KITFTp2620  ssh-vIQDXV3333

用nice命令,使执行ls的nice值为-11,此时超过了ulimit对nice的软限制,出现了异常.
nice -n -11 ls /tmp
nice: cannot set niceness: Permission denied


三)内存锁定值的限制(max locked memory)
这个值只对普通用户起作用,对超级用户不起作用,这个问题是由于CAP_IPC_LOCK造成的.
linux对内存是分页管理的,这意味着有不需要时,在物理内存的数据会被换到交换区或磁盘上.
有需要时会被交换到物理内存,而将数据锁定到物理内存可以避免数据的换入/换出.
采用锁定内存有两个理由:
1)由于程序设计上需要,比如oracle等软件,就需要将数据锁定到物理内存.
2)主要是安全上的需要,比如用户名和密码等等,被交换到swap或磁盘,有泄密的可能,所以一直将其锁定到物理内存.

四)进程打开文件的限制(open files)
这个值针对所有用户,表示可以在进程中打开的文件数.

例如我们将open files的值改为3
ulimit -n 3

五)信号可以被挂起的最大数(pending signals)

这个值针对所有用户,表示可以被挂起/阻塞的最大信号数量

六)可以创建使用POSIX消息队列的最大值,单位为bytes.(POSIX message queues)

限制POSIX消息队列的最大值为1000个字节
ulimit -q 1000


七)程序占用CPU的时间,单位是秒(cpu time)

用ulimit将程序占用CPU的时间改为2秒,再运行程序.
ulimit -t 2

程序2S后被kill掉了.


八)限制程序实时优先级的范围,只针对普通用户.(real-time priority)
九)限制程序可以fork的进程数,只对普通用户有效(max user processes)
程序fork的进程数成倍的增加,这里是14个进程的输出.除自身外,其它13个进程都是test程序fork出来的.
我们将fork的限定到12,如下:
ulimit -u 12

十)限制core文件的大小(core file size)

如果在当前目录下没有core文件,我们应该调整ulimit对core的大小进行限制,如果core文件大小在这里指定为0,将不会产生core文件.
这里设定core文件大小为10个blocks.注:一个blocks在这里为1024个字节.

ulimit -c 10
再次运行这个程序
./test
Segmentation fault (core dumped)

查看core文件的大小
ls -lh core
-rw------- 1 root root 12K 2011-03-08 13:54 core

我们设定10个blocks应该是10*1024也不是10KB,为什么它是12KB呢,因为它的递增是4KB.
如果调整到14个blocks，我们将最大产生16KB的core文件.


十一)限制进程使用数据段的大小(data seg size)

Linux对于每个用户，系统限制其最大进程数。为提高性能，可以根据设备资源情况，设置各linux 用户的最大进程数
可以用`ulimit -a` 来显示当前的各种用户进程限制。
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 31548
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 31548
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

-H hard	设置硬资源限制，一旦设置不能增加。 	                ulimit – Hs 64；限制硬资源，线程栈大小为 64K。
-S soft	设置软资源限制，设置后可以增加，但是不能超过硬资源设置。 ulimit – Sn 32；限制软资源，32 个文件描述符。

-a 	显示当前所有的 limit 信息。 	                     ulimit – a；显示当前所有的 limit 信息。
-c 	最大的 core 文件的大小， 以 blocks 为单位           ulimit – c unlimited； 对生成的 core 文件的大小不进行限制。
-d 	进程最大的数据段的大小，以 Kbytes 为单位             ulimit -d unlimited；对进程的数据段大小不进行限制。
-f  file size	进程可以创建文件的最大值，以 blocks 为单位            ulimit – f 2048；限制进程可以创建的最大文件大小为 2048 blocks。
-l 	最大可加锁内存大小，以 Kbytes 为单位。 	           ulimit – l 32；限制最大可加锁内存大小为 32 Kbytes。
-m 	最大内存大小，以 Kbytes 为单位。                  ulimit – m unlimited；对最大内存不进行限制。
-n 	open files 可以打开最大文件描述符的数量。 	                  ulimit – n 128；限制最大可以使用 128 个文件描述符。
-p 	管道缓冲区的大小，以 Kbytes 为单位。 	             ulimit – p 512；限制管道缓冲区的大小为 512 Kbytes。
-s 	线程栈大小，以 Kbytes 为单位。 	                 ulimit – s 512；限制线程栈的大小为 512 Kbytes。
-t 	最大的 CPU 占用时间，以秒为单位。 	               ulimit – t unlimited；对最大的 CPU 占用时间不进行限制。
-u 	max user processes 用户最大可用的进程数。 	                         ulimit – u 64；限制用户最多可以使用 64 个进程。
-v 	进程最大可用的虚拟内存，以 Kbytes 为单位。 	       ulimit – v 200000；限制最大可用的虚拟内存为 200000 Kbytes。




下面我把某linux用户的最大进程数设为10000个：
    ulimit -u 10240
    对于需要做许多 socket 连接并使它们处于打开状态的 Java 应用程序而言，
    最好通过使用 ulimit -n xx 修改每个进程可打开的文件数，缺省值是 1024。
    ulimit -n 4096 将每个进程可以打开的文件数目加大到4096，缺省为1024
    其他建议设置成无限制（unlimited）的一些重要设置是：
    数据段长度：ulimit -d unlimited
    最大内存大小：ulimit -m unlimited
    堆栈大小：ulimit -s unlimited
    CPU 时间：ulimit -t unlimited
    虚拟内存：ulimit -v unlimited
　　
    暂时地，适用于通过 ulimit 命令登录 shell 会话期间。
    永久地，通过将一个相应的 ulimit 语句添加到由登录 shell 读取的文件中， 即特定于 shell 的用户资源文件，如：
1)、解除 Linux 系统的最大进程数和最大文件打开数限制：
        vi /etc/security/limits.conf
        # 添加如下的行
        * soft noproc 11000
        * hard noproc 11000
        * soft nofile 4100
        * hard nofile 4100
      说明：* 代表针对所有用户，noproc 是代表最大进程数，nofile 是代表最大文件打开数
2)、让 SSH 接受 Login 程式的登入，方便在 ssh 客户端查看 ulimit -a 资源限制：
        a、vi /etc/ssh/sshd_config
            把 UserLogin 的值改为 yes，并把 # 注释去掉
        b、重启 sshd 服务：
              /etc/init.d/sshd restart
3)、修改所有 linux 用户的环境变量文件：
    vi /etc/profile
    ulimit -u 10000
    ulimit -n 4096
    ulimit -d unlimited
    ulimit -m unlimited
    ulimit -s unlimited
    ulimit -t unlimited
    ulimit -v unlimited
 保存后运行#source /etc/profile 使其生效
/**************************************
有时候在程序里面需要打开多个文件，进行分析，系统一般默认数量是1024，（用ulimit -a可以看到）对于正常使用是够了，但是对于程序来讲，就太少了。

文件打开数量限制 默认1024 open files                      (-n) 1024

修改2个文件。

1./etc/security/limits.conf
vi /etc/security/limits.conf
加上：
* soft nofile 8192
* hard nofile 20480

2./etc/pam.d/login
session required /lib/security/pam_limits.so
/**********
另外确保/etc/pam.d/system-auth文件有下面内容
session required /lib/security/$ISA/pam_limits.so
这一行确保系统会执行这个限制。

/***********

3.一般用户的.bash_profile
#ulimit -n 1024
重新登陆ok
