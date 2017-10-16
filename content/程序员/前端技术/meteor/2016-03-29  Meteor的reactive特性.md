---
title: Meteor
date: 2016-03-29T20:57:24+08:00
update: 2016-01-01
categories:
tags: [Meteor]
---

Principles of Meteor

Meteor 是一个实时 full stack JavaScript 框架。Reactivity 是它的一个非常重要的特点。官网上列出了 Meteor 的7大原则或者说是特点:

    Data on the Wire. Meteor 不发 HTML，服务器端只负责发送数据，让客户端来渲染

    One Language. 前后端都是 JavaScript 语言

    Database Everywhere. 前后端都可以直接创建存取修改数据库里的数据，并且安全

    Latency Compensation. Meteor 在前端提前获取数据并模拟数据模型，使其看起来像是从服务器端立即返回了数据

    Full Stack Reactivity. 实时相应是 Meteor 的缺省配置。在所有层面，从数据库到模板，都会在必要时自动更新

    Embrace the Ecosystem. Meteor 完全开源并集成了很多现有的开源工具和框架。例如 Angular，React。Meteor 有自己的 AtmosphereJS 包下载管理应用，也可直接使用 NPM (目前是非官方支持)

    Simplicity Equals Productivity. Meteor 简单易上手，API 简介优美

什么是 Reactivity

可能还有人不理解什么是 Reactivity。简单来说 Reactivity 就是数据传递的一种模式，特别是如何传递数据的变化。一种编程语言或者框架如果能够自动传递数据的变化，不需要用户再编写代码去更新使用到的变量，那么我们就说它是 reactive 的。

比如 Meteor 和 facebook 的 React 框架就是这么处理数据变化的，不需要额外的代码。如果 reactive 的变量发生了变化，那么框架会自动再次运行使用到这个变量且具有 reactive 特性的代码段 - 这里引入了一个 reactive computation/context (程序的上下文，一般是一个函数) 概念。如果配合使用 React，React 会自动在 virtual dom 上比较，然后只渲染更新了的那一小部分，而不是再把所有涉及到的无论变化与否的 view 都再渲染一次。这样不用自己再写代码来指定更新的地方，代码就更容易维护，前端的开发和运行效率都有提高。

举个例子。a = b + c，如果 b 是 1，c 是 2，那么 a 的值就是 3。在不是 reactive 的函数里，如果 b 的值变为 4，什么事情都不会发生，你得自己动手去触发需要更新的地方；而在 reactive 的函数里，a 的值会自动变为 6。凡是在 Template 里引用 a 的地方都会变为 6，而不再需要手动更新。就是 b 和 c 改变了，这个 reactive 函数会被自动调用，再次计算得出 a 的新值 6。这样代码会少很多，逻辑也更简单，特别是涉及到需要再次渲染 view 的时候。

最后注意，要具备 reactivity，必须得满足两个条件。第一是要有一个 reactive 的数据源，第二就是这个数据源要在具有 reactive 特性的上下文里被使用。这样可以避免一些不必要的副作用，可以选择不用 reactivity，如果不需要的话。
Reactivity of Meteor

Meteor server 端没有 reactivity，只有 client 端才有。
Meteor 数据库和模板都能自动更新，可以使用 facebook 的 React 使前端组件化，代码会更好维护。可以把 Meteor 看做是 flux 的一种实现，类似 redux 之类的。
Reactivity 可以避免使用很多回调函数。
Computation

下面是 Meteor 里自带的具有 reactive computation 特性的函数:

    Templates
    Tracker.autorun
    Template.autorun
    Blaze.render Bleze。renderWithData

不过如果使用 React 的话，那就是 mixins: [ReactMeteorData] 这个 mixin 和
getMeteorData() 函数一起使用。
变量

下面介绍几种 Meteor 常用的 reactive 变量。

    MongoDB

Meteor 里用得最多的 reactive 变量来源当然是 Mongodb 的 collections。

    Session

Session是 Meteor 提供的一个只在前端使用的全局 reactive 数据源。
只要 Session.set 被调用并且改变了原值，那么对应的 Session.get 所在的模板或者 reactive 函数就会被自动重新运行。

例如官方给的这个例子:

Tracker.autorun(function () {
  Meteor.subscribe("chat-history", {room: Session.get("currentRoomId")});
});

// 下面这条语句会导致上面的 Tracker.autorun 函数再次被执行
// chat-history 的注册也转移到了 home
Session.set("currentRoomId", "home");

注意 Session.get 和 Session.equals 的文档里有这句 “…, invalidate the computation the next time the variable changes to or from the value.”, 这句话有点让人难以理解。它的意思是这两个 API 会使其所在的 reactive computation 失效，然后自动再运算。其实就是调用了 Session.set 且改变了原值之后，它所对应的 get 和 equals 所在的 reactive computation 函数会被重新运算一次。

还有如果遇到以下情况:

(1) Session.get("key") === value
(2) Session.equals("key", value)

(2) 比 (1) 要好，可以避免不必要的重新渲染。细节见文档。

但是如果要比较 object 和 array，不能使用 Session.equals。建议使用 underscore 的
_ .isEqual(Session.get(key), value).

另外如果使用 Session.get(), 它返回的是一个克隆值，所以改变返回值没有任何 reactive 效果。

Session 因为是全局的，支持 hot code push。但是不支持用户 refresh page，如果 refresh，值会回到初始值。

    ReactiveVar/ReactiveDict

这两个未来会合并到后者 ReactiveDict。主要是用于本地变量。

    Meteor.status

不使用回调函数就可以实时获得客户端和服务器端连接的变化。

    Meteor.user / Meteor.userId

如果没有登录的话，值为 null。

    Meteor.loggingIn

获得登录状态变化，用于显示登录动画。

    The ready() method on a subscription handle

类似 subscription 的一个 callback 函数。在ready() 里，Meteor 会自动处理 unsubscription 和回收 subscription 的 handle。所以可以重复 subscribe 同一个数据源而不用自己 unsubscribe,  也避免了重复 subscribe 产生数据冲突。Meteor 还能自动判断已被 unsubscribe 过的数据，如果再次 subscribe 就不会产生 client server 间的重复通信操作。
高级用法

你也可以使用 Deps 和 Tracker package 创建自己的 reactive 数据源和 computation。不过这里就不介绍了。
Meteor 的坑:

    目前 NPM 没有官方支持。不过第三方的支持也做得还不错。
    很多时候必须得按照 Meteor 的方式来编程。如果是老手可能会觉得掣肘。但是反过来，我认为新手可以学到好的编程模式。
    大而全的框架更新慢，特别是在前端这个进化快速到几乎变态的环境下。很多新的东西出来不一定马上用得上，不过如果是真的有用，总会有第三方集成支持。
    数据库只能选 MongoDB。不过有 PostgreSQL 的第三方支持。据说其他数据库支持快了。
    如果不读文档没有理解 Meteor 的机制会感觉黑魔法有点多。
