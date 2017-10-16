---
title: Linux命令 Nginx proxy cache
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
[【译】Ngnix实现一个缓存和缩略处理的反向代理服务器 - QueenKing - SegmentFault](https://segmentfault.com/a/1190000004604380)
[Linux 运维 » Nginx 代理 配置详解](http://www.mylinuxer.com/?p=281)
2  Proxy Buffer详解
proxy buffer启用以后，nginx服务器会异步地将被failing服务器的响应数据传递给客户端，首先，nginx服务器会尽可能的从被代理服务器哪里接收响应数据，放在Proxy Buffer中
2.1
proxy_buffering on|off;
配置是否开启或关闭proxy buffer功能,默认为开启

2.2
proxy_buffers number size;
设置接收一次被代理服务器响应数据的proxy buffer个数和每个buffer的大小
number 为个数
size 为打下你
默认设置为
proxy_buffers 8 4k|8k;

2.3
proxy_buffer_size size;
配置从被代理服务器获取的第一部分响应数据的大小
size 设置缓存的大小，保持与proxy_buffers设置的size相同

2.4
proxy_busy_buffers_seze size;
限制同时处于BUSY状态的缓存区总大小，默认为8KB故意整个16KB

2.5
proxy_temp_path path .........;
配置磁盘上的一个文件路径，用于零食存放服务器的大体积响应数据
path 设置存放临时文件的路径
..... 目录
eg :
    proxy_temp_path /nginx/proxy_web/proxy_temp 1 2;
    临时文件存放目录为/nginx/proxy_web/proxy_temp路径下的第二级目录中

2.6
proxy_max_temp_file_size size;
配置所有临时文件的总体积的大小，存放在磁盘上的临时文件大小不能超过该值
size设置大小，默认我1024MB

2.7
proxy_temp_file_write_size size;
配置同时写入临时文件的数据量的总大小，可以设置为8KB 16KB,一般与平台的内存页大小相同
