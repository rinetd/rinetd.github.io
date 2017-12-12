---
title: Linux命令 Nginx列出目录 autoindex
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
X-Forwarded-For: 203.0.113.195, 70.41.3.18, 150.172.238.178

```
location / {
            proxy_pass   http://192.168.1.12:11080/v1/;
            proxy_cookie_path /v1/ /; #关键

            proxy_set_header   Host    $host;
            proxy_set_header   Remote_Addr    $remote_addr;
            proxy_set_header   X-Real-IP    $remote_addr;
            proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
        }
```

```
location / {        
        proxy_pass http://127.0.0.1:8090/sso;  
        proxy_cookie_path /sso/ /;  
        proxy_cookie_path /sso /;  
}  
```

1. 如果只是host、端口转换，则cookie不会丢失。例如：
   location /project {
       proxy_pass   http://127.0.0.1:8080/project;

   }


通过浏览器访问http://127.0.0.1/project时，浏览器的cookie内有jsessionid。再次访问时，浏览器会发送当前的cookie。


2. 如果路径也变化了，则需要设置cookie的路径转换，nginx.conf的配置如下
   location /proxy_path {
       proxy_pass   http://127.0.0.1:8080/project;

   }


通过浏览器访问http://127.0.0.1/proxy_path时，浏览器的cookie内没有jsessionid。再次访问时，后台当然无法获取到cookie了。

详细看了文档：http://nginx.org/en/docs/http/ngx_http_proxy_module.html?&_ga=1.161910972.1696054694.1422417685#proxy_cookie_path


加上路径转换：proxy_cookie_path  /project /proxy_path;

则可以将project的cookie输出到proxy_path上。正确的配置是：


   location /proxy_path {
       proxy_pass   http://127.0.0.1:8080/project;
       proxy_cookie_path  /project /proxy_path;
   }
