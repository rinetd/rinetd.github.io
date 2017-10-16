---
title: Hexo使用文档
date: 2016-02-02T15:03:34+08:00
update: 2016-09-27 16:42:48
categories: [linux_base]
tags: [Hexo]
---

[leanote博客评论设置之Disqus](http://leanote.com/blog/view/52db8463e01c530ef8000001)
[Hexo document](http://wiki.jikexueyuan.com/project/hexo-document/)
[Hexo 中文文档](https://wizardforcel.gitbooks.io/hexo-doc/content/index.html)
说明:hexo 还是很不错的
## hexo 按更新时间排序 `vi _config.yml`
index_generator:
  order_by: -update # order_by: Posts order. (Order by date descending by default)
## 
<!-- more -->
### 0x01 安装node.js
[node.js稳定版](https://nodejs.org/en/)
`ln -s /home/kun/mysofltware/node-v0.10.28-linux-x64/bin/node /usr/local/bin/node`
`ln -s /home/kun/mysofltware/node-v0.10.28-linux-x64/bin/npm /usr/local/bin/npm`

### 0x02 配置node.js
通过npm config set   生成 .npmrc
prefix=D:\Users\nodejs\npm
cache=D:\Users\nodejs\npm-cache

### 0x03 安装 hexo
`npm install -g hexo`
查看安装结果
`npm list -g **hexo**`
## Ubuntu
sudo apt-get install nodejs
sudo ln -s /usr/bin/nodejs /usr/bin/node
npm install -g cnpm --registry=https://registry.npm.taobao.org
sudo npm install cnpm -g
sudo cnpm install hexo -g
sudo cnpm install


   "hexo": "^3.2.0",
   "hexo-toc": "^0.0.6",
   "hexo-server": "^0.2.0",
   "hexo-github": "^1.0.1",
   "hexo-deployer-git": "^0.1.0",
   "hexo-generator-archive": "^0.1.4",
   "hexo-generator-category": "^0.1.3",
   "hexo-generator-feed": "^1.1.0",
   "hexo-generator-index": "^0.2.0",
   "hexo-generator-sitemap": "^1.1.2",
   "hexo-generator-tag": "^0.2.0",
   "hexo-renderer-ejs": "^0.2.0",
   "hexo-renderer-sass": "^0.2.0",
   "hexo-renderer-jade": "^0.3.0",
   "hexo-renderer-marked": "^0.2.10",
   "hexo-renderer-stylus": "^0.3.1",

hexo

npm install hexo -g #安装
npm update hexo -g #升级
hexo init #初始化
简写

hexo n "我的博客" == hexo new "我的博客" #新建文章
hexo p == hexo publish
hexo g == hexo generate#生成
hexo s == hexo server #启动服务预览
hexo d == hexo deploy#部署

服务器

hexo server #Hexo 会监视文件变动并自动更新，您无须重启服务器。
hexo server -s #静态模式
hexo server -p 5000 #更改端口
hexo server -i 192.168.1.1 #自定义 IP

hexo clean #清除缓存 网页正常情况下可以忽略此条命令
hexo g #生成静态网页
hexo d #开始部署
python -m SimpleHTTPServer
监视文件变动

hexo generate #使用 Hexo 生成静态文件快速而且简单
hexo generate --watch #监视文件变动

完成后部署

两个命令的作用是相同的
hexo generate --deploy
hexo deploy --generate
hexo deploy -g
hexo server -g

草稿

hexo publish [layout] <title>

模版

hexo new "postName" #新建文章
hexo new page "pageName" #新建页面
hexo generate #生成静态页面至public目录
hexo server #开启预览访问端口（默认端口4000，'ctrl + c'关闭server）
hexo deploy #将.deploy目录部署到GitHub

hexo new [layout] <title>
hexo new photo "My Gallery"
hexo new "Hello World" --lang tw

模版（Scaffold）

hexo new photo "My Gallery"

设置文章摘要

以上是文章摘要 <!--more--> 以下是余下全文
写作

hexo new page <title>
hexo new post <title>

变量  描述
:title  标题
:year   建立的年份（4 位数）
:month  建立的月份（2 位数）
:i_month    建立的月份（去掉开头的零）
:day    建立的日期（2 位数）
:i_day  建立的日期（去掉开头的零）
推送到服务器上

hexo n #写文章
hexo g #生成
hexo d #部署 #可与hexo g合并为 hexo d -g

报错

1.找不到git部署

ERROR Deployer not found: git
解决方法

npm install hexo-deployer-git --save

3.部署类型设置git

hexo 3.0 部署类型不再是github，_config.yml 中修改

# Deployment
## Docs: http://hexo.io/docs/deployment.html
deploy:
  type: git
  repository: git@***.github.com:***/***.github.io.git
  branch: master
4. xcodebuild

xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance

npm install bcrypt

5. RSS不显示

安装RSS插件

npm install hexo-generator-feed --save

开启RSS功能

编辑hexo/_config.yml，添加如下代码：

rss: /atom.xml #rss地址  默认即可
### 0x04 创建项目
 `hexo init rinetd`
 `hexo new rinetd`
 `hexo g`
### 0x05 主题安装
 maupassant
`git clone https://github.com/tufu9441/maupassant-hexo.git themes/maupassant`
`npm install hexo-renderer-sass --save`
`npm install hexo-renderer-jade --save`

## 0x06 配置多说
 申请多说开发者帐号[注册](http://duoshuo.com/create-site)
 [测试帐号](http://api.duoshuo.com/sites/listTopThreads.json?short_name=jyprince)

## 0x07 配置disqus
  [申请Disqus帐号](https://disqus.com/admin/signup/?utm_source=New-Site)


http://segmentfault.com/a/1190000002632530
