---
title: Linux命令 ImageMagick
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [ImageMagick]
---
[ImageMagick常用指令详解 - 牛奶、不加糖 - 博客园](http://www.cnblogs.com/ITtangtang/p/3951240.html)
[ImageMagicK 图片尺寸转换 - pjw0221的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/pjw0221/article/details/5837879)

yairc -a ym.png 产生ios图标
# 生成 应用宝上传图标
convert -resize 16x16 文件名 favicon.ico #应用小图标16x16
convert -resize 16x16 文件名 qq-small-@16x16.png #应用小图标16x16
convert -resize 512x512 文件名 qq-@512x512.png  #应用图标512x512
convert -resize 480x800 文件名 截屏-@480x800.png #应用图标480x800
# 宽358 高441
convert jh.jpg -resize 358x441 jhua.jpg

格式转换Transform 缩放resize Fit 剪裁crop 旋转rotate 质量quality 翻转Flip  放大upscale
# 获取图片信息
`identify image.png`
如果只需要获取宽高：
$`identify -format "%wx%h" image.png `
# 关闭 alpha 通道 设置背景色
`convert image.png  -background white -alpha off out.png`
# 批量修改图片尺寸
`convert -resize 600x480 文件名 文件名`
`find ./ -name '*.jpg' -exec convert -resize 600x480 {} {} ;`

`for file in *.png; do convert $file -rotate 90 rotated-$file; done` #批量旋转

# 微信图标 28x28 108x108
convert -resize 28x28 in.png weixin28x28.png

#去除多余信息Exif信息
`convert +profile “*” 　或　-strip`

`find . -name '*.jpg' -exec convert -strip {} {} ;`
#先缩放后剪裁中心区域到指定大小
convert -resize "500x250^"  -gravity center -crop 500x250 5896fb1cb5fa3.png naoyuanxiao.png

调亮度, 饱和度, 色调
# 调节亮度
gm convert -modulate 150,100,100 input.jpg output.jpg

# 调节饱和度
gm convert -modulate 100,150,100 input.jpg output.jpg

# 调节色调
gm convert -modulate 100,100,150 input.jpg output.jpg

特效
# 黑白
gm convert -monochrome input.jpg output.jpg  

# 反色
gm convert -negate input.jpg  output.jpg

# 油画
gm convert -paint 4 input.jpg output.jpg

# 模糊
gm convert -blur 80x5 input.jpg output.jpg

# 铅笔画
gm convert -charcoal 2 input.jpg output.jpg

# 毛玻璃
gm convert -spread 30 input.jpg output.jpg
旋转与翻转
# 旋转
gm convert -rotate 90 input.jpg output.jpg

# 水平翻转
gm convert -flop input.jpg output.jpg

# 垂直翻转
gm convert -flip input.jpg output.jpg
裁剪与合成
# 裁剪成距离左上角 100,100, 长宽为 400x400 的图片
gm convert -crop 400x400+100+100 input.jpg output.jpg

# 合成图片
gm composite -gravity center output.jpg input.jpg output.jpg

创建缩略图
# 保持图片比例不变
gm convert -resize 200x200 input.jpg  output.jpg

# 指定图片大小
gm convert -resize 200x200! input.jpg  output.jpg

# 既保证大小，还保证比例, 多余部分可按指定颜色进行填充
gm convert -resize 200x200 -gravity center -extent 200x200 input.jpg  output.jpg

给图片加水印
# 在右下角加上 Hello World 水印
gm convert -fill red -gravity southeast -pointsize 40 -draw 'text 40 40 "Hello World"' input.jpg output.jpg

# fill: 填充颜色
# gravity: 地理位置
# pointsize: 字体大小
# draw: 绘制

建立GIF图片
# 从 gif 图片转成一群 jpg 图片
gm convert +adjoin input.gif output%d.jpg

# 从一群 jpg 图片转成 gif 图片
gm `convert -delay 50 *.jpg animation.gif`

# adjoin: 邻接
# delay: 延时

##缩放图像
1. 默认 <比例缩放>
convert example.png -resize 200×100 example.png
2. <图片变形> 通过压缩或拉伸，强制转换为指定尺寸。600×600，而图片无需保持原有比例，可以在宽高后面加上一个感叹号!.
`convert -resize 600×600! src.jpg dst.jpg`

##剪裁图片
imagemagick的convert命令通过crop参数，可以把一幅大图片分成若干块大小一样的图片，同时也可以在大图上截取一块图片来。命令格式为

convert 原始图片 -crop widthxheight+x+y 目标图片

其中widthxheight是目标图片的尺寸，+x+y是原始图片的坐标点，这两组值至少要出现一组，也可以同时存在。另外该命令也可使用gravity来重新定义坐标系统。关于更多gravity的信息，请参考：ImageMagicK之gravity参数详解。下面介绍几种常用的命令。

    把原始图片分割成多张小图

convert src.jpg -crop 100x100 dest.jpg

假设src.jpg的大小是300x200,执行命令后将得到名为dest-0.jpg、dest-1.jpg...dest-5.jpg
的6张大小为100x100的小图片。注意如果尺寸不是目标图片的整数倍，那么右边缘和下边缘的一部分图片就用实际尺寸

    在原始图片上剪裁一张指定尺寸的小图

convert src.jpg -crop 100x80+50+30 dest.jpg
在原始图片的上距离上部30像素左部50为起点的位置,分别向左向下截取一块大小为100x80的图片。如果x相对于坐标，宽度不够100，那就取实际值。

convert src.jpg -gravity center -crop 100x80+0+0 dest.jpg
在原始图上截取中心部分一块100x80的图片

convert src.jpg -gravity southeast -crop 100x80+10+5 dest.jpg
在原始图上截取右下角距离下边缘10个像素，右边缘5个像素一块100x80的图片


## 缩放图片
ImageMagick是一系列的用于修改、加工图像的命令行工具。ImageMagick能够快速地使用命令行对图片进行操作，对大量的图片进行批处理，或者是集成到bash脚本里去。ImageMagick能够执行相当多的操作。本指南将会指引你 ...

ImageMagick是一系列的用于修改、加工图像的命令行工具。ImageMagick能够快速地使用命令行对图片进行操作，对大量的图片进行批处理，或者是集成到bash脚本里去。
ImageMagick能够执行相当多的操作。本指南将会指引你学习ImageMagick的语法和基本操作，并且给你展示如何将各个操作结合起来以及如何对多个图像进行批处理。
安装

在Ubuntu以及很多Linux发行版中，没有默认安装ImageMagick，要在Ubuntu上安装它的话，请使用下面的命令：
`sudo apt-get install imagemagick`
转换图像的格式

转换命令对一幅图像执行某项操作，并将其以你指定的名字保存。你能使用它完成的一个最基本的事情是转换你的图像到各种其他的格式。下面的命令将当前目录下的一个叫“howtogeek.png”的PNG文件转换为一个JPEG文件。
convert howtogeek.png howtogeek.jpg

image2
你还可以指定JPEG格式图像的压缩级别：
convert howtogeek.png -quality 95 howtogeek.jpg

这个数字的必须在1到100之间。在没有指定的情况下，ImageMagick使用原始图像的质量等级（quality level），否则的话ImageMagick取92作为其默认值。
缩放图像

转换命令还可以便捷地调整一幅图像的大小。下面的命令指示ImageMagick将一幅图像调整为200像素宽，100像素高。
convert example.png -resize 200×100 example.png

在这个命令里面，我们对输入和输出使用了相同的文件名，这样ImageMagick将会覆盖掉原始文件。
image3
在使用这个命令的时候，ImageMagick会尽量保持图像的纵横比。它将会调整图像以适应200×100的区域，这样图像就不是恰好200×100了。如果你想要强制把图像设置为指定的大小——即使这样做会改变图像的纵横比的话——那么在尺寸参数后面加一个叹号就可以了。
convert example.png -resize 200×100! example.png

你还可以只指定特定的宽度或者高度，ImageMagick会在保持纵横比的情况下进行缩放。下面的命令将把一幅图像的宽度缩放为200像素宽：
convert example.png -resize 200 example.png

下面的命令会把一幅图像缩放为100像素高：
convert example.png -resize x100 example.png
旋转图像

ImageMagick能够快速地旋转图像。下面的命令将一幅叫做“howtogeek.jpg”的图像旋转90度，并将旋转后的图像保存为“howtogeek-rotated.jpg”：
convert howtogeek.jpg -rotate 90 howtogeek-rotated.jpg

如果你指定了相同的文件名的话，ImageMagick将会用旋转过的图像覆盖掉原始图像。
image4
应用特效

ImageMagick能够在一幅图像上做出很多种特效来。例如，下面的命令将一种叫做“炭笔画”（charcoal）的效果应用到一幅图像上：
convert howtogeek.jpg -charcoal 2 howtogeek-charcoal.jpg

image5
这个命令将会让你的图像有一种艺术炭画的效果，-charcoal选项后面的2可以控制效果的强度。
image6
下面的命令产生强度为1的“内爆”（implode）效果：
convert howtogeek.jpg -implode 1 howtogeek-imploded.jpg

image7
“内爆”效果使得一副图像看上去中央好像有一个黑洞一样。
image8
把各个操作结合起来！

所有的这些命令都可以结合起来使用，这样一条命令，你就可以对一幅图像同时执行缩放、旋转、添加特效以及格式转换等操作：
convert howtogeek.png -resize 400×400 -rotate 180 -charcoal 4 -quality 95 howtogeek.jpg

image9
使用ImageMagick，你能做的远不止这些，还有很多你可以结合起来使用的命令呢！
批处理

利用Bash，你能够便捷地对多个图像文件进行批处理。例如，下面的命令将会把当前目录下的所有PNG文件旋转之后，以原始文件名加“-rotated”组成的新文件名保存。
`for file in * .png; do convert $file -rotate 90 rotated-$file; done`

稍微修改一下这个命令，你就可以用它做很多其他的事情了。此外你还可以把批处理命令集成到Bash脚本中，从而自动化图像处理的过程。

任何关于ImageMagick的文章都会省略很多东西——因为它的命令和选项实在是太多了。如果你对ImageMagick的其他功能感兴趣的话，请查阅ImageMagick的官方文档来对ImageMagick进行更进一步的了解。


11、使用ImageMagicK给图片瘦身

原文：http://www.netingcn.com/imagemagick-strip-profile.html
影响图片大小（占用空间）主要取决于图片的profile和quality。
```
   quality：图片的品质，品质越高，占用的空间越大。适当降低品质能很大程度的减少图片的尺寸。一般来说，从品质100降到85，基本上肉眼很难区别其差别，但尺寸上减少很大。imagemagick通过通过-quality 来设置。
   profile：记录图片一些描述信息。例如相机信息（光圈，相机型号）、photoshop元数据，颜色表等信息。它占用的空间可以从几KB到几百KB，甚至可能更大。ImageMagicK可以通过两种方式来去掉这些信息。+profile “*” 　或　-strip
```
下述图片中第一张原始图片为56KB，第二张图片执行了　`convert +profile “*” -strip src.jpg src-profile.jpg`　后变成了26.3KB, 第三张设置图片品质为85，convert -quality 85 src.jpg src-quality85.jpg，图片大小变成了19.5KB，第四张是同时使用去掉profile和设置品质为85,convert -quality 85 -strip src.jpg src-p-q85.jpg，图片只有18.7KB。经过一个简单的命令处理，就可以把原始图片体积减小到原来的的三分之一。一般来说jpg格式的图片有比较大的操作空间，而png、gif有时候处理了反而变大。所以具体问题需要具体分析。

原始图片

去掉profile

quality85

最终图片

在linux下可以很方便把某个目录下的所有jpg文件来一次瘦身运动，例如命令　`find /tmp/images -iname “*.jpg” -exec convert -strip +profile “*” -quality 85 {} {} \;`　可以把/tmp/images目录下所有jpg图片进行压缩。



转载自：http://www.linuxdiyf.com/viewarticle.php?id=170334
```
Convert的resize子命令应该是在ImageMagick中使用较多的命令，它实现了图片任意大小的缩放，唯一需要掌握的就是如何使用它的一些参数测试设定值：

此说明文件中所用的原始文件(src.jpg)，宽度：200，高度：150

命令格式： -resize widthxheight{%} {@} {!} {<} {>} {^}

1. 默认时，宽度和高度表示要最终需要转换图像的最大尺寸，同时Convert会控制图片的宽和高，保证图片按比例进行缩放。

如：convert -resize 600×600 src.jpg dst.jpg

转换后的dst.jpg的图片大小(宽度为600，而高度已经按比例调整为450).

2.如果需要转换成600×600，而图片无需保持原有比例，可以在宽高后面加上一个感叹号!.

如：convert -resize 600×600! src.jpg dst.jpg

3. 只指定高度，图片会转换成指定的高度值，而宽度会按原始图片比例进行转换。

如：convert -resize 400 src.jpg dst.jpg

转换后的dst.jpg的图片大小(宽度为400，而高度已经按比例调整为300)，和例1有点类似。

4. 默认都是使用像素作为单位，也可以使用百分比来形象图片的缩放。

如：convert -resize 50%x100%! src.jpg dst.jpg 或者convert -resize 50%x100% src.jpg dst.jpg

此参数只会按你的比例计算后缩放，不保持原有比例。（结果尺寸为100×150)

5.使用 @ 来制定图片的像素个数。

如：convert -resize “10000@” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（115×86），图片保持原有比例（115×86= 9080 < 10000)。

6.当原始文件大于指定的宽高时，才进行图片放大缩小，可使用>命令后缀。

如：convert -resize “100×50>” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（67×50），图片保持原有比例。

如：convert -resize “100×50>!” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（100×50），图片不保持原有比例。

7.当原始文件小于指定的宽高时，才进行图片放大转换，可使用<命令后缀。

如：convert -resize “100×500<” src.jpg dst.jpg 或者convert -resize “100×100<!” src.jpg dst.jpg

此命令执行后，dst.jpg和src.jpg大小相同，因为原始图片宽比100大。

如：convert -resize “600×600<” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（600×450），图片保持原有比例。

如：convert -resize “600×600<!” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（600×600），图片不保持原有比例。

8.使用^命令后缀可以使用宽高中较小的那个值作为尺寸

如：convert -resize “300×300^” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（400×300），图片保持原有比例，(300:300 < 200:150，选择高作为最小尺寸）。

如：convert -resize “300×200^” src.jpg dst.jpg

此命令执行后，dst.jpg图片大小为（300×225），图片保持原有比例，(300:200 > 200:150，选择宽作为最小尺寸）。

转载自：http://www.linuxdiyf.com/viewarticle.php?id=170334

convert命令可以用来转换图像的格式，支持JPG, BMP, PCX, GIF, PNG, TIFF, XPM和XWD等类型，下面举几个例子:
convert xxx.jpg xxx.png 将jpeg转成png文件
convert xxx.gif xxx.bmp 将gif转换成bmp图像
convert xxx.tiff xxx.pcx 将tiff转换成pcx图像
还可以改变图像的大小:
convert -resize 1024x768 xxx.jpg xxx1.jpg 将图像的像素改为1024x768，注意1024与768之间是小写字母x
convert -sample 50%x50% xxx.jpg xxx1.jpg 将图像的缩减为原来的50% 50%
旋转图像：
convert -rotate 270 sky.jpg sky-final.jpg 将图像顺时针旋转270度
使用-draw选项还可以在图像里面添加文字：
convert -fill black -pointsize 60 -font helvetica -draw 'text 10,80 "Hello, World!" ‘ hello.jpg helloworld.jpg
在图像的10,80 位置采用60磅的全黑Helvetica字体写上 Hello, World!
convert还有其他很多有趣和强大的功能，大家不妨可以试试。
```

[后台使用imagemagick的convert命令来处理图片真是太方便了。 - pb09013037的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/pb09013037/article/details/44221809)
1，获取图片信息

$identify image.png  
image.png PNG 559x559 559x559+0+0 8-bit sRGB 467KB 0.000u 0:00.008  
如果只需要获取宽高：

$identify -format "%wx%h" image.png  
2，放大，缩小 -resize

$convert image.png -resize 200x200 resize.png  
也可以按照比例（缩小一半）：

$convert image.png -resize 50% resize.png  
还可以多次缩放（先缩小一半，再放大一倍，效果就是变模糊了）：

$convert image.png -resize 50%  -resize 200%  resize.png  
3，放大，缩小 -sample
与resize的区别在于-sample只进行了采样，没有进行插值，所以用来生成缩略图最合适

$convert image.png -sample 50% sample.png  
这个处理的效果就是马赛克：

$convert image.png -sample 10% -sample 1000% sample.png  
4，裁剪 -crop
从（50，50）位置开始，裁剪一个100X100大小的图片：

$convert image.png -crop 100x100+50+50 crop.png  
如果不指定位置，则按照这个大小分隔出小图片，这个命令生成crop-0.png，crop-1.png，crop-2.png……：

$convert image.png -crop 100x100 crop.png  
可以指定裁剪位置的相对位置 -gravity：

$convert image.png -gravity northeast -crop 100x100+0+0 crop.png  
-gravity即指定坐标原点，有northwest：左上角，north：上边中间，northeast：右上角，east：右边中间……
5，旋转 -rotate

$convert image.png -rotate 45 rotate.png  
默认的背景为白色，我们可以指定背景色：

$convert image.png -backround black -rotate 45 rotate.png  
$convert image.png -background #000000 -rotate 45 rotate.png  
还可以指定为透明背景色：

$convert image.png -background rgba(0,0,0,0) -rotate 45 rotate.png  
6，合并
合并指的是将一张图片覆盖到一个背景图片上：

$convert image.png -compose over overlay.png -composite newimage.png  
-compose指定覆盖操作的类型，其中over为安全覆盖，另外还有xor、in、out、atop等等
覆盖的位置可以通过-gravity指定：

$convert image.png -gravity southeast -compose over overlay.png -composite newimage.png  
这是将图片覆盖到底图的右下角。
7，更改图片的alpha通道
分两步：

$convert image.png -define png:format=png32  image32.png  
$convert image32.png -channel alpha -fx "0.5" imagealpha.png  
这个命令首先将image.png的格式改为png32（确保有alpha通道），然后更改alpha通道置为0.5，也就是半透明，值的范围为0到1.0
可以使用将一张透明图片覆盖到原图上的方式做水印图片：

$convert image.png -gravity center -compose over overlay.png -composite newimage.png  
$convert image.png -gravity southeast -compose over overlay.png -composite newimage.png  
8，拼接
横向拼接（+append），下对齐（-gravity south）：

$convert image1.png image2.png image3.png -gravity south +append result.png  
纵向拼接（-append），右对齐（-gravity east）：

$convert image1.png image2.png image3.png -gravity east -append result.png  
9，格式转换

$convert image.png image.jpg  
$convert image.png -define png:format=png32 newimage.png  
10，文字注释

$convert image.png -draw "text 0,20 'some text'" newimage.png  
从文件text.txt中读取文字，指定颜色，字体，大小，位置：

$convert source.jpg -font xxx.ttf -fill red -pointsize 48 -annotate +50+50 @text.txt result.jpg  
11，去掉边框
$convert image.png -trim -fuzz 10% newimage.png
