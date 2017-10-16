---
title: Linux命令 Cryptsetup
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [Cryptsetup]
---
在Linux系统中，基于DEVICE MAPPER机制对设备进行管理，通过在物理设备和逻辑设备之间创建mapping，从而在系统中通过对逻辑设备的操作实现对物理设备的操作。device mapper机制主要包括三个部分：用户空间部分、内核部分和dm-setup。在本文中，将介绍如何使用cryptsetup对存储设备进行加密。

1 设置系统内核
1.1 查看系统是否有crypto加密模块
cat /proc/crypto //ook over crypt methods , eg. aes
如果模块不存在，使用如下命令进行安装：
sudo modprobe aes
1.2 安装dmsetup、cryptsetup
sudo apt-get install dmsetup cryptsetup
1.3 加载dm-crypt内核模块
首先查看dmsetup是否已经建立了映像
ls -l /dev/mapper/control //接下来加载dm-crypt内核模块
已经建立映像之后加载dm-crypt内核模块，使用如下命令：
sudo modprobe dm-crypt  //dm-crypt加载后，device-mapper自动注册
成功加载之后，查看是否已经正确安装：
sudo dmsetup targets //如果一切顺利，目前你应该看到crypt的下列输出：
crypt            v1.1.0
striped          v1.0.2
linear           v1.0.1
error            v1.0.1
2 建立加密设备
为当便后期使用，直接使用物理设备进行安装测试。
2.1 首先使用cryptsetup来建立逻辑卷，并将其和块设备即物理设备捆绑：
sudo cryptsetup -y create myEncryptedFilesystem /dev/sdb4  //myEncryptedFilesystem 是新建的逻辑卷的名称，/dev/sdb4是将用作加密卷的块设备
/*
* 查看物理设备号可以使用如下命令进行查看：
* sudo fdisk -l
*/
为了确认逻辑卷是否已建立，能使用下列命令进行检查一下：
sudo dmsetup ls //只要该命令列出了逻辑卷，就说明已成功建立了逻辑卷
2.2 在创建完成的逻辑卷即虚拟设备上创建文件系统，进行文件存储
sudo mkfs.ext3 /dev/mapper/myEncryptedFilesystem  //文件系统创建为ext3文件系统
文件系统创建成功后，需要在/mnt文件分区下建立装载点，然后才能将其挂载，创建文件夹命令如下：
sudo mkdir /mnt/myEncryptedFilesystem
文件夹创建完成，将其挂载到新建挂载点/mnt/myEncryptedFilesystem下：
sudo mount /dev/mapper/myEncryptedFilesystem  /mnt/myEncryptedFilesystem
使用如下命令查看其装载后的情况，可以看到文件系统的名称和大小，以及可以使用的空间：
df -h /mnt/myEncryptedFilesystem
Filesystem              Size  Used Avail Use% Mounted on
/dev/mapper/myEncryptedFilesystem     97M  2.1M   90M   2% /mnt/myEncryptedFilesystem
/*
* 仔细观察可以发现，此处的文件系统大小即为物理设备空间大小
* 加密文件系统建立并加载后，可以对其进行正常的文件读写存储,与普通文件系统在这方面没有差别
* 但是在该文件系统下存储的文件均为密文存储
*/
3 卸载加密设备
卸载加密设备，和普通设备卸载方法相同：
sudo umount /mnt/myEncryptedFilesystem
/*
*卸载之后，在dm-crypt中仍然还可以看到有一个虚拟设备，再次装载设备的时候不需要输入口令认证即可
*/
为了保证设备安全性，需要将设备以及逻辑卷全部删除:
sudo cryptsetup remove myEncryptedFilesystem
/*
* 完全卸载后，再次装载设备时，需要进行口令认证
*/


/*
*
* 完全卸载加密设备已经写入shell脚本umount_atuo.sh
* sudo ./umount_auto.sh
*
*/

[plain] view plain copy
#!/bin/sh  
umount /mnt/myFilesystem  
cryptsetup remove myEncryptedFilesystem  

