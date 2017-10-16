---
title: 文本编辑 spacemacs
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [emacs]
---
ivy：
去掉 [SPC SPC] counsel-M-x命令行中自动添加的`^`符号
;; (setq ivy-initial-inputs-alist nil)


(evil-global-set-key 'visual (kbd "C-*") 'mc/mark-all-like-this-dwim)
(evil-global-set-key 'visual (kbd "M-*") 'mc/mark-all-symbols-like-this-in-defun)
(evil-global-set-key 'visual (kbd "C-<") 'mc/mark-previous-like-this)
(evil-global-set-key 'visual (kbd "C->") 'mc/mark-next-like-this)
(evil-global-set-key 'visual (kbd "C-M-<") 'mc/skip-to-previous-like-this)
(evil-global-set-key 'visual (kbd "C-M->") 'mc/skip-to-next-like-this)
(evil-global-set-key 'visual (kbd "C-S-SPC") 'mc/skip-to-next-like-this)

#  清空evil insert map
在dotspacemacs/user-config加入以下代码：

(setcdr evil-insert-state-map nil)
(define-key evil-insert-state-map [escape] 'evil-normal-state)

#添加better-default， `C-e` 未生效
(better-defaults :variables
                 better-defaults-move-to-end-of-code-first t)

(define-key evil-insert-state-map (kbd "C-e") 'mwim-end-of-code-or-line)
(define-key evil-motion-state-map (kbd "C-e") 'mwim-end-of-code-or-line)
;; vim

(chinese :packages
        :variables
        ;;pangu-spacingchinese-enable-fcitx t
        pangu-spacing-real-insert-separtor t ;;将空格加入 linux 到你的档案
        ;;linux 或者有 fcitx-remote 才启用 fcitx 支持
        chinese-enable-fcitx (or (spacemacs/system-is-linux) (executable-find "fcitx-remote"))
        chinese-enable-youdao-dict t)
```
(defun set-font (english chinese english-size chinese-size)
  (set-face-attribute
   'default nil :font (format "%s:pixelsize=%d" english english-size))
  (dolist
      (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font
     (frame-parameter nil 'font) charset (font-spec :family chinese :size
                                                    chinese-size))))
(when (spacemacs/system-is-mac)
  (set-font "PragmataPro" "Source Han Sans SC" 18 20))

(when (spacemacs/system-is-linux)
  (set-font "Source Code Pro" "Droid Sans Fallback" 18 20))

```
(shell :variables
       shell-default-shell (if (spacemacs/system-is-linux) 'eshell 'eshell)
       ;; shell-default-term-shell "/usr/bin/zsh"
       shell-protect-eshell-prompt t
       shell-default-height 35
       shell-default-position 'bottom
       )

(restclient :variables
           restclient-use-org t)

prodigy

(dash :variables helm-dash-docset-newpath "~/.local/share/Zeal/Zeal/docsets/")

(deft :variables
  deft-recursive t
  deft-text-mode 'org-mode
  deft-default-extension "org"
  deft-directory "~/org-notes/"
  deft-extensions '("org" "clj" "txt" "md" )
  )

```
(org :variables
     org-enable-github-support t
     org-enable-bootstrap-support t
     org-enable-reveal-js-support t)

```
project 添加排除目录
  (setq projectile-globally-ignored-directories
        (append '(".svn") projectile-globally-ignored-directories))
# ranger 模式错误总结
[ranger文件管理器](http://debsoft.blog.163.com/blog/static/170754272201192204553391/)
```
(ranger :variables
        ranger-header-func 'ranger-header-line
        ranger-parent-depth 1        ;; 显示父目录
        ranger-show-preview t        ;; 开启文件预览
        ranger-show-literal nil      ;; 预览开启语法高亮
        ranger-max-preview-size 1    ;; 仅小于1M启用预览
        ranger-ignored-extensions '("mkv" "iso" "mp4" "png" "jpeg" "jpg")
        )

```
S: 在当前目录下开启一个 shell

1. 没有创建Bookmark 导致的ranger不可用
`ranger-mode: Symbol’s value as variable is void: bookmark-alist`
2. Ranger 与 golden ratio 不兼容
my-quit-ranger: Symbol’s value as variable is void: golden-ratio-previous-enable


(with-eval-after-load 'ranger
    (progn		    (progn
 -    (define-key ranger-normal-mode-map (kbd "q") 'ranger-close)))		 +    (define-key ranger-normal-mode-map (kbd "q") 'ranger-close)
 +    (define-key evil-normal-state-local-map (kbd "SPC f j") 'deer)))

# 常用快捷键设置
 ;; 行插入
(global-set-key (kbd "<C-S-return>") 'evil-open-above)
(global-set-key (kbd "<C-return>") 'evil-open-below)
(with-eval-after-load 'lispy
  (define-key lispy-mode-map (kbd "<C-return>") 'evil-open-below))
;; 交换行
(global-set-key (kbd "<C-up>") 'move-text-line-up)
(global-set-key (kbd "<C-down>") 'move-text-line-down)
# avy
(use-package avy
:init (setq avy-keys '(?j ?h ?k ?l ?f ?g ?d ?s ?u ?r ?n ?v ?i ?e ?o ?w))
(setq avy-keys '(?a ?s ?d ?f ?j ?k ?l ;; home row keys
                    ?w ?e ?r ?u ?i ?o ?g ?h ?x ?c ?v ?m ;; easy moves
                    ?t ?n ?z ?p ;; harder moves
                    ))
:config (progn
          (define-key evil-normal-state-map (kbd "s") 'avy-goto-char)
          (define-key evil-normal-state-map (kbd "f") 'avy-goto-char)
          (define-key evil-normal-state-map (kbd "C-f") 'avy-goto-char-2)
        )
)
(use-package avy
  :ensure t
  :init
  ;; Use more keys
  (setq avy-keys (append (number-sequence ?a ?z) '(?ö ?ä)))
  ;; Overlay the first character on top, but show the full path
  :config
  (define-key evil-motion-state-map (kbd "SPC") 'kluge-avy-goto-char)
  (define-key evil-motion-state-map (kbd "g SPC") 'kluge-avy-goto-line))

(use-package avy
  :ensure t

  :config
  (setq avy-keys (string-to-list "asdfjklqwecviopnmughr"))
  :bind (("C-'"     . avy-goto-char-2)
         ("C-\""    . avy-goto-char-timer)
         ("C-c j ," . avy-pop-mark)))
# 如何修改emacs中关于单词的划分？
查看分词表 `C-h s`
http://emacs.stackexchange.com/questions/10195/word-delimiters-in-standard-syntax-table
`%';$()-=`
modify-syntax-entry
## syntax class

-   whitespace character        
_   symbol constituent   符号组成
w   word constituent     单词组成
```
    (modify-syntax-entry ?[ "w")
    (modify-syntax-entry ?] "w")
```
'   expression prefix  
    `(modify-syntax-entry ?' "'")`

<   comment starter          >   comment ender   注释
```
    (modify-syntax-entry ?\; "<" st)
    (modify-syntax-entry ?\n ">" st)
```
(   open delimiter character )   close delimiter character
```
    (modify-syntax-entry ?^ "($")
    (modify-syntax-entry ?$ ")^")
```
$   paired delimiter 配对分隔符
  `(modify-syntax-entry ?$ "$" text-mode-syntax-table)`

|   generic string delimiter
!   generic comment delimiter
@   inherit from `standard-syntax-table`

.   punctuation character 标点符号

"   string quote character
/   character quote character
\   escape character


## syntax table
1. 所有的分词表都继承`standard-syntax-table`
2. (`make-syntax-table` 默认创建 `standard-syntax-table`.)
3. 查看分词表命令 describe-syntax (C-h s).


## paredit
分割和连接（split & join）

一个表分为两个表，一个字符串分割为两个字符串。这些在Paredit中是十分简单的。只需要在要分割的地方按下M-S。

;;; 例子，将光标放在world前，按下M-S
(hello world)
(hello) (world)
;;; 字符串的
"Hello,world"
"Hello," "world"
连接的我就不写了，快捷键是M-J。还有看到上面代码的注释了吧，我要写注释的时候就按M-;然后注释符自动就打出来了，Paredit就是这么酷。

吞吐S表达式（Barfage & Slurpage）

我觉得这简直就是Paredit的精髓，简直太好用了。吞掉右边的S表达式，C-)，吐出来C-}。对应的，吞掉左边的S表达式，C-(，吐出来C-{。

(foo bar (baz) quux zot)
;;; 把光标放到(baz)里面，先吞右边（C-)）后吞左边（C-(）
(foo bar (baz quux) zot)
(foo (bar baz quux) zot)
;;; 吐：把光标放在(bar baz quux)中，先吐左边（C-{）后吐右边（C-}）
(foo bar (baz quux) zot)
(foo bar (baz) quux zot)
跳出外围块

这个不太好表达，就写个例子吧。就是下面这个样子的。

(foo (let ((x 5))
       (sqrt n)) bar)
;;; 光标停留在(sqrt n)前面，按下M-r
(foo (sqrt n) bar)

;;; 再来一个
(if (pre)
    (then)
    (otherwise))
;;; 在(then)前面按M-r
(then)
