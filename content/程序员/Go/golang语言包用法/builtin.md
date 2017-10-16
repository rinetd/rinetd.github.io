---
title: golang中builtin包说明
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中builtin包说明](/chenbaoke/article/details/42025867)

builtin包是go的预声明定义，包括go语言中常用的各种类型和方法声明，包括变量和常量两部分．其详细声明在builtin.go文件中，链接：http://golang.org/src/builtin/builtin.go

首先介绍一下golang中常量．

<span style="font-size:18px">常量：</span>

    const (
            true  = 0 == 0 // Untyped bool.
            false = 0 != 0 // Untyped bool.
    )

true和false是两个无类型的bool值

    const iota = 0 // Untyped int.无类型int

<span style="background-color:rgb(255,0,0)">iota是预声明标示符，它只能用在常量声明中</span>，并且其值从０开始，在const中每新增一行将使得iota计数一次，即iota自己增长１（从这点来看，iota可以看成const块中的行索引，记录行数），其值一直自增１直到遇到下一个const关键字，其值才被重新置为０．

１在常量声明中，如果一个常量没有赋值，则他就跟上一行的赋值相同，这个可以用在如果多个常量其值相同时，则只需给１个常量赋值，其他常量跟在他后面即可．

``` go
package main
import (
    "fmt"
)
const (
    a = iota　　　//iota默认初始值为０
    b = 100
    c　　　　　　//c默认跟上一个赋值相同
    d = iota　　　//iota默认每行加１，故此时其值为３
)
func main() {
    fmt.Println(a, b, c, d)
}
运行结果： 0 100 100 3
```

２在变量声明中，每新增一行，iota值采增加１，如果多个变量在一行中声明，iota值只增加１次

``` go
package main

import (
    "fmt"
)
const (
    a    = iota
    b, c = iota, iota
    d    = iota
)
func main() {
    fmt.Println(a, b, c, d)
}
运行结果：0 1 1 2
```

３iota遇到下一个const关键字，其值重新被赋值为０

``` go
package main

import (
    "fmt"
)

const (
    a    = iota
    b, c = iota, iota
    d    = iota
)
const e = iota　//再次遇到const关键字，iota值变为０

func main() {
    fmt.Println(a, b, c, d, e)
}
运行结果：0 1 1 2 0
```

４常量定义方式：　const 名字［数据类型］＝表达式，其中数据类型可有可无，但是使用数据类型时其必须注意：两个带类型常量不能写在同一行，带类型常量必须赋值，不能为空，如下所示：

``` go
const (
    a    = 1
    　d    int　　　//错误
    b int, c int = 1, 1　//错误

)
```

正确写法如下：

``` go
const (
    a    int = 1
    d    int
    b, c = 1, 1
)
```

所以在定义const常量时，除非特别强调常量类型，否则可以不带数据类型．
<span style="font-size:18px">变量：</span>

func append(slice \[\]Type, elems ...Type) \[\]Type

其使用有两种方式：

    slice = append(slice, elem1, elem2)　　//直接在slice后面添加单个元素，添加元素类型可以和slice相同，也可以不同
    slice = append(slice, anotherSlice...)　　//直接将另外一个slice添加到slice后面，但其本质还是将anotherSlice中的元素一个一个添加到slice中，和第一种方式类似．

作为一种特殊情况，将字符串添加到字节数组之后是合法的．

``` go
package main

import (
    "fmt"
)

func main() {
    slice := append([]byte("hello "), "world"...)　　//其实考虑一下，这也是很正常的，因为在go中[]byte和string是可以直接相互转换的．
    fmt.Println(string(slice))
}
运行结果：hello world
```

func len(v Type) int

len()是go中使用频率比较高的一个函数，其用来返回Type v的length，其对应的类型以及返回的值如下：

    数组：数组长度
    数组指针：数组长度
    slice/map：slice 或者map中元素个数
    string：字符串中字节数
    channel:通道中现有数量

