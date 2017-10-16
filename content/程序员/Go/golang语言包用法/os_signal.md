---
title: golang中os/signal包的使用
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中os/signal包的使用](/chenbaoke/article/details/42555361)
os/signal包实现对信号的处理

golang中对信号的处理主要使用os/signal包中的两个方法：一个是notify方法用来监听收到的信号；一个是 stop方法用来取消监听。

func Notify(c chan&lt;- os.Signal, sig ...os.Signal)

``` go
func Notify(c chan<- os.Signal, sig ...os.Signal)
```

第一个参数表示接收信号的channel, 第二个及后面的参数表示设置要监听的信号，<span style="color:#FF0000">如果不设置表示监听所有的信号</span>。

``` go
func main() {
    c := make(chan os.Signal, 0)
    signal.Notify(c)

    // Block until a signal is received.
    s := <-c
    fmt.Println("Got signal:", s) //Got signal: terminated

}
结果分析：运行该程序，然后在终端中通过kill命令杀死对应的进程，便会得到结果
```

func Stop(c chan&lt;- os.Signal)

``` go
func main() {
    c := make(chan os.Signal, 0)
    signal.Notify(c)

    signal.Stop(c) //不允许继续往c中存入内容
    s := <-c       //c无内容，此处阻塞，所以不会执行下面的语句，也就没有输出
    fmt.Println("Got signal:", s)
}
```

由于signal存入channel中，所以可以利用channel特性，通过select针对不同的signal使得系统或者进程执行不同的操作．
