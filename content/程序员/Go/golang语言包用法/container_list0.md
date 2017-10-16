---
title: golang中container/list包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中container/list包用法](/chenbaoke/article/details/42780895)

list是一个双向链表。该结构具有链表的所有功能。
type Element

    type Element struct {

            Value interface{}   //在元素中存储的值
    }

func (e \*Element) Next() \*Element  //返回该元素的下一个元素，如果没有下一个元素则返回nil
func (e \*Element) Prev() \*Element//返回该元素的前一个元素，如果没有前一个元素则返回nil。

type List
func New() \*List //返回一个初始化的list
func (l \*List) Back() \*Element //获取list l的最后一个元素
func (l \*List) Front() \*Element //获取list l的第一个元素
<span style="color:#FF0000">func (l \*List) Init() \*List  //list l初始化或者清除list l</span>
func (l \*List) InsertAfter(v interface{}, mark \*Element) \*Element  //在list l中元素mark之后插入一个值为v的元素，并返回该元素，如果mark不是list中元素，则list不改变。
func (l \*List) InsertBefore(v interface{}, mark \*Element) \*Element//在list l中元素mark之前插入一个值为v的元素，并返回该元素，如果mark不是list中元素，则list不改变。
func (l \*List) Len() int //获取list l的长度
func (l \*List) MoveAfter(e, mark \*Element)  //将元素e移动到元素mark之后，如果元素e或者mark不属于list l，或者e==mark，则list l不改变。
func (l \*List) MoveBefore(e, mark \*Element)//将元素e移动到元素mark之前，如果元素e或者mark不属于list l，或者e==mark，则list l不改变。
func (l \*List) MoveToBack(e \*Element)//将元素e移动到list l的末尾，如果e不属于list l，则list不改变。
func (l \*List) MoveToFront(e \*Element)//将元素e移动到list l的首部，如果e不属于list l，则list不改变。
func (l \*List) PushBack(v interface{}) \*Element//在list l的末尾插入值为v的元素，并返回该元素。
func (l \*List) PushBackList(other \*List)//在list l的尾部插入另外一个list，其中l和other可以相等。
func (l \*List) PushFront(v interface{}) \*Element//在list l的首部插入值为v的元素，并返回该元素。
func (l \*List) PushFrontList(other \*List)//在list l的首部插入另外一个list，其中l和other可以相等。
func (l \*List) Remove(e \*Element) interface{}//如果元素e属于list l，将其从list中删除，并返回元素e的值。

举例说明其用法。

``` go
package main

import (
    "container/list"
    "fmt"
)

func main() {
    l := list.New() //创建一个新的list
    for i := 0; i < 5; i++ {
        l.PushBack(i)
    }
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value) //输出list的值,01234
    }
    fmt.Println("")
    fmt.Println(l.Front().Value) //输出首部元素的值,0
    fmt.Println(l.Back().Value)  //输出尾部元素的值,4
    l.InsertAfter(6, l.Front())  //首部元素之后插入一个值为10的元素
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value) //输出list的值,061234
    }
    fmt.Println("")
    l.MoveBefore(l.Front().Next(), l.Front()) //首部两个元素位置互换
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value) //输出list的值,601234
    }
    fmt.Println("")
    l.MoveToFront(l.Back()) //将尾部元素移动到首部
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value) //输出list的值,460123
    }
    fmt.Println("")
    l2 := list.New()
    l2.PushBackList(l) //将l中元素放在l2的末尾
    for e := l2.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value) //输出l2的值,460123
    }
    fmt.Println("")
    <span style="color:#FF0000;">l.Init()           //清空l</span>
    fmt.Print(l.Len()) //0
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value) //输出list的值,无内容
    }

}
```
