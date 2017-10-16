---
title: golang中image/gif包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---

golang中image/gif包用法
==============================================================================================


gif包实现了gif图片的解码及编码
func Decode(r io.Reader) (image.Image, error)      //Decode从r中读取一个GIF图像，然后返回的image.Image是第一个嵌入的图。

func DecodeConfig(r io.Reader) (image.Config, error)   //DecodeConfig不需要解码整个图像就可以返回全局的颜色模型和GIF图片的尺寸。

``` go
type Config struct {
    ColorModel    color.Model
    Width, Height int
}
```

Config返回图像的颜色model和尺寸
func Encode(w io.Writer, m image.Image, o \*Options) error    //将图片m按照gif模式写入w中

``` go
type Options struct {
    // NumColors是图片中使用颜色的最大值，它的范围是1-256
    NumColors int

    // Quantizer经常被用来通过NumColors产生调色板，palette.Plan9 被用来替代nil Quantizer
    Quantizer draw.Quantizer

    // Drawer i用于将源图片转化为期望的调色板， draw.FloydSteinberg 用来替代一个空 Drawer.
    Drawer draw.Drawer
}
```

func EncodeAll(w io.Writer, g \*GIF) error    //将图片按照帧与帧之间指定的循环次数和时延写入w中

``` go
type GIF struct {
    Image     []*image.Paletted // 连续的图片
    Delay     []int             // 连续的延迟时间，每一帧单位都是百分之一秒，delay中数值表示其两个图像动态展示的时间间隔
    LoopCount int               // 循环次数，如果为0则一直循环。
}
```

func DecodeAll(r io.Reader) (\*GIF, error) //DecodeAll 从r上读取一个GIF图片，并且返回顺序的帧和时间信息

简单举例说明如何利用gif包制作一个gif图片，画两条垂直相交的动态图线（如果想要得到复杂的gif图像，可以自己设置较复杂的画线以及颜色模式，得到复杂图形）：

``` go
package main

import (
    "fmt"
    "image"
    "image/color"
    "image/color/palette"
    "image/gif"
    "net/http"
    "os"
)

func main() {
    http.HandleFunc("/display", display)
    err := http.ListenAndServe(":9100", nil)
    if err != nil {
        fmt.Println(err)
    }
}

func display(w http.ResponseWriter, q *http.Request) {

    f1, err := os.Create("test.gif")
    if err != nil {
        fmt.Println(err)
    }
    defer f1.Close()

    p1 := image.NewPaletted(image.Rect(0, 0, 110, 110), palette.Plan9)
    for x := 0; x < 100; x++ {
        for y := 0; y < 100; y++ {
            p1.Set(50, y, color.RGBA{uint8(x), uint8(y), 255, 255})

        }
    }
    p2 := image.NewPaletted(image.Rect(0, 0, 210, 210), palette.Plan9)
    for x := 0; x < 100; x++ {
        for y := 0; y < 100; y++ {
            p2.Set(x, 50, color.RGBA{uint8(x * x % 255), uint8(y * y % 255), 0, 255})

        }
    }
    g1 := &gif.GIF{
        Image:     []*image.Paletted{p1, p2},
        Delay:     []int{30, 30},
        LoopCount: 0,
    }
    gif.EncodeAll(w, g1)  //浏览器显示
    gif.EncodeAll(f1, g1) //保存到文件中
}
```

动态gif图像如下：

![](http://img.blog.csdn.net/20150122143546218)

当然，也可以利用已有图片生成gif，代码如下：

``` go
package main

import (
    "fmt"
    "image"
    "image/color/palette"
    "image/draw"
    "image/gif"
    "image/jpeg"
    "image/png"
    "net/http"
    "os"
)

func main() {
    http.HandleFunc("/display", display)
    err := http.ListenAndServe(":9100", nil)
    if err != nil {
        fmt.Println(err)
    }
}

func display(w http.ResponseWriter, q *http.Request) {
    f, err := os.Open("test.jpeg")
    if err != nil {
        fmt.Println(err)
    }
    defer f.Close()
    g, err := jpeg.Decode(f)
    if err != nil {
        fmt.Println(err)
    }

    f2, err := os.Open("123.png")
    if err != nil {
        fmt.Println(err)
    }
    defer f.Close()

    g2, err := png.Decode(f2)
    if err != nil {
        fmt.Println(err)
    }

    f1, err := os.Create("test.gif")
    if err != nil {
        fmt.Println(err)
    }
    defer f1.Close()

    p1 := image.NewPaletted(image.Rect(0, 0, 200, 200), palette.Plan9)

    draw.Draw(p1, p1.Bounds(), g, image.ZP, draw.Src) //添加图片

    p2 := image.NewPaletted(image.Rect(0, 0, 200, 200), palette.Plan9)
    draw.Draw(p2, p2.Bounds(), g2, image.ZP, draw.Src) //添加图片

    g1 := &gif.GIF{
        Image:     []*image.Paletted{p1, p2},
        Delay:     []int{30, 30},
        LoopCount: 0,
    }

    gif.EncodeAll(w, g1)  
    gif.EncodeAll(f1, g1)
}
```

得到的gif图片如下所示：
![](http://img.blog.csdn.net/20150122160256050)
