---
title: golang中net/mail包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中net/mail包用法](/chenbaoke/article/details/42782615)

net/mail包实现了解析邮件消息的功能

本包大部分都遵守[RFC 5322](http://tools.ietf.org/html/rfc5322)规定的语法，值得注意的区别是：

旧格式地址和嵌入远端信息的地址不会被解析
组地址不会被解析
不支持全部的间隔符（CFWS语法元素），如分属两行的地址

<span style="font-size:18px">函数：</span>

func ParseAddressList(list string) (\[\]\*Address, error)//该函数将给定的字符形式表示的地址list解析成标准的地址列表。
type Address //该结构体代表一个独立的mail地址，一个地址："Barry Gibbs &lt;bg@example.com&gt;"经过地址解析后会变成Address{Name: "Barry Gibbs", Address: "bg@example.com"}。

    type Address struct {
            Name    string // Proper name; may be empty.
            Address string // user@domain
    }

func ParseAddress(address string) (\*Address, error) //解析一个独立的RFC 5322地址，地址形如：“Barry Gibbs &lt;bg@example.com&gt;”
func (a \*Address) String() string //将a代表的地址表示为合法的RFC 5322地址字符串。如果Name字段包含非ASCII字符将根据RFC 2047转义。

type Header //Header代表在一个邮件消息头部的key-value对。

    type Header map[string][]string

func (h Header) AddressList(key string) (\[\]\*Address, error)//将键key对应的值（字符串）作为邮箱地址列表解析并返回
func (h Header) Date() (time.Time, error)//获取header中Date的值
func (h Header) Get(key string) string//返回在header中指定分配给指定key的第一个值。如果该key没有值的话，返回“”
type Message//表示一个解析后的邮件消息

    type Message struct {
            Header Header
            Body   io.Reader
    }

func ReadMessage(r io.Reader) (msg \*Message, err error) //从r读取一个邮件，会解析邮件头域，消息主体可以从r/msg.Body中读取。

举例说明用法。

参考：<http://golang.org/pkg/net/mail/>
