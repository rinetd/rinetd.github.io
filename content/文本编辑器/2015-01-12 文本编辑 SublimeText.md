---
title: 文本编辑 Sublime Text 3
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [Sublime]
---
快捷键
ctrl+p                  文件切换
ctrl+shift+p            系统函数
ctrl+shift+R            转到项目中的符号
ctrl+r  =   ctrl+p @    快速跳转到文件中的某个函数处
ctrl+g  =   ctrl+p :    跳转到指定行
ctrl+;  =   ctrl+p #    在当前文件中快速搜索内容
Alt+O可以实现头文件和源文件之间的快速切换
Ctrl+Shift+T        恢复刚刚关闭的标签
注释：
ctrl+/                  单行注释 及取消注释
ctrl+shift+/            区块注释

删除
Ctrl+KK：                从光标处删除至行尾
Ctrl+Shift+K            删除光标所在行
Ctrl+X                  删除当前行

复制
Ctrl+Shift+D            复制光标所在行
ctrl+shift+↑↓   光标定位到某一行-》上下移动一行
ctrl+shift+↑↓ 选中之后-》上下移动选中区域。

Ctrl+KU     改为大写
Ctrl+KL     改为小写
Alt+.       闭合当前标签
Ctrl+Shift+[    折叠代码
Ctrl+Shift+]    展开代码
Ctrl+KJ     展开全部代码
Ctrl+K1     折叠代码等级

选择
ctrl+l  继续选择下一行
ctrl+d  选择整个单词,继续按向下查找

