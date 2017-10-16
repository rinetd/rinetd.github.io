---
title: android中解析JSON
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags:
---
[怎样在android中解析JSON ](http://blog.csdn.net/dadoneo/article/details/6233285)
Jackson 是一个将java对象转换成JSON与JSON转化java类的类库。Gson 是解决这个问题的流行方案，然而我们发现Jackson更高效,因为它支持替代的方法处理JSON:流、内存树模型,和传统JSON-POJO数据绑定。不过，请记住， Jsonkson库比起GSON更大，所以根据你的情况选择，你可能选择GSON来避免APP 65k个方法限制。其它选择: Json-smart and Boon JSON
