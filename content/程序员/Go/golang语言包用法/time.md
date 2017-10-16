---
title: golang中time包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中time包用法](/chenbaoke/article/details/41519193)

time包中包括两类时间：时间点（某一时刻）和时常（某一段时间）

１时间常量（时间格式化）
```
    const (
        ANSIC       = "Mon Jan _2 15:04:05 2006"
        UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
        RubyDate    = "Mon Jan 02 15:04:05 -0700 2006"
        RFC822      = "02 Jan 06 15:04 MST"
        RFC822Z     = "02 Jan 06 15:04 -0700" // RFC822 with numeric zone
        RFC850      = "Monday, 02-Jan-06 15:04:05 MST"
        RFC1123     = "Mon, 02 Jan 2006 15:04:05 MST"
        RFC1123Z    = "Mon, 02 Jan 2006 15:04:05 -0700" // RFC1123 with numeric zone
        RFC3339     = "2006-01-02T15:04:05Z07:00"
        RFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
        Kitchen     = "3:04PM"
        // Handy time stamps.
        Stamp      = "Jan _2 15:04:05"
        StampMilli = "Jan _2 15:04:05.000"
        StampMicro = "Jan _2 15:04:05.000000"
        StampNano  = "Jan _2 15:04:05.000000000"
    )
```
这些常量是在time包中进行time 格式化 和time解析而预定义的一些常量，其实他们使用的都是一个特定的时间：
    Mon Jan 2 15:04:05 MST 2006

这个时间是Unix time 1136239445，因为MST是GMT-0700，所以这个指定的时间也可以看做

    01/02 03:04:05PM '06 -0700

可见程序猿也有调皮的一面．

因此我们只需要利用上面这些时间变可以随意的指定自己的时间格式，例如：

layout := "01\_\_02-2006 3.04.05 PM"

fmt.Println(time.Now().Format(layout))

便会输出类似的时间：11\_\_26-2014 8.40.00 PM

２　函数

time 组成：

　　　time.Duration（时间长度，消耗时间）

　　　time.Time（时间点）

　　　time.C（放时间的channel通道）（注：Time.C:=make(chan time.Time)）

After函数：

１）func After(d Duration) <-chan Time

表示多少时间之后，但是在取出channel内容之前不阻塞，后续程序可以继续执行

    ２）func Sleep(d Duration)
    表示休眠多少时间，休眠时处于阻塞状态，后续程序无法执行．

举例说明二者区别：

fmt.Println("hello")

chan := time.After(time.Secone*1)

fmt.Println("World")

则程序在执行完输出hello后，接着便输出world，不用等待１s，但是１s后，chan中有数据，此时chan阻塞

mt.Println("hello")

chan := time.Sleep(time.Secone*1)

fmt.Println("World")

则表示在输出hello后，程序变休眠1s中，然后才输出World．由此可见阻塞和非阻塞便是这两个函数的本质区别．

鉴于After特性，其通常用来处理程序超时问题，如下所示：

``` code
select {
case m := <-c:
    handle(m)
case <-time.After(5 * time.Minute):
    fmt.Println("timed out")
}
```

    ３）func Tick(d Duration) <-chan Time

time.Tick(time.Duration)用法和time.After差不多，<span style="color:#FF0000">但是它是表示每隔多少时间之后，是一个重复的过程</span>，其他与After一致

4)type Duration int64 //时间长度，其对应的时间单位有Nanosecond，Microsecond,Millisecond,Second,Minute,Hour
    (1)func ParseDuration(s string) (Duration, error)//传入字符串，返回响应的时间，其中传入的字符串中的有效时间单位如下：h,m,s,ms,us,ns，其他单位均无效，如果传入无效时间单位，则会返回０
    (2)func Since(t Time) Duration //表示自从t时刻以后过了多长时间，是一个时间段，相当于time.Now().Sub(t)
　(3)func (d Duration) Hours() float64 //将制定时间段换算为float64类型的Hour为单位进行输出

　(4)func (d Duration) Minutes() float64 //将制定时间段换算为float64类型的Minutes为单位进行输出

　(5)func (d Duration) Nanoseconds() int64 //将制定时间段换算为int64类型的Nanoseconds为单位进行输出

　(6)func (d Duration) Seconds() float64 //将制定时间段换算为float64类型的Seconds为单位进行输出

    (7)func(d Duration) String() string  //与ParseDuration函数相反，该函数是将时间段转化为字符串输出

5) type Location
func FixedZone(name string, offset int) \*Location
func LoadLocation(name string) (\*Location, error)
func (l \*Location) String() string

