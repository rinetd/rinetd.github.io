---
title: 工具软件 node yarn
date: 2016-03-24T14:55:34+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [npm]
---
# node & npm 自用前端实用工具总结

## 1 起步

### 1.1 安装 nodeJs & npm
初次可直接从官网下载安装(内含最新版的 nodejs 和 npm) [https://nodejs.org](https://nodejs.org)

### 1.2 管理 nodeJs 版本
1. 安装 n 模块
    ```shell
    $ sudo npm install -g n
    ```

2. 升级 nodeJs
    ```shell
    # Use or install the latest official release:
    $ n latest

    # Use or install the stable official release:
    $ n stable

    # Use or install the latest LTS official release:
    $ n lts
    ```

3. 切换 nodeJs 版本
    ```shell
    $ n

      4.6.0
    ο 6.8.0
    ```

4. 删除 nodeJs 版本
    ```shell
    $ n rm 0.9.4
    ```

5. n 模块 github 地址：[https://github.com/tj/n](https://github.com/tj/n)

6. **注意：windows 系统不适用以上方法**
    * windows 直接在官网下载最新版本，覆盖安装来升级 nodeJs 版本
    * win10自带的 Ubuntu bash 代码行也可以试一下（未测试过）

### 1.3 MAC系统 npm 需要管理员权限问题(未测试)
```shell
$ sudo chown -R $USER /usr/local   
```

### 1.4 win使用`nvm-windows`安装&管理node版本
1. 安装[nvm-windows](https://github.com/coreybutler/nvm-windows)
2. 在命令行输入nvm验证安装成功
3. 常用命令

    ```shell
    # 查看已安裝的Node版本
    $ nvm list

    # 查看提供哪些Node版本
    $ nvm list available

    # 安裝指定的Node版本
    $ nvm install [version]

    # 指定使用Node版本
    $ nvm use [version]
    ```

## 2 管理 npm 模块管理器
### 2.1 升级 npm 的版本
* 通用
    ```shell
    $ npm install npm@latest -g
    ```

* windows 平台插件： [npm-windows-upgrade](https://github.com/felixrieseberg/npm-windows-upgrade)
    ```shell
    $ npm i -g npm-windows-upgrade
    $ npm-windows-upgrade
    ```

### 2.2 升级 npm 依赖包
[npm-check](https://github.com/dylang/npm-check)是用来检查npm依赖包是否有更新、错误以及是否在使用的，可以方便的使用npm-check进行包的更新

1. 安装npm-check

    ```shell
    $ npm install -g npm-check
    ```

2. 检查全局的 npm 包是否可升级

    ```shell
    $ npm-check -u -g
    ```

### 2.3 淘宝NPM镜像`cnpm` (不推荐，用yarn代替)
1. 安装`cnpm`

    ```shell
    $ npm install -g cnpm --registry=https://registry.npm.taobao.org
    ```

2. 用cnpm安装模块

    ```shell
    $ cnpm install [name]
    ```

### 2.4 npm 个人常用命令
```shell
# 查看 npm 的版本
$ npm -v

# 为npm init设置默认值
$ npm set init-author-name 'cycjimmy'
$ npm set init-author-email 'cycjimmy@gmail.com'
$ npm set init-author-url 'https://github.com/cycjimmy'
$ npm set init-license 'MIT'

# 初始化生成一个package.json文件。
# 使用 -y 可以跳过提问阶段，直接生成package.json文件
$ npm init -y

# 列出当前项目安装的所有模块包
$ npm ls --depth=0

# npm install默认会安装dependencies字段和devDependencies字段中的所有依赖包
$ npm i
# 针对国内可以加上参数
$ npm --registry=https://registry.npm.taobao.org i

# 安装依赖包
# –save：添加到dependencies，可简化为-S
# –save-dev: 添加到devDependencies，可简化为-D
$ sudo npm i -g [package name]
$ npm i [package name]
$ npm i [package name] -S
$ npm i [package name] -D

# 更新依赖包
# -S表示保存新的依赖包版本号到package.json
$ npm update <package name> -S
# npm update只更新顶层依赖包，而不更新依赖的依赖，如果想递归更新取，使用下面的命令
$ npm --depth 9999 update

# 卸载依赖包
$ npm uninstall [package name]
$ npm uninstall [package name] -global

# 执行任务
$ npm run [task name]

# 针对国内的设置
$ npm config set registry=http://registry.npmjs.org

# 使用XX-Net的可设置下http代理
$ npm config set proxy http://127.0.0.1:8087
$ npm config set https-proxy http://127.0.0.1:8087
$ npm config set strict-ssl false -g

# 还原设置
$ npm config delete registry
$ npm config delete proxy
$ npm config delete https-proxy
$ npm config delete strict-ssl

# 列出所有npm配置项目
$ npm config ls -l
```

*  `strict-ssl` 需手动修改 `.npmrc` 文件(located in \Users\ in Windows)
    ```shell
    # .npmrc文件中添加
    strict-ssl=false
    ```

[其他比较详细的npm命令查看 ](http://javascript.ruanyifeng.com/nodejs/npm.html)

### 2.5 用yarn取代npm
[Yarn](https://yarnpkg.com/) is a package manager for your code.

1. 安装(升级)yarn

    ```shell
    $ npm install -g yarn
    ```

2. yarn常用命令
    ```shell
    # npm init =>
    $ yarn init

    # npm install =>
    $ yarn install
    $ yarn install --force     #强制所有包重新下载

    # npm install --save [package] =>
    $ yarn add [package]

    # npm install --save-dev [package] =>
    $ yarn add [package] --dev

    # npm install --global [package] =>
    $ yarn global add [package]

    # rm -rf node_modules && npm install =>
    $ yarn upgrade [package]
    $ yarn upgrade [package] --ignore-engines  #忽略引擎

    # npm uninstall --save [package] =>
    # npm uninstall --save-dev [package] =>
    $ yarn remove [package]

    # npm cache clean =>
    $ yarn cache clean

    # 针对国内的设置
    $ yarn config set registry https://registry.npm.taobao.org

    # 使用XX-Net的可设置下http代理
    $ yarn config set proxy http://127.0.0.1:8087
    $ yarn config set https-proxy http://127.0.0.1:8087
    $ yarn config set strict-ssl false -g

    # 还原设置
    $ yarn config delete registry
    $ yarn config delete proxy
    $ yarn config delete https-proxy
    $ yarn config delete strict-ssl
    ```

  * yarn的 `strict-ssl` 配置目前存在BUG，需手动修改 `.yarnrc` 文件(located in \Users\ in Windows)【[yarn/issues#980](https://github.com/yarnpkg/yarn/issues/980)】
    ```shell
    # 进入vi修改.yarnrc
    $ vi ~/.yarnrc

    # .yarnrc内容:
    # ------------------------------------------------------------------------
      # THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.
      # yarn lockfile v1
      strict-ssl false

    # ------------------------------------------------------------------------
    # 修改完毕输入 :wq 保存退出
    ```

### 2.6 国内抓取node-sass失败的解决方案

```shell
# 使用淘宝镜像
$ SASS_BINARY_SITE=https://npm.taobao.org/mirrors/node-sass/ npm install node-sass

# 或者使用淘宝镜像cnpm
$ cnpm install node-sass
```

// 安装yarn

cnpm install yarn -g



yarn更换下载源

// 查看下载源

yarn config get registry

// 更换为淘宝源

yarn config set registry https://registry.npm.taobao.org

// 初始化项目

yarn init -y

// 安装webpack

yarn add webpack

// 更新到最新的

yarn upgrade webpack

// 安装项目里的依赖

yarn install


# CYarn

> 使用 cnpm 源的 Yarn

Yarn 是一个快速、可靠、安全的 JavaScript 依赖管理工具。

- Yarn 文档：https://yarnpkg.com/ （官方网站支持多语言，但是中文文档还没有）

## 安装 CYarn

```shell
npm install -g cyarn
```

或者使用 cnpm 源：

```shell
npm install -g cyarn --registry=https://registry.npm.taobao.org
```

## 其他修改源的方式

### 配置 yarn config

https://yarnpkg.com/en/docs/cli/config

```shell
yarn config set registry https://registry.npm.taobao.org
```

### 使用 yrm

https://github.com/i5ting/yrm

```shell
npm install -g yrm
yrm use cnpm
```

## 现有技术

CYarn 离不开这些现有技术：

 - [Yarn](https://github.com/yarnpkg/yarn)
 - [cnpm](https://github.com/cnpm/cnpm)
