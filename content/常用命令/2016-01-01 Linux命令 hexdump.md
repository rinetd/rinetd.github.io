---
title: Linux命令 hexdump
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [hexdump]
---

[hexdump - ”十六“进制查看器 - Bash @ Linux - ITeye技术网站](http://codingstandards.iteye.com/blog/805778)
#单字节方式显示且不要省略
hexdump -Cv 1.jpg


示例一 比较各种参数的输出结果
[root@new55 ~]# `echo /etc/passwd | hexdump`
0000000 652f 6374 702f 7361 7773 0a64          
000000c
[root@new55 ~]# `echo /etc/passwd | od -x`
0000000 652f 6374 702f 7361 7773 0a64
0000014
[root@new55 ~]# `echo /etc/passwd | xxd`
0000000: 2f65 7463 2f70 6173 7377 640a            /etc/passwd.
[root@new55 ~]# echo /etc/passwd | hexdump -C      <== 规范的十六进制和ASCII码显示（Canonical hex+ASCII display ）
00000000  2f 65 74 63 2f 70 61 73  73 77 64 0a              |/etc/passwd.|
0000000c
[root@new55 ~]# echo /etc/passwd | hexdump -b      <== 单字节八进制显示（One-byte octal display）
0000000 057 145 164 143 057 160 141 163 163 167 144 012                
000000c
[root@new55 ~]# echo /etc/passwd | hexdump -c      <== 单字节字符显示（One-byte character display）
0000000   /   e   t   c   /   p   a   s   s   w   d  \n                
000000c
[root@new55 ~]# echo /etc/passwd | hexdump -d      <== 双字节十进制显示（Two-byte decimal display）
0000000   25903   25460   28719   29537   30579   02660                
000000c
[root@new55 ~]# echo /etc/passwd | hexdump -o       <== 双字节八进制显示（Two-byte octal display）
0000000  062457  061564  070057  071541  073563  005144                
000000c
[root@new55 ~]# echo /etc/passwd | hexdump -x       <== 双字节十六进制显示（Two-byte hexadecimal display）
0000000    652f    6374    702f    7361    7773    0a64                
000000c
[root@new55 ~]# echo /etc/passwd | hexdump -v
0000000 652f 6374 702f 7361 7773 0a64          
000000c

比较来比较去，还是hexdump -C的显示效果更好些。
示例二 确认文本文件的格式
文本文件在不同操作系统上的行结束标志是不一样的，经常会碰到由此带来的问题。比如Linux的许多命令不能很好的处理DOS格式的文本文件。Windows/DOS下的文本文件是以\r\n作为行结束的，而Linux/Unix下的文本文件是以\n作为行结束的。

[root@new55 ~]# cat test.bc
123*321
123/321
scale=4;123/321

[root@new55 ~]# hexdump -C test.bc
00000000  31 32 33 2a 33 32 31 0a   31 32 33 2f 33 32 31 0a  |123*321.123/321.|
00000010  73 63 61 6c 65 3d 34 3b  31 32 33 2f 33 32 31 0a  |scale=4;123/321.|
00000020  0a                                                |.|
00000021
[root@new55 ~]#

注：常见的ASCII字符的十六进制表示
\r      0D
\n      0A
\t      09
DOS/Windows的换行符 \r\n 即十六进制表示 0D 0A
Linux/Unix的换行符      \n    即十六进制表示 0A

示例三 查看wav文件
有些IVR系统需要8K赫兹8比特的语音文件，可以使用hexdump看一下具体字节编码。
[root@web186 root]# ls -l tmp.wav
-rw-r--r--    1 root     root        32381 2010-04-19  tmp.wav
[root@web186 root]# file tmp.wav
tmp.wav: RIFF (little-endian) data, WAVE audio, ITU G.711 a-law, mono 8000 Hz
[root@web186 root]# hexdump -C tmp.wav | less
