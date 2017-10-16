---
title:  Linux下批量将md文件转换为html文件
date: 2016-10-05T16:46:14+08:00
update: 2016-09-28 10:22:41
categories:
tags:
---

https://segmentfault.com/a/1190000000596769
要将markdown文件转换成html文件，可以用discount或python-markdown软件包提供的markdown工具。

$ sudo apt-get install discount

或

$ sudo apt-get install python-markdown

用discount提供的markdown工具转换：

$ markdown -o Release-Notes.html Release-Notes.md

用python-markdown提供的markdown_py工具转换：

$ markdown_py -o html4 Release-Notest.md > Release-Notes.html

如果要生成PDF，可以用python-pisa提供的xhtml2pdf转换：

$ sudo apt-get install python-pisa
$ xhtml2pdf --html Release-Notes.html Release-Notes.pdf

也可以在文档目录下放置一个Makefile来自动完成转换过程：

# Makefile

MD = markdown
MDFLAGS = -T
H2P = xhtml2pdf
H2PFLAGS = --html

SOURCES := $(wildcard *.md)
OBJECTS := $(patsubst %.md, %.html, $(wildcard *.md))
OBJECTS_PDF := $(patsubst %.md, %.pdf, $(wildcard *.md))

all: build

build: html pdf

pdf: $(OBJECTS_PDF)

html: $(OBJECTS)

$(OBJECTS_PDF): %.pdf: %.html
    $(H2P) $(H2PFLAGS) $< > $@

$(OBJECTS): %.html: %.md
    $(MD) $(MDFLAGS) -o $@ $<

clean:
    rm -f $(OBJECTS)

html输出：

$ make html

pdf输出：

$ make pdf

如果markdown的内容是中文，那么转换出来的html在浏览器中打开就无法自动识别编码，pdf更惨，直接是一堆乱码。这时可以借助markdown对html标记的支持，在markdown文件中加入编码信息。例如我们要将markdown转换为html文件，可以在文件的开头加上meta标记，指明编码格式：

$ sed -i '1i\<meta http-equiv="content-type" content="text/html; charset=UTF-8">' *.md

使用以上的方法，转换出来的效果并不理想，所以尝试使用pandoc去转换，在Ubuntu上使用以下指令安装：

$ sudo apt-get autoremove pandoc
$ sudo apt-get install cabal-install
$ cabal update
$ cabal install pandoc

html输出：

$ pandoc Release-Notest.md -o Release-Notes.html

pdf输出：

$ pandoc Release-Notest.md -o Release-Notes.pdf

参考文章

Linux下批量将md文件批量转换为html文件
如何在Linux下使用Markdown进行文档工作
利用Pandoc转换markdown和HTML、LaTeX
