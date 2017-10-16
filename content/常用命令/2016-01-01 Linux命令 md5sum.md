---
title: md5sum
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [md5sum]
---
# 生成校验文件
md5sum target/app.jar > app.jar.md5
# 校验文件
md5sum -c app.jar.md5
