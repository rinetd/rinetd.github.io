---
title: Linux命令 snap
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [snap]
---

https://github.com/snapcraft-gui/snapcraft-gui
息称，Snap 软件包拥有更加稳定和安全的特性，本文我们就一起来看看如何在 Ubuntu 16.04 中使用 Snap 软件包。
什么是Snap软件包

首先要说什么是「包」？Linux 中应用程序的安装通常有两种方式：其一，是直接通过源代码编译安装，需要用户手动执行脚本、处理依赖等不太人性化的操作；其二，是由软件发行商将应用程序打包成「软件包」进行交付，例如 Ubuntu 用户直接双击 .deb（Debian 软件包） 文件即可安装软件。

现在 Ubuntu 搞一个新的 Snap 包管理系统是因为基于 Debian .deb 文件并被大量使用的包管理方式不好吗？其实不然，它只对包管理进行了规范并更多会在类似无人机项目等物联网领域进行使用。

Canonical 官方是这么进行描述的：

    .snap 包中包含了 Ubuntu 核心中的所有依赖关系，这比传统 .deb 或基于 RPM 的依赖处理更有优势。更重要的是，开发人员不必担心应用被分发到用户系统之后其它方面触发的系统变更。

使用Snap软件包

通常我们都使用 apt-get 来管理 Ubuntu 中的软件包， 16.04 发布之后建议大家直接使用 apt 命令。与此类似，用户可以使用

`snap find` 命令来列出适用于当前系统的 Snap 软件包。

Ubuntu 16.04 LTS如何使用Snap软件包

安装 Snap 包可以使用如下命令：

`sudo snap install` <包名>

Ubuntu 16.04 LTS如何使用Snap软件包

查看当前系统中已安装的 Snap 软件包：

`snap list`

大家看到了吧，Ubuntu 16.04 的 Ubuntu 核心已经使用 Snap。

Snap 还提供了其对系统的更改历史记录，可以使用如下命令查看：

`snap changes`

Ubuntu 16.04 LTS如何使用Snap软件包

要升级 Snap 软件包版本，可以使用如下命令：

sudo snap refresh <包名>

移除 Snap 软件包使用如下命令：

sudo snap remove <包名>

Ubuntu 16.04 LTS如何使用Snap软件包

目前来看，采用 Snap 方式打包的软件非常少，不过国外已经有大的开源软件发行商已经公开表态将逐步开始采用 Snap 软件包发行软件。Canonical 也已经推出了 Snapcraft 工具帮助开发人员打包 Snap 应用。
