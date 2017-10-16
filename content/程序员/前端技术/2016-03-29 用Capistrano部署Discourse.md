---
title: 用Capistrano部署Discourse
date: 2016-03-29T20:57:24+08:00
update: 2016-01-01
categories:
tags: [Capistrano,Discourse]
---
Discourse是什么

Discourse6是最新最潮最酷的开源论坛软件（本站就是它的一个实例），由Stack Overflow的联合创始人Jeff Atwood创建。Jeff无法忍受现有的论坛软件——他想要一个更加社会化（civilized）、面向移动终端（mobile），并且使用起来更方便、简洁的论坛，于是就创造了Discourse。关于它的更多介绍，请参考Discourse官网3。
为什么要用Capistrano部署

Discourse的官方推荐&支持的部署方式是使用Docker的。其目在于简化、傻瓜化部署——用户根本不必了解Ruby、Ruby on Rails（没错Discourse是一个RoR程序）以及PostgreSQL、Redis、Sidekiq这一些列名词的意义及其背后需要安装、配置的软件，只要几个简单的命令，就能用Docker部署一个配置好的image！

听上去不错，不过由于 墙 的存在，Ruby Gems（Ruby的packages）是没法正常下载安装的——虽然你可以使用Gems镜像，但那意味着你需要手工修改Docker image的配置或者模版等等；另一方面，官方的Docker image把数据库、缓存服务器、Web服务器等等全部集成在一个image内，这可能不够scalable——你可能想要在一群服务器上部署一个具有负载均衡（LB）和高可用性（HA）的Discourse，或者是使用外部的数据库／缓存服务而不是自己搭建。如果是这样，Capistrano可以帮上忙。

Capistrano1是Ruby Web程序的流行的部署工具，它强大、灵活——既可以用来部署具有高可用性（HA）和负载均衡（LB）的服务器集群，也可以把数据库、缓存、Web和App服务等等全部部署在一台主机上；另外，它与Bundler（A Ruby package manager & installer）配合使用可以在 部署时 轻松解决Ruby Gems的下载问题。
开始之前

在开始之前，我必须要说明：相对于Docker方式，使用Capistrano对于用户有较高的要求——你必须对Ruby、RVM（本文假定Ruby都是通过RVM安装的）和Ruby on Rails有一些经验，知道如何安装Ruby Gems以及Bundler如何根据Gemfile管理Gems，你还要能够比较熟练地使用Google搜索解决一些诸如“如何运行这个Linux命令”之类的问题，当然Git也是必须的。如果你根本没有接触过Ruby或者Rails，我建议你先对照着Rails Guide练一遍，然后再回来。
干货

Capistrano的部署文件都在这里
https://github.com/coin8086/discourse-capistrano6
如果你是一个有经验的Rails开发者，我想你已经知道八成该怎么做了。简单地说，四步：

    下载Discourse代码
    加入Capistrano部署文件
    初次部署之前的工作
    部署

下面对每一步做详细介绍。
下载Discourse代码

我们要从官方的Git repo clone代码到本地，做一些编辑，然后保存修改到自己的Git repo——这个repo必须是你要部署的主机可以访问的repo，所以一般来说它是一个remote repo——你可以利用GitHub，也可以在自己的某一台服务器上做一个私有的Git repo，这很简单。这样对本地代码而言我们就有了2个remote repo：将来我们升级Discourse时需要从官方repo fetch，然后打上我们将要做的patch，push到我们自己的remote repo，然后指示Capistrano从那里取得代码部署。

从官方repo clone:

    git clone git@github.com:discourse/discourse.git

注意：

    master是最新的开发分支，不是我们要部署的
    可以部署的分支是：stable, beta和tests-passed，稳定性依次递减，但是代码更新依次递增。你可以选择任何一个分支，在这里我们选beta

加入Capistrano部署文件

需要的文件都在这：
https://github.com/coin8086/discourse-capistrano6

你要在本地新建一个Git分支（在stable, beta或者tests-passed的基础上），然后把上面的部署文件手工patch进去：

    把discourse-capistrano的Gemfile内容添加到discourse的Gemfile里
    把discourse-capistrano的Capfile文件添加到discourse根目录下
    把discourse-capistrano的config目录的内容合并到discourse的config目录下

然后你需要手工修改一下config/deploy.rb和config/deploy/production.rb，指定你的部署参数：

    对于config/deploy.rb，你至少要指定“repo_url”——就是上文提到的你存放修改过的Discourse的repo
    对于config/deploy/production.rb，你至少要指定一个server

以上文件中有充分的注释和示例，你只要修改必要的参数就好。

