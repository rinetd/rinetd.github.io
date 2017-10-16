---
title: Linux命令 bash
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [bash]
---

[Linux 技巧: Bash 测试和比较函数](https://www.ibm.com/developerworks/cn/linux/l-bash-test.html)
[Bash的=~正则表达式匹配](http://zengrong.net/post/1563.htm)

[](http://mywiki.wooledge.org/BashPitfalls/)

<<< 就是将后面的内容作为前面命令的标准输入
grep a <<< "$VARIABLE" 意思就是在VARIABLE这个变量值里查找字符a

## 1. bash 命令行快捷键

1. Bash命令行的编辑模式：
   （1）有两种：emacs模式、vi 模式。EMACS=Esc+Meta+Alt+Control+Shift，VI=Visual+Interface。
   （2）emacs模式是默认的。
   （3）可以在选项中查看、修改输入模式：命令set -o查看，命令set -o vi/emacs修 改。

2. emacs模式的热键操作：
   （1）对于字符（ctrl）：
           前移一个字符：ctrl+f
           后移一个字符：ctrl+b
           删除前一字符：ctrl+h
           删除后一字符：ctrl+d
   （2）对于单词（esc）：
           前移一个单词：esc+f
            后移一个单词：esc+b
            删除前一单词：esc+ctrl+h，或ctrl+w
            删除后一单词：esc+d
            恢复最后删除的项：ctrl+y
    （3）对于行（ctrl）：
           移到行首：ctrl+a
           移到行尾：ctrl+e
           从光标所在删除直到行首：ctrl+u
           从光标所在删除直到行尾：ctrl+k
           移到前一行：ctrl+p
           移到后一行：ctrl+n
    （4）对于历史文件（esc）：
           移动到历史文件的首行：esc+<
           移动到历史文件的末行：esc+>
           在历史文件中反向搜索：ctrl+r

3. 命令行补齐：
    （1）通用热键：
           试图补齐命令行：tab
           列出所有可能的备选项：esc+?
    （2）补齐文件名（/）：
           试图补齐文件名：esc+/
           列出所有备选文件名：ctrl+x+/
    （3）补齐用户名（~）：
            试图补齐用户名：esc+~
            列出所有备选用户名：ctrl+x+~
    （4）补齐主机名（@）：
            试图补齐主机名：esc+@
            列出所有备选主机名：ctrl+x+@
    （5）补齐内置变量（$）：
            试图补齐变量名：esc+$
            列出所有备选变量名：ctrl+x+$
    （6）补齐命令名（!）：
            试图补齐命令名：esc+!
            列出所有备选命令名：ctrl+x+!
    （7）补齐历史列表中的命令 名：esc+tab

4. 杂项命令：

    （1）清 屏：ctrl+l
    （2）反转光 标所在字符及其前面的字符：ctrl+t
    （3）从光标处开始的整个单词大写：esc+u
    （4）从光标处开始的整个单词小写：esc+l
    （5）将光标处的单词的首字母大写：esc+c

Emacs风格

ctrl+p: 方向键 上 ↑
ctrl+n: 方向键下 ↓
ctrl+b: 方向键 ←
alt+f: 光标右移一个单词
ctrl+f :方向键 →
alt+b: 光标左移一个单词
ctrl+a:光标移到行首
ctrl+e:光标移到行尾
ctrl+k:清除光标后至行尾的内容。
ctrl+d: 删除光标所在字母;注意和backspace以及ctrl+h的区别，这2个是删除光标前的字符
ctrl+r:搜索之前打过的命令。会有一个提示，根据你输入的关键字进行搜索bash的history
ctrl+m : 输入回车
ctrl+i : 输入tab
ctrl+[ : 输入esc

Ctrl+U 剪切文本直到行的起始(可以用于清空行)
其它
ctrl+h:删除光标前一个字符，同 backspace 键相同。
alt + p 非增量方式反向搜索历史
alt + > 历史命令列表中的最后一行命令开始向前
ctrl+u: 清除光标前至行首间的所有内容。(可用于复制整行内容)
ctrl+w: 移除光标前的一个单词
ctrl+t: 交换光标位置前的两个字符
ctrl+y: 粘贴或者恢复上次的删除
ctrl+l:清屏，相当于clear。
ctrl + xx 光标在行头与行尾进行跳转
alt+r 撤销当前行的所有内容
ctrl+z : 把当前进程转到后台运行
ctrl+s : 锁住屏幕
ctrl+q : 恢复屏幕
ctrl+v key: 输入特殊字符
alt + l 将当前光标处之后的字母转化成小写字母
alt + u 将当前光标处之后的字母转化成大写字母
ctrl + Alt + e 扩展命令行的内容（例如：ls  =>  ls  -l  --color=tty）
ctrl+c:杀死当前进程, 输入模式下，中断输入的命令。
ctrl+d:退出当前 Shell
esc + . 快捷键可以轮询历史命令的参数或选项。
esc + t 快捷键可以 置换前两个单词。
输入重复字母 Esc {100} e 可以输入100个e字符

按多次{esc}可以补全
{esc}{~}可以补全本机上的用户名
{esc}{/}可以补全文件名
{esc}{@}可以补全主机名,localhost可以方便地用 lo补全.

Bang Bang 历史命令

!!    重新执行上一条命令
!N  重新执行第N条命令。比如 !3
!-N 重新执行倒数第N条命令。!-3
!string  重新执行以字符串打头的命令。 比如 !vim
!?string?  重新执行包含字符串的命令。 比如 !?test.cpp?
!?string?%  替换为： 最近包含这个字符串的命令的参数。比如：   vim !?test.cpp?%
!$   替换为：上一条命令的最后一个参数。比如 vim !$
!!string  在上一条命令的后面追加 string ，并执行。
!Nstring  在第N条指令后面追加string，并执行。
^old^new^  对上一条指令进行替换
修饰

:s/old/new/  对第N条指令中第一次出现的new替换为old。 比如 vim !?test.cpp?:s/cpp/c/
:gs/old/new/  全部替换
:wn  w为数字， 取指令的第w个参数.
:p 回显命令而不是执行, 比如 !ls:p  。 这个很有用， 你可以先查看你选的命令对不对，要执行时再使用!!

################################################################################
# 2. bash 配置
## PS1：(提示字符的配置)
这是 PS1 (数字的 1 不是英文字母)，这个东西就是我们的『命令提示字符』喔！ 当我们每次按下 [Enter] 按键去运行某个命令后，最后要再次出现提示字符时， 就会主动去读取这个变量值了。上头 PS1 内显示的是一些特殊符号，这些特殊符号可以显示不同的信息， 每个 distributions 的 bash 默认的 PS1 变量内容可能有些许的差异，不要紧，『习惯你自己的习惯』就好了。 你可以用 man bash (注3)去查询一下 PS1 的相关说明，以理解底下的一些符号意义。
# \a                 ASCII 响铃字符（也可以键入 \007）
# \d                 "Wed Sep 06" 格式的日期
# \e                 ASCII 转义字符（也可以键入 \033）
# \h                 主机名的第一部分（如 "mybox"）
# \H                 主机的全称（如 "mybox.mydomain.com"）
# \j                 在此shell中通过按 ^Z 挂起的进程数
# \l                 此 shell 的终端设备名（如 "ttyp4"）
# \n                 换行符
# \r                 回车符
# \s                 shell 的名称（如 "bash"）
# \t                 24 小时制时间（如 "23:01:01"）
# \T                 12 小时制时间（如 "11:01:01"）
# \@                 带有 am/pm 的 12 小时制时间
# \u                 用户名
# \v                 bash 的版本（如 2.04）
# \V                 Bash 版本（包括补丁级别）
# \w                 当前工作目录（如 "/home/drobbins"）
# \W                 当前工作目录的“基名 (basename)”（如 "drobbins"）
# \!                 当前命令在历史缓冲区中的位置
# \#                 命令编号（只要您键入内容，它就会在每次提示时累加）
# \$                 如果您不是超级用户 (root)，则插入一个 "$"；如果您是超级用户，则显示一个 "#"
# \xxx               插入一个用三位数 xxx（用零代替未使用的数字，如 "\007"）表示的 ASCII 字符
# \\                 反斜杠
# \[                 这个序列应该出现在不移动光标的字符序列（如颜色转义序列）之前。它使 bash 能够正确计算自动换行。
# \]                 这个序列应该出现在非打印字符序列之后。
export PS1="\[\033]0;\w\007\]";

# 变量默认值设置
Use Default Values: ${parameter-default}, ${parameter:-default}
${parameter-default} -- 如果变量parameter没被声明, 那么就使用默认值.
${parameter:-default} -- 如果变量parameter没被设置, 那么就使用默认值.
注：“（没）被声明”与“（没）被设置”在是否有 “:” 号的句式差别中仅仅是触发点的不同而已。
“被声明”的触发点显然要比“被设置”的要低，
“被设置”是在“被声明”的基础上而且不能赋值（设置）为空（没有赋值/设置为空）。
比如：DIR=${1:-/root}  意思是说，当第一个命令行参数没有或者为空时，默认值为/root。
比如：DIR=${1-/root}  当没有参数时（第一个命令行参数没有声明，当然就是没有参数），默认值为/root。
Assign Default Values: ${parameter=default}, ${parameter:=default}
${parameter=default} -- 如果变量parameter没被声明, 那么就把它的值设为default.
${parameter:=default} -- 如果变量parameter没被设置, 那么就把它的值设为default.
##  : 空命令
: ${parameter:=default}
注意前面加上了冒号(:)，即空命令，等同于下面的写法：
[ -z "$parameter" ] && parameter=default
if [ -z "$parameter" ]; then parameter=default; fi

运算符 	描述 	示例
## 文件比较运算符
-e filename 	如果 filename 存在，则为真 	[ -e /var/log/syslog ]
-d filename 	如果 filename 为目录，则为真 	[ -d /tmp/mydir ]
-f filename 	如果 filename 为常规文件，则为真 	[ -f /usr/bin/grep ]
-L filename 	如果 filename 为符号链接，则为真 	[ -L /usr/bin/grep ]
-r filename 	如果 filename 可读，则为真 	[ -r /var/log/syslog ]
-w filename 	如果 filename 可写，则为真 	[ -w /var/mytmp.txt ]
-x filename 	如果 filename 可执行，则为真 	[ -L /usr/bin/grep ]
filename1 -nt filename2 	如果 filename1 比 filename2 新，则为真 	[ /tmp/install/etc/services -nt /etc/services ]
filename1 -ot filename2 	如果 filename1 比 filename2 旧，则为真 	[ /boot/bzImage -ot arch/i386/boot/bzImage ]
## 字符串比较运算符 （请注意引号的使用，这是防止空格扰乱代码的好方法）
-z string 	如果 string 长度为零，则为真 	[ -z "$myvar" ]
-n string 	如果 string 长度非零，则为真 	[ -n "$myvar" ]
string1 = string2 	如果 string1 与 string2 相同，则为真 	[ "$myvar" = "one two three" ]
string1 != string2 	如果 string1 与 string2 不同，则为真 	[ "$myvar" != "one two three" ]
## 算术比较运算符
num1 -eq num2 	等于 	[ 3 -eq $mynum ]
num1 -ne num2 	不等于 	[ 3 -ne $mynum ]
num1 -lt num2 	小于 	[ 3 -lt $mynum ]
num1 -le num2 	小于或等于 	[ 3 -le $mynum ]
num1 -gt num2 	大于 	[ 3 -gt $mynum ]
num1 -ge num2 	大于或等于 	[ 3 -ge $mynum ]



    3.1     保留变量

    BASH 中有一些保留变量，下面列出了一些：

    $IFS　　这个变量中保存了用于分割输入参数的分割字符，默认识空格。
    $HOME 　这个变量中存储了当前用户的根目录路径。
    $PATH 　这个变量中存储了当前 Shell 的默认路径字符串。
    $PS1　　表示第一个系统提示符。
    $PS2　　表示的二个系统提示符。
    $PWD　　表示当前工作路径。
    $EDITOR 表示系统的默认编辑器名称。
    $BASH 　表示当前 Shell 的路径字符串。
    $0, $1, $2, ...

    $RANDOM    随机数
    # 特殊参数
    1) $* : 代表所有参数，其间隔为IFS内定参数的第一个字元
    2) $@ : 与*星号类同。不同之处在於不参照IFS
    3) $# : 代表参数数量
    4) $? : 执行上一个指令的返回值
    5) $- : 最近执行的foreground pipeline的选项参数
    6) $$ : 本身的Process ID
    7) $! : 执行上一个背景指令的PID
    8) $_ : 显示出最後一个执行的命令

    运算符
    含义（ 满足下面要求时返回 TRUE ）

  file1 -nt file2   文件 file1 比 file2 更新
  file1 -ot file2   文件 file1 比 file2 更老
  对应的操作
