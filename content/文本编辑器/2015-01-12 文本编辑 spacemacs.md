---
title: 文本编辑 spacemacs
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [emacs]
---
[appleshan/my-spacemacs-config: My personal Spacemacs config](https://github.com/appleshan/my-spacemacs-config)
[dotspacemacs/.spacemacs at master · pandemie/dotspacemacs](https://github.com/pandemie/dotspacemacs/blob/master/.spacemacs)
安装 & 使用
sudo apt-get install emacs
$ git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

git clone https://github.com/syl20bnr/spacemacs.git ~/.emacs.d -b develop
git clone https://github.com/zilongshanren/spacemacs-private.git ~/.spacemacs.d/
如果使用了 .spacemacs.d 目录来保存你的 spacemacs 配置，就不需要在 HOME 目录维护一个 .spacemacs 文件了。 至于为什么要使用 .spacemacs.d 目录而不是 .spacemacs 文件，主要是方便分离自己的配置与 spacemacs 的配置，更新更容易。
如果发现添加在 .spacemacs.d/init.el 里面的配置没有生效，检查一下是否你的 HOME 目录还存在一个 .spacemacs 文件。
## 问题汇总

File error: Cannot open load file, No such file or directory, bind-map
解決方法：
bind-map spacemacs启动的时候下载的 选择 spacemacs-base 模式先把bind-map下载下来



# ELPA 镜像<http://elpa.emacs-china.org>
添加下面的代码到`.spacemacs`的`dotspacemacs/user-init()`
(setq configuration-layer--elpa-archives
    '(("melpa-cn" . "http://elpa.emacs-china.org/melpa/")
      ("org-cn"   . "http://elpa.emacs-china.org/org/")
      ("gnu-cn"   . "http://elpa.emacs-china.org/gnu/")))

## 使用代理
```elisp
(setq url-proxy-services
   '(("no_proxy" . "^\\(localhost\\|10.*\\)")
     ("http" . "127.0.0.1：8087")
     ("https" . "127.0.0.1:8087")))
```
## emacs 中怎么删除最大匹配的括号中的内容?
先把光标放置到最左边的括号处，然后C-M-K就可以

跳转总结：
同一层级
  ( 往前跳|往上跳 C-M-b backward-sexp
    往前跳|往上跳 C-M-p backward-list
上一级
  ( 往上跳 C-M-u  backward-up-list

##
优化删除括号的函数

这一期没啥内容，只是最近写代码的时候发现 Emacs 自带的删除括号功能 （'delete-pair）非常的原始且不好用，于是随手写了个优化的版本。
(defun c-delete-pair ()
  (interactive)
  (let ((re "[([{<'\"]"))
    (when (or (looking-at-p re) (re-search-backward re nil t))
      (save-excursion (forward-sexp) (delete-char -1))
      (delete-char 1))))
使用该函数可以向前搜索括号（以及引号）然后删除匹配的括号（或者引号）。


## 安装插件


## 约定
#+TITLE: Spacemacs Conventions


** Use-package
- Always use =progn= when a code block requires multiple lines for =:init= or
  =:config= keywords.
- If there is only one line of code then try to keep =:init= or =:config=
  keywords on the same line.
- Don't nest multiple =use-package= calls unless you have a very good reason
  to do it.

dwim  缩写（Do what I mean）。

## 调试技巧
(pp (macroexpand '(
  ;;pp 格式化输出，让输出更美观
  ;;macroexpand 宏展开
  )))
#小技巧：
<left>"  'evil-window-left
SPC SPC | M-x 进入命令模式
- M-n 自动输入当前所在的文本
- M-p 选择历史输入


## 插件
emacs-window-manager
emacs-neotree : neotree
avy(ace) : easymotion

popwin 光标自动跳转到新建的窗口中
web-mode: html 模版编辑扩展(项目地址)
js2-mode: javascript 编辑扩展(项目地址)
flycheck: 语法检查(项目地址)
smex: 命令输入自动补全(项目地址)
company-mode: 代码自动补全(项目地址)
magit: git 管理插件(项目地址)
markdown-mode: markdown 编辑扩展(项目地址)
web-beautify: js/css/html代码格式化(项目地址)
window-numbering: 编辑窗口分割(项目地址)
paredit 该插件用于括号/引号的自动补全. 如果担心evil mode破坏括号的完整, 编写时先暂停掉evil mode

install ag or rg
M-x package-install dumb-jump
跳转到定义 dumb-jump
代码折叠 hs-minor-mode
快速选定区域 expand-region
简化按键利器hydra
org-capture是orgmode的最新特性之一，它试图取代org-remember，成为快速记录的利器。
Prodigy可以让你在Emacs中直接管理外部服务, 方便快捷, 无需多次切换. 比如: Python Simple HTTP Server, Nodemon Server, Sinatra Server 或 Octopress Preview.
org-bullets org皮肤，更好看
## layer
SPC h l 查看layer帮助
SPC h R 在帮助文档org中搜索

## spacemacs  快捷键
, | SPC m major-mode
z
g

SPC h SPC | SPC h p 查看layer源码
SPC h k **查看顶层快捷键**
同上查看当前mode的快捷键  which-key-show-top-level

M-m | SPC   触发  
M-x | SPC ：命令行
M-g |       移动
M-s |       搜索
C-w | SPC w 窗口相关
C-x |       系统功能
C-c |       命令模式 [major mode]
C-g |       取消命令

C-h |       帮助

ctrl+z      切换 evil 和 emacs模式
SPC s j  dird-jump
:hint-is-doc t
:dynamic-hint(spacemacs//layouts-ts-hint)

### 快速切换窗口
alt+1 .. 0
SPC 1 .. 0
SPC w m: 最大化或者最小化当前窗口
SPC w s | SPC w - 水平分割窗口
SPC w v | SPC w / 垂直分割窗口

C-c <- | SPC w u winner undo
C-c -> | SPC w U winner redo

SPC a u     undo-tree-visualize
## 重复
C-u 次数 命令

C-,
M-w 复制

##区域选择
C-= : 不断的按该快捷键,会使选定的区域不断的扩展,而且只扩展到语法层面的父 结构中,
SPC v   er/expand-region 扩展选定区域;接着按ｖ就可以不断的扩大选择区域, 按V可以缩小区域
        er/contract-region 缩小选定区域
## 行插入
SPC i j: 在当前行的下面插入一个空行
SPC i k: 在当前行的上面插入一个空行

## orgmode
g 跳转
### agenda
C-c a
|SPC m a org-agenda
C-c c|SPC m c org-capture
# 文件

C-c C-f |SPC f f find-file
-------------------------------------


M-m f s     保存当前文件

C-x <left>  next-buffer 移动到下一个缓冲
C-x <right> previous-buffer	移动到前一个缓冲
C-x 1       回到正在编辑的文件
C-x b       切换缓冲区
C-x k       关闭缓冲区

--- edit
C-j         合并行
S-j         拆分行
---

常用快捷键
## 帮助

配置文件管理
SPC f e d 快速打开配置文件 .spacemacs
SPC f e R 同步配置文件
文件管理

SPC f f 打开文件（夹），相当于 $ open xxx 或 $ cd /path/to/project
SPC p f 搜索文件名，相当于 ST / Atom 中的 Ctrl + p
SPC s a p 搜索内容，相当于 $ ag xxx 或 ST / Atom 中的 Ctrl + Shift + f

SPC f t 打开/关闭侧边栏，相当于 ST / Atom 中的 Ctrl(cmd) + k + b

SPC 0 光标跳转到侧边栏（NeoTree）中
SPC n(数字) 光标跳转到第 n 个 buffer 中


SPC j = 自动对齐，相当于 beautify

# Emacs 服务器
Spacemacs 会在启动时启动服务器，这个服务器会在 Spacemacs 关闭的时候被杀掉。
## 使用 Emacs 服务器

当 Emacs 服务器启动的时候，我们可以在命令行中使用 emacsclient 命令：

    $ emacsclient -c 用 Emacs GUI 来打开文件

    $ emacsclient -t 用命令行中 Emacs 来打开文件

## 杀掉 Emacs 服务器

除了关闭 Spacemacs 之外，我们还可以用下面的命令来杀掉 Emacs 服务器：

    $ emacsclient -e '(kill-emacs)'

## 持久化 Emacs 服务器

我们可以持久化 Emacs 服务器，在 Emacs 关闭的时候，服务器不被杀掉。只要设置 ~/.spacemacs 中 dotspacemacs-persistent-server 为 t 即可。

但这种情况下，我们只可以通过以下方式来杀掉服务器了：

    SPC q q 退出 Emacs 并杀掉服务器，会对已修改的 Buffer 给出保存的提示。

    SPC q Q 同上，但会丢失所有未保存的修改。
## 问题整理
deft 模式增加 q 退出
;  (evil-define-key 'normal deft-mode-map "q" 'quit-window)
 (with-eval-after-load 'deft
   (bind-map-set-keys deft-mode-map   "<S-return>" 'deft-new-file)
   (define-key deft-mode-map (kbd "C-g") 'quit-window)
  )

### 设置启动模式
  (evil-set-initial-state 'magit-status-mode 'emacs)

magit自动进入插入模式
1. Default to insert state in COMMIT_EDITMSG buffers ？
```
    (add-to-list 'evil-buffer-regexps
                     '("COMMIT_EDITMSG" . insert))

    (push '("*magit" . emacs) evil-buffer-regexps)
    (push '("\\`CAPTURE-" . insert) evil-buffer-regexps)
    (add-hook 'org-capture-mode-hook 'evil-insert-state)
```

## ** Disable evilification of a mode?
You can ensure a mode opens in emacs state by using =evil-set-initial-state=.

#+BEGIN_SRC emacs-lisp
(evil-set-initial-state 'magit-status-mode 'emacs)
#+END_SRC

You can also do this using buffer name regular expressions. E.g. for magit,
which has a number of different major modes, you can catch them all with
```
#+BEGIN_SRC emacs-lisp
(push '("*magit" . emacs) evil-buffer-regexps)
#+END_SRC

This should make all original magit bindings work in the major modes in
question. To enable the leader key in this case, you may have to define a
binding in the mode's map, e.g. for =magit-status-mode=,

#+BEGIN_SRC emacs-lisp
(with-eval-after-load 'magit
  (define-key magit-status-mode-map
    (kbd dotspacemacs-leader-key) spacemacs-default-map))
#+END_SRC
```
## ** Include underscores in word motions? 单词移动包含下划线_
You can modify the syntax table of the mode in question. To do so you can
include this on your =dotspacemacs/user-config=.

#+BEGIN_SRC emacs-lisp
;; For python
(add-hook 'python-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))
;; For ruby
(add-hook 'ruby-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))
;; For Javascript
(add-hook 'js2-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))
#+END_SRC



2. 常见的 Emacs 的快捷键设置主要有四种类型
[那就从妖艳酷炫的快捷键开始吧！（一） - Ghost in Emacs - 知乎专栏](https://zhuanlan.zhihu.com/p/22786322)
全局快捷键:
(global-set-key (kbd "A") 'your-command)
(global-unset-key (kbd "grm"))
等价于
(define-key global-map )
全局映射键:
(define-key key-translation-map (kbd "A") (kbd "B"))

基于 Major-Mode 的局部快捷键，以及
(local-set-key (kbd "A") 'your-command)
(local-unset-          ("laptop" . ?l) ("pc" . ?p)))

定义需用到的快捷键
a-z				直接插入已定义的 TAGS
<TAB>				切换到手动输入 TAGS
<SPC>				清空所有 TAGS
!				关闭或开启互不相容的 TAGS 标记
q/C-g				退出设置key (kbd "grm"))

基于 Minor-Mode 的局部快捷键，对应的命令分别是
(define-key your-minor-mode-map (kbd "A") 'your-command)
(define-key evil-normal-state-map "q" 'evil-force-normal-state )
(define-key evil-normal-state-map "q" nil )

(define-key global-map (kbd "C-c t") 'org-capture)

# * Binding keys
Key sequences are bound to commands in Emacs in various keymaps. The most basic
map is the =global-map=. Setting a key binding in the =global-map= is achieved
with the function =global-set-key=. Example to bind a key to the command
=forward-char=:

#+BEGIN_SRC emacs-lisp
(global-set-key (kbd "C-]") 'forward-char)
#+END_SRC

The =kbd= macro accepts a string describing a key sequence. The =global-map= is
often shadowed by other maps. For example, =evil-mode= defines keymaps that
target states (or modes in vim terminology). Here is an example that creates the
same binding as above but only in =insert state= (=define-key= is a built-in
function. =Evil-mode= has its own functions for defining keys).

#+BEGIN_SRC emacs-lisp
(define-key evil-insert-state-map (kbd "C-]") 'forward-char)
#+END_SRC

Perhaps most importantly for Spacemacs is the use of the bind-map package to
bind keys behind a leader key.
This is where most of the Spacemacs bindings live. Binding keys behind the
leader key is achieved with the functions =spacemacs/set-leader-keys= and
=spacemacs/set-leader-keys-for-major-mode=, example:

#+BEGIN_SRC emacs-lisp
(spacemacs/set-leader-keys "C-]" 'forward-char)
(spacemacs/set-leader-keys-for-major-mode 'emacs-lisp-mode "C-]" 'forward-char)
#+END_SRC

These functions use a macro like =kbd= to translate the key sequences for you.
The second function, =spacemacs/set-leader-keys-for-major-mode=, binds the key
only in the specified mode. The second key binding is active only when the
major mode is =emacs-lisp=.

Finally, one should be aware of prefix keys. Essentially, all keymaps can be
nested. Nested keymaps are used extensively in spacemacs, and in vanilla Emacs
for that matter. For example, ~SPC a~ points to key bindings for "applications",
like ~SPC a c~ for =calc-dispatch=. Nesting bindings is easy.

#+BEGIN_SRC emacs-lisp
(spacemacs/declare-prefix "]" "bracket-prefix")
(spacemacs/set-leader-keys "]]" 'double-bracket-command)
#+END_SRC

The first line declares ~SPC ]~ to be a prefix and the second binds the key
sequence ~SPC ]]~ to the corresponding command. The first line is actually
unnecessary to create the prefix, but it will give your new prefix a name that
key-discovery tools can use (e.g., which-key).

There is much more to say about bindings keys, but these are the basics. Keys
can be bound in your =~/.spacemacs= file or in individual layers.
