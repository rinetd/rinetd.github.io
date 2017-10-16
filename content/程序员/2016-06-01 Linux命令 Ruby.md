---
title: ruby
date: 2016-03-24T14:55:34+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [ruby]
---
# Ruby特殊变量：
$: = default search path (array of paths)
$. 解释器最近读的行数(line number)
$! 最近一次的错误信息
$@ 错误产生的位置
$_ gets最近读的字符串
$& 最近一次与正则表达式匹配的字符串
$~ 作为子表达式组的最近一次匹配
$n 最近匹配的第n个子表达式(和$~[n]一样)
$= 是否区别大小写的标志
$/ 输入记录分隔符
$\ 输出记录分隔符
$0 Ruby脚本的文件名
$* 命令行参数
$$ 解释器进程ID
$? 最近一次执行的子进程退出状态

[1](http://www.ruby-grape.org/)
##
Young [](https://github.com/shiyanhui/Young)

[ubuntu 14.04中安装 ruby on rails 环境（填坑版） 呕血推荐](http://www.tuicool.com/articles/BbMJveF)

# 1.版本管理器工具:rvm
1、安装RVM
[RVM 安装](https://ruby-china.org/wiki/rvm-guide)
```bash
## RVM
# curl -sSL https://get.rvm.io | bash -s stable
# [[ -d "$HOME/.rvm" ]] && export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# git clone --depth 1 https://github.com/rvm/rvm.git  ~/.rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

```
安装RVM的环境依赖
` rvm requirements`

Ruby 的安装与切换
rvm list
rvm list known
rvm install 2.2.0
rvm use 2.2.0
rvm use 2.2.0 --default
rvm remove 1.8.7
rvm use system
# 2、安装Ruby
* 修改 RVM 的 Ruby 安装源到国内的 淘宝镜像服务器，这样能提高安装速度
`sed -i -E 's!https?://cache.ruby-lang.org/pub/ruby!https://ruby.taobao.org/mirrors/ruby!' ~/.rvm/config/db`

mkdir .nvm/rubies .nvm/archives .rvm/user
`rvm install ruby`
* 如果想在Ubuntu上安装多个Ruby版本，那么可以使用下面的命令来指定使用rvm作为默认的Ruby版本管理。
`rvm use ruby --default`


# 3. 包管理工具:RubyGems
* [RubyGems 镜像](https://gems.ruby-china.org/)
```
1. gem update --system #更新RubyGems >2.6x
2. gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
3. gem sources -l # 查看当前使用的镜像

bundle config mirror.https://rubygems.org https://gems.ruby-china.org
```
