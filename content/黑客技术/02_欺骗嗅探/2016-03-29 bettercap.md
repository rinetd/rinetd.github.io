---
title: ettercap
date: 2016-03-29T21:25:45+08:00
update: 2016-01-01
categories: [网络安全]
tags:
---
bettercap是一个强大的,模块化的,方便并且容易扩展的中间人攻击框架。

一些主要的功能如下:

.支持全双工和半双工ARP欺骗。
.第一次真正实现ICMP 双向欺骗。
.可配置的DNS欺骗。
.完全自动化,可实时发现主机。
.实时获取通信协议中的安全凭证，包括HTTP(S)中的Post数据，Basic和Digest认证，FTP,IRC,POP,IMAP,SMTP,NTLM(HTTP,SMB,LDAP)以及更多
.完全可定制的网络嗅探器。
.模块化的HTTP和HTTPS透明代理,支持用户自定义插件或内置插件，注入到目标的HTML代码、JS、CSS文件，以及URL中。
.使用HSTS bypass技术拆封SSL。
.内置式的HTTP服务器。

    1
    2
    3
    4
    5
    6
    7
    8
    9

以上都是胡扯,框架好不好,用了才知道.
0x01:安装(Kali 2.0平台)

以下方法都已在Kali 2.0 平台亲测,请在安装前确保主机可以正常联网

方法一:(推荐) 安装稳定版

root@Kali:~# apt-get install build-essential ruby-dev libpcap-dev
root@Kali:~# gem sources --remove https://rubygems.org/
root@Kali:~# gem sources -a https://ruby.taobao.org/
root@Kali:~# gem install bettercap

    1
    2
    3
    4
    5

方法二:(不推荐) 安装最新版

root@Kali:~# git clone https://github.com/evilsocket/bettercap
root@Kali:~# cd bettercap/
root@Kali:~/bettercap# gem build bettercap.gemspec
root@Kali:~/bettercap# gem install bettercap*.gem
root@Kali:~/bettercap# apt-get install build-essential ruby-dev libpcap-dev
root@Kali:~/bettercap# gem sources --remove https://rubygems.org/
root@Kali:~/bettercap# gem sources -a https://ruby.taobao.org/
root@Kali:~/bettercap# gem install bettercap*.gem

    1
    2
    3
    4
    5
    6
    7
    8

说明:
推荐第一种方法安装bettercap,最保险,可以正常使用;
第二种方法安装的bettercap在我的kali linux 2.0平台下可以打开,但无法正常使用;
如果安装平台不是Kali,安装出错请查阅官方文档说明,官方地址见文章最后部分.
0x02:使用方法:

先查看当前工作的网卡接口的名称:如eth0,wlan0.

root@Kali:~# ifconfig
或者
root@Kali:~# ip address

    1
    2
    3

然后，start ！

root@Kali:~# bettercap -I wlan0 -X
或者
root@Kali:~# bettercap -I wlan0 --sniffer

    1
    2
    3

0x03:命令参数详解

-h, --help                          使用帮助;
-G, --gateway ADDRESS               手动指定网关地址,如果没有指定当前的网关,网关将被自动检索和使用;
-I, --interface                     指定网络接口名，默认为eth0;
-S, --spoofer NAME                  指定欺骗模块，此参数默认为ARP，支持ICMP与ARP,可设为None;
-T, --target ADDRESS1,ADDRESS2      目标IP地址,如果没有将指定整个子网为目标,
    --ignore ADDRESS1,ADDRESS2      寻找目标时,忽略指定的地址;
-O, --log LOG_FILE                  把所有消息记录到一个文件中,如果未指定则只打印到shell,
    --log-timestamp                 启用日志记录每一行的时间戳,默认禁用;
-D, --debug                         调试功能，会将每一步操作详细记录，便于调试;
-L, --local                         解析流经本机的所有数据包（此操作会开启嗅探器），默认为关闭;
-X, --sniffer                       开启嗅探器,
    --sniffer-source FILE           加载指定的PCAP包文件,而不是使用接口(此操作将开启嗅探器),
    --sniffer-pcap FILE             将数据包保存为指定的PCAP文件（此操作会开启嗅探器),
    --sniffer-filter EXPRESSION     配置嗅探器使用BPF过滤器（此操作会开启嗅探器);
