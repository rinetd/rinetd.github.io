---
title: Linux命令 lsof
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [lsof]
---
关于端口的一些命令：
lsof  -i  :端口号    ----查看端口进程信息
`sudo lsof -i:80`

关闭某个端口的进程：

  先用lsof -i:端口号 查出这个端口的进程，找出pid，然后kill -9 pid，关闭进程

  或者 直接: fuser -k 80/tcp     

查看端口进程：

  netstat -anp | grep 80
## 进程相关
lsof 文件 #查看文件占用
lsof /etc/passwd //那个进程在占用/etc/passwd
lsof `which httpd` //那个进程在使用apache的可执行文件
lsof -p 30297 //显示那些文件被pid为30297的进程打开
lsof /dev/hda6 //那个进程在占用hda6
lsof /dev/cdrom //那个进程在占用光驱
lsof -c sendmail //查看sendmail进程的文件使用情况
lsof -c courier -u ^zahn //显示出那些文件被以courier打头的进程打开，但是并不属于用户zahn
lsof -D /tmp 显示所有在/tmp文件夹中打开的instance和文件的进程。但是symbol文件并不在列

lsof -u1000 //查看uid是100的用户的进程的文件使用情况
lsof -utony //查看用户tony的进程的文件使用情况
lsof -u^tony //查看不是用户tony的进程的文件使用情况(^是取反的意思)
lsof -i //显示所有打开的端口
lsof -i:80 //显示所有打开80端口的进程
lsof -i -U //显示所有打开的端口和UNIX domain文件
lsof -i UDP@[url]www.akadia.com:123 //显示那些进程打开了到www.akadia.com的UDP的123(ntp)端口的链接
lsof -i tcp@ohaha.ks.edu.tw:ftp -r //不断查看目前ftp连接的情况(-r，lsof会永远不断的执行，直到收到中断信号,+r，lsof会一直执行，直到没有档案被显示,缺省是15s刷新)
lsof -i tcp@ohaha.ks.edu.tw:ftp -n //lsof -n 不将IP转换为hostname，缺省是不加上-n参数
