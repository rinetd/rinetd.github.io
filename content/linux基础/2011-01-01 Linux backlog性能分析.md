---
title: Linux  php-fpm backlog参数潜在问题
date: 2016-01-07T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags:
---

http://blog.csdn.net/willas/article/details/11634825


有高并发的业务，就必须要调整backlog。对于PHP而言，需要注意的有3方面：

    1、操作系统 | sysctl

    2、WEB前端 | 比如：Nginx

    3、PHP后台 | 比如：php-fpm

操作系统以CentOS为例，可通过默认配置 /etc/sysctl.conf 文件进行调整。比如：

net.core.somaxconn = 1048576 # 默认为128

net.core.netdev_max_backlog = 1048576 # 默认为1000

net.ipv4.tcp_max_syn_backlog = 1048576 # 默认为1024

WEB前端以Nginx为例，可通过默认配置 /etc/nginx/nginx.conf 文件中的监听选项来调整。比如：

listen       80 backlog=8192; # 默认为511

PHP后台，以PHP-FPM为例，可以通过默认配置 /etc/php-fpm.d/www.conf 文件进行调整。比如：

listen.backlog = 8192 # 默认为-1（由系统决定）

大系统下，如上3处都应该进行调整。

值得注意的是：

    PHP-FPM的配置文件中，关于listen.backlog选项的注释有些误导人：

; Set listen(2) backlog. A value of '-1' means unlimited.
; Default Value: -1

实际上如果使用默认值，很容易出现后端无法连接的问题，按老文档上的解释这个默认是200。建议此处不要留空，务必设置一个合适的值。



       前几天有业务在新机器上线测试时，发现个问题：同样的资源的虚机、同样配置的ngxin+PHP-fpmweb后端的两台机器，测试后发现：访问.html文件时QPS相差不大，但是访问php

页面时其中一台的QPS是另一台的数倍。通过分析，发现是php-fpm的backlog参数引起的，可以通过设置php-fpm.conf中的backlog参数来解决。下面是对问题的简单分析。



一、问题分析

       1、通过测试分析，的确存在所述的性能相差数倍的问题，因为访问静态文件的性能相当，所以可以确定排除nginx错误的可能，猜想是不是有php执行过慢导致呢？

于是安装了我们针对php5.2.5开发的slow log调试模块后发现没有执行慢的地方，然后把目光放到了nginx 与php建立连接的阶段上，使用tcpdump在服务器上抓包，

发现性能差的机器上存在大量的SYN3秒超时，并且会伴有请求头的超时重传。如下图：



        看来凶手已经找到了：是SYN 超时。一般SYN 超时是由于服务端backlog引起的，在我们的应用中，nginx –> php-fpm，所以php-fpm相当于服务端，查看php-fpm配置发现 backlog值是 -1 !!

gdb 跟踪fpm启动过程发现fpm没有对-1进行处理，而是直接把 -1 赋给了listen 系统调用，抱着好奇的心下载了linux2.6.18内核源码，跟踪listen系统调用执行过程如下：

asmlinkage long sys_listen(int fd, intbacklog)        {

if ((sock = sockfd_lookup_light(fd, &err, &fput_needed))!= NULL) {

         if((unsigned) backlog >sysctl_somaxconn)               //unsigned 把backlog变成了一个32位的最大整数：4294967295

             backlog =sysctl_somaxconn;                                    //也就是说当backlog=-1时，在内核中backlog被赋值为/proc/sys/net/core/somaxconn 的值，本机上为262144

      err =security_socket_listen(sock, backlog);

        if (!err)

                  err= sock->ops->listen(sock, backlog);

        fput_light(sock->file,fput_needed);

        }

         return err;

}



        抱着试试看的心态，改变了fpm配置backlog的值，测试发现把php-fpm的backlog值设为：10 –262143 之间机器的性能恢复了（1-10因为太小，所以性能不太理想），CPU跑得很high，但是

只要大于262144，性能就又变差了。结合上面的问题，SYN超时一般是服务器端完成连接队列满导致的， 既然backlog值被设置成了somaxconn，那么不应该出现内核中完成连接队列满的情况。

    为了搞清楚backlog值对tcp监听套接字的影响，编写了一个测试程序：服务端listen之后不accept，客户端循环来连接（服务端非阻塞）。

（1）把backlog设置为-1 或 大于262144的一个值时，客户端连接很慢，抓包发现有SYN 3、6秒超时，服务器端ESTABLISHED的连接也很少，如图：


（2）把backlog设置为n（10 <n < 262143）时，客户端瞬间就建立了n个连接（n到达ulimit -a的open files上限时报Too many open files 错误后客户端退出）。



        从上面的测试我们可以认为php-fpm是因为没有及时accept连接导致服务器不再接收TCP连接导致的，那么fpm为什么会不及时accept呢？

原来fpm 多个进程是监听同一个套接字的，通过一个套接字锁来保证同一时刻只有一个进程可以accept，多进程间抢锁是需要消耗时间的，

在backlog被设置成-1的情况下，如果fpm没有及时accept，那么在并发量很大的情况下势必会出现SYN 超时重连了。



二、结论

        综上：性能差是由于php-fpm backlog参数设置为-1，导致fpm没能及时取出完成连接队列的socket，出现SYN 超时，最终导致压不上去，表现出性能差。

所以安装php-fpm时backlog一定要重新设置，不能用fpm默认配置的-1 ，可以根据机器的并发量来设置，建议设置在1024以上，最好是2的幂值（因为内核会调整成2的n次幂）。

如果您的业务机是2.6.18内核，同时发现php 机器性能特不合理，那么就试试改一下fpm的backlog参数吧，您肯定会震惊的。。。。



三、备注

       在2.6.32内核上测试就不会出现这个问题，因为2.6.32内核给listen socket分配空间时做了特殊的处理：

int reqsk_queue_alloc(struct request_sock_queue*queue,unsigned int nr_table_entries){

//…

   nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);

   nr_table_entries = max_t(u32, nr_table_entries,8);

   nr_table_entries =roundup_pow_of_two(nr_table_entries + 1);

  lopt_size += nr_table_entries * sizeof(structrequest_sock *);

//…

}

nr_table_entries 可以认为是用户空间传进来的值，min_t保证了最大只取sysctl_max_syn_backlog的值，系统中是8196。



四、遗留问题

        虽然问题解决了，但是还存在两个疑问。

        1、虽然通过测试可以确定backlog设置很大会出现SYN超时，但是还不能从原理上解释？

         2、为什么同样设置的-1，有的机器性能很好，有的却很差呢？
