---
title: BurpsSuite
date: 2016-03-29T21:25:45+08:00
update: 2016-01-01
categories: [网络安全]
tags: [BurpsSuite]
---
Windows 下启动 BurpsSuite
`java.exe -cp BurpLoader.jar;burpsuite_pro_v1.7.03.jar larry.lau.BurpLoader`
java -jar BurpLoader.jar
java -cp BurpLoader.jar;burpsuite_pro.jar larry.lau.BurpLoader
java -cp BurpLoader.jar:burpsuite_pro.jar larry.lau.BurpLoader

`java -jar Cknife.jar `
[PortSwigger CA](https://support.portswigger.net/customer/portal/articles/1783087-Installing_Installing%20CA%20Certificate%20-%20FF.html)
[Burp Suite使用介绍](http://drops.wooyun.org/tools/1548)
[book burpsuite实战指南](https://t0data.gitbooks.io/burpsuite/content/)
[Burp Suite 官方文档中文版](https://yw9381.gitbooks.io/burp_suite_doc_zh_cn/content/)

java -jar BurpLoader.jar --help
# 插件安装目录
~/.Burpsuite/bapps/

# [Intercept 拦截规则]
# [Intruder 自动攻击]

Creating a Custom CA Certificate

You can use the following OpenSSL commands to create a custom CA certificate with your own details, such as CA name:

openssl req -x509 -days 730 -nodes -newkey rsa:2048 -outform der -keyout server.key -out ca.der

[OpenSSL will prompt you to enter various details for the certificate. Be sure to enter suitable values for all the prompted items.]

openssl rsa -in server.key -inform pem -out server.key.der -outform der

openssl pkcs8 -topk8 -in server.key.der -inform der -out server.key.pkcs8.der -outform der -nocrypt

Then click on the "Import / export CA certificate" button in Burp, and select "Cert and key in DER format". Select ca.der as the certificate file, and server.key.pkcs8.der as the key file. Burp will then load the custom CA certificate and begin using it to generate per-host certificates.
