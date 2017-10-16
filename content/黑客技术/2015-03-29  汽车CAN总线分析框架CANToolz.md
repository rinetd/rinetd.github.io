---
title:  汽车CAN总线分析框架CANToolz
date: 2016-03-29T21:25:45+08:00
update: 2016-01-01
categories: [网络安全]
tags:
---
  [汽车CAN总线分析框架CANToolz](http://www.freebuf.com/sectool/104985.html)
 CANToolz 是一个分析控制局域网络CAN(Controller Area Network) 和设备的框架。该工具基于不同的模块组装在一起，可以被安全研究人员和 汽车业/OEM 的安全测试人员使用进行黑盒分析等，你可以使用本软件发现电子控制单元ECU，中间人攻击测试，模糊测试，暴力破解，扫描或 R&D测试和验证。

 car-hacking-4.jpg

 该平台试图将所有需要的 技巧/工具 和其他你可以对CAN总线做的事情结合在一起。我发现，有许多可用的工具，从 Charlie Miller 和 Chris Valasek 工具 到Craig Smith 开发的 UDS/CAN。它们都有很出色并且有效，但它们仍然很难在每一天的工作中使用（至少对我来说），并且你需要 修改/编写 代码才能得到你想要的东西（MITM，有逻辑的扫描仪）。这就是为什么我使用这款软件。如果有更多的人可以提供模块，这会使其更有价值。它提供了一个简单的方法来添加模块并根据你的需要使用“扩展”版本（比如选择ECU自定义暴力破解等）。没有任何其他目的，这里仅仅想推荐给大家一个好的工具被更多的人使用。

 还有一点：这是基于模块的引擎，所以你可以使用它作为您的测试过程的一部分，或者当你需要和CAN总线工作时，添加更复杂的 场景/软件。

 “我不明白为什么大家始终在发布新的“汽车黑客工具”。我和 @nudehaberdasher 在 2013 年发布的工具仍然运作的很好。” (c) Charlie Miller (‏@0xcharlie)

 “如何查询我们的汽车黑客 工具/数据/脚本？请下载http://illmatics.com/content.zip”(c) Chris Valasek ‏@nudehaberdasher

 更多的细节和用例见[博客]（），请参见维基（目前正在开发中）：[WIKI]
 使用硬件

 CANToolz 可以利用以下硬件与 CAN 网络协同工作：

     USBtin

     CANBus Triple

 依赖项

 python 3.4
   pip install pyserial
   pip install numpy

 for MIDI_to_CAN
   pip install mido

 安装

 python setup.py install

 快速启动

 sudo python cantoolz.py -g w -c examples/can_sniff.py

 然后在浏览器中访问 http://localhost:4444
 模块

         hw_CANBusTriple – CANBus Triple HW 的 IO 模块

         hw_USBtin – USBtin 的 IO 模块

         mod_firewall – 通过 ID 阻塞 CAN 报文模块

         mod_fuzz1 – 简单‘代理’模糊（1字节）可以与 gen_ping/gen_replay结合使用

         mod_printMessage – 打印 CAN 报文

         mod_stat – CAN 报文统计 (使用 .csv 文件 输出)分析选项（c mod_stat a）试图找到 UDS/ISO TP 报文

         gen_ping – 使用选择 IDs (ECU/Service discovery) 生成 CAN 报文

         gen_replay – 保存重发数据包

 附言：我们致力于支持其他类型的I/O硬件和模块。欢迎加入我们！主要想法是希望产生不同的模块对以上8个模块提供帮助。

 监看和UDS检测实例，如下图所示：

 vw2.png

 Python 2.7最终稳定版本: https://github.com/eik00d/CANToolz/tree/Python_2.7_last_release
 使用示例

 在示例文件夹中可以查看更多的用例：

         CAN 开关过滤器扫描检测哪个 CAN 帧可以通过诊断接口到 HU 并返回

         中间人与防火墙 (ECU ID 检测)，检测哪些包对应选定的“行为”

         重放发现，检测哪些包对应选定的“行为”

         Ping 发现( 使用 ISO TP 和 UDS 支持)， 检测 UDS 等

 有许多其他可能的选择，你只要根据需要选择模块。例如 使用 DIFF 模式，找到开锁命令。

 备注：目前的版本是 uber-beta。缺乏充分的测试，代码不够整洁和美观，可能还有一些尚未发现的 bug。很抱歉，有很多不需要的 IF，糟糕的代码，奇怪的 RPINTs 等，请随意修正或直接忽略。

 致以最诚挚的问候：

 Alexey Sintsov (@asintsov)alex.sintsov@gmail.com

 DC#7812: DEFCON-RUSSIA