整数操作

字符串操作
相同          -eq =
不同          -ne !=
大于          -gt >
小于          -lt <
大于或等于     -ge
小于或等于     -le
为空          -z
不为空         -n

# 1、字符串判断

str1 = str2　　　　　　当两个串有相同内容、长度时为真
str1 != str2　　　　　 当串str1和str2不等时为真
-n str1　　　　　　　 当串的长度大于0时为真(串非空)
-z str1　　　　　　　 当串的长度为0时为真(空串)
str1　　　　　　　　   当串str1为非空时为真
[ -z STRING ]  “STRING” 的长度为零则为真。
[ -n STRING ] or [ STRING ]  “STRING” 的长度为非零 non-zero则为真。
[ STRING1 == STRING2 ]  如果2个字符串相同。 “=” may be used instead of “==” for strict POSIX compliance则为真。
[ STRING1 != STRING2 ]  如果字符串不相等则为真。
[ STRING1 < STRING2 ]  如果 “STRING1” sorts before “STRING2” lexicographically in the current locale则为真。
[ STRING1 > STRING2 ]  如果 “STRING1” sorts after “STRING2” lexicographically in the current locale则为真。  

# 2、数字的判断

int1 -eq int2　　　　两数相等为真
int1 -ne int2　　　　两数不等为真
int1 -gt int2　　　　int1大于int2为真
int1 -ge int2　　　　int1大于等于int2为真
int1 -lt int2　　　　int1小于int2为真
int1 -le int2　　　　int1小于等于int2为真

