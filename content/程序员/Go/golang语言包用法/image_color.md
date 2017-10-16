---
title: golang中image/color包的用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中image/color包的用法](/chenbaoke/article/details/42804943)

color包是image包对于color重点介绍，实现了基本的颜色库

color中定义了如下几个变量

``` html
var (
    Black       = Gray16{0}
    White       = Gray16{0xffff}
    Transparent = Alpha16{0}
    Opaque      = Alpha16{0xffff}
)
```

func RGBToYCbCr(r, g, b uint8) (uint8, uint8, uint8)　//RGBToYCbCr将RGB的三重色转换为Y'CbCr模型的三重色
func YCbCrToRGB(y, cb, cr uint8) (uint8, uint8, uint8)  //YCbCrToRGB将Y'CbCr上的三重色转变成RGB的三重色。

type Alpha       //Alpha代表一个8-bit的透明度。

``` html
type Alpha struct {
    A uint8
}
```

func (c Alpha) RGBA() (r, g, b, a uint32)

type Alpha16       //Alpha16代表一个16位的透明度。

``` html
type Alpha16 struct {
    A uint16
}
```

func (c Alpha16) RGBA() (r, g, b, a uint32)

<span style="color:#FF0000">预乘简单定义（预乘会在后面的定义中用到）：</span>

<span style="color:#FF0000">什么是预乘？假设一个像素点，用RGBA四个分量来表示，记做(R,G,B,A)，那预乘后的像素就是(R\*A,G\*A,B\*A, A)，这里A的取值范围是\[0,1\]。所以，预乘就是每个颜色分量都与该像素的alpha分量预先相乘。可以发现，对于一个没有透明度，或者说透明度为1的像素来说，预乘不预乘结果都是一样的。</span>

type Color      //Color可以将它自己转化成每个RGBA通道都预乘透明度。这种转化可能是有损的。任何实现RGBA()方法的结构体都实现了Color接口

``` html
type Color interface {

    // RGBA返回预乘透明度的红，绿，蓝和颜色的透明度。每个值都在[0, 0xFFFF]范围内，
    // 但是每个值都被uint32代表，这样可以乘以一个综合值来保证不会达到0xFFFF而溢出。
    RGBA() (r, g, b, a uint32)
}
```

type Gray     //Gray代表一个8-bit的灰度。

``` html
type Gray struct {
    Y uint8
}
```

func (c Gray) RGBA() (r, g, b, a uint32)

type Gray16         //Gray16代表了一个16-bit的灰度。

``` html
type Gray struct {
    Y uint16
}
```

func (c Gray16) RGBA() (r, g, b, a uint32)

type Model         //Model接口实现了Convert方法，Model可以在它自己的颜色模型中将一种颜色转化到另一种。这种转换可能是有损的。

``` html
type Model interface {
    Convert(c Color) Color
}
```

其中基本的颜色模型Model如下所示：

``` html
var (
    RGBAModel    Model = ModelFunc(rgbaModel)
    RGBA64Model  Model = ModelFunc(rgba64Model)
    NRGBAModel   Model = ModelFunc(nrgbaModel)
    NRGBA64Model Model = ModelFunc(nrgba64Model)
    AlphaModel   Model = ModelFunc(alphaModel)
    Alpha16Model Model = ModelFunc(alpha16Model)
    GrayModel    Model = ModelFunc(grayModel)
    Gray16Model  Model = ModelFunc(gray16Model)
)
```

而YCbCrModel是Y'CbCr颜色的模型

``` html
var YCbCrModel Model = ModelFunc(yCbCrModel)
```

func ModelFunc(f func(Color) Color) Model　　//ModelFunc返回一个Model，它可以调用f来实现转换。

type NRGBA            //NRGBA代表一个没有32位透明度加乘的颜色。每个红，绿，蓝和透明度都是８bit的数值

``` html
type NRGBA struct {
    R, G, B, A uint8
}
```

func (c NRGBA) RGBA() (r, g, b, a uint32)

type NRGBA64         //NRGBA64代表无透明度加乘的64-bit的颜色，它的每个红，绿，蓝，和透明度都是个16bit的数值。

``` html
type NRGBA struct {
    R, G, B, A uint16
}
```

func (c NRGBA64) RGBA() (r, g, b, a uint32)

type Palette         //Palette是颜色的调色板

``` html
type Palette []Color
```

func (p Palette) Convert(c Color) Color    //返回欧式r g b空间中最接近color　c 的调色板颜色
func (p Palette) Index(c Color) int　　　//Index在Euclidean R,G,B空间中找到最接近c的调色板对应的索引。

type RGBA         //RGBA代表一个传统的32位的预乘透明度的颜色，它的每个红，绿，蓝，和透明度都是个8bit的数值。

``` html
type RGBA struct {
    R, G, B, A uint8
}
```

func (c RGBA) RGBA() (r, g, b, a uint32)

type RGBA64       //RGBA64代表一个64位的预乘透明度的颜色，它的每个红，绿，蓝，和透明度都是个8bit的数值。

``` html
type RGBA64 struct {
    R, G, B, A uint16
}
```

func (c RGBA64) RGBA() (r, g, b, a uint32)

type YCbCr        //YCbCr代表了完全不透明的24-bit的Y'CbCr的颜色，它的每个亮度和每两个色度分量是8位的。

``` html
type YCbCr struct {
    Y, Cb, Cr uint8
}
```

JPEG，VP8，MPEG家族和其他一些解码器使用这个颜色模式。每个解码器经常将YUV和Y'CbCr同等使用，但是严格来说，YUV只是用于分析视频信号，Y' (luma)是Y (luminance)伽玛校正之后的结果。

RGB和Y'CbCr之间的转换是有损的，并且转换的时候有许多细微的不同。这个包是遵循JFIF的说明：<http://www.w3.org/Graphics/JPEG/jfif3.pdf>。

func (c YCbCr) RGBA() (r uint32,g uint32,b uint32,a uint32)
