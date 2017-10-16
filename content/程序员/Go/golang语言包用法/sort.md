---
title: golang中sort包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
# [golang中sort包用法](/chenbaoke/article/details/42340301)


golang中也实现了排序算法的包sort包．

sort包中实现了３种基本的排序算法：插入排序．快排和堆排序．和其他语言中一样，这三种方式都是不公开的，他们只在sort包内部使用．所以用户在使用sort包进行排序时无需考虑使用那种排序方式，sort.Interface定义的三个方法：获取数据集合长度的Len()方法、比较两个元素大小的Less()方法和交换两个元素位置的Swap()方法，就可以顺利对数据集合进行排序。sort包会根据实际数据自动选择高效的排序算法。

----------------------------------------------------------------------------------

    type Interface interface {
        Len() int    // Len 为集合内元素的总数
        Less(i, j int) bool　//如果index为i的元素小于index为j的元素，则返回true，否则返回false
        Swap(i, j int)  // Swap 交换索引为 i 和 j 的元素
    }

任何实现了 sort.Interface 的类型（一般为集合），均可使用该包中的方法进行排序。这些方法要求集合内列出元素的索引为整数。

func Float64s(a float64)     //Float64s将类型为float64的slice a以升序方式进行排序
func Float64sAreSorted(a float64) bool　　//判定是否已经进行排序func Ints(a int)

func Ints(a int)                       //Ints 以升序排列 int 切片。
func IntsAreSorted(a int) bool　　　  //IntsAreSorted 判断 int 切片是否已经按升序排列。
func IsSorted(data Interface) bool    IsSorted 判断数据是否已经排序。包括各种可sort的数据类型的判断．

func Strings(a string)//Strings 以升序排列 string 切片。
func StringsAreSorted(a string) bool//StringsAreSorted 判断 string 切片是否已经按升序排列。

``` go
package main

import (
    "fmt"
    "sort"
)

//定义interface{},并实现sort.Interface接口的三个方法
type IntSlice []int

func (c IntSlice) Len() int {
    return len(c)
}
func (c IntSlice) Swap(i, j int) {
    c[i], c[j] = c[j], c[i]
}
func (c IntSlice) Less(i, j int) bool {
    return c[i] < c[j]
}

func main() {
    a := IntSlice{1, 3, 5, 7, 2}
    b := []float64{1.1, 2.3, 5.3, 3.4}
    c := []int{1, 3, 5, 4, 2}
    fmt.Println(sort.IsSorted(a)) //false
    if !sort.IsSorted(a) {
        sort.Sort(a)
    }

    if !sort.Float64sAreSorted(b) {
        sort.Float64s(b)
    }
    if !sort.IntsAreSorted(c) {
        sort.Ints(c)
    }
    fmt.Println(a)//[1 2 3 5 7]
    fmt.Println(b)//[1.1 2.3 3.4 5.3]
    fmt.Println(c)// [1 2 3 4 5]
}
```

func Search(n int, f func(int) bool) int   

search使用二分法进行查找，Search()方法回使用“二分查找”算法来搜索某指定切片[0:n]，并返回能够使f(i)=true的最小的i（0<=i<n）值，并且会假定，如果f(i)=true，则f(i+1)=true，即对于切片\[0:n\]，i之前的切片元素会使f()函数返回false，i及i之后的元素会使f()函数返回true。但是，当在切片中无法找到时f(i)=true的i时（此时切片元素都不能使f()函数返回true），<span style="color:#FF0000">Search()方法会返回n（而不是返回-1）。

Search 常用于在一个已排序的，可索引的数据结构中寻找索引为 i 的值 x，例如数组或切片。这种情况下，实参 f，一般是一个闭包，会捕获所要搜索的值，以及索引并排序该数据结构的方式。

为了查找某个值，而不是某一范围的值时，如果slice以升序排序，则　f func中应该使用＞＝,如果slice以降序排序，则应该使用&lt;=. 例子如下：package main

``` go
package main

import (
    "fmt"
    "sort"
)

func main() {
    a := []int{1, 2, 3, 4, 5}
    b := sort.Search(len(a), func(i int) bool { return a[i] >= 30 })
    fmt.Println(b)　　　　　　　//5，查找不到，返回a slice的长度５，而不是-1
    c := sort.Search(len(a), func(i int) bool { return a[i] <= 3 })
    fmt.Println(c)                             //0，利用二分法进行查找，返回符合条件的最左边数值的index，即为０
    d := sort.Search(len(a), func(i int) bool { return a[i] == 3 })
    fmt.Println(d)                          //2　　　
}
```

