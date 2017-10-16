---
title: Linux update-alternatives
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [linux_base]
tags: [update-alternatives]
---
update-alternatives 可以创建、删除、修复、软连接，还能显示出已存在软连接的信息，而所有的这些就构成了备选方案系统（alternatives system）。

很多时候我们会将拥有相同或相似功能的不同应用程序安装在同一个操作系统上，例如同一个操作系统上的不同文本编辑器。这给了这个系统的用户在编辑文本时有了更多的选择，如果用户愿意他们可以自由选择任意一个来使用。但是假如用户没有指定他想用哪一个编辑器，那么会怎样呢？对于程序来说它很尴尬，因为它没有人一样的意愿去做出一个所谓“好”的选择。

不过alternatives系统的出现解决了这个问题。文件系统中的一个共用名（generic name）被那些拥有可交换功能的文件所共享，而备选方案系统和系统管理员共同决定具体是哪一个文件被这个共用名所指定（就是说备选方案系统并不能彻底地帮助用户来管理软连接，毕竟以人为本嘛）。举个例子，如果文本编辑器ed(1)和nvi(1)被安装在一个系统里，并且假定备选系统方案让共用名（/usr/bin/editor）默认指向/usr/bin/nvi，那么系统管理员就可以废除这个指定并且让共用名指向/usr/bin/ed，之后除非有特别明确的必要，否则备选方案系统不会改变这个设定。

其实，共用名并不是直接指向已选定程序（命令）的软连接，而是指向备选方案目录（alternatives directory）中的一个名字。这个名字也是一个软连接，它才是直接指向已选定程序（命令）。这种机制的目的是将管理员所做的更改限定在/etc目录下的相应配置文件中：FHS可以很好地给出这样做的好处。

当任意一个提供特定功能的文件（程序/包）被安装、删除或者更改，update-alternatives都会被调用以更新备选方案中相应文件的信息。update-alternatives经常被Debian包中psstinst（配置）或prerm（安装）脚本调用。

那些为了更好地发挥作用而被同步的多个备选方案被称作组；例如，当多个版本的vi编辑器都被安装时，被/usr/share/man/man1/vi.1指定的man page就应该跟当前被/usr/bin/vi指定的vi版本相对应（不同版本的vi都有各自的man，我们要做的就是要man的时候显示的man page与我们正在使用的vi编辑器对应）。

每一个链接组（link group）都有两种不同的模式：自动模式和手动模式，任一给定时刻一个组都是而且只能是其中的一种模式。如果一个组处于自动模式，当包被安装或删除时，备选方案系统会自己决定是否和如何来更新相应链接（links）。如果处于手动模式，备选方案系统会保留原先管理员所做的选择并且避免改变链接（除非发生broken）。

当第一次被安装到系统时链接组被分配为自动模式；如果之后系统管理员对模式的设置做出更改，这个组会被自动转换为手动模式。

备选方案都有自己的级别（priority）；当一个链接组处于自动模式时，它的成员会指向级别高的备选方案。

当使用--config选项时，update-alternatives 会列出所有链接组的主链接名，当前被选择的组会以*号标出。可以在提示下对链接指向做出改变，不过这会将模式变为手动。如果想回复自动模式，你可以使用--auto选项，或者--config重新选择标为自动的组。

如果你不想用--config提供的交互模式，你也可以使用--set选项

提供相同文件的不同包需要进行同步，换句话说，update-alternatives的使用是对所用牵连的包起作用的。



   update-alternatives是用来维护系统命令的符号链接，以决定系统默认使用什么命令，可以设置系统默认加载的首选程序

我们可能会同时安装有很多功能类似的程序和可选配置，如Web浏览器程序(firefox，konqueror)、窗口管理器(wmaker、metacity)和鼠标的不同主题等。这样，用户在使用系统时就可进行选择，以满足自已的需求。

但对于普通用户来说，在这些程序间进行选择配置会较困难。update-alternatives工具就是为了解决这个问题，帮助用户能方便地选择自已喜欢程序和配置系统功能。

  比如我系统已安装有java 1.6，还想要安装java 1.7，但我不想卸载java 1.6。就可以通过update-alternatives  --config在多个java版本间进程切换。update-alternatives是用于在多个同类型命令中进行切换的一个命令。

在说明update-alternatives的详细用法之前，先让我们看看系统中已有的例子。

打开终端，执行下面的命令：

[root@SC4303 ~]# java -version
java version "1.7.0_45"
OpenJDK Runtime Environment (rhel-2.4.3.3.el6-x86_64 u45-b15)
OpenJDK 64-Bit Server VM (build 24.45-b08, mixed mode)
[root@SC4303 ~]# which java
/usr/bin/java
[root@SC4303 ~]# ls -l /usr/bin/java
lrwxrwxrwx. 1 root root 22 Dec  8 20:49 /usr/bin/java -> /etc/alternatives/java
[root@SC4303 ~]# ls -l /etc/alternatives/java
lrwxrwxrwx. 1 root root 46 Dec  8 20:49 /etc/alternatives/java -> /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java

java这个可执行命令实际是一个链接，指向了/etc/alternatives/java。而这个也是一个链接，指向了/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java这才是最终的可执行文件。之所以建立这样两个链接，是为了方便脚本程序的编写和系统的管理。

2、使用

root@xj alternatives]# ll $(which update-alternatives)
lrwxrwxrwx. 1 root root 12 10月 27 16:39 /usr/sbin/update-alternatives -> alternatives
[root@xj alternatives]# ll $(which alternatives)
-rwxr-xr-x 1 root root 27496 9月  23 2013 /usr/sbin/alternatives

以上可知：update-alternatives和alternatives是同一个命令，只是为了和debian系统一吗？

命令格式:

   update-alternatives  [options]  command

