---
title: Linux命令 Nginx反向代理 Google
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
[分享一下我的 Nginx 反向代理 Google 以及草榴等的参数配置 - V2EX](https://www.v2ex.com/t/126028#reply0)

# 1、这里监听了80和443端口，用了ssl加密，高大上。ssl证书是免费的，startssl，自己去申请个吧。
# 2、定义了个upstream google，放了5个谷歌的ip，如果不这样做，就等着被谷歌的验证码搞崩溃吧。
# 3、也设置了反向代理缓存，某些资源不用重复去请求谷歌获取，加快搜索速度。
# 4、proxy_redirect https://www.google.com/ /; 这行的作用是把谷歌服务器返回的302响应头里的域名替换成我们的，不然浏览器还是会直接请求www.google.com，那样反向代理就失效了。
# 5、proxy_cookie_domain google.com centos.bz; 把cookie的作用域替换成我们的域名。
# 6、proxy_pass http://google; 反向代理到upstream google，会随机把请求分配到那几个ip。忘记说了，那几个ip可以在自己的vps或服务器上使用nslookup www.google.com获取。
# 7、proxy_set_header Accept-Encoding “”; 防止谷歌返回压缩的内容，因为压缩的内容我们无法作域名替换。
# 8、proxy_set_header Accept-Language “zh-CN”;设置语言为中文
# 9、proxy_set_header Cookie “PREF=ID=047808f19f6de346:U=0f62f33dd8549d11:FF=2:LD=zh-CN:NW=1:TM=1325338577:LM=1332142444:GM=1:SG=2:S=rE0SyJh2w1IQ-Maw”; 这行很关键，传固定的cookie给谷歌，是为了禁止即时搜索，因为开启即时搜索无法替换内容。还有设置为新窗口打开网站，这个符合我们打开链接的习惯。
# 10、sub_filter www.google.com www.centos.bz;当然是把谷歌的域名替换成我们的了，注意需要安装nginx的sub_filter模块
```
proxy_cache_path  /data/nginx/cache/one  levels=1:2   keys_zone=one:10m max_size=10g;
proxy_cache_key  "$host$request_uri";

server {
  listen 80;
  server_name www.centos.bz centos.bz;
  rewrite ^(.*) https://www.centos.bz$1 permanent;
}

upstream google {
  server 74.125.224.80:80 max_fails=3;
  server 74.125.224.81:80 max_fails=3;
  server 74.125.224.82:80 max_fails=3;
  server 74.125.224.83:80 max_fails=3;
  server 74.125.224.84:80 max_fails=3;
}
server {
  listen      443;
  server_name  www.centos.bz centos.bz;

  # ssl on;
  # ssl_certificate      /etc/nginx/ca/server.crt;
  # ssl_certificate_key  /etc/nginx/ca/server.key;
  # ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
  # ssl_ciphers          HIGH:!aNULL:!MD5;
  # ssl_prefer_server_ciphers  on;

  location / {
    proxy_cache one;
    proxy_cache_valid  200 302  1h;
    proxy_cache_valid  404      1m;
    proxy_redirect https://www.google.com/ /;
    proxy_cookie_domain google.com centos.bz;
    proxy_pass              http://google;
    proxy_set_header Host "www.google.com";
    proxy_set_header Accept-Encoding "";
    proxy_set_header User-Agent $http_user_agent;
    proxy_set_header Accept-Language "zh-CN";
    proxy_set_header Cookie "PREF=ID=047808f19f6de346:U=0f62f33dd8549d11:FF=2:LD=zh-CN:NW=1:TM=1325338577:LM=1332142444:GM=1:SG=2:S=rE0SyJh2w1IQ-Maw";
    sub_filter www.google.com www.centos.bz;
    sub_filter_once off;
  }
}
```
