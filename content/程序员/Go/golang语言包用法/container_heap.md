---
title: golang中container/heap包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中container/heap包用法](/chenbaoke/article/details/42782305)

heap包对任意实现了heap接口的类型提供堆操作。（小根）堆是具有“每个节点都是以其为根的子树中最小值”属性的树。树的最小元素在根部，为index 0.

heap是常用的实现优先队列的方法。要创建一个优先队列，实现一个具有使用（负的）优先级作为比较的依据的Less方法的Heap接口，如此一来可用Push添加项目而用Pop取出队列最高优先级的项目。

type Interface

```
type Interface interface {
    sort.Interface
    Push(x interface{}) // add x as element Len()
    Pop() interface{}   // remove and return element Len() - 1.
}
```

可以看出，这个堆结构继承自sort.Interface, 而sort.Interface，需要实现三个方法：Len() int /   Less(i, j int) bool  /  Swap(i, j int) 再加上堆接口定义的两个方法：Push(x interface{})   /  Pop() interface{}。故只要实现了这五个方法，变定义了一个堆。

任何实现了本接口的类型都可以用于构建最小堆。最小堆可以通过heap.Init建立，数据是递增顺序或者空的话也是最小堆。最小堆的约束条件是：

    !h.Less(j, i) for 0 <= i < h.Len() and 2*i+1 <= j <= 2*i+2 and j < h.Len()

注意接口的Push和Pop方法是供heap包调用的，请使用heap.Push和heap.Pop来向一个堆添加或者删除元素。
func Fix(h Interface, i int)  //  在修改第i个元素后，调用本函数修复堆，比删除第i个元素后插入新元素更有效率。复杂度O(log(n))，其中n等于h.Len()。
func Init(h Interface)  //初始化一个堆。一个堆在使用任何堆操作之前应先初始化。Init函数对于堆的约束性是幂等的（多次执行无意义），并可能在任何时候堆的约束性被破坏时被调用。本函数复杂度为O(n)，其中n等于h.Len()。
func Pop(h Interface) interface{}  //删除并返回堆h中的最小元素（不影响约束性）。复杂度O(log(n))，其中n等于h.Len()。该函数等价于Remove(h, 0)。
func Push(h Interface, x interface{})  //向堆h中插入元素x，并保持堆的约束性。复杂度O(log(n))，其中n等于h.Len()。
func Remove(h Interface, i int) interface{}  //删除堆中的第i个元素，并保持堆的约束性。复杂度O(log(n))，其中n等于h.Len()。

举例说明其用法：

``` go
package main

import (
    "container/heap"
    "fmt"
)

// An IntHeap is a min-heap of ints.
type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *IntHeap) Push(x interface{}) {
    // Push and Pop use pointer receivers because they modify the slice's length,
    // not just its contents.
    *h = append(*h, x.(int))
}

func (h *IntHeap) Pop() interface{} {
    old := *h
    n := len(old)
    x := old[n-1]
    *h = old[0 : n-1]
    return x
}

// This example inserts several ints into an IntHeap, checks the minimum,
// and removes them in order of priority.
func main() {
    h := &IntHeap{2, 1, 5, 100, 3, 6, 4, 5}
    heap.Init(h)
    heap.Push(h, 3)
    heap.Fix(h, 3)
    fmt.Printf("minimum: %d\n", (*h)[0])
    for h.Len() > 0 {
        fmt.Printf("%d ", heap.Pop(h))
    }

}
```

利用heap创建一个优先级队列

``` go
// This example demonstrates a priority queue built using the heap interface.
package main

import (
    "container/heap"
    "fmt"
)

// An Item is something we manage in a priority queue.
type Item struct {
    value    string // The value of the item; arbitrary.
    priority int    // The priority of the item in the queue.
    // The index is needed by update and is maintained by the heap.Interface methods.
    index int // The index of the item in the heap.
}

// A PriorityQueue implements heap.Interface and holds Items.
type PriorityQueue []*Item

func (pq PriorityQueue) Len() int { return len(pq) }

func (pq PriorityQueue) Less(i, j int) bool {
    // We want Pop to give us the highest, not lowest, priority so we use greater than here.
    return pq[i].priority > pq[j].priority
}

func (pq PriorityQueue) Swap(i, j int) {
    pq[i], pq[j] = pq[j], pq[i]
    pq[i].index = i
    pq[j].index = j
}

func (pq *PriorityQueue) Push(x interface{}) {
    n := len(*pq)
    item := x.(*Item)
    item.index = n
    *pq = append(*pq, item)
}

func (pq *PriorityQueue) Pop() interface{} {
    old := *pq
    n := len(old)
    item := old[n-1]
    item.index = -1 // for safety
    *pq = old[0 : n-1]
    return item
}

// update modifies the priority and value of an Item in the queue.
func (pq *PriorityQueue) update(item *Item, value string, priority int) {
    item.value = value
    item.priority = priority
    heap.Fix(pq, item.index)
}

// This example creates a PriorityQueue with some items, adds and manipulates an item,
// and then removes the items in priority order.
func main() {
    // Some items and their priorities.
    items := map[string]int{
        "banana": 3, "apple": 2, "pear": 4,
    }

    // Create a priority queue, put the items in it, and
    // establish the priority queue (heap) invariants.
    pq := make(PriorityQueue, len(items))
    i := 0
    for value, priority := range items {
        pq[i] = &Item{
            value:    value,
            priority: priority,
            index:    i,
        }
        i++
    }
    heap.Init(&pq)

    // Insert a new item and then modify its priority.
    item := &Item{
        value:    "orange",
        priority: 1,
    }
    heap.Push(&pq, item)
    pq.update(item, item.value, 5)

    // Take the items out; they arrive in decreasing priority order.
    for pq.Len() > 0 {
        item := heap.Pop(&pq).(*Item)
        fmt.Printf("%.2d:%s \n", item.priority, item.value)
    }
}
```

参考：<https://golang.org/pkg/container/heap/>
 
