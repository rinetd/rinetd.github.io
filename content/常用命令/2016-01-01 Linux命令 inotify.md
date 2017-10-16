---
title: Linux命令 Inotifywatch
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags:
---
inotify+rsync实时同步


inotifywait -mrq --timefmt '%d/%m/%y/%H:%M' --format '%T %w %f' -e modify,delete,create,attrib

inotifywait命令参数
 -m是要持续监视变化。
 -r使用递归形式监视目录。
 -q减少冗余信息，只打印出需要的信息。
 -e指定要监视的事件列表。
 --timefmt是指定时间的输出格式。
 --format指定文件变化的详细信息。

可监听的事件 事件 描述
access 访问，读取文件。
modify 修改，文件内容被修改。
attrib 属性，文件元数据被修改。
move 移动，对文件进行移动操作。
create 创建，生成新文件
open 打开，对文件进行打开操作。
close 关闭，对文件进行关闭操作。
delete 删除，文件被删除。

来自: http://man.linuxde.net/inotifywait

inotifywait 单独分析

/usr/local/bin/inotifywait -mrq --format '%Xe %w%f' -e modify,create,delete,attrib /data/

执行上面命令，是让inotifywait监听/data/目录，当监听到有发生modify,create,delete,attrib等事件发生时，按%Xe %w%f的格式输出。

在/data/目录touch几个文件
touch /data/{1..5}

观看inotify输出
ATTRIB /data/1           -- 表示发生了ATTRIB事件 路径为/data/1
ATTRIB /data/2
ATTRIB /data/3
ATTRIB /data/4
ATTRIB /data/5


知道上面的输出效果之后 我们应该想得到，可以用rsync获取inotifywait监控到的文件列表来做指定的文件同步，而不是每次都由rsync做全目录扫描来判断文件是否存在差异。
网上的inotify+rsync分析

我们来看网上的教程，我加了注释。(网上所有的教程基本都一模一样，尽管写法不一样，致命点都是一样的)
#!/bin/bash
/usr/bin/inotifywait -mrq --format '%w%f'-e create,close_write,delete /backup |while read file
#把发生更改的文件列表都接收到file 然后循环，但有什么鬼用呢？下面的命令都没有引用这个$file 下面做的是全量rsync
do
    cd /backup && rsync -az --delete /backup/ rsync_backup@192.168.24.101::backup/--password-file=/etc/rsync.password
done


#注意看 这里的rsync 每次都是全量的同步(这就坑爹了)，而且 file列表是循环形式触发rsync ，等于有10个文件发生更改，就触发10次rsync全量同步(简直就是噩梦)，那还不如直接写个死循环的rsync全量同步得了。

#有很多人会说 日志输出那里明明只有差异文件的同步记录。其实这是rsync的功能，他本来就只会输出有差异需要同步的文件信息。不信你直接拿这句rsync来跑试试。

#这种在需要同步的源目录文件量很大的情况下，简直是不堪重负。不仅耗CPU还耗时，根本不可以做到实时同步。

备注：backup为rsync server配置module，除了编写脚本以外，还需要配置一个rsync server，rsync server配置参考《http://www.ttlsa.com/linux/rsync-install-on-linux/》
改良方法

要做到实时，就必须要减少rsync对目录的递归扫描判断，尽可能的做到只同步inotify监控到已发生更改的文件。结合rsync的特性，所以这里要分开判断来实现一个目录的增删改查对应的操作。

