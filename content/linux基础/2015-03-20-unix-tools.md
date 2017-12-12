---
title: UNIX那些实用工具
date: 2016-01-07T16:46:14+08:00
update: 2016-01-01
categories: [Linux基础]
tags:
---

# UNIX那些实用工具 #

## 用户 ##

- id 可以看自己加入了哪些组。
- who 看都有谁在系统上。
- adduser username groupname和 deluser username groupname
- usermod 可以更改所属组

## 硬件信息 ##

- cat /proc/cpuinfo  查看cpu信息
- cat /proc/meminfo  查看硬盘信息
- lspci -tv          以树的形式输出连接到PCI上的设备
- hdparm -I /dev/sda    查看第一块串口硬盘的信息
- df -h         查看各个存储设备的剩余空间
- du -sh dirname 查看该目录的总大小，如果不给目录名，就是当前目录
  的大小。相当于 du -csh。
- du -ks是以K为单位显示大小，而du -ms是以兆为单位。

## 文件系统 ##

mkdir 加参数 -p 可以一次建立一个很深的目录，中间如果有原来不存在的目录
，会自动建立。

mv的几个有用选项

- -b 如果目的文件存在，就创造一个备份。
- -f 强暴的，如果目的文件存在就覆盖它，默认选项。
- -i 礼貌的，如果目的文件存在，会询问是否要覆盖。
- -u 只有当源文件比目的文件新或者目的文件不存在时才移动。

### 查看目录：ls ###

- ls -F可以对目录下的文件分类显示，例如目录后显示/，可执行文件后显示*。
- ls -X 按文件类型分类显示
- ls -ld directory 可显示某个目录的访问权限等详细信息。
- ls -r(--reverse) 按字母表逆序按列显示目录内容。如 ls -lhSr按文
  件大小排序，不过文件越大，越排在后面。
- ls -x 横向按行显示目录内容。
- ls -lh 在显示目录内容时，以人类可读的方式给出文件大小。
  -h = --human-readable
- ls -R 递归的显示一个目录及其子目录下的文件。

### 目录栈 ###

- 查看目录栈：dirs。如果目录栈为空，则只显示当前的工作目录。
- 切换到新目录：pushd newpath。新路径会放在栈顶。
- 切换栈中最顶上两项：pushd不加参数。
  同时目录也切换，使用cd -可以实现同样的功能。
- pushd +n 将从栈顶（栈顶为第0个）算起第n个目录和后面的项提到
  栈顶元素前面，原第n项成为栈顶，并成为当前目录。
- pushd -n 将从栈底（栈底为第0个）算起第n个目录和后面的项提到
  栈顶元素前面，原倒数第n项成为栈顶，并成为当前目录。
- popd，弹出栈顶项，目录切换到新的栈顶。
- popd +n 把从栈顶算起第n项弹出，目录并不切换。
- popd -n 把从栈底算起第n项弹出，目录并不切换。

### 建立链接 ln ###

ln [参数] <目标> [链接名]

- -f 强制删除已经存在的目标文件
- -s 创建符号链接
- -t 在指定目录创建链接

## 显示和设置系统时间：date ##

用date查看时间大概每个人都知道，但有几个人会用date设置系统时间呢？

    # set time described by STRING
    date --set=STRING

问题的关键是那个STRING应该怎么写，经实验表明，
按照date输出的格式写设定时间的字符串即可。
这个date真的很好用，不用担心系统重启后时钟又改回去，
可能用date写入系统时钟的同时已写入硬件时钟了。

## 文件补丁：diff 和 patch ##

这两个古老而实用的Unix工具！

    diff a.txt b.txt > 1.diff

生成一个补丁。

    patch a.txt 1.diff

对a.txt应用补丁，将把a.txt变得和b.txt一模一样。

diff是按行为单位比较文件的，也比较容易读懂：

    0a1
    > hehe!

表示在第0行生成第1行：hehe!

    1c1
    < aaaa
    ---
    > hehe!

表示把第1行由aaaa修改成hehe!

    2,3d1
    < bbbb
    < hello

删除第2，3行。


## 归档文件 tar ##

