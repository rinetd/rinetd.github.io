---
title: vagrant
date: 2016-03-24T14:55:34+08:00
update: 2016-01-01
categories: [Linux基础]
tags:
---
初步
# Install
 - [downloads](https://www.vagrantup.com/downloads.html)
`aria2c -c -x 10 https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb`
` sudo dpkg -i vagrant_1.9.3_x86_64.deb `

 - 配置代理
 Install proxyconf:

`vagrant plugin install vagrant-proxyconf`
Configure your Vagrantfile: vi $HOME/.vagrant.d/Vagrantfile
```
config.proxy.http     = "http://127.0.0.1:8087"
config.proxy.https    = "http://127.0.0.1:8087"
config.proxy.no_proxy = "localhost,127.0.0.1"
```
在官网https://www.vagrantup.com/ 下载对应平台的软件包安装. Vagrant不用来建立虚拟机, 因此

确保你安装有VirtualBox.

# 制作box
    1. 建虚拟机这种事对任何一个开发人员都是小意思. 这里主要注意几点就OK了. 这里主要使用Ubuntu发行版, 其他版本会有些许差异.
    2. 启动虚拟,并做如下配置:
    3. 请将用户名和密码都设置为vagrant, 毕竟之后的box会分发给第三者
    4. 安装ssh, 命令: sudo apt-get install openssh-server
    5. 修改root密码为vagrant,命令: sudo passwd root
    6. 设置vagrant用户sudo免密码, 建议在/etc/sudoers.d/目录 新建`vagrant`文件并写入`vagrant ALL=(ALL) NOPASSWD:ALL` | `echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant`
    7. 添加公钥到`~/.ssh/authorized_keys`文件. 可以使用自己的公钥, 也可以使用Vagrant公开的, 命令: `wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O ~/.ssh/authorized_keys`. 确保.ssh目录权限为0700和authorized_keys文件权限为0600. vagrant私钥: `https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant`
    8. 推荐安装虚拟机增强包guest additions package来实现文件共享, 点击安装增强包后, 命令: sudo mount /dev/cdrom /media/cdrom; cd /media/cdrom; sudo ./VBoxLinuxAdditions.sh, 可能要安装依赖sudo apt-get install linux-headers-generic build-essential dkms
    9. 配置软件源, 安装需要的软件, 更新系统设定虚拟机的端口转发, 图形设置:控制->设置->网络->端口转发,关键的两点是主机端口任意和虚拟机端口22

基本上, 以上就是主要操作了, 除了第1个是在VirtualBox建虚拟机时设定的, 第8条是在VirtualBox上设定虚拟机的参数, 其余全是在虚拟机内进行的. 这些都是标准设定, 你可以改变用户名和密码, 根用户密码, 以及公钥, 只是需要在项目目录的Vagrantfile文件进行相应的参数设定.

# 打包为 Box
  - 生成Base Box
  `vagrant package --base vmname --output /path/to/boxname.box`
      vmname是virtualbox虚拟机列表中的名字, 新建虚拟机时输入的名称,
      省略--output时默认在当前目录下生成.box文件. 命令可在任意目录下执行.

执行命令前最好先关闭虚拟机,就目前的情况看,虽然vagrant能自动ssh到虚拟机并执行关机命令,但在windows执行失败,不确定和平台有没有关系.
如果当前虚拟机本身是从Box解压生成的, 你安装了些软件, 更新了下系统, 反正是做出些改变, 可以省略--base vmname参数, 以将改动后的虚拟机重打包成box以分发.

  - 将box添加到全局环境中
`vagrant box add boxname boxurl ` 等效
`vagrant box add boxurl --name boxname`

此命令最好在box的生成目录下进行, 否则需要其完整路径.
boxurl随意, 唯一的用处是全局定位指定的box, 以方便解压生成虚拟机, 而不用指定box文件的完整路径.

1. `vagrant box add precise64 http://files.vagrantup.com/precise64.box`

# 生成虚拟机

新建项目目录并切换, 执行`vagrant init boxurl`命令. 生成.vagrant目录, 包含ssh到虚拟机的私钥, 以及Vagrantfile文件, 用于虚拟机的参数设定.

好了, 你现在从指定的box生成了一个新的虚拟机, 对这个虚拟机的所有操作都不会影响到box, 在不需要时完全可以删除.

以下命令是经常使用的:
```
vagrant up  # 开机
vagrant ssh  # 连接
vagrant halt  # 关机
vagrant suspend  # 相当于休眼
vagrant resume  # 恢复
vagrant destroy [-f] # 删除虚拟机
```
更多的命令

管理系统的box
```
vagrant box list查看全局box
vagrant box remove boxname移除box
vagrant box outdated检查当前项目使用的box是否有更新
vagrant box repackage NAME PROVIDER VERSION 重打包box到当前目录,其中3个参数由vagrant box list获取.是add解压的反过程
vagrant box update [--box boxname]更新box,但并不反应在当前项目的虚拟机上,需要destroy后再up
```
额外的说明

在windows平台,请确保ssh程序在path中,或者通过你喜欢的ssh client,如putty, xshell. 默认up时会建立主机2222端口到虚拟机22端口的映射, 并删除此前添加的公开公钥而使用随机生成的公钥, 而对应的私钥存储在当前项目目录的.vagrant\machines\default\virtualbox\private_key, 用户名为vagrant.

开启虚拟机后,并不显示虚拟机, 但其确实已运行, 打开virtualbox后可看到项目运行的虚拟机名,点击显示则可显示虚拟机. 或者说, 虚拟机默认以headless模式运行, 也就是不显示界面, 这是VirtualBox提供的功能.

就我个人理解来看, 实际上, 上述的功能都可以通过VboxManage命令来进行. Vagrant对虚拟机的管理, 要么通过VirtualBox提供的开发接口来实现, 要么能过ssh到虚拟机中来实现.

最后, Vagrant是用Ruby开发的.


## 修改默认的public同步文件夹至其他文件夹

打开Vagrantfile，找到

config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]

修改"."为自己的目录，然后vagrant up开启虚拟机，进入ect/apache2目录，配置vituralhost的directory，从public改为自定目录即可
## box镜像文件快速下载

box镜像文件动辄五六百MB，如果用Vagrant默认的下载方式，真的不知道下到啥时候，这里介绍一个『快一点』的下载方式：

    首先按照正常步骤，输入vagrant up之后会有一句指示当前下载box文件的url，例如

    ==> default: Adding box 'hashicorp/precise32' (v1.0.0) for provider: virtualbox

    default: Downloading: https://atlas.hashicorp.com/hashicorp/boxes/precise32/versions/1.0.0/providers/virtualbox.box

    此时我们ctrl+c强制停止当前进程，将url拷贝到迅雷或者别的下载工具中进行下载，下载完成后进入下载目录，打开命令行，输入（其中hashicorp/precise32为配置文件为box镜像起的名字）

    vagrant box add hashicorp/precise32

    Vagrant会自动对box镜像进行处理，此时我们再回到之前的Vagrant配置目录中，vagrant up启动，过不了一会儿就安装好了。
