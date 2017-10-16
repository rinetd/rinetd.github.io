---
title: Linux命令 apache2
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
a2dissite yun.kljiyou.com.conf
a2ensite yun.kljiyou.com.conf

useradd -d /alidata1/web/yun.kljiyou.com/ -s /usr/sbin/nologin yunkljiyou
service apache2 reload
ipconfig /flushdns
