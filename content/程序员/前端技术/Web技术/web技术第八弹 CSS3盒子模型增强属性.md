---
title: web技术第八弹 CSS3盒子模型增强属性
date: 2016-03-20T09:55:58+08:00
update: 2016-01-01
categories:
tags:
---

web技术第八弹 CSS3盒子模型增强属性
==================================

<span class="spacer l">2016-04-06 17:59:06</span> <span class="spacer l spacer-2">1314浏览</span> <a href="#comment" class="spacer l">1评论</a>

      前一弹讲述了在CSS中，盒子模型的相关标准属性和布局简单应用。这一弹，我们会继续讲述盒子模型，并了解在新的CSS3标准下，盒子模型的背景和边框，都有哪些新的增强属性可以设置。
      ​ 首先，我们看下**盒子的页面重叠以及内部元素溢出的相关属性**。由于设定了盒子的浮动和定位，这样盒子可能会有重叠，见图。重叠相关的属性设置原则：
![图片描述](http://img.mukewang.com/5704dbf60001f61e03730242.png "web技术第八弹CSS3盒子模型增强属性_")
一、设定了static的盒子不受任何影响，总是在最底层
二、设定了其他position属性的盒子，可以再设定z-index属性。 属性值越高，就会越显示在顶部
三、z-index的属性不可继承
       由于盒子可能不够大（显式设置了宽度和高度的情况下），内部的元素可能会放不下。可以对其应用overflow等属性。如下：
一、 overflow属性:
       visible 默认值，溢出的部分会显示出来
       auto 内容会被修建，溢出的部分用滚动条移动显示
       hidden 溢出部分不显示
       scroll 溢出部分用滚动条显示
       inherit 继承父元素的属性

二、盒子的水平和垂直方向做溢出属性的设置。应用overflow-x和overflow-y (IE8以上支持）

三、对于设置了文本white-space为nowrap（文本不换行）的元素，设置text-overflow的属性，可以使尾部截断的部分显示出一个…的效果。注意写法：
              white-space : nowrap; ​
              text-overflow : ellipsis;
              -webkit-text-overflow : ellipsis;
              -o-text-overflow : ellipsis;
      
**盒子的宽度和高度，有对应的一些属性可以设置如下：**
![图片描述](http://img.mukewang.com/5704dc180001e4e807390234.png "web技术第八弹CSS3盒子模型增强属性_")
      这里还是要注意，CSS默认的宽度是指内容的宽度。如果指定了内外边距和边框而又要固定宽度的话，记得要用 box-sizing属性更改一下。

​        之前我们谈过，盒子的背景有一些基本属性：颜色、图片来源、重复、滚动和显示位置。在此基础上，CSS3对背景，做了一些新的增强属性设置。可以**在一个盒子里显示多个背景图片；整个盒子，可以设置阴影；之前默认的背景范围也可以做自定义**。见下面的图解：
![图片描述](http://img.mukewang.com/5704dc310001cd0507710546.png "web技术第八弹CSS3盒子模型增强属性_")
      此外，CSS3增加了对边框的高级设置。很多原先只能依赖于美工切图再放置的功能，可以用CSS3属性直接实现，例如**盒子边框的圆角设置和边框图片放置**。
![图片描述](http://img.mukewang.com/5704dc5b0001c1d507680547.png "web技术第八弹CSS3盒子模型增强属性_")
      了解了以上这些盒子模型的属性，大家就可以发动脑洞，在页面上做出各种复杂的盒子模块了。当然CSS3在具体的浏览器上的实现还有不完全一致或者支持的地方，主要注意几点：
一、很多CSS3的新属性，针对不同的浏览器要可能需要重复加上前缀分别书写。-webkit- ， -o- ，-moz- ， -ms
二、强烈推荐 www.caniuse.com 这个网站做具体属性值的浏览器版本兼容预审，输入属性，他会很详细的列出最新的浏览器兼容情况作为参考。例如我输入border-image 就能知道IE需要从IE11才开始支持。
![图片描述](http://img.mukewang.com/5704dc8d000152e013470591.png "web技术第八弹CSS3盒子模型增强属性_")
       下一弹，我们来看看，在CSS3中增加了那几种新的盒子模型以及他们在页面布局上是如何使用的。也许**是时候该抛弃float和clear方法了。**

<span class="l">相关标签：</span> <a href="/article/tag/5" class="cat l">Html/CSS</a> <a href="/article/tag/14" class="cat l">Html5</a> <a href="/article/tag/25" class="cat l">CSS3</a>

<span class="icon-thumb_o"></span>

<span class="num">15</span> <span class="person">人</span>推荐

<span>分享即可 +</span>**1积分** <span class="rule-arrow"></span>

-   <a href="#" class="bds_weixin icon-nav icon-share-weichat" title="分享到微信"></a> <a href="#" class="bds_tsina icon-nav icon-share-weibo" title="分享到新浪微博"></a> <a href="#" class="bds_qzone icon-nav icon-share-qq" title="分享到QQ空间"></a>

<span id="js-follow" class="dc-follow l" data-id="6265"> <span>收藏</span> </span>

<span><img src="http://img.mukewang.com/images/avatar_default.png" width="40" /></span>

请登录后，发表评论
评论（Enter+Ctrl）

热门评论

评论加载中...

全部评论<span class="comment-num">**条</span>

评论加载中...

<a href="/u/438321/articles" class="l" title="键盘大官人"><img src="http://img.mukewang.com/56cf2a6d0001e87f01790182-100-100.jpg" /></a>

<a href="/u/438321/articles" class="nick" title="键盘大官人">键盘大官人</a>

<span class="user-job">产品经理</span> <span class="user-desc"> 做懂技术的产品经理，做最懂营销的技术开发 </span>
<a href="/u/438321/articles" class="article-num r-bor l"><span></span>篇手记</a> <a href="/u/438321/articles?type=praise" class="article-recom l"><span></span>推荐</a>

作者的热门手记
--------------

-   [](/article/5129 "浅谈计算机开发技术人员的基础知识储备")

    ### 浅谈计算机开发技术人员的基础知识储备

    <span class="spacer l">6223浏览</span> <span class="spacer l spacer-2">141推荐</span> <span class="spacer l" href="">19评论</span>

-   [](/article/5059 "【web应用技术第二弹】 打开页面时网络发生的事情")

    ### 【web应用技术第二弹】 打开页面时网络发生的事情

    <span class="spacer l">1980浏览</span> <span class="spacer l spacer-2">30推荐</span> <span class="spacer l" href="">8评论</span>

-   [](/article/5991 "web技术第七弹  CSS盒子模型及布局应用")

    ### web技术第七弹 CSS盒子模型及布局应用

    <span class="spacer l">1377浏览</span> <span class="spacer l spacer-2">32推荐</span> <span class="spacer l" href="">3评论</span>

-   [](/article/5057 "【web技术入门第一弹 】互联网、电脑和浏览器")

    ### 【web技术入门第一弹 】互联网、电脑和浏览器

    <span class="spacer l">1501浏览</span> <span class="spacer l spacer-2">29推荐</span> <span class="spacer l" href="">1评论</span>

-   [](/article/5061 "web技术入门第三弹  页面开发技术基础（一）")

    ### web技术入门第三弹 页面开发技术基础（一）

    <span class="spacer l">1754浏览</span> <span class="spacer l spacer-2">19推荐</span> <span class="spacer l" href="">5评论</span>

<a href="javascript:;" class="followus-weixin" title="微信"></a>

<a href="http://weibo.com/u/3306361973" class="followus-weibo" title="新浪微博"></a> <a href="http://user.qzone.qq.com/1059809142/" class="followus-qzone" title="QQ空间"></a>

-   [网站首页](http://www.imooc.com/)
-   [企业合作](/about/cooperate "企业合作")
-   [人才招聘](/about/job)
-   [联系我们](/about/contact)
-   [合作专区](/corp/index)
-   [关于我们](/about/us)
-   [讲师招募](/about/recruit)
-   [常见问题](/about/faq)
-   [意见反馈](/user/feedback)
-   [友情链接](/about/friendly)

Copyright © 2016 imooc.com All Rights Reserved | 京ICP备 13046642号-2

<a href="/user/feedback" class="elevator-msg" title="意见反馈"><em></em></a> <a href="javascript:" class="elevator-app" title="app下载"><em></em></a>

<a href="javascript:" id="js-elevator-weixin" class="elevator-weixin no-goto" title="官方微信"><em></em></a>

<a href="javascript:void(0)" id="backTop" class="elevator-top no-goto" title="返回顶部"><em></em></a>
