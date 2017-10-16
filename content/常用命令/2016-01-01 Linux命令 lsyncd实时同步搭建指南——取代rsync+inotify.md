---
title: Linux命令 lsyncd
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [rsync]
---
1.1 inotify + rsync

最近一直在寻求生产服务服务器上的同步替代方案，原先使用的是inotify + rsync，但随着文件数量的增大到100W+，目录下的文件列表就达20M，在网络状况不佳或者限速的情况下，变更的文件可能10来个才几M，却因此要发送的文件列表就达20M，严重减低的带宽的使用效率以及同步效率；更为要紧的是，加入inotifywait在5s内监控到10个小文件发生变化，便会触发10个rsync同步操作，结果就是真正需要传输的才2-3M的文件，比对的文件列表就达200M。使用这两个组合的好处在于，它们都是最基本的软件，可以通过不同选项做到很精确的控制，比如排除同步的目录，同步多个模块或同步到多个主机。
1.2 sersync

后来听同事说 sersync 这么个工具可以提高同步的性能，也解决了同步大文件时出现异常的问题，所以就尝试了一下。sersync是国内的一个开发者开源出来的，使用c++编写，采用多线程的方式进行同步，失败后还有重传机制，对临时文件过滤，自带crontab定时同步功能。网上看到有人说性能还不错，说一下我的观点：

    国产开源，文档不是很全，在2011年之后就没更新了（googlecode都要快关闭了，其实可以转交其他人维护），网上关于它的使用和讨论都止于10年了
    采用xml配置文件的方式，可读性比较好，但是有些原生的有些功能没有实现就没法使用了
    无法实现多目录同步，只能通过多个配置文件启动多个进程
    文件排除功能太弱。这个要看需求，不是每个人都需要排除子目录。而对于我的环境中，这个功能很重要，而且排除的规则较多
    虽然提供插件的功能，但很鸡肋，因为软件本身没有持续更新，也没有看到贡献有其它插件出现（可能是我知识面不够，还用不到里面的refreshCDN plugin）。

虽然不懂c++，但大致看了下源码 FileSynchronize，拼接rsync命令大概在273行左右，最后一个函数就是排除选项，简单一点可以将--exclude=改成--eclude-from来灵活控制。有机会再改吧。

另外，在作者的文章 Sersync服务器同步程序 项目简介与设计框架 评论中，说能解决上面 rsync + inotify中所描述的问题。阅读了下源码，这个应该是没有解决，因为在拼接rsync命令时，后面的目的地址始终是针对module的，只要执行rsync命令，就会对整个目录进行遍历，发送要比对的文件列表，然后再发送变化的文件。sersync只是减少了监听的事件，减少了rsync的次数——这已经是很大的改进，但每次rsync没办法改变。（如有其它看法可与我讨论）

其实我们也不能要求每一个软件功能都十分健全，关键是看能否满足我们当下的特定的需求。所谓好的架构不是设计出来的，而是进化来的。目前使用sersync2没什么问题，而且看了它的设计思路应该是比较科学的，特别是过滤队列的设计。双向同步看起来也是可以实现。
1.3 lsyncd

废话说这么多，本文就是介绍它了。有些博客说lsyncd是谷歌开源的，实际不是了，只是托管在了googlecode上而已，幸运的是已经迁移到github了：https://github.com/axkibe/lsyncd 。

Lysncd 实际上是lua语言封装了 inotify 和 rsync 工具，采用了 Linux 内核（2.6.13 及以后）里的 inotify 触发机制，然后通过rsync去差异同步，达到实时的效果。我认为它最令人称道的特性是，完美解决了 inotify + rsync海量文件同步带来的文件频繁发送文件列表的问题 —— 通过时间延迟或累计触发事件次数实现。另外，它的配置方式很简单，lua本身就是一种配置语言，可读性非常强。lsyncd也有多种工作模式可以选择，本地目录cp，本地目录rsync，远程目录rsyncssh。

实现简单高效的本地目录同步备份（网络存储挂载也当作本地目录），一个命令搞定。
2. 使用 lsyncd 本地目录实时备份