4 重新装载
4.1 在卸载加密设备后，我们非常可能还需作为普通用户来装载他们。为了简化该工作，我们需要在/etc/fstab文件中添加下列内容：
/dev/mapper/myEncryptedFilesystem  /mnt/myEncryptedFilesystem  ext3 noauto,noatime 0 0
[html] view plain copy
* /etc/fstab 包含了电脑上所有的存储设备及其文件系统的信息，是决定一个硬盘（分区）被怎样使用或者说将设备整合到整个系统中的唯一文件  
    * ********************   内容解析  ******************************  
    * 文件中共有如下参数 ： <file system><dir><type><options><dump><pass>  
    * <file system> ： 即设备的名称  
    * <dir> : 设备装载的路径  
    * <type> ： 设备的文件系统类型  
    * <options> ：能使所挂载的设备在开机时自动加载、使中文显示不出现乱码、限制对挂载分区读写权限等多种功能，具体参数如下：  
    *       noatime   关闭atime特性，提高性能，这是一个很老的特性，放心关闭，还能减少loadcycle  
    *       defaults  使用默认设置。等于rw,suid,dev,exec,auto,nouser,async，具体含义看下面的解释  
    *       auto  在启动或在终端中输入mount -a时自动挂载  
    *       noauto  设备（分区）只能手动挂载 The file system can be mounted only explicitly  
    *       IO编码设置 ：  
    *           iocharset＝   在＝号后面加入你的本地编码，在这个设备（分区）中做文件IO的时候就会自动做编码的格式转换。  
    *       中文乱码的解决 ：  
    *           nls=     在=号后面加入你的本地编码，你的中文就不会出现乱码  
    *       可执行 ：  
    *           exec     是一个默认设置项，它使在那个分区中的可执行的二进制文件能够执行。  
    *           noexec  二进制文件不允许执行  
    *       I/O同步 ：  
    *           sync    所有的I/O将以同步方式进行  
    *           async  所有的I/O将以非同步方式进行  
    *       用户挂载权限 :  
    *           user  允许任何用户挂载设备。 Implies noexec,nosuid,nodev unless overridden.  
    *           nouser  只允许root用户挂载。这是默认设置。  
    * <dump> :是dump utility用来决定是否做备份的.允许的数字是0和1。如果是0，dump就会忽略这个文件系统，如果是1，dump就会作一个备份。  
    * <pass> :fsck会检查这个头目下的数字来决定检查文件系统的顺序.允许的数字是0, 1, 和2.0将不会被fsck utility检查。root文件系统应该拥有最高的优先权， 1                  ，而所有其它的文件系统，如果你想让它被check的话，应该写成2  
        *  在和老师交流以及自己测试之后，发现了/etc/fstab的用途，简单来说，就是通过在/etc/fstab文件中添加一条命令，可以简化加载输入。如在/etc/fstab文件中加入/dev/mapper/myEncryptedFilesystem  /mnt/myEncryptedFilesystem 之后，可以直接使用<span style="color:#ff6666;">sudo mount /dev/mapper/myEncryptedFilesystem</span>命令在加载设备，然后/dev/mapper/myEncryptedFilesystem就会按照/etc/fstab文件中添加的命令一样，挂载到/mnt/myEncryptedFilesystem 挂载点目录下。如果没有加入这条命令，那么需要使用<span style="color:#ff6666;">sudo mount /dev/mapper/myEncryptedFilesystem  /mnt/myEncryptedFilesystem</span>命令才能将设备挂载。  
4.2 装载设备

在测试中使用shell脚本进行创建设备和装载设备
/*
* remount.sh脚本实现重载设备功能
* sudo ./remount.sh
*/
#!/bin/sh  
cryptsetup create myEncryptedFilesystem  /dev/sdb4  
mount /dev/mapper/myEncryptedFilesystem  /mnt/myFilesystem  

5 总结
crptsetup是一款能够将设备进行加密的软件，使用时需要先创建本地的逻辑卷即逻辑设比，并通过dmsetup将逻辑设备和物理设备进行mapping，从而将对逻辑设备的操作映射到物理设备。在进行文件存储时，需要先对逻辑设备创建文件系统，并在/mnt文件分区下建立挂载点，将其mount到该挂载点之后，才能对其进行正常操作。一次操作结束之后，需要将设备完全卸载，保证下次装载的安全。
当再一次对物理设备重新装载使用时，只需要重新建立逻辑卷并和物理设备绑定即可，此时需要输入口令进行确认，只有正确输入口令才能够正常挂载，否则无法成功挂载。此外，重新装载不许要重新创建文件系统，否则会将原有数据全部删除。
物理设备（U盘）在加密映射之后，只能通过建立逻辑设备并进行绑定才能够读写，直接连接PC（WIN 、LINUX）只能识别无法操作。但在WIN下可以将其格式化，且无法恢复数据。
当在其他PC上对设备进行读写操作时，也需要建立逻辑设备并对其绑定才能够正常操作。


参考地址：
[1]http://blog.sina.com.cn/s/blog_600e39a801011mo7.html
[2]http://ckc620.blog.51cto.com/631254/394238

欢迎大家查看交流，下一篇将介绍CRYPTSETUP加密存储设备之二（Android篇）
