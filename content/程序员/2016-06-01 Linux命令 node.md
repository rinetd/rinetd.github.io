---
title: 工具软件 npm
date: 2016-03-24T14:55:34+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [npm]
---
# nvm
[linux]( curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash )
[windows]( https://github.com/coreybutler/nvm-windows/releases/download/1.1.0/nvm-noinstall.zip )

## npm配置镜像、设置代理
registry = http://registry.npmjs.org/      #[官方npm镜像](npmjs.org)
registry = http://registry.npm.taobao.org/ #[淘宝npm镜像](npm.taobao.org)
registry=http://npmreg.mirrors.ustc.edu.cn/

1.临时使用
npm --registry https://registry.npm.taobao.org install express

2.持久使用
`npm config set registry https://registry.npm.taobao.org`

// 配置后可通过下面方式来验证是否成功
npm config get registry
npm info express

3.编辑 ~/.npmrc 加入下面内容 和2等价
registry = https://registry.npm.taobao.org

4.通过cnpm使用
`npm install -g cnpm --registry=https://registry.npm.taobao.org`

5.设置代理
npm config set proxy http://server:port
npm config set https-proxy http://server:port
如果需要认证的话可以这样设置：
npm config set proxy http://username:password@server:port
npm confit set https-proxy http://username:password@server:port
如果代理不支持https的话需要修改npm存放package的网站地址。

## 升级npm
npm install -g npm

使用nrm快速切换npm源
nrm 是一个 NPM 源管理器，允许你快速地在如下 NPM 源间切换：

列表项目
npm
cnpm
strongloop
enropean
australia
nodejitsu
taobao
Install
sudo npm install -g nrm
如何使用？
列出可用的源：

  ➜  ~  nrm ls
  npm ---- https://registry.npmjs.org/
  cnpm --- http://r.cnpmjs.org/
  taobao - http://registry.npm.taobao.org/
  eu ----- http://registry.npmjs.eu/
  au ----- http://registry.npmjs.org.au/
  sl ----- http://npm.strongloop.com/
  nj ----- https://registry.nodejitsu.com/
  pt ----- http://registry.npmjs.pt/
切换：

➜  ~  nrm use taobao
   Registry has been set to: http://registry.npm.taobao.org/
增加源：

nrm add <registry> <url> [home]
删除源：

nrm del <registry>
测试速度：

nrm test


只需三步就可以绑定：1、ping你的http://github.io域名，得到一个IP；2、修改你的域名解析记录，添加一个A记录，用得到的IP；3、登录http://github.com>进入项目>Settings>Custom domain>输入你的域名>Save。
