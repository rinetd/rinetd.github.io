---
title: Linux命令 Nginx try_files
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

```
try_files $uri/index.html $uri.html $uri @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;

    proxy_redirect off;

    proxy_pass http://unicorn;

    proxy_buffer_size 16k;
    proxy_busy_buffers_size 16k;
  }

  error_page 500 502 503 504 /500.html;
  ```
Nginx的try_files指令使用实例
IT运维
编辑：优云小编
2016-05-01 459 次围观
0

blob.png

Nginx的配置语法灵活，可控制度非常高。在0.7以后的版本中加入了一个try_files指令，配合命名location，可以部分替代原本常用的rewrite配置方式，提高解析效率。
try_files指令说明

try_files指令
语法：try_files file ... uri 或 try_files file ... = code
默认值：无
作用域：server location

其作用是按顺序检查文件是否存在，返回第一个找到的文件或文件夹(结尾加斜线表示为文件夹)，如果所有的文件或文件夹都找不到，会进行一个内部重定向到最后一个参数。

需要注意的是，只有最后一个参数可以引起一个内部重定向，之前的参数只设置内部URI的指向。最后一个参数是回退URI且必须存在，否则会出现内部500错误。命名的location也可以使用在最后一个参数中。与rewrite指令不同，如果回退URI不是命名的location那么args，则必须明确声明。

try_files $uri $uri/ /index.php?q=$uri&$args;

实例分析
示例一

try_files 将尝试你列出的文件并设置内部文件指向。

例如:

try_files /app/cache/ $uri @fallback;
index index.php index.html;

它将检测document_root/app/cache/index.html 和 uri是否存在，如果不存在着内部重定向到@fallback(＠表示配置文件中预定义标记点) 。
你也可以使用一个文件或者状态码(=404)作为最后一个参数，如果是最后一个参数是文件，那么这个文件必须存在。
示例二

例如nginx不解析PHP文件，以文本代码返回

try_files $uri /cache.php @fallback;

因为这个指令设置内部文件指向到 $document_root/cache.php 并返回,但没有发生内部重定向，因而没有进行location段处理而返回文本 。
(如果加上index指令可以解析PHP是因为index会触发一个内部重定向)
示例三

跳转到变量
```
  server {
   listen 8000;
   server_name 192.168.119.100;
   root html;
   index index.html index.php;

   location /abc {
       try_files /4.html /5.html @qwe;              #检测文件4.html和5.html,如果存在正常显示,不存在就去查找@qwe值
  }

   location @qwe  {
      rewrite ^/(.*)$   http://www.baidu.com;       #跳转到百度页面
   }
```
示例四

跳转指定文件
```
server {
   listen 8000;
   server_name 192.168.119.100;
   root html;
   index index.php index.html;

   location /abc {
       try_files /4.html /5.html /6.html;
  }
```
示例五

将请求跳转到后端

upstream tornado {
        server 127.0.0.1:8001;
}

server {
        server_name imike.me;
        return 301 $scheme://www.imike.me$request_uri;
}

server {
        listen 80;
        server_name www.imike.me;

        root /var/www/www.imike.me/V0.3/www;
        index index.html index.htm;

        try_files $uri @tornado;

        location @tornado {
                proxy_pass_essay-header Server;
                proxy_set_essay-header Host $http_host;
                proxy_set_essay-header X-Real-IP $remote_addr;
                proxy_set_essay-header X-Scheme $scheme;

                proxy_pass http://tornado;
        }
}

常见错误
常见错误一

try_files 按顺序检查文件是否存在，返回第一个找到的文件，至少需要两个参数，但最后一个是内部重定向也就是说和rewrite效果一致，前面的值是相对$document_root的文件路径。也就是说参数的意义不同，甚至可以用一个状态码 (404)作为最后一个参数。如果不注意会有死循环造成500错误。

location ~.*\.(gif|jpg|jpeg|png)$ {
        root /web/wwwroot;
        try_files /static/$uri $uri;
}

原意图是访问http://example.com/test.jpg时先去检查/web/wwwroot/static/test.jpg是否存在，不存在就取/web/wwwroot/test.jpg

但由于最后一个参数是一个内部重定向，所以并不会检查/web/wwwroot/test.jpg是否存在，只要第一个路径不存在就会重新向然后再进入这个location造成死循环。结果出现500 Internal Server Error

location ~.*\.(gif|jpg|jpeg|png)$ {
        root /web/wwwroot;
        try_files /static/$uri $uri 404;
}

这样才会先检查/web/wwwroot/static/test.jpg是否存在，不存在就取/web/wwwroot/test.jpg再不存在则返回404 not found
常见错误二

Nginx try_files $query_string为空的解决办法

server {
    listen 80;
    server_name localhost.dev;
    index index.php index.html index.htm;
    set $root_path '/var/www/phalcon/public';
    root $root_path;
    location / {
        try_files $uri $uri/ /index.php;
    }
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; include fastcgi_params;
    }
    location ~* ^/(css|img|js|flv|swf|download)/(.+)$ {
        root $root_path;
    }
    location ~ /\.ht {
        deny all;
    }
}

发现PHP无法获取$_GET信息

try_files $uri $uri/ /index.php;

改为

try_files $uri $uri/ /index.php?$query_string;

即可解决
