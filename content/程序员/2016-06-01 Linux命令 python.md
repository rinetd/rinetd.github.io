---
title: python
date: 2016-03-24T14:55:34+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [python]
---

[用pyenv和virtualenv搭建单机多版本python虚拟开发环境](http://www.it165.net/pro/html/201405/13603.html)
sudo apt-get install python python-pip

# 设置python编码
##  在 python 源代码文件中，如果你有用到非ASCII字符，则需要在文件头部进行字符编码的声明，声明如下：

    # code: UTF-8

```
#!/usr/bin/python
# -*- coding: <encoding name> -*-     ##推荐使用，支持更多的编辑器
# coding=<encoding name>
```
[原文](http://blog.chinaunix.net/uid-27838438-id-4227131.html)
在 python 源代码文件中，如果你有用到非ASCII字符，则需要在文件头部进行字符编码的声明，声明如下：

   # code: UTF-8


因为python 只检查 #、coding 和编码字符串，所以你可能回见到下面的声明方式，这是有些人为了美观等原因才这样写的：

   #-*- coding: UTF-8 -*-


常见编码介绍：

       GB2312编码：适用于汉字处理、汉字通信等系统之间的信息交换
       GBK编码：是汉字编码标准之一，是在 GB2312-80 标准基础上的内码扩展规范，使用了双字节编码
       ASCII编码：是对英语字符和二进制之间的关系做的统一规定
       Unicode编码：这是一种世界上所有字符的编码。当然了它没有规定的存储方式。
       UTF-8编码：是 Unicode Transformation Format - 8 bit 的缩写， UTF-8 是 Unicode 的一种实现方式。它是可变长的编码方式，可以使用 1~4 个字节表示一个字符，可根据不同的符号而变化字节长度。


编码转换：

Python内部的字符串一般都是 Unicode编码。代码中字符串的默认编码与代码文件本身的编码是一致的。所以要做一些编码转换通常是要以Unicode作为中间编码进行转换的，即先将其他编码的字符串解码（decode）成 Unicode，再从 Unicode编码（encode）成另一种编码。

       decode 的作用是将其他编码的字符串转换成 Unicode 编码，eg name.decode(“GB2312”)，表示将GB2312编码的字符串name转换成Unicode编码
       encode 的作用是将Unicode编码转换成其他编码的字符串，eg name.encode(”GB2312“)，表示将GB2312编码的字符串name转换成GB2312编码

所以在进行编码转换的时候必须先知道 name 是那种编码，然后 decode 成 Unicode 编码，最后载 encode 成需要编码的编码。当然了，如果 name 已经就是 Unicode 编码了，那么就不需要进行 decode 进行解码转换了，直接用 encode 就可以编码成你所需要的编码。值得注意的是：对 Unicode 进行编码和对 str 进行编码都是错误的。

具体的说就是：如果在UTF-8文件中，则这个字符串就是 UTF-8编码的。它的编码取决于当前的文本编码。当然了，GB2312文本的编码就是GB2312。要在同一个文本中进行两种编码的输出等操作就必须进行编码的转换，先用decode将文本原来的编码转换成Unicode，再用encode将编码转换成需要转换成的编码。

eg：
由于内置函数 open() 打开文件时，read() 读取的是 str，读取后需要使用正确的编码格式进行 decode()。write() 写入时，如果参数是 Unicode，则需要使用你希望写入的编码进行 encode()，如果是其他编码格式的 str，则需要先用该 str 的编码进行 decode()，转成 Unicode 后再使用写入的编码进行 encode()。如果直接将 Unicode 作为参数传入 write() ，python 将先使用源代码文件声明的字符编码进行编码然后写入。

   # coding: UTF-8

   fp1 = open('test.txt', 'r')
   info1 = fp1.read()
   # 已知是 GBK 编码，解码成 Unicode
   tmp = info1.decode('GBK')

   fp2 = open('test.txt', 'w')
   # 编码成 UTF-8 编码的 str
   info2 = tmp.encode('UTF-8')
   fp2.write(info2)
   fp2.close()


获取编码的方式：
判断是 s 字符串否为Unicode，如果是返回True，不是返回False ：

   isinstance(s, unicode)


下面代码可以获取系统默认编码：

   #!/usr/bin/env python
   #coding=utf-8
   import sys
   print sys.getdefaultencoding()





























# 安装 Scrapy
```
sudo apt install python-pip
sudo apt install libssl-dev
sudo apt install python-lxml
sudo pip install scrapy
```
