---
title: golang中image包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------

###
[golang中image包用法](/chenbaoke/article/details/42782767)

image包实现了一个基本的2D图像库，该包中包含基本的接口叫做image，这个里面包含color，这个将在image/color中描述，

image接口的值创建方式有如下几种：

１调用NewRGBA和NewPaletted

２解码一个包含gif.jpen或者png格式的image数据的io.Reader

首先介绍一些image接口

type Image    //image是一个从颜色模型中采取color.Color的矩形网格

``` go
type Image interface {
    ColorModel() color.Model　//ColorModel　返回图片的 color.Model
    Bounds() Rectangle　　　　//图片中非０color的区域
    At(x, y int) color.Color　　//返回指定点的像素color.Color
}
```

任何一个struct只要实现了image中的三个方法，便实现了image接口
func Decode(r io.Reader) (Image, string, error)　//Decode对一个根据指定格式进行编码的图片进行解码操作，string返回的是在注册过程中使用的格式化名字，如"gif"或者"jpeg"等．

func RegisterFormat(name, magic string, decode func(io.Reader) (Image, error), decodeConfig func(io.Reader) (Config, error))

RegisterFormat注册一个image格式给解码使用，name是格式化名字，例如＂jpeg"或者＂png＂,magic标明格式化编码的前缀，magic字符串中能够包含一个?字符，用来匹配任何一个字符，decode是用来解码＂编码图像"的函数，DecodeConfig是一个仅仅解码它的配置的函数．

type Alpha　//用来设置图片的透明度

``` go
type Alpha struct {

    Pix []uint8　　// Pix 存储图片的像素 ，像 alpha 值. 在（X,Y）的像素 starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*1].

    Stride int          // Stride 表示垂直两个像素之间的步幅（距离）

    Rect Rectangle　　// Rect 表示 图片边界.
}
```

func NewAlpha(r Rectangle) \*Alpha       //利用给定矩形边界产生一个alpha
func (p \*Alpha) AlphaAt(x, y int) color.Alpha      //获取指定点的透明度
func (p \*Alpha) At(x, y int) color.Color　　　//获取指定点的color(指定点的红绿蓝的透明度)
func (p \*Alpha) Bounds() Rectangle　　　//获取alpha的边界
func (p \*Alpha) ColorModel() color.Model　//获取alpha的颜色模型
func (p \*Alpha) Opaque() bool　　　　　　//检查alpha是否完全不透明
func (p \*Alpha) PixOffset(x, y int) int　　　//获取指定像素相对于第一个像素的相对偏移量
func (p \*Alpha) Set(x, y int, c color.Color)　//设定指定位置的color
func (p \*Alpha) SetAlpha(x, y int, c color.Alpha)  //设定指定位置的alpha
func (p \*Alpha) SubImage(r Rectangle) Image   //获取p图像中被r覆盖的子图像，父图像和子图像公用像素

下面举例说明其用法：

``` go
package main

import (
    "fmt"
    "image"
    "image/color"
    "image/jpeg"
    "log"
    "os"
)

const (
    dx = 500
    dy = 200
)

func main() {

    file, err := os.Create("test.jpeg")
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()
    alpha := image.NewAlpha(image.Rect(0, 0, dx, dy))
    for x := 0; x < dx; x++ {
        for y := 0; y < dy; y++ {
            alpha.Set(x, y, color.Alpha{uint8(x % 256)})   //设定alpha图片的透明度
        }
    }

    fmt.Println(alpha.At(400, 100))    //144 在指定位置的像素
    fmt.Println(alpha.Bounds())        //(0,0)-(500,200)，图片边界
    fmt.Println(alpha.Opaque())        //false，是否图片完全透明
    fmt.Println(alpha.PixOffset(1, 1)) //501，指定点相对于第一个点的距离
    fmt.Println(alpha.Stride)          //500，两个垂直像素之间的距离
    jpeg.Encode(file, alpha, nil)      //将image信息写入文件中
}
```

得到的图形如下所示：

