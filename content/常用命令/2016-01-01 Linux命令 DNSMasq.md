---
title: Linux命令 DNSMasq
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [DNSMasq]
---
规则如下，广告过滤地址可以自己添加修改，网上找的，小弟整理了一下，希望能和大家多多交流交流，共同分享：
DNSmasq规则

编辑 /etc/dnsmasq.conf，加入下面一条配置：
#add dnsmasq.ads rule list
conf-dir=/etc/dnsmasq.d
addn-hosts=/etc/dnsmasq.d/simpleu.txt
记得在etc文件夹下新建一个名字为dnsmasq.d的文件夹，以免配置不正确，然后命令行运行以下批处理即可更新过滤规则，可以添加到定时任务脚本或者开机启动脚本里面，方便自动更新，以下为自动更新命令：
```
wget --no-check-certificate -qO - https://easylist-downloads.adblockplus.org/chinalist+easylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/127\.0\.0\.1:' > /etc/dnsmasq.d/chinalist+easylist.conf
wget --no-check-certificate -qO - http://winhelp2002.mvps.org/hosts.txt | \
awk '{if(/^#/||/^$/) {print $0} else {print "address=/"$2"/"$1"\t"$3,"\n""server=/"$2"/#"}}' > /etc/dnsmasq.d/mvps.conf
wget --no-check-certificate -qO - http://someonewhocares.org/hosts/hosts | \
awk '{if(/^#/||/^$/) {print $0} else {print "address=/"$2"/"$1"\t"$3,"\n""server=/"$2"/#"}}' > /etc/dnsmasq.d/someonewhocares.conf
wget --no-check-certificate -qO - http://www.malwaredomainlist.com/hostslist/hosts.txt | \
awk '{if(/^#/||/^$/) {print $0} else {print "address=/"$2"/"$1"\t"$3,"\n""server=/"$2"/#"}}' > /etc/dnsmasq.d/malwaredomainlist.conf
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/simpleu/master/hosts > /etc/dnsmasq.d/simpleu.txt
/etc/init.d/dnsmasq restart
```
