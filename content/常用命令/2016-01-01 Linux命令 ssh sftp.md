---
title: 完全使用 SFTP 替代 FTP
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [ssh,sftp]
---
如何开启sftp
1. 启用internal-sftp [必须 否则禁止登陆的用户无法使用sftp]
  `sed -i 's|Subsystem sftp /usr/lib/openssh/sftp-server|Subsystem sftp internal-sftp|' /etc/ssh/sshd_config`
2. 创建sftp用户
  ` useradd -o -r -u 33 -g www-data -c sftp -d /home/wwwroot/default/bizchinalinyi -s /usr/sbin/nologin sftp `
  ` useradd -o -r -u 1000 -g ftp -c sftp -d /docker/destoon/bizchinalinyi -s /usr/sbin/nologin sftp `
  ` useradd -o -r -u 0 -g root -c sftp -d /docker/tomcat/ -s /usr/sbin/nologin tomcat ` infotop.123
3. 修改密码
  ` passwd sftp  LinyiBR@2017@`
4. 登陆
  `sftp -P 3009 sftp@ `

--------------------------------------------------------------------------------
系统内开启ssh服务和sftp服务都是通过/usr/sbin/sshd这个后台程序监听22端口，而sftp服务作为一个子服务，是通过/etc/ssh/sshd_config配置文件中的Subsystem实现的，如果没有配置Subsystem参数，则系统是不能sftp访问的。

使用 internal-sftp 未登陆用户可以使用sftp

默认：只有登陆的用户才能使用sftp  usermod -s /bin/bash www-data
`sed -i 's|Subsystem sftp /usr/lib/openssh/sftp-server|Subsystem sftp internal-sftp|' /etc/ssh/sshd_config`


```sh
#!/bin/bash

sed -i 's|Subsystem sftp /usr/lib/openssh/sftp-server|Subsystem sftp internal-sftp|' /etc/ssh/sshd_config

groupadd sftpusergroup

echo "Match Group sftpusergroup" >> /etc/ssh/sshd_config
echo "    ChrootDirectory /sftp/%u" >> /etc/ssh/sshd_config
echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config
echo "    AllowTCPForwarding no" >> /etc/ssh/sshd_config
echo "    X11Forwarding no" >> /etc/ssh/sshd_config

mkdir /sftp
chown -R root:root /sftp
chmod 755 /sftp

/etc/init.d/sshd restart
```
完全使用 SFTP 替代 FTP ：SFTP+OpenSSH+ChrootDirectory 设置详解

    本站文章除注明转载外，均为本站原创或者翻译。
    本站文章欢迎各种形式的转载，但请18岁以上的转载者注明文章出处，尊重我的劳动，也尊重你的智商；
    本站部分原创和翻译文章提供markdown格式源码，欢迎使用文章源码进行转载；
    本博客采用 WPCMD 维护；
    本文标题：完全使用 SFTP 替代 FTP ：SFTP+OpenSSH+ChrootDirectory 设置详解
    本文链接：http://zengrong.net/post/1616.htm

完全使用SFTP替代FTP：SFTP+OpenSSH+ChrootDirectory设置详解

2012-09-28更新:加入web服务器需求的内容。

由于采用明文传输用户名和密码，FTP协议是不安全的。在同一机房中只要有一台服务器被攻击者控制，它就可能获取到其它服务器上的FTP密码，从而控制其它的服务器。

当然，很多优秀的FTP服务器都已经支持加密。但如果服务器上已经开了SSH服务，我们完全可以使用SFTP来传输数据，何必要多开一个进程和端口呢？

下面，我就从账户设置、SSH设置、权限设置这三个方面来讲讲如何使用SFTP完全替代FTP。本教程基于CentOS5.4。
范例

本文要实现以下功能：

SFTP要管理3个目录：

    homepage
    blog
    pay

权限配置如下：

    账户www，可以管理所有的3个目录；
    账户blog，只能管理blog目录；
    账户pay，只能管理pay目录。

web服务器需求：

    账户blog管理的目录是一个博客网站，使用apache服务器。apache服务器的启动账户是apache账户，组为apache组。
    账户blog属于apache组，它上传的文件能够被apache服务器删除。同样的，它也能删除在博客中上传的文件（就是属于apache账户的文件）。

账户设置

SFTP的账户直接使用Linux操作系统账户，我们可以用useradd命令来创建账户。

## 首先建立3个要管理的目录：

mkdir /home/sftp/homepage
mkdir /home/sftp/blog
mkdir /home/sftp/pay

## 创建sftp组和www、blog、pay账号，这3个账号都属于sftp组：

groupadd sftp

useradd -M -d /home/sftp -G sftp www
useradd -M -d /home/sftp/blog -G sftp blog
useradd -M -d /home/sftp/pay -G sftp pay

## 将blog账户也加到apache组
useradd -M -d /home/sftp/blog -G apache blog

## 设置3个账户的密码密码
passwd www
passwd blog
passwd pay

至此账户设置完毕。
SSH设置

设置sshd_config。通过Chroot限制用户的根目录。