![](http://img.blog.csdn.net/20150120163123872)

由于每种类型其方法类似，下面不再距离说明。

type Alpha16

``` go
type Alpha16 struct {
    // Pix holds the image's pixels, as alpha values in big-endian format. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*2].　大端模式，所以像素计算和alpha不同
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

其中alpha16中方法用法与alpha中方法用法类似，这里不再赘述．
func NewAlpha16(r Rectangle) \*Alpha16
func (p \*Alpha16) Alpha16At(x, y int) color.Alpha16
func (p \*Alpha16) At(x, y int) color.Color
func (p \*Alpha16) Bounds() Rectangle
func (p \*Alpha16) ColorModel() color.Model
func (p \*Alpha16) Opaque() bool
func (p \*Alpha16) PixOffset(x, y int) int
func (p \*Alpha16) Set(x, y int, c color.Color)
func (p \*Alpha16) SetAlpha16(x, y int, c color.Alpha16)
func (p \*Alpha16) SubImage(r Rectangle) Image

type Config　//包括图像的颜色模型和宽高尺寸

``` go
type Config struct {
    ColorModel    color.Model
    Width, Height int
}
```

func DecodeConfig(r io.Reader) (Config, string, error)

type Gray　　／／用来设置图片的灰度

``` go
type Gray struct {
    // Pix holds the image's pixels, as gray values. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*1].
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

其中Gray方法与Alpha完全相同，不在赘述

func NewGray(r Rectangle) \*Gray
func (p \*Gray) At(x, y int) color.Color
func (p \*Gray) Bounds() Rectangle
func (p \*Gray) ColorModel() color.Model
func (p \*Gray) GrayAt(x, y int) color.Gray
func (p \*Gray) Opaque() bool
func (p \*Gray) PixOffset(x, y int) int
func (p \*Gray) Set(x, y int, c color.Color)
func (p \*Gray) SetGray(x, y int, c color.Gray)
func (p \*Gray) SubImage(r Rectangle) Image

type Gray16

``` go
type Gray16 struct {
    // Pix holds the image's pixels, as gray values in big-endian format. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*2].
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

Gray16方法与Alpha16方法完全相同，不再赘述
func NewGray16(r Rectangle) \*Gray16
func (p \*Gray16) At(x, y int) color.Color
func (p \*Gray16) Bounds() Rectangle
func (p \*Gray16) ColorModel() color.Model
func (p \*Gray16) Gray16At(x, y int) color.Gray16
func (p \*Gray16) Opaque() bool
func (p \*Gray16) PixOffset(x, y int) int
func (p \*Gray16) Set(x, y int, c color.Color)
func (p \*Gray16) SetGray16(x, y int, c color.Gray16)
func (p \*Gray16) SubImage(r Rectangle) Image

type NRGBA

``` go
type NRGBA struct {
    // Pix holds the image's pixels, in R, G, B, A order. The pixel at
    // (x, y) starts at <span style="color:#FF0000;">Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*4]</span>.
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

func NewNRGBA(r Rectangle) \*NRGBA
func (p \*NRGBA) At(x, y int) color.Color
func (p \*NRGBA) Bounds() Rectangle
func (p \*NRGBA) ColorModel() color.Model
func (p \*NRGBA) NRGBAAt(x, y int) color.NRGBA
func (p \*NRGBA) Opaque() bool
func (p \*NRGBA) PixOffset(x, y int) int
func (p \*NRGBA) Set(x, y int, c color.Color)
func (p \*NRGBA) SetNRGBA(x, y int, c color.NRGBA)
func (p \*NRGBA) SubImage(r Rectangle) Image

type NRGBA64

``` go
type NRGBA64 struct {
    // Pix holds the image's pixels, in R, G, B, A order and big-endian format. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*8].
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

func NewNRGBA64(r Rectangle) \*NRGBA64
func (p \*NRGBA64) At(x, y int) color.Color
func (p \*NRGBA64) Bounds() Rectangle
func (p \*NRGBA64) ColorModel() color.Model
func (p \*NRGBA64) NRGBA64At(x, y int) color.NRGBA64
func (p \*NRGBA64) Opaque() bool
func (p \*NRGBA64) PixOffset(x, y int) int
func (p \*NRGBA64) Set(x, y int, c color.Color)
func (p \*NRGBA64) SetNRGBA64(x, y int, c color.NRGBA64)
func (p \*NRGBA64) SubImage(r Rectangle) Image

type Paletted

``` go
type Paletted struct {
    // Pix holds the image's pixels, as palette indices. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*1].
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
    // Palette is the image's palette. 图片的调色板
    Palette color.Palette
}
```

func NewPaletted(r Rectangle, p color.Palette) \*Paletted　　//根据指定的宽高和颜色调色板生成一个新的调色板
func (p \*Paletted) At(x, y int) color.Color
func (p \*Paletted) Bounds() Rectangle
func (p \*Paletted) ColorIndexAt(x, y int) uint8
func (p \*Paletted) ColorModel() color.Model
func (p \*Paletted) Opaque() bool
func (p \*Paletted) PixOffset(x, y int) int
func (p \*Paletted) Set(x, y int, c color.Color)
func (p \*Paletted) SetColorIndex(x, y int, index uint8)
func (p \*Paletted) SubImage(r Rectangle) Image

type PalettedImage　　//调色板图像接口

``` go
type PalettedImage interface {

    ColorIndexAt(x, y int) uint8　//返回在位置(x,y)处像素的索引
    Image　　//image接口
}
```

type Point　//一个点的(x,y)坐标对

``` go
type Point struct {
    X, Y int
}
```

func Pt(X, Y int) Point      //Pt是Point{X, Y}的简写
func (p Point) Add(q Point) Point　　//两个向量点求和
func (p Point) Div(k int) Point　　　//Div returns the vector p/k，求Point／k的值
func (p Point) Eq(q Point) bool　　　//判定两个向量点是否相等
func (p Point) In(r Rectangle) bool　//判断某个向量点是否在矩阵中
func (p Point) Mod(r Rectangle) Point    //在矩阵r中求一个点q，是的p.x-q.x是矩阵宽的倍数，p.y-q.y是矩阵高的倍数
func (p Point) Mul(k int) Point　　　//返回向量点和指定值的乘积组成的向量点
func (p Point) String() string　　　　//返回用string表示的向量点，其样式如(1,2)
func (p Point) Sub(q Point) Point      //两个向量点求差

举例说明如下：

``` go
func main() {
    pt := image.Point{X: 5, Y: 5}
    fmt.Println(pt)            //(5,5) ，输出一个点位置（X,Y）
    fmt.Println(image.Pt(1, 2))   //(1,2)  ，Pt输出一个点位置的简写形式
    fmt.Println(pt.Add(image.Pt(1, 1)))  //(6,6)，两个点求和
    fmt.Println(pt.String())      //(5,5) ，以字符串形式输出点
    fmt.Println(pt.Eq(image.Pt(5, 5)))        //true，判断两个点是否完全相等
    fmt.Println(pt.In(image.Rect(0, 0, 10, 10)))    //true，判断一个点是否在矩阵中
    fmt.Println(pt.Div(2))          //(2,2)，求点的商
   fmt.Println(pt.Mul(2))             // (10,10)，求点的乘积
    fmt.Println(pt.Sub(image.Pt(1, 1)))     // (4,4)，求两个点的差fmt.Println(pt.Mod(image.Rect(9, 8, 10, 10)))  // (9,9)，dx=10-9=1,dy=10-8=2,9-5=4,4是1和2的倍数并且（9,9）在矩阵中
}
```

type RGBA

``` go
type RGBA struct {
    // Pix holds the image's pixels, in R, G, B, A order. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*4]
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

func NewRGBA(r Rectangle) \*RGBA
func (p \*RGBA) At(x, y int) color.Color
func (p \*RGBA) Bounds() Rectangle
func (p \*RGBA) ColorModel() color.Model
func (p \*RGBA) Opaque() bool
func (p \*RGBA) PixOffset(x, y int) int
func (p \*RGBA) Set(x, y int, c color.Color)
func (p \*RGBA) SetRGBA(x, y int, c color.RGBA)
func (p \*RGBA) SubImage(r Rectangle) Image

举例说明RGBA用法：

``` go
package main

import (
    "fmt"
    "image"
    "image/color"
    "image/jpeg"
    "log"
    "os"
)

const (
    dx = 500
    dy = 200
)

func main() {

    file, err := os.Create("test.jpg")
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()
    rgba := image.NewRGBA(image.Rect(0, 0, dx, dy))
    for x := 0; x < dx; x++ {
        for y := 0; y < dy; y++ {
            rgba.Set(x, y, color.NRGBA{uint8(x % 256), uint8(y % 256), 0, 255})
        }
    }

    fmt.Println(rgba.At(400, 100))    //{144 100 0 255}
    fmt.Println(rgba.Bounds())        //(0,0)-(500,200)
    fmt.Println(rgba.Opaque())        //true，其完全透明
    fmt.Println(rgba.PixOffset(1, 1)) //2004
    fmt.Println(rgba.Stride)          //2000
    jpeg.Encode(file, rgba, nil)      //将image信息存入文件中
}
```

得到的文件如下;

![](http://img.blog.csdn.net/20150120164811640)

type RGBA64

``` go
type RGBA64 struct {
    // Pix holds the image's pixels, in R, G, B, A order and big-endian format. The pixel at
    // (x, y) starts at Pix[(y-Rect.Min.Y)*Stride + (x-Rect.Min.X)*8].
    Pix []uint8
    // Stride is the Pix stride (in bytes) between vertically adjacent pixels.
    Stride int
    // Rect is the image's bounds.
    Rect Rectangle
}
```

func NewRGBA64(r Rectangle) \*RGBA64
func (p \*RGBA64) At(x, y int) color.Color
func (p \*RGBA64) Bounds() Rectangle
func (p \*RGBA64) ColorModel() color.Model
func (p \*RGBA64) Opaque() bool
func (p \*RGBA64) PixOffset(x, y int) int
func (p \*RGBA64) RGBA64At(x, y int) color.RGBA64
func (p \*RGBA64) Set(x, y int, c color.Color)
func (p \*RGBA64) SetRGBA64(x, y int, c color.RGBA64)
func (p \*RGBA64) SubImage(r Rectangle) Image

type Rectangle　　　//利用两个坐标点来生成矩阵

``` go
type Rectangle struct {
    Min, Max Point
}
```

func Rect(x0, y0, x1, y1 int) Rectangle　//Rect是Rectangle{Pt(x0, y0), Pt(x1, y1)}的一种简写形式
func (r Rectangle) Add(p Point) Rectangle　//矩阵中两个点都与指定的点求和组成一个新的矩阵
func (r Rectangle) Canon() Rectangle　　//返回标准格式的矩形，如果有必要的话，会进行最小值坐标和最大坐标的交换
func (r Rectangle) Dx() int　　　　　　　//返回矩阵宽度dx
func (r Rectangle) Dy() int　　　　　　　//返回矩阵高度dy
func (r Rectangle) Empty() bool            　　//判定是否该矩阵为空，即不包含任何point
func (r Rectangle) Eq(s Rectangle) bool    //判断两个矩阵是否相等，指的是完全重合
func (r Rectangle) In(s Rectangle) bool　　//判断一个矩阵是否在另外一个矩阵之内

func (r Rectangle) Inset(n int) Rectangle　//返回根据n算出的嵌入的矩阵，计算方法是矩阵的每个坐标都减去n，求得的矩阵必须在已知矩阵内嵌，如果没有的话则返回空矩阵
func (r Rectangle) Intersect(s Rectangle) Rectangle     //求两个矩阵的相交矩阵，如果两个矩阵不相交，则返回０矩阵
func (r Rectangle) Overlaps(s Rectangle) bool　　//判断两个矩阵是否有交集，即判断两个矩阵是否有公共区域
func (r Rectangle) Size() Point　　　　　　　//返回矩阵的宽和高，即dx和dy
func (r Rectangle) String() string                         //返回矩阵的字符串表示
func (r Rectangle) Sub(p Point) Rectangle　　//一个矩阵的两个坐标点同时减去一个指定的坐标点p，得到的一个新的矩阵
func (r Rectangle) Union(s Rectangle) Rectangle　//两个矩阵的并集，这个是和Intersect（求两个矩阵的交集）相对的

举例说明Rectangle用法:

``` go
package main

import (
    "fmt"
    "image"
)

func main() {
    rt := image.Rect(0, 0, 100, 50)
    rt1 := image.Rect(100, 100, 10, 10)

    fmt.Println(rt1.Canon())      //(10,10)-(100,100)，rt1大小坐标交换位置
    fmt.Println(rt, rt1)          //(0,0)-(100,50) (10,10)-(100,100)
    fmt.Println(rt.Dx(), rt.Dy()) //100 50，返回矩阵的宽度和高度
    fmt.Println(rt.Empty())       //false，矩阵是否为空
    fmt.Println(rt.Eq(rt1))       //false，两个矩阵是否相等
    fmt.Println(rt.In(rt1))       //false，矩阵rt是否在矩阵rt1中
    fmt.Println(rt.Inset(10))     //(10,10)-(90,40)，查找内嵌矩阵，用原矩阵坐标点减去给定的值10得到的矩阵，该矩阵必须是原矩阵的内嵌矩阵

    if rt.Overlaps(rt1) {
        fmt.Println(rt.Intersect(rt1)) //(10,10)-(100,50) //求两个矩阵的交集
    }
    fmt.Println(rt.Size())                //(100,50)，求矩阵大小，其等价与（dx，dy）
    fmt.Println(rt.String())              //  (0,0)-(100,50)
    fmt.Println(rt.Sub(image.Pt(10, 10))) // (-10,-10)-(90,40)，求矩阵和一个点的差，用于将矩阵进行移位操作
    fmt.Println(rt.Union(rt1))            //(0,0)-(100,100)，求两个矩阵的并集
}
```

type Uniform     //Uniform是一个具有统一颜色无穷大小的图片，它实现了color.Color, color.Model, 以及 Image的接口

``` go
type Uniform struct {
    C color.Color
}
```

func NewUniform(c color.Color) \*Uniform　　//根据color.Color产生一个Uniform
func (c \*Uniform) At(x, y int) color.Color             //获取指定点的像素信息
func (c \*Uniform) Bounds() Rectangle　　　　//获取图像的边界矩阵信息
func (c \*Uniform) ColorModel() color.Model　　//获取图像的颜色模型
func (c \*Uniform) Convert(color.Color) color.Color　//将图片的像素信息转换为另外一种指定的像素信息
func (c \*Uniform) Opaque() bool　　　　　　　　　//判定图片是否完全透明
func (c \*Uniform) RGBA() (r, g, b, a uint32)　　　　//返回图片的r,g,b,a（红，绿，蓝，透明度）的值

type YCbCr　　//YCbCr是一个Y'CbCr颜色的图片，每个Y样本表示一个像素，但是每个Cb和Cr能够代表一个或者更多的像素，YStride是在相邻垂直像素的Ｙslice索引增　　　　　　　　　//量，CStride是Cb和 Cr　slice在相邻垂直像素（映射到独立色度采样）的索引增量．通常YStride和len(Y)是８的倍数，而CStride结果如下：

    For 4:4:4, CStride == YStride/1 && len(Cb) == len(Cr) == len(Y)/1.
    For 4:2:2, CStride == YStride/2 && len(Cb) == len(Cr) == len(Y)/2.
    For 4:2:0, CStride == YStride/2 && len(Cb) == len(Cr) == len(Y)/4.
    For 4:4:0, CStride == YStride/1 && len(Cb) == len(Cr) == len(Y)/2.

``` go
type YCbCr struct {
    Y, Cb, Cr      []uint8
    YStride        int
    CStride        int
    SubsampleRatio YCbCrSubsampleRatio
    Rect           Rectangle
}
```

func NewYCbCr(r Rectangle, subsampleRatio YCbCrSubsampleRatio) \*YCbCr　//通过给定边界和子样本比例创建新的YCbCr
func (p \*YCbCr) At(x, y int) color.Color　　　　　//获取指定点的像素
func (p \*YCbCr) Bounds() Rectangle　　　　　//获取图像边界
func (p \*YCbCr) COffset(x, y int) int　　　　　　　//获取指定点相对于第一个Cb元素的像素点的相对位置
func (p \*YCbCr) ColorModel() color.Model　　　　//获取颜色Model
func (p \*YCbCr) Opaque() bool                              //判定是否完全透明
func (p \*YCbCr) SubImage(r Rectangle) Image　　//根据指定矩阵获取原图像的子图像
func (p \*YCbCr) YCbCrAt(x, y int) color.YCbCr　　
func (p \*YCbCr) YOffset(x, y int) int　　　　　　　//获取相对于第一个Y元素的像素点的相对位置

type YCbCrSubsampleRatio　//YCbCr的色度子样本比例，常用于NewYCbCr(r Rectangle, subsampleRatio YCbCrSubsampleRatio)中用来创建YCbCr

``` go
const (
    YCbCrSubsampleRatio444 YCbCrSubsampleRatio = iota
    YCbCrSubsampleRatio422
    YCbCrSubsampleRatio420
    YCbCrSubsampleRatio440
)
```

func (s YCbCrSubsampleRatio) String() string　//YCbCrSubsampleRatio结构的字符串表示
