---
title: 文本编辑 editorconfig
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [editorconfig]
---
[](http://editorconfig.org/)
[EditorConfig介绍](http://ju.outofmemory.cn/entry/104488)

```
root = true

[*]
indent_style = space								# tab space
indent_size = 2
end_of_line = lf 										# lf crlf cr
charset = utf-8											# latin1 utf-8 utf-16be utf-16le
trim_trailing_whitespace = true			# true false
insert_final_newline = true					# true false

[*.{c,cpp,h,java,php}]
indent_size = 4

# Tab indentation (no size specified)
[Makefile]
indent_style = tab

[{package.json,*.yml}]
indent_style = space
indent_size = 2

```

    indent_style：tab为hard-tabs，space为soft-tabs。
    indent_size：设置整数表示规定每级缩进的列数和soft-tabs的宽度（译注：空格数）。如果设定为tab，则会使用tab_width的值（如果已指定）。
    tab_width：设置整数用于指定替代tab的列数。默认值就是indent_size的值，一般无需指定。
    end_of_line：定义换行符，支持lf、cr和crlf。
    charset：编码格式，支持latin1、utf-8、utf-8-bom、utf-16be和utf-16le，不建议使用uft-8-bom。
    trim_trailing_whitespace：设为true表示会除去换行行首的任意空白字符，false反之。
    insert_final_newline：设为true表明使文件以一个空白行结尾，false反之。
    root：表明是最顶层的配置文件，发现设为true时，才会停止查找.editorconfig文件。

* 	匹配除/之外的任意字符串
** 	匹配任意字符串
? 	匹配任意单个字符
[name] 	匹配name字符
[!name] 	匹配非name字符
{s1,s3,s3} 	匹配任意给定的字符串（0.11.0起支持）
