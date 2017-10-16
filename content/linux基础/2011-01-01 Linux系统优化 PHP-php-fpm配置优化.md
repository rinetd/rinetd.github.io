---
title: Linux  php-fpm 优化
date: 2016-01-07T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags:
---

前言:

　　1.少安装PHP模块, 费内存

　　2.调高linux内核打开文件数量，可以使用这些命令(必须是root帐号)(我是修改/etc/rc.local，加入ulimit -SHn 51200的)

echo `ulimit -HSn 65536` >> /etc/profile
echo `ulimit -HSn 65536` >> /etc/rc.local
source /etc/profile
　　如果`ulimit -n`数量依旧不多(即上面配置没生效)的话, 可以在 /etc/security/limits.conf 文件最后加上

* soft nofile 51200
* hard nofile 51200
1.与Nginx使用Unix域Socket通信(Nginx和php-fpm在同一台服务器)

　　Unix域Socket因为不走网络，的确可以提高Nginx和php-fpm通信的性能，但在高并发时会不稳定。

　　Nginx会频繁报错：connect() to unix:/dev/shm/php-fcgi.sock failed (11: Resource temporarily unavailable) while connecting to upstream

　　可以通过下面两种方式提高稳定性：
　　1）调高nginx和php-fpm中的backlog
    　　 配置方法为：在nginx配置文件中这个域名的server下，在listen 80后面添加default backlog=1024。
     　　同时配置php-fpm.conf中的listen.backlog为1024，默认为128。
　　2）增加sock文件和php-fpm实例数
     　　再新建一个sock文件，在Nginx中通过upstream模块将请求负载均衡到两个sock文件背后的两套php-fpm实例上。



2.php-fpm参数调优

　　pm = dynamic; 表示使用哪种进程数量管理方式

　　　　dynamic表示php-fpm进程数是动态的，最开始是pm.start_servers指定的数量，如果请求较多，则会自动增加，保证空闲的进程数不小于pm.min_spare_servers，如果进程数较多，也会进行相应清理，保证多余的进程数不多于pm.max_spare_servers

　　　　static表示php-fpm进程数是静态的, 进程数自始至终都是pm.max_children指定的数量，不再增加或减少

　　pm.max_children = 300; 静态方式下开启的php-fpm进程数量
　　pm.start_servers = 20; 动态方式下的起始php-fpm进程数量
　　pm.min_spare_servers = 5; 动态方式下的最小php-fpm进程数量
　　pm.max_spare_servers = 35; 动态方式下的最大php-fpm进程数量

　　　　如果pm为static, 那么其实只有pm.max_children这个参数生效。系统会开启设置数量的php-fpm进程

　　　　如果pm为dynamic, 那么pm.max_children参数失效，后面3个参数生效。系统会在php-fpm运行开始的时候启动pm.start_servers个php-fpm进程，然后根据系统的需求动态在pm.min_spare_servers和pm.max_spare_servers之间调整php-fpm进程数

　　　　那么，对于我们的服务器，选择哪种pm方式比较好呢？事实上，跟Apache一样，运行的PHP程序在执行完成后，或多或少会有内存泄露的问题。这也是为什么开始的时候一个php-fpm进程只占用3M左右内存，运行一段时间后就会上升到20-30M的原因了。

　　　　对于内存大的服务器（比如8G以上）来说，指定静态的max_children实际上更为妥当，因为这样不需要进行额外的进程数目控制，会提高效率。因为频繁开关php-fpm进程也会有时滞，所以内存够大的情况下开静态效果会更好。数量也可以根据 内存/30M 得到，比如8GB内存可以设置为100，那么php-fpm耗费的内存就能控制在 2G-3G的样子。如果内存稍微小点，比如1G，那么指定静态的进程数量更加有利于服务器的稳定。这样可以保证php-fpm只获取够用的内存，将不多的内存分配给其他应用去使用，会使系统的运行更加畅通。

　　　　对于小内存的服务器来说，比如256M内存的VPS，即使按照一个20M的内存量来算，10个php-cgi进程就将耗掉200M内存，那系统的崩溃就应该很正常了。因此应该尽量地控制php-fpm进程的数量，大体明确其他应用占用的内存后，给它指定一个静态的小数量，会让系统更加平稳一些。或者使用动态方式，因为动态方式会结束掉多余的进程，可以回收释放一些内存，所以推荐在内存较少的服务器或VPS上使用。具体最大数量根据 内存/20M 得到。比如说512M的VPS，建议pm.max_spare_servers设置为20。至于pm.min_spare_servers，则建议根据服务器的负载情况来设置，比较合适的值在5~10之间。

