---
title: nginx 支持apk ipa 禁止重命名为zip文件
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

.apk 和 .ipa分别是android应用和ios应用的扩展名。

如果在浏览器下载这些文件为后缀的文件时，会自动重命名为zip文件。

当然可以下载后手动修改后缀，依然可以安装。

如果想下载后缀直接就是apk ipa的，可以修改 /usr/local/nginx/conf目录下的mime.types

增加如下配置，重启nginx生效

Apache
application/vnd.android.package-archive apk;
application/iphone          pxl ipa;
1
2

application/vnd.android.package-archive apk;
application/iphone          pxl ipa;
