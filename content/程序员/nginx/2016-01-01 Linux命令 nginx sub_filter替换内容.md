---
title: Nginx替换文本内容sub_filter
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---

首先是示例：

location / {
  sub_filter      </head>   '</head><script language="javascript" src="x.js"></script>';
  sub_filter_once on;
  sub_filter_types text/html;
}

解释：

sub_filter 一行代码前面是需要替换的内容，后面单引号内是替换成的内容。

sub_filter_once 意思是只查找并替换一次。on是开启此功能，off是关闭——默认值是on。

sub_filter_types 一行意思是选定查找替换文件类型为文本型。也可以不加此行，因为默认只查找文本型文件。

sub_filter模块可以用在http, server, location模块中。主要作用就是查找替换文件字符。

比较实用的例子就是，如果我们用模板生成网站的时候，因为疏漏或者别的原因造成代码不如意，但是此时因为文件数量巨大，不方便全部重新生成，那么这个时候我们就可以用此模块来暂时实现纠错。另一方面，我们也可以利用这个实现服务器端文字过滤的效果——至于原因，你懂的。

subs_filter

   语法;subs_filter 源字段串 目标字段串 [gior]

   默认:无

   适用区域：http, server, location

   subs_filter指令允许在nginx响应输出内容时替换源字段串（正则或固定）为目标字符串。第三个标志含意如下：
g(默认): 替换所有匹配的字段串。（默认可省略）
  i: 执行区分大小写的匹配。
  o: 仅替换首个匹配字符串。
  r: 使用正则替换模式，默认是固定模式。

# sub_filter 由于 gzip 不能插入内容
Nginx 的 sub_filter 模块（http://wiki.nginx.org/HttpSubModule）来替换返回文件中的文本。可以用来不修改应用程序的同时，为文件增加一些监控标志，或增加额外的 javascript 用于数据统计等，使用方式如下：
```
location / {
  sub_filter      &lt;/head&gt;
    '&lt;/head&gt;&lt;script language=&quot;javascript&quot; src=&quot;$script&quot;&gt;&lt;/script&gt;';
  sub_filter_once on;
}
```

当然方式可以更灵活，比如插入 google analytics 代码等等。

但如果后端返回的文件是已经 gzip 压缩过的文件，因为需要解压缩，然后再压缩，sub_filter 不支持gzip。为了避免此种情况，我们需要后端不压缩文件，做法就是去除 HTTP 请求头中的 压缩头，指导后端不压缩：

`proxy_set_header Accept-Encoding "";`

当然，为了保证到浏览器的数据是压缩的，sub_filter 前端还是需要配置 gzip on 的
