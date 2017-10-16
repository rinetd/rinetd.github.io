---
title: Android gpio输出
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android底层]
tags:
---
使用手册
[Power_ePAPR_APPROVED_v1.1.pdf](http://files.cnblogs.com/files/pengdonglin137/Power_ePAPR_APPROVED_v1.1.pdf)
[GPIO接口解析 ](http://blog.chinaunix.net/uid-27717694-id-3701921.html)
[Device Tree（二）：基本概念](http://www.wowotech.net/device_model/dt_basic_concept.html)
[ Linux加载DTS设备节点的过程(以高通8974平台为例)](http://blog.csdn.net/loongembedded/article/details/48973861)
[msm平台GPIO相关的device tree设置](http://blog.csdn.net/hongzg1982/article/details/47784627)
[我眼中的Linux设备树(四 中断)](http://www.th7.cn/system/lin/201512/147714.shtml)
[Linux 中断(irq)控制器以及device tree设置](http://blog.csdn.net/hongzg1982/article/details/47660649)
源码分析
[Linux驱动基础：device tree](http://blog.csdn.net/hongzg1982/article/details/47308321)
[msm平台GPIO相关的device tree设置](http://blog.csdn.net/hongzg1982/article/details/47784627)
[GIC 驱动代码分析](http://www.360doc.com/content/14/0813/17/14530056_401586832.shtml)
[linux kernel的中断子系统之（七）：GIC代码分析](http://www.wowotech.net/linux_kenrel/gic_driver.html)
[GPIO (Linux)](http://developer.toradex.com/knowledge-base/gpio-%28linux%29)
[为AM335x移植Linux内核主线代码(34)GPIO的dts及驱动](http://bbs.ednchina.com/BLOG_ARTICLE_3027425.HTM)
[gpio_request 原形代码](http://blog.csdn.net/maopig/article/details/7428561)
gpio键盘active_low参数 的作用
active_low = 1，还是active_low =0，要根据硬件的连接，如果按下按键为高电平那么active_low =0，如果按下按键为低电平那么active_low =1.如果这个参数搞错了，按键松开后就不断发按键键码，表现为屏幕上乱动作。
在gpio和中断debug方法


在debug目录下，可以查到每个gpio的输入输出设置，以及当前的值。
查看所有可操作的GPIO
`cat /sys/kernel/debug/gpio`

#cat /d/gpio
//这个命令只会显示AP设置的GPIO信息，不显示Modem设置的GPIO信息

如果想看更详细的GPIO设置的话

#cat /d/gpiomux
//显示AP,CP所有的GPIO的信息

//开始操作GPIO的时候必须要先执行
#echo 30 > /sys/class/gpio/export

//设置GPIO 30的输入输出
#echo "out" > /sys/class/gpio/gpio30/direction
#echo "in"  > /sys/class/gpio/gpio30/direction

//改变GPIO 30的值
#echo 1 > /sys/class/gpio/gpio30/value
#echo 0 > /sys/class/gpio/gpio30/value

//操作完毕需要执行如下命令
#echo 30 > /sys/class/gpio/unexport

查找Wakeup IRQ等

#echo 1 > /sys/module/msm_show_resume_irq/parameters/debug_mask.
//这样输入完之后，如果被中断唤醒就会输出如下log
[ 75.0xxx] pm8xxx_show_resume_irq_chip: 479 triggered
[ 75.0xxx] msm_gpio_show_resume_irq: 392 triggered
[ 75.0xxx] gic_show_resume_irq: 48 triggered
[ 75.0xxx] gic_show_resume_irq: 52 triggered
显示整个中断设置情况

#cat /proc/interrupts

------------
在嵌入式设备中对GPIO的操作是最基本的操作。一般的做法是写一个单独驱动程序，网上大多数的例子都是这样的。其实linux下面有一个通用的GPIO操作接口，那就是我要介绍的 “/sys/class/gpio” 方式。

首先，看看系统中有没有“/sys/class/gpio”这个文件夹。如果没有请在编译内核的时候加入   Device Drivers  —>  GPIO Support  —>     /sys/class/gpio/… (sysfs interface)。

/sys/class/gpio 的使用说明：


gpio_operation 通过/sys/文件接口操作IO端口 GPIO到文件系统的映射

* 控制GPIO的目录位于/sys/class/gpio

* /sys/class/gpio/export文件用于通知系统需要导出控制的GPIO引脚编号

* /sys/class/gpio/unexport 用于通知系统取消导出

* /sys/class/gpio/gpiochipX目录保存系统中GPIO寄存器的信息，包括每个寄存器控制引脚的起始编号base，寄存器名称，引脚总数 导出一个引脚的操作步骤

* 首先计算此引脚编号，引脚编号 = 控制引脚的寄存器基数 + 控制引脚寄存器位数

* 向/sys/class/gpio/export写入此编号，比如12号引脚，在shell中可以通过以下命令实现，命令成功后生成/sys/class/gpio/gpio12目录，如果没有出现相应的目录，说明此引脚不可导出：

echo 12 &gt; /sys/class/gpio/export
* direction文件，定义输入输入方向，可以通过下面命令定义为输出

echo out &gt; direction

* direction接受的参数：in, out, high, low。high/low同时设置方向为输出，并将value设置为相应的1/0。

* value文件是端口的数值，为1或0.

echo 1 &gt; value
下面在2440下进行一下测试

1.取得GPIO信息，在终端中敲入以下命令

$ cd /sys/class/gpio
$ for i in gpiochip* ; do echo `cat $i/label`: `cat $i/base` ; done
终端中显示如下
GPIOA: 0
GPIOE: 128
GPIOF: 160
GPIOG: 192
GPIOH: 224
GPIOB: 32
GPIOC: 64
GPIOD: 96
2.计算GPIO号码

我们把GPE11用来控制LED。

GPE0的头是128，GPE11 就是128+11 = 139.
$ echo 139 >; /sys/class/gpio/export
ls 一下看看有没有 gpio139 这个目录

3.GPIO控制测试。

控制LED所以是输出。

所以我们应该执行
$ echo out > /sys/class/gpio/gpio139/direction
之后就可以进行输出设置了。

$ echo 1 > /sys/class/gpio/gpio139/value
or
$ echo 0 > /sys/class/gpio/gpio139/value

---
Linux driver中gpio_request和gpio_free的调用
一般来说，一个GPIO只是分配给一个设备的，所以这个设备的驱动会请求这个GPIO。这样，在其他的设备也想请求这个GPIO的时候会返回失败。事实上，gpio_request只是给这个GPIO做一个标示，并没有什么实质的作用。操作GPIO是通过gpio_set_value、gpio_direction_output之类的函数去做的，即便没有request，一样可以设置GPIO的电平。

对于设备驱动来说，应该保证每一个在初始化的时候（一般是probe），对和设备有关的GPIO都进行一次gpio_request，在remove时候时候使用gpio_free。当然，如果probe失败，应该在probe里面free掉已经request过的GPIO。每次使用的时候不需要再request和free了，只需要直接gpio_set_value就可以了。

可以参考下kernel里面已有的一些设备驱动，GPIO的操作还是挺基本的，那些设备驱动里都有现成的做法，可供参考。

------
一 概述
  Linux内核中gpio是最简单，最常用的资源(和 interrupt ,dma,timer一样)驱动程序，应用程序都能够通过相应的接口使用gpio，gpio使用0～MAX_INT之间的整数标识，不能使用负数,gpio与硬件体系密切相关的,不过linux有一个框架处理gpio，能够使用统一的接口来操作gpio.在讲gpio核心(gpiolib.c)之前先来看看gpio是怎么使用的
二 内核中gpio的使用
     1 测试gpio端口是否合法 int gpio_is_valid(int number);

     2 申请某个gpio端口当然在申请之前需要显示的配置该gpio端口的pinmux
        `int gpio_request(unsigned gpio, const char *label)`

     3 标记gpio的使用方向包括输入还是输出
       /*成功返回零失败返回负的错误值*/
       int gpio_direction_input(unsigned gpio);
       int gpio_direction_output(unsigned gpio, int value);

     4 获得gpio引脚的值和设置gpio引脚的值(对于输出)
        int gpio_get_value(unsigned gpio);
        void gpio_set_value(unsigned gpio, int value);

     5 gpio当作中断口使用
        int gpio_to_irq(unsigned gpio);
        返回的值即中断编号可以传给request_irq()和free_irq()
        内核通过调用该函数将gpio端口转换为中断，在用户空间也有类似方法

     6 导出gpio端口到用户空间
        int gpio_export(unsigned gpio, bool direction_may_change);
        内核可以对已经被gpio_request()申请的gpio端口的导出进行明确的管理，
        参数direction_may_change表示用户程序是否允许修改gpio的方向，假如可以
        则参数direction_may_change为真
         撤销GPIO的导出
        void gpio_unexport();

三 用户空间gpio的调用
          用户空间访问gpio，即通过sysfs接口访问gpio，下面是/sys/class/gpio目录下的三种文件：
            --export/unexport文件
            --gpioN指代具体的gpio引脚
            --gpio_chipN指代gpio控制器
            必须知道以上接口没有标准device文件和它们的链接。
 (1) export/unexport文件接口：
               /sys/class/gpio/export，该接口只能写不能读
               用户程序通过写入gpio的编号来向内核申请将某个gpio的控制权导出到用户空间当然前提是没有内核代码申请这个gpio端口
               比如  echo 19 > export
               上述操作会为19号gpio创建一个节点gpio19，此时/sys/class/gpio目录下边生成一个gpio19的目录
               /sys/class/gpio/unexport和导出的效果相反。
               比如 echo 19 > unexport
               上述操作将会移除gpio19这个节点。
 (2) /sys/class/gpio/gpioN
       指代某个具体的gpio端口,里边有如下属性文件
      direction 表示gpio端口的方向，读取结果是in或out。该文件也可以写，写入out 时该gpio设为输出同时电平默认为低。写入low或high则不仅可以
                      设置为输出 还可以设置输出的电平。 当然如果内核不支持或者内核代码不愿意，将不会存在这个属性,比如内核调用了gpio_export(N,0)就
                       表示内核不愿意修改gpio端口方向属性

      value      表示gpio引脚的电平,0(低电平)1（高电平）,如果gpio被配置为输出，这个值是可写的，记住任何非零的值都将输出高电平, 如果某个引脚
                      能并且已经被配置为中断，则可以调用poll(2)函数监听该中断，中断触发后poll(2)函数就会返回。

      edge      表示中断的触发方式，edge文件有如下四个值："none", "rising", "falling"，"both"。
           none表示引脚为输入，不是中断引脚
           rising表示引脚为中断输入，上升沿触发
           falling表示引脚为中断输入，下降沿触发
           both表示引脚为中断输入，边沿触发
                      这个文件节点只有在引脚被配置为输入引脚的时候才存在。 当值是none时可以通过如下方法将变为中断引脚
                      echo "both" > edge;对于是both,falling还是rising依赖具体硬件的中断的触发方式。此方法即用户态gpio转换为中断引脚的方式

      active_low 不怎么明白，也木有用过                                                                
 (3)/sys/class/gpio/gpiochipN
      gpiochipN表示的就是一个gpio_chip,用来管理和控制一组gpio端口的控制器，该目录下存在一下属性文件：

      base   和N相同，表示控制器管理的最小的端口编号。
      lable   诊断使用的标志（并不总是唯一的）
      ngpio  表示控制器管理的gpio端口数量（端口范围是：N ~ N+ngpio-1）
四 用户态使用gpio监听中断      
首先需要将该gpio配置为中断
echo  "rising" > /sys/class/gpio/gpio12/edge       
以下是伪代码
int gpio_id;
struct pollfd fds[1];
gpio_fd = open("/sys/class/gpio/gpio12/value",O_RDONLY);
if( gpio_fd == -1 )
   err_print("gpio open");
fds[0].fd = gpio_fd;
fds[0].events  = POLLPRI;
ret = read(gpio_fd,buff,10);
if( ret == -1 )
    err_print("read");
while(1){
     ret = poll(fds,1,-1);
     if( ret == -1 )
         err_print("poll");
       if( fds[0].revents & POLLPRI){
           ret = lseek(gpio_fd,0,SEEK_SET);
           if( ret == -1 )
               err_print("lseek");
           ret = read(gpio_fd,buff,10);
           if( ret == -1 )
               err_print("read");
            /*此时表示已经监听到中断触发了，该干事了*/
            ...............
    }
}
记住使用poll()函数，设置事件监听类型为POLLPRI和POLLERR在poll()返回后，使用lseek()移动到文件开头读取新的值或者关闭它再重新打开读取新值。必须这样做否则poll函数会总是返回。
