---
title: Linux命令 Nginx
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

location /status {
  // 查看nginx当前的状态情况,需要模块 “--with-http_stub_status_module”支持
               stub_status on;
               access_log /usr/local/nginx/logs/status.log;
               auth_basic "NginxStatus"; }

#设定查看Nginx状态的地址
location /NginxStatus {
  stub_status on;
  access_log on;
  auth_basic "NginxStatus";
  auth_basic_user_file conf/htpasswd;
  #htpasswd文件的内容可以用apache提供的htpasswd工具来产生。
}


Nginx 的访问控制模块默认就会安装，而且写法也非常简单，可以分别有多个allow,deny，允许或禁止某个ip或ip段访问，依次满足任何一个规则就停止往下匹配。如：

location /nginx-status {
  stub_status on;
  access_log off;
#  auth_basic   "NginxStatus";
#  auth_basic_user_file   /usr/local/nginx-1.6/htpasswd;
  allow 192.168.10.100;
  allow 172.29.73.0/24;
  deny all;
}

我们也常用 httpd-devel 工具的 htpasswd 来为访问的路径设置登录密码：

# htpasswd -c htpasswd admin
New passwd:
Re-type new password:
Adding password for user admin
# htpasswd htpasswd admin    //修改admin密码
# htpasswd htpasswd sean    //多添加一个认证用户

这样就生成了默认使用CRYPT加密的密码文件。打开上面nginx-status的两行注释，重启nginx生效。
