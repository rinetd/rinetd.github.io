---
title: Windows命令 netsh
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [netsh]
---


添加转发

    netsh interface portproxy add v4tov4 转发端口 目标IP 目标端口
    或者
    netsh interface portproxy add v4tov4 listenport=转发端口 listenaddress=本机IP connectport=目标端口 connectaddress=目标IP

查看转发

netsh interface portproxy show all


删除转发
netsh interface portproxy delete v4tov4 listenport=转发端口
或者
netsh interface portproxy delete v4tov4 listenport=转发端口 listenaddress=本机IP

# windows命令行下用netsh实现端口转发(端口映射)
首先安装IPV6（xp、2003下IPV6必须安装，否则端口转发不可用！）
netsh interface ipv6 install
查看转发配置：
netsh interface portproxy show all
将本机22到 1.1.1.1的22：
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=22 connectaddress=1.1.1.1 connectport=22
删除配置：
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=22
添加防火墙规则，允许连接22：
netsh firewall set portopening protocol=tcp port=22 name=Forward mode=enable scope=all profile=all


例如：listenaddress=192.168.193.1，参数可以省略，如果省略，则监听本地所有IP地址。

添加：netsh interface portproxy add v4tov4 listenport=88 connectaddress=127.0.0.1 connectport=80
删除：netsh interface portproxy delete v4tov4 listenport=88

批量添加：for /l %i in (100,1,200) do @netsh interface portproxy add v4tov4 listenport=%i connectaddress=www.baidu.com connectport=80
全部删除：for /f "skip=5 tokens=2 " %i in ('netsh interface portproxy show all') do @netsh interface portproxy delete v4tov4 listenport=%i

# Netsh 进行高级的 Windows 防火墙操作
//给防火墙添加允许 TCP 3389 端口通过
netsh advfirewall firewall add rule name=Windows Security Port dir=in action=allow protocol=TCP localport=3389

//删除防火墙所有针对 TCP 8080 端口入站的规则
netsh advfirewall firewall delete rule name=all dir=in protocol=TCP localport=8080

//直接重设防火墙策略到默认状态
netsh advfirewall reset

//关闭防火墙所有规则
netsh advfirewall set allprofiles state off

//将入站默认规则设置成阻挡并允许出站
netsh advfirewall set allprofiles firewallpolicy blackinbound,allowoutbound

//将本地的3389端口的数据转发至<公网IP>上的8080端口
netsh interface portproxy add v4tov4 listenport=3389 connectaddress=<公网IP> connectport=8080

//将本地3389端口的数据改成转发至<公网IP>的9080端口
netsh interface portproxy set v4tov4 listenport=3389 connectaddress=<公网IP> connectport=9080

//显示所有IPv4端口代理参数
netsh interface portproxy show v4tov4

//删除本地端口3389的端口转发配置
netsh interface portproxy delete v4tov4 listenport=3389

封锁指定IP：
`netsh advfirewall firewall add rule name="BLOCKDWS" dir=in interface=any action=block remoteip=111.221.29.177`
netsh advfirewall firewall add rule name="BLOCKDWS" dir=out interface=any action=block remoteip=111.221.29.177
netsh advfirewall firewall add rule name="Remote Desktop Services" protocol=TCP dir=in localport=%port% action=allow
netsh advfirewall firewall add rule name="CMS RTSP" protocol=TCP dir=in localport=554 action=allow
netsh advfirewall firewall add rule name="EasyDarwin RTSP" protocol=TCP dir=in localport=8554 action=allow
开启 RDP 服务
```
reg add "hklm\system\currentcontrolset\control\terminal server" /f /v fDenyTSConnections /t REG_DWORD /d 0
netsh firewall set service remoteadmin enable
netsh firewall set service remotedesktop enable
```
关闭 Windows 防火墙
```
netsh firewall set opmode disable
```

（1）启用桌面防火墙
netsh advfirewall set allprofiles state on
（2）设置默认输入和输出策略
netsh advfirewall set allprofiles firewallpolicy allowinbound,allowoutbound
以上是设置为允许，如果设置为拒绝使用blockinbound,blockoutbound
（3）关闭tcp协议的139端口
netsh advfirewall firewall add rule name="deny tcp 139" dir=in protocol=tcp localport=139 action=block
（4）关闭udp协议的139端口
netsh advfirewall firewall add rule name="deny udp 139" dir=in protocol=udp localport=139 action=block
（5）关闭tcp协议的445端口
netsh advfirewall firewall add rule name="deny tcp 445" dir=in protocol=tcp localport=445 action=block
（6）关闭udp协议的445端口
netsh advfirewall firewall add rule name="deny udp 445" dir=in protocol=udp localport=445 action=block
（7）使用相同的方法，依次关闭TCP协议的21、22、23、137、138、3389、5800、5900端口。
netsh advfirewall firewall add rule name= "deny tcp 21" dir=in protocol=tcp localport=21 action=block
netsh advfirewall firewall add rule name= "deny tcp 22" dir=in protocol=tcp localport=22 action=block
netsh advfirewall firewall add rule name= "deny tcp 23" dir=in protocol=tcp localport=23 action=block
netsh advfirewall firewall add rule name= "deny tcp 3389" dir=in protocol=tcp localport=3389 action=block
netsh advfirewall firewall add rule name= "deny tcp 5800" dir=in protocol=tcp localport=5800 action=block
netsh advfirewall firewall add rule name= "deny tcp 5900" dir=in protocol=tcp localport=5900 action=block
netsh advfirewall firewall add rule name= "deny tcp 137" dir=in protocol=tcp localport=137 action=block
netsh advfirewall firewall add rule name= "deny tcp 138" dir=in protocol=tcp localport=138 action=block
（8）执行完毕后暂停
pause
echo 按任意键退出
2．恢复初始配置
（1）恢复初始防火墙设置
netsh advfirewall reset
（2）关闭防火墙
netsh advfirewall set allprofiles state off
