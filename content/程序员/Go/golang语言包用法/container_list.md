---
title: golang中container/list包中的坑
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中container/list包中的坑](/chenbaoke/article/details/42782113)

golang中list包用法可以参看<http://blog.csdn.net/chenbaoke/article/details/42780895>

<span style="color:#FF0000">但是list包中大部分对于e \*Element进行操作的元素都可能会导致程序崩溃，其根本原因是e是一个Element类型的指针，当然其也可能为nil，但是golang中list包中函数没有对其进行是否为nil的检查，变默认其非nil进行操作，所以这种情况下，便可能出现程序崩溃</span>。

1.举个简单例子，Remove（）函数

``` go
package main

import (
    "container/list"
    "fmt"
)

func main() {
    l := list.New()
    l.PushBack(1)
    fmt.Println(l.Front().Value) //1
    value := l.Remove(l.Front())
    fmt.Println(value)            //1
    value1 := l.Remove(l.Front()) //panic: runtime error: invalid memory address or nil pointer dereference
    fmt.Println(value1)
}
```

从程序中可以直观的看出程序崩溃，原因是list中只有1个元素，但是要删除2个元素。但是再进一步查看一下原因，便会得出如下结果。

golang中Front()函数实现如下

``` go
func (l *List) Front() *Element {
    if l.len == 0 {
        return nil
    }
    return l.root.next
}
```

由此可见，当第一次删除之后。list的长度变为0，此时在调用l.Remove(l.Front()),其中l.Front()返回的是一个nil。

接下来再看golang中Remove（）函数实现，该函数并没有判定e是否为nil，变直接默认其为非nil，直接对其进行e.list或者e.Value取值操作。当e为nil时，这两个操作都将会造成程序崩溃，这也就是为什么上面程序会崩溃的原因。

``` go
func (l *List) Remove(e *Element) interface{} {
    if e.list == l {
        // if e.list == l, l must have been initialized when e was inserted
        // in l or l == nil (e is a zero Element) and l.remove will crash
        l.remove(e)
    }
    return e.Value
}
```

2.（l \*list）PushBackList（other \*list)该函数用于将other list中元素添加在l list的后面。基本实现思想是取出other中所有元素，将其顺次挂载在l列表中，但是golang中实现有问题，代码如下。

``` go
func (l *List) PushBackList(other *List) {
    l.lazyInit()
    for i, e := other.Len(), other.Front(); i > 0; i, e = i-1, e.Next() {
        l.insertValue(e.Value, l.root.prev)
    }
}
```

其具体思想是首先获取other的长度n，然后循环n次取出其元素将其插入l中。问题就出现在循环n次，如果在这个过程中other的元素变化的话，例如其中有些元素被删除了，这就导致e的指针可能为nil，此时再利用e.Value取值，程序便会崩溃。如下所示。

``` go
package main

import (
    "container/list"
    "runtime"
)

func main() {
    runtime.GOMAXPROCS(8)
    l := list.New()
    ls := list.New()
    for i := 0; i < 10000; i++ {
        ls.PushBack(i)
    }
    go ls.Remove(l.Back())
    l.PushBackList(ls) //invalid memory address or nil pointer dereference
}
```

如程序中所示，再讲ls中元素添加到l过程中，如果ls中元素减少，程序便会崩溃。原因如上面分析。

<span style="font-size:18px">建议：</span>

<span style="color:#FF0000">在golang中如果对与list的操作只有串行操作，则只需要注意检查元素指针是否为nil便可避免程序崩溃，如果程序中会并发处理list中元素，建议对list进行加写锁（全局锁），然后再操作。注意，读写锁无法保证并行处理list时程序的安全性。</span>
