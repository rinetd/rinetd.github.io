---
title: spacemacs 加载顺序
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [emacs]
---
[Spacemacs configuration layers - 小幻的博客 - 博客频道 - CSDN.NET](http://blog.csdn.net/xh_acmagic/article/details/52054569)
[Spacemas的Dotfile配置 - 小幻的博客 - 博客频道 - CSDN.NET](http://blog.csdn.net/xh_acmagic/article/details/52081549)
特性： 自动加载Auto-loading
[emacs autoload 集装箱 · LinuxTOY](https://linuxtoy.org/archives/emacs-autoload.html)
```
(defun add-to-load-path (dir) (add-to-list 'load-path dir))
(add-to-list 'exec-path "~/.local/bin/")
```
# Spacemacs 约定
* Code guidelines
** Spacemacs core and layer
函数命名
  - =spacemacs/xxx= 命令函数
  - =spacemacs//xxx= 私有函数
  - =spacemacs|xxx= 宏

变量命名规范
  - =spacemacs-xxx= 普通变量
  - =spacemacs--xxx= 私有变量

layer 命名规范
(defun  layer/init-package ()
  )


[zhexuany/.spacemacs.d](https://github.com/zhexuany/.spacemacs.d)
[eggcaker/spacemacs-layers](https://github.com/eggcaker/spacemacs-layers)
[chrisbarrett/spacemacs-layers](https://github.com/chrisbarrett/spacemacs-layers)
## emacs配置加载顺序
[`~/.emacs|.emacs.el` ->  `~/.emacs.d/init.el`] -> [`.spacemacs` -> `.spacemacs.d/init.el`]

..spacemacs.d/init.el 文件加载顺序定义在`~/.emacs.d/init.el -> .emacs.d/core/core-spacemacs.el`中通过 `dotspacemacs|call-func` 宏实现调用。
在这个文件中有四个顶级函数： dotspacemacs/init，dotspacemacs/user-init, dotspacemacs/layers, 和 dotspacemacs/user-config。
```
Dotspacemacs/init  函数是在启动过程中，在其他东西运行前运行，并且包含  Spacemacs  设置。 除非你需要更改默认 Spacemacs 设置，否则你不用动这个函数。
Dotspacemacs/user-init 函数也是在其他程序运行前运行，并包含用户特定配置。
dotspacemacs/emacs-custom-settings
Dotspacemacs/layers 函数仅用于启用和禁用层和包 自定义层在此处加载
Dotspacemacs/user-config 最后加载，函数是你用到最多的函数。 在这里，你可以定义任何用户配置
```
## spacemacs 顶级函数之三 `Dotspacemacs/layers`

```lisp
(defun dotspacemacs/layers ()

 (setq-default dotspacemacs-configuration-layers
   '(
      ;; :packages            ;; 针对当前layer需要启用的package 默认全部启用
      ;; :variables           ;; 配置当前layer 变量设置
      ;; :disabled-for        ;; 指定layer中禁用
      ;; :enabled-for         ;; 在指定layer中启用

      (chinese :packages
         :variables
         ;;pangu-spacingchinese-enable-fcitx t
         pangu-spacing-real-insert-separtor t ;;将空格加入 linux 到你的档案
         ;;linux 或者有 fcitx-remote 才启用 fcitx 支持
         chinese-enable-fcitx '(or (spacemacs/system-is-linux) (executable-find "fcitx-remote"))
         chinese-enable-youdao-dict t)

      (auto-completion :enabled-for java python)
      (auto-completion :disabled-for org git)

     )))
```

### Spacemacs layer创建自定义层layer
`configuration-layer/create-layer`

### Spacemacs layer加载顺序
1. layers.el   declare additional layers
2. packages.el the packages list and configuration
        <layer>/pre-init-<package>
        <layer>/init-<package>
         `use-package` 一般在此处调用
        <layer>/post-init-<package>
        除非至少一个层为其定义了一个init函数，否则不会安装该包。 也就是说，在某种意义上，init函数是强制性设置，而pre-init和post-init函数做可选的设置。 这可以用于管理跨层依赖性，我们将在后面讨论。
3. funcs.el    all functions used in the layer should be declared here
4. config.el   layer specific configuration
5. keybindings.el  general key bindings

## Spacemacs layer加载过程

 Spacemacs加载过程可以概括如下：

Spacemacs经过所有启用层，并评估他们的文件。通过引入的变化config.el因此被应用，然后funcs.el和 packages.el被加载，但没有从发生packages.el，因为这些文件只定义函数和变量。
Spacemacs检查该包应下载并安装。要安装一个程序包必须
I layer配置package **以下4个条件必须都满足才可以**
1. 在layer中声明，并且启用
2. 不能被其他层排除掉 =<layer>-excluded-packages=
3. 不能被自己排除掉 =<layer>-excluded-packages=.
4. 必须有至少一个<layer>/init-<package>为它定义的功能。

1. included by a layer that the user has enabled,
2. not be excluded by any other layer that the user has enabled,
3. not be excluded by the user herself, and
4. there must be at least one <layer>/init-<package> function defined for it.

II: 另外，如果一个包是最终用户的一部分 `dotspacemacs-additional-packages`，它也将被安装。

加载所有的包，并按字母顺序排列 package.el内置的Emacs库负责隐含的依赖。不包含上述规则的包及其依赖将被删除。（是否移除依赖包是可选的，缺省值t）。
的pre-init，init并且post-init为每个安装的包功能依次执行。

> 注意： 如果一个layer拥有一个包，仅仅只定义pre-init或post-init 函数 但是没有定义init函数，那么这个包并不会安装。
所以 如果一个layer已经init了一个包，自定义的layer可以只定义 pre-init或post-init 去配置一个自定义的选项。
 每一个包应该只在一个layer中初始化，在其他层配置
> 注意：


### 1. layers.el
移除layer
`(configuration-layer/remove-layer 'chinese)`
添加 其他layer
(configuration-layer/declare-layers '(

                                      ))


### 2. packages.el


Packages.el 文件包含你可以在 <layer-name>-packages 变量中安装的包的列表。所有 MELPA 仓库中的包都可以添加到这个列表中。还可以使用 :excluded t 特性将包包含在列表中。每个包都需要一个函数来初始化。这个函数必须以这种模式命名：<layer-name>/init-<package-name>。这个函数包含了包的配置。同时还有一个 pre/post-init 函数来在包加载之前或之后运行代码。它看起来想这个样子：

(defconst layer-name-packages '(example-package

                            ;; :location built-in

                            ;; :toggle 条件控制 当变量chinese-enable-fcitx为`t`时加载fcitx包
                            (fcitx :toggle chinese-enable-fcitx)

                            ;; :excluded 为真(t)来卸载example-package-2
                            (example-package-2 :excluded t)))

;; List of packages to exclude.
(setq appleshan-core-excluded-packages '())  

(defun layer-name/post-init-package ()
  ;;在这里添加**另一个层**的包的配置
  )
(defun layer-name/init-example-package ()
  ;;在这里配置example-package
  )
**注意**：只有一个层可以具有一个对于包的 init 函数。如果你想覆盖另一个层对一个包的配置，请使用 use-package hooks 中的 <layer-name>/pre-init 函数。

如果 MELPA 中没有你想要的包，你必须是由一个本地包或一个包源。关于此的更多信息可以从层的剖析处获得。

确保你添加了你的层到你的 .spacemacs 文件中，并重启 spacemacs 以激活。
### 3. funcs.el
### 4. config.el
声明一些可被外部配置的变量
### 5. keybindings.el

为了将配置分组或当配置与你的 .spacemacs 文件之间不匹配时，你可以创建一个配置层。Spacemacs 提供了一个内建命令用于生成层的样板文件：SPC :configuration-layer/create-layer。这条命令将会生成一个如下的文件夹：



## 依赖检查
Spacemacs提供了一些可以用来检查是否包括其他层或包的其他有用的功能。
### 启用一个层
对于需要启用另一个层，使用功能的层 configuration-layer/declare-layer及configuration-layer/declare-layers以确保即使用户没有使他们明确表示的层被启用。调用这些功能必须去的config.el文件。
### 检查是否启用了一个层
`configuration-layer/layer-usedp`

### 启用package

即使在layer中激活了一个package，但是依然有可能会在其他层中excluded掉
1. =<layer>-excluded-packages=.
2. =dotspacemacs-excluded-packages=

### 检查包是否或将被安装
`configuration-layer/package-usedp`

(when (configuration-layer/layer-usedp 'chinese) # 当chinese层被启用时才执行以下配置

这些是在某些情况下是有用的，但通常可以只通过使用获得所需的结果post-init的功能。


## 关系整合
use-package 与 layer
use-package 与 require
use-package 与 autoload
layer 与 package
require 与 load


### 加载

注意，是**加载**，而不是**激活**。回忆下你是怎么使用Chrome的插件系统：安装插件，插件的图标出现在浏览器地址栏的右侧，点击插件的图标来使用插件（激活其功能），有的插件甚至默认激活。这个过程中，所有加载和初始化配置的工作都由软件自动完成，你唯一需要做的就是选择用不用（激活）而已。

然而，`elpa`要求你自己完成加载和配置的步骤。一般来说，常见的载入命令有，`require`，`load`，`autoload`等。而所谓的配置就是初始化一些参数。

emacs一般称“插件”为"package"或者"library"。本质上，它们都提供一堆定义好的函数，来实现一些操作，进而实现某个功能。这里多说几句。在emacs中，连移动光标这种最底层的操作都有对应的函数。比如，你在emacs中可以键入`C-f`来将光标向右移动一个字符，同时也可键入`M-x forward-char`来实现。任何复杂的功能，比如给文档生成一个目录，都可以被分解为一个个操作，或者说调用一个个函数，而这些函数顺序执行下来功能就得到了实现。

当emacs想要加载某个插件时，归根到底需要**定位并运行**一个（也许是一些）脚本文件，那个脚本里定义了实现插件功能所需的变量和函数。emacs将它们转变为可供自己使用的对象（elisp object），放到运行环境中等待调用。而脚本自身还可以在内部进一步加载其他脚本。下面，来了解加载脚本的几个语句，`load`，`require`，`load-file`，`autoload`。
参考[Emacs Lisp's Library System: What's require, load, load-file, autoload, feature?](http://ergoemacs.org/emacs/elisp_library_system.html)
延伸阅读 [Required Feature](http://www.emacswiki.org/emacs/RequiredFeature)
参考[Autoload](http://ergoemacs.org/emacs_manual/elisp/Autoload.html)
延伸阅读
* [Features](http://www.gnu.org/software/emacs/manual/html_node/elisp/Named-Features.html) TD
* [How Programs Do Loading](http://www.gnu.org/software/emacs/manual/html_node/elisp/How-Programs-Do-Loading.html) TD
* [Libraries of Lisp Code for Emacs](http://www.gnu.org/software/emacs/manual/html_node/emacs/Lisp-Libraries.html) TD
* [Byte Compilation](https://www.gnu.org/software/emacs/manual/html_node/elisp/Byte-Compilation.html) TD

+ Feature可以理解为“特色功能”，比如，你在苹果的App Store里查看应用程序简介时，一般都会看到一个以Features开头的段落。单数形式，feature，一般对应一个插件的名字，因为一般插件的名字直接表明它实现的功能。复数形式，features，是一个用来存储feature的列表，这个列表可以告诉emacs哪些插件经被加载了。一般情况下，一个插件的启动脚本的结尾会调用`(provide '<symbol name>)`，将`'<symbol name>`加入到features中去。`'<symbol name>`一般就是插件的名字
+ `load`一个位于硬盘上的文件，意味着执行这个文件里的所有elisp语句，然后将执行结果放进emacs的运行环境
+ `(require '<symbol name>)`会先查看features里面是否存在`<symbol name>`。如果存在，语句执行完毕。如果不存在，基于它来猜一个文件名，或者由`require`的第二个参数直接指定文件名，然后`load`文件。注意，`load`完成后，`require`函数会再一次查看features列表中是否存在`'<symbol name>`，如果发现还是不存在，视参数`<soft-flag>`来决定是否报错
+ `require` 只不过是一种加载load-file的方法，它的意义在于避免重复加载。比如，某个插件的启动脚本中需要用到另一个插件提供的某个函数。那么它就会`require`这个插件，保证插件已被载入，然后再执行后续语句。

+ `load-file`需要指定文件路径，
+ `load`对load-file进行封装,不需要指定路径。会自动搜索`load-path`，
+  `require` 只不过是一种加载load-file的方法，它确保文件以正确的顺序加载，并避免重复加载。在某种程度上解决了去哪里找到需要加载的文件的问题，但是过长的加载列表依然导致emacs加载起来很慢。所以采用autoload才是王道
+ `autoload`在函数执行时再`load`指定文件 （该函数关联到指定el,当该函数被调用时再去加载运行指定文件）

其实，连整个emacs的启动都可以概括为一句话：加载一系列脚本。只不过这些脚本有的是内置的（built in），有的是你安装的插件包含的，有的是你自己写的。

autoload原理:
1. 首先当函数加载时，将函数定义为null,当调用时立即将函数替换为函数本身，并加载执行。所以也会带来微小的延时。
2. autoload 主要用于 xxx-mode major模式中.
+ `autoload`告诉emacs某个地方有一个定义好的函数，并且告诉emacs，先别加载，只要记住在调用这个函数时去哪里寻找它的定义即可
+ 这样做的一个好处是，避免在启动emacs时因为执行过多代码而效率低下，比如启动慢，卡系统等。想象一下，如果你安装了大量的有关python开发的插件，而某次打开emacs只是希望写点日记，你肯定不希望这些插件在启动时就被加载，让你白白等上几秒，也不希望这些插件在你做文本编辑时抢占系统资源（内存，CPU时间等）。所以，一个合理的配置应该是，当你打开某个python脚本，或者手动进入python的编辑模式时，才加载那些插件
+ 一个简单概括：“只注册函数名而不定义函数本身”

前面介绍了几种加载机制。加载的目的在于定义变量和函数以供使用。任何插件，只有先被加载才能被使用。而且通常，你都希望先加载一个插件，再来配置它。考虑如下情景。

你的插件中定义了一个变量a，默认值是1，插件内定义的许多函数都在内部使用了a。你希望在自己使用这些函数时，用到的a的值是2。有两种实现途径。一种是直接到插件的脚本文件中修改a的值为2。这叫做"hard coding"，有很多坏处。比如，每次更新插件，都要重新修改。另一种方法是，等这个插件已经被加载后，修改相应的elisp object。那自然，你得先让这个对象存在于emacs中，然后才能修改。所以要先加载，让需要配置的变量得到定义，再去修改变量的值。

下面，让我们来看看这些脚本文件究竟长什么样子。打开emacs内置插件的文件夹，`emacs安装路径\share\emacs\24.4.91\lisp`，你会看到一些子文件夹，一些后缀名为`gz`的压缩文件，以及一些后缀名为`elc`的文件。压缩文件中存放的其实是同名的`.el`文件，也就是前面一直在提的脚本。`.elc`是这个脚本编译好的版本，可以加快载入速度，不适合人类阅读。所以，如果你想查看一个插件的源代码，请查看`.el`文件。`.el`被放在压缩包是为了避免源代码被修改，进而造成各种问题。另外，加载插件时，总是会优先加载编译好的版本，其默认的文件扩展名即`.elc`；如果不存在，才会加载`.el`或者其他格式的文件。
## autoload
autoload 在 emacs 中也是一种类型，和符号、数字、字符串、函数是同等级别的对象，实际上，它就是个函数。它和函数的区别类似于函数原型和函数的区别——没有实际的定义，只有简单说明， 调用的时候才加载相关定义。
有两种定义方式：
1. (autoload 'some-function "some-file")

autoload 对象需要用 autoload 函数生成，类似下面这种：(autoload 'fn "file" "docstring" interactive type)
参数包含：
      fn （没有名称你敢怎么调用）
      file （具体定义实际存储的位置）
      docstring （使用说明）
      interactive （如果非 nil 表示可以通过交互方式调用）
      type （类型：函数、宏、键图）

2. **Magic comments** `;;;###autoload`

把你所有的非emacs自带函数集中起来，放到一个文件夹里；
然后拆分成许多文件（每个文件里的函数建议不要超过5个），然后函数前面加上 **Magic comments** `;;;###autoload` ，在你的配置文件里写：
;假设你的这个文件夹路径为 /x/y/z
`(lazily "/x/y/z")`
通俗的说，效果就是，给这些文件里面的函数生成一个路径表，这些函数文件都不用读取了，只读取这个路径表，用到这些函数的时候再根据这个路径表读取所在文件，对于加快 emacs 的启动速度有一定帮助

##3.5 Use-package
默认 不加参数相当于 require

它把各种配置整合到属性里面去
:commands (isearch-moccur isearch-all) == autoload
  当包的作者已经不更新时，你可以通过:commands创建自己的autoload引用。推迟到使用他们时在去加载
:init  == pre-init
   不管什么情况下,init代码块都会执行,即使use-package调用包不存在，也会执行。并且调用时立即执行。
:defer t == lazyload
  使用package本身提供的autoload命令延迟package的加载。实现lazyload 本质上，这就是一个空操作。
:config == post-init
  当启用defer后 :init依然会立即执行，但是:config块会延迟到package加载完成之后执行。 因此defer和config盘配合起来使用相当于`with-eval-after-load`

### 使用`spacemacs|use-package-add-hook` 注入`Use-package` hooks
(spacemacs|use-package-add-hook helm
  :pre-init 注入use-package :init
  ;; Code
  :post-init
  ;; Code
  :pre-config
  ;; Code
  :post-config
  ;; Code
  )

当`use-package`被调用时立即执行:init块代码，因此任何想要将代码注入此块的函数必须在调用use-package之前运行。
此外，由于对use-package的调用通常发生在`init-<package>`函数中，
而对`spacemacs|use-package-add-hook`的调用通常发生在`pre-init-<package>`函数中，而不在`post-init-<package>` 中。
所以嘛，`spacemacs|use-package-add-hook`当然最好在`pre-init-<package>`中。