６）type Month //定义了１年的１２个月

func (m Month) String() string  //将时间月份以字符串形式打印出来．如fmt.Println(time.June.String())则打印出June

７）type ParseError
func (e \*ParseError) Error() string
８）type Ticker  //主要用来按照指定的时间周期来调用函数或者计算表达式，通常的使用方式是利用go新开一个协程使用，它是一个断续器
func NewTicker(d Duration) \*Ticker    //新生成一个ticker,此Ticker包含一个channel，此channel以给定的duration发送时间。duration d必须大于0
func (t \*Ticker) Stop()  //用于关闭相应的Ticker，但并不关闭channel

例子如下：

### 使用时间控制停止ticker

       ticker := time.NewTicker(time.Millisecond * 500)
        go func() {
            for t := range ticker.C {
                fmt.Println("Tick at", t)
            }
        }()

    time.Sleep(time.Millisecond * 1500)   //阻塞，则执行次数为sleep的休眠时间/ticker的时间
        ticker.Stop()     
        fmt.Println("Ticker stopped")

### 使用channel控制停止ticker

    ticker := time.NewTicker(time.Millisecond * 500)
    c := make(chan int，num) //num为指定的执行次数
    go func() {
        for t := range ticker.C {
                  c<-1
                   fmt.Println("Tick at", t)

        }
    }()
            ticker.Stop()

这种情况下，在执行num次以Ticker时间为单位的函数之后，c　channel中已满，以后便不会再执行对应的函数．
９）type Time　//包括日期和时间
func Date(year int, month Month, day, hour, min, sec, nsec int, loc \*Location) Time　//按照指定格式输入数据后，便会按照如下格式输出对应的时间，输出格式为
    yyyy-mm-dd hh:mm:ss + nsec nanoseconds，　其中loc必须指定，否则便会panic，
    例子如下：
    t := time.Date(2009, time.November, 10, 23, 0, 0, 0, time.UTC)
    fmt.Printf("Go launched at %s\n", t.Local())
    输出为：
    Go launched at 2009-11-10 15:00:00 -0800 PST

func Now() Time //返回当前时间，包括日期，时间和时区

func Parse(layout, value string) (Time, error)　//输入格式化layout和时间字符串，输出时间

func ParseInLocation(layout, value string, loc \*Location) (Time, error)

func Unix(sec int64, nsec int64) Time　//返回本地时间

func (t Time) Add(d Duration) Time　　//增加时间

func (t Time) AddDate(years int, months int, days int) Time//增加日期

func (t Time) After(u Time) bool　　//判断时间t是否在时间ｕ的后面

func (t Time) Before(u Time) bool　//判断时间t是否在时间ｕ的前面

func (t Time) Clock() (hour, min, sec int)　//获取时间ｔ的hour,min和second

func (t Time) Date() (year int, month Month, day int)　//获取时间ｔ的year,month和day

func (t Time) Day() int   //获取时间ｔ的day

func (t Time) Equal(u Time) bool  //判断时间t和时间u是否相同

func (t Time) Format(layout string) string  //时间字符串格式化

func (t \*Time) GobDecode(data \[\]byte) error //编码为god

func (t Time) GobEncode() (\[\]byte, error)//解码god

func (t Time) Hour() int　//获取时间ｔ的小时

func (t Time) ISOWeek() (year, week int)//获取时间ｔ的年份和星期

func (t Time) In(loc \*Location) Time//获取loc时区的时间ｔ的对应时间

func (t Time) IsZero() bool　//判断是否为０时间实例January 1, year 1, 00:00:00 UTC

func (t Time) Local() Time　//获取当地时间

func (t Time) Location() \*Location   //获取当地时区

func (t Time) MarshalBinary() (\[\]byte, error)　//marshal binary序列化，将时间t序列化后存入\[\]byte数组中

func (t Time) MarshalJSON() (\[\]byte, error)     //marshal json序列化，将时间t序列化后存入\[\]byte数组中

func (t Time) MarshalText() (\[\]byte, error)    //marshal text序列化，将时间t序列化后存入\[\]byte数组中

    举例说明：
    a := time.Now()
        fmt.Println(a)　　　输出：2014-11-27 14:58:31.583853811 +0800 CST
        b, _ := a.MarshalText()
        fmt.Println(b)　　　输出：[50 48 49 52 45 49 49 45 50 55 84 49 52 58 53 56 58 51 49 46 53 56 51 56 53 51 56 49 49 43 48 56 58 48 48]
        var c = new(time.Time)
        fmt.Println(c)　　　输出：0001-01-01 00:00:00 +0000 UTC
        c.UnmarshalText(b)
        fmt.Println(c)　　　输出：2014-11-27 14:58:31.583853811 +0800 CST
    可见Marshal类的函数只是提供一个将时间t序列化为[]byte数组的功能，利用UnMarshal类的函数可以获取到原来的时间t

