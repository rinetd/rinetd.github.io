---
title: Linux命令 rename
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [rename]
---
# 批量去掉文件名里的空格
`rename      's/[ ]+/_/g'       *`
方括号内的空格可以用[:space:]代替，
即可以写成`'s/[[:space:]]+/_/g'`


3.1 将所有*.nc文件中Sam3替换成Stm32
rename -v 's/Sam3/Stm32/' *.nc　　/*执行修改，并列出已重命名的文件*/
3.2 去掉文件后缀名(比如去掉.bak)
rename 's/\.bak$//' *.bak
3.3 将文件名改为小写
rename 'y/A-Z/a-z/' *
3.4 去掉文件名的空格
rename 's/[ ]+//g' *
3.5 文件开头加入字符串(比如jelline)
rename 's/^/jelline/' *
3.6 文件末尾加入字符串(比如jelline)
rename 's/$/jelline/' *



还有几个好玩的例子：
比如统一在文件头部添加上hello
rename         's/^/hello/'       *
统一把.html扩展名修改为.htm
rename          's/.html$/.htm/'      *
统一在尾部追加.zip后缀：
rename          's/$/.zip/'      *
统一去掉.zip后缀：

rename          's/.zip$//'      *

规则化数字编号名，比如1.jpg, 2.jpg ..... 100.jpg , 现在要使文件名全部三位即1.jpg .... 001.jpg

运行两次命令：

rename           's/^/00/'          [0-9].jpg     # 这一步把1.jpg ..... 9.jpg 变幻为001.jpg .... 009.jpg

rename            's/^/0/'           [0-9][0-9].jpg   # 这一步把10.jpg ..... 99.jpg 变幻为010.jpg ..... 090.jpg

Ok ，rename就研究了这么多，暂时不知道如何在rename中引入动态变量，比如$i++

我测试过i=0;  rename -n "s/^.*$/$((++i))/"   * 执行后i被自增了1,并非想我想像中那样，可以在每操作一个文件自增一，猜想可能是因为rename批量实现的，导致++i只计算一次！



-n  用来测试rename过程，并不直接运行，可以查看测试效果后，然后再运行。
好了，再次说明一下，你在使用的时候一定要确认一下你语言的版本，我的是C语言版本~

RENAME(1)                  Linux Programmer’s Manual                 RENAME(1)

功能：

 rename from to file...

用法：

For example, given the files foo1, ..., foo9, foo10, ..., foo278, the commands
              rename foo foo0 foo?
              rename foo foo0 foo??
       will turn them into foo001, ..., foo009, foo010, ..., foo278.

And
              rename .htm .html *.htm
       will fix the extension of your html files.

下面来看一个例子：



最后再来个实际应用当中的问题，先看下以下的图~



看到了吧，我们想把那个图片文件名中的ad字母换成big【注意：拷贝一份，不能直接替换】，那么想想该怎么做呢，对了，就是用rename~

cd /data/openshop_1028/IMG_SERVER/sources/goods/

find ./ -name "*_ad.jpg" -exec cp "{}" {}.1 \;

find ./ -name "*_ad.jpg.1" -exec renamead.jpg.1 big.jpg {} \;

假如要是能够直接替换的话，那就一条命令了：

cd /data/openshop_1028/IMG_SERVER/sources/goods/

find ./ -name "*_ad.jpg" -exec rename ad big {} \;
