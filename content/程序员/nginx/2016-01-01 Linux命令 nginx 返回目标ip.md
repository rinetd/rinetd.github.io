---
title: Linux命令 Nginx列出目录 autoindex
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

```
location  /ip {
  # 默认是文件格式
  add_header  Content-Type 'text/html; charset=utf-8';

  set $realip $remote_addr;
  if ($http_x_forwarded_for ~ "^(\d+\.\d+\.\d+\.\d+)") {
    set $realip $1;
  }

  return 200 "$realip";
}
```

#获取用户真实IP，并赋值给变量$clientRealIP
```
map $http_x_forwarded_for  $clientRealIp {
        ""      $remote_addr;
        ~^(?P<firstAddr>[0-9\.]+),?.*$  $firstAddr;
}
```
