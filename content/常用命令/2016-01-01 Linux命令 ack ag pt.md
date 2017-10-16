---
title: Linux命令 ack
date: 2016-01-06T16:46:14+08:00
update: 2017-03-27 16:50:34
categories: [linux_base]
tags: [ack]
---

rg ripgrep is faster than {grep, ag, git grep, ucg, pt, sift}

[pt]()
It searches code about 3–5× faster than ack.
It searches code as fast as the_silver_searcher(ag).

time 统计时间
# grep
time grep -r out_of_memory *
time grep out_of_memory $(find . -type f | grep -v '\.git')
# ack
time ack out_of_memory
# ag
time ag out_of_memory

#pt
1. Install
go get -u github.com/monochromegane/the_platinum_searcher/
curl  -O https://github.com/monochromegane/the_platinum_searcher/releases/download/v2.1.4/pt_linux_amd64.tar.gz
2. 使用
$ # Recursively searchs for PATTERN in current directory.
当前路径下搜索
$ pt PATTERN

$ # You can specified PATH and some OPTIONS.
$ pt OPTIONS PATTERN PATH
3. 配置
If you put configuration file on the following directories, pt use option in the file.

    $XDG_CONFIG_HOME/pt/config.toml
    $HOME/.ptconfig.toml
    .ptconfig.toml (current directory)
```
color = true
context = 3
ignore = ["dir1", "dir2"]
color-path = "1;34"
```
# ack的使用案例

1.在当前目录递归搜索单词”eat”,不匹配类似于”feature”或”eating”的字符串:
$ ack -w eat

2.搜索有特殊字符的字符串’$path=.’,所有的元字符（比如’$',’.')需要在字面上被匹配:
$ ack -Q '$path=.' /etc

3.除了dowloads目录，在所有目录搜索”about”单词:
$ ack about --ignore-dir=downloads

4.只搜索包含’protected’单词的PHP文件，然后通过文件名把搜索结果整合在一起，打印每个文件对应的搜索结果:
$ ack --php --group protected

5.获取包含’CFLAG’关键字的Makefile的文件名。文件名为*.mk,makefile,Makefile,GNUmakefile的都在考虑范围内:
$ ack --make -l CFLAG

6.显示整个日志文件时高亮匹配到的字符串:
$ tail -f /var/log/syslog | ack --passthru 192.168.1.10

7.要换取ack支持的文件过滤类型，运行：
$ ack --help-type
