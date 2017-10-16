---
title: HTML5+CSS3整体回顾
date: 2016-10-19T09:35:08+08:00
tags:
    - HTMl5
    - CSS3
categories: [Front-End]
top: true
---

> 转载请声明 [原文链接](http://blog.poetries.top/2016/10/19/HTML5+CSS3%E5%9F%BA%E7%A1%80%E5%9B%9E%E9%A1%BE%20/)

这篇文章主要总结H5的一些新增的功能以及一些基础归纳，并不是很详细，后面会一直完善补充新的内容，本文是一些笔记记录，放在这里供自己参考也供他人学习！

#### 第一课 HTML5结构
---

- `HTML5` 是新一代的 `HTML`
- `DTD`声明改变	`<!DOCTYPE html>`
    - 新的结构标签			
    - 注意的地方			
        - `ie8` 不兼容

![一些总结--from-dunitian](http://upload-images.jianshu.io/upload_images/1480597-ce00790dcabf9c47.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
<!--more-->
##### 常用的一些新的结构标签
---

![结构标签](http://upload-images.jianshu.io/upload_images/1480597-4585c0d9a5309443.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![多媒体交互标签](http://upload-images.jianshu.io/upload_images/1480597-a13888da66c8fc8a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### 删除的`HTML`标签
---

- 纯表现的元素：
    - `basefont`
    - `big`
    - `center`
    - `font`
    - `s`
    - `strike`
    - `tt`
    - `u`
- 对可用性产生负面影响的元素：
    - `frame`
    - `frameset`
    - `noframes`
  - 产生混淆的元素：
    - `acronym`
    - `applet`
    - `isindex`
    - `dir`
- **重新定义的`HTML`标签**
  - `<b>`  代表内联文本，通常是粗体，没有传递表示重要的意思
  - `<i> ` 代表内联文本，通常是斜体，没有传递表示重要的意思
  - `<dd>` 可以同`details`与`figure`一同使用，定义包含文本，`ialog`也可用
  - `<dt>` 可以同`details`与`figure`一同使用，汇总细节，`dialog`也可用
  - `<hr> `表示主题结束，而不是水平线，虽然显示相同
  - `<menu>` 重新定义用户界面的菜单，配合`commond`或者`menuitem`使用
  - `<small>` 表示小字体，例如打印注释或者法律条款
  - `<strong>` 表示重要性而不是强调符号

- 崭新新的页面布局

![传统的布局](http://upload-images.jianshu.io/upload_images/1480597-b8990303b1d10379.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![HTML5标签布局](http://upload-images.jianshu.io/upload_images/1480597-a7b3e5dca9341862.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![实例-from-dunitian](http://upload-images.jianshu.io/upload_images/1480597-6f30a458860e606f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![草图--from-dunitian](http://upload-images.jianshu.io/upload_images/1480597-dd4078736467f182.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 第二课 HTML5智能表单
---

##### HTML4.01 form表单复习
---

- `input`表单`type`属性值
    - `type="text"  `          单行文本输入框
    - `type="password" `  密码（`maxlength=""`）
    - `type="radio"   `       单项选择（`checked="checked"`）
    - `type="checkbox" `  多项选择
    - `type="button" `     按钮
    - `type="submit"`	     提交
    - `type="file"`           上传文件
    - `type="reset"	 `    重置

##### HTML5智能表单
---

- `input`表单`type`属性值：
    - `type = "email" ` 限制用户输入必须为`Email`类型
    - `type="url"`	      限制用户输入必须为`URL`类型
    - `type="date" `     限制用户输入必须为日期类型
    - `type="datetime"` 显示完整日期 含时区
    - `type="datetime-local" ` 显示完整日期 不含时区
    - `type="time"  `    限制用户输入必须为时间类型
    - `type="month" `  限制用户输入必须为月类型
    - `type="week" `    限制用户输入必须为周类型
    - `type="number"` 限制用户输入必须为数字类型
    - `type="range"`    生成一个滑动条
    - `type="search"`  具有搜索意义的表单`results="n"`属性
    - `type="color" `    生成一个颜色选择表单
    - `type="tel" `    显示电话号码


##### Input 类型 - Date Pickers（日期选择器）
---

- **`HTML5` 拥有多个可供选取日期和时间的新输入类型：
- `date` 选取日、月、年
- `month` 选取月、年
- `week`  选取周和年
- `time `  选取时间（小时和分钟）

- 以下两个没有作用
    - `datetime`  选取时间、日、月、年（UTC 时间）
    - `datetime-local`  选取时间、日、月、年（本地时间）

##### HTML5新增表单属性
---
- `required:` `required `内容不能为空
- `placeholder:` 表单提示信息
- `autofocus:`自动聚焦
- `pattern:` 正则表达式  输入的内容必须匹配到指定正则范围
- `autocomplete:`是否保存用户输入值
   - 默认为`on`，关闭提示选择`off`
- `formaction:` 在`submit`里定义提交地址
- `datalist:` 输入框选择列表配合`list`使用 ` list`值为`datalist`的`id`值
- `output:` 计算或脚本输出

##### 表单验证
---

- `validity`对象，通过下面的`valid`可以查看验证是否通过，如果八种验证都返回`true`,一种验证失败返回`false`

    - `oText.addEventListener("invalid",fn1,false)`
    - `ev.preventDefault()`: 阻止默认事件
    - `valueMissing`: 当输入值为空的时候，返回`true`
    - `typeMismatch`: 控件值与预期不吻合，返回`true`
    - `patternMismatch`: 输入值不满足`pattern`正则，返回`true`
    - `cusomError`
      - `setCustomValidity()`

#### 第三课 css3选择器
---

- `CSS3`发展史简介

    - `HTML`的诞生 20世纪90年代初
    - `1996`年底，	`CSS`第一版诞生
    - `1998`年`5`月 	`CSS2`正式发布
    - `2004`年 	`CSS2.1`发布
    - `CSS3`的发布	`2002 ` `2003`  `2004` `2005`  `2007` `2009` `2010`


- **模块化开发**

    - `CSS1` 中定义了网页的基本属性：
        - 字体、颜色、基本选择器等
    - `CSS2`中在`CSS1`的基础上添加了高级功能
         - 浮动和定位、高级选择器等(子选择器、相邻选择器、通用选择器)
    - `CSS3`遵循的是模块化开发。发布时间并不是一个时间点，而是一个时间段

- **`CSS`选择器复习**

    - 通用选择器：`* ` 选择到所有的元素
    - 选择子元素：`>` 选择到元素的直接后代
    - 相邻兄弟选择器：`+ `选择到紧随目标元素后的第一个元素
    - 普通兄弟选择器：`~ `选择到紧随其后的所有兄弟元素
    - 伪元素选择器：
    	- `::first-line` 匹配文本块的首行
    	- `::first-letter` 选择文本块的首字母
    - 伪类选择器：
    	- `:before`,`:after`在元素内容前面、后面添加内容(相当于行内元素)


- **CSS3结构选择器**

![CSS3结构选择器](http://upload-images.jianshu.io/upload_images/1480597-33def0f200fe738a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


- **`Css3` 属性选择器**


![Css3属性选择器](http://upload-images.jianshu.io/upload_images/1480597-f9339ed4dcc201aa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


- **`CSS3`伪类选择器**

  - **UI伪类选择器：**
    - `:enabled `选择启用状态元素
    - `:disabled` 选择禁用状态元素
    - `:checked `选择被选中的`input`元素（单选按钮或复选框）
    - `:default` 选择默认元素
    - `:valid`、`invalid` 根据输入验证选择有效或无效的`input`元素
    - `:in-range`、`out-of-range`选择指定范围之内或者之外受限的元素
    - `:required`、`optional `根据是否允许:`required`属性选择`input`元素

  - **动态伪类选择器：**
    - `:link `选择链接元素
    - `:visited` 选择用户以访问的元素
    - `:hover` 鼠标悬停其上的元素
    - `:active `鼠标点击时触发的事件
    - `:focus` 当前获取焦点的元素

  - **其他伪类选择器**：
    - `:not(<选择器>) `对括号内选择器的选择取反
    - `:lang(<目标语言>)` 基于`lang`全局属性的元素
    - `:target` `url`片段标识符指向的元素
      - `:empty`选择内容为空的元素
    - `:selection `鼠标光标选择元素内容

#### 第四课 CSS3新增文本属性
---

- **CSS文本属性复习**
    - `white-space`：对象内空格的处理方式
      - `nowrap` 控制文本不换行

      - `pre` 空白会被浏览器保留

      - `pre-line` 合并空白  保留换行符

      - `pre-wrap` 保留空白  正常换行

    - `direction`：文本流的方向
      - `ltr` 文本从左向右
      - `rtl`  文本从右往左

    - `unicode-bidi`：用于同一个页面里存在从不同方向读进的文本显示。与`direction`属性一起使用

- **CSS3新增文本属性**

    - `color:rgba()`;
    - `text-overflow`:是否使用一个省略标记（...）标示对象内文本的溢出
    - `text-align`:文本的对齐方式
    - `text-transform`:文字的大小写
    - `text-decoration`:文本的装饰线，复合属性
    - `text-shadow`:文本阴影
    - `text-fill-color`:文字填充颜色
    - `text-stroke`:复合属性。设置文字的描边
    - `tab-size`:制表符的长度
    - `word-wrap`:当前行超过指定容器的边界时是否断开转行
    - `word-break`:规定自动换行的处理方法


- **`text-overflow:`是否使用一个省略标记（`...`）标示对象内文本的溢出**
    - `clip`： 默认值 无省略号
    - `ellipsis`：当对象内文本溢出时显示省略标记（`...`）。
    - **注意**：该属性需配合`over-flow:hidden`属性(超出处理)还有 `white-space:nowrap`(禁止换行)配合使用，否则无法看到效果

- **`text-align`:文本的对齐方式**
    - `css1`
    - `left`:默认值 左对齐
    - `right`:右对齐
    - `center`:居中
    - `justify`： 内容两端对齐。
    - `css3`
    - `start`:开始边界对齐
    - `end`:结束边界对齐

- **`text-transform`**:文字的大小写
    - **`css1`**
        - `none`：	默认值 无转换
        - `capitalize`： 	将每个单词的第一个字母转换成大写
        - `uppercase`：	转换成大写
        - `lowercase`：	转换成小写
    - **`css3`**
        - `full-width`：	将左右字符设为全角形式。不支持
        - `full-size-kana`：将所有小假名字符转换为普通假名。不支持
			- 例如：土耳其语

- **`text-decoration`:文本的装饰线，复合属性(只火狐支持)**
    - `text-decoration-line `：
         - 指定文本装饰的种类。相当于`CSS1`时的`text-decoration`属性
    - `text-decoration-style` ：
        - `指定文本装饰的样式。
    - `text-decoration-color`：
         - `指定文本装饰的颜色。
    - `blink`： 指定文字的装饰是闪烁。  `opera`和`firefox`
    - `text-decoration` : `#F00 double overline`   `CSS3`实例

- **`text-shadow`:文本阴影**
    - 取值：`x ` `y`   `blur` `color`,......
        - `x  `  	横向偏移
        - `y `   	纵向偏移
        - `blur `     模糊距离(灰度)
        - `color`    阴影颜色

- `text-fill-color`:文字填充颜色
- `text-stroke`:复合属性。设置文字的描边
  - `text-stroke-width`:文字的描边厚度
  - `text-stroke-color`:文字的描边颜色
- `tab-size`:制表符的长度   
    - 默认值为`8`(一个`tab`键的空格字节长度)，在	`pre`标签之内才会有显示
- `word-wrap`:当前行超过指定容器的边界时是否断开转行
	- `normal`： 默认值
	- 允许内容顶开或溢出指定的容器边界。
- `break-word`：
    - 内容将在边界内换行。如果需要，单词内部允许断行


#### 第五课 CSS3盒模型
---

- CSS盒模型复习

![标准盒子模型](http://upload-images.jianshu.io/upload_images/1480597-320bad065d62c499.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![IE盒子模型](http://upload-images.jianshu.io/upload_images/1480597-693242e2f03506f8.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **CSS3弹性盒模型**

    - `display:box`或者`display:inline-box`;  设置给父元素
    - `box-orient `定义盒模型的布局方向   设置给父元素
    	- `horizontal` 水平显示
    	- `vertical` 垂直方向
    - `box-direction` 元素排列顺序     设置给父元素
    	- `normal`  正序
        - `reverse`  反序
    - `box-ordinal-group`  设置元素的具体位置   设置子元素


- `flex`布局语法篇

![flex布局语法篇小结](http://upload-images.jianshu.io/upload_images/1480597-885b1d526653b87d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 拓展阅读
    - [flex布局语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)
    - [flex布局实例篇](http://www.ruanyifeng.com/blog/2015/07/flex-examples.html)


#### 第六课 css3新增背景属性
---

- **CSS背景属性复习**
  - `background`:
	  - `background-color`:背景颜色
	  - `background-image`:背景图片
	  - `background-repeat`:背景重复
	  - `background-position`:背景定位
	  - `background-attachment`:背景固定(`scroll/fixed)`

- **CSS3新增背景属性**

- `background-size`  背景尺寸
	- `background-size:x y`
	- `background-size:100% 100%`
	- `background-size:cover` 比例放大
    - `background-size:contain` 包含（图片不溢出）

- **多背景**
  - `background:url() 0 0,url() 0 100%`;
  - `background-origin ` 背景区域定位
  - `border-box`： 从`borde`r区域开始显示背景。
  - `padding-box`： 从`padding`区域开始显示背景。
  - `content-box`： 从`content`内容区域开始显示背
  - `background-clip`   背景绘制区域
  - `border-box`： 从`border`区域向外裁剪背景。
  - `padding-box`： 从`padding`区域向外裁剪背景。
  - `content-box`： 从`content`区域向外裁剪背景。
  - `text`:背景填充文本
  - `no-clip`： 从`border`区域向外裁剪背景

- **颜色渐变**
  - **线性渐变**：`linear-gradient`(起点/角度，颜色 位置，...,)
      - 起点：`left/top/right/bottom/left top...... `默认`top`
      - 角度：逆时针方向 `0-360`度
      - 颜色 位置：`red 50%`, `blue 100%`(红色从50%渐变到100%为蓝色)

    - `repeating-linear-gradient`  线性渐变重复平铺
       - `IE`低版本渐变(滤镜)：
	   - `filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff',endColorstr='#ff0000',GradientType='1');`

  - **径向渐变**：`radial-gradient`(起点(圆心位置), 形状/半径/大小，颜色1，颜色2)
      - 起点：`left/top/right/bottom`或具体值/百分比
      - 形状：`ellipse`(椭圆)、`circle`(正圆)
      - 大小：具体数值或百分比，也可以是关键字（`closest-side`(最近端), `closest-corner`最近角), `farthest-side`(最远端), f`arthest-corner`(最远角), `contain`(包含) ,`cover`(覆盖)）;



#### 第七课 css3新增颜色属性
---

- **CSS颜色属性复习**

    - `color name `    颜色英文名称命名
    - `HEX`方式         十六进制方式
    - `rgb`方式           三原色配色方式

- **CSS3新增颜色属性**

    - **`rgba()`**

|名称|颜色|颜色|取值|
|---|---|---|---|
|r    |     red      |	  红色   |  0-255|
|g     |   green   |  绿色  |  0-255|
|b     |   blue    |   蓝色   |  0-255|
|a      |  alpha    | 透明  |   0-1|


- **`HSL`模式  `HSLA`模式**

    - `H`： `Hue`(色调)。
        - 0(或360)表示红色，120表示绿色，240表示蓝色，也可取其他数值来指定颜色。取值为：`0 - 360`
    - `S`：` Saturation`(饱和度)。取值为：0.0% - 100.0%
    - `L`： `Lightness`(亮度)。取值为：0.0% - 100.0%
    - `A`:    `alpha  `   透明度   0~1之间

    - 语法:`HSLA(H,S,L,A)`

- HSL色轮


![HSL色轮](http://upload-images.jianshu.io/upload_images/1480597-e966854f01e64406.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


- 透明颜色：`transparent`
    - 实例：`border`实现三角箭头、风车等

- 透明度：
	- `opacity`
	- 取值：`0-1`之间
	- 注：低版本的`IE`浏览器不兼容,需用IE浏览器的滤镜实现相同效果，`filter:alpha(opacity=50)`
	- 对于低版本的火狐浏览器需添加内核前缀，`-moz-opacity`


#### 第八课 CSS3边框系列
---

##### 圆角-阴影
---

- 边框圆角
    - 在` CSS2 `中添加圆角矩形需要技巧。我们必须为每个圆角使用不同的图片
    - 在 `CSS3 `中，创建圆角是非常容易的
    - 在` CSS3 `中，`border-radius `属性用于创建圆角

- **`border-radius`边框圆角写法**
  - `border-radius: 2em 1em 4em / 0.5em 3em;`
  - 等价于
```css
border-top-left-radius: 2em 0.5em;
border-top-right-radius: 1em 3em;
border-bottom-right-radius: 4em 0.5em;
border-bottom-left-radius: 1em 3em;
```

- **`box-shadow`方框添加阴影**
    - 语法：`box-shadow:x-shadow y-shadow blur spread color inset;`

    - **box-shadow的API**
        - `x-shadow	` 必需。水平阴影的位置。允许负值。
        - `y-shadow` 	必需。垂直阴影的位置。允许负值。
        - `blur	` 	可选。模糊距离。
        - `spread` 	可选。阴影的尺寸。
        - `color` 	可选。阴影的颜色。请参阅 `CSS `颜色值
        - `inset` 	可选。将外部阴影 (`outset`) 改为内部阴影
    - 实例：`box-shadow:10px 10px 5px 5px #888888;`

##### 边框系列-图片
---

- **`border-image`语法**

|属性|	版本|	简介|
|---|---|---|
|border-image|	CSS3|	设置或检索对象的边框使用图像来填充|
|border-image-source| CSS3|设置或检索对象的边框是否用图像定义样式或图像来源路径|
|border-image-slice|	CSS3|	设置或检索对象的边框背景图的分割方式|
|border-image-width|	CSS3|	设置或检索对象的边框厚度|
|border-image-outset|	CSS3|	设置或检索对象的边框背景图的扩展|
|border-image-repeat|	CSS3|	设置或检索对象的边框图像的平铺方式|

- **`border-image-slice`**
  - 设置或检索对象的边框背景图的分割方式

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1480597-b6daa34d69905a1d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- **`border-image-repeat`**
  - 用于指定边框背景图的重复方式
  - 取值：
    - `stretch`： 指定用拉伸方式来填充边框背景图。 *默认的
    - `repeat`： 指定用平铺方式来填充边框背景图。当图片碰到边界时，如果超过则被截断。
    - `round`： 指定用平铺方式来填充边框背景图。图片会根据边框的尺寸动态调整图片的大小	直至正好可以铺满整个边框。写本文档时仅Firefox能看到该效果


#### 第九课 CSS3运动体系
---

##### 过渡
---

- 过渡：给改变添加过程
    - 什么是过渡
    - 过渡效果由哪几部分组成
    - 过渡可以干些什么

- `transition` 过渡属性

- `transition: property duration timing-function delay`;
	- `transition-property:`过渡属性的名称
    	- `none `  没有过渡属性
    	- `all  `      所有属性都过渡(默认值)
    	- `property `   具体属性名称(`property1`,`property2`...)
	- `transition-duration:`过渡属性花费的时间
	    - `time `  秒或毫秒
	- `transition-timing-function:`过渡效果速度曲线
	    - `time `  秒或毫秒
	- `transition-delay:`过渡效果延迟时间

- **`transition-timing-function`:过渡效果速度曲线**
	- `linear`:规定以相同速度开始至结束的过渡效果（等于 `cubic-bezier(0,0,1,1)`）。
	- `ease`:规定慢速开始，然后变快，然后慢速结束的过渡效果（`cubic-bezier(0.25,0.1,0.25,1)`）。
	- `ease-in`:规定以慢速开始的过渡效果（等于 `cubic-bezier(0.42,0,1,1)`）。
	- `ease-out`	:规定以慢速结束的过渡效果（等于 `cubic-bezier(0,0,0.58,1)`）。
	- `ease-in-out` :规定以慢速开始和结束的过渡效果（等于 `cubic-bezier(0.42,0,0.58,1)`）。
	- `cubic-bezier(n,n,n,n)`:在 `cubic-bezier` 函数中定义自己的值。可能的值是 `0 `至 `1` 之间的数值。

- 过渡完成事件   
![过渡完成事件](http://upload-images.jianshu.io/upload_images/1480597-f8a2291a249961ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- `Webkit`内核：
```javascript
obj.addEventListener('webkitTransitionEnd',function(){})
```

- 标准:

```javascript
obj.addEventListener('transitionend',function(){})
```

##### 动画
---

- 什么是`CSS3` 动画？
  - 通过 `CSS3`，我们能够创建动画，这可以在许多网页中取代动画图片、`Flash` 动画以及 `JavaScript`

- **动画接口**


|属性  | 描述 |
|---|---|
| @keyframes|	规定动画。|
| animation	|所有动画属性的简写属性，除了 animation-play-state 属性。|
| animation-name	|规定 @keyframes 动画的名称。|
| animation-duration	|规定动画完成一个周期所花费的秒或毫秒。|
| animation-timing-function|	规定动画的速度曲线。|
| animation-delay	|规定动画何时开始。|
| animation-iteration-count	|规定动画被播放的次数。|
| animation-direction	|规定动画是否在下一周期逆向地播放。|
| animation-play-state|	规定动画是否正在运行或暂停。|
| animation-fill-mode	|规定对象动画时间之外的状态。|

- **animation-timing-function速度曲线**


|值 |	描述
|---|---|
|linear 	|动画从头到尾的速度是相同的。|
|ease |	默认。动画以低速开始，然后加快，在结束前变慢。|
|ease-in |	动画以低速开始。 |
|ease-out |	动画以低速结束。 |
|ease-in-out |	动画以低速开始和结束。 |
|cubic-bezier(n,n,n,n) |	在 cubic-bezier 函数中自己的值。可能的值是从 0 到 1 的数值。 |

- 在谷歌浏览器里面需要加上`-webkit-`
`IE6,7,8,9`不支持`css3`运动

- 拓展阅读
  - [CSS3动画简介](http://note.youdao.com/noteshare?id=c4f5a977a7b3aa256a3c28aa64d6f989)


- **CSS3盒模型阴影**

    - `box-shadow:inset x y blur spread color`
    - `inset`：投影方式
    - `inset`：内投影
    - `outset`：外投影 默认(不能设置)
    - `x`、`y`：阴影偏移
    - `blur`：模糊半径（灰度）
    - `spread`：扩展阴影半径
    -  先扩展原有形状，再开始画阴影
    - `color`

- **`CSS3`盒模型倒影**

- `box-reflect` 倒影
	- 方向 ` above|below|left|right;`
	- 距离
    - 渐变（可选）

- **CSS3其他盒模型**

    - `box-sizing` 盒模型解析模式
    - `content-box`  标准盒模型(和`css2`一样的计算)
    - `width/height=border+padding+content`
    - `border-box` 怪异盒模型` width/height`与设置的值一样 ，`content`减小

- 扩展阅读
  - [学会使用css3的box-sizing布局](http://www.jianshu.com/p/e2eb0d8c9de6)

#### 第十课 transform 2D转换
---

- **`Css3`平面转换方法**
  - `translate() `		移动
  - `rotate()`		旋转
  - `scale()`		缩放
  - `skew()`		翻转
  - `matrix()	`	矩阵


- **transform**:
	- `rotate()`  旋转函数 (deg)
        - `deg`  度数
	- `skew(X,Y)` 倾斜函数 (deg)
        - `skewX()`
        - `skewY()`
	- `scale(X,Y)` 缩放函数 (正数、负数和小数)
        - `scaleX()`
        - `scaleY()`
	- `translate(X,Y)` 位移函数(px)
        - `translateX()`
        - `translateY()`


- **`rotate()` 旋转方法**
  - 用于旋转元素角度
  - 例：`rotate(30deg) `
    - 把元素顺时针旋转 30 度

- **`translate()`位置方法**
  - 用于移动元素位置
    - 例：`translate(50px,100px)`
      - 把元素从左侧移动 50 像素，从顶端移动 100 像素。
  - 其实有些类似于我们的相对定位

- **`scale()`尺寸方法**
  - 方法用于改变元素尺寸
    - 例：`scale(2,4)`
      - 把宽度转换为原始尺寸的 2 倍，把高度转换为原始高度的 4 倍

- **`skew()` 翻转方法**
  - 通过 `skew() `方法，元素翻转给定的角度
   - 例：`transform: skew(30deg,20deg);`
     - 把元素围绕 `X `轴把元素翻转` 30` 度，围绕 `Y` 轴翻转 `20 `度

#### 第十一课 transform 3D转换
---

- **`Css3`立体转换**
    - `transform-style（preserve-3d）` 建立`3D`空间
    - `Perspective` 视角
    - `Perspective- origin` 视角基点
    - `transform-origin`：坐标轴基点

- **transform 新增函数**
    - `rotateX()`
    - `rotateY()`
    - `rotateZ()`
    - `translateZ()`
    - `scaleZ()`

#### 第十二课 视频音频
---

- 视频音频格式的简单介绍
  - 常见的视频格式
    - 视频的组成部分：画面、音频、编码格式
    - 视频编码：H.264、Theora、VP8(google开源)
  - 常见的音频格式
    - 视频编码：ACC、MP3、Vorbis

- **`HTML5`支持的格式**
---

- `HTML5`能在完全脱离插件的情况下播放音视频,但是不是所有格式都支持。
- **支持的视频格式：**
    - `Ogg=`带有`Theora`视频编码`+Vorbis`音频编码的`Ogg`文件
    - `MEPG4=`带有H.264视频编码`+AAC`音频编码的`MPEG4`文件
    - `WebM=`带有`VP8`视频编码`+Vorbis`音频编码的`WebM`格式

##### `Video`的使用
---

- **单独用法**
  - `<video src="文件地址" controls="controls"></video>`
- **带提示用法**

```html
< video src="文件地址" controls="controls">
	您的浏览器暂不支持video标签。播放视频
</ video >
```

- **兼容用法**

```html
< video  controls="controls"  width="300">
	<source src="move.ogg" type="video/ogg" >
	<source src="move.mp4" type="video/mp4" >
	您的浏览器暂不支持video标签。播放视频
</ video >
```

- **`Video`的常见属性**

|属性|	值|	描述|
|---|---|---|
|Autoplay|	Autoplay|	视频就绪自动播放|
|controls|	controls|	向用户显示播放控件|
|Width|	Pixels(像素)|	设置播放器宽度|
|Height|	Pixels(像素)|	设置播放器高度|
|Loop|	Loop|	播放完是否继续播放该视频，循环播放|
|Preload	|load{auto,meta,none}|	规定是否预加载视频。|
|Src	|url	|视频url地址|
|Poster|	Imgurl	|加载等待的画面图片|
|Autobuffer|	Autobuffer	|设置为浏览器缓冲方式，不设置autoply才有效|

- **`Video`的`API`方法**

|方法|	属性|	事件|
|---|---|---|
|play()|	currentSrc|	play|
|pause()|	currentTime|	pause|
|load()|	videoWidth|	progress|
|canPlayType()|	videoHeight|	error|

#### 第十三课 canvas
---

- 标签 `<canvas>`
  - 不支持`canvas` 的浏览器可以看到的内容
- `<canvas>` 绘制环境
  - `getContext("2d")`;目前支持`2d`的场景


- **绘制矩形**
  - `rect(L,T,W,H)`:创建一个矩形
  - `fillRect(L,T,W,H)`:绘制填充的矩形
  - `strokeRect(L,T,W,H)`绘制矩形(无填充)
    - 默认一像素黑色边框
- **设置绘图**
  - `fillStyle`:填充颜色(绘制`canvas`是有顺序的)
  - `lineWidth`:线宽度，笔迹粗细
  - `strokeStyle`:边线颜色
- **绘制路径**
  - `stroke` ：绘制，划线(黑色默认)
  - `fill` :填充(黑色默认)
  - `rect(矩形区域)`
  - `clearRect` 擦除一个矩形区域
  - `save` 进入到XXX（高逼格）状态
  - `restore` 退出xxx（高逼格）状态

- **绘制圆形**
  - `arc(x,y,半径,起始弧度,结束弧度,旋转方向)`
  - `x`，`y`起始位置
  - 弧度与角度：`弧度=角度 x π / 180`
  - 旋转方向：顺时针（默认：`false`），逆时针（`true`）
- **绘制字体**
  - `font`：设置字体大小
  - `fillText`：填充字体
  - `strokeText`：绘制字体
- 扩展阅读
	- [canvas学习之API整理笔记（一）](http://luckykun.com/work/2016-09-01/canvas-study01.html)
	- [HTML5 API大盘点](http://jartto.wang/2016/07/25/make-an-inventory-of-html5-api/)


#### 第十四课 SVG绘图
---

- **svg是什么**
  - 矢量图
  - 与`canvas`的区别

- **svg的引入方式**

- 方式一：
```html
<?xml version="1.1" encoding="utf-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"      	"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg"></svg>
```
- 方式二：
	- 图片、背景、框架
- 方式三:
	- `html`页面中添加`svg`

- **`circle`:圆形**
    - 圆心坐标  `cx`,`cy`
    - 半径  `r`
    - `fill`   `stroke `  `stroke-width`     `stlye`样式
    - `fill = "none/transparent" `
- **ellipse:椭圆**
    - `cx`属性定义的椭圆中心的x坐标
    - `cy`属性定义的椭圆中心的y坐标
    - `rx`属性定义的水平半径
    - `ry`属性定义的垂直半径
- **rect : 矩形**
    - `width`  `height ` 宽高   
    - 坐标 ` x`,` y`
    - 圆角  `rx`,`ry`
- **`line `:线条**
    - `x1`,`y1`,`x2`,`y2`
    - `stroke-opacity`  透明  `fill-opacity`

- **polyline:折线**
  - `points`:点坐标（`x1 y1 x2 y2...`）或(`x1,y1,x2,y2....`)
- **polygon:多边形**
  - 折线闭合  `fill-rule:evenodd/nonzero`;
- **path: 路劲**
    - `d`属性
    - `M(起始坐标)`,`L(结束坐标)`,`H(水平线)`,`V(垂直线)`,`A(圆弧)`,`Z(闭合路劲)`
        - `C`,`S`,`Q`,`T` 贝塞尔曲线
        - 大写为绝对坐标(具体的坐标位置)
        - 小写为相对坐标(相对起始坐标点的具体长度)
    - A命令
        - `x`半径 `y`半径 角度  弧长(0 小弧 1大弧)  方向(0逆时针 1顺时针)
        - 终点`(x y)`

- **C命令：三次贝塞尔曲线**
  - `(x1,y1,x2,y2,x,y)`    `x1`,`y1 `控制点一    `x2`,`y2 `控制点二   ` x`,`y `结束点
- **S命令：平滑贝塞尔曲线(自动对称一个控制点)**
  - `(x2,y2,x,y) `  `x2`,`y2`控制点    x,y结束点
- **Q命令：二次贝塞尔曲线**
  - `(x1,y1,x,y)`   x1,y1控制点  x,y结束点
- **T命令：一次贝塞尔曲线**
  - `(x,y)`结束点

- **`g`标签:组合元素  设置元素公共属性**
    - 共用属性
    - `transform = "translate(0,0)"`

- **`text`标签**
    - `x`, `y`, `text-anchor`(对齐start end middle)	`font-size `

- **`image` 标签**
    - `x`, `y`, `width`  `height `
    - `xlink:href`(图片地址)


#### 第十五课 地理信息与本地存储
---

##### 地理位置
---

- 经度  :   南北极的连接线
- 纬度  :   东西连接的线

- 位置信息从何而来
    - `IP`地址
    - `GPS`全球定位系统
    - `Wi-Fi`无线网络
    - 基站

- `avigator.geolocation`
  - 单次定位请求  ：`getCurrentPosition`(请求成功,请求失败,数据收集方式)
  - **请求成功函数**
    - 经度 :  `coords.longitude`
    - 纬度 :  `coords.latitude`
    - 准确度 :  `coords.accuracy`
    - 海拔 : ` coords.altitude`
    - 海拔准确度 :  `coords.altitudeAcuracy`
    - 行进方向 :  `coords.heading`
    - 地面速度 :  `coords.speed`
    - 请求的时间: `new Date(position.timestamp)`

  - **请求失败函数**
    - 失败编号  ：`code`
      - 0  :  不包括其他错误编号中的错误
      - 1  :  用户拒绝浏览器获取位置信息
      - 2  :  尝试获取用户信息，但失败了
      - 3  :   设置了`timeout`值，获取位置超时了
  - **数据收集 :  json的形式**
      - `enableHighAcuracy`  :  更精确的查找，默认`false`
      - `timeout ` :  获取位置允许最长时间，默认`infinity`
      - `maximumAge` :  位置可以缓存的最大时间，默认`0`

  - **多次定位请求***  : ` watchPosition`
      - 移动设备有用，位置改变才会触发
      - 配置参数：`frequency` 更新的频率
      - 关闭更新请求  :  `clearWatch`

  - **百度地图`API`**

```javascript
<script src="http://api.map.baidu.com/api?v=2.0&ak=qZfInp9MaT9Qa0PoNy4Rmx3Y9W9ZXMfw"></script>
```

##### 本地存储
---

- **`Storage`**
    - `sessionStorage`
        - `session`临时回话，从页面打开到页面关闭的时间段
        - 窗口的临时存储，页面关闭，本地存储消失
    - `localStorage`
        - 永久存储（可以手动删除数据）

- **`Storage`的特点**
    - 存储量限制 ( 5M )
    - 客户端完成，不会请求服务器处理
    - `sessionStorage`数据是不共享、 `localStorage`共享

- **`Storage API`**
    - `setItem()`:
        - 设置数据，(`key`,`value`)类型，类型都是字符串
        - 可以用获取属性的形式操作
    - `getItem():`
        - 获取数据，通过`key`来获取到相应的`value`
    - `removeItem()`:
        - 删除数据，通过key来删除相应的`value`
    - `clear()`:
        - 删除全部存储的值

- **存储事件:**
    - 当数据有修改或删除的情况下，就会触发`storage`事件
    - 在对数据进行改变的窗口对象上是不会触发的`
    - `Key` : 修改或删除的`key`值，如果调用`clear()`,`key`为`null`
    - `newValue`  :  新设置的值，如果调用`removeStorage()`,`key`为`null`
    - `oldValue` :  调用改变前的`value`值
    - `storageArea` : 当前的`storage`对象
    - `url` :  触发该脚本变化的文档的url
    - 注：`session`同窗口才可以,例子：`iframe`操作

#### 第十六课 HTML5新增JS方法
---

- **新增选择器**
    - `document.querySelector() ` 选择单个元素
    - `document.querySelectorAll() ` 选择所有的
    - `document.getElementsByClassName()` 通过类名选择

- **延迟加载JS**

    - `JS`的加载会影响后面的内容加载
      - 很多浏览器都采用了并行加载JS，但还是会影响其他内容
    - `Html5`的`defer`和`async`
      - `defer=“defer ”`: 延迟加载，会按顺序执行，在`onload`执行前被触发
      - `async =“async”`: 异步加载，加载完就触发，有顺序问题
    - 浏览器兼容性：`Labjs`库

- **获取`class`列表属性**
    - `classList`
        - `length` :  `class`的长度
        - `add() ` :  添加`class`方法
        - `remove()`  :  删除`class`方法
        - `toggle()` :  切换`class`方法
        - `contains()` : 判断类名是否存在返回`bool`值

- **`JSON`的新方法**
  - `parse()` : 把字符串转成`json`
    - 字符串中的属性要严格的加上引号
  - `stringify()` : 把`json`转化成字符串
    - 会自动的把双引号加上

  - 与`eval`的区别
    - `eval()`：对任何的字符串进行解析变成js
    - `parse()`：字符串中的属性要严格的加上引号
  - 其他浏览器兼容
    - [去下载json2.js](http://www.json.org/)

- **历史管理**
  - `onhashchange` ：改变hash值来管理
  - `history`  ：
    - 服务器下运行
      - `pushState` :  三个参数 ：数据  标题(都没实现)  地址(可选)
      - `onpopstate`事件 :  读取数据   `event.state`

#### 第十七课 HTML5拖拽事件
---

- 图片自带拖拽功能
- 其他元素可设置`draggable`属性
- **`draggable ：true`**
    - 拖拽元素(被拖拽元素对象)事件 :  
        - `ondragstart` : 拖拽前触发
        - `ondrag` :拖拽前、拖拽结束之间，连续触发
        - `ondragend` :拖拽结束触发
    - 目标元素(拖拽元素被拖到的对象)事件 :  
        - `ondragenter` :进入目标元素触发
        - `ondragover `:进入目标、离开目标之间，连续触发
        - `ondragleave` :离开目标元素触发
        - `ondrop` :在目标元素上释放鼠标触发
            - 需要在`ondragover`事件里面阻止默认事件

- **拖拽兼容问题**
  - 火狐浏览器下需设置`dataTransfer`对象才可以拖拽除图片外的其他标签
    - `dataTransfer`对象
    - `setData()` : 设置数据 `key`和`value`(必须是字符串)
    - `getData()` : 获取数据，根据`key`值，获取对应的`value`
    - `effectAllowed` : 设置光标样式(`none`, `copy`, `copyLink`, `copyMove`, `link`, `linkMove`,` move`, `all` 和` uninitialized`)

    - `setDragImage` ：三个参数（指定的元素，坐标`X`，坐标`Y`）
    - `files`： 获取外部拖拽的文件，返回一个`filesList`列表
        - `filesList`下有个`type`属性，返回文件的类型
- **读取文件信息**
    - `FileReader`(读取文件信息)
        - `readAsDataURL`
    - 参数为要读取的文件对象
        - `onload`当读取文件成功完成的时候触发此事件
        - `this. result` 获取读取的文件数据


#### 第十八课 跨文档操作
---

- **跨文档请求**

- 同域跨文档
	- `iframe`内页：
		- 父页面操作子页面：`contentWindow`
		- 子页面操作父页面：`window.top`(找到最顶级的父页面)/`parent`(第一父页面)
		- 新窗口页：
			- 父页面操作子页面：`window.open`
			- 子页面操作父页面：`window.opener`

- **不同域跨文档**
	- `postMessage（“发送的数据”,”接收的域”）`
		- `message`事件监听
		- `ev.origin `发送数据来源的域
		- `ev.data ` 发送的数据
	- 通过判断发送的数据来执行相应的需求

- **ajax跨域**

    - `XMLHttpRequest` 新增功能
	 	- 跨域请求：修改服务端头信息
		- I`E`兼容：`XDomaiRequest`

    - 进度事件：
		- `upload.onprogress(ev) ` 上传进度(实现文件上传进度条)
			- `ev.total`  发送文件的总量
			- `ev.loaded` 已发送的量
		- `FormData`  构建提交二进制数据


###### 附录一　HTML5速查表
---

- [可以查阅支持H5+CSS3的属性](http://caniuse.com/#search=canvas)
- [HTML5 标签含义之元素周期表](http://www.html5star.com/manual/html5label-meaning/)
- [HTML5标签速查表](http://www.inmotionhosting.com/img/infographics/html5_cheat_sheet_tags.png)

---
-  [本文md文件-仅供参考](https://github.com/poetries/poetries.github.io/blob/dev/source/_posts/HTML5+CSS3%E5%9F%BA%E7%A1%80%E5%9B%9E%E9%A1%BE%20.md)
