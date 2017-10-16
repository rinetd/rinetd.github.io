---
title:  用Linux命令行生成随机密码的十种方法
date: 2016-10-05T16:46:14+08:00
update: 2016-09-28 10:22:41
categories:
tags:
---

Linux操作系统的一大优点是对于同样一件事情，你可以使用高达数百种方法来实现它。例如，你可以通过数十种方法来生成随机密码。本文将介绍生成随机密码的十种方法。
这些方法均收集于[Command-Line Fu](http://www.commandlinefu.com/commands/matching/random-password/cmFuZG9tIHBhc3N3b3Jk/sort-by-votes "commandlinefu.com")，并且在我们自己的Linux PC机上测试过。这十种方法的一些在安装了[Cygwin](http://www.cygwin.com/ "cygwin")的Windows下也是可以运行的，特别是最后一种方法。

生成一个随机密码
----------------

对于下面的任何一种方法，你可以通过简单的修改来生成特定长度的密码，或者只使用其输出结果的前N位。希望你正在使用一些类似于[LastPass](http://www.lastpass.com/ "lastpass")的密码管理器，这样你就不用自己记住这些随机生成的密码了。

1. 这种方法使用SHA算法来加密日期，并输出结果的前32个字符：

`date +%s | sha256sum | base64 | head -c 32 ; echo`


2. 这种方法使用内嵌的/dev/urandom，并过滤掉那些日常不怎么使用的字符。这里也只输出结果的前32个字符：
`/dev/urandom tr -dc \_A-Z-a-z-0-9 | head -c${1:-32};echo;`

3. 这种方法使用openssl的随机函数。如果你的系统也许没有安装openssl，你可以尝试其它九种方法或自己安装openssl。

openssl rand -base64 32


4. 这种方法类似于之前的urandom，但它是反向工作的。Bash的功能是非常强大的！

tr -cd '\[:alnum:\]' < /dev/urandom | fold -w30 | head -n1


5. 这种方法使用string命令，它从一个文件中输出可打印的字符串：

strings /dev/urandom | grep -o '\[\[:alnum:\]\]' | head -n 30 | tr -d '\\n'; echo


7. 这种方法使用非常有用的dd命令：


dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev


8. 你甚至可以生成一个只用左手便可以输入的密码：
/dev/urandom tr -dc '12345!@\#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c8; echo ""

9. 如果每次都使用上述某种方法，那更好的办法是将它保存为函数。如果这样做了，那么在首次运行命令之后，你便可以在任何时间只使用randpw就可以生成随机密码。或许你可以把它保存到你的~/.bashrc文件里面。

randpw(){ < /dev/urandom tr -dc \_A-Z-a-z-0-9 | head -c${1:-16};echo;}

10. 最后这种生成随机密码的方法是最简单的。它同样也可以在安装了Cygwin的Windows下面运行。在Mac OS X下或许也可以运行。我敢肯定会有人抱怨这种方法生成的密码没有其它方法来的随机。但实际上如果你使用它生成的全部字符串作为密码，那这个密码就足够随机了。
date | md5sum

是的，这种方法也极其好记。

原文链接： [Lowell Heddings](http://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/) 翻译： [极客范](http://www.geekfan.net) - [小道空空](http://www.geekfan.net/author/wangqing/)
译文链接： <http://www.geekfan.net/7064/>
