---
title: Linux命令 enca 编码转换
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [enca]
---
# iconv
输入/输出格式规范：
-f, --from-code=名称 原始文本编码
-t, --to-code=名称 输出编码

信息：
-l, --list 列举所有已知的字符集

输出控制：
-c 从输出中忽略无效的字符
-o, --output=FILE 输出文件
-s, --silent 关闭警告
--verbose 打印进度信息
`iconv -l | grep `
`iconv -f utf-8 -t gb2312 config > config.tmp`
`curl -s http://www.google.com.hk/ | iconv -f big5 -t gbk`

# 转换文件编码 enca
`enca -L zh_CN -x UTF-8 *.md`

更好的傻瓜型命令行工具enca，它不但能智能的识别文件的编码，而且还支持成批转换。  　　
1.安装  　　
$sudo apt-get install enca  　　
2.查看当前文件编码  　　
`enca -L zh_CN ip.txt`     Simplified Chinese National Standard; GB2312     Surrounded by/intermixed with non-text data  　　
3.转换  　　命令格式如下  　　
$`enca -L` 当前语言 -x 目标编码 文件名  　　
例如要把当前目录下的所有文件都转成utf-8  　　
`enca -L zh_CN -x utf-8 *`     
检查文件的编码　enca -L zh_CN file   　　
将文件编码转换为"UTF-8"编码　 enca -L zh_CN -x UTF-8 file
如果不想覆盖原文件可以这样         enca -L zh_CN -x UTF-8 < file1 > file2

# linux文件名编码转换工具convmv
今天介绍个文件名转码的工具–convmv，convmv能帮助我们很容易地对一个文件，一个目录下所有文件进行编码转换，比如gbk转为utf8等。
语法：
convmv [options] FILE(S) … DIRECTORY(S)
主要选项：
1、-f ENCODING
指定目前文件名的编码，如-f gbk
2、-t ENCODING
指定将要转换成的编码，如-t utf-8
3、-r
递归转换目录下所有文件名
4、–list
列出所有支持的编码
5、–notest
默认是只打印转换后的效果，加这个选项才真正执行转换操作。
更多选项请man convmv。

convmv -f 源编码 -t 新编码 [选项] 文件名
常用参数：
   -r 递归处理子文件夹
   --notest 真正进行操作，请注意在默认情况下是不对文件进行真实操作的，而只是试验。
   --list 显示所有支持的编码
   --unescap 可以做一下转义，比如把%20变成空格
比如我们有一个utf8编码的文件名，转换成GBK编码，命令如下：
convmv -f UTF-8 -t GBK --notest utf8编码的文件名

例子：递归转换centos目录下的目前文件名编码gbk为utf-8:
`convmv -f gbk -t utf-8 --notest -r centos`
