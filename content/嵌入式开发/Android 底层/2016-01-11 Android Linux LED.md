---
title: Android LED 输出
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android底层]
tags:
---
1.2 LED使用1.2.1前言
Firefly-RK3288开发板上有 2 个 LED 灯，如下表所示：
LED GPIO ref. GPIO number
Blue GPIO8_A1 257
Yellow GPIO8_A2 258
可通过使用 LED 设备子系统或者直接操作 GPIO 控制该 LED。
1.2.2以设备的方式控制 LED
标准的 Linux 专门为 LED 设备定义了 LED 子系统。 在 Firefly-RK3288 开发板中的两个 LED 均以设备的形式被定义。
用户可以通过 /sys/class/leds/ 目录控制这两个LED。
更详细的说明请参考 leds-class.txt 。
开发板上的 LED 的默认状态为：
§ Blue:系统上电时打开
§ Yellow：用户自定义
用户可以通过 echo 向其 trigger 属性输入命令控制每一个 LED：
root@firefly:~ # echo none >/sys/class/leds/firefly:blue:power/trigger
root@firefly:~ # echo default-on >/sys/class/leds/firefly:blue:power/trigger
用户还可以使用 cat 命令获取 trigger 的可用值：
root@firefly:~ # cat /sys/class/leds/firefly:blue:power/trigger
none [ir-power-click] test_ac-online test_battery-charging-or-full test_battery-chargingtest_battery-full test_battery-charging-blink-full-solid test_usb-online mmc0 mmc1 mmc2backlight default-on rfkill0 rfkill1 rfkill2
1.2.3 在内核中操作 LED
在内核中操作 LED 的步骤如下：
1、在 dts 文件中定义 LED 节点“leds”
在kernel/arch/arm/boot/dts/firefly-rk3288.dts 文件中定义LED节点，具体定义如下：
leds {
  compatible ="gpio-leds";
  power {
    label ="firefly:blue:power";
    linux,default-trigger ="ir-power-click";
    default-state ="on";
    gpios =<&gpio8 GPIO_A1 GPIO_ACTIVE_LOW>;
    };
  user{
    label ="firefly:yellow:user";
    linux,default-trigger ="ir-user-click";
    default-state ="off";
    gpios =<&gpio8 GPIO_A2 GPIO_ACTIVE_LOW>;
    };
  };

注意：compatible 的值要跟 drivers/leds/leds-gpio.c 中的 .compatible 的值要保持一致。
2、在驱动文件包含头文件
#include <linux/leds.h>
3、在驱动文件中控制 LED。
（1）、定义 LED 触发器
DEFINE_LED_TRIGGER(ledtrig_ir_click);
（2）、注册该触发器
led_trigger_register_simple("ir-power-click",&ledtrig_ir_click);
（3）、控制 LED 的亮灭。
led_trigger_event(ledtrig_ir_click, LED_FULL);//亮
led_trigger_event(ledtrig_ir_click, LED_OFF);//灭
