---
title: Linux命令 fstabl
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [fstab]
---

# 挂载Windows ntfs

/dev/sda2 /mnt/sda2 auto rw,nodev,user,owner,nodiratime,noatime,umask=033,uid=1000,gid=1000,nofail 0 0

time sync


fstab文件介绍

fstab文件包含了你的电脑上的存储设备及其文件系统的信息。它是决定一个硬盘（分区）被怎样使用或者说整合到整个系统中的文件。具体来说：用fstab可以自动挂载各种文件系统格式的硬盘、分区、可移动设备和远程设备等。对于Windows与Linux双操作系统用户，用fstab挂载FAT格式和NTFS格式的分区，可以在Linux中共享windows系统下的资源。

这个文件的全路径是/etc/fstab。它只是一个文本文件，你能够用你喜欢的编辑器打开它，但是必须是root用户才能编辑它。同时fsck、mount、umount的等命令都利用该程序。

/etc/fstab 是启动时的配置文件，不过，实际 filesystem 的挂载是记录到 /etc/mtab 与 /proc/mounts 这两个文件当中的。每次我们在更动 filesystem 的挂载时，也会同时更动这两个文件喔！
系统挂载的一些限制：

        根目录 / 是必须挂载的﹐而且一定要先于其它 mount point 被挂载进来。
        其它 mount point 必须为已创建的目录﹐可任意指定﹐但一定要遵守必须的系统目录架构原则
        所有 mount point 在同一时间之内﹐只能挂载一次。
        所有 partition 在同一时间之内﹐只能挂载一次。
        如若进行卸除﹐您必须先将工作目录移到 mount point(及其子目录) 之外。

文件各字段解释

示例：

# <fs>            <mountpoint>    <type>        <opts>        <dump/pass>

# NOTE: If your BOOT partition is ReiserFS, add the notail option to opts.

/dev/sda10        /boot            ext4        noauto,noatime    1 2
/dev/sda6         /                ext4        noatime           0 1
/dev/sda9         none             swap        sw                0 0
/dev/cdrom        /mnt/cdrom       auto        noauto,ro         0 0

其实 /etc/fstab (filesystem table) 就是将我们利用 mount 命令进行挂载时， 将所有的选项与参数写入到这个文件中就是了。除此之外， /etc/fstab 还加入了 dump 这个备份用命令的支持！ 与启动时是否进行文件系统检验 fsck 等命令有关。

        <file systems> 挂载设备 : 不是我们通常理解的文件系统，而是指设备（硬盘及其分区，DVD光驱等）。它告知我们设备（分区）的名字，这是你在命令行中挂载（mount）、卸载（umount）设备时要用到的。
        <mountpoint> 挂载点：告诉我们设备挂载到哪里。
        <type> 文件系统类型：Linux支持许多文件系统。 要得到一个完整的支持名单查找mount man-page。典型 的名字包括这些：ext2, ext3, reiserfs, xfs, jfs,iso9660, vfat, ntfs, swap和auto, 'auto' 不是一个文件系统，而是让mount命令自动判断文件类型，特别对于可移动设备，软盘，DVD驱动器，这样做是很有必要的，因为可能每次挂载的文件类型不一致。
        <opts> 文件系统参数：这部分是最有用的设置！！！ 它能使你所挂载的设备在开机时自动加载、使中文显示不出现乱码、限制对挂载分区读写权限。它是与mount命令的用法相关的，要想得到一个完整的列表，参考mount manpage.
        <dump> 备份命令：dump utility用来决定是否做备份的. dump会检查entry并用数字来决定是否对这个文件系统进行备份。允许的数字是0和1。如果是0，dump就会忽略这个文件系统，如果是1，dump就会作一个备份。大部分的用户是没有安装dump的，所以对他们而言<dump>这个entry应该写为0。
        <pass> 是否以fsck检验扇区：启动的过程中，系统默认会以fsck检验我们的 filesystem 是否完整 (clean)。 不过，某些 filesystem 是不需要检验的，例如内存置换空间 (swap) ，或者是特殊文件系统例如 /proc 与 /sys 等等。fsck会检查这个头目下的数字来决定检查文件系统的顺序，允许的数字是0, 1, 和2。0 是不要检验， 1 表示最早检验(一般只有根目录会配置为 1)， 2 也是要检验，不过1会比较早被检验啦！一般来说,根目录配置为1,其他的要检验的filesystem都配置为 2 就好了。

<opts>常用参数：

    noatime 关闭atime特性，提高性能，这是一个很老的特性，放心关闭，还能减少loadcycle
    defaults 使用默认设置。等于rw,suid,dev,exec,auto,nouser,async，具体含义看下面的解释。
    自动与手动挂载:
    auto 在启动或在终端中输入mount -a时自动挂载
    noauto 设备（分区）只能手动挂载
    读写权限:
    ro 挂载为只读权限
    rw 挂载为读写权限
    可执行:
    exec 是一个默认设置项，它使在那个分区中的可执行的二进制文件能够执行
    noexec 二进制文件不允许执行。千万不要在你的root分区中用这个选项！！！
    I/O同步:
    sync 所有的I/O将以同步方式进行
    async 所有的I/O将以非同步方式进行
    户挂载权限:
    user 允许任何用户挂载设备。 Implies noexec,nosuid,nodev unless overridden.
    nouser 只允许root用户挂载。这是默认设置。
    临时文件执行权限：
    suid Permit the operation of suid, and sgid bits. They are mostly used to allow users on a computer system to execute binary executables with temporarily elevated privileges in order to perform a specific task.
    nosuid Blocks the operation of suid, and sgid bits.

重启系统

重启系统，或在终端中输入mount -a就可以看到修改后的效果了。