ctrl+shift+l        [打散行](http://upload-images.jianshu.io/upload_images/207604-1f31e27eae6e4087.gif?imageMogr2/auto-orient/strip)
ctrl+J              [合并行](http://upload-images.jianshu.io/upload_images/207604-239fe134ffa973ef.gif?imageMogr2/auto-orient/strip)

Ctrl+M              切换匹配brackets标签
Ctrl+Shift+J        选择匹配的indentation标签的内容
ctrl+shift+space    选择scope 标签的内容 " " [ ] { } ()
ctrl+shift+M        选择brackets标签的内容 " " [ ] { } ()

Ctrl + Enter        在当前行下面新增一行然后跳至该行
Ctrl + Shift + Enter在当前行上面增加一行并跳至该行。
列选择模式
    1.鼠标右键+shift
    2.Ctlr+Shift+上下箭头

{ "keys": ["alt+d"], "command": "goto_definition" },
{ "keys": ["alt+-"], "command": "jump_back" },
{ "keys": ["alt+="], "command": "jump_forward" },

退出
ctrl+shift+w            迅速退出

## 安装Sublime Text 3

sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text

—– BEGIN LICENSE —–
Michael Barnes
Single User License
EA7E-821385
8A353C41 872A0D5C DF9B2950 AFF6F667
C458EA6D 8EA3C286 98D1D650 131A97AB
AA919AEC EF20E143 B361B1E7 4C8B7F04
B085E65E 2F5F5360 8489D422 FB8FC1AA
93F6323C FD7F7544 3F39C318 D95E6480
FCCC7561 8A4A1741 68FA4223 ADCEDE07
200C25BE DBBC4855 C4CFB774 C5EC138C
0FEC1CEF D9DCECEC D3A5DAD1 01316C36
—— END LICENSE ——

## 为Package Control设置代理

import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)

Preferences->Package Settings->Package Control ->( Settings - Default | Settings - User)
Package Control.sublime-settings
{
    "http_proxy": "127.0.0.1:8087",
    "https_proxy": "127.0.0.1:8087",
    "installed_packages":
    [
        "ConvertToUTF8",
        "CTags",
        "Git",
        "MakeCommands",
        "MIPS Syntax",
        "SideBarEnhancements",
        "Vintageous"
    ]
}
## 快捷键优化
1.SublimeText自带格式化代码
该选项的路径：Edit - Line - Reindent（中文路径则是：编辑 - 行 - 再次缩进）

2.其实这个 key setting 就是用回车向右移动一格 不过有两个要求
第一个要求是说光标后的内容必须符合 "^[)\\]\\>\\'\\\"]" 这个 regex。
基本就是光标后为 ) ] > ' " 的时候。
注意是用的是following_text 还有 是 regex_contains
第二个要求是说光标前的内容必须不符合 `"^.*\\{$"` 这个 regex。
就是说光标的左边不能是 {
这次用的是 preceding_text 和 not_regex_match
所以说其实并没有跳出括号 只是向右移动罢了
Default (Windows).sublime-keymap
```
[
    //CodeFormat:Edit --> Line --> Reindent
    {"keys": ["ctrl+alt+a"], "command": "reindent" , "args":{"single_line": false}},
    //Auto Skip{[()]}
    {"keys": ["enter"], "command": "move", "args": {"by": "characters", "forward": true}, "context":
            [
                { "key": "following_text", "operator": "regex_contains", "operand": "^[)\\]\\>\\'\\\"\\ %>\\}\\;\\,]", "match_all": true },
                { "key": "preceding_text", "operator": "not_regex_match", "operand": "^.*\\{$", "match_all": true  },
                { "key": "auto_complete_visible", "operator": "equal", "operand": false }
            ]
        }
]
```
## 帮助菜单优化
Main.sublime-menu
```
[    {
        "id": "help",
        "children":
        [
            { "caption": "-" },
            { "command": "open_url", "args": {"url": "http://www.baidu.com"}, "caption": "Baidu" },
            { "command": "open_file", "args": {"file": "${packages}/../KEEPME"}, "caption": "KEEPME" },
        ]
    }
]
```
## 添加Java编译环境
Tools->build system->new build system
```
{
     "cmd": ["javac","-encoding","UTF-8","$file"],
     "file_regex": "^(...*?):([0-9]*):?([0-9]*)",
     "selector": "source.java",
     "encoding":"GBK",
     "variants":
    [
        {
            "name": "Run",
            "cmd" :  ["java", "$file_base_name"],
            "encoding":"GBK"
        }
    ]
}
```

## 系统配置
Preferences.sublime-settings
```
{
  "theme": "Spacegray Eighties.sublime-theme",
  "color_scheme": "Packages/Theme - Spacegray/base16-eighties.dark.tmTheme",
  "font_face":"DejaVu Sans Mono",
  // "font_face":"Droid Sans Mono",
  "font_size": 12.0,
  "rulers": [80],
  "tab_size": 4,
  "use_tab_stops": true,
  "translate_tabs_to_spaces": true,
  "highlight_line": true,
  "highlight_modified_tabs": true,// #设置文件修改时, 标签高亮提示
  "show_encoding": true, //在窗口右下角显示打开文件的编码
  "auto_match_enabled": false,    //禁用自动补全
  "always_show_minimap_viewport": true,
  "auto_find_in_selection": true,    //在选中范围内搜索
  "save_on_focus_lost": true,    //自动保存文件
  "match_brackets_square": true, // 突出显示圆括号
  "match_brackets_braces": true,  // 突出显示大括号
  "match_brackets_angle": true,// 是否突出显示尖括号
  "line_padding_top": 1,    // 设置每一行到顶部，以像素为单位的间距，效果相当于行距
  "line_padding_bottom": 1,    // 设置每一行到底部，以像素为单位的间距，效果相当于行距
  // 设置成true，当光标已经在第一行时，再Up则到行首，如果光标已经在最后一行，再Down则跳到行尾
  "move_to_limit_on_up_down": true,
  "trim_trailing_white_space_on_save": true,    // 保存文件时会删除每行结束后多余的空格
  "ensure_newline_at_eof_on_save": true,    // 为true时，保存文件时光标会在文件的最后添加空行
  "word_wrap": "auto",    //自动换行
  "draw_white_space": "all"    // 显示所有的缩进线
}
```

## VIM模式
    shift+enter  向下翻页
    zz  将当前光标所在的行居中显示
    v   选择一个字符
    u   撤销删除
    d   删除选中
    [n]dd   删除当前光标开始的连续n行
    x   删除当前光标所在的单个字符
    c   剪切字符
    p   粘贴字符
    r  －－－－－修改光标所在的字符
    S  －－－－－删除光标所在的列，并进入输入模式
    i   在当前字符的左边插入
    I   在当前行首插入
    a   在当前字符的右边插入
    A   在当前行尾插入
    o   在当前行下面插入一个新行
    O   在当前行上面插入一个新行
    yy  移动到行首
    0   移动到行首
    $   移动到行尾
    H   移动光标到屏幕上面
    M   移动光标到屏幕中间
    L   移动光标到屏幕下面
    {   跳到上一段的开头
    }   跳到下一段的的开头.
    (   移到段落开头
    )   移到段落结尾
    %   跳转括号匹配
    gg  跳转到文件首
    G   跳转到文件尾
    f   移动到指定字符
    [n]f    找第n个字符
    w   后移动一个单词，光标位于行首
    [n]w    向后移动n个单词，光标位于行首
    e   向后移动一个单词，光标位于行尾
    [n]e    向后移动n个单词，光标位于行尾
    b   前移动一个单词，光标位于行首
    [n]b    向前移动n个单词，光标位于行首

自动换行是每行超过 n 个字的时候 vim 自动加上换行符用
类似 :set textwidth=70 来设置 n
自动折行 是把长的一行用多行显示 , 不在文件里加换行符用
:set wrap 设置自动折行
:set nowrap 设置不自动折行
      :!ls  运行命令

1. Alignment
    选中文本并按ctrl + alt + a 就可以进行对齐操作

2.Change List
    在Ctrl+p 中使用
3.DocBlockr
    文档注视
    在函数前面/** Enter
4.HexViewer
    ctrl+shift+b","ctrl+shift+h 查看
5.Terminal
    ctrl+shift+t        在当前文件目录下打开终端
    ctrl+shift+alt+t    在当前工程目录下打开终端

7.SublimeAStyleFormatter    代码格式化
    ctrl+alt+F 全部格式化

9.Ctags     函数跳转

    跳到定义处使用”ctrl+t ctrl+t”，跳回来使用”ctrl+t ctrl+b”
        跳到定义处使用”ctrl+>”，跳回来使用”ctrl+<”

    列出当前函数 ALT+S

8.SublimeLinter             代码语法检查

    1.  默认采用cppcheck.exe    将cppcheck添加到环境变量中
    2.  cpplint.py 暂未调通。
    All under the beta mode:
    (Maybe there were something wrong with my operation before?)
    SublimeLinter: c enabled (using "D:\Program Files\Cppcheck\cppcheck.exe" for executable)
    (But it seems still some problem with cpplint,py?)
    Keyerror: u'c_cpplint'
    (But It works if I specify shell=True argument for the subprocess.Popen)
    SublimeLinter: c_cpplint enabled (using "d:\cpplint\cpplint.py" for executable)


10.sublimeclang 类似Ctags
    配置
      |alt+d,alt+d|Go to the parent reference of whatever is under the current cursor position|
      |alt+d,alt+i|Go to the implementation|
      |alt+d,alt+b|Go back to where you were before hitting alt+d,alt+d or alt+d,alt+i|
      |alt+d,alt+c|Clear the cache. Will force all files to be reparsed when needed|
      |alt+d,alt+w|Manually warm up the cache|
      |alt+d,alt+r|Manually reparse the current file|
      |alt+d,alt+t|Toggle whether Clang completion is enabled or not. Useful if the complete operation is slow and you only want to use it selectively|
      |alt+d,alt+p|Toggle the Clang output panel|
      |alt+d,alt+e|Go to next error or warning in the file|
      |alt+shift+d,alt+shift+e|Go to the previous error or warning in the file|
      |alt+d,alt+s|Run the Clang static analyzer on the current file|
      |alt+d,alt+o|Run the Clang static analyzer on the current project|
      |alt+d,alt+f|Toggle whether fast (but possibly inaccurate) completions are used or not|
    注:  仅支持UTF-8编码，不支持GBK
    1.  先保存sublime工程
    2.  将 MyProject 改为自己的工程名
    3.  Preferences->Package Setting ->SublimeClang -> setting user
{
    // 不显示提示窗
    "show_output_panel": false,
    // 不包括clang自身的头文件
    "dont_prepend_clang_includes": true,

    "additional_language_options":
    {
        "c++" :
        [
            "-std=c++11" // enable C++11
            // "-std=gnu++11"
        ],
        "c":
        [
            "-std=gnu11"
        ],
        "objc":
        [
            "-std=gnu11"
        ],
        "objc++":
        [
            "-std=gnu++11"
        ]
    },

    "options":
    [
        "-m32",
        "-w",
        "-ferror-limit=9",
        "-fgnu-runtime",
        "-fms-extensions",
        "-nostdinc",
        "-D__GNUC__=4",
        "-D__GNUC_MINOR__=2",
        "-D__GNUC_PATCHLEVEL__=1",
        "-D__GXX_ABI_VERSION__=1002",
        "-Di386=1",
        "-D__i386=1",
        "-D__i386__=1",
        "-DWIN32=1",
        "-D_WIN32=1",
        "-D__WIN32=1",
        "-D__WIN32__=1",
        "-DWINNT=1",
        "-D__WINNT=1",
        "-D__WINNT__=1",
        "-D_X86_=1",
        "-D__MSVCRT__=1",
        "-D__MINGW32__=1",
        "-D__STDC_VERSION__=201112L",
        "-Wno-deprecated-declarations",
        "-Wall",
        "-isystem", "/usr/include",
        "-isystem", "/usr/include/c++/*",
        // dev-Cpp
        "-isystem", "D:\\Program Files\\MingW\\lib\\gcc\\mingw32\\4.7.0\\include",
        "-isystem", "D:\\Program Files\\MingW\\lib\\gcc\\mingw32\\4.7.0\\include\\c++",
        "-isystem", "D:\\Program Files\\MingW\\lib\\gcc\\mingw32\\4.7.0\\include\\c++\\mingw32",
        // Cfree5
        "-isystem", "D:\\Program Files\\MingW\\lib\\gcc\\mingw32\\3.4.5\\include"
        "-isystem", "D:\\Program Files\\MingW\\include",
        "-I${folder:${project_path:Gateway.sublime-project}}/**"
    ]
}

    4.  如果是单独的项目，在项目文件中添加

        "settings":
        {
            "sublimeclang_options":
            [
                "-I/home/wyang/workspace/muduo",
                "-I/home/wyang/workspace/muduo/**"
            ]
        }
    5.  记得在build文件中添加--std=c++11使Build&Run功能生效
11.SublimeCodeIntel
        多种语言的代码提示功能
        打开 SublimeClang 的 user-setting 文件, 添加

        {
            "codeintel_config": {
                "Python": {
                    "env": {
                        "PYTHONPATH": "/usr/lib/python2.7/site-packages:/usr/lib/python:$PYTHONPATH"
                    }
                }
            }
        }
12.SublimeGDB
        gdb的一个插件，可以用来简单调试
        同上安装
        在项目文件中添加

        "settings":
        {
            "sublimegdb_commandline": "gdb --interpreter=mi ./contains",
            "sublimegdb_workingdir": "${folder:${project_path:contains.cc}}"
        }
        注意在build文件中加入-g（调试）选项

MarkdownEditing
14.TodoReview

{
    "patterns": {
        "TAG": "TAG[\\s]*?:+(?P<tag>.*)$",
        "TODO": "TODO[\\s]*?:+(?P<todo>.*)$",
        "NOTE": "NOTE[\\s]*?:+(?P<note>.*)$",
        "FIXME": "FIX ?ME[\\s]*?:+(?P<fixme>.*)$",
        "UPDATE": "UPDATE[\\s]*?:+(?P<update>.*)$",
        "CHANGED": "CHANGED[\\s]*?:+(?P<changed>.*)$"
    }
}

使用： //TODO:  注释
13.ConvertToUTF8

    解决乱码
    1.在 Sublime Text 里打开这个文件（状态栏应显示为 UTF-8）
    2. 选择菜单 File -> Save with Encoding -> Western (Windows 1252)
    3. 关闭再打开就正常了。

    对中文操作系统来说，Ansi就是gb2312或gbk.
    unicode是一种编码方式，和ascii是同一个概念，而UTF是一种存储方式（格式）
    编码指不同国家的语言在计算机中的一种存储和解释规范
    ANSI与ASCII
    最初，Internet上只有一种字符集——ANSI的ASCII字符集(American Standard Code for Information Interchange， “美国信息交换标准码），它使用7 bits来表示一个字符，总共表示128个字符，后来IBM公司在此基础上进行了扩展，用8bit来表示一个字符，总共可以表示256个字符，充分利用了一个字节所能表达的最大信息
    ANSI字符集：ASCII字符集，以及由此派生并兼容的字符集，如：GB2312，正式的名称为MBCS（Multi-Byte Chactacter System，多字节字符系统），通常也称为ANSI字符集。

    UNICODE与UTF8，UTF16

        由于每种语言都制定了自己的字符集，导致最后存在的各种字符集实在太多，在国际交流中要经常转换字符集非常不便。因此，产生了Unicode字符集，它固定使用16 bits（两个字节）来表示一个字符，共可以表示65536个字符
    标准的Unicode称为UTF-16(UTF:UCS Transformation Format )。后来为了双字节的Unicode能够在现存的处理单字节的系统上正确传输，出现了UTF-8，使用类似MBCS的方式对Unicode进行编码。(Unicode字符集有多种编码形式)
    例如“连通”两个字的Unicode标准编码UTF-16 (big endian）为：DE 8F 1A 90
    而其UTF-8编码为：E8 BF 9E E9 80 9A
        当一个软件打开一个文本时，它要做的第一件事是决定这个文本究竟是使用哪种字符集的哪种编码保存的。软件一般采用三种方式来决定文本的字符集和编码：
    检测文件头标识，提示用户选择，根据一定的规则猜测
    最标准的途径是检测文本最开头的几个字节，开头字节 Charset/encoding,如下表：
    EF BB BF UTF-8
    FE FF UTF-16/UCS-2, little endian
    FF FE UTF-16/UCS-2, big endian
    FF FE 00 00 UTF-32/UCS-4, little endian.
    00 00 FE FF UTF-32/UCS-4, big-endian.

    Windows下 新建文本文件
    ni好
    6E 69 Ba C3             ANSI    默认编码
    6e 69 e5 a5 bd          UTF-8   无Bom
    ef bb bf 6e 69 e5 a5 bd     UTF-8   标准
    fe ff 00 6e 00 69 59 7d     UCS-2   Big
    ff fe 6e 00 69 00 7d 59     UCS-2   Little


14.Theme - Soda 主题
spacegrayhttps://github.com/kkga/spacegray/
"Alignment",
"C++ Snippets",
"ConvertToUTF8",
"Cscope",   cscope -Rbq
"CTags",
"DocBlockr",
"GitGutter",
"Open-Include",
"Package Control",
"Search Stack Overflow",
"SideBarEnhancements",
"SideBarGit",
"Sublime Files",
"SublimeAStyleFormatter",
"TodoReview",
"Vintageous"
Theme - Centurion
Theme - Soda
Theme - Spacegray