这一节实现的功能是，本地目录source实时同步到另一个目录target，而在source下有大量的文件，并且有部分目录和临时文件不需要同步。
2.1 安装lsyncd

安装lsyncd极为简单，已经收录在ubuntu的官方镜像源里，直接通过apt-get install lsyncd就可以。
在Redhat系（我的环境是CentOS 6.2 x86_64 ），可以手动去下载 lsyncd-2.1.5-6.fc21.x86_64.rpm，但首先你得安装两个依赖yum install lua lua-devel。也可以通过在线安装，需要epel-release扩展包：

    # rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    # yum install lsyncd

源码编译安装

从源码编译安装可以使用最新版的lsyncd程序，但必须要相应的依赖库文件和编译工具：yum install lua lua-devel asciidoc cmake。

从 googlecode lsyncd 上下载的lsyncd-2.1.5.tar.gz，直接./configure、make && make install就可以了。

从github上下载lsyncd-master.zip 的2.1.5版本使用的是 cmake 编译工具，无法./configure：

    # uzip lsyncd-master.zip
    # cd lsyncd-master
    # cmake -DCMAKE_INSTALL_PREFIX=/usr/local/lsyncd-2.1.5
    # make && make install

我这个版本编译时有个小bug，如果按照INSTALL在build目录中make，会提示：

    [100%] Generating doc/lsyncd.1
    Updating the manpage
    a2x: failed: source file not found: doc/lsyncd.1.txt
    make[2]: *** [doc/lsyncd.1] Error 1
    make[1]: *** [CMakeFiles/manpage.dir/all] Error 2
    make: *** [all] Error 2

解决办法是要么直接在解压目录下cmake，不要mkdir build，要么在CMakeList.txt中搜索doc字符串，在前面加上${PROJECT_SOURCE_DIR}。
2.2 lsyncd.conf

下面都是在编译安装的情况下操作。
2.2.1 lsyncd同步配置

    # cd /usr/local/lsyncd-2.1.5
    # mkdir etc var
    # vi etc/lsyncd.conf
    settings {
        logfile      ="/usr/local/lsyncd-2.1.5/var/lsyncd.log",
        statusFile   ="/usr/local/lsyncd-2.1.5/var/lsyncd.status",
        inotifyMode  = "CloseWrite",
        maxProcesses = 7,
        -- nodaemon =true,
        }
    sync {
        default.rsync,
        source    = "/tmp/src",
        target    = "/tmp/dest",
        -- excludeFrom = "/etc/rsyncd.d/rsync_exclude.lst",
        rsync     = {
            binary    = "/usr/bin/rsync",
            archive   = true,
            compress  = true,
            verbose   = true
            }
        }

到这启动 lsycnd 就可以完成实时同步了，默认的许多参数可以满足绝大部分需求，非常简单。
2.2.2 lsyncd.conf配置选项说明


sync

里面是定义同步参数，可以继续使用maxDelays来重写settings的全局变量。一般第一个参数指定lsyncd以什么模式运行：rsync、rsyncssh、direct三种模式：

    default.rsync ：本地目录间同步，使用rsync，也可以达到使用ssh形式的远程rsync效果，或daemon方式连接远程rsyncd进程；
    default.direct ：本地目录间同步，使用cp、rm等命令完成差异文件备份；
    default.rsyncssh ：同步到远程主机目录，rsync的ssh模式，需要使用key来认证

    source 同步的源目录，使用绝对路径。

    target 定义目的地址.对应不同的模式有几种写法：
    /tmp/dest ：本地目录同步，可用于direct和rsync模式
    172.29.88.223:/tmp/dest ：同步到远程服务器目录，可用于rsync和rsyncssh模式，拼接的命令类似于/usr/bin/rsync -ltsd --delete --include-from=- --exclude=* SOURCE TARGET，剩下的就是rsync的内容了，比如指定username，免密码同步
    172.29.88.223::module ：同步到远程服务器目录，用于rsync模式
    三种模式的示例会在后面给出。

    init 这是一个优化选项，当init = false，只同步进程启动以后发生改动事件的文件，原有的目录即使有差异也不会同步。默认是true

    delay 累计事件，等待rsync同步延时时间，默认15秒（最大累计到1000个不可合并的事件）。也就是15s内监控目录下发生的改动，会累积到一次rsync同步，避免过于频繁的同步。（可合并的意思是，15s内两次修改了同一文件，最后只同步最新的文件）
    excludeFrom 排除选项，后面指定排除的列表文件，如excludeFrom = "/etc/lsyncd.exclude"，如果是简单的排除，可以使用exclude = LIST。
    这里的排除规则写法与原生rsync有点不同，更为简单：
    ```
        监控路径里的任何部分匹配到一个文本，都会被排除，例如/bin/foo/bar可以匹配规则foo
        如果规则以斜线/开头，则从头开始要匹配全部
        如果规则以/结尾，则要匹配监控路径的末尾
        ?匹配任何字符，但不包括/
        *匹配0或多个字符，但不包括/
        **匹配0或多个字符，可以是/
    ```
    delete 为了保持target与souce完全同步，Lsyncd默认会delete = true来允许同步删除。它除了false，还有startup、running值，请参考 Lsyncd 2.1.x ‖ Layer 4 Config ‖ Default Behavior。

