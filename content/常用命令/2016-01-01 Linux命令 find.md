---
title: Linux命令 find
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [find]
---
[Find replace files Command Line](http://linuxtips.kig5.com/find-replace-files-command-line-linux.html)

xargs 之所以能用到这个命令，关键是由于很多命令不支持|管道来传递参数，而日常工作中有有这个必要，所以就有了xargs命令，例如：
这个命令是错误的
find /sbin -perm +700 |ls -l
这样才是正确的
find /sbin -perm +700 |xargs ls -l   


| 管道是实现“将前面的标准输出作为后面的标准输入”
xargs是实现“将标准输入作为命令的参数”
echo "--help"|cat
echo "--help"|xargs cat

# 多线程处理数据
find . -type f | xargs -i -n 1 -P 20 sh -c "grep "asdf" {} > {}.log"
cat url_file |xargs -n 1 -P 100 wget

# 参数详解
-prune                       #忽略某个目录
-name   filename             #查找名为filename的文件

-type   b/c/d/p/l/f/s          #查是块设备block、字符设备character、目录directory、管道pipe、符号链接link、普通文件file,socket
-size   b/c/w/k/M/G          #查长度为n块[或n字节]的文件 [+|-]b[block]/c[bytes]/w[word]/
-perm [+|-] MODE             #按执行权限来查找; 不带[+|-]表示精确权限匹配，+表示任何一类用户的任何一位权限匹配 - 表示每类用户的每位权限都匹配
## 时间属性
-amin    -n +n
-mmin    -n +n
-cmin    -n +n
-atime   -n +n               #按文件访问时间来查
-mtime   -n +n               #按文件更改时间来查找文件，-n指n天以内，+n指n天以前
-ctime   -n +n               #按文件创建时间来查找文件，-n指n天以内，+n指n天以前
-newer   f1 !f2              #查更改时间比f1新但比f2旧的文件
## 用户属性
-user    username            #按文件属主来查找
-group groupname             #按组来查找
-user:      查找owner属于-user选项后面指定用户的文件。
! -user:    查找owner不属于-user选项后面指定用户的文件。
-group:   查找group属于-group选项后面指定组的文件。
! -group: 查找group不属于-group选项后面指定组的文件。
-nogroup                     #查无有效属组的文件，即文件的属组在/etc/groups中不存在
-nouser                      #查无有效属主的文件，即文件的属主在/etc/passwd中不存
-depth                       #使查找在进入子目录前先行查找完本目录
-mount                       #查文件时不跨越文件系统mount点
-follow                      #如果遇到符号链接文件，就跟踪链接所指的文件
-fstype                      #查位于某一类型文件系统中的文件，这些文件系统类型通常可 在/etc/fstab中找到
-cpio                        #对匹配的文件使用cpio命令，将他们备份到磁带设备中

find [PATH] [option] [action]  

# 与时间有关的参数：  
-mtime n : n为数字，意思为在n天之前的“一天内”被更改过的文件；  
-mtime +n : 列出在n天之前（不含n天本身）被更改过的文件名；  
-mtime -n : 列出在n天之内（含n天本身）被更改过的文件名；  
-newer file : 列出比file还要新的文件名  
# 例如：  
find /root -mtime 0 # 在当前目录下查找今天之内有改动的文件  

# 与用户或用户组名有关的参数：  
-user name : 列出文件所有者为name的文件  
-group name : 列出文件所属用户组为name的文件  
-uid n : 列出文件所有者为用户ID为n的文件  
-gid n : 列出文件所属用户组为用户组ID为n的文件  
# 例如：  
find /home/ljianhui -user ljianhui # 在目录/home/ljianhui中找出所有者为ljianhui的文件  

# 与文件权限及名称有关的参数：  
-name filename ：找出文件名为filename的文件  
-size [+-]SIZE ：找出比SIZE还要大（+）或小（-）的文件  
-tpye TYPE ：查找文件的类型为TYPE的文件，TYPE的值主要有：一般文件（f)、设备文件（b、c）、  
             目录（d）、连接文件（l）、socket（s）、FIFO管道文件（p）；  
