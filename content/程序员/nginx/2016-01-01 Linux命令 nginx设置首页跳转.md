---
title: Linux命令 Nginx反向代理 Google
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
location /wmb {
 if ( $request_uri = "/wmb/" ) {
      rewrite "/wmb/" /wmb/weibo.html break;
  }
  proxy_redirect off;
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_pass http://10.29.164.2:9008;
}
