---
title: Android GPIO输入
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android底层]
tags:
---
[petazzoni-device-tree-dummies](http://events.linuxfoundation.org/sites/events/files/slides/petazzoni-device-tree-dummies.pdf)
[Android编译系统参考手册](http://android.cloudchou.com/)
[ 键值从键盘到Linux内核传输过程分析](http://blog.csdn.net/kangear/article/details/42265927)
[Android4.2.2自增物理按键frameworks](http://www.2cto.com/kf/201405/298944.html)
[android kl文件](http://blog.csdn.net/mcgrady_tracy/article/details/47358689)
[android4.0 添加一个新的android 键值](http://bbs.9ria.com/thread-244419-1-1.html)
[按键从Linux到Android](http://blog.csdn.net/kangear/article/details/12110951)
[Android下添加新的自定义键值和按键处理流程](http://blog.csdn.net/tkwxty/article/details/43338921)
[android 添加新的键值，自定义按键](http://blog.csdn.net/mr_raptor/article/details/8053871)
[Android添加新键值实现](http://blog.csdn.net/linuxdriverdeveloper/article/details/7241999)
------
扫描码是Linux Input系统中规定的码值 /kernel/include/input.h
Android也定义了一套码，叫作键盘码 .kl

## android kl文件优先级
/system/usr/keylayout/Vendor_XXXX_Product_XXXX_Version_XXXX.kl
/system/usr/keylayout/Vendor_XXXX_Product_XXXX.kl
/system/usr/keylayout/DEVICE_NAME.kl
/data/system/devices/keylayout/Vendor_XXXX_Product_XXXX_Version_XXXX.kl
/data/system/devices/keylayout/Vendor_XXXX_Product_XXXX.kl
/data/system/devices/keylayout/DEVICE_NAME.kl
/system/usr/keylayout/Generic.kl
/data/system/devices/keylayout/Generic.kl

#查看事件和设备的关联
`adb shell cat /proc/bus/input/devices`

I: Bus=0000 Vendor=0000 Product=0000 Version=0000
N: Name="qpnp_pon"
P: Phys=qpnp_pon/input0
S: Sysfs=/devices/virtual/input/input2
U: Uniq=
H: Handlers=kbd event2 cpufreq cpufreq
B: PROP=10
B: EV=3
B: KEY=140000 0 0 0

#获取输入事件
`adb shell getevent`
root@M120D:/ # getevent                                                    
add device 1: /dev/input/event4
  name:     "msm8x10-skuaa-snd-card Headset Jack"
add device 2: /dev/input/event3
  name:     "msm8x10-skuaa-snd-card Button Jack"
add device 3: /dev/input/event1
  name:     "qpnp_pon"
add device 4: /dev/input/event0
  name:     "acc"
add device 5: /dev/input/event2
  name:     "gpio-keys"
  //press Volume UP
/dev/input/event2: 0001 0073 00000001
/dev/input/event2: 0000 0000 00000000
/dev/input/event2: 0001 0073 00000000
/dev/input/event2: 0000 0000 00000000
//press Volume DOWN
/dev/input/event1: 0001 0072 00000001
/dev/input/event1: 0000 0000 00000000
//release
/dev/input/event1: 0001 0072 00000000
/dev/input/event1: 0000 0000 00000000
//press POWER
/dev/input/event1: 0001 0074 00000001
/dev/input/event1: 0000 0000 00000000
//release
/dev/input/event1: 0001 0074 00000000
/dev/input/event1: 0000 0000 00000000

                  Type  code value
Linux上传的Code是0x0073 对应10进制115
Kernel/include/input.h KEY_VOLUMEUP 115


模拟按键
# Press power button(Don't release)
$ adb shell sendevent /dev/input/event2 1 $((0x74)) 1
$ adb shell sendevent /dev/input/event2 0 0 0

# Release power button
$ adb shell sendevent /dev/input/event5 1 $((0x74)) 0
$ adb shell sendevent /dev/input/event5 0 0 0

Linux


#define KEY_POWER       116 //SC System Power Down
Android也定义了一套码，叫作键盘码，power 0x74 116
通过一个/system/usr/keylayout/来将两套码对应起来
1.
frameworks/base/*core*/java/android/view/KeyEvent.java
410    public static final int KEYCODE_F1              = 131;

638    // NOTE: If you add a new keycode here you must also add it to:
    //  isSystem()
    //  frameworks/native/include/android/keycodes.h
    //  frameworks/base/include/androidfw/KeycodeLabels.h
    //  external/webkit/WebKit/android/plugins/ANPKeyCodes.h
    //  frameworks/base/core/res/res/values/attrs.xml
    //  emulator?
    //  LAST_KEYCODE
    //  KEYCODE_SYMBOLIC_NAMES
    //
    //  Also Android currently does not reserve code ranges for vendor-
    //  specific key codes.  If you have new key codes to have, you
    //  MUST contribute a patch to the open source project to define
    //  those new codes.  This is intended to maintain a consistent
    //  set of key code definitions across all Android devices.
    // Symbolic names of all key codes.
    private static final SparseArray<String> KEYCODE_SYMBOLIC_NAMES = new SparseArray<String>();
    private static void populateKeycodeSymbolicNames() {
        SparseArray<String> names = KEYCODE_SYMBOLIC_NAMES;
658        names.append(KEYCODE_UNKNOWN, "KEYCODE_UNKNOWN");
789        names.append(KEYCODE_F1, "KEYCODE_F1");
2.
frameworks/native/include/android/keycodes.h


frameworks/base/*policy*/src/com/android/internal/policy/impl/PhoneWindowManager.java

2030 if ((keyCode == KeyEvent.KEYCODE_F1) && down) {
     Intent intent4 = new Intent();
     //ComponentName cn4 = new ComponentName("com.android.camera", "com.android.camera.Camera");
     ComponentName cn4 = new ComponentName("com.android.camera2", "com.android.camera.CameraLauncher");
     intent4.setComponent(cn4);
     intent4.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
     intent4.setAction("android.intent.action.MAIN");
     mContext.startActivity(intent4);
     }
------------------------
/M120D/target/product/M120D/obj/KERNEL_OBJ/scripts/dtc/dtc -p 1024 -O dtb -o
./kernel/arch/arm/boot/dts/msm8610-rumi.dts;

./kernel/arch/arm/boot/dts/msm8610-sim.dts;
./kernel/arch/arm/boot/dts/msm8610-v1-cdp.dts;  
./kernel/arch/arm/boot/dts/msm8610-v1-mtp.dts;  
./kernel/arch/arm/boot/dts/msm8610-v1-qrd-skuaa.dts;  
./kernel/arch/arm/boot/dts/msm8610-v1-qrd-skuab-dvt2.dts;  

./kernel/arch/arm/boot/dts/msm8610-v1-qrd-skuab.dts;  
./kernel/arch/arm/boot/dts/msm8610-v2-cdp.dts;  
./kernel/arch/arm/boot/dts/msm8610-v2-mtp.dts;  
./kernel/arch/arm/boot/dts/msm8610-v2-qrd-skuaa.dts;  
./kernel/arch/arm/boot/dts/msm8610-v2-qrd-skuab-dvt2.dts;  
./kernel/arch/arm/boot/dts/msm8610-v2-qrd-skuab.dts;  
-----------------------

/kernel/arch/arm/boot/dts/msm8610-mdss.dtsi

qcom,platform-lcd-power-en-gpio = <&pm8110_gpios 2 0>;去掉

//
msm-pm8100.dtsi 电源键配置
1. 将GPIO_78 配置为 keycode 59
/kernel/arch/arm/boot/dts/msm8610-qrd.dtsi
		        key_f1 {
                        label = "key_f1";
                        gpios = <&msmgpio *78* 0x1>;
                        linux,input-type = <1>;
                        linux,code = <*59*>;
                        gpio-key,wakeup;
                        debounce-interval = <15>;
		};
2./kernel/arch/arm/mach-msm/board-8610-gpiomux.c
.gpio = 78,
.settings = {
  [GPIOMUX_ACTIVE]	= &m120ay_custom_gpio_config,-->gpio_keys_active
  [GPIOMUX_SUSPENDED]	= &m120ay_custom_gpio_config,-->gpio_keys_suspend
},
3.//实现 将Linux key code 59 映射为F1
/device/reach/M120D/gpio-keys.kl
key 59	 F1	 WAKE

-----
<4>[ 3170.548611] /mnt/M120D_Release/kernel/drivers/misc/ytgpio_ctrl.c:yt_gpio_init:166: yt_gpio_init:gpio: = 76 GPIO_9
<4>[ 3170.568567] /mnt/M120D_Release/kernel/drivers/misc/ytgpio_ctrl.c:yt_gpio_init:166: yt_gpio_init:gpio: = 83 GPIO_3
<4>[ 3170.588833] /mnt/M120D_Release/kernel/drivers/misc/ytgpio_ctrl.c:yt_gpio_init:166: yt_gpio_init:gpio: = 86
<4>[ 3170.608561] /mnt/M120D_Release/kernel/drivers/misc/ytgpio_ctrl.c:yt_gpio_init:166: yt_gpio_init:gpio: = 88
<4>[ 3170.628554] /mnt/M120D_Release/kernel/drivers/misc/ytgpio_ctrl.c:yt_gpio_init:166: yt_gpio_init:gpio: = 89

引出的引脚为 GPIO_7 6 1 5 4
对应的gpio号为 78 77 9
SWDCLK
VCC3.3
GND
GND
GPIO_7  pin25   GPIO_7        gpio_78
GPIO_6  pin25   GPIO_8        gpio_77
GPIO_1  PIN_79  BLSP3_UART_RX gpio_9
GPIO_5  PIN_69  UIM1_RESET    gpio_38
GPIO_4  PIN_68  SDC2_CARD_DET gpio_42
MISO    PIN_78 BLSP1_SPI_MISO gpio_87
CE0     PIN_21 BLSP1_SPI_CS_N gpio_88
MOSI    PIN_22 BLSP1_SPI_MOSI gpio_86
SCLK    PIN_77 BLSP1_SPI_CLK  gpio_89




#######BUG
/kernel/arch/arm/mach-msm/board-8610-gpiomux.c:1242
static struct gpiomux_setting interrupt_gpio_suspend_pulldown = {
	.func = GPIOMUX_FUNC_GPIO,
	.drv = GPIOMUX_DRV_6MA,
	.pull = GPIOMUX_PULL_UP,>>>GPIOMUX_PULL_DOWN
};
