---
title: 10个核心的Linux面试问题与答案
date: 2016-10-05T16:46:14+08:00
update: 2016-09-28 10:22:41
categories:
tags:
---
10个核心的Linux面试问题与答案
=============================

**1. 问： 当你需要给命令绑定一个宏或者按键的时候，应该怎么做呢？**

答：可以使用bind命令，bind可以很方便地在shell中实现宏或按键的绑定。

在进行按键绑定的时候，我们需要先获取到绑定按键对应的字符序列。

比如获取F12的字符序列获取方法如下：先按下`Ctrl+V,然后按下F12` .我们就可以得到F12的`字符序列 ^\[\[24~`。

接着使用bind进行绑定。

<span class="crayon-title"></span>

\[root@localhost ~\]\# bind ‘”\\e\[24~":"date"'
 

注意：相同的按键在不同的终端或终端模拟器下可能会产生不同的字符序列。

【附】也可以使用showkey -a命令查看按键对应的字符序列。

 

**2. 问： 如果一个linux新手想要知道当前系统支持的所有命令的列表，他需要怎么做？**

答： 使用命令compgen ­-c，可以打印出所有支持的命令列表。


**3. 问：如果你的助手想要打印出当前的目录栈，你会建议他怎么做？**

答：使用Linux 命令dirs可以将当前的目录栈打印出来。

<span class="crayon-title"></span>

\[root@localhost ~\]\# dirs /usr/share/X11

【附】：目录栈通过pushd popd 来操作。

 

**4. 问： 你的系统目前有许多正在运行的任务，在不重启机器的条件下，有什么方法可以把所有正在运行的进程移除呢？**

答： 使用linux命令 ’disown -r ’可以将所有正在运行的进程移除。

 

**5. 问： bash shell 中的hash 命令有什么作用？**

答：linux命令’hash’管理着一个内置的哈希表，记录了已执行过的命令的完整路径, 用该命令可以打印出你所使用过的命令以及执行的次数。

<span class="crayon-title"></span>

\[root@localhost ~\]\# hash hits command 2 /bin/ls 2 /bin/su


**6. 问：哪一个bash内置命令能够进行数学运算。**

答： bash shell 的内置命令let 可以进行整型数的数学运算。

<span class="crayon-title"></span>

\#! /bin/bash … … let c=a+b … …

**8. 问：数据字典属于哪一个用户的？**

答：数据字典是属于’SYS’用户的，用户‘SYS’ 和 ’SYSEM’是由系统默认自动创建的。

 

**9 .  问： 怎样查看一个linux命令的概要与用法？**

假设你在/bin目录中偶然看到一个你从没见过的的命令，怎样才能知道它的作用和用法呢？

答 ： 使用命令whatis 可以先出显示出这个命令的用法简要，比如，你可以使用whatis zcat 去查看‘zcat’的介绍以及使用简要。


\[root@localhost ~\]\# whatis zcat zcat \[gzip\] (1) – compress or expand files
`whatis git-submodule`
git-submodule (1)    - Initialize, update or inspect submodules


**10.  <span style="font-family: 宋体;">问：使用哪一个命令可以查看自己文件系统的磁盘空间配额呢？</span>**

答： 使用命令<span style="font-family: 'Times New Roman';">repquota </span><span style="font-family: 宋体;">能够显示出一个文件系统的配额信息</span>

【附】只有<span style="font-family: 'Times New Roman';">root</span><span style="font-family: 宋体;">用户才能够查看其它用户的配额。</span>

 

到这里，整个面试就结束啦，请将您的宝贵意见在评论中反馈给我们，敬请期待更多的Linux以及开源软件文章。

 