# 3、文件的判断
-a file   文件 file 存在则为真
-e file   文件 file 已经存在
-s file   文件 file 大小不为零

-f file   文件 file 是普通文件
-d file   文件 file 是一个目录
-c file　　文件为字符特殊文件为真
-b file　　文件为块特殊文件为真

-r file   文件 file 对当前用户可以读取
-w file   文件 file 对当前用户可以写入
-x file   文件 file 对当前用户可以执行

-k FILE ]  如果 FILE 存在且已经设置了粘制位则为真。

-g file   文件 file 的 GID 标志被设置
-u file   文件 file 的 UID 标志被设置
-O file   文件 file 是属于当前用户的
-G file   文件 file 的组 ID 和当前用户相同
[ -S FILE ]  如果 FILE 存在且是一个套接字则为真。
[ -L FILE ]  如果 FILE 存在且是一个符号连接则为真。
[ -t FD ]  如果文件描述符 FD 打开且指向一个终端则为真。

[ FILE1 -nt FILE2 ]  如果 FILE1 has been changed more recently than FILE2, or 如果 FILE1 exists and FILE2 does not则为真。
[ FILE1 -ot FILE2 ]  如果 FILE1 比 FILE2 要老, 或者 FILE2 存在且 FILE1 不存在则为真。
[ FILE1 -ef FILE2 ]  如果 FILE1 和 FILE2 指向相同的设备和节点号则为真。

