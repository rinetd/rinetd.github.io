---
title: Linux useradd
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [linux_base]
tags: [useradd]
---
mysql:x:27:27:MariaDB Server:/var/lib/mysql:/sbin/nologin
useradd -r -u 33 -g www-data -c www-data -d /var/www -s /usr/sbin/nologin www-data
useradd -o -r -u 501 -g www -c ftp -d /home/wwwroot/default/bizchinalinyi -s /usr/sbin/nologin ftp

-c, --comment comment 指定一段注释性描述。
-d, --home-dir 目录 指定用户主目录，如果此目录不存在，则同时使用-m选项，可以创建主目录。
-g, --gid 用户组 指定用户所属的用户组。
-G 用户组，用户组 指定用户所属的附加组。
-s, --shell  Shell文件 指定用户的登录Shell。
-u, --uid UID 用户号 指定用户的用户号，如果同时有-o选项，则可以重复使用其他用户的标识号。
-o, --non-unique 创建uid相同的账户
-r, --system 创建系统账户uid<1000 递减
