---
title: Linux命令 Nginx proxy cache
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
[【译】Ngnix实现一个缓存和缩略处理的反向代理服务器 - QueenKing - SegmentFault](https://segmentfault.com/a/1190000004604380)
[Linux 运维 » Nginx 代理 配置详解](http://www.mylinuxer.com/?p=281)

3.Proxy Cache配置详解
Proxy Cache机制依赖于Proxy Buffer机制，只有当Buffer(默认开启)开启的时候，Cache才能使用


3.1
proxy_cache zone | off;
配置一块用于公用的内存区域名称，该区域可以存放缓存的索引数据
zone 设置用于存放缓存索引的内存区域的名称
off  关闭proxy_cache功能，默认为关闭的

3.2
proxy_cache_bypass string..........；
配置nginx服务器向客户端发送响应数据时，不从缓存中获取的条件
string 为条件变量
eg:
  proxy_cache_bypass $cookie_nocache;

3.3
proxy_cache_key string;
配置nginx服务器在内存中为缓存数据建立索引时使用的关键字
string 为设置的关键字
通常使用以下配置
 eg :
    proxy_cache_key "$scheme$proxy_host$uri$is_args$args";

3.4
proxy_cache_lock on|off;
设置是否开启缓存锁的功能，默认为关闭状态

3.5
proxy_cache_lock_timeout time;
设置缓存锁功能开启以后锁的超时时间，默认为5

3.6
proxy_cache_min_uses number;
设置客户请求发送的次数，当客户端向被代理服务器发送相同请求到达一定的次数后，nginx才对请求进行缓存，默认为1

3.7
proxy_cache_path path [levels=levels] keys_zone=name:size [inactive=time] [max_size=size2] [loader_files=number] [loader_sleep=time2] [loader_threshold=time3];
设置nginx服务器存储数据的路径以及和缓存索引相关的内容
path 设置缓存数据存放的根路径，此路径必须存在
levels 设置相对于path指定目录的第几级hash目录中缓存数据
        设置缓存目录层数，如levels=1:2，表示创建两层目录缓存，最多创建三层。第一层目录名取proxy_cache_key md5的最后一个字符，第二层目录名取倒数2-3字符，如：
        proxy_cache_key md5为b7f54b2df7773722d382f4809d65029c，则：
        levels=1:2为/data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c
        levels=1:2:3为/data/nginx/cache/c/29/650/b7f54b2df7773722d382f4809d65029c
keys_zone=name:size：用于设置存放缓存索引的内存区域的名称和大小
        定义缓存区域名称及大小，缓存名称用于proxy_cache指令设置缓存放置在哪，如proxy_cache one，则把缓存放在zone名称为one的缓存区，即proxy_cache_path指定的具体位置。

inactive=time 设置强制更新缓存数据的时间 默认为10s
max_size=size2 设置硬盘中缓存数据的大小限制
loader_files=100 设置缓存索引重建进程每次加载的数据袁术的数量上限，默认为100
loader_sleep=50ms 设置缓存索引重建进程在一次遍历结束，下一次遍历开始之间的暂停时间，默认为50ms
loader_threshold=200ms 设置遍历一次磁盘缓存源数据的时间上限，默认为200ms
eg:
   proxy_cache_path /home/cache levels=1:2 keys_zone=cache_one:200m inactive=1d max_size=30g;

3.8
proxy_cache_use_stale error|timeout|invalid_header|updating|http_500|http_502|http_503|http_504|http_404 | off .....;
设置nginx在访问被代理服务器过程中出现被代理服务器无法访问或者访问错误等现象时，nginx服务器可以使用历史缓存响应客户端，该指令默认为off

3.9
proxy_cache_valid [ code ....] time;
设置对不同的HTTP响应状态设置不同的缓存时间
code 设置响应状态，nginx 职位http状态代码为200 301  302做缓存，可以使用any表示所有该指令中为设置的其他响应数据
time 设置缓存时间
eg:
   proxy_cache_valid 200 302 1h;
   proxy_cache_valid 301 1h;
   proxy_cache_valid any 1m;

3.10
proxy_no_cache string;
设置什么情况下不使用cache
