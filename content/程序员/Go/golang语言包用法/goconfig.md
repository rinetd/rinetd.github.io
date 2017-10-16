---
title: golang中goconfig包使用解析
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中goconfig包使用解析](/chenbaoke/article/details/41683601)

**注意事项**

本博客隶属于 [goconfig - 课时 1：goconfig 使用解析](https://github.com/Unknwon/go-rock-libraries-showcases/tree/master/lectures/01-goconfig#%E8%AF%BE%E6%97%B6-1goconfig-%E4%BD%BF%E7%94%A8%E8%A7%A3%E6%9E%90) 请注意配套使用。

本博文为 [goconfig](https://github.com/Unknwon/goconfig) - Go 语言 INI 解析器的配套博客，旨在通过文字结合代码示例对该库的使用方法和案例进行讲解，便于各位同学更好地使用和深入了解。

库简介
------

goconfig 是一个由 Go 语言开发的针对 Windows 下常见的 INI 格式的配置文件解析器。该解析器在涵盖了所有 INI 文件操作的基础上，又针对 Go 语言实际开发过程中遇到的一些需求进行了扩展。相对于其它 INI 文件解析器而言，该解析器最大的优势在于对注释的极佳支持；除此之外，支持多个配置文件覆盖加载也是非常特别但好用的功能。

下载安装
--------

您可以通过以下两种方式下载安装 goconfig：

    gopm get github.com/Unknwon/goconfig

或

    go get github.com/Unknwon/goconfig

### API 文档

请移步 [Go Walker](http://gowalker.org/github.com/Unknwon/goconfig)。

基本使用方法
------------

[示例代码](https://github.com/Unknwon/go-rock-libraries-showcases/tree/master/lectures/01-goconfig/class1/sample1)

一般来说，INI 格式的文件均以 `.ini` 为后缀，但您可以使用任意后缀，这并不影响您使用该库进行解析。在本例中，我们使用 ` conf.ini` 作为我们的配置文件。

### 加载配置文件

要操作某个配置文件，需要先将其加载到内存中，我们需要调用 `LoadConfigFile` 函数来完成该操作：

    cfg, err := goconfig.LoadConfigFile("conf.ini")

配置文件的文件名可以写相对路径或绝对路径，该函数返回值分别为 `ConfigFile` 和 error 类型。如果加载操作发生错误，则变量 `cfg` 为 nil；否则 `err` 为 nil。加载完成之后，我们就可以通过操作变量 `cfg` 来对配置文件的数据进行操作。要注意的是，加载完成后所有数据均已存入内存，任何对文件的修改操作都不会影响到已经获取到的对象。也就是说，此时对文件的修改是不会影响到 `cfg` 这个对象里的数据的。

### 基本读写操作

通过 `GetValue` 方法可实现最基本的读取操作。在本例中，键 `key_default` 属于未命名的分区（section），则 goconfig 在解析器将它直接归于名为 `DEFAULT` 的分区。当我们想要获取它的值的时候，可以进行如下操作：

    value, err := cfg.GetValue(goconfig.DEFAULT_SECTION, "key_default")

第一个返回值为 string 类型，即取到的值；第二个返回值为 error 类型，当发生错误时不为 nil。

除了读取之外，还可以进行设置值操作：

    isInsert := cfg.SetValue(goconfig.DEFAULT_SECTION, "key_default", "这是新的值")

该方法返回值类型为 bool 类型，表示是否为插入操作。如果值为 true，表明该键之前未存在，现在插入成功；否则表示该键之前已经存在，它的值现在被重写了。

如果您觉得每次都调用 `goconfig.DEFAULT_SECTION` 来表示 `DEFAULT` 分区非常繁琐，您也可以直接使用空白字符串来代表 `DEFAULT` 分区：

    value, err = cfg.GetValue("", "key_default")

以上代码也可以达到相同的效果。

除了使用等号作为键值之间的分隔符之外，冒号也是允许的：

    key_super2 : 测试值

### 注释读写操作

虽然大多数情况下程序都只从 INI 文件进行数据的读取操作，但偶尔会需要实现写入到文件的操作。此时，其余所有的解析器都会将注释给过滤掉；当注释是配置文件各项说明的重要依据时，这种做法显然是不可取的。因此，完整地保存文件中的注释，并提供在程序中对注释进行操作的 API 不可谓不是 goconfig 的一大特色。

goconfig 允许您的配置文件以分号 `;` 或井号 `#` 为开头在单独的一行作为注释：

    ; 以分号开头的均为注释行
    # 以井号开头的也为注释行

但不可以在某一行的中间：

    key_default = 默认节的一个键 # 注释必须单独占行，此处的注释无效

通过 goconfig 提供的 API，您可以操作某个分区或键的注释。

获取某个分区的注释：

    comment := cfg.GetSectionComments("super")

获取某个键的注释：

    comment = cfg.GetKeyComments("super", "key_super")

这两个方法均返回 string 类型的返回值。

设置某个键的注释：

    v := cfg.SetKeyComments("super", "key_super", "# 这是新的键注释")

设置某个分区的注释：

    v = cfg.SetSectionComments("super", "# 这是新的分区注释")

上面两个方法的返回值都是 bool 类型。若为 true 表示注释被插入或删除（当传入的参数为空字符串时）；为 false 表示注释已存在，现在被重写。

### 类型转换读取

goconfig 提供以类型命名的一些方法，例如 `Int`、`Int64` 和 `Bool` 等等，这些方法会返回非 string 类型的值以及一个 error 类型的返回值表示是否发生错误：

    vInt, err := cfg.Int("must", "int")

第一个返回值为 int 类型，第二个返回值为 error 类型。

### Must 系列方法

Must 系列方法是用于避免检查 error 类型所造成的代码臃肿，简化数据获取流程。这些方法均已 `Must` 字符开头，如 ` MustInt`、`MustInt64` 和 `MustBool` 等等。这些方法一定会返回指定类型的值，若发生错误，则返回零值，不会发生错误：

    vBool := cfg.MustBool("must", "bool")

该方法返回值为 bool 类型。

### 删除指定键值

当您想要抛弃某个键时，可以通过 `DeleteKey` 方法来删除某个键：

    ok := cfg.DeleteKey("must", "string")

该方法返回值为 bool 类型，用于表示删除操作是否成功（若键不存在则会表示为不成功）。

### 保存配置文件

当完成操作需要将数据写回硬盘时，可以使用 `SaveConfigFile` 函数来将 `ConfigFile` 对象以字符串的形式保存到文件系统中：

    err = goconfig.SaveConfigFile(cfg, "conf_save.ini")

您需要指定要保存的对象和文件名，该方法返回一个 error 类型的值。

高级使用技巧
------------

[示例代码](https://github.com/Unknwon/go-rock-libraries-showcases/tree/master/lectures/01-goconfig/class1/sample2)

上一小结展示了如果使用 goconfig 完成常见的 INI 文件操作，本小节则将着重介绍 goconfig 库为大家带来的一些扩展功能。

### 多文件覆盖加载

函数 `LoadConfigFile` 其实可以接受多个 string 类型的参数来表示要加载的多个配置文件名，并根据次序进行覆盖式地加载：

    cfg, err := goconfig.LoadConfigFile("conf.ini", "conf2.ini")

在本例中，如果 `conf.ini` 和 `conf2.ini` 中同时出现相同分区和键名时，则只会获取到 ` conf2.ini` 文件中的值。

如果在程序运行途中发现需要增加配置文件，则可通过方法 `AppendFiles` 实现追加操作：

    err = cfg.AppendFiles("conf3.ini")

### 配置文件重载

若外部文件发生修改，可通过调用方法进行快速重载：

    err = cfg.Reload()

该方法返回一个 error 类型的值表示操作是否成功。

### 为 Must 系列方法设置缺省值

借助 Go 语言变参的功能，当 Must 系列方法拥有三个参数时，则第三个参数即为获取失败时的默认值：

    vBool := cfg.MustBool("must", "bool404", true)

本例中键名为 `bool404` 根本不存在，则会采用 true 作为返回值。

### 递归读取键值

在文件 `conf3.ini` 中，默认分区有两个键如下：

    google=www.google.com
    search=http://%(google)s

当您使用 `%(<key>)s` 包含某个键名来作为值的时候，goconfig 会去寻找相应的键的值进行替换；如果被替换的键的值还有这样的嵌套，则会递归执行替换。该操作最多允许 200 层的嵌套。此时，键 `search` 真正的值为 `http://www.google.com`。要注意的是，被包含的键可以是位于 `DEFAULT` 分区或同一分区的，出现顺序任意。

### 子孙分区覆盖读取

在文件 `conf3.ini` 中，有如下配置：

    [parent]
    name=john
    relation=father
    sex=male
    age=32

    [parent.child]
    age=3

当我们获取 `parent.child` 分区中的键 `age` 时，我们会得到 `3`；但当我们想要获取 `sex` 时，正常情况下应该为获取失败，不过，goconfig 会发现 `parent.child` 还有父分区 ` parent`，因为 `parent.child` 使用了半角符号 `.` 来实现分级。这时候，获取 ` sex` 会得到 `male`。

### 自增键名获取

在文件 `conf3.ini` 中，有如下配置：

    [auto increment]
    -=hello
    -=go
    -=config

由于使用 `-` 作为键名，则 goconfig 在解析时，会将它翻译成自增数字，从 1 开始。在本例中，上面的键在对象中会被保存为：

    #1: hello
    #2: go
    #3: config

要注意的是，计数只在同个分区内有效，新的分区又会从 1 开始重新计数。

### 获取整个分区

如果您想要直接操作某个分区，可通过方法 `GetSection` 来返回一个类型为 map\[string\]string 的值，其包含了相应分区的所有键值对：

    sec, err := cfg.GetSection("auto increment")

总结
----

goconfig 包的 API 提供非常全面，用法非常简单，但核心代码并不多，各位同学有兴趣的可以阅读其源代码。

使用案例
--------

-   [gopm](https://github.com/gpmgo/gopm)
-   [beego - i18n](https://github.com/beego/i18n)
-   [beeweb](https://github.com/beego/beeweb)
-   wetalk
-   [gowalker](https://github.com/Unknwon/gowalker)

注：本文转自无闻大神的博客，原文链接：<http://studygolang.com/wr?u=http%3a%2f%2fwuwen.org%2farticle%2f17%2f01-goconfig-class1.html>
