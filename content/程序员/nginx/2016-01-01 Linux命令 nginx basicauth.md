---
title: Linux命令 Nginx basicauth
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

`chmod 400 htpasswd`

# printf "liuyc:$(openssl passwd -crypt Liuyc@2017)\n" >>htpasswd
# cat conf/htpasswd
ttlsa:xyJkVhXGAZ8tM


  location /
  {
          auth_basic "nginx basic http test for ttlsa.com";
          auth_basic_user_file conf/htpasswd;
          autoindex on;
  }


  /usr/local/apache2/bin/htpasswd -c -d pass_file user_name
  #回车输入密码，-c 表示生成文件，-d 是以 crypt 加密。


### proxy 
```
location /proxy/ {
  if ($arg_token ~ "^$") { return 404; }
  if ($arg_url ~ "^$") { return 404; }

  set $url $arg_url;
  set $token $arg_token;
  set $args "";

  # IMPORTANT, this is required when using dynamic proxy pass
  # You can alternatively use any DNS resolver under your control
  resolver 8.8.8.8;

  proxy_pass $url;
  proxy_set_header Authorization "Bearer $token";
  proxy_redirect off;
}
```
