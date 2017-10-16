---
title: ctags
date: 2016-01-01T15:30:01+08:00
update: 2016-01-01
categories: [linux_base]
tags: [ctags]
---
[Exuberant Ctags中文手册](http://easwy.com/blog/archives/exuberant-ctags-chinese-manual/)
[ctags的使用及相关参数介绍](http://www.cnblogs.com/moiyer/archive/2010/03/31/1952685.html)

ctags 可以识别哪些语言
`ctags --list-languages`
查看默认哪些扩展名对应哪些语言：
`ctags --list-maps`
 ctags  为扩展名指定语法解析
`ctags –R --langmap=c++:+.c `
 只扫描C++ 和java文件
--languages=c++,java

!ctags -R --sort=foldcase --file-scope=yes --langmap=c:+.h --languages=Asm,Make,C,C++,C\#,Java,Python,sh,Vim,REXX,SQL --links=yes --c-kinds=+px --c++-kinds=+px --fields=+ainKsS --extra=+qf .

ctags -R -f .tags --languages=C,Java --langmap=C:+.h  --exclude=kernel
ctags -R -f .tags --languages=C,Java --langmap=C:+.h  --exclude=kernel --exclude=out