vim /etc/ssh/sshd_config
```sh
#注释原来的Subsystem设置 **必须
# Subsystem   sftp    /usr/libexec/openssh/sftp-server # <<<< 原来的这行注释掉

#启用internal-sftp
Subsystem       sftp    internal-sftp
#限制www用户的根目录
Match User www
    ChrootDirectory /home/sftp
    ForceCommand    internal-sftp
#限制blog和pay用户的根目录
Match Group sftp
    ChrootDirectory %h
    ForceCommand    internal-sftp

# Example of overriding settings on a per-user basis
Match User sftp               # <<----   匹配用户为 sftp ,  man sshd_config 有更详细的介绍,还支持用户组,同进设置多用户等
    ChrootDirectory  /home/%u #  <<-------指定chroot的目录, %u 为转换成用户名, 也就是 /home/sftp 目录了,帮助上显示 %h就带表home了
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp #    <<---- 添加这句  internal-sftp
    #ForceCommand cvs server   # <<--- 这句也注释掉
```
完成这一步之后，尝试登录SFTP：

sftp -P222 sftp@abc.com
#或者
ssh www@abc.com
#如果出现下面的错误信息，则可能是目录权限设置错误，继续看下一步
#Connection to abc.com closed by remote host.
#Connection closed

权限设置

要实现Chroot功能，目录权限的设置非常重要。否则无法登录，给出的错误提示也让人摸不着头脑，无从查起。我在这上面浪费了很多时间。

目录权限设置上要遵循2点：

    ChrootDirectory设置的目录权限及其所有的上级文件夹权限，属主和属组必须是root；
    ChrootDirectory设置的目录权限及其所有的上级文件夹权限，只有属主能拥有写权限，也就是说权限最大设置只能是755。

如果不能遵循以上2点，即使是该目录仅属于某个用户，也可能会影响到所有的SFTP用户。

chown root.root /home/sftp /home/sftp/homepage /home/sftp/blog /home/sftp/pay
chmod 755 /home/sftp /home/sftp/homepage /home/sftp/blog /home/sftp/pay

由于上面设置了目录的权限是755，因此所有非root用户都无法在目录中写入文件。我们需要在ChrootDirectory指定的目录下建立子目录，重新设置属主和权限。以homepage目录为例：

mkdir /home/sftp/homepage/web
chown www.sftp /home/sftp/homepage/web
chmod 775 /home/sftp/homepage/web

要实现web服务器与blog账户互删文件的权限需求，需要设置umask，让默认创建的文件和目录权限为775即可。将下面的内容写入.bashrc中：

umask 0002

至此，我们已经实现了所有需要的功能。
参考资料

    http://www.mike.org.cn/articles/centos-sftp-chroot/
    http://www.mike.org.cn/articles/centos-install-openssh/
    http://www.ctohome.com/FuWuQi/29/554.html
    http://rainbird.blog.51cto.com/211214/275162/
    http://www.debian-administration.org/articles/590

关联文章

    Apache不显示符号链接的处理办法
    升级CentOS 5.x中的PHP 5.1到5.3
    Gitweb 和 WebSVN
    【转】Bash命令行历史权威指南
    [转]每个人都是CEO

基于 ssh 的 sftp 服务相比 ftp 有更好的安全性（非明文帐号密码传输）和方便的权限管理（限制用户的活动目录）。

1、开通 sftp 帐号，使用户只能 sftp 操作文件， 而不能 ssh 到服务器

2、限定用户的活动目录，使用户只能在指定的目录下活动，使用 sftp 的 ChrootDirectory 配置

确定版本

#确保 ssh 的版本高于 4.8p1 否则升级一下 一般都高于这个版本
ssh -V

新建用户和用户组

#添加用户组 sftp
groupadd sftp
#添加用户 指定家目录 指定用户组 不允许shell登录
useradd -d /home/sftp -m -g sftp -s /bin/false sftp
#设置用户密码
passwd sftp

活动目录

#设定你想要的活动目录
mkdir -p /var/www/sftp
#配置权限
chown root:sftp /var/www/sftp

配置 sftp

# ssh 服务的配置文件
vi /etc/ssh/sshd_config

在文件末有如下配置

internal-sftp 是 linux 自带的 sftp 服务 可以满足我们的基本需求

ChrootDirectory 用户的可活动目录 还可以用 %h代表用户家目录 %u代表用户名

#这里我们使用系统自带的 internal-sftp 服务即可满足需求
#Subsystem      sftp    /usr/libexec/openssh/sftp-server
Subsystem      sftp    internal-sftp

Match Group sftp
  ChrootDirectory /var/www/sftp # 还可以用 %h代表用户家目录 %u代表用户名
  ForceCommand    internal-sftp # 使用系统自带的 internal-sftp 服务
  AllowTcpForwarding no
  X11Forwarding no

# 这里要特别的注意一点，ChrootDirectory 的权限问题

====================================================================================

1、由ChrootDirectory指定的目录开始一直往上到系统根目录为止的目录拥有者都只能是root

2、由ChrootDirectory指定的目录开始一直往上到系统根目录为止都不可以具有群组写入权限

比如我们现在例子中的 /var/www/sftp 文件夹

1、/var/www/sftp 的各层级目录都必须属于 root 用户， 这里我们将 sftp 目录设为了 root:sftp 的所属权限

2、/var/www/sftp 的各层级目录的最大权限为 0755，所以如果你想要上传文件，必须在此目录下新建登录用户可读写的权限目录，你可以在你的活动目录下新建一个登录用户有读写权限的目录，如下

cd /var/www/sftp
mkdir uploads
#保证目录有读写权限
chown sftp:sftp uploads

====================================================================================

配置完成 重启 sshd 服务

service sshd restart

下面就可以使用 ftp 客户端 的 sftp 协议 或 sftp 命令登录服务器了，且只能在我们指定的目录下活动
