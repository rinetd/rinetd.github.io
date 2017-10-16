---
title: golang 中fmt用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang 中fmt用法](/chenbaoke/article/details/39932845)
fmt包实现了格式化的I/O函数，这点类似Ｃ语言中的printf和scanf，但是更加简单．
<span style="font-size:18px">占位符：</span>

通用占位符：

    %v 值的默认格式。当打印结构体时，“加号”标记（%+v）会添加字段名
    %#v　相应值的Go语法表示
    %T  相应值的类型的Go语法表示
    %%  字面上的百分号，并非值的占位符　

用法如下：

``` go
package main

import (
    "fmt"
)

type Sample struct {
    a   int
    str string
}

func main() {
    s := new(Sample)
    s.a = 1
    s.str = "hello"
    fmt.Printf("%v\n", *s)　//{1 hello}
    fmt.Printf("%+v\n", *s) //  {a:1 str:hello}
    fmt.Printf("%#v\n", *s) // main.Sample{a:1, str:"hello"}
    fmt.Printf("%T\n", *s)   //  main.Sample
    fmt.Printf("%%\n", s.a) //  %  %!(EXTRA int=1)       <span style="color:#FF0000;"> 注：暂时还没有明白其用法</span>
}
```

布尔值：

    %t  true 或 false

整数值：

    %b 二进制表示
    %c  相应Unicode码点所表示的字符
    %d  十进制表示
    %o  八进制表示
    %q  单引号围绕的字符字面值，由Go语法安全地转义
    %x  十六进制表示，字母形式为小写 a-f
    %X  十六进制表示，字母形式为大写 A-F
    %U  Unicode格式：U+1234，等同于 "U+%04X"

浮点数及复数：

    %b 无小数部分的，指数为二的幂的科学计数法，与 strconv.FormatFloat中的 'b' 转换格式一致。例如 -123456p-78
    %e  科学计数法，例如 -1234.456e+78
    %E  科学计数法，例如 -1234.456E+78
    %f  有小数点而无指数，例如 123.456
    %g  根据情况选择 %e 或 %f 以产生更紧凑的（无末尾的0）输出
    %G  根据情况选择 %E 或 %f 以产生更紧凑的（无末尾的0）输出

字符串和bytes的slice表示：

    %s 字符串或切片的无解译字节
    %q  双引号围绕的字符串，由Go语法安全地转义
    %x  十六进制，小写字母，每字节两个字符
    %X  十六进制，大写字母，每字节两个字符

指针：

    %p 十六进制表示，前缀 0x

这里没有 'u' 标记。若整数为无符号类型，他们就会被打印成无符号的。类似地，这里也不需要指定操作数的大小（int8，int64）。

对于％ｖ来说默认的格式是：

    bool:                    %t
    int, int8 etc.:          %d
    uint, uint8 etc.:        %d, %x if printed with %#v
    float32, complex64, etc: %g
    string:                  %s
    chan:                    %p
    pointer:                 %p

由此可以看出，默认的输出格式可以使用%v进行指定，除非输出其他与默认不同的格式，否则都可以使用%v进行替代（但是不推荐使用）

对于复合对象，里面的元素使用如下规则进行打印：

    struct:             {field0 field1 ...}
    array, slice:       [elem0  elem1 ...]
    maps:               map[key1:value1 key2:value2]
    pointer to above:   &{}, &[], &map[]

宽度和精度：

宽度是在％之后的值，如果没有指定，则使用该值的默认值，精度是跟在宽度之后的值，如果没有指定，也是使用要打印的值的默认精度．例如：％９.２f，宽度９，精度２

    %f:    default width, default precision
    %9f    width 9, default precision
    %.2f   default width, precision 2
    %9.2f  width 9, precision 2
    %9.f   width 9, precision 0

对数值而言，宽度为该数值占用区域的最小宽度；精度为小数点之后的位数。但对于 %g/%G 而言，精度为所有数字的总数。例如，对于123.45，格式 %6.2f会打印123.45，而 %.4g 会打印123.5。%e 和 %f 的默认精度为6；但对于 %g 而言，它的默认精度为确定该值所必须的最小位数。

