---
---
title: makefile笔记
update: 2016-01-01
layout: post
category: Linux开发
---


## 注释 ##

使用'#'开始的行是注释行。如果行尾是\\，则下一行也是注释。
要输入'#'用\\#。


## 变量 ##

使用赋值运算符'='定义变量，如：variableName = string。

使用$(variableName)或 ${variableName}访问变量。


## 基本的Makefile ##

        foo.o : foo.c defs.h
        	cc -c -g foo.c

第一行是条件，如果foo.c或defs.h比foo.o的日期新，就更新foo.o。

第二行是更新条件成立时，要执行的操作。
操作命令要是另起一行，必须以tab键开头：

        targets : prerequisites
            command

command也可以与prerequisites写成一行，不过要带分号：

        targets : prerequisites ; command

如果命令太长，可以写成多行，用\连接。

命令前面加一个-，表示即使命令执行过程中发生错误，也不要管，继续执行。如：

        clean:
            -rm *.o

或

        -include a.mk b.mk


## 隐晦规则 ##

对于c语言，make知道由abc.c生成abc.o，所以不需要写出abc.c，
make也知道abc.o是依赖abc.c的。如

        abc.o: global.h

make就知道abc.o依赖的是global.h和abc.c。
对于c++语言也类似，make知道abc.o是由abc.C或abc.cpp或abc.cc生成的。


## 静态依赖模式 ##

看下面的例子：

        objects = foo.o bar.o
        all: $(objects)
        $(objects): %.o: %.c
               $(CC) -c $(CFLAGS) $< -o $@

- $(objects)是一个目标集合。
- %.o定义了目标集模式，即%中的元素加上.o构成的。
- %.c是目标依赖模式，即文件名为%中的元素加上.c的那些文件。
- $<是自动化变量，表示依赖目标集，即那些.c文件。
- $@也是自动化变量，表示目标集合，即那些.o文件。


## 伪目标 ##

makefile中可能会定义多个目标，但只有一个最终目标。
第一条规则中的目标被确立为最终的目标。

如果第一条规则中有多个目标，那么第一个目标就是最终目标。

        clean:
               rm *.o temp

clean并不是一个文件，只是一个标签。它是一个伪目标。
因此make无法根据文件的日期来决定是否执行它下面的命令。
只有显示指明目标来执行它，如：make clean.

一般伪目标不能和文件重名，但如果用.PHONY显式指明它是伪目标，
则不需要在乎是否与已有文件重名。

        .PHONY: clean
        clean:
                rm *.o temp

伪目标可以使make一次生成多个目标，如makefile的第一条规则为：

        all : prog1 prog2 prog3
        .PHONY : all

伪目标总是不如其它文件“新”，因此它总是被执行。

## include: 引用其它的makefile ##

  include <files>

被include的多个makefile之间以空格隔开。
在make命令执行时，会把include的文件插到当前位置。

如果被include的文件没指定路径，make会先在当前路径下寻找，
找不到再到 `-I` 或 `--include-dir` 指定的目录中去寻找。
也会到/usr/local/include和/usr/include目录中去找。

## 关于gcc,g++的事项 ##

- gcc - 预处理、编译（汇编代码）、汇编（二进制）、链接（执行文件）
- CCFLAGS中有-DSOMETHING，-D是g++的参数，-DSOMETHING代表把SOMETHING
  声明为全局宏，预处理时对所有文件有效。
- gcc(g++)编译选项： ``-x language filename``	指定要编译的文件的语言。

        gcc -x c hello.pig -x none hello.c

  上面先是告诉编译器hello.pig使用的编程语言是c，
  然后用-x none关掉语言选项，让编译器根据文件扩展名确定编程语言。

- -I <dir>  指定编译时的搜索路径。