我现在有两个文件a.txt和b.html，想用tar将它们归档，用什么命令？

    tar -c -f ab.tar a.txt b.html

-c表示生成归档文件，-f后面指定我们要生成的归档文件的名称，
这个参数是必须的。后面跟要打包的文件或文件夹。通常为了简洁，
我们会把多个选项连起来写，如上面的命令可以写为：

    tar -cf ab.tar a.txt b.html

注意，f后面要立即跟归档文件名。所以当多个选项连起来写时，f会写在最后。
加上-v选项会显示正在归档的文件名，一般在前台压缩都会使用这个选项，
另外，连字符也可以省略：

    tar cvf ab.tar a.txt b.html

现在，我们不仅要归档a.txt和b.html，而且还要压缩减少它们占的空间。
我们可以：

    tar cjvf ab.tar.bz2 a.txt b.html

或：

    tar czvf ab.tar.gz a.txt b.html

加上-j选项，会使用bzip2压缩归档文件，而加上-z选项会用gzip压缩归档文件。
bzip2的压缩比很高，但是压缩时间也长一些。

现在，给定ab.tar或ab.tar.bz2，我们怎么查看它里面有哪些文件呢？

    tar tf ab.tar.bz2

或

    tar jtf ab.tar.bz2

-t是查看归档文件的内容，不能和-c同时使用。如果加上-v选项，则会显示
归档文件中文件的详细信息。

那么，给定ab.tar.bz2，怎么从中解出文件呢？

    tar xjvf ab.tar.bz2

-x表示从归档文件中释放文件。
如果是bzip2压缩过的，就要加上-j；如果是gzip压缩过的，就需要-z。

如果我只想从ab.tar.bz2中加压出a.txt呢？

    tar xjvf ab.tar.bz2 a.txt

假设ab.tar.bz2在目录 `dir_c` 下，我们怎么把它解压到dir_d下呢？

    cd dir_d
    tar xjvf dir_c/ab.tar.bz2

或者

    tar xjvf -C dir_d dir_c/ab.tar.bz2

用 -C 选项的另一个好处是，dir_d 可以是一个深目录，如果不存在，会创建它。

如果我想把当前目录的c.odt加入ab.tar.bz2，用什么命令呢？
如果压缩了，需要解压出ab.tar，然后用-r选项添加c.odt到ab.tar中：

  tar rvf ab.tar c.odt

对于压缩的归档文件，用-r不行。

## 搜索某个文件：find ##

Linux的高级命令之一。

- -name 要查找的文件名，含通配符*和?的文件名要用引号括起来。
- -perm xxx 文件属性，用三位数表示。
- -atime n n天内访问过的文件。
- -mtime n n天内修改过的文件。
- -ctime n n天内修改过状态的文件。
- -newer filename 比给定的文件新的文件。
- -user username 所有者为username的文件。
- -a and算子。
- -o or算子。
- ! not算子。
- -exec cmd 对满足查找条件的文件执行cmd命令。
- -ok cmd 对满足查找条件的文件执行cmd命令，但在执行前要用户确认。
- -print 打印找到的文件名。


各个表达式可以用\( 和 \)括起来表示优先级。

    find blog/ -name "00*" -o -name "*vim*" -exec cat


## 在文件中搜索：grep ##

grep是global regular expression print的缩写。
是Unix中的另一个高级命令。

grep credit memo 在文件memo中搜索包含credit的那行。
如果搜索的字符串中有特殊字符(\\或空格等)，记住用''括起来。

grep有返回值，如果搜索成功，返回0；如果搜索不成功，返回1；
如果搜索的文件不存在，返回2。

基本的正则表达式字符集：

