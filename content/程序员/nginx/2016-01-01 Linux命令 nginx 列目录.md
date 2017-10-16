---
title: Linux命令 Nginx列出目录 autoindex
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
列出目录 autoindex

Nginx默认是不允许列出整个目录的。如需此功能，打开nginx.conf文件，在location，server 或 http段中加入autoindex on;，另外两个参数最好也加上去:

autoindex_exact_size off

默认为on，显示出文件的确切大小，单位是bytes。改为off后，显示出文件的大概大小，单位是kB或者MB或者GB

autoindex_localtime on

默认为off，显示的文件时间为GMT时间。改为on后，显示的文件时间为文件的服务器时间

location /images {
  root   /var/www/nginx-default/images;
  autoindex on;
  autoindex_exact_size off;
  autoindex_localtime on;
}



1.目录列表(directory listing)

nginx让目录中的文件以列表的形式展现只需要一条指令

autoindex on;

autoindex可以放在location中，只对当前location的目录起作用。你也可以将它放在server指令块则对整个站点都起作用。或者放到http指令块，则对所有站点都生效。

下面是一个简单的例子:
server {
        listen   80;
        server_name  domain.com www.domain.com;
        access_log  /var/...........................;
        root   /path/to/root;
        location / {
                index  index.php index.html index.htm;
        }
        location /somedir {
               autoindex on;
        }
}


2.nginx禁止访问某个目录

跟Apache的Deny from all类似，nginx有deny all指令来实现。

禁止对叫dirdeny目录的访问并返回403 Forbidden，可以使用下面的配置:
location /dirdeny {
      deny all;
      return 403;
}
