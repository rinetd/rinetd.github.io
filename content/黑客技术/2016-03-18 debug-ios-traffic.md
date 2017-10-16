---
title: iOS抓包（使用BurpSuite和tcpdump）
date: 2015-12-25T08:52:52+08:00
update: 2016-01-01
categories: [网络安全]
tags: ['iOS','debug','BurpSuite','tcpdump']
---

## Introduce

开发过程中我们经常会需要对网络请求抓包，本次介绍的是使用BurpSuite抓取HTTP/HTTPS包，以及不越狱使用tcpdump抓取iPhone的网络包。  

## 使用BurpSuite对HTTP/HTTPS抓包
开发中我们经常会需要对HTTP/HTTPS请求进行抓包。  
抓包实际上是在中间机器开了一个代理服务，让需要抓包的请求经过代理，我们就可以看到这些请求了。本质上是中间人攻击。  
BurpSuite是一个常用的调试工具。  

#### 1. 下载BurpSuite
从[BurpSuite](http://portswigger.net/burp/download.html)官网下载jar包，右键点击，运行：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_1.jpg "947" )

<!--more-->

#### 2. Burp设置

先从菜单Burp->Remember settings中检查是否All options都记录设置了，以便下次打开不用重新配置：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_2.jpg "百度logo")

在选项卡的Proxy->Options中，选择代理规则，点击Edit：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_3.jpg "693" )

在弹出的对话框中选择All interfaces，再点击OK，来监听所有的网卡：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_4.jpg "707" )

至此已经可以通过代理来监听手机的HTTP请求了。现在我们再制作CA让手机信任，来解密被加密的HTTPS请求。  

回到选项卡的Proxy->Options中，重新生成证书，以防被拥有相同的证书的人中间人攻击。生成后需要重启Burp：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_5.jpg "633" )

重启Burp后，回到选项卡的Proxy->Options中，导出证书为Der格式：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_6.jpg "946" )

然后将Der证书通过HTTP服务器或邮件发给手机，在手机上安装证书：  

![](http://openfibers.github.io/images/blog/ios_burp/InstallCert_1.jpg "250")
![](http://openfibers.github.io/images/blog/ios_burp/InstallCert_2.jpg "250")
![](http://openfibers.github.io/images/blog/ios_burp/InstallCert_3.jpg "250")

第一次用，先关闭排除规则，抓取全部的包。在Proxy->Intercept选项卡中，点击按钮，使其显示‘Intercept is off’:  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_7.jpg "571" )

#### 3. 设置手机/模拟器代理

先看下Mac的网卡地址：  

![](http://openfibers.github.io/images/blog/ios_burp/ProxySettings_1.jpg "664" )

然后在手机的wifi详情中设置手动代理：  

![](http://openfibers.github.io/images/blog/ios_burp/ProxySettings_2.jpg "375" )

如果是模拟器，在网卡的高级设置中，设置HTTP和HTTPS代理为127.0.0.1:8080：  

![](http://openfibers.github.io/images/blog/ios_burp/ProxySettings_3.jpg "662" )

在手机或模拟器中发送请求，然后在Burp选项卡的Proxy->HTTP history中可以查看到结果：  

![](http://openfibers.github.io/images/blog/ios_burp/BurpSuite_8.jpg "857" )

#### 4. 测试完成后删除手机的Der

不删除一旦私钥泄露会被中间人攻击，保险起见，调试完就赶紧从手机删掉证书。  

在系统设置->通用->描述文件中找到刚才安装的证书，然后删除：  

![](http://openfibers.github.io/images/blog/ios_burp/RemoveCert_1.jpg "375")
![](http://openfibers.github.io/images/blog/ios_burp/RemoveCert_2.jpg "375" )

## 使用tcpdump抓包

我们经常会用tcpdump抓取各种协议的网络包。  
iOS5之后，可以使用Remote Virtual Interface(RVI)建立虚拟网卡进行抓包，好处是：  

* 新版的Macbook/Air/Pro只有一块Wifi，没有RJ45接口，我们用USB线连接手机就可以完成抓包。  
* 使用RVI不管是蜂窝数据还是Wifi，网络报文都能抓的到，而以往用Wifi把流量导入电脑抓包无法抓取蜂窝数据下的报文。  

#### 1. 建立RVI

首先将手机用数据线连接到电脑。  

使用ifconfig -l命令查看当前网卡：  

```bash
$ ifconfig -l
lo0 gif0 stf0 en0 en1 en2 p2p0 awdl0 bridge0 en4
```

查看手机的udid，然后使用rvictl命令建立rvi：  

```bash
$ rvictl -s a1fad5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc60b
Starting device a1fad59f135e2cd8f7dda951a15c01cd2220c60b [SUCCEEDED] with interface rvi0
```

再次使用ifconfig -l查看网卡：  

```bash
$ ifconfig -l
lo0 gif0 stf0 en0 en1 en2 p2p0 awdl0 bridge0 en4 rvi0
```

我们发现多出了一个rvi0，这个就是新建立的rvi。  


#### 2. 抓包

```bash
$ sudo tcpdump -i rvi0 -w trace.pcap
```

然后在手机上进行操作，操作结束后在terminal里按control+c，结束抓包。然后trace.pcap就是生成的抓包记录。  

之后断开rvi连接：  

```bash
$ rvictl -s a1fad5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc60b
Stopping device a1fad59f135e2cd8f7dda951a15c01cd2220c60b [SUCCEEDED]
```

我们可以将pcap文件转换成纯文本格式查看：  

```bash
tcpdump -n -e -x -vvv -r trace.pcap > trace.txt
```

不过一般还是用wireshark直接打开pcap文件查看比较方便。  

相关资源：  

[Apple Technical Q&A 1176 : Getting a Packet Trace](https://developer.apple.com/library/mac/qa/qa1176/_index.html)

Over
