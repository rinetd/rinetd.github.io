---
title: Linux命令 Composer
date: 2016-03-29T20:57:24+08:00
update: 2016-01-01
categories:
tags: [Composer]
---
[install](http://pkg.phpcomposer.com/)
Packagist 镜像

请各位使用本镜像的同学注意：

本镜像已经依照 composer 官方的数据源安全策略完全升级并支持 https 协议！请各位同学 按照下面所示的两个方法将 http://packagist.phpcomposer.com 修改为 https://packagist.phpcomposer.com

    还没安装 Composer 吗？请往下看如何安装 Composer 。

用法：

有两种方式启用本镜像服务：

    系统全局配置： 即将配置信息添加到 Composer 的全局配置文件 config.json 中。见“例1”
    单个项目配置： 将配置信息添加到某个项目的 composer.json 文件中。见“例2”

例1：修改 composer 的全局配置文件（推荐方式）

打开命令行窗口（windows用户）或控制台（Linux、Mac 用户）并执行如下命令：

` composer config -g repo.packagist composer https://packagist.phpcomposer.com
`
例2：修改当前项目的 composer.json 配置文件：

打开命令行窗口（windows用户）或控制台（Linux、Mac 用户），进入你的项目的根目录（也就是 composer.json 文件所在目录），执行如下命令：

composer config repo.packagist composer https://packagist.phpcomposer.com

上述命令将会在当前项目中的 composer.json 文件的末尾自动添加镜像的配置信息（你也可以自己手工添加）：

"repositories": {
    "packagist": {
        "type": "composer",
        "url": "https://packagist.phpcomposer.com"
    }
}

以 laravel 项目的 composer.json 配置文件为例，执行上述命令后如下所示（注意最后几行）：

{
    "name": "laravel/laravel",
    "description": "The Laravel Framework.",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "type": "project",
    "config": {
        "preferred-install": "dist"
    },
    "repositories": {
        "packagist": {
            "type": "composer",
            "url": "https://packagist.phpcomposer.com"
        }
    }
}

OK，一切搞定！试一下 composer install 来体验飞一般的速度吧！

## 安装composer
1.
`sudo apt install composer --no-install-recommends`
2.
`curl -sS https://getcomposer.org/installer | php`
`php -r "readfile('https://getcomposer.org/installer');" | php`

`curl -sS https://getcomposer.org/installer | php7.0 -- --install-dir=/usr/local/bin --filename=composer`
`php7.0 -r "readfile('https://getcomposer.org/installer');" |  php7.0 -- --install-dir /usr/local/bin --filename composer`
3.
```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '070854512ef404f16bac87071a6db9fd9721da1684cd4589b1196c3faf71b9a2682e2311b36a5079825e155ac7ce150d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```
php composer.phar install

sudo mv composer.phar /usr/bin/composer

Windows 系统：

    找到并进入 PHP 的安装目录（和你在命令行中执行的 php 指令应该是同一套 PHP）。
    将 composer.phar 复制到 PHP 的安装目录下面，也就是和 php.exe 在同一级目录。
    在 PHP 安装目录下新建一个 composer.bat 文件，并将下列代码保存到此文件中。

@php "%~dp0composer.phar" %*

3. 修改composer Packagist 镜像
composer config -g repo.packagist composer https://packagist.phpcomposer.com
composer config repo.packagist composer https://packagist.phpcomposer.com
4. 更新composer
`composer selfupdate`

################################################################################

# 安装 Laravel
/etc/apt/sources.list.d/ondrej-php-7_0-trusty.list
  deb http://ppa.launchpad.net/ondrej/php/ubuntu trusty main

sudo apt-get update
sudo apt-get install php-mbstring
sudo apt-get install mcrypt php7.0-mcrypt
sudo apt-get upgrade


composer create-project laravel/laravel learnlaravel5

composer update


cd public
php -S 0.0.0.0:1024

## 添加用户
;"laravel/framework": "5.2.* ",
php artisan make:auth

## 添加数据库
;could not find driver
sudo apt-get -y install php-mysql

;SQLSTATE[HY000] [1044] Access denied for user 'homestead'@'%' to database 'homestead'
vim .env
  DB_HOST=127.0.0.1
  DB_PORT=3306
  DB_DATABASE=laravel5
  DB_USERNAME=root
  DB_PASSWORD=''
php artisan config:clear

create user homestead;
set password for homestead = password('secret');
