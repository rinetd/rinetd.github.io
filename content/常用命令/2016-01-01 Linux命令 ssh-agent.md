---
title: Linux命令 ssh-agent
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [ssh]
---
ssh-agent

一直不知道啥是ssh-agent，今晚看了几篇文章，终于领悟到了。
一般的ssh过程

    ssh-keygen 生成一个公钥私钥，注意，这里生成私钥的时候可以选密码，也可以不选密码。 openssh牛的地方在于能用key 登陆，而非用密码。
    然后做免密码登陆，一般是复制到.ssh/authorized_keys ,或者用ssh-copy-id 。

其实第二步做完以后基本上就不输密码登陆。那需要ssh-agent 以及ssh-add有什么用呢？

其实ssh-keygen的时候，可以输密码，也可以不输密码，刚才那种就是不输密码的情况，那么如果你输了密码，ssh 登陆的时候还是会提示你将私钥的密码输入的(不需要输入服务器的密码)。而ssh-agent能避免这种反复输入私钥的烦恼。
用法很简单

    ssh-agent
    ssh-add 私钥 (这里会提示一次输密码，之后将密码保存在缓存中，之后便不能再input了)

mac上面还有个叫keychain Access 的东西，是管理密码的软件，也是通过ssh-add来实现ssh免密码登陆。
