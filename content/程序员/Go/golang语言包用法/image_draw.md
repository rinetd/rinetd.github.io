---
title: golang中image/draw包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
golang中image/draw包用法

draw包提供了图片的生成方法，或者绘制方法．其使用方法只需导入响应的包即可＂import image/draw"

func Draw(dst Image, r image.Rectangle, src image.Image, sp image.Point, op Op)

Draw是DrawMask的一种特殊形式，当DrawMask方法中mask为nil时，便是Draw函数
func DrawMask(dst Image, r image.Rectangle, src image.Image, sp image.Point, mask image.Image, mp image.Point, op Op)

其中各个参数的含义如下：

``` go
　dst  绘图的背景图。
    r 是背景图的绘图区域
    src 是要绘制的图
    sp 是 src 对应的绘图开始点（绘制的大小 r变量定义了）
    mask 是绘图时用的蒙版，控制替换图片的方式。
    mp 是绘图时蒙版开始点（绘制的大小 r变量定义了）
　op Op is a Porter-Duff compositing operator.  参考文章："http://blog.csdn.net/ison81/article/details/5468763"  http://blog.csdn.net/ison81/article/details/5468763
　Porter-Duff 等式12种规则可以看这篇博客："http://www.blogjava.net/onedaylover/archive/2008/01/16/175675.html" http://www.blogjava.net/onedaylover/archive/2008/01/16/175675.html
```

DrawMask将dst上的r.Min，src上的sp，mask上的mp对齐，然后对dst上的r型矩阵区域执行Porter-Duff合并操作。mask设置为nil就代表完全不透明。

type Drawer　//Drawer中只含有一个Draw函数

``` go
type Drawer interface {

    // Draw 根据 src 中的 sp 来对齐 dst 中的 r.Min，然后用在 dst 上画出 src
    // 的结果来替换掉矩形 r
    Draw(dst Image, r image.Rectangle, src image.Image, sp image.Point)
}
```

type Image

``` go
type Image interface {
    image.Image
    Set(x, y int, c color.Color)
}
```

draw.Image实在image.Image基础上带有一个Set方法来改变一个单一的像素
type Op

``` go
type Op int，启用在Draw和DrawMask方法中

const (

    // Over说明``(在mask上的src)覆盖在dst上''。
    Over Op = iota

    // Src说明``src作用在mask上''。
    Src
)
```

func (op Op) Draw(dst Image, r image.Rectangle, src image.Image, sp image.Point)　//Draw 通过用此 Op 调用 Draw 函数实现了 Drawer 接口。

type Quantizer

``` go
type Quantizer interface {
    // Quantize appends up to cap(p) - len(p) colors to p and returns the
    // updated palette suitable for converting m to a paletted image.
    Quantize(p color.Palette, m image.Image) color.Palette
}
```

举例说明draw包的用法：

原始图片：

![](http://img.blog.csdn.net/20150121144238821)

截取图片的一部分：

``` go
package main

import (
    "fmt"
    "image"
    "image/color"
    "image/draw"
    "image/jpeg"
    "os"
)

func main() {
    file, err := os.Create("dst.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file.Close()

    file1, err := os.Open("20.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file1.Close()
    img, _ := jpeg.Decode(file1)

    jpg := image.NewRGBA(image.Rect(0, 0, 100, 100))
    draw.Draw(jpg, img.Bounds().Add(image.Pt(10, 10)), img, img.Bounds().Min, draw.Src) //截取图片的一部分
    jpeg.Encode(file, jpg, nil)

}
```

截取后的图片：

![](http://img.blog.csdn.net/20150121144519156)

将原始图片转换为灰色图片：

``` go
package main

import (
    "fmt"
    "image"
    "image/color"
    "image/draw"
    "image/jpeg"
    "os"
)

func main() {
    file, err := os.Create("dst.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file.Close()

    file1, err := os.Open("20.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file1.Close()
    img, _ := jpeg.Decode(file1)

    jpg := image.NewGray(img.Bounds())                                 //NewGray

    draw.Draw(jpg, jpg.Bounds(), img, img.Bounds().Min, draw.Src) //原始图片转换为灰色图片

    jpeg.Encode(file, jpg, nil)

}
```

转换后效果图：

![](http://img.blog.csdn.net/20150121154159340)

利用draw实现两张图片合成：

``` go
func main() {
    file, err := os.Create("dst.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file.Close()

    file1, err := os.Open("20.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file1.Close()
    img, _ := jpeg.Decode(file1)

    file2, err := os.Open("10.jpg")
    if err != nil {
        fmt.Println(err)
    }
    defer file2.Close()
    img2, _ := jpeg.Decode(file2)

    jpg := image.NewRGBA(image.Rect(0, 0, 300, 300))

    draw.Draw(jpg, jpg.Bounds(), img2, img2.Bounds().Min, draw.Over)                   //首先将一个图片信息存入jpg
    draw.Draw(jpg, jpg.Bounds(), img, img.Bounds().Min.Sub(image.Pt(0, 0)), draw.Over)   //将另外一张图片信息存入jpg

    // draw.DrawMask(jpg, jpg.Bounds(), img, img.Bounds().Min, img2, img2.Bounds().Min, draw.Src) // 利用这种方法不能够将两个图片直接合成？目前尚不知道原因。

    jpeg.Encode(file, jpg, nil)

}
```

合成后图片如下：

![](http://img.blog.csdn.net/20150121162111106)

参考:

蝈蝈俊博客：<http://www.cnblogs.com/ghj1976/p/3443638.html>

golang官网：<http://docscn.studygolang.com/pkg/image/draw/>