- ^ 行的开始
- $ 行的结束
- . **一个** 非换行符的任何字符。
- \* 零个或多个 **先前字符** ， ``.*`` 代表任意字符串。
- [] 一个指定范围内的字符，[Gg]匹配G或者g。[A-D]表示ABCD中任一个字符。
- `[^]` 匹配一个不在指定范围内的字符，`[^ABC]` 不是ABC的字符。
- \\< 单词开始，如 \\<grep 匹配包含以grep开头的单词的行。
- \\> 单词结束， 如 grep\\> 匹配包含以grep结尾的单词的行。
- x\\{m\\} 匹配包含连续m个x的行。
- x\\{m,\\} 匹配包含至少m个连续的x的行。
- x\\{m,n\\} 匹配包含至少m个至多n个连续的x的行。
- \w 匹配字母和数字，相当于[A-Za-z0-9]。
- \W 和\w相反，匹配标点空格等。
- (..) 标记匹配字符。如 `\(love\).*\(warm\).*\1.*\2` ，
  将love标记为1，将warm标记为2，用 \\1 和 \\2 可以直接引用。

有用的选项：

- -c 只打印匹配的行数，不显示匹配的内容。
- -h 当搜索多个文件时，不显示文件名前缀。
- -i 忽略大小写差别。
- -q 不打印结果，只打印返回值，如成功则打印0。
- -n 在匹配的行前打印行号。
- -v 反检索，打印不匹配的行。

在源码中搜索某项内容：

    grep -iRn --include="*.c" GoodStudy

## 挂载文件系统：mount ##

- -t 指定这个分区的文件系统格式，一般不必要，mount会自动识别。
- -o 附加参数，如挂载光驱或iso文件时，要加loop。有时为避免乱码，
  需要加iocharset=xxx

用 `umount mount-point` 卸载已经挂载的文件系统。


## 磁盘分区：fdisk和mkfs ##

- `fdisk -l` 列出所有磁盘设备的分区表
- `fidsk -l device` 列出某个磁盘设备的分区表

对设备分区

    fdisk device

启动fdisk，对device进行分区操作，device通常是 `/dev/hda` ，
`/dev/sdb` 等。

按菜单提示建立分区表并保存退出即可。

然后用 `mkfs.vfat /dev/xxx` 可以将指定的分区格式化成fat32格式。

磁盘在使用前会被划分为一个或多个逻辑分区。
这种划分以分区表的方式描述，分区表存在磁盘的第零个扇区。

## 光盘刻录：mkisofs 和 cdrecord ##

与硬盘不同，CD上的文件系统并非先创建后填充数据的。

- `cdrecord -scanbus` 检查是否有刻录光驱。
- 刻录之前将要刻录的内容创建iso。
  ``mkisofs -J -R -v -V test_disc -o test.iso``

  - -J，为了与windows兼容使用Joliet命名记录
  - -R，为乐与unix兼容使用Rock Ridge命名约定
  - -v，输出详细的运行信息
  - -V，指定光盘名称
  - -o，指定输出的iso。

- 刻录。 ``cdrecord -v -eject dev=0,1,0 test.iso``

  - -v，指定详细模式。
  - -eject，刻录后弹出。
  - dev=0,1,0。通过scanbus得到的设备标识指定刻录机。
    我的系统不用指定设备，指定了反而出错。

- 复制盘。如果有两个光驱，
  ``cdrecord -v speed=4 -isosize /dev/scd0`` 。
  不要在速度慢的机器上这么做，容易出错。
  如果只有一个光驱，可以先把源盘内容存成硬盘上的iso，然后刻录：

  ::

    mount /cdrom
    dd if=/dev/scd0 of=/tmp/diskfile.iso
    cdrecord speed=8 fs=8m -v -eject -dummy /tmp/diskfile.iso

  - fs=8m，指定8M缓冲，防止刻录数据中断，默认是4M。
  - -dummy，先排练一次，再真的向目标盘写数据。

看 这篇文章_ 获得更详细的教程。

.. _这篇文章: 001burn-cd.html

## 数码相机：gphoto2 ##

- gphoto2 --auto-detect：自动检测相机类型
- gphoto2 --get-all-files：拷出所有文件
- gphoto2 --delete-all-files：删除所有文件


## 将手机录音amr文件转换成Mp3 ##

安装必要的套件：

    sudo apt-get install amrnb sox lame

用以下指令转换之：

    amrnb-decoder file.amr file.raw # 先轉成 raw 檔
    sox -r 8000 -w -c 1 -s file.raw -r 16000 -w -c 1 file.wav # 再轉為 wav
    lame babycry.wav babycry.mp3 # 最後轉為 mp3

