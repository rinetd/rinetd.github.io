---

title: golang中container/ring包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中container/ring包用法](/chenbaoke/article/details/42782297)

ring包实现了环形链表的操作。

 
type Ring  //Ring类型代表环形链表的一个元素，同时也代表链表本身。环形链表没有头尾；指向环形链表任一元素的指针都可以作为整个环形链表看待。Ring零值是具有一个（Value字段为nil的）元素的链表。

    type Ring struct {
            Value interface{} // 供调用者使用，本包不会对该值进行操作
            // 包含未导出字段
    }

func New(n int) \*Ring //创建一个长度为n的环形链表
func (r \*Ring) Do(f func(interface{}))  //对链表中任意元素执行f操作，如果f改变了r，则该操作造成的后果是不可预期的。
func (r \*Ring) Len() int  //求环长度，返回环中元素数量
func (r \*Ring) Link(s \*Ring) \*Ring  //Link连接r和s，并返回r原本的后继元素r.Next()。r不能为空。

如果r和s指向同一个环形链表，则会删除掉r和s之间的元素，删掉的元素构成一个子链表，返回指向该子链表的指针（r的原后继元素）；如果没有删除元素，则仍然返回r的原后继元素，而不是nil。如果r和s指向不同的链表，将创建一个单独的链表，将s指向的链表插入r后面，返回s原最后一个元素后面的元素（即r的原后继元素）。

func (r \*Ring) Unlink(n int) \*Ring //删除链表中n % r.Len()个元素，从r.Next()开始删除。如果n % r.Len() == 0，不修改r。返回删除的元素构成的链表，r不能为空。

func (r \*Ring) Move(n int) \*Ring  //返回移动n个位置（n&gt;=0向前移动，n&lt;0向后移动）后的元素，r不能为空。
func (r \*Ring) Next() \*Ring  //获取当前元素的下个元素
func (r \*Ring) Prev() \*Ring //获取当前元素的上个元素
举例说明其用法：

``` go
package main

import (
    "container/ring"
    "fmt"
)

func main() {
    RingFunc()

}
func RingFunc() {
    r := ring.New(10) //初始长度10
    for i := 0; i < r.Len(); i++ {
        r.Value = i
        r = r.Next()
    }
    for i := 0; i < r.Len(); i++ {
        fmt.Println(r.Value)
        r = r.Next()
    }
    r = r.Move(6)
    fmt.Println(r.Value) //6
    r1 := r.Unlink(19)   //移除19%10=9个元素
    for i := 0; i < r1.Len(); i++ {
        fmt.Println(r1.Value)
        r1 = r1.Next()
    }
    fmt.Println(r.Len())  //10-9=1
    fmt.Println(r1.Len()) //9
}
```

参考：<https://golang.org/pkg/container/ring/>