-perm mode ：查找文件权限刚好等于mode的文件，mode用数字表示，如0755；  
-perm -mode ：查找文件权限必须要全部包括mode权限的文件，mode用数字表示  
-perm +mode ：查找文件权限包含任一mode的权限的文件，mode用数字表示  
# 例如：  
find / -name passwd # 查找文件名为passwd的文件  
find . -perm 0755 # 查找当前目录中文件权限的0755的文件  
find . -size +12k # 查找当前目录中大于12KB的文件，注意c表示byte  

--------------------------------------------------------------------------------
# 查找
find . -not -group ftp

#  find的文件名中有空格，如何与xargs配合
-i  替换字符串，将搜索的每一行内容作为一个整体处理了。
find . -type f | xargs -i chmod -x "{}"
find . -type f -print -exec sudo chmod -x {} \;

# xargs -exec **详情参考sed**
#xargs将参数一次传给echo，即执行：echo begin ./xargs.txt ./args.txt  
`find . -name '*.txt' -type f | xargs echo begin `
#exec一次传递一个参数，即执行：echo begin ./xargs.txt;echo begin ./args.txt  
`find . -name '*.txt' -type f -exec echo begin {} \;   # [\; \+]`

## 查找并删除 .git 目录
find ./subclone -name .git -type d |xargs rm -r

## 排除指定文件
find . -type f -not -name "x"

## 查找大于100k文件
find . -size +100k

## 排除目录是必须带 -o 参数
1.  只排除一个目录或者文件，如查找/tmp/ 目录下所有文件（不包含目录）, 并且不包含目录123
    `find /tmp/ -path "/tmp/123" -prune -o         -type f  -print`

2. 排除两个或者多个目录或者文件，如查找/tmp/ 目录下所有文件（不包含目录）, 并且不包含目录123和目录234和目录345
    `find  /tmp/ \( -path "/tmp/123" -o -path "/tmp/234" -o -path "/tmp/345" \) -prune -o     -type f -print`
    `find . -path "./proc" -prune -o     -path "./sys" -prune -o        -cmin -50`

注意，如果是查找目录时，-path 后面的目录名一定不要带/  如 写成  -path "/tmp/123/" 就错了，而查找文件时，带/ 没有问题。
```
查找最近30分钟修改的当前目录下的.php文件
find . -name '*.php' -mmin -30
查找最近24小时修改的当前目录下的.php文件
find . -name '*.php' -mtime 0
查找最近24小时修改的当前目录下的.php文件，并列出详细信息
find . -name '*.inc' -mtime 0 -ls
查找当前目录下，最近24-48小时修改过的常规文件。
find . -type f -mtime 1
查找当前目录下，最近1天前修改过的常规文件。
find . -type f -mtime +1

sed -i "s#http://aywusq#https://aywusq#g" `grep -rl http://aywusq .`
find . -name "*.html" -type f -print | xargs sed -i 's#http://aywusq#https://aywusq#g'
find . -name "*.html" -type f -print | xargs sed -i 's/bizchinalinyi/chinaebr/g'
```


## 查木马
```
  find . -name "*.php" | xargs grep "eval"
  find . -name "*.php" | xargs grep "base64_decode"
```
################################################################################
netstat -ano |find /C "80"


关于find -perm +mode
-mode
mode
/mode 的用法：
+mode指部分满足权限
-mode指完全满足权限（还可以比此权限更高）
mode指正好满足权限的
/mode指只要有权限就可以，
find -perm -mode ， 表示mode中转换成二进制的1在文件权限位里面必须匹配，比如mode=644那么转换成二进制为110 100 100，而被查找的文件的权限位也可以被转换成一个二进制数，两者在位上为1的部分必须完全匹配，而0则不管。例如被查找的文件的权限为转换成二进制数是111 111 111那么这个比如被匹配，而假如是100 100 100那么则不会匹配。所以这个’-‘的作用归结起来就是匹配比mode权限更充足的文件
find -perm +mode ， 与 -mode的区别是+mode只需其中的任意一个1的部分被匹配，-mode是所有1的部分都必须被匹配，同样+mode也不管0位