[root@xxj ~]$ update-alternatives
alternatives（备用）版本 1.3.61 - 版权 (C) 2001 红帽公司
在 GNU 公共许可条款下，本软件可被自由地重发行。

用法：alternatives --install <链接> <名称> <路径> <优先度>
               [--initscript <服务>]
               [--slave <链接> <名称> <路径>]*
  alternatives --remove <名称> <路径>
  alternatives --auto <名称>
  alternatives --config <名称>
  alternatives --display <名称>
  alternatives --set <名称> <路径>
  alternatives --list

公用选项：--verbose --test --help --usage --version
           --altdir <目录> --admindir <目录>

install选项

      install选项的功能就是增加一组新的系统命令链接符了
使用语法：

update-alternatives  --install link name path priority [--slave link name path]...

其中link为系统中功能相同软件的公共链接目录，比如/usr/bin/java(需绝对目录);

name为命令链接符名称,如java；

path为你所要使用新命令、新软件的所在目录；

priority为优先级，当命令链接已存在时，需高于当前值，因为当alternative为自动模式时,系统默认启用priority高的链接;

--slave为从alternative。

alternative有两种模式：auto和manual，默认都为auto模式，因为大多数情况下update-alternatives命令都被postinst (configure) or prerm (install)调用的，如果将其更改成手动的话安装脚本将不会更新它了。

例如：

update-alternatives --install /usr/bin/java java /usr/local/lib/java/jdk1.7.0_67 17067   
# /usr/bin/java   java link所在的路径
# java  创建link的名称
# /usr/local/lib/java/jdk1.7.0_67  java链接指向的路径
# 17067  根据版本号设置的优先级（更改的优先级需要大于当前的）

注意：

    这里，你不需要再/etc/alternatives/下面建立任何你想设置的链接名称，因为这完全可以通过update-alternative  --install命令来实现;而且你也不需要在/usr/bin/目录下建立相关链接名称，理由同上。你只需要确定这几个功能类似的软件的源目的地，然后执行如下命令:(以gcc为例)
#sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-3.3 100(这个优先级100必须键入)
#sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.1 90
#sudo update-alternatives --install /usr/bin/gcc gcc /ur/bing/gcc-4.2 80

remove选项

  remove选项的功能是删除一个alternative及相关从alternative

使用语法：

update-alternatives --remove name path

其中name与path与install中的一致，如果所删除的链接组中还有其他链接的话，系统将会自动从其他中选择一个priority高的链接作为默认为链接。

例如：update-alternatives --remove  java /usr/local/lib/java/jdk1.7.0_67
auto选项

    auto选项用于修改命令的模式，

语法如下：

update-alternatives --auto name    #只有两个auto和manual模式，默认都为auto模式

config选项

    config选项功能为在现有的命令链接选择一个作为系统默认的

使用语法为：

 update-alternatives --config name

[root@localhost yxkong]# update-alternatives --config java
共有 2 个提供“java”的程序。
选项    命令
-----------------------------------------------
*+ 1      /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64/jre/bin/java
2      /usr/local/lib/java/jdk1.7.0_67/bin/java
按 Enter 保留当前选项[+]，或者键入选项编号：2

这里才是配置版本的重点，当系统中有多个版本时，可以通过该命令设置默认版本，类似于默认程序

星号表示当前系统使用的，加号表示优先级最高的。输入数值可修改默认配置，直接按回车保持原来状态。

display选项

display选项的功能就是查看一个命令链接组的所有信息，包括链接的模式(自动还是手动)、链接priority值、所有可 用的链接命令等等。

使用语法：

update-alternatives --display name

[yxkong@localhost ~]$ update-alternatives --display java
java - 状态为手工。
链接当前指向 /usr/local/lib/java/jdk1.7.0_67/bin/java
/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64/jre/bin/java - 优先度 170051
....
当前“最佳”版本是 /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64/jre/bin/java。

[root@SC4303 ~]# alternatives --display mta
mta - status is auto.
link currently points to /usr/sbin/sendmail.postfix
/usr/sbin/sendmail.postfix - priority 30
slave mta-mailq: /usr/bin/mailq.postfix
slave mta-newaliases: /usr/bin/newaliases.postfix
slave mta-pam: /etc/pam.d/smtp.postfix
slave mta-rmail: /usr/bin/rmail.postfix
slave mta-sendmail: /usr/lib/sendmail.postfix
slave mta-mailqman: /usr/share/man/man1/mailq.postfix.1.gz
slave mta-newaliasesman: /usr/share/man/man1/newaliases.postfix.1.gz
slave mta-sendmailman: /usr/share/man/man1/sendmail.postfix.1.gz
slave mta-aliasesman: /usr/share/man/man5/aliases.postfix.5.gz
Current `best‘ version is /usr/sbin/sendmail.postfix.

[root@xj alternatives]# update-alternatives --display mta
mta - 状态是自动。
链接目前指向 /usr/sbin/sendmail.postfix
/usr/sbin/sendmail.postfix - 优先度 30
从 mta-mailq：/usr/bin/mailq.postfix
从 mta-newaliases：/usr/bin/newaliases.postfix
从 mta-pam：/etc/pam.d/smtp.postfix
从 mta-rmail：/usr/bin/rmail.postfix
从 mta-sendmail：/usr/lib/sendmail.postfix
从 mta-mailqman：/usr/share/man/man1/mailq.postfix.1.gz
从 mta-newaliasesman：/usr/share/man/man1/newaliases.postfix.1.gz
从 mta-sendmailman：/usr/share/man/man1/sendmail.postfix.1.gz
从 mta-aliasesman：/usr/share/man/man5/aliases.postfix.5.gz
当前“最佳”版本是 /usr/sbin/sendmail.postfix。