　　　　在4G内存的服务器上200就可以(我的1G测试机，开64个是最好的，建议使用压力测试获取最佳值)

　　pm.max_requests = 10240;

　　　　nginx php-fpm配置过程中最大问题是内泄漏出问题：服务器的负载不大，但是内存占用迅速增加，很快吃掉内存接着开始吃交换分区，系统很快挂掉！其实根据官方的介绍，php-cgi不存在内存泄漏，每个请求完成后php-cgi会回收内存，但是不会释放给操作系统，这样就会导致大量内存被php-cgi占用。
　　　　

　　　　官方的解决办法是降低PHP_FCGI_MAX_REQUESTS的值，如果用的是php-fpm，对应的php-fpm.conf中的就是max_requests，该值的意思是发送多少个请求后会重启该线程，我们需要适当降低这个值，用以让php-fpm自动的释放内存，不是大部分网上说的51200等等，实际上还有另一个跟它有关联的值max_children，这个是每次php-fpm会建立多少个进程，这样实际上的内存消耗是max_children*max_requests*每个请求使用内存，根据这个我们可以预估一下内存的使用情况，就不用再写脚本去kill了。

　　request_terminate_timeout = 30;

　　　　最大执行时间, 在php.ini中也可以进行配置(max_execution_time)

　　request_slowlog_timeout = 2; 开启慢日志
　　slowlog = log/$pool.log.slow; 慢日志路径

　　rlimit_files = 1024; 增加php-fpm打开文件描述符的限制

3.php-fpm的高CPU使用率排查方法

　　1)使用top命令, 直接执行top命令后，输入1就可以看到各个核心的CPU使用率。而且通过top -d 0.1可以缩短采样时间

　　2)查询php-fpm慢日志

grep -v "^$" www.log.slow.tmp | cut -d " " -f 3,2 | sort | uniq -c | sort -k1,1nr | head -n 50


复制代码
   5181 run() /www/test.net/framework/web/filters/CFilter.php:41

   5156 filter() /www/test.net/framework/web/filters/CFilterChain.php:131

   2670 = /www/test.net/index.php

   2636 run() /www/test.net/application/controllers/survey/index.php:665

   2630 action() /www/test.net/application/controllers/survey/index.php:18

   2625 run() /www/test.net/framework/web/actions/CAction.php:75

   2605 runWithParams() /www/test.net/framework/web/CController.php:309

   2604 runAction() /www/test.net/framework/web/filters/CFilterChain.php:134

   2538 run() /www/test.net/framework/web/CController.php:292

   2484 runActionWithFilters() /www/test.net/framework/web/CController.php:266

   2251 run() /www/test.net/framework/web/CWebApplication.php:276

   1799 translate() /www/test.net/application/libraries/Limesurvey_lang.php:118

   1786 load_tables() /www/test.net/application/third_party/php-gettext/gettext.php:254

   1447 runController() /www/test.net/framework/web/CWebApplication.php:135
复制代码
　　　　参数解释:

                sort:  对单词进行排序
                uniq -c:  显示唯一的行，并在每行行首加上本行在文件中出现的次数
                sort -k1,1nr:  按照第一个字段，数值排序，且为逆序
                head -10:  取前10行数据

　　3)用strace跟踪进程

　　　　a)利用nohup将strace转为后台执行，直到attach上的php-fpm进程死掉为止：

nohup strace -T -p 13167 > 13167-strace.log &
　　　　参数说明:

　　　　　  -c 统计每一系统调用的所执行的时间,次数和出错的次数等.
                -d 输出strace关于标准错误的调试信息.
                -f 跟踪由fork调用所产生的子进程.
                -o filename,则所有进程的跟踪结果输出到相应的filename
                -F 尝试跟踪vfork调用.在-f时,vfork不被跟踪.
                -h 输出简要的帮助信息.
                -i 输出系统调用的入口指针.
                -q 禁止输出关于脱离的消息.
                -r 打印出相对时间关于,,每一个系统调用.
                -t 在输出中的每一行前加上时间信息.
                -tt 在输出中的每一行前加上时间信息,微秒级.
                -ttt 微秒级输出,以秒了表示时间.
                -T 显示每一调用所耗的时间.
                -v 输出所有的系统调用.一些调用关于环境变量,状态,输入输出等调用由于使用频繁,默认不输出.
                -V 输出strace的版本信息.
                -x 以十六进制形式输出非标准字符串
                -xx 所有字符串以十六进制形式输出.
                -a column
                设置返回值的输出位置.默认为40.
                -e execve 只记录 execve 这类系统调用
                -p 主进程号