# 4、复杂逻辑判断

-a 　 　　　　　 与
-o　　　　　　　 或
!　　　　　　　　非
################################################################################
# shell编程
```bash
DATEPATTERN="^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$"
if [[ "$STARTDATE" =~ $DATEPATTERN ]] && [[ $ENDDATE =~ $DATEPATTERN ]]; then :
else
echo "date format is invalid!"
exit;
fi
```
多条件判断
```bash
if [ "$i" == "mysql" ] || [ "$i" == "information_schema" ]; then
 continue
fi
```

一．   bash [  ] 单双括号

基本要素：

Ø  [ ] 两个符号左右都要有空格分隔

Ø  内部操作符与操作变量之间要有空格：如  [  “a”  =  “b”  ]

Ø  字符串比较中，> < 需要写成\> \< 进行转义

Ø  [ ] 中字符串或者${}变量尽量使用"" 双引号扩住，避免值未定义引用而出错的好办法

Ø  [ ] 中可以使用 –a –o 进行逻辑运算

Ø  [ ] 是bash 内置命令：[ is a shell builtin

1.测试时逻辑操作符



-a

逻辑与，操作符两边均为真，结果为真，否则为假。

-o

逻辑或，操作符两边一边为真，结果为真，否则为假。

!

逻辑否，条件为假，结果为真。



举例: [ -w result.txt-a -w score.txt ] ;echo $? // 测试两个文件是否均可写



二．   bash  [[  ]] 双方括号



基本要素：

Ø  [[ ]] 两个符号左右都要有空格分隔

Ø  内部操作符与操作变量之间要有空格：如  [[  “a” =  “b”  ]]

Ø  字符串比较中，可以直接使用 > < 无需转义

Ø  [[ ]] 中字符串或者${}变量尽量如未使用"" 双引号扩住的话，会进行模式和元字符匹配

[root@localhostkuohao]# [[ "ab"=a* ]] && echo "ok"

  ok

Ø  [[] ] 内部可以使用 &&  || 进行逻辑运算

Ø  [[ ]] 是bash  keyword：[[ is a shell keyword

[[ ]] 其他用法都和[ ] 一样

二者共同特性：

Ø  && ||-a –o 处理

[  exp1  -a exp2  ] = [[  exp1 && exp2 ]] = [  exp1  ]&& [  exp2  ] = [[ exp1  ]] && [[  exp2 ]]

[  exp1  -o exp2  ] = [[  exp1 || exp2 ]] = [  exp1  ]|| [  exp2  ] = [[ exp1  ]] || [[  exp2 ]]

[root@localhost ~]# if [[ "a" == "a" && 2 -gt1 ]] ;then echo "ok" ;fi

ok

[root@localhost ~]# if [[ "a" == "a" ]] && [[2 -gt 1 ]] ;then echo "ok" ;fi

ok

[root@localhost ~]# if [[ "a" == "a" ]] || [[ 2 -gt 1]] ;then echo "ok" ;fi

ok

[root@localhost ~]# if [[ "a" == "a" ]] || [[ 2 -gt10 ]] ;then echo "ok" ;fi

ok

[root@localhost ~]# if [[ "a" == "a"  || 2 -gt 10 ]] ;then echo "ok" ;fi

ok

Ø  [[ ]] 和 [ ] 都可以和 ! 配合使用

优先级 !  >  && > ||

逻辑运算符  < 关系运算符

逻辑运算符  ： !  &&  || -a  -o

关系运算符  ： <  >  \> \<  ==  = !=  – eq –ne  -gt -ge  –lt  -le



-----------------------------------------------------------------------------

n  [[  ]] 比[ ] 具备的优势

-----------------------------------------------------------------------------



    ①[[是 bash 程序语言的关键字。并不是一个命令，[[ ]] 结构比[ ]结构更加通用。在[[和]]之间所有的字符都不会发生文件名扩展或者单词分割，但是会发生参数扩展和命令替换。



    ②支持字符串的模式匹配，使用=~操作符时甚至支持shell的正则表达式。字符串比较时可以把右边的作为一个模式，而不仅仅是一个字符串，比如[[ hello == hell? ]]，结果为真。[[ ]] 中匹配字符串或通配符，不需要引号。



    ③使用[[ ... ]]条件判断结构，而不是[... ]，能够防止脚本中的许多逻辑错误。比如，&&、||、<和> 操作符能够正常存在于[[ ]]条件判断结构中，但是如果出现在[ ]结构中的话，会报错。



    ④bash把双中括号中的表达式看作一个单独的元素，并返回一个退出状态码。



使用[[ ... ]]条件判断结构, 而不是[ ... ], 能够防止脚本中的许多逻辑错误. 比如,&&, ||, <, 和> 操作符能够正常存在于[[]]条件判断结构中, 但是如果出现在[ ]结构中的话, 会报错。

if 条件判断中有多个条件
#!/bin/bash
score=$1
if [ $score = 5 ]||[ $score = 3 ];then
    echo right
else
    echo wrong
fi

-------------------------------------------------------
#!/bin/bash
score=$1
if [ $score -gt 5 ]||[ $score -lt 3 ];then
    echo right
else
    echo wrong
fi

-------------------------------------------------------
#!/bin/bash
score=$1
if [ $score -gt 15 ]||([ $score -lt 8 ]&&[ $score -ne 5 ]);then
    echo right
else
    echo wrong
fi


-------------------------------------------------------
或：
#!/bin/bash

count="$1"

if [ $count -gt 15 -o $count -lt 5 ];then

   echo right

fi

且：
#!/bin/bash

count="$1"

if [ $count -gt 5 -a $count -lt 15 ];then

   echo right

fi
-------------------------------------------------------
score=$1
if [[ $score -gt 15 || $score -lt 8 && $score -ne 5 ]];then
    echo right
else
    echo wrong
fi
记住必须加两个中括号






Shell中的括号有其特殊的用法, 现总结如下:
1. 符号$后的括号
${a} 变量a的值, 在不引起歧义的情况下可以省略大括号.
$(cmd) 命令替换, 结果为shell命令cmd的输出, 和`cmd`效果相同, 不过某些Shell版本不支持$()形式的命令替换, 如tcsh.
$((exp)) 和`expr exp`效果相同, 计算数学表达式exp的数值, 其中exp只要符合C语言的运算规则即可, 甚至三目运算符和逻辑表达式都可以计算.

2. 多条命令执行
(cmd1;cmd2;cmd3) 新开一个子shell顺序执行命令cmd1,cmd2,cmd3, 各命令之间用分号隔开, 最后一个命令后可以没有分号.
{ cmd1;cmd2;cmd3;} 在当前shell顺序执行命令cmd1,cmd2,cmd3, 各命令之间用分号隔开, 最后一个命令后必须有分号, 第一条命令和左括号之间必须用空格隔开.
对{}和()而言, 括号中的重定向符只影响该条命令, 而括号外的重定向符影响到括号中的所有命令.

3. 双括号的特殊用法
(()) 增强括号的用法, 常用于算术运算比较. 双括号中的变量可以不使用$符号前缀, 只要括号中的表达式符合c语言运算规则, 支持多个表达式用逗号分开.
比如可以直接使用for((i=0;i<5;i++)), 如果不使用双括号, 则为for i in `seq 0 4`或者for i in {0..4}.
再如可以直接使用if (($i<5)), 如果不使用双括号, 则为if [ $i -lt 5 ].
[[]] 增强方括号用法, 常用于字符串的比较. 主要用于条件测试, 双括号中的表达式可以使用&&, ||, <, >等C语言语法.
比如可以直接使用if [[ $a != 1 && $a != 2 ]], 如果不适用双括号, 则为if [ $a -ne 1] && [ $a != 2 ]或者if [ $a -ne 1 -a $a != 2 ].