func (t Time) Minute() int　　//获取时间ｔ的分钟

func (t Time) Month() Month　//获取时间ｔ的月份

func (t Time) Nanosecond() int　//获取时间ｔ的纳秒

func (t Time) Round(d Duration) Time　//将时间ｔ以d Duration为单位进行四舍五入求近似值．

示例如下：

代码：

``` code
t := time.Date(0, 0, 0, 12, 15, 30, 918273645, time.UTC)
round := []time.Duration{
    time.Nanosecond,
    time.Microsecond,
    time.Millisecond,
    time.Second,
    2 * time.Second,
    time.Minute,
    10 * time.Minute,
    time.Hour,
}

for _, d := range round {
    fmt.Printf("t.Round(%6s) = %s\n", d, t.Round(d).Format("15:04:05.999999999"))
}
```

输出：

``` output
t.Round(   1ns) = 12:15:30.918273645
t.Round(   1µs) = 12:15:30.918274
t.Round(   1ms) = 12:15:30.918
t.Round(    1s) = 12:15:31
t.Round(    2s) = 12:15:30
t.Round(  1m0s) = 12:16:00
t.Round( 10m0s) = 12:20:00
t.Round(1h0m0s) = 12:00:00
```

func (t Time) Second() int　//获取时间ｔ的秒
func (t Time) String() string　//获取时间ｔ的字符串表示

func (t Time) Sub(u Time) Duration　//与Add相反，Sub表示从时间ｔ中减去时间ｕ

func (t Time) Truncate(d Duration) Time　//去尾法求近似值

示例代码如下：

代码：

``` code
t, _ := time.Parse("2006 Jan 02 15:04:05", "2012 Dec 07 12:15:30.918273645")
trunc := []time.Duration{
    time.Nanosecond,
    time.Microsecond,
    time.Millisecond,
    time.Second,
    2 * time.Second,
    time.Minute,
    10 * time.Minute,
    time.Hour,
}

for _, d := range trunc {
    fmt.Printf("t.Truncate(%6s) = %s\n", d, t.Truncate(d).Format("15:04:05.999999999"))
}
```

输出：

``` output
t.Truncate(   1ns) = 12:15:30.918273645
t.Truncate(   1µs) = 12:15:30.918273
t.Truncate(   1ms) = 12:15:30.918
t.Truncate(    1s) = 12:15:30
t.Truncate(    2s) = 12:15:30
t.Truncate(  1m0s) = 12:15:00
t.Truncate( 10m0s) = 12:10:00
t.Truncate(1h0m0s) = 12:00:00
```

func (t Time) UTC() Time　//将本地时间变换为UTC时区的时间并返回

func (t Time) Unix() int64　//返回Unix时间，该时间是从January 1, 1970 UTC这个时间开始算起的．

func (t Time) UnixNano() int64　//以纳秒为单位返回Unix时间

func (t \*Time) UnmarshalBinary(data \[\]byte) error　//将data数据反序列化到时间ｔ中

func (t \*Time) UnmarshalJSON(data \[\]byte) (err error)　//将data数据反序列化到时间ｔ中

func (t \*Time) UnmarshalText(data \[\]byte) (err error)　//将data数据反序列化到时间ｔ中

func (t Time) Weekday() Weekday　//获取时间ｔ的Weekday

func (t Time) Year() int　　　//获取时间ｔ的Year

func (t Time) YearDay() int     //获取时间ｔ的YearDay，即１年中的第几天

func (t Time) Zone() (name string, offset int)

１０）type Timer　//用于在指定的Duration类型时间后调用函数或计算表达式，它是一个计时器

func AfterFunc(d Duration, f func()) \*Timer　//和After差不多，意思是**多少时间之后执行函数f**

func NewTimer(d Duration) \*Timer　//使用NewTimer(),可以返回的Timer类型在计时器到期之前,取消该计时器

func (t \*Timer) Reset(d Duration) bool　//重新设定timer t的Duration d.

func (t \*Timer) Stop() bool　//阻止timer事件发生，当该函数执行后，timer计时器停止，相应的事件不再执行

１１）type Weekday
func (d Weekday) String() string　//获取一周的字符串

###