然后安装Gems：

    bundle install

然后把所有Gems保存到vendor/cache目录下（此步骤可选）：

    bundle package

之所以这么做是因为我们想要在部署时从这个目录下安装所有的Gems，而不是从网上下载，因为 墙 会使所有的Gems安装失败——我们在本地开发时可以比较方便地通过VPN等工具下载好这些Gems，然后保存。注意：如果你选择这么做，你应该保证你的开发环境和部署环境一致——使用相同的OS以及Ruby版本。

最后別忘了把所有的修改，连同vendor/cache下的Gems，一并保存到你的Git repo——就是上面的repo_url所指定的那个。
初次部署之前的工作

好了，现在所有Capistrano部署脚本相关的工作已经完成了。但是我们还少一些东西，比如数据库，缓存服务等等。没有这些东西，部署的Discourse不会工作（如果没有数据库则部署不会成功）。在这里你可以选择自己搭建数据库，也可以利用一些现成的数据库服务（如阿里云数据库等等），缓存服务也是一样。下面的列表是你需要准备的东西：

    Web/App服务器：Apache/Nginx ＋ Fusion Passenger /Unicorn /...任何支持Ruby Rack的服务器都可以
    PostgreSQL数据库（参考PostgreSQL安装与管理速成指南）
    Redis缓存服务（参考Redis缓存服务安装与管理速成指南）
    Sidekiq后台处理服务
    以及下面这些软件包：
        ImageMagick
        libxml2, libpq-dev, g++, gifsicle, libjpeg-progs, make

除此以外，你还需要SMTP服务——Discourse有很多邮件通知，包括注册邮件。如果你没有SMTP，那么Discourse就难以工作。

当你准备好了以上这些，你要告诉Discourse，通过config/discourse.conf。注意：你可以直接修改这个文件，然后保存到你的 私有 repo下；如果你使用 公开的 repo，比如GitHub，你应该把这个文件保存在其它地方，然后在部署时使用它——discourse-capistrano假定你把它保存在需要部署的主机的~/discourse.conf，脚本会在每次部署时把它链接到config/discourse.conf，如果这不是你想要的，注释掉相关的Capistrano代码（在config/deploy.rb中）。
部署

假设你的本地Git分支叫my-1.6.0-beta1——你已经加入了部署脚本并且把它push到了一个同名的remote repo下（就是你在repo_url里指定的那个），你只需在本地执行：

    bundle exec cap production deploy

命令会提示你输入／确认要部署的remote分支名称，回车确认。

注意：第一次部署会失败，因为数据库还没有初始化——discourse-capistrano的脚本缺省不会初始化数据库，否则以后每次升级数据库都会被重置。第一次失败以后，我们要登录待部署的主机，手工执行一下数据库初始化的工作——为什么不先执行一次初始化然后再部署？因为我们要让代码和Gems都更新完毕后才能利用Ruby脚本初始化，第一次部署虽然失败了，但是代码和Gems都已经安装完毕，如果失败不是因为其它原因的话。

代码会部署在config/deploy.rb的deploy_to所指示的位置，登录部署主机进入这个目录，找到releases子目录，最新的代码就在其中（唯一的）的一个子目录里，进入这里。然后执行数据库初始化：

    RAILS_ENV=production bundle exec rake db:create db:migrate

之后在本地再重新执行一次部署命令，大功告成！
部署之后的话

    如果App服务器使用了Fusion Passenger，你需要阅读一下 https://github.com/SamSaffron/message_bus 的文档，设置passenger_force_max_concurrent_requests_per_process（Nginx）或者PassengerForceMaxConcurrentRequestsPerProcess（Apache）否则网站性能会随着访问人数的增加而显著下降
    强烈推荐你使用CDN，这也是官方的建议

Discourse十分强大，也十分复杂——超过12万行Ruby代码以及15万行JavaScript，是我见过的最复杂的Rails程序——因此部署过程也相对复杂一些。所以官方推荐&支持的方式是Docker——手工部署如Capistrano一般人确实hold不住（满满地自豪感:sunglasses::sweat_smile:）。但我之所以选择一条困难的路，其实首先是因为懒——我不了解Docker，也没有多少时间（其实是不想:joy:）去学习它；其次是因为我不想引入额外的复杂性——Discourse本身已经够复杂了，容器带来的额外的复杂性可能会对整个系统的稳定性产生影响，而一旦发生影响，问题的定位也会带着这一层额外的复杂性，这很麻烦——虽然这只是一种潜在的可能性，但IT界有句名言说“只要有可能就一定会发生”，我想想还是不要让它发生的好。
