---
title: Meteor
date: 2016-03-29T20:57:24+08:00
update: 2016-01-01
categories:
tags: [Meteor]
---


从 Meteor 1.2 开始，这三个框架都是官方支持的了。如果你开始一个新的 Meteor 项目，还没有确定用什么前端框架的时候，估计会遇到这个问题。
Blaze

Blaze 是这三个里最简单的，特别是用过 Handlebar 的话。几乎没有什么 learning curve，直观、容易上手。它的问题是除非你只用 Meteor，否则当你改用别的后端框架时，你得使用别的前端框架，所以不如另外两个应用广泛。技能市场更小。
Angular vs React

其实这两者不好放在一起比较。因为 React 只涉及 View，而 Angular 是一个完整的前端框架。这里只是比较他们作为 View 的场景。

我曾经是一个 React 黑。因为 React 咋一看把啥都混在一起写。HTML，CSS 和 JavaScript 混在一个文件里，搞点语法糖，取名叫 JSX。还看到有人说“ JSX：让人无法想像的历史倒退，W3C通过20年将 “布局、样式、数据” 三者分离，Facebook只花了几个月就能合并到一起了。” 当时觉得无比赞同。也有部分原因是自己已经对 Angular 投入了很多时间学习使用。人都是这样，对你用顺手了并且擅长的工具就会更喜欢，即使有更好的新工具出来。

后来遇到好多写了多年前端的人几乎都是一致推荐 React。JSX 虽然刚开始看起来恶心，但还真是起到解耦和封装的作用，比只是简单地把文件分开的解耦更高级，达到逻辑了上的封装。而 Angular，更符合后端转前端的人的思维，不同语言分开，大而全的 framework，脏检查，双向绑定等等，都是老思维了。难怪 React 一出来基本就是压倒性的受欢迎。

React 设计的理念肯定是超过 Angular 1.0 的。React 的组件化，单向数据流和 Virtual Dom 是前端演化的方向。据说 Angular 2.0 也会有这些。但是 Angular 2.0 居然选择 TypeScript。个人认为这是一步臭棋，把 learning curve 又提高了。不知道他们团队怎么想的，估计以为 ES6/7 遥遥无期，和微软合作时作为交换筹码？

Meteor 可以作为 React 的一种 Flux 实现，他们两者的 Reactive 特性是很匹配的。Angular 1.0 虽然号称也可以做到，但是实现并不理想。比如在异步时你得自己使用 $digest 来手动更新；脏检查机制给 reactivity 带来性能上的问题等等。
结论

如果不是维护历史项目，首选 React。要快速上手 Meteor 可以先使用 Blaze。

[1](https://cnodejs.org/topic/563f0e218e90ab7c391e9f5f)
