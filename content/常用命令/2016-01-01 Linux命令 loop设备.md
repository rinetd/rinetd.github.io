---
title: Linux命令 loop
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [losetup]
---
loop设备介绍
   在类 UNIX 系统里，loop 设备是一种伪设备(pseudo-device)，或者也可以说是仿真设备。它能使我们像块设备一样访问一个文件。
在使用之前，一个 loop 设备必须要和一个文件进行连接。这种结合方式给用户提供了一个替代块特殊文件的接口。因此，如果这个文件包含有一个完整的文件系统，那么这个文件就可以像一个磁盘设备一样被 mount 起来。
   上面说的文件格式，我们经常见到的是 CD 或 DVD 的 ISO 光盘镜像文件或者是软盘(硬盘)的 * .img 镜像文件。通过这种 loop mount (回环mount)的方式，这些镜像文件就可以被 mount 到当前文件系统的一个目录下。
   至此，顺便可以再理解一下 loop 之含义：对于第一层文件系统，它直接安装在我们计算机的物理设备之上；而对于这种被 mount 起来的镜像文件(它也包含有文件系统)，它是建立在第一层文件系统之上，这样看来，它就像是在第一层文件系统之上再绕了一圈的文件系统，所以称为 loop。
1.创建一个100M大小的映像文件
`dd if=/dev/zero of=test.img bs=10m count=100`
2.查找空闲的loop设备
`losetup -f`
3.将映像文件挂接到loop4中。
`losetup /dev/loop4 test.img`
4.对loop4进行分区
fdisk /dev/loo4
spacer.gif223212936.png
5.使用kpartx将分区装载到映像文件中
kpartx -av test.img
6.格式化分区
mkfs.ext4 /dev/loo4p1
这时，我们已经可以在/dev/mapper下看到loop4的映射，然后挂载之：
mount /dev/mapper/loo4p1 /mnt



卸载：
umount /mnt
kpartx -dv /dev/loop4
losetup -d /dev/loop4
如果挂载的映像文件，本身有分区，通过空间的loop设备挂接以后，可通过kpartx -av直接进行装载。
losetup -f
losetup /dev/loop4 test.img
kpartx -av /dev/loop4
mount /dev/loop4p1 /mnt
