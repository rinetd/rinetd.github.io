---
title:  Linux 用文件作为Swap分区
date: 2016-09-27T15:58:27+08:00
update: 2016-09-27 16:03:41
categories: [Linux基础]
tags:
---
由于未知原因，开发服务器没有配置swap（交换分区）。
虽然有4GB物理内存撑场面，但还是架不住多个tomcat+jetty的啃食，服务器频频死机！
这时候增加SWAP物理分区是不可能了，但我们可以通过增加swap文件的方式增加swap！

1.使用dd命令创建一个指定大小的文档 将swap文件写在/var/swap！

dd if=/dev/zero of=/swapfile bs=1M count=8096


2.使用mkswap创建swap

mkswap /swapfile

3.通过swapon命令开启swap分区

swapon /swapfile

4.查看swap分区状况

`swapon -s`  或 `cat /proc/swaps`  

在/etc/fstab中增加如下语句：
<file system> <mount point> <type>  <options> <dump> <pass>
`/var/swap  swap  swap    defaults 0 0`
`/swapfile                                 none            swap    sw              0       0`

  mount:   对于swap分区，这个域应该填写：none，表示没有挂载点。
  type：   adfs、cifs、ext3、iso9660、kafs、minix、msdos、vfat、umsdos、proc、swap、 squashfs、nfs、ntfs、affs、ufs
  options: defaults，它代表包含了选项rw,suid,dev,exec,auto,nouser和 async。

5.如果不再需要swap，可以清理该分区，关闭swap

swapoff /tmp/swap

-------------------------------------------------------------------------------
# 格式化分区  
mkfs.ext3 /dev/sda5   
# 将分区转换成交换分区  
#1、格式化交换分区［mkswap］  
mkswap /dev/sda5   

#2、激活交换分区［swapon］  
swapon /dev/sda5  

# 将交换分区转换成EXT3格式  
#1、关闭交换分区［swapoff］  
swapoff /dev/sda5  

#2、重新格式化分区[mkfs.ext3]  
mkfs.ext3 /dev/sda5  
# 设置磁盘巻标  
e2label /dev/sda5 sky  
# 查看巻标  
e2label /dev/sda5  
# 根据巻标查看硬盘  
findfs LABEL=sky  


注：top命令下，想关参数含义

    * %mem 内存使用率
    * virt  虚拟内存
    * res  常驻内存
    * shr  共享内存

VIRT：virtual memory usage。Virtual这个词很神，一般解释是：virtual adj.虚的, 实质的, [物]有效的, 事实上的。到底是虚的还是实的？让Google给Define之后，将就明白一点，就是这东西还是非物质的，但是有效果的，不发生在真实世界的，发生在软件世界的等等。这个内存使用就是一个应用占有的地址空间，只是要应用程序要求的，就全算在这里，而不管它真的用了没有。写程序怕出错，又不在乎占用的时候，多开点内存也是很正常的。

RES：resident memory usage。常驻内存。这个值就是该应用程序真的使用的内存，但还有两个小问题，一是有些东西可能放在交换盘上了（SWAP），二是有些内存可能是共享的。
SHR：shared memory。共享内存。就是说这一块内存空间有可能也被其他应用程序使用着；而Virt － Shr似乎就是这个程序所要求的并且没有共享的内存空间。

DATA：数据占用的内存。如果top没有显示，按f键可以显示出来。这一块是真正的该程序要求的数据空间，是真正在运行中要使用的。