　　　　b)用利用-c参数让strace帮助汇总，非常方便非常强大！

复制代码
[root@b28-12 log]# strace -cp 9907

Process 9907 attached - interrupt to quit

Process 9907 detached

% time     seconds  usecs/call     calls    errors syscall

------ ----------- ----------- --------- --------- ----------------

56.61    0.016612           5      3121           read

11.11    0.003259           1      2517       715 stat

  8.04    0.002358           7       349           brk

  6.02    0.001767           1      1315           poll

  4.28    0.001255           6       228           recvfrom

  2.71    0.000796           1       671           open

  2.54    0.000745           0      2453           fcntl

  2.37    0.000696           1      1141           write

  1.69    0.000497           1       593        13 access

  1.37    0.000403           0      1816           lseek

  0.89    0.000262           1       451        22 sendto

  0.56    0.000163           1       276       208 lstat

  0.49    0.000145           0       384           getcwd

  0.31    0.000090           0      1222           fstat

  0.28    0.000082           0       173           munmap

  0.26    0.000077           0       174           mmap

  0.24    0.000069           2        41           socket

  0.23    0.000068           0       725           close

  0.00    0.000000           0        13           rt_sigaction

  0.00    0.000000           0        13           rt_sigprocmask

  0.00    0.000000           0         1           rt_sigreturn

  0.00    0.000000           0        78           setitimer

  0.00    0.000000           0        26        26 connect

  0.00    0.000000           0        15         2 accept

  0.00    0.000000           0        39           recvmsg

  0.00    0.000000           0        26           shutdown

  0.00    0.000000           0        13           bind

  0.00    0.000000           0        13           getsockname

  0.00    0.000000           0        65           setsockopt

  0.00    0.000000           0        13           getsockopt

  0.00    0.000000           0         8           getdents

  0.00    0.000000           0        26           chdir

  0.00    0.000000           0         1           futex

------ ----------- ----------- --------- --------- ----------------