-P, --parsers PARSERS               解析指定的数据包并用逗号分隔（此操作会开启嗅探器),支持
    IRC, WHATSAPP, HTTPAUTH, HTTPS, MYSQL, POST, REDIS, DICT, COOKIE, NNTP,
    MPD, SNMP, PGSQL, RLOGIN, NTLMSS, SNPP, URL, FTP, DHCP, MAIL, CREDITCARD.
    --custom-parser EXPRESSION      使用正则表达式来捕获和显示嗅探的数据(此操作会开启嗅探器),
    --silent                        如果不是警告或者错误消息,就不显示,默认关闭,
    --no-discovery                  不主动寻找目标主机,只使用当前的ARP缓存,默认关闭,
    --no-spoofing                   禁用欺骗,同--spoofer NONE命令,
    --no-target-nbns                禁用NBNS主机名,
    --half-duplex                   使用半双工模式,遇到大流量路由器时可以保证其正常工作,    
    --proxy                         启用HTTP代理和重定向所有HTTP请求,默认关闭,          
    --proxy-https                   启用HTTPS代理和重定向所有HTTPS请求,默认关闭,           
    --proxy-port PORT               设置HTTP代理端口,默认为8080,     
    --http-ports PORT1,PORT2        用逗号分隔需要重定向到代理的HTTP端口,默认为80,
    --https-ports PORT1,PORT2       用逗号分隔需要重定向到代理的HTTPS端口,默认为443,
    --proxy-https-port PORT         设置HTTPS代理端口,默认为8083,
    --proxy-pem FILE                为HTTPS代理使用自定义PEM证书文件,默认文件为
                                    /root/.bettercap/bettercap-ca.pem,
    --proxy-module MODULE           要么加载Ruby代理模块,要么加载injectjs,
                                    injectcss,injecthtml之一
    --custom-proxy ADDRESS          使用一个自定义HTTP上游代理,而不是嵌入式的,   
    --custom-proxy-port PORT        为自定义的HTTP上游代理指定一个端口,默认为8080,
    --no-sslstrip                   禁用SSLStrip,
    --custom-https-proxy ADDRESS    使用一个自定义HTTPS上游代理,而不是内置的,
    --custom-https-proxy-port PORT  为自定义的HTTPS端口指定上游代理,默认为8083,
    --custom-redirection RULE       使用自定义的端口重定向,格式是:
    PROTOCOL ORIGINAL_PORT NEW_PORT. 例如:TCP 21 2100,重定向所有TCP流量，从端口21定向到端口2100.
    --httpd                         启用HTTP服务器,默认关闭,
    --httpd-port PORT               设置HTTP服务器端口,默认为8081,
    --dns FILE                      使用DNS服务器文件作为解析表,
    --dns-port PORT                 设置DNS服务器端口,默认为5300,
    --httpd-path PATH               设置HTTP服务器路径,默认为:./,
    --kill                          杀掉连接目标,不转发,
    --packet-throttle NUMBER        设置要发送的每个数据包之间延迟的秒数,
    --check-updates                 检查更新.


0x04:使用实图

使用姿势:

其实后面可以加一个：-O /evil.log,将嗅探的信息保存到文件中，方便查看与分析
使用方式

自动的主机发现：

主机好多。。。

嗅探数据:

嗅探出了小米的服务凭证
0x05官方部分命令示例

    Default sniffer mode, all parsers enabled:
    sudo bettercap -X
    Enable sniffer and load only specified parsers:
    sudo bettercap -X -P “FTP,HTTPAUTH,MAIL,NTLMSS”
    Enable sniffer and use a custom expression:
    sudo bettercap -X –custom-parser “password”
    Enable sniffer + all parsers and parse local traffic as well:
    sudo bettercap -X -L
    Enable sniffer + all parsers and also dump everything to a pcap file:
    sudo bettercap –sniffer –sniffer-pcap=output.pcap
    What about saving only HTTP traffic to that pcap file?
    sudo bettercap –sniffer –sniffer-pcap=http.pcap –sniffer-filter “tcp and dst port 80”
    Default ARP spoofing mode on the whole network without sniffing:
    sudo bettercap

0x06: 后记

文章为原创,转载请注明博客出处地址;
文章参考bettercap官网:https://bettercap.org 文档、freebuf http://www.freebuf.com/tools/99607.html和个人理解与整理创作而成,顺便感谢下有道翻译~
