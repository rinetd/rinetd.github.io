---
title: Emacs笔记
category: 文本编辑
update: 2016-01-01
---

# 1. 关于Emacs #

EMacs 是一个 Lisp 解释器，是 Elisp Macros 的缩写。用 /高德纳/ 的话讲，用
EMacs 按键就像弹琴。没错，使用Emacs，你经常需要按 Esc + Meta + Alt +
Control + Shift，所以叫 *Emacs* 。

一些约定：

- C-x 表示同时按住Ctrl和x，M-x 表示先按Esc再按x，或者按住Alt的时候按x。
- C-x v l表示同时按住Ctrl和x后，松开Ctrl再依次按v和l。
- C-x C-f表示按住Ctrl同是分别按x和f。
- 键序列是大小写敏感的。如果你的键序列输入一半，你又改变了注意，可以按
  C-g 或者 Esc Esc Esc，取消键入的命令。

## Good reference ##

1. [EmacsWiki](http://www.emacswiki.org)
2. [CmdMarkdown](https://www.zybuluo.com/mdeditor)
3. [sacha chua, an awsome girl](http://sachachua.com/blog/)

# 2. 启动Emacs时的选项 #

- -nw 在终端下启动emacs，不使用gui。
- -q 不读取 =.emacs= 。
- -Q 不仅不读取 =.emacs= ，也略过 site-lisp 。


# 3. 用户界面 #

如果你在终端使用Emacs, 用 (M-`) 或者 (ESC, `) 可以方便的使用菜单.
在图形界面下同样可以试试啊.

- 状态栏上的标记：（把鼠标放在状态栏上在 MiniBuffer 上会出现说明）
  + -- 表明缓冲区的内容和磁盘上的一致。
  + ** 表明文件被修改了，还没保存。
  + %% 表明文件是只读的。
  + %* 表明文件是写保护的，但是已经被修改了。
- M-x menu-bar-mode能显示和隐藏菜单。
- M-x tool-bar-mode能显示和隐藏工具栏。
- M-x hl-line-mode 打开高亮当前行模式。
- M-x set-background-color      设置背景色。
- M-x set-foreground-color      设置前景色。
- M-x set-cursor-color          设置光标颜色。

## gtk版Emacs设置Widget外观 ##

当我们使用 xlib 版的Emacs时，可以通过 XResource 定义 Emacs 的菜单
栏、工具条、滚动条的外观。

现在，在Linux上我们大多使用 gtk版的Emacs，是否还有办法定义 Emacs
的菜单栏、工具条等的外观？

一种方法是，通过 ~/.gtkrc 定义全局的 Gtk Widget 的外观。Emacs的外
观自然也会改变。

另一种方法是单独定制 emacs 的 Gtk Widget的外观。
<http://www.gnu.org/software/emacs/manual/html_node/emacs/GTK-resources.html>
讲述了 emacs 的资源名，以及如何定制。

下面我们改变 Emacs 菜单栏的字体。
在 ~/.emacs.d/ 下新建 ``gtkrc`` 文件。
内容如下：

    style "emacs-menu"
    {
      font_name = "monospace 10"
      bg[NORMAL] = "gray70"
      bg[ACTIVE] = "gray75"
      fg[NORMAL] = {0.0, 0.2, 0.05}
    }

    widget "*menubar*" style "emacs-menu"
    widget "*emacs-menuitem*" style "emacs-menu"

现在重启 Emacs 看看，菜单栏是不是变样了？

# 4. 与文件有关的操作 #

- C-x C-f    查找文件并且在新缓冲区中打开。
  当打开文件时，提示的路径可能不是你想要的，你可以输入 =//= ，
  则提示的路径变为 =/= 。你也可以输入 =/~/= ，
  则提示的路径变为 =~/= 。
- C-x C-r 以只读方式打开文件。
- C-x C-v    读入另一个文件，覆盖当前缓冲区的内容
- C-x i      把文件插入到光标的当前位置
- C-x C-s    保存文件
- C-x C-w    把缓冲区内容写入一个文件（另存为）
- C-x C-c    退出Emacs

# 5. 光标移动 #

- C-f     光标前移一个字符（右）
- C-b     光标后移一个字符（左）
- C-p     光标前移一行（上）
- C-n     光标后移一行（下）
- M-f (C-Right)    前移一个单词，也可以用C-<right>或M-<right>
- M-b (C-Left)    后移一个单词，也可以用C-<left>或M-<left>
- M-r     循环移动到窗口中间,窗口顶端,窗口底端
- C-a     移动到行首
- C-e     移动到行尾
- M-m     移动到第一个非空格字符
- M-e     前移一个句子
- M-a     后移一个句子
- M-}     前移一个段落
- M-{     后移一个段落
- C-v: scroll-up, 屏幕上卷一屏, 如果加参数N, 向上滚动N行. 如果N是
  负数, 则相当于 C-u -N M-v.
- M-v: scroll-down, 屏幕下卷一屏.
- C-x >: scroll-left. This command is disabled by default.
- C-x <: scroll-right. 加参数N可以指定滚动N列。
- C-x ]    前移一页（页由Ctrl+L分割，C-q C-l 可以插入一个分页符）
- C-x [    后移一页
- M-< (C-Home) 移动光标到文档开头，其实可以加参数2-9，将光标移到距开头
  0.2-0.9处，如M-5 M-< 将光标定位到文档50%处。
- M-> (C-End)    后移到文件尾
- C-l: recenter-top-bottom. 重新绘制屏幕，当前行放在画面中心, 继续
  调用该函数, 会把当前行放在窗口顶端, 然后是底端, 再然后又是中间.
  在Emacs 23之前的版本中, C-l 只是绑定到 recenter. 是否重新绘制屏
  幕受变量 recenter-redisplay的影响, 如果该变量值是 nil, 则始终不
  重绘屏幕. 默认值是 `tty`, 表示只有在终端中才重绘屏幕.
- C-u n C-l: 将当前行滚动到距屏幕顶端第n行的位置，所以C-u 0 C-l，
  将当前行移动到屏幕顶部。当然C-0 C-l或M-0 C-l也能实现同样的功能。
  C-u C-l把当前行滚动到屏幕中间, 如果参数是负数, 则把当前行滚动到
  距屏幕底部第n行的位置.
- C-M-l: reposition-window, 主要针对lisp文件, 尽量让定义或注释完全
  可见. 例如, 如果函数定义不完全可见, 尽可能使整个函数可见. 如果函
  数完全可见, 则将之滚动到屏幕顶端.
- C-o open-line, 插入空行, 如果光标在行首, 则在当前行上方插入空行;
  如果光标在行尾, 则在当前行下方插入空行；如果光标在行中央, 则分割
  当前行.
- C-x C-o 把多个空行合并成一个空行, 如果只有一个空行, 则删除这个空行.
- M-x flush-lines RET ^$ 删除选中区域的所有空行

- M-x goto-line 到文件第N行。
- M-x goto-char 到文件第N个字节。

# 6. 删除剪切与复制 #

和vim相同，所有删除都是剪切操作。

在 EMACS 中所谓的 kill-ring 是指一个存放从文件缓冲区中删除和
复制的文本的地方。文本在缓冲区中是消失了， 但却储存在kill-ring。
EMACS 可以有许多的缓冲区，但却只有一个 kill-ring。
EMACS 所设计共享的 killing-ring 的用意是让被遗弃的文件可以找回， 而且各
缓冲区彼此也可借由killing-ring 来建立一个互通的管道。
因此，想将甲缓冲区中的某些文本给乙缓冲区，只要将那些文本放
入 kill-ring 中，乙缓冲区就可以至此共享的 kill-ring 中将文本取出。

要查看kill-ring中的内容， 键入 =Ctrl-h v= 后，echo area 处会出现提示：输入
"kill-ring"， Emacs 会另开一个 视窗来显示 kill-ring的值。

- C-d或Del     删除光标位置上的字符
- BACKSPACE    删除光标位置上的字
- M-d          删除光标后面的单词
- M-DEL        删除光标前面的单词
- C-k          从光标位置删除到行尾
- C-S-BACKSPACE  不管光标位置在哪, 删除当前整行的内容 (kill-whole-line)
- M-k          删除到句子结尾
- C-x <DEL>    删除光标前面的句子
- C-M-k   删除point后面的sexp, kill-sexp.
- C-w     删除选中的文件块
- C-M-w   append-next-kill, 下一次kill的内容会追加到kill-ring中最新的entry.
- M-w     复制选中的文件块
- C-y 在当前位置粘贴剪贴板的内容, point在后，mark在开始处。C-u
  C-y会使得point在前，mark在结束处。
- C-y M-y   即如果在粘贴命令后根一个M-y，则切换到剪贴板中前一个内容，
  可以有多个M-y。
- 按下M-x后在辅助输入区中输入"kill-paragraph"删除光标后面的段落，
  按下"backward-kill-paragraph"删除光标前面的段落
- M-z CHAR 剪切到当前行指定的字符CHAR, 包括CHAR在内。

# 7. 标记 #

- C-@  标记文本块的开始（或结束）位置，
  如果你的不是用C-SPC激活输入法，用C-SPC也可以开始标记。
  或者M-x set-mark-command。
- M-@       从光标所在位置开始，标记到一个单词的末尾。
- C-M-@     在point后的表达式(如被括号包围的文本)的结尾设置标记.
- M-h     标记段落, 将 point 移到段首, 在段末设定标记.
- C-M-h 标记函数(mark-defun), 将 point 移到函数开头, 在函数末尾设
  定标记.
- C-x C-x 交换当前插入点和上一个marker的位置。
- C-x C-p    标记页面, point 在页开始的地方, 在页结束的地方设定标记.
- C-x h    标记整个缓冲区
- M-h 标记一段, 重复按M-h会继续标记后面的段落. 可以加前缀参数, 如
  C-u M-h, 会标记从当前段开始的后续四段. C-u -2 M-h 会标记从
  point 向上的两段.
- 如果用鼠标标记一个区域(鼠标左键拖动, 鼠标右键单击), 会自动将选定
  的区域复制到kill-ring中.
- M-=, M-x count-words-region 会显示选中的区域中有多少行，多少词，多少个字符。
  （注意，一个汉字也只算一个字符哦）

## 可以应用于 region 的操作: ##

- M-%: query-replace.
- C-x <TAB> 或 C-M-\\ 缩进.
- M-x eval-region.
- C-x r s 将选定的内容copy到register中 (copy-to-register). 你可以
  用 M-x append-to-register 向register中添加内容. C-x r i 将指定
  register的内容插入到当前位置.
- M-$: ispell-region
- M-x delete-selection-mode. 开启这个模式后, 如果有选定的文本, 在
  你输入文本时会自动删除选定的文本.

## mark ring ##

- mark的位置存储在mark ring中, 默认可以存储16个mark的位置. 你可以
  通过设置 =mark-ring-max= 来改变这个值. 每个buffer都有自己的
  mark ring.
- 使用mark在文档中跳转的方法, C-SPC C-SPC在当前位置做一个标记, 然
  后通过 C-u C-SPC可以回到做标记的地方. 如果
  `set-mark-command-repeat-pop` 的值不是 nil, 则C-u C-SPC后就可
  以继续按C-SPC回到以前的标记位置.
- Emacs也有一个全局的 mark-ring, 每当你激活一个标记, 在存入当前
  buffer的mark-ring的同时, 也存入global-mark-ring. *C-x C-SPC* 可
  以跳回到global-mark-ring中上一个mark所在的buffer和位置.

## 收集分散的文本 ##

- M-x append-to-buffer 将选定的文本追加到指定buffer的光标处，光标
  放在追加文本的末尾.
- M-x prepend-to-buffer 也是将选定的文本追加到指定的buffer处，光标
  放在追加文本的开始处.
- M-x copy-to-buffer 用选定的文本替换 指定buffer 中原有的文本.
- M-x insert-buffer 将指定的 buffer 插入到光标处，光标放置于插入的
  内容之前，并在插入内容的末尾放置标记. 比如你用 append-to-buffer
  累积了一些文本到 buffer1 中，可以再用 insert-buffer buffer1 将累
  积的文本取回来.
- *M-x append-to-file* 将选定的文本追加到指定文件的末尾.

# 8. 寄存器 Registers #

寄存器可以存储 mark或point的位置, 文本, 矩形区域内的文本, 窗口配置, 文件名等.

寄存器的名字可以是一个字母(区分大小写), 也可以是一个数字或者其它字符.

- M-x view-register R: 查看寄存器中R存放的内容.
- C-x r <SPC> R: point-to-register, 把point在哪个buffer什么位置的
  信息记录下来.
- C-x r j R: jump-to-register, 跳转到寄存器R记录的位置. 如果缓冲区
  已经关闭, Emacs会问你是否重新加载.
- C-x r s R: 复制region内的内容到R中. C-u C-x r s R, 在将region复
  制到R中后从buffer中删除.
- C-x r i R: 将R中的内容插入到当前位置. Point在插入的文本前, mark
  在插入的文本后. 以C-u引导则相反.
- M-x append-to-register <RET> R: 向R中追加文本. 以C-u引导也会从
  buffer中删除选定的内容.
- M-x prepend-to-register <RET> R: 向R中已有的内容之前添加内容.

- C-x r r R: 把rectangle选定的内容存入寄存器R中. 同样用C-x r i R取回内容.
- C-x r w R: window-configuration-to-register, 将窗口配置存入R. 包
  括窗口布局, 以及各窗口关联的缓冲区. C-x r j R可以恢复存储在R中的窗口配置.
- C-x r f R: frame-configuration-to-register, 将各帧的窗口布局, 缓
  冲区等配置存入R, 同样用C-x r j R来恢复. C-u C-x r j R在恢复
  frame configuration时, 会删除 frame configuration 不包含的帧.
- C-u NUMBER C-x r n R: 将数字NUMBER存入R. 如果没有参数,
  会把0存入R. 同样用C-x r i R来插入.
- C-u NUMBER C-x r + R: 给R中存储的数字增加NUMBER, 如果没有参数, 增加1.
- (set-register ?R '(file . "PATH"))会把文件名存入R, C-x r j R会打开该文件.

# 9. 查找与替换 #

- C-s RET searchstring RET  向前开始非递增查找操作，
  继续按C-s就会查找下一个。如果你上次搜索了beer，只需要按C-s C-s，
  就会再搜索beer。如果你已经标记了要搜索的文本，只需要按C-s M-y。
  可以用C-s M-p或C-s M-n翻看查找历史。
- ESC C-s 递增地用正则表达式向前查找
- ESC C-r 递增地用正则表达式向后查找
- C-r RET searchstring RET  和C-s对称，只不过是向后查找。
- C-s C-w    开始递增查找，把光标位置的单词做查找字符串
- C-s C-y    开始递增查找，把光标位置到行尾之间的文本做查找字符串
- 多次按C-s进入增量搜索后，按Backspace可定位到上一个匹配处。
- M-x search-forward   非递增的向前查找
- M-x search-backward   非递增的向后查找
- M-x re-search-forward    非递增地用正则表达式向前查找
- M-x re-search-backward   非递增地用正则表达式向后查找
- C-s return C-w  向前开始单词查找（不受换行符、空格、标点符号影响）
- C-r return C-w  向后开始单词查找（不受换行符、空格、标点符号影响）
- M-x replace-string RET 旧字串 RET 新字串 RET（不征询意见）
- M-x replace-regexp 不征询意见地替换一个正则表达式
- M-% (M-x query-replace) 交互式替换。空格或y，替换并找到下一个；Del或n，
  不替换，找到下一个；"."，替换并退出；"!"，替换剩下的全部，不要再问；
  "^"，回到上一个；回车或q，退出查询替换。
- M-x query-replace-regexp 交互式替换正则表达式。


# 10. 缓冲区、窗口和帧 #

## 缓冲区 ##

- C-x b    如果输入一个新的文件名则新建一个文件并且编辑,否则打开该文件
- C-x C-left    上一个缓冲区
- C-x C-right    下一个缓冲区

- C-x C-b   可以得到一个buffer列表，下面是列表的一些快捷键：
  + 空格或n，下一个buffer
  + p，上一个buffer
  + 1，全屏打开当前buffer
  + d或k，做删除的标记
  + x，执行标记的命令，比如有几个buffer标记了删除，x则删除这几个buffer。

- C-x s    保存全部缓冲区
- C-x k    删除缓冲区
- M-x kill-some-buffers 对每个缓冲区询问是否关闭
- M-x rename-buffer 重命名当前缓冲区
- C-x C-q    Toggle当前缓冲区的只读属性

## 窗口 ##

- C-x 0    删除当前所在的窗口
- C-x 4 0  将缓冲区和窗口一起删除
- C-x 4 f  在别的窗口打开文件
- C-x 4 b  切换其它窗口中的缓冲区
- C-x 1    当前缓冲区满屏显示（常用的按键）, 或者按Esc Esc Esc关
  闭其它窗口.
- C-x 2    创建上下排列的窗口
- C-x 3    创建左右排列的窗口
- C-x o    在窗口之间移动
- C-x ^    将窗口增高一行，也可以用M-x enlarge-window
- C-u n C-x ^   将窗口增高n行
- M-- C-x ^  将窗口垂直收缩一行，也可以用M-x shrink-window
- C-x }   将当前窗口增宽一列，也可以用M-x enlarge-window-horizontally
- C-x {   将当前窗口水平减一列，也可用M-x shrink-window-horizontally
- ESC C-v或C-M-v 滚动其它窗口的内容。你也可以用M-PgDn和M-PgUp滚动
  其它窗口内容。

## 帧 (frame) ##

一个frame就是一个Emacs窗口，这个窗口是被窗口管理器管理的窗口，
有自己的菜单栏，工具栏的。

- C-x 5 0       删除当前的frame
- C-x 5 1       删除其它的frame
- C-x 5 b       在其它的frame中打开缓冲区
- C-x 5 f       在其它的frame中打开文件

## MiniBuffer ##

- 按 RET 会退出MiniBuffer, _要想输入换行符, 可以输入 C-o 或 C-q C-j_.
- 默认情况下, 在 MiniBuffer 中输入 <TAB>, <SPACE>, <?> 都会补全,
  要想输入这些字符, 可以用C-q.
- 当你在MiniBuffer中输入命令或参数时, 可能要在另一个窗口中弹出候选
  项,当候选项多时, 你可以用 C-M-v 来滚动补全的内容, 或者用
  M-<PageUp> 和 M-<PageDown>来上下滚动帮助内容.
  似乎连续地按Tab键也可以让帮助内容向下滚动。
- 在 MiniBuffer 输入过的东西会记录在 Minibuffer history list中,
  =M-p= 和 <UP> 是上一个项目, =M-n= 和<Down> 是下一个项目, =M-r
  REGEXP <RET>= 向前搜索符合正则表达式的项目, =M-s REGEXP <RET>=
  向后搜索符合正则表达式的项目.
- minibuffer history list分为几个: 文件名, 缓冲区名, 命令参数,
  Emacs命令, 编译命令...
- *C-x <ESC> <ESC>* 重新执行最近的一个命令.
- M-x list-command-history 会显示minibuffer的命令历史, 最近使用的排在最先.
- 当在minibuffer中输入密码时, C-u: delete all; <RET> 或 <ESC>: submit.

# 11. 编辑 #

## 一些方便的按键 ##

- M-m    移动光标到当前行的第一个非空字符
- ESC ^    将这一行与上一行合并
- M-SPC    删除连续的空格，只保留一个
- M-\\     删除连续的空格, =C-u M-\\= 只删除 point 前面的空白字符.
- M-(      输入 =()=
- Esc, Tab (M-Tab)     用字典补全输入。
- 插入/覆盖模式切换：M-x overwrite-mode是用来转换 insert mode
  与 overwrite mode ，按Insert键可以实现同样的功能。
- C-i 相当于TAB，M-i 输入制表符。
- C-m 相当于RET；C-o在光标后重开一行，但光标保持不动。
- C-j 换行并根据当前模式缩进。M-j 重开一行并保持缩进，如果当前行是注
  释，下一行也是注释。
- C-o 在光标后插入一个空白行。
- C-x C-o 删除多个连续的空行。
- list-matching-lines: 列出符合给定模式的行(对整个文件).
- delete-matching-lines: 删除符合模式的行. (如果有region, 作用于
  region, 否则作用于光标到文件末尾)
- delete-non-matching-lines: 与 delete-matching-lines 类似.

## 输入特殊符号 ##

- C-q: (1) C-q后按特殊按键 如按TAB输入制表符；按回车(或C-m)输入回
  车符, 等等. (2) C-q后可以跟ascII码, 如 =C-q 7 7 b= 会输入 =?b=.
- C-q C-m 会输入 ^M, C-q C-j 会输入换行符。
- C-x 8 可以插入一些特殊符号。

  - C-x 8 "a ä
  - C-x 8 "A Ä
  - C-x 8 ~D Ð
  - C-x 8 /e æ
  - C-x 8 /E Æ
  - C-x 8 ,c ç
  - C-x 8 ,C Ç
  - C-x 8 /o ø
  - C-x 8 "o ö
  - C-x 8 "s ß
  - C-x 8 ~t þ

## 在多个位置间跳转 ##

以前的marker存在mark ring中，所以可以用C-@ 或C-SPC在多个位置做标
记，然后用C-u C-@ 或C-u C-SPC在当前缓冲区内跳转。用C-x C-@ 或C-x
C-SPC在全局的标记位置内跳转。

## 矩形区域操作 ##

在矩形的左上角进行标记，然后将光标移动到矩形的右下角，
就可以进行矩形操作了。

- C-x r d: delete-rectangle, 删除矩形区域的文字
- C-x r k: kill-rectangle, 删除矩形区域，并把它放入kill-ring
- C-x r y: yank-rectangle, 粘贴最后剪切的矩形区域
- C-x r o: open-rectangle, 将选定的rectangle用空格填充, 将已有的文本右移.
- C-x r c: clear-rectangle, 将矩形区域内的文本用空格替换.
- C-x r t STRING: 将矩形区域的每行用给定的字符串替换.
- M-x string-insert-rectangle <RET> STRING: 用字符串填充矩形区域,
  原有文本右移.
- C-x r r R: 将矩形区域的内容存储在寄存器R中. 可以再用C-x r i R取回.
- 进行矩形区域操作时打开CUA (common user access) mode会方便许多.
  在CUA模式下, C-x 剪切, C-c复制, C-v粘贴, 如果选中了Region, 你输
  入内容会删除Region. 如果你不想原来的Emacs键绑定产生干扰. 你可以
  (setq cua-enable-cua-keys nil). 或者你可以按住shift来调用C-x, 如
  果你想C-x C-f, 你要输入 S-C-x C-f, 或者你可以多按一次C-x, 如C-x
  C-x C-f. 要启用CUA模式, M-x cua-mode <RET>.

## 文本位置交换 ##

- C-t     交换光标所在字符与前一个字符的位置
- M-t     交换光标前后两个单词的位置
- C-x C-t    交换两个文本行的位置
- 按下M-x后在辅助输入区中输入"transpose-sentences"交换两个句子的位置，
  按下"transpose-paragraph"交换两个段落的位置

## 改变字母大小写 ##

- M-c     单词首字母改为大写
- M-u     单词的字母全部改为大写
- M-l     单词的字母全部改为小写
- C-x C-l（downcase-region）使标记的区域变成小写
- C-x C-u（upcase-region）使标记的区域变成大写
- M-x upcase-initials-region, 选定区域首字母大写.

## 撤销与重做 ##

- 撤销操作 (undo）：C-x u或C-_或C-/。
- 重做。GNU Emacs本身没有Redo，不过可以借助undo undoes来实现。
  在做了一系列undo后，只要让光标离开原来的位置，再执行undo的动作，
  就会Redo。
- 撤销上次保存后的所有操作：M-x revert-buffer RET。

## 简单排版 ##

- 如果想启用自动断行，M-x auto-fill-mode。
- M-s  让一行居中 (M-x center-line)
- M-S  让一段居中 (M-x center-paragraph)
- M-x center-region    让一个区域居中
- M-q (M-x fill-paragraph)  让一段自动断行
- M-x fill-region           让选中的区域自动断行
- 统计字数：C-x h选中整个缓冲区。M-\|会让你输入shell命令，
  输入wc -w 统计单词数，输入 wc -m 可以统计字符数。
- 统计中文字数：M-x count-words，会告诉你行数和字符数。不管使用什
  么编码，每个汉字算是一个字符，所以字符数减去行数，就大致是汉字的
  字数。比实际的汉字数要多，因为文中可能包含空格和英文字符。

## 宏 ##

- C-x ( 开始宏，也可以按 F3 。
- C-x ) 结束宏，也可以按 F4 。
- C-x e 执行宏。

## 重复操作 ##

- C-num 可以重复执行一条命令，比如C-9 \*可以连续插入9个星号。
  M-num可以达到相同的目的. 即使数值参数超过9, 这种方式也可以工作.
  如按住Meta时按下5, 放开meta再按6, 再输入其它命令, 则会重复56次.
- 也可以用C-u num来辅助，如用C-u 20 \*插入20个星号。
  如撤销10次操作：C-u 10 C-x u。
- 如果C-u后面不加数值参数，则默认的数值参数是4。C-u C-u C-n 会向下移动16行.
  但是要输入重复的数字，就需要用C-u来间隔重复的次数和要重复的数字，
  例如：要输入20个5，C-u 20 C-u 5。
- 有一个例外是，C-u 3 C-v不是翻3页，而是整个屏幕上移三行。
- C-x z重复上一次操作, 如果想重复一次以上, 就继续按z.


## abbrev ##

1. =C-x a g= add-global-abbrev, 输入一个单词后，按C-x a g, 然后输入这个单词的缩写，再回车。
2. =C-x a -= or =C-x a i g=, inverse-add-global-abbrev, 输入一个缩写，按这个序列，再输入完整的单词。
3. =C-x a += or =C-x a C-a=, add-mode-abbrev, 为当前模式加入缩写。
4. =C-x a i l= inverse-add-mode-abbrev, 反向（先写缩写，再写完整的）为当前模式加入缩写。
5. "C-x a '" or "C-x a e" 扩展缩写。
6. =C-x a n=, expand-jump-to-next-slot; =C-x a p=, expand-jump-to-previous-slot.

# 12. 书签 #

书签可以看成一种特殊的寄存器, 和寄存器的区别在于寄存器的名字是单个
字符, 而书签名可以是多个字符.

- C-x r m BOOKMARK <RET> 在光标当前位置设置一个书签, 如果直接回车,
  会使用缓冲区的名字做书签名.
- C-x r b BOOKMARK <RET>  跳到指定的书签
- M-x bookmark-rename   重命名书签
- M-x bookmark-delete   删除书签
- M-x bookmark-insert-location: 插入BOOKMARK指向的文件名.
- M-x bookmark-insert <RET> BOOKMARK <RET>: 插入BOOKMARK指向文件的内容.

- M-x bookmark-save 用该命令, 可以随时保存书签列表, Emacs在退出时
  也会自动保存默认的书签列表, 存储在 ``~/.emacs.bmk``. 如果你想每
  次新建书签都保存书签列表, `(setq bookmark-save-flag 1)`.
- M-x bookmark-write    保存书签列表到特定的文件
- M-x bookmark-load     从特定的文件读取书签列表

- C-x r l   打开书签列表，下面是书签列表的一些快捷键：

  - f: 显示光标所在的书签
  - t: 是否显示和书签关联的文件路径
  - q: 退出书签列表
  - m: 标记在其它的窗口显示
  - v: 显示被标记的书签，如果没有标记的书签，就显示光标所在的书签
  - d: 做删除的标记
  - x: 删除被标记删除的书签
  - u: 移除标记


# 13. 使用在线帮助 #

- C-h t   运行Emacs教程。
- C-h C-f 查看Emacs FAQ.
- C-h [C-n, n] 查看最近版本的新特性.
- C-h C-p 查看已知的问题.
- C-h p 可以查看Emacs中包含了哪些包.
- C-h C-c, describe-copying, 查看GPL许可证。

- C-h c   describe-key-briefly, 查看某个键序列对应的命令。
- C-h k   比C-h c更详细。查看某个键序列对应的命令及做了什么。
  像是C-h c和C-h f的结合。还可以查看某个菜单项对应的命令。
- C-h K 显示按键序列对应的手册. 注意: C-h c, C-h k 和 C-h K的参数
  可以是按键序列, 也可以是菜单项或鼠标动作.

- C-h f 描述一个函数（或命令）做了什么。如果你使用Emacs23或更新的版本，你可
  以用*进行模糊查找。比如 ~C-h f *buffer TAB~, 就会得到所有以buffer结尾的函数列
  表。
- C-h F   打开对应命令的手册. command = interactive function.

- C-h b   describe-bindings, 显示所有活跃的键绑定.
- C-h w   查看对应某个命令的键绑定是什么。对应的是 where-is 命令。
- C-h d   查看匹配给定模式的关于变量和命令的文档.
- C-h v   查看某个变量的含义和它的值。
- C-h e   显示 \*Messages\* buffer.
- C-h m   描述当前的模式。
- C-h l 查看我最后敲的100个字符是什么。等同于 M-x view-lossage,最
  后键入的100个键盘输入称为 Lossage。有什么实际用途呢？
- C-h C-h 如果你记不住前面那么多的C-h没有关系，记住C-h C-h就可以
  了。

- C-h a apropos-command, 查看哪些命令包含了某个子字符串。参数可以
  是单个关键字, 关键字列表 和 正则表达式.
- C-u C-h a, show apropos commands or functions.
  When looking for command by apropos-command, you can call it with 【Ctrl+u】 first.
  It'll then also list functions.
- M-x apropos 查看哪些命令或变量包含了某个子串。默认不显示与命令对
  应的按键, C-u M-x apropos会显示对应的按键(如果有绑定按键的话).
- M-x apropos-variable 列出用户可以定制的变量, 如果用C-u 做前缀,
  列出所有匹配的变量.
- M-x apropos-value 列出附和条件的变量值。
- M-x apropos-documentation 搜索文档字符串匹配模式的命令和变量.

- M-x elisp-index-search 在elisp手册中寻找函数的文档
- M-x emacs-index-search 在emacs手册中寻找函数的文档

- C-h r   在Info中显示Emacs Manual.
- 如果你在编辑程序，你可以按C-h S (info-lookup-symbol)在对应的手册
  中找到光标下符号的入口，前提是你有Info版的手册。
- C-h i 或者M-x info查看帮助info。
  运行 C-h i 指令，会先进入 info 树状结构的根部 (/usr/share/info)。
  任何情况下， 可键入 =d= 回到此根部.

  - 空格键和退格键，分别向下和向上滚动当前节点，并自动地跳到下一个和上一个节点。
    当向下滚动遇到菜单时，会跳转到菜单引用的第一个节点。
  - h 介绍如何使用 info.
  - m MenuName 直接移动到指定的Menu上, 如m Emacs <RET>会跳转到Emacs的Info.
  - n 将结点移至下一个与此结点相连的结点。
  - p 将结点移至上一个与此结点相连的结点。
  - u 将结点移至上一层的结点。
  - t 移动到当前节点的top节点。
  - > 移动到当前文档指向的最后一个节点。
  - l 移动到之前访问的最后一个节点。
  - i <keyword> <RET>, 调用info-index命令，搜索索引中包含给定关键字的节点。
    会在当前Info节点中搜索keyword, 按 ',' 到下一个匹配处.
  - s <keyword> <RET> 搜索手册, 可以输入正则表达式.
  - q 隐藏 Info 的缓冲区，可以按 C-x b 返回 Info.
    若想真正关闭 Info，就像关闭一个普通缓冲区一样，C-x k <RET>
  - Tab 将光标移动到下一个交叉引用处，M-Tab则移动到上一个交叉引用处。

- C-h在后面输入，也很有用，比如：要看以C-c为前缀的有哪些键绑定，可
  以按C-c C-h。常用的命令都以C-x为前缀，而和模式有关的按键一般以
  C-c为前缀。再如：要看以C-x r为前缀的有哪些命令，可以按C-x r C-h。

- C-x = what-cursor-position 显示光标所在字符信息。
- M-x describe-char, 描述光标下的字符。
- M-x describe-font 描述光标下的字体信息。
- M-=, count-lines-region, 统计被选中的行数和字符数, 汉字算一个字符.
- M-x what-line, 显示光标所在的当前行数.
- M-x what-page, 显示光标在多少页多少行.
- C-x l, count-lines-page, 统计当前页多少行.

`C-h` 相当于 `<F1>`, 可以跟在前缀按键后查看前缀按键都有哪些命令,
有时C-h和前缀按键一起绑定到特定的命令, 但`<F1>`总是有效的. 如 C-x v
`<F1>` 可以查看所有以 C-x v为前缀的键绑定对应的命令.

# 14. 一些模式的帮助 #

C-h m 列出目前的mode的特殊说明。

## TEXT MODE ##

- M-Tab 单词的拼写补全
- M-S   段落居中
- M-s   本行居中

## HTML MODE ##

- C-c C-v  在浏览器中查看正在编辑的网页。
- C-c C-s (M-x html-autoview-mode) 在保存文档时自动打开浏览器显示
  文档。
- C-c 1   插入1级标题。
- C-c 2   插入2级标题。
- C-c 3   插入3级标题。
- C-c 4   插入4级标题。
- C-c 5   插入5级标题。
- C-c 6   插入6级标题。
- C-c C-j  插入回车的标记。
- C-c RET  插入新的段落。
- C-c C-c -   插入分割线。
- C-c C-c h   插入链接标记。
- C-c C-c n   插入锚点。
- C-c C-c i   插入图片标记。
- C-c C-c o   插入排序列表。
- C-c C-c u   插入无序列表。
- C-c C-c l   插入列表项。
- C-c C-f     向前跳过同一级tag。
- C-c C-b     向后跳过同一级tag。
- C-c C-t     会提示你输入标签，如果你输入html，就会生成html文档的模板。
  如果你输入别的标签，Emacs都会智能的补全。这是个非常有用的绑定。
- C-c /       闭合未闭合的标签，这个功能也很棒。
- C-c Tab     隐藏和显示标签。
- 将光标移动到标签上，按C-c ?可以查看标签的简单含义。
- C-c C-n     用于输入特殊字符，指被html标签占用的字符，如：
  C-c C-n SPC会输入 ``&nbsp;`` ，C-c C-n < 会输入 ``&lt;`` 。
- C-c DEL     删除光标所在的标签，包括与之配对的标签。

## Outline模式 ##

- C-c C-n  移动到下一个可见的标题
- C-c C-p  移动到上一个可见的标题
- C-c C-f  移动到下一个同级标题
- C-c C-b  移动到上一个同级标题
- C-c C-u  移动到上一级
- C-c C-t  收起正文
- C-c C-d  收起子标题
- M-x hide-entry   收起指定标题的正文
- C-c C-a  显示所有

## Tex模式 ##

- M-x plain-tex-mode 进入plain-Tex模式
- M-x latex-mode     进入latex模式
- M-x validate-tex-buffer   检查缓冲区内容是否符合Tex语法。
- C-c C-f            保存并编译当前文件。
- C-c C-v            预览编译结果(dvi文件)。
- C-c TAB            bibtex
- C-j                插入两个硬回车，即Tex中的分段，并检查段落的语法
- C-c {              插入{}，并将光标置于其中间。
- C-c }              如果光标在{}之间，将光标定位到\}。
- C-c C-e            对于latex中的\\begin{x}，自动补全\\end{x}。
- C-c C-o            插入\\begin{。
- M-RET              插入\\item。

## rst模式 ##

*reStructuredText* 是我常用的文档格式。

- C-c C-t            显示文档目录。
- C-t C-u            更新文档目录。
- C-c C-n            下一节。
- C-c C-p            上一节。
- C-c RET            标记当前节。
- C-c 1              编译当前rst为html文档。
- C-c C-b            把当前域转换为无序列表。
- C-c C-e            把当前域转换为有序列表。
- C-c C-v            把无序列表转换为有序列表。
- C-c C-d            把当前域转换为line block。
- C-c C-l            把当前域左移。
- C-c C-r            把当前域右移。

## narrow模式 ##

- C-x n n narrow模式：让你聚焦于选中的区域，隐藏其他的文本。
- C-x n w 从narrow模式恢复。

## Follow模式 ##

两个窗口显示同一个缓冲区时，可以设置follow mode (M-x follow-mode)，
滚动一个窗口时，另一个窗口会跟着滚动。

两个窗口显示的内容是连续的，如果你的光标移出了一个窗口的范围，
它会出现在另一个窗口里。不清楚这个模式有什么作用。


# 15. 编程 #

## 一些编程模式下通用按键 ##

### 快速移动 ###

- C-M-a (M-x beginning-of-defun) 到当前或上一个函数定义的开始处。
- C-M-e (M-x end-of-defun) 到当前或下一个函数定义的开始处。
- C-M-h (M-x mark-defun) 选中当前或下一个函数。
- C-M-u (M-x backward-list) 到当前程序块的开始
- C-M-n (M-x forward-list) 到下一个程序块的开始，或是当前程序块的结束。
- C-M-f 向前匹配括号；C-M-b 向后匹配括号。

### 缩进 ###

- ESC C-\\ 选中区域的每行都缩进。 (M-x indent-region)
- C-M-\\: indent-region
- C-c C-q: 缩进当前函数。
- `C-c . <RET> STYLE <RET>' Select a predefined style STYLE (`c-set-style').

### 注释 ###

- =ESC ;= 或 =M-;=    在当前行右边注释。如果选中区域，则注释/反注释选中的区域。
- M-x uncomment-region  取消选中区域的注释

- M-x hs-minor-mode     打开折叠模式，然后可以使用hs-show-block,
  hide-hide-block, hs-show-all, hs-hide-all等命令

## CC-Mode ##

- C-c C-a或M-x c-toggle-auto RET，打开或关闭C模式的自动状态（输入
  分号自动换行并缩进）。
- M-x ff-find-other-file 打开和源文件对应的头文件，或者相反。


针对条件编译指令的快捷键(c-mode && c++-mode):

- C-c C-u: c-up-conditional, 回到 ~#if~ 的开始处
- C-c C-n: c-forward-conditional, 移动光标到当前或下一个 条件编译 的结束处。
- C-c C-p: c-backward-conditional, 移动光标到当前或上一个 条件编译 的开始处。
- M-x hide-ifdef-mode, 然后你可以按 C-c @ C-d 隐藏 ifdef block，按 C-c @
  C-s 显示隐藏的 ifdef block. 你还可以用 C-c @ d 指定要 ifdef block 是关于哪
  个宏的，然后你可以用 C-c @ h 和 C-c @ s 来隐藏和显示关于这个宏的 ifdef
  block. 你可以按 C-c @ u 取消已指定的宏。

## 编译 ##

- M-x compile：编译。
- C-x `：到下一个出错的地方。

## 使用GDB ##

- M-x gdb：启动GDB
- C-h m: 描述GDB模式
- M-n：下一行
- M-s：下一行，遇到函数则进入
- C-c C-f：执行完当前函数
- M-c：继续执行
- C-x SPC：设置断点。

## Etags ##

- 建立tag表。M-x cd RET切换默认目录到程序目录，
  用M-!etags \*.[ch]建立tag表。
- M-.	find tags
- M-\*   返回
- 如果要查看一个函数的定义，将光标在函数名上，
  M-. RET就搞定了。
- 如果emacs找错了，你可以用C-u M-. 找下一个。

## global ##

用emacs + global阅读代码方便得很。
global相当于ctags + cscope。

+ 在工程目录运行 =gtags= 生成TAG文件
+ 在emacs中 =M-x gtags-mode=
+ 然后 =M-x gtags-visit-rootdir=
+ 就可以使用 =M-.= 定位tag，使用 =M-*= 返回
+ 而且可以通过 =M-x gtags-find-rtag= 定位tag被访问的位置

## Python模式 ##

- M-TAB   符号补全
- C-c C-c 运行当前缓冲区中的python代码
- C-c C-z 切换到Python解释器
- C-c C-k 标记光标所在的代码块
- C-c C-u 找到代码块的开始
- C-c C-f 如果你安装了pythonDoc，可以程序中某个符号的帮助文档。
- C-M-a   移动到一个函数或类定义的开始，你可以按ESC C-a来得到这个按键
  序列。
- C-M-e   移动到一个函数或类定义的结束。
- Python代码的 *折叠显示* 。C-u 4 C-x $ ，只显示缩进级别小于4的
  行；C-u 8 C-x $ ，只显示缩进级别小于8的行； C-x $ ，显示所有行。

## Grep ##

如果不想记住复杂的grep参数，可以使用 =M-x rgrep= (递归子目录), =M-x lgrep= (只搜索当前目录)

# 16. 会话管理 #

Emacs 23已经集成了desktop包，在退出emacs时，我们可以使用 `M-x desktop-save` 在选定的目录下生成 `.emacs.desktop` ，保存一些会话信息。

在保存有 `.emacs.desktop` 的目录下，启动emacs，然后 `M-x desktop-read` 恢复会话。

你可以在多个目录下保存 `.emacs.desktop` ，然后用 `M-x desktop-change-dir` 加载新的会话。现在不确定在加载新的会话前会不会保存当前会话。

可以用 `M-x desktop-clear` 清空当前会话。


# 17. 编码 #

- Emacs22和Emacs21一样，通过mule能支持gb2312和utf-8编码，  但不支持gbk和gb18030。
- Emacs23进行一番大改动，内置unicode，支持gb2312, gbk, gb18030。也就是说能完美的支持中文。而且可以使用xft字体了！
  对中文用户来讲，Emacs23将是比较完美的一个版本。
- 转换文件编码，比如想把gb2312编码的文件转换为utf-8编码，C-x C-m f，会让你选择编码系统，我们选utf-8-unix，回车。则转换完成，别忘了保存。注意：C-m = RET
- 如果想转换编码后，将文件另存。C-x C-m c，会让你选择编码系统，
  然后让你输入命令序列，输入C-x C-w，输入另存的文件名，回车。
- C-x C-m k，改变键盘输入的编码系统。
- C-x C-m l，设定当前的语言环境。
- C-x C-m p, 设定进程输入输出的编码系统。
- C-x C-m r，设定打开文件的编码系统，当你打开文件乱码的时候可以试试这
  个。
- C-x C-m t，设定终端显示的编码系统。
- C-x C-m x，设定X选中文本的编码系统。

# 18. Faces #

- M-x set-face-foreground
- M-x set-face-background
- M-x list-faces-display, 显示当前frame的所有face. C-u M-x
  list-faces-display, 会提示你输入一个正则表达式，只会列出匹配这个
  表达式的face.
- M-x highlight-phrase (C-x w p): 用指定的颜色高亮给定的字符串.

# 19. Emacs的其它用途 #

## 在Emacs中使用shell ##

- M-! 可以执行外部命令。 C-u M-! 会将shell命令的输出结果插入到当前缓冲区中。
- M-x shell  启动shell。
- C-u M-x shell 可以打开新的shell。
- 在Emacs中使用shell的好处是你可以全屏编辑，一个最酷的例子是：
  如果你想把以前执行过的长命令修改一下再执行，
  你可以C-r向后递增查找到这个长命令，然后编辑修改，
  然后，最神奇的地方，你在这条命令上按回车，这条修改过的命令就执行了。
- 如果你想在emacs中启动多个shell可能会疑惑，
  因为你使用两次M-x shell也只有一个shell。
  你需要将第一个shell所在的缓冲区重命名才能启动新的shell。
  还记得吗？重命名用M-x rename-buffer。看来这个命令还是有些用的。
- 这并不是一个功能完整的shell，如果你想在emacs中用功能完整的shell，用
  M-x term 。
- 你可以将shell中的输出或者命令提示符向普通文本一样地删除。
  也可以用C-c C-o清理刚才的输出。
- C-c C-u 相当于C-u。M-p 上一条命令; M-n 下一条命令。

## 用Dired做文件管理器 ##

- C-x d		打开 Dired ，进入某个目录
- i         在当前缓冲区打开子目录
- $         折叠光标所在目录
- ^         进入上一级目录
- a         在当前缓冲区进入新的目录
- e         在当前窗口打开文件
- o         在另一个窗口打开文件
- j         跳到当前目录中指定的文件
- <         跳到上一个子目录
- \>         跳到下一个子目录

功能很多，还是看 *菜单* 和 *帮助* 吧。

## 打开系统文件 ##

要在普通用户的emacs会话中打开系统文件, 需要 TRAMP 的辅助.
TRAMP = Transparent Remote Access Multiple Protocols,
即支持多种协议的远程访问.

打开远程文件的方法为: `C-x C-f /protocol:user@machine:file`,
protocol 可以是ftp, ssh等. 要打开本地的系统文件, 比如
`/etc/php/php.ini/`, 当前用户名 `john`, 主机名 `ArchLinux`, 有两种
方法:

- `C-x C-f /su::/etc/php/php.ini`, 相当于
  `/su:root@ArchLinux:/etc/php/php.ini`, 要输入 root的密码.
- `C-x C-f /sudo::/etc/php/php.ini`, 相当于
  `/sudo:root@ArchLinux:/etc/php/php.ini`, 要输入john的密码.

## 其它 ##

- 在emacs中查看手册，M-x man。如果要查看带颜色的手册，M-x woman。
  man依赖于Unix/Linux系统的man，而woman是完全用elisp实现的。
- M-x list-colors-display 可以查看emacs使用的顏色。
- M-x calc 打開emacs自帶的計算器。
- C-x l: 可以显示缓冲区共有多少行，光标前有多少行，光标后有多少行。

# 20. Vim_ 功能的模拟 #

- gf：ffap (find file at point)或ffap-other-window。可以做一个键绑定：
  `(global-set-key (kbd "C-c g f") 'ffap-other-window)`
