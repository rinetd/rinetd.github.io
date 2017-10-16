---
title: Linux 下/etc/fstab文件详解
date: 2016-09-27T15:58:27+08:00
update: 2016-09-27 16:03:41
categories: [Linux基础]
tags:
---
有很多人经常修改/etc/fstab文件，但是其中却有很多人对这个文件所表达的意义不太清楚，因为只要按照一定的模式，就可以轻而易举地添加一行挂载信息，而不需要完全理解其中的原理。

/etc/fstab是用来存放文件系统的静态信息的文件。位于/etc/目录下，可以用命令less /etc/fstab 来查看，如果要修改的话，则用命令 vi /etc/fstab 来修改。

当系统启动的时候，系统会自动地从这个文件读取信息，并且会自动将此文件中指定的文件系统挂载到指定的目录。下面我来介绍如何在此文件下填写信息。

在这个文件下，我们要关注的是它的六个域，分别为：<file system>、<mount point>、<type> 、<options>、<dump>、<pass>。下面将详细介绍这六个域的详细意义。

1. <fie sysytem>。这里用来指定你要挂载的文件系统的设备名称或块信息，也可以是远程的文件系统。做过嵌入式linux开发的朋友都可能知道 mount 192.168.1.56:/home/nfs /mnt/nfs/ -o nolock (可以是其他IP)命令所代表的意义。它的任务是把IP为192.168.1.56的远程主机上的/home/nfs/目录挂载到本机的/mnt/nfs /目录之下。如果要把它写进/etc/fstab文件中，file system这部分应填写为：/192.168.1.56:/home/nfs/。

如果想把本机上的某个设备（device）挂载上来，写法如：/dev/sda1、/dev/hda2或/dev/cdrom，其中，/dev/sda1 表示第一个串口硬盘的第一个分区，也可以是第一个SCSI硬盘的第一个分区，/dev/hda1表示第一个IDE硬盘的第一个分区，/dev/cdrom 表示光驱。

此外，还可以label(卷标)或UUID（Universally Unique Identifier全局唯一标识符）来表示。用label表示之前，先要e2label创建卷标，如：e2label /dir_1 /dir_2，其意思是说用/dir_2来表示/dir_1的名称。然后，再在/etc/fstab下按如下形式添加：LABEL=/dir_2 /dir_2 <type>   <options> <dump> <pass>。重启后，系统就会将/dir_1挂载到/dir_2目录上。对于UUID，可以用blkid -o value -s UUID /dev/sdxx来获取。比如我想挂载第一块硬盘的第十一个分区，先用命令blkid -o value -s UUID /dev/sda11 来取得UUID，比如是：5dc08a62-3472-471b-9ef5-0a91e5e2c126，然后在<file system>这个域上填写： UUID=5dc08a62-3472-471b-9ef5-0a91e5e2c126，即可表示/dev/sda11。Red Hat linux 一般会使用label，而Ubuntu linux 一般会用UUID。

2. <mount point>。挂载点，也就是自己找一个或创建一个dir（目录），然后把文件系统<fie sysytem>挂到这个目录上，然后就可以从这个目录中访问要挂载文件系统。对于swap分区，这个域应该填写：none，表示没有挂载点。

3. <type>。这里用来指定文件系统的类型。下面的文件系统都是目前Linux所能支持的：adfs、befs、cifs、ext3、 ext2、ext、iso9660、kafs、minix、msdos、vfat、umsdos、proc、reiserfs、swap、 squashfs、nfs、hpfs、ncpfs、ntfs、affs、ufs。

4. <options>。这里用来填写设置选项，各个选项用逗号隔开。由于选项非常多，而这里篇幅有限，所以不再作详细介绍，如需了解，请用命令 man mount 来查看。但在这里有个非常重要的关键字需要了解一下：defaults，它代表包含了选项rw,suid,dev,exec,auto,nouser和 async。

5. <dump>。此处为1的话，表示要将整个<fie sysytem>里的内容备份；为0的话，表示不备份。现在很少用到dump这个工具，在这里一般选0。

6. <pass>。这里用来指定如何使用fsck来检查硬盘。如果这里填0，则不检查；挂载点为 / 的（即根分区），必须在这里填写1，其他的都不能填写1。如果有分区填写大于1的话，则在检查完根分区后，接着按填写的数字从小到大依次检查下去。同数字的同时检查。比如第一和第二个分区填写2，第三和第四个分区填写3，则系统在检查完根分区后，接着同时检查第一和第二个分区，然后再同时检查第三和第四个分区。


参考文献：
1、On-line reference manuals of Linux (用命令 man 5 fstab 查看)。
2、Linux Bible 2008 Edition.   By Christopher Negus. Published by Wiley Publishing, Inc.2008
3、Linux Administration Handbook (Second Edition)    By [US] Evi Nemeth   Garth Snyder   Trent R. Hein .    Published by Pearson Education,Inc.2007