rsync

（提示一下，delete和exclude本来都是rsync的选项，上面是配置在sync中的，我想这样做的原因是为了减少rsync的开销）

    bwlimit 限速，单位kb/s，与rsync相同（这么重要的选项在文档里竟然没有标出）
    compress 压缩传输默认为true。在带宽与cpu负载之间权衡，本地目录同步可以考虑把它设为false
    perms 默认保留文件权限。
    其它rsync的选项

其它还有rsyncssh模式独有的配置项，如host、targetdir、rsync_path、password_file，见后文示例。rsyncOps={"-avz","--delete"}这样的写法在2.1.版本已经不支持。

lsyncd.conf可以有多个sync，各自的source，各自的target，各自的模式，互不影响。
2.3 启动lsyncd

使用命令加载配置文件，启动守护进程，自动同步目录操作。

    lsyncd -log Exec /usr/local/lsyncd-2.1.5/etc/lsyncd.conf

2.4 lsyncd.conf其它模式示例

以下配置本人都已经过验证可行，必须根据实际需要裁剪配置：
settings

里面是全局设置，--开头表示注释，下面是几个常用选项说明：

    logfile 定义日志文件
    stausFile 定义状态文件
    nodaemon=true 表示不启用守护模式，默认
    statusInterval 将lsyncd的状态写入上面的statusFile的间隔，默认10秒
    inotifyMode 指定inotify监控的事件，默认是CloseWrite，还可以是Modify或CloseWrite or Modify
    maxProcesses 同步进程的最大个数。假如同时有20个文件需要同步，而maxProcesses = 8，则最大能看到有8个rysnc进程
    maxDelays 累计到多少所监控的事件激活一次同步，即使后面的delay延迟时间还未到

    settings {
        logfile 	= 	FILENAME 	logs into this file
        pidfile 	= 	FILENAME 	logs PID into this file
        nodaemon 	= 	true 	does not detach
        statusFile 	= 	FILENAME 	periodically writes a status report to this file
        statusInterval 	= 	NUMBER 	writes the status file at shortest after this number of seconds has passed (default: 10)
        logfacility 	= 	STRING 	syslog facility, default "user"
        logident 	= 	STRING 	syslog identification (tag), default "lsyncd"
        insist 	= 	true 	keep running at startup although one or more targets failed due to not being reachable.
        inotifyMode 	= 	STRING 	Specifies on inotify systems what kind of changes to listen to. Can be "Modify", "CloseWrite" (default) or "CloseWrite or Modify".
        maxProcesses 	= 	NUMBER 	Lysncd will not spawn more than these number of processes. This adds across all sync{}s.
}
```
    settings {
        logfile ="/var/lsyncd.log",
        statusFile ="/var/lsyncd.status",
        inotifyMode = "CloseWrite",
        maxProcesses = 8,
        }
    -- I. 本地目录同步，direct：cp/rm/mv。 适用：500+万文件，变动不大
    sync {
        default.direct,
        source    = "/tmp/src",
        target    = "/tmp/dest",
        delay = 1
        maxProcesses = 1
        }
    -- II. 本地目录同步，rsync模式：rsync
    sync {
        default.rsync,
        source    = "/tmp/src",
        target    = "/tmp/dest1",
        excludeFrom = "/etc/rsyncd.d/rsync_exclude.lst",
        rsync     = {
            binary = "/usr/bin/rsync",
            archive = true,
            compress = true,
            bwlimit   = 2000
            }
        }
    -- III. 远程目录同步，rsync模式 + rsyncd daemon
    sync {
        default.rsync,
        source    = "/tmp/src",
        target    = "syncuser@172.29.88.223::module1",
        delete="running",
        exclude = { ".*", ".tmp" },
        delay = 30,
        init = false,
        rsync     = {
            binary = "/usr/bin/rsync",
            archive = true,
            compress = true,
            verbose   = true,
            password_file = "/etc/rsyncd.d/rsync.pwd",
            _extra    = {"--bwlimit=200"}
            }
        }
    -- IV. 远程目录同步，rsync模式 + ssh shell
    sync {
        default.rsync,
        source    = "/tmp/src",
        target    = "172.29.88.223:/tmp/dest",
        -- target    = "root@172.29.88.223:/remote/dest",
        -- 上面target，注意如果是普通用户，必须拥有写权限
        maxDelays = 5,
        delay = 30,
        -- init = true,
        rsync     = {
            binary = "/usr/bin/rsync",
            archive = true,
            compress = true,
            bwlimit   = 2000
            -- rsh = "/usr/bin/ssh -p 22 -o StrictHostKeyChecking=no"
            -- 如果要指定其它端口，请用上面的rsh
            }
        }
    -- V. 远程目录同步，rsync模式 + rsyncssh，效果与上面相同
    sync {
        default.rsyncssh,
        source    = "/tmp/src2",
        host      = "172.29.88.223",
        targetdir = "/remote/dir",
        excludeFrom = "/etc/rsyncd.d/rsync_exclude.lst",
        -- maxDelays = 5,
        delay = 0,
        -- init = false,
        rsync    = {
            binary = "/usr/bin/rsync",
            archive = true,
            compress = true,
            verbose   = true,
            _extra = {"--bwlimit=2000"},
            },
        ssh      = {
            port  =  1234
            }
        }
```
上面的内容几乎涵盖了所有同步的模式，其中第III个要求像rsync一样配置rsyncd服务端，见本文开头。第IV、V配置ssh方式同步，达到的效果相同，但实际同步时你会发现每次同步都会提示输入ssh的密码，可以通过以下方法解决：