对大多数值而言，<span style="color:#FF0000">宽度为输出的最小字符数，如果必要的话会为已格式化的形式填充空格。对字符串而言，精度为输出的最大字符数，如果必要的话会直接截断</span>。

<span style="color:#FF0000">宽度是指"必要的最小宽度". 若结果字符串的宽度超过指定宽度时, 指定宽度就会失效</span>。

若将宽度指定为\`\*'时, 将从参数中取得宽度值。

紧跟在"."后面的数串表示精度(若只有"."的话，则为".0")。若遇到整数的指示符(\`d', \`i', \`b', \`o', \`x', \`X', \`u')的话，精度表示数值部分的长度
若遇到浮点数的指示符(\`f')的话，它表示小数部分的位数。

若遇到浮点数的指示符(\`e', \`E', \`g', \`G')的话，它表示有效位数

若将精度设为\`\*'的话，将从参数中提取精度的值

<span style="color:#FF0000">其中对于字符串％s或者浮点类型％f,来说，精度可以截断数据的长度</span>．如下所示．

``` go
func main() {
    a := 123
    fmt.Printf("%1.2d\n", a)    //123，宽度为１小于数值本身宽度，失效，而精度为２，无法截断整数
    b := 1.23
    fmt.Printf("%1.1f\n", b)    //1.2，精度为１，截断浮点型数据
    c := "asdf"
    fmt.Printf("%*.*s\n", 1, 2, c) //as，利用'*'支持宽度和精度的输入，并且字符串也可以利用精度截断
}
```

其他标志：

    +  总打印数值的正负号；对于%q（%+q）保证只输出ASCII编码的字符。
    -   左对齐
    #   备用格式：为八进制添加前导 0（%#o），为十六进制添加前导 0x（%#x）或0X（%#X），为 %p（%#p）去掉前导 0x；对于 %q，若 strconv.CanBackquote
        返回 true，就会打印原始（即反引号围绕的）字符串；如果是可打印字符，%U（%#U）会写出该字符的Unicode编码形式（如字符 x 会被打印成 U+0078 'x'）。
    ' ' （空格）为数值中省略的正负号留出空白（% d）；以十六进制（% x, % X）打印字符串或切片时，在字节之间用空格隔开
    0   填充前导的0而非空格；对于数字，这会将填充移到正负号之后

``` go
func main() {
    a := 123
    fmt.Printf("%+10d\n", a)  //+123
    fmt.Printf("%+010d\n", a) //+000000123，利用０来补齐位数，而不是空格
}
```

对于每一个 Printf 类的函数，都有一个 Print 函数，该函数不接受任何格式化，它等价于对每一个操作数都应用 %v。另一个变参函数 Println 会在操作数之间插入空白，并在末尾追加一个换行符

不考虑占位符的话，如果操作数是接口值，就会使用其内部的具体值，而非接口本身。如下所示：

``` go
package main

import (
    "fmt"
)

type Sample struct {
    a   int
    str string
}