100.00    0.029344                 18000       986 total
复制代码
4.使用Opcode缓存(http://www.cnblogs.com/JohnABC/p/4531038.html)

5.对PHP性能进行监控

　　常用的方法就是开启xdebug的性能监控功能，将xdebug输出结果通过WinCacheGrind软件分析。
　　xdebug的安装和配合IDE调试的方法参见：Vim+XDebug调试PHP

　　php.ini中配置的这几项是输出性能信息的：
xdebug.auto_trace = on
xdebug.auto_profile = on
xdebug.collect_params = on
xdebug.collect_return = on
xdebug.profiler_enable = on
xdebug.trace_output_dir = "/tmp"
xdebug.profiler_output_dir ="/tmp"

　　这样XDebug会输出所有执行php函数的性能数据，但产生的文件也会比较大。可以关闭一些选项如collect_params、collect_return，
　　来减少输出的数据量。或者关闭自动输出，通过在想要监控的函数首尾调用xdebug函数来监控指定的函数。

　　输出的文件名类似cachegrind.out.1277560600和trace.3495983249.txt，可以拿到Windows平台下用WinCacheGrind进行图形化分析。
6.监测php-fpm线程状态

　　nginx配置

location ~ ^/status$ {
    include fastcgi_params;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
}
　　php-fpm配置

pm.status_path = /status
　　这样的话通过http://域名/status就可以看到当前的php情况

　　下面介绍每个参数的作用：
　　pool：php-fpm池的名称，一般都是应该是www
　　process manage：进程的管理方法，php-fpm支持三种管理方法，分别是static,dynamic和ondemand，一般情况下都是dynamic
　　start time：php-fpm启动时候的时间，不管是restart或者reload都会更新这里的时间
　　start since：php-fpm自启动起来经过的时间，默认为秒
　　accepted conn：当前接收的连接数
　　listen queue：在队列中等待连接的请求个数，如果这个数字为非0，那么最好增加进程的fpm个数
　　max listen queue：从fpm启动以来，在队列中等待连接请求的最大值
　　listen queue len：等待连接的套接字队列大小
　　idle processes：空闲的进程个数
　　active processes：活动的进程个数
　　total processes：总共的进程个数
　　max active processes：从fpm启动以来，活动进程的最大个数，如果这个值小于当前的max_children，可以调小此值
　　max children reached：当pm尝试启动更多的进程，却因为max_children的限制，没有启动更多进程的次数。如果这个值非0，那么可以适当增加fpm的进程数
　　slow requests：慢请求的次数，一般如果这个值未非0，那么可能会有慢的php进程，一般一个不好的mysql查询是最大的祸首。

7.开启php-fpm慢日志

　　slowlog = /usr/local/php/log/php-fpm.log.slow

　　request_slowlog_timeout = 5s

8.设置php-fpm单次请求最大执行时间，今天碰到一个问题，测试服务器php-fpm一直是被占满状态，后来发现是set_time_limit(0)，file_get_content()，原因如下:

　　比如file_get_contents(url)等函数，如果网站反应慢，会一直等在那儿不超时，php-fpm一直被占用。有一个参数 max_execution_time 可以设置 PHP 脚本的最大执行时间，但是，在 php-cgi(php-fpm) 中，该参数不会起效。真正能够控制 PHP 脚本最大执行时间的是 php-fpm.conf 配置文件中的以下参数。

　　request_terminate_timeout = 10s

　　默认值为 0 秒，也就是说，PHP 脚本会一直执行下去。这样，当所有的 php-cgi 进程都卡在 file_get_contents() 函数时，这台 Nginx+PHP 的 WebServer 已经无法再处理新的 PHP 请求了，Nginx 将给用户返回“502 Bad Gateway”。可以使用 request_terminate_timeout = 30s，但是如果发生 file_get_contents() 获取网页内容较慢的情况，这就意味着 150 个 php-cgi 进程，每秒钟只能处理 5 个请求，WebServer 同样很难避免“502 Bad Gateway”。php-cgi进程数不够用、php执行时间长、或者是php-cgi进程死掉，都会出现502错误。

　　要做到彻底解决，只能让 PHP 程序员们改掉直接使用 file_get_contents("http://example.com/") 的习惯，而是稍微修改一下，加个超时时间，用以下方式来实现 HTTP GET 请求。要是觉得麻烦，可以自行将以下代码封装成一个函数。

复制代码
<?php  
    $ctx = stream_context_create(array(  
       'http' => array(  
           'timeout' => 1 //设置一个超时时间，单位为秒  
           )  
       )  
    );  
    file_get_contents("http://example.com/", 0, $ctx);  
复制代码
　　当然，导致 php-cgi 进程 CPU 100% 的原因不只有这一种，那么，怎么确定是 file_get_contents() 函数导致的呢？

　　首先，使用 top 命令查看 CPU 使用率较高的 php-cgi 进程。

复制代码
top - 10:34:18 up 724 days, 21:01,  3 users,  load average: 17.86, 11.16, 7.69
Tasks: 561 total,  15 running, 546 sleeping,   0 stopped,   0 zombie
Cpu(s):  5.9%us,  4.2%sy,  0.0%ni, 89.4%id,  0.2%wa,  0.0%hi,  0.2%si,  0.0%st
Mem:   8100996k total,  4320108k used,  3780888k free,   772572k buffers
Swap:  8193108k total,    50776k used,  8142332k free,   412088k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                                                                              
10747 www       18   0  360m  22m  12m R 100.6 0.3    0:02.60 php-cgi                                                                                                              
10709 www       16   0  359m  28m  17m R 96.8  0.4    0:11.34 php-cgi                                                                                                              
10745 www       18   0  360m  24m  14m R 94.8  0.3    0:39.51 php-cgi                                                                                                              
10707 www       18   0  360m  25m  14m S 77.4  0.3    0:33.48 php-cgi                                                                                                              
10782 www       20   0  360m  26m  15m R 75.5  0.3    0:10.93 php-cgi                                                                                                              
10708 www       25   0  360m  22m  12m R 69.7  0.3    0:45.16 php-cgi                                                                                                              
10683 www       25   0  362m  28m  15m R 54.2  0.4    0:32.65 php-cgi                                                                                                              
10711 www       25   0  360m  25m  15m R 52.2  0.3    0:44.25 php-cgi                                                                                                              
10688 www       25   0  359m  25m  15m R 38.7  0.3    0:10.44 php-cgi                                                                                                              
10719 www       25   0  360m  26m  16m R  7.7  0.3    0:40.59 php-cgi
复制代码
　　找其中一个 CPU 100% 的 php-cgi 进程的 PID，用以下命令跟踪一下：

strace -p 10747
　　如果屏幕显示：

复制代码
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
select(7, [6], [6], [], {15, 0})        = 1 (out [6], left {15, 0})
poll([{fd=6, events=POLLIN}], 1, 0)     = 0 (Timeout)
复制代码
　　那么，就可以确定是 file_get_contents() 导致的问题了。(参考:http://zyan.cc/tags/request_terminate_timeout/1/)

9.查看php-fpm启动时间(可以得出执行了多长时间)

ps -A -o pid,lstart,cmd |grep php-fpm
10.