官网上面有趣的例子：
```go
    func GuessingGame() {
        var s string
        fmt.Printf("Pick an integer from 0 to 100.\n")
        answer := sort.Search(100, func(i int) bool {
            fmt.Printf("Is your number <= %d? ", i)
            fmt.Scanf("%s", &s)
            return s != "" && s[0] == 'y'
        })
        fmt.Printf("Your number is %d.\n", answer)
    }
```
func SearchFloat64s(a float64, x float64) int　　//SearchFloat64s 在float64s切片中搜索x并返回索引如Search函数所述. 返回可以插入x值的索引位置，如果x不存在，返回数组a的长度切片必须以升序排列
func SearchInts(a int, x int) int  //SearchInts 在ints切片中搜索x并返回索引如Search函数所述. 返回可以插入x值的索引位置，如果x不存在，返回数组a的长度切片必须以升序排列
func SearchStrings(a string, x string) int//SearchFloat64s 在strings切片中搜索x并返回索引如Search函数所述. 返回可以插入x值的索引位置，如果x不存在，返回数组a的长度切片必须以升序排列

<span style="color:#FF0000">其中需要注意的是，以上三种search查找方法，其对应的slice必须按照升序进行排序，否则会出现奇怪的结果．

``` go
package main

import (
    "fmt"
    "sort"
)

func main() {
    a := []string{"a", "c"}
    i := sort.SearchStrings(a, "b")
    fmt.Println(i) //1
    b := []string{"a", "b", "c", "d"}
    i = sort.SearchStrings(b, "b")
    fmt.Println(i) //1
    c := []string{"d", "c"}
    i = sort.SearchStrings(c, "b")
    fmt.Println(i) //0
    d := []string{"c", "d", "b"}
    i = sort.SearchStrings(d, "b")
    fmt.Println(i) //0，由于d不是以升序方式排列，所以出现奇怪的结果，这可以根据SearchStrings的定义进行解释．见下方．
}
func SearchStrings(a []string, x string) int {
return Search(len(a), func(i int) bool { return a[i] >= x })
}
```

由此可见，为了精确查找，必须对string　以升序方式进行排序．

func Sort(data Interface)//Sort 对 data 进行排序。它调用一次 data.Len 来决定排序的长度 n，调用 data.Less 和 data.Swap 的开销为O(n*log(n))。此排序为不稳定排序。他根据不同形式决定使用不同的排序方式（插入排序，堆排序，快排）

func Stable(data Interface)Stable对data进行排序，不过排序过程中，如果data中存在相等的元素，则他们原来的顺序不会改变，即如果有两个相等元素num,他们的初始index分别为i和j，并且i&lt;j，则利用Stable对data进行排序后，i依然小于ｊ．直接利用sort进行排序则不能够保证这一点．

golang自身实现的interface有三种，Float64Slice，IntSlice，StringSlice，具体如下所示：

type Float64Slice

    type Float64Slice []float64

Float64Slice 针对 float6 实现接口的方法，以升序排列。

``` go
func (p Float64Slice) Len() int　　　　//求长度
func (p Float64Slice) Less(i, j int) bool　//比大小
func (p Float64Slice) Search(x float64) int　//查找
func (p Float64Slice) Sort()　　　　　　//排序
func (p Float64Slice) Swap(i, j int)　　　//交换位置
```

type IntSlice

    type IntSlice []int

IntSlice 针对 int 实现接口的方法，以升序排列。

``` go
func (p IntSlice) Len() int
func (p IntSlice) Less(i, j int) bool
func (p IntSlice) Search(x int) int
func (p IntSlice) Sort()
func (p IntSlice) Swap(i, j int)
```

type StringSlice

    type StringSlice []string

StringSlice 针对 string 实现接口的方法，以升序排列。

``` go
func (p StringSlice) Len() int
func (p StringSlice) Less(i, j int) bool
func (p StringSlice) Search(x string) int
func (p StringSlice) Sort()
func (p StringSlice) Swap(i, j int)
```

func Reverse(data Interface) Interface

    func Reverse(data Interface) Interface

Reverse实现对data的逆序排列

``` go
package main

import (
    "fmt"
    "sort"
)

func main() {
    a := []int{1, 2, 5, 3, 4}
    fmt.Println(a)        // [1 2 5 3 4]
    sort.Sort(sort.Reverse(sort.IntSlice(a)))
    fmt.Println(a)        // [5 4 3 2 1]
}
```
