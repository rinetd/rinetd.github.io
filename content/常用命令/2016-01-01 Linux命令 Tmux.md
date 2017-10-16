---
title: Tmux 速成教程
date: 2016-01-12T15:30:01+08:00
update: 2016-09-27 17:18:56
categories: [linux_base]
tags: [Tmux]
---
[Tmux 速成教程](http://blog.jobbole.com/87584/)
[Tmux - Linux从业者必备利器](http://cenalulu.github.io/linux/tmux/)
tmux attach #恢复上次会话
ctrl +b : 进入命令模式
setw -g mode-mouse on 开启鼠标滚屏
set -g mouse on       # tmux > 2.1
###session 操作
- tmux new -s test 新建session，并命名为test
- tmux ls 列出所有session
- Ctrl+b d - (d)eattch 当前session
- tmux attach [-t sessionname]重新进入某session
- Ctrl+b $ - 重命名当前session

###window 操作
- Ctrl+b c - (c)reate 生成一个新的窗口
- Ctrl+b n - (n)ext 移动到下一个窗口
- Ctrl+b p - (p)revious 移动到前一个窗口.
- Ctrl+b w - 列出所有窗口编号,并进行选择切换.
- Ctrl+b & - 确认后关闭当前window tmux

###pane 操作
- Ctrl+b " - 将当前window水平划分
- Ctrl+b % - 将当前window垂直划分
- Ctrl+b 方向键 - 在各pane间切换
- Ctrl+b，并且不要松开Ctrl，方向键 - 调整窗格大小
- Ctrl+b x - 关闭当前pane
- Ctrl+b { 或} - 左右pane 交换
- Ctrl+b 空格键 - 采用下一个内置布局
- Ctrl+b q - 显示pane的编号
- Ctrl+b o - 跳到下一个pane

vim ~/.tmux.conf
unbind C-b
set -g prefix C-a

“ctrl-b [" 进入拷贝模式，使用空格键（space）开始内容选取，回车键（Enter）进行拷贝
"ctrl-b ]” 进行粘贴。
CTRL-b <光标键>  切换窗口
CTRL-b <C-光标键> 调整窗口大小


CRTL-b " 水平分割
CRTL-b % 竖直分割

CTRL-b <窗口号>
CTRL-b f
CTRL-b w
CTRL-b n（到达下一个窗口） CTRL-b p（到达上一个窗口）
CTRL-b & 退出  或者：exit

    $ tmux new -s new session
    $ top
然后输入CTRL-b d从此会话脱离，想要重新连接此会话，需输入：
    $ tmux attach-session -t session
