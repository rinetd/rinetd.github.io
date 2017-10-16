---
title: 文本编辑 Emacs Elisp
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [emacs]
---
interactive 可以控制要接受的参数的位置

(defun send-message-to-function (a)
  (interactive "p")
  (message (format "%s" a)))
这么写的话就可以通过C-u 12 函数的快捷键将数字12传递给函数了。如果是用helm调用的话要输入 M-x 函数名 C-u 数字 RET来调用

详细介绍的话这里有中文版： https://github.com/emacs-china/hello-emacs/blob/master/elisp.org#L5453

摘录如下：

    若一个函数带了交互模式声明,则它也就是一个命令了,即可以通过M-x(execute-command)来调用了.

    交互模式声明的格式为(interactive code-string),其中:
       * 若interactive的参数以*开头，则意义是，如果当前buffer是只读的，则不执行该函数

       * interactive可以后接字符串,表示获得参数的方式
      * p 接收C-u的数字参数

           也可以不用P参数,直接在代码中判断current-prefix-arg的值
      * r region的开始/结束位置
      * n 提示用户输入数字参数,n后面可用接着提示符
      * s 提示用户输入字符串参数
      * 若函数接收多个input,需要用\n来分隔