func cap(v Type) int

cap()返回的是容器的容量，有时候和len()返回的值是不同的，其对应的类型和返回情况如下：

    数组：数组长度
    数组指针：数组长度
    slice:slice重新分配后能够达到最大长度
    channel:分配channel中缓存的大小

通过对比我们可以看到，在面对数组类型以及数组指针时，len和cap的值都是一样的，都是数组长度．

异同点：cap不支持map，string类型．而在slice 和channel，二者获取的值也是不同的，len取得的是现有值，而cap取得的是最大值．例子如下：

``` go
package main

import (
    "fmt"
)

func main() {

    a := make(chan int, 10)
    fmt.Println(cap(a))        //10
    fmt.Println(len(a))        //0
    b := make([]int, 2)
    b = append(b, 1)
    fmt.Println(len(b))        //3
    fmt.Println(cap(b))      //4
}
运行结果：10 0 3 4
```

func close(c chan&lt;- Type)

close()只能用来关闭channel，并且其只能在发送端关闭，不能在接受端关闭．具体参见<http://blog.csdn.net/chenbaoke/article/details/41647865>

func complex(r, i FloatType) ComplexType     //将两个浮点数类型转换为一个复数，其中实部和虚部二者类型必须一致，并且只能为float32和float64的一种

func imag(c ComplexType) FloatType　　　//获取复数的虚部

func real(c ComplexType) FloatType　　　//获取复数的实部

``` go
package main

import (
    "fmt"
)
func main() {
    a := complex(1, 2)
    b := imag(a)
    c := real(a)
    fmt.Println(a, b, c)
}
运行结果：(1+2i) 　2 　1
```

func copy(dst, src \[\]Type) int
copy实现两个slice之间的复制，其中复制的长度是dst和src中长度比较小的长度，返回的也是比较小的长度，copy过程中允许覆盖．

``` go
package main

import (
    "fmt"
)

func main() {

    a := make([]int, 1)
    b := []int{1, 2}
    c := copy(a, b)　//由于a的大小为１，所以b只给a复制了１个元素１，并且返回ｃ的长度也是１
    fmt.Println(a, b, c)
}
运行结果：[1] [1 2] 1
```

func delete(m map\[Type\]Type1, key Type)

从map中删除相应的元素，如果无此key，则不做任何操作
func make(Type, size IntegerType) Type

只能用于map,slice,channel

func new(Type) \*Type //初始化对象并返回一个指向对象的指针

func panic(v interface{})　　//停止goroutine执行，先执行defer函数，待defer函数执行完，将出错信息向其panic调用者传递panic相关信息．
func recover() interface{}　  //defer函数中通过recover获取panic调用的错误信息，并恢复正常执行．如果没有panic，则recover会返回nil.

<span style="color:#FF0000">func print(args ...Type)
func println(args ...Type)</span>    //暂时没有明白其用法
type ComplexType    //表示所有的复数类型complex64 或 complex128
type FloatType　　　//表示所有的浮点类型：float32 或 float64
type IntegerType
type Type
type Type1
type bool
type byte　　　　　//等价与uinit8，习惯上用它来区分字节值和８位无符号整数
type complex128
type complex64
type error
type float32
type float64
type int　　　　　　//带符号整型，其大小与机器总线数量有关，但是他是一种具体的类型，而不是int32或者int64的别名．
type int16
type int32
type int64
type int8
type rune　　　　//int32别名，习惯上用它来区分字符值和整数值
type string　　　//８位字节的字符串合集，string可为空，但是不能为nil，不能够对string进行修改．
type uint
type uint16
type uint32
type uint64
type uint8
type uintptr　　//其为整数类型，其大小足以容纳任何指针的位模式．

    var nil Type      //nil只能表示指针，channel，函数，interface，map或者slice类型，不能够表示其他类型．

参考：<http://golang.org/pkg/builtin/>
