---
title: python 编码
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [python]
---

>>> u = u"中文"
>>> u
u'\u4e2d\u6587'
>>> s = "中文"
>>> s
'\xe4\xb8\xad\xe6\x96\x87'

>>> s.decode("utf8")
u'\u4e2d\u6587'
>>> u.encode("gbk")
'\xd6\xd0\xce\xc4'


>>> s.encode("gbk")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe4 in position 0: ordinal not in range(128)
>>> u.decode("utf8")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib/python2.7/encodings/utf_8.py", line 16, in decode
    return codecs.utf_8_decode(input, errors, True)
UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)



python编码encode和decode

计算机里面，编码方法有很多种，英文的一般用ascii,而中文有unicode，utf-8,gbk,utf-16等等。

unicode是 utf-8,gbk,utf-16这些的父编码，这些子编码都能转换成unicode编码，然后转化成子编码，例如utf8可以转成unicode，再转gbk，但不能直接从utf8转gbk

所以，python中就有两个方法用来解码（decode）与编码（encode），解码是子编码转unicode，编码就是unicode转子编码

1.编码

#encoding=utf-8
c=u'\u5f00\u59cb\u6267\u884c\u66f4\u65b0\u547d\u4ee4'
print c
print c.encode('utf8')
print c.encode('gbk')

在这里，文件的编码方式为utf8,控制台的编码方式是utf8
变量c是一个unicode编码的字符串（需要在引号前面加u）

输出的结果为：

开始执行更新命令
开始执行更新命令
��ʼִ�и�������

因为控制台是utf8编码，所以unicode编码和utf8编码都能识别，但是gbk就不可以了
2.解码

#encoding=utf-8
a = '中文'
print a.decode('g')
print [a.decode('g')]

这里a为utf8编码，decode方法将utf8解码为unicode编码
输出结果：

中文
[u'\u4e2d\u6587']

由于控制台能识别unicode编码，所以需要把字符串放在列表里面才能看到unicode源码

#encoding=utf-8
a = '中文'
print [a.decode('gbk')]

因为a是utf8编码的，如果将a用gbk解码，程序就会报错

UnicodeDecodeError: 'gbk' codec can't decode bytes in position 2-3: illegal multibyte sequence





a = '中文'
print a.decode('utf-16')

如果用utf-16解码方法解码utf-8的字符串，程序并不会报错（可能因为它们的编码方式相似），但是返回的是乱码：

룤螖





如果一个字符串为unicode码，又没有u标识，可以这样来转换成中文

a='\u8054\u76df\u533a'
b="u'%s'"%a

print eval(b)





后记

1.如果想知道一个字符串是什么编码，可以print [字符串] 来看二进制码

[u'\u76ee\u6807\u533a\u670d']
['\xe7\x9b\xae\xe6\xa0\x87\xe5\x8c\xba\xe6\x9c\x8d']

第一个是unicode，第二个是utf-8


分类: Python
好文要顶 关注我 收藏该文
Xjng
关注 - 3
粉丝 - 33
+加关注
0
0
« 上一篇：安装saltstack
» 下一篇：python使用psutil获取服务器信息
posted @ 2014-06-26 11:59 Xjng 阅读(5845) 评论(0) 编辑 收藏
