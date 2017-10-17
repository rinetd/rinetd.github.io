---
title: Linux命令 Nginx rewrite
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

1.
```
server {

  listen 8000;

  server_name project.example.com;

  root   /path/to/www;

  #Matches the path project.example.com only (mind there is a =)

  location = / {

    #the rewrite statement will forward the project.example.com to project.example.com/project (which must be handled internally)

    rewrite / /project;

  }



  #Matches every path (mind: there is no =)

  location / {

    #the rewrite statement with "permanent" at the end will visibly forward every link on the subdomain to the main domain

   rewrite ^(.+)$ http://www.example.be$request_uri? permanent;

  }

  ... #php handling code
```



`rewrite ^/(ask|forum|qa)/(.*)$ http://forum.site.com/$2 permanent;`

2. redirect URL subdirectory to subdomain
```
server {
    server_name  www.mydomain.com mydomain.com;
    rewrite ^(.*) http://mysite.mydomain.com$1 permanent;
}

server {
listen :80;
server_name mysite.mydomain.com;
root /var/www/mydomain.com/mysite;
......
}

```

nginx通过ngx_http_rewrite_module模块支持url重写、支持if条件判断，但不支持else。

该模块需要PCRE支持，应在编译nginx时指定PCRE源码目录, nginx安装方法。
nginx rewrite指令执行顺序：

1. 执行server块的rewrite指令(这里的块指的是server关键字后{}包围的区域，其它xx块类似)
2. 执行location匹配
3. 执行选定的location中的rewrite指令

如果其中某步URI被重写，则重新循环执行1-3，直到找到真实存在的文件

如果循环超过10次，则返回500 Internal Server Error错误

break指令

语法：break;
默认值：无
作用域：server,location,if

停止执行当前虚拟主机的后续rewrite指令集
break指令实例：
 if ($slow) {
     limit_rate 10k;
     break;
 }

 if ($slow) {
     limit_rate 10k;
     break;
 }

if指令

语法：if(condition){...}
默认值：无
作用域：server,location
对给定的条件condition进行判断。如果为真，大括号内的rewrite指令将被执行。
if条件(conditon)可以是如下任何内容:

    一个变量名；false如果这个变量是空字符串或者以0开始的字符串；
    使用= ,!= 比较的一个变量和字符串
    是用~， ~* 与正则表达式匹配的变量，如果这个正则表达式中包含}，;则整个表达式需要用" 或' 包围
    使用-f ，!-f 检查一个文件是否存在
    使用-d, !-d 检查一个目录是否存在
    使用-e ，!-e 检查一个文件、目录、符号链接是否存在
    使用-x ， !-x 检查一个文件是否可执行

if指令实例
```
 if ($http_user_agent ~ MSIE) {
     rewrite ^(.*)$ /msie/$1 break;
 }

 if ($http_cookie ~* "id=([^;]+)(?:;|$)") {
     set $id $1;
 }

 if ($request_method = POST) {
     return 405;
 }

 if ($slow) {
     limit_rate 10k;
 }

 if ($invalid_referer) {
     return 403;
 }
```

return指令

语法：return code;

return code URL;

return URL;
默认值：无
作用域：server,location,if

停止处理并返回指定状态码(code)给客户端。
非标准状态码444表示关闭连接且不给客户端发响应头。
从0.8.42版本起，return 支持响应URL重定向(对于301，302，303，307），或者文本响应(对于其他状态码).
对于文本或者URL重定向可以包含变量
rewrite指令

语法：rewrite regex replacement [flag];
默认值：无
作用域：server,location,if
如果一个URI匹配指定的正则表达式regex，URI就按照replacement重写。
rewrite按配置文件中出现的顺序执行。flags标志可以停止继续处理。
如果replacement以"http://"或"https://"开始，将不再继续处理，这个重定向将返回给客户端。
flag可以是如下参数
last 停止处理后续rewrite指令集，然后对当前重写的新URI在rewrite指令集上重新查找。
break 停止处理后续rewrite指令集，并不在重新查找,但是当前location内剩余非rewrite语句和location外的的非rewrite语句可以执行。
redirect 如果replacement不是以http:// 或https://开始，返回302临时重定向
permant 返回301永久重定向
最终完整的重定向URL包括请求scheme(http://,https://等),请求的server_name_in_redirect和 port_in_redirec三部分 ，说白了也就是http协议 域名 端口三部分组成。

rewrite实例
```
 server {
     ...
     rewrite ^(/download/.*)/media/(.*)..*$ $1/mp3/$2.mp3 last;
     rewrite ^(/download/.*)/audio/(.*)..*$ $1/mp3/$2.ra last;
     return 403;
     ...
 }
```
如果这些rewrite放到 “/download/” location如下所示, 那么应使用break而不是last , 使用last将循环10次匹配，然后返回 500错误:
```
 location /download/ {
     rewrite ^(/download/.*)/media/(.*)..*$ $1/mp3/$2.mp3 break;
     rewrite ^(/download/.*)/audio/(.*)..*$ $1/mp3/$2.ra break;
     return 403;
 }
```
对于重写后的URL（replacement）包含原请求的请求参数，原URL的?后的内容。如果不想带原请求的参数 ，可以在replacement后加一个问号。如下，我们加了一个自定义的参数user=$1,然后在结尾处放了一个问号?,把原请的参数去掉。
`rewrite ^/users/(.*)$ /show?user=$1? last;`

如果正则表达regex式中包含 “}” 或 “;”, 那么整个表达式需要用双引号或单引号包围.
rewrite_log指令


语法：rewrite_log on|off;
默认值：rewrite_log off;
作用域：http,server,location,if
开启或关闭以notice级别打印rewrite处理日志到error log文件。

nginx打开rewrite log例子

rewrite_log on;
error_log logs/xxx.error.log notice;

1.打开rewrite on
2.把error log的级别调整到 notice
set指令


语法：set variable value;
默认值：none
作用域：server,location,if
定义一个变量并赋值，值可以是文本，变量或者文本变量混合体。
uninitialized_variable_warn指令


语法：uninitialized_variable_warn on | off;
默认值：uninitialized_variable_warn on
作用域：http,server,location,if
