---
title: Linux命令 Nginx proxy
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

location / {
    # 包含关键词 '计算机' 重定向至 /test
    rewrite ^.*计算机.*$ /test last;

    # 通用透明代理
    proxy_pass $scheme://$host$request_uri;
    proxy_set_header Host $http_host;
    proxy_buffers 256 4k;
    proxy_max_temp_file_size 0k;
}