脚本如下
```sh
#!/bin/bash
src=/data/                           # 需要同步的源路径
des=data                             # 目标服务器上 rsync --daemon 发布的名称，rsync --daemon这里就不做介绍了，网上搜一下，比较简单。
rsync_passwd_file=/etc/rsyncd.passwd            # rsync验证的密码文件
ip1=192.168.0.18                 # 目标服务器1
ip2=192.168.0.19                 # 目标服务器2
user=root                            # rsync --daemon定义的验证用户名
cd ${src}                              # 此方法中，由于rsync同步的特性，这里必须要先cd到源目录，inotify再监听 ./ 才能rsync同步后目录结构一致，有兴趣的同学可以进行各种尝试观看其效果
/usr/local/bin/inotifywait -mrq --format  '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file         # 把监控到有发生更改的"文件路径列表"循环
do
        INO_EVENT=$(echo $file | awk '{print $1}')      # 把inotify输出切割 把事件类型部分赋值给INO_EVENT
        INO_FILE=$(echo $file | awk '{print $2}')       # 把inotify输出切割 把文件路径部分赋值给INO_FILE
        echo "-------------------------------$(date)------------------------------------"
        echo $file
        #增加、修改、写入完成、移动进事件
        #增、改放在同一个判断，因为他们都肯定是针对文件的操作，即使是新建目录，要同步的也只是一个空目录，不会影响速度。
        if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]         # 判断事件类型
        then
                echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'
                rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip1}::${des} &&         # INO_FILE变量代表路径哦  -c校验文件内容
                rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip2}::${des}
                 #仔细看 上面的rsync同步命令 源是用了$(dirname ${INO_FILE})变量 即每次只针对性的同步发生改变的文件的目录(只同步目标文件的方法在生产环境的某些极端环境下会漏文件 现在可以在不漏文件下也有不错的速度 做到平衡) 然后用-R参数把源的目录结构递归到目标后面 保证目录结构一致性
        fi
        #删除、移动出事件
        if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
        then
                echo 'DELETE or MOVED_FROM'
                rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip1}::${des} &&
                rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip2}::${des}
                #看rsync命令 如果直接同步已删除的路径${INO_FILE}会报no such or directory错误 所以这里同步的源是被删文件或目录的上一级路径，并加上--delete来删除目标上有而源中没有的文件，这里不能做到指定文件删除，如果删除的路径越靠近根，则同步的目录月多，同步删除的操作就越花时间。这里有更好方法的同学，欢迎交流。
        fi
        #修改属性事件 指 touch chgrp chmod chown等操作
        if [[ $INO_EVENT =~ 'ATTRIB' ]]
        then
                echo 'ATTRIB'
                if [ ! -d "$INO_FILE" ]                 # 如果修改属性的是目录 则不同步，因为同步目录会发生递归扫描，等此目录下的文件发生同步时，rsync会顺带更新此目录。
                then
                        rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip1}::${des} &&            
                        rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip2}::${des}
                fi
        fi
done
```


每两小时做1次全量同步

因为inotify只在启动时会监控目录，他没有启动期间的文件发生更改，他是不知道的，所以这里每2个小时做1次全量同步，防止各种意外遗漏，保证目录一致。
crontab -e
`* */2 * * * rsync -avz --password-file=/etc/rsync-client.pass /data/ root@192.168.0.18::data && rsync -avz --password-file=/etc/rsync-client.pass /data/ root@192.168.0.19::data`

改良后我们公司这种百万级小文件也能做到实施同步了。
下面附上inotify的参数说明

inotify介绍-- 是一种强大的、细颗粒的、异步的文件系统监控机制，内核从2.6.13起，加入Inotify可以监控文件系统中添加、删除、修改移动等各种事件，利用这个内核接口，就可以监控文件系统下文件的各种变化情况。

inotifywait 参数说明
参数名称 	参数说明
-m,–monitor 	始终保持事件监听状态
-r,–recursive 	递归查询目录
-q,–quiet 	只打印监控事件的信息
–excludei 	排除文件或目录时，不区分大小写
-t,–timeout 	超时时间
–timefmt 	指定时间输出格式
–format 	指定时间输出格式
-e,–event 	后面指定删、增、改等事件

inotifywait events事件说明
事件名称 	事件说明
access 	读取文件或目录内容
modify 	修改文件或目录内容
attrib 	文件或目录的属性改变
close_write 	修改真实文件内容
close_nowrite 	
close 	
open 	文件或目录被打开
moved_to 	文件或目录移动到
moved_from 	文件或目录从移动
move 	移动文件或目录移动到监视目录
create 	在监视目录下创建文件或目录
delete 	删除监视目录下的文件或目录
delete_self 	
unmount 	卸载文件系统
优化 Inotify

# 在/proc/sys/fs/inotify目录下有三个文件，对inotify机制有一定的限制
[root@web ~]# ll /proc/sys/fs/inotify/
总用量0
-rw-r--r--1 root root 09月923:36 max_queued_events
-rw-r--r--1 root root 09月923:36 max_user_instances
-rw-r--r--1 root root 09月923:36 max_user_watches

-----------------------------
max_user_watches #设置inotifywait或inotifywatch命令可以监视的文件数量(单进程)
max_user_instances #设置每个用户可以运行的inotifywait或inotifywatch命令的进程数
max_queued_events #设置inotify实例事件(event)队列可容纳的事件数量
----------------------------

[root@web ~]# echo 50000000>/proc/sys/fs/inotify/max_user_watches -- 把他加入/etc/rc.local就可以实现每次重启都生效
[root@web ~]# echo 50000000>/proc/sys/fs/inotify/max_queued_events