在远端被同步的服务器上开启ssh无密码登录，请注意用户身份：

    user$ ssh-keygen -t rsa
    ...一路回车...
    user$ cd ~/.ssh
    user$ cat id_rsa.pub >> authorized_keys

把id_rsa私钥拷贝到执行lsyncd的机器上

    user$ chmod 600 ~/.ssh/id_rsa
    测试能否无密码登录
    user$ ssh user@172.29.88.223

3. lsyncd的其它功能

lsyncd的功能不仅仅是同步，官方手册 Lsyncd 2.1.x ‖ Layer 2 Config ‖ Advanced onAction 高级功能提到，还可以监控某个目录下的文件，根据触发的事件自己定义要执行的命令，example是监控某个某个目录，只要是有jpg、gif、png格式的文件参数，就把它们转成pdf，然后同步到另一个目录。正好在我运维的一个项目中有这个需求，现在都是在java代码里转换，还容易出现异常，通过lsyncd可以代替这样的功能。但，门槛在于要会一点点lua语言（根据官方example还是可以写出来）。

另外偶然想到个问题，同时设置了maxDelays和delay，当监控目录一直没有文件变化了，也会发生同步操作，虽然没有可rsync的文件。

TO-DO：

    其它同步工具：csync2，clsync，btsync，drdb 。
    lsyncd双向同步：GlusterFS

    参考

        Lsyncd21Manual （本文很大一部分翻译自官网手册）
        使用lsyncd配置数据库备份多异地同步
        如何实时同步大量小文件
        Lsyncd 测试远程、本地目录自动同步
