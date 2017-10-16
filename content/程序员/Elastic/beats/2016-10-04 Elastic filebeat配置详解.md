---
title: filebeat配置详解
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

Registry File

Registry File存储了Filbeat最后一次读的位置和状态。在Logstash-Forwarder被称为.logstash-fowarder(位于/var/lib/logstash-forwarder/.logstash-forwarder)。对于Filebeat需要将其重命名为 .filebeat。
迁移配置文件
```
```




在Filebeat安装完成准备使用前，最好先对Filebeat进行一些详细的配置再使用，下面来详细讲解一下相关内容。

Filebeat的配置文件是/etc/filebeat/filebeat.yml，遵循YAML语法。具体可以配置如下几个项目：

    Filebeat
    Output
    Shipper
    Logging(可选)
    Run Options（可选）

这个Blog主要讲解Filebeat的配置部分，其他部分后续会有新的Blog介绍。

Filebeat的部分主要定义prospector的列表，定义监控哪里的日志文件，关于如何定义的详细信息可以参考filebeat.yml中的注释，下面主要介绍一些需要注意的地方。

    paths：指定要监控的日志，目前按照Go语言的glob函数处理。没有对配置目录做递归处理，比如配置的如果是：

    /var/log/* /*.log

则只会去/var/log目录的所有子目录中寻找以”.log”结尾的文件，而不会寻找/var/log目录下以”.log”结尾的文件。

    encoding：指定被监控的文件的编码类型，使用plain和utf-8都是可以处理中文日志的。

    input_type：指定文件的输入类型log(默认)或者stdin。

    exclude_lines：在输入中排除符合正则表达式列表的那些行。

    include_lines：包含输入中符合正则表达式列表的那些行（默认包含所有行），include_lines执行完毕之后会执行exclude_lines。

    exclude_files：忽略掉符合正则表达式列表的文件（默认为每一个符合paths定义的文件都创建一个harvester）。

    fields：向输出的每一条日志添加额外的信息，比如“level:debug”，方便后续对日志进行分组统计。默认情况下，会在输出信息的fields子目录下以指定的新增fields建立子目录，例如fields.level。

    fields:
    level: debug

则在Kibana看到的内容如下：

这里写图片描述

    fields_under_root：如果该选项设置为true，则新增fields成为顶级目录，而不是将其放在fields目录下。自定义的field会覆盖filebeat默认的field。例如添加如下配置：

    fields:
    level: debug
    fields_under_root: true

则在Kibana看到的内容如下：

这里写图片描述

    ignore_older：可以指定Filebeat忽略指定时间段以外修改的日志内容，比如2h（两个小时）或者5m(5分钟)。

    close_older：如果一个文件在某个时间段内没有发生过更新，则关闭监控的文件handle。默认1h,change只会在下一次scan才会被发现

    force_close_files：Filebeat会在没有到达close_older之前一直保持文件的handle，如果在这个时间窗内删除文件会有问题，所以可以把force_close_files设置为true，只要filebeat检测到文件名字发生变化，就会关掉这个handle。

    scan_frequency：Filebeat以多快的频率去prospector指定的目录下面检测文件更新（比如是否有新增文件），如果设置为0s，则Filebeat会尽可能快地感知更新（占用的CPU会变高）。默认是10s。

    document_type：设定Elasticsearch输出时的document的type字段，也可以用来给日志进行分类。

    harvester_buffer_size：每个harvester监控文件时，使用的buffer的大小。

    max_bytes：日志文件中增加一行算一个日志事件，max_bytes限制在一次日志事件中最多上传的字节数，多出的字节会被丢弃。

    multiline：适用于日志中每一条日志占据多行的情况，比如各种语言的报错信息调用栈。这个配置的下面包含如下配置：

<code class="hljs applescript has-numbering" style="display: block; padding: 0px; color: inherit; box-sizing: border-box; font-family: "Source Code Pro", monospace;font-size:undefined; white-space: pre; border-radius: 0px; word-wrap: normal; background: transparent;">pattern：多行日志开始的那一行匹配的pattern negate：是否需要对pattern条件转置使用，不翻转设为<span class="hljs-constant" style="box-sizing: border-box;">true</span>，反转设置为<span class="hljs-constant" style="box-sizing: border-box;">false</span> match：匹配pattern后，与前面（<span class="hljs-keyword" style="color: rgb(0, 0, 136); box-sizing: border-box;">before</span>）还是后面（<span class="hljs-keyword" style="color: rgb(0, 0, 136); box-sizing: border-box;">after</span>）的内容合并为一条日志 max_lines：合并的最多行数（包含匹配pattern的那一行） <span class="hljs-keyword" style="color: rgb(0, 0, 136); box-sizing: border-box;">timeout</span>：到了<span class="hljs-keyword" style="color: rgb(0, 0, 136); box-sizing: border-box;">timeout</span>之后，即使没有匹配一个新的pattern（发生一个新的事件），也把已经匹配的日志事件发送出去</code><ul class="pre-numbering" style="box-sizing: border-box; position: absolute; width: 50px; top: 0px; left: 0px; margin: 0px; padding: 6px 0px 40px; border-right-width: 1px; border-right-style: solid; border-right-color: rgb(221, 221, 221); list-style: none; text-align: right; background-color: rgb(238, 238, 238);"><li style="box-sizing: border-box; padding: 0px 5px;">1</li><li style="box-sizing: border-box; padding: 0px 5px;">2</li><li style="box-sizing: border-box; padding: 0px 5px;">3</li><li style="box-sizing: border-box; padding: 0px 5px;">4</li><li style="box-sizing: border-box; padding: 0px 5px;">5</li></ul>

    tail_files：如果设置为true，Filebeat从文件尾开始监控文件新增内容，把新增的每一行文件作为一个事件依次发送，而不是从文件开始处重新发送所有内容。

    backoff：Filebeat检测到某个文件到了EOF之后，每次等待多久再去检测文件是否有更新，默认为1s。

    max_backoff：Filebeat检测到某个文件到了EOF之后，等待检测文件更新的最大时间，默认是10秒。

    backoff_factor：定义到达max_backoff的速度，默认因子是2，到达max_backoff后，变成每次等待max_backoff那么长的时间才backoff一次，直到文件有更新才会重置为backoff。比如：

这里写图片描述

如果设置成1，意味着去使能了退避算法，每隔backoff那么长的时间退避一次。

    spool_size:spooler的大小，spooler中的事件数量超过这个阈值的时候会清空发送出去（不论是否到达超时时间）。

    idle_timeout:spooler的超时时间，如果到了超时时间，spooler也会清空发送出去（不论是否到达容量的阈值）。

    registry_file:记录filebeat处理日志文件的位置的文件

    config_dir:如果要在本配置文件中引入其他位置的配置文件，可以写在这里（需要写完整路径），但是只处理prospector的部分。

    publish_async：是否采用异步发送模式（实验功能）。