func main() {
    var i interface{} = Sample{1, "a"}
    fmt.Printf("%v\n", i)　　　　　　//{1 a}
}
```

显示参数占位符：

go中支持显示参数占位符，通过在输出格式中指定其输出的顺序即可，如下所示：

``` go
func main() {
    fmt.Printf("%[2]d, %[1]d\n", 11, 22)  //22, 11，先输出第二个值，再输出第一个值
}
```

格式化错误：

如果给占位符提供了无效的实参（如将一个字符串提供给％d），便会出现格式化错误．<span style="color:#FF0000">所有的错误都始于“%!”</span>，有时紧跟着单个字符（占位符），并以小括号括住的描述结尾。

``` go
func main() {
    var i int = 1
    fmt.Printf("%s\n", i)  //%!s(int=1)
}
```

### Scanning

一组类似的函数通过扫描已格式化的文本来产生值。Scan、Scanf 和 Scanln 从os.Stdin 中读取；Fscan、Fscanf 和 Fscanln 从指定的 io.Reader 中读取；Sscan、Sscanf 和 Sscanln 从实参字符串中读取。Scanln、Fscanln 和 Sscanln在换行符处停止扫描，且需要条目紧随换行符之后；Scanf、Fscanf 和 Sscanf需要输入换行符来匹配格式中的换行符；其它函数则将换行符视为空格。

Scanf、Fscanf 和 Sscanf 根据格式字符串解析实参，类似于 Printf。例如，%x会将一个整数扫描为十六进制数，而 %v 则会扫描该值的默认表现格式。

格式化类似于 Printf，但也有例外，如下所示：

    %p 没有实现
    %T 没有实现
    %e %E %f %F %g %G 都完全等价，且可扫描任何浮点数或复合数值
    %s 和 %v 在扫描字符串时会将其中的空格作为分隔符
    标记 # 和 + 没有实现

在输入Scanf中，宽度可以理解成输入的文本（％5s表示输入５个字符），而Scanf没有精度这种说法（没有%5.2f，只有 %5f）

<span style="font-size:18px">函数：</span>
func Errorf(format string, a ...interface{}) error

Errorf 根据于格式说明符进行格式化，并将字符串作为满足 error 的值返回，其返回类型是error．

``` go
func main() {
    a := fmt.Errorf("%s%d", "error:", 1)
    fmt.Println(a)
}
```

<span style="color:#FF0000">对于每一个 Printf 类的函数，都有一个 Print 函数，该函数不接受任何格式化，它等价于对每一个操作数都应用 %v。另一个变参函数 Println 会在操作数之间插入空白，并在末尾追加一个换行符</span>

func Fprint(w io.Writer, a ...interface{}) (n int, err error)　//Fprint 使用其操作数的默认格式进行格式化并写入到 w。当两个连续的操作数均不为字符串时，它们之间就会添加空格。它返回写入的字节数以及任何遇到的错误。

func Fprintf(w io.Writer, format string, a ...interface{}) (n int, err error) //Fprintf 根据于格式说明符进行格式化并写入到 w。它返回写入的字节数以及任何遇到的写入错误。
func Fprintln(w io.Writer, a ...interface{}) (n int, err error)  //Fprintln 使用其操作数的默认格式进行格式化并写入到 w。其操作数之间总是添加空格，且总在最后追加一个换行符。它返回写入的字节数以及任何遇到的错误。

``` go
func main() {
    a := "asdf"
    fmt.Fprintln(os.Stdout, a)          //asdf
    fmt.Fprintf(os.Stdout, "%.2s\n", a) //as
    fmt.Fprint(os.Stdout, a)            //asdf
}
```

func Fscan(r io.Reader, a ...interface{}) (n int, err error) //Fscan 扫描从 r 中读取的文本，并将连续由空格分隔的值存储为连续的实参。换行符计为空格。它返回成功扫描的条目数。若它少于实参数，err 就会报告原因。
func Fscanf(r io.Reader, format string, a ...interface{}) (n int, err error) //Fscanf 扫描从 r 中读取的文本，并将连续由空格分隔的值存储为连续的实参，其格式由 format 决定。它返回成功解析的条目数。
func Fscanln(r io.Reader, a ...interface{}) (n int, err error) //Fscanln 类似于 Sscan，但它在换行符处停止扫描，且最后的条目之后必须为换行符或 EOF。
<span style="color:#FF0000">注：Fscan类的也是由空格进行分割的．</span>

``` go
func main() {
    r := strings.NewReader("hello 1")
    var a string
    var b int
    fmt.Fscanln(r, &a, &b)
    fmt.Println(a, b)　　　　　　　　 //hello 1
    r1 := strings.NewReader("helloworld 2")
    fmt.Fscanf(r1, "hello%s%d", &a, &b) 　
    fmt.Println(a, b)　　　　　　　　//world 2
}
```

func Print(a ...interface{}) (n int, err error) //Print 使用其操作数的默认格式进行格式化并写入到标准输出。当两个连续的操作数均不为字符串时，它们之间就会添加空格。它返回写入的字节数以及任何遇到的错误。
func Printf(format string, a ...interface{}) (n int, err error)  //Printf 根据格式说明符进行格式化并写入到标准输出。它返回写入的字节数以及任何遇到的写入错误。
func Println(a ...interface{}) (n int, err error)   //println 使用其操作数的默认格式进行格式化并写入到标准输出。其操作数之间总是添加空格，且总在最后追加一个换行符。它返回写入的字节数以及任何遇到的错误。

``` go
func main() {
    s := "hello,world!"
    fmt.Println(s)     //hello,world!
    fmt.Printf("%s\n", s)    //hello,world!
    fmt.Print(s)           //hello,world!
}
```

其类似与Fprint(os.Stdout,...)
func Scan(a ...interface{}) (n int, err error)  //Scan 扫描从标准输入中读取的文本，并将连续由空格分隔的值存储为连续的实参。换行符计为空格。它返回成功扫描的条目数。若它少于实参数，err 就会报告原因。
func Scanf(format string, a ...interface{}) (n int, err error) //Scanf 扫描从标准输入中读取的文本，并将连续由空格分隔的值存储为连续的实参，其格式由 format 决定。它返回成功扫描的条目数。
func Scanln(a ...interface{}) (n int, err error) //Scanln 类似于 Scan，但它在换行符处停止扫描，且最后的条目之后必须为换行符或 EOF。

``` go
func main() {
    var a string
    var b int
    fmt.Scanln(&a, &b)   // 2,1
    fmt.Println(a, b)        //输出２　１
    fmt.Scanf("%s%d", &a, &b)　//2 1
    fmt.Println(a, b)　　//输出２　１
}
```

func Sprint(a ...interface{}) string　//Sprint 使用其操作数的默认格式进行格式化并返回其结果字符串。当两个连续的操作数均不为字符串时，它们之间就会添加空格。
func Sprintf(format string, a ...interface{}) string     //Fprintf 根据于格式说明符进行格式化并返回其结果字符串。
func Sprintln(a ...interface{}) string       //Sprintln 使用其操作数的默认格式进行格式化并写返回其结果字符串。其操作数之间总是添加空格，且总在最后追加一个换行符。

``` go
func main() {
    a := fmt.Sprintf("%s,%d", "hello", 1)
    fmt.Println(a)       //hello,1
}
```

func Sscan(str string, a ...interface{}) (n int, err error) //Sscan 扫描实参 string，并将连续由空格分隔的值存储为连续的实参。换行符计为空格。它返回成功扫描的条目数。若它少于实参数，err 就会报告原因。
func Sscanf(str string, format string, a ...interface{}) (n int, err error) //Scanf 扫描实参 string，并将连续由空格分隔的值存储为连续的实参，其格式由 format 决定。它返回成功解析的条目数。
func Sscanln(str string, a ...interface{}) (n int, err error)  //Sscanln 类似于 Sscan，但它在换行符处停止扫描，且最后的条目之后必须为换行符或 EOF。
<span style="color:#FF0000">注：Sscanf有固定格式去进行分割读取数值，而Sscan和Sscanln靠空格进行分割进行值存储．</span>

``` go
func main() {
    var a string
    var b int
    var c int
    fmt.Sscan("hello 1", &a, &b) //hello 1
    fmt.Println(a, b)
    fmt.Sscanf("helloworld 2 ", "hello%s%d", &a, &c) //world 2
    fmt.Println(a, c)
}
```

type Formatter

``` go
// Formatter 用于实现对象的自定义格式输出
type Formatter interface {
    // Format 用来处理当对象遇到 c 标记时的输出方式（c 相当于 %s 中的 s）
    // f 用来获取占位符的宽度、精度、扩展标记等信息，同时实现最终的输出
    // c 是要处理的标记
    Format(f State, c rune)
}
```

type GoStringer

``` go
type GoStringer interface {
    // GoString 获取对象的 Go 语法文本形式（以 %#v 格式输出的文本）
    GoString() string
}
```

type ScanState

``` go
// ScanState 会返回扫描状态给自定义的 Scanner
// Scanner 可能会做字符的实时扫描
// 或者通过 ScanState 获取以空格分割的 token
type ScanState interface {
    // ReadRune 从输入对象中读出一个 Unicode 字符<pre name="code" class="html">//world 2
```

// 如果在 Scanln、Fscanln 或 Sscanln 中调用该方法// 该方法会在遇到 '\\n' 或读取超过指定的宽度时返回 EOFReadRune() (r rune, size int, err error)// UnreadRune 撤消最后一次的 ReadRune 操作UnreadRune() error// SkipSpace 跳过输入数据中的空格// 在 Scanln、Fscanln、Sscanln 操作中，换行符会被当作 EOF// 在其它 Scan 操作中，换行符会被当作空格SkipSpace()// 如果参数 skipSpace 为 true，则 Token 会跳过输入数据中的空格// 然后返回满足函数 f 的连续字符，如果 f 为 nil，则使用 !unicode.IsSpace 来代替 f// 在 Scanln、Fscanln、Sscanln 操作中，换行符会被当作 EOF// 在其它 Scan 操作中，换行符会被当作空格// 返回的 token 是一个切片，返回的数据可能在下一次调用 Token 的时候被修改Token(skipSpace bool, f func(rune) bool) (token \[\]byte, err error)// Width 返回宽度值以及宽度值是否被设置Width() (wid int, ok bool)// 因为 ReadRune 已经通过接口实现，所以 Read 可能永远不会被 Scan 例程调用// 一个 ScanState 的实现，可能会选择废弃 Read 方法，而使其始终返回一个错误信息Read(buf \[\]byte) (n int, err error)}

type Scanner

    type Scanner interface {
        Scan(state ScanState, verb rune) error
    }

Scanner 由任何拥有 Scan 方法的值实现，它将输入扫描成值的表示，并将其结果存储到接收者中，该接收者必须为可用的指针。Scan 方法会被 Scan、Scanf 或 Scanln 的任何实现了它的实参所调用。

type State

    type State interface {

        // Write 函数用于打印出已格式化的输出。
        Write(b []byte) (ret int, err error)

        // Width 返回宽度选项的值以及它是否已被设置。
        Width() (wid int, ok bool)

        // Precision 返回精度选项的值以及它是否已被设置。
        Precision() (prec int, ok bool)

        // Flag 返回标记 c（一个字符）是否已被设置。
        Flag(c int) bool
    }

type Stringer

``` go
type Stringer interface {
    // String 获取对象的文本形式
    String() string
}
```

示例如下：

``` go
type Ustr string

func (us Ustr) String() string {
    return string(us) + " 自定义格式"
}

func (us Ustr) GoString() string {
    return string(us) + " Go 格式"
}

func (us Ustr) Format(f fmt.State, c rune) {
    switch c {
    case 'm', 'M':
        f.Write([]byte(us + "\n扩展标记：["))
        if f.Flag('-') {
            f.Write([]byte(" -"))
        }
        if f.Flag('+') {
            f.Write([]byte(" +"))
        }
        if f.Flag('#') {
            f.Write([]byte(" #"))
        }
        if f.Flag(' ') {
            f.Write([]byte(" space"))
        }
        if f.Flag('0') {
            f.Write([]byte(" 0"))
        }
        f.Write([]byte(" ]\n"))
        if w, wok := f.Width(); wok {
            f.Write([]byte("宽度值：" + fmt.Sprint(w) + "\n"))
        }
        if p, pok := f.Precision(); pok {
            f.Write([]byte("精度值：" + fmt.Sprint(p)))
        }
    case 'v': // 如果使用 Format 函数，则必须自己处理所有格式，包括 %#v
        if f.Flag('#') {
            f.Write([]byte(us.GoString()))
        } else {
            f.Write([]byte(us.String()))
        }
    default: // 如果使用 Format 函数，则必须自己处理默认输出
        f.Write([]byte(us.String()))
    }
}

func main() {
    us := Ustr("Hello World!")
    fmt.Printf("% 0-+#8.5m\n", us)
    // Hello World!
    // 扩展标记：[ - + # space 0 ]
    // 宽度值：8
    // 精度值：5
    fmt.Println(us)
    // Hello World! 自定义格式
    fmt.Printf("%#v\n", us)
    // Hello World! Go 格式
}
```

参考：
Golang学习-fmt包：<http://www.cnblogs.com/golove/p/3286303.html>

go语言官网：<http://golang.org/pkg/fmt/>