## ADSL上网 ##

用pppoe，ubuntu已经内置了，如果没有则安装之。

配置。sudo pppoeconf，在配置窗口中输入用户名和密码。

手工拨号上网：sudo pon dsl-provider。如果连接有问题，
查看 `/etc/ppp/peers/dsl-provider` ，手工添加 ``password *****`` ，
重拨试试看。

一般情况下，一次拨通后，以后ubuntu都会自动拨号上网了。

手工断网。 sudo poff

查看连接情况：plog和 ifconfig ppp0


## 查看系统进程：ps ##

- ps aux|grep xxx：查看和xxx有关的进程，相当于pgrep xxx。
- ps aux：以BSD方式显示所有进程
- ps -ef：以System-V方式显示所有进程。

- ps -o aa,bb,cc: 可以按指定的格式列出进程，
  可以指定的列有：

  - %cpu cpu占用率
  - %mem 内存占用率
  - egroup 启动进程的用户组
  - euser 启动进程的用户
  - args 进程启动时的参数
  - pid 显示进程的id
  - comm 启动进程的命令
  - nice 进程的优先级，越小优先级越高，列首以 NI 标志
  - tty 进程运行的终端
  - s 进程的状态。进程的状态包括：R（运行中），S（可中断的睡眠，等待信
    号），D（不可中断的睡眠，可能在输入输出），T（停止），Z（僵尸状态
    ，终止了，但未完全解决掉）

例如，下面的命令可以查找僵尸进程：

::

  ps -eo pid,comm,s | grep Z


## 增加和删除用户 ##

增加一个用户用useradd [参数] [用户名]

- -d dir 指定一个已经存在的目录做家目录；
- -m 在/home下给用户新建一个家目录；
- s shellPath 指定用户使用的path。

删除一个用户用userdel [参数] [用户名]

- -r 把这个用户的家目录一起干掉。


## wget: 小巧而强悍的下载工具 ##

- -r: 递归下载
- -l num: --level=num 指定递归深度
- -k: 将链接转换为本地链接
- -p: 获取页面需要的元素，图片等。
- -np: 不要上升到父目录。
- -L: 只跟随相对链接。
- -c: 断点续传的下载。

用下面的代码可以爬取整个网站。

    wget -r -p -k -np http://hi.baidu.com/jiqing0925

还可以将要下载的 *url* 写到一个文件中，每个 *url* 一行，
用 ``wget -i download.txt`` 或
``wget --input-file=download.txt`` 下载。

使用代理：在用户目录下建立.wgetrc，写入代理，如：
``http-proxy=123.456.78.9:80`` 。
然后用 ``wget --proxy=on --proxy-user=username
--proxy-passwd=passwd someUrl`` 下载。

替代 `wget` 的工具有 `aria2c`，还可以下载bt链接

## 其它有用的命令 ##

- cal：字符模式的日历
- iconv ：转换文件的编码
- df -h：查看磁盘空间使用情况
- convmv：文件名转换工具
- enca：查看文件的编码
- sort将文件内容排序后显示，但并不改变文件内容。
- uniq 显示文件的内容并忽略文件中的重复行。
- diff 比较两个文件内容。
- script用于记录会话过程，用script开始记录，用exit结束记录。
- 使用tr可以实现dos到linux文件格式的转换。如：
  cat memo | tr -d '\r' > memo.txt
- bzcat可以显示bzip2压缩的文件的内容。
- zcat可以显示gzip压缩的文件的内容。
- whereis在标准路径下搜索与工具相关的文件，
  包括该工具的二进制文件、帮助文件和源码。如：whereis tar。
- which 相当于 whereis -b abc。
- whatis 可以简要说明工具的功能。如：whatis ls.
- locate 用于在本地搜索文件。
- ntfs-3g /dev/xxx mount-point 读写NTFS分区。
- cfdisk 比 fdisk 更直观。
- tr "[a-z]" "[A-Z]" filename 将输入文件中的小写转换成大写。
- 用man看手册时，按一下p会显示百分比。
