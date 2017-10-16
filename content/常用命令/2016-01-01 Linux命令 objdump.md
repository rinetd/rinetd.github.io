---
title: gcc objdump 反汇编
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [objdump]
---

objdump -s -d global > global.txt 是反汇编 global

    -s 参数可以将所有段的内容以十六进制的方式打印出来
    -d 参数可以将所有包含指令的段反汇编
    > global.txt 是将标准输出输出到 global.txt 文件 （专业点的话，叫"输出重定向"）
