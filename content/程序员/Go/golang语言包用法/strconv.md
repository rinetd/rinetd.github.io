---
title: golang 中strconv包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang 中strconv包用法](/chenbaoke/article/details/40318357)
本文转自Golove博客：http://www.cnblogs.com/golove/p/3262925.html

strconv 包中的函数和方法
// atob.go
------------------------------------------------------------
// ParseBool 将字符串转换为布尔值
// 它接受真值：[1, t, T, TRUE, true, True]
// 它接受假值：[0, f, F, FALSE, false, False].
// 其它任何值都返回一个错误
func ParseBool(str string) (value bool, err error)

``` go
package main

import (
    "fmt"
    "strconv"
)

func main() {
    fmt.Println(strconv.ParseBool("1"))    // true
    fmt.Println(strconv.ParseBool("t"))    // true
    fmt.Println(strconv.ParseBool("T"))    // true
    fmt.Println(strconv.ParseBool("true")) // true
    fmt.Println(strconv.ParseBool("True")) // true
    fmt.Println(strconv.ParseBool("TRUE")) // true
    fmt.Println(strconv.ParseBool("TRue"))
    // false strconv.ParseBool: parsing "TRue": invalid syntax
    fmt.Println(strconv.ParseBool("0"))     // false
    fmt.Println(strconv.ParseBool("f"))     // false
    fmt.Println(strconv.ParseBool("F"))     // false
    fmt.Println(strconv.ParseBool("false")) // false
    fmt.Println(strconv.ParseBool("False")) // false
    fmt.Println(strconv.ParseBool("FALSE")) // false
    fmt.Println(strconv.ParseBool("FALse"))
    // false strconv.ParseBool: parsing "FAlse": invalid syntax
}
```

------------------------------------------------------------
// FormatBool 将布尔值转换为字符串 "true" 或 "false"
func FormatBool(b bool) string
``` go
func main() {
    fmt.Println(strconv.FormatBool(0 < 1)) // true
    fmt.Println(strconv.FormatBool(0 > 1)) // false
}
```

------------------------------------------------------------
// AppendBool 将布尔值 b 转换为字符串 "true" 或 "false"
// 然后将结果追加到 dst 的尾部，返回追加后的 \[\]byte
func AppendBool(dst \[\]byte, b bool) \[\]byte
``` go
func main() {
    rst := make([]byte, 0)
    rst = strconv.AppendBool(rst, 0 < 1)
    fmt.Printf("%s\n", rst) // true
    rst = strconv.AppendBool(rst, 0 > 1)
    fmt.Printf("%s\n", rst) // truefalse
}
```

============================================================
// atof.go
------------------------------------------------------------
// ParseFloat 将字符串转换为浮点数
// s：要转换的字符串
// bitSize：指定浮点类型（32:float32、64:float64）
// 如果 s 是合法的格式，而且接近一个浮点值，
// 则返回浮点数的四舍五入值（依据 IEEE754 的四舍五入标准）
// 如果 s 不是合法的格式，则返回“语法错误”
// 如果转换结果超出 bitSize 范围，则返回“超出范围”
func ParseFloat(s string, bitSize int) (f float64, err error)
``` go
func main() {
    s := "0.12345678901234567890"
    f, err := strconv.ParseFloat(s, 32)
    fmt.Println(f, err)          // 0.12345679104328156
    fmt.Println(float32(f), err) // 0.12345679
    f, err = strconv.ParseFloat(s, 64)
    fmt.Println(f, err) // 0.12345678901234568
}
```

============================================================
// atoi.go
------------------------------------------------------------
// ErrRange 表示值超出范围
var ErrRange = errors.New("value out of range")
// ErrSyntax 表示语法不正确
var ErrSyntax = errors.New("invalid syntax")
// NumError 记录转换失败
type NumError struct {
Func string // 失败的函数名(ParseBool, ParseInt, ParseUint, ParseFloat)
Num string // 输入的值
Err error // 失败的原因(ErrRange, ErrSyntax)
}
// int 或 uint 类型的长度(32 或 64)
const IntSize = intSize
const intSize = 32 &lt;&lt; uint(^uint(0)&gt;&gt;63)
// 实现 Error 接口，输出错误信息
func (e \*NumError) Error() string
------------------------------------------------------------
// ParseInt 将字符串转换为 int 类型
// s：要转换的字符串
// base：进位制（2 进制到 36 进制）
// bitSize：指定整数类型（0:int、8:int8、16:int16、32:int32、64:int64）
// 返回转换后的结果和转换时遇到的错误
// 如果 base 为 0，则根据字符串的前缀判断进位制（0x:16，0:8，其它:10）
func ParseInt(s string, base int, bitSize int) (i int64, err error)
``` go
func main() {
    fmt.Println(strconv.ParseInt("123", 10, 8))
    // 123
    fmt.Println(strconv.ParseInt("12345", 10, 8))
    // 127 strconv.ParseInt: parsing "12345": value out of range
    fmt.Println(strconv.ParseInt("2147483647", 10, 0))
    // 2147483647
    fmt.Println(strconv.ParseInt("0xFF", 16, 0))
    // 0 strconv.ParseInt: parsing "0xFF": invalid syntax
    fmt.Println(strconv.ParseInt("FF", 16, 0))
    // 255
    fmt.Println(strconv.ParseInt("0xFF", 0, 0))
    // 255
}
```

------------------------------------------------------------
// ParseUint 功能同 ParseInt 一样，只不过返回 uint 类型整数
func ParseUint(s string, base int, bitSize int) (n uint64, err error)
``` go
func main() {
    fmt.Println(strconv.ParseUint("FF", 16, 8))
    // 255
}
```

------------------------------------------------------------
// Atoi 相当于 ParseInt(s, 10, 0)
// 通常使用这个函数，而不使用 ParseInt
func Atoi(s string) (i int, err error)
``` go
func main() {
    fmt.Println(strconv.Atoi("2147483647"))
    // 2147483647
    fmt.Println(strconv.Atoi("2147483648"))
    // 2147483647 strconv.ParseInt: parsing "2147483648": value out of range
}
```

============================================================
// ftoa.go
------------------------------------------------------------
// FormatFloat 将浮点数 f 转换为字符串值
// f：要转换的浮点数
// fmt：格式标记（b、e、E、f、g、G）
// prec：精度（数字部分的长度，不包括指数部分）
// bitSize：指定浮点类型（32:float32、64:float64）
//
// 格式标记：
// 'b' (-ddddp±ddd，二进制指数)
// 'e' (-d.dddde±dd，十进制指数)
// 'E' (-d.ddddE±dd，十进制指数)
// 'f' (-ddd.dddd，没有指数)
// 'g' ('e':大指数，'f':其它情况)
// 'G' ('E':大指数，'f':其它情况)
//
// 如果格式标记为 'e'，'E'和'f'，则 prec 表示小数点后的数字位数
// 如果格式标记为 'g'，'G'，则 prec 表示总的数字位数（整数部分+小数部分）
func FormatFloat(f float64, fmt byte, prec, bitSize int) string
``` go
package main

import (
    "fmt"
    "strconv"
)

func main() {
    f := 100.12345678901234567890123456789
    fmt.Println(strconv.FormatFloat(f, 'b', 5, 32))
    // 13123382p-17
    fmt.Println(strconv.FormatFloat(f, 'e', 5, 32))
    // 1.00123e+02
    fmt.Println(strconv.FormatFloat(f, 'E', 5, 32))
    // 1.00123E+02
    fmt.Println(strconv.FormatFloat(f, 'f', 5, 32))
    // 100.12346
    fmt.Println(strconv.FormatFloat(f, 'g', 5, 32))
    // 100.12
    fmt.Println(strconv.FormatFloat(f, 'G', 5, 32))
    // 100.12
    fmt.Println(strconv.FormatFloat(f, 'b', 30, 32))
    // 13123382p-17
    fmt.Println(strconv.FormatFloat(f, 'e', 30, 32))
    // 1.001234588623046875000000000000e+02
    fmt.Println(strconv.FormatFloat(f, 'E', 30, 32))
    // 1.001234588623046875000000000000E+02
    fmt.Println(strconv.FormatFloat(f, 'f', 30, 32))
    // 100.123458862304687500000000000000
    fmt.Println(strconv.FormatFloat(f, 'g', 30, 32))
    // 100.1234588623046875
    fmt.Println(strconv.FormatFloat(f, 'G', 30, 32))
    // 100.1234588623046875
}
```

------------------------------------------------------------
// AppendFloat 将浮点数 f 转换为字符串值，并将转换结果追加到 dst 的尾部
// 返回追加后的 \[\]byte
func AppendFloat(dst \[\]byte, f float64, fmt byte, prec int, bitSize int) \[\]byte
``` go
func main() {
    f := 100.12345678901234567890123456789
    b := make([]byte, 0)
    b = strconv.AppendFloat(b, f, 'f', 5, 32)
    b = append(b, " "...)
    b = strconv.AppendFloat(b, f, 'e', 5, 32)
    fmt.Printf("%s", b) // 100.12346 1.00123e+0
}
```

============================================================
// itoa.go
------------------------------------------------------------
// FormatUint 将 int 型整数 i 转换为字符串形式
// base：进位制（2 进制到 36 进制）
// 大于 10 进制的数，返回值使用小写字母 'a' 到 'z'
func FormatInt(i int64, base int) string
``` go
func main() {
    i := int64(-2048)
    fmt.Println(strconv.FormatInt(i, 2))  // -100000000000  二进制
    fmt.Println(strconv.FormatInt(i, 8))  // -4000
    fmt.Println(strconv.FormatInt(i, 10)) // -2048          十进制
    fmt.Println(strconv.FormatInt(i, 16)) // -800           十六进制
    fmt.Println(strconv.FormatInt(i, 36)) // -1kw
}
```

------------------------------------------------------------
// FormatUint 将 uint 型整数 i 转换为字符串形式
// base：进位制（2 进制到 36 进制）
// 大于 10 进制的数，返回值使用小写字母 'a' 到 'z'
func FormatUint(i uint64, base int) string
``` go
func main() {
    i := uint64(2048)
    fmt.Println(strconv.FormatUint(i, 2))  // 100000000000
    fmt.Println(strconv.FormatUint(i, 8))  // 4000
    fmt.Println(strconv.FormatUint(i, 10)) // 2048
    fmt.Println(strconv.FormatUint(i, 16)) // 800
    fmt.Println(strconv.FormatUint(i, 36)) // 1kw
}
```

------------------------------------------------------------
// Itoa 相当于 FormatInt(i, 10)
func Itoa(i int) string
``` go
func main() {
    fmt.Println(strconv.Itoa(-2048)) // -2048
    fmt.Println(strconv.Itoa(2048))  // 2048
}
```

------------------------------------------------------------
// AppendInt 将 int 型整数 i 转换为字符串形式，并追加到 dst 的尾部
// i：要转换的字符串
// base：进位制
// 返回追加后的 \[\]byte
func AppendInt(dst \[\]byte, i int64, base int) \[\]byte
``` go
func main() {
    b := make([]byte, 0)
    b = strconv.AppendInt(b, -2048, 16)
    fmt.Printf("%s", b) // -800
}
```

------------------------------------------------------------
// AppendUint 将 uint 型整数 i 转换为字符串形式，并追加到 dst 的尾部
// i：要转换的字符串
// base：进位制
// 返回追加后的 \[\]byte
```go
func AppendUint(dst \[\]byte, i uint64, base int) \[\]byte
func main() {
    b := make(\[\]byte, 0)
    b = strconv.AppendUint(b, 2048, 16)
    fmt.Printf("%s", b) // 800
}
```
============================================================
// quote.go
------------------------------------------------------------
// Quote 将字符串 s 转换为“双引号”引起来的字符串
// 其中的特殊字符将被转换为“转义字符”
// “不可显示的字符”将被转换为“转义字符”
func Quote(s string) string
``` go
func main() {
    fmt.Println(strconv.Quote(`C:\Windows`))
    // "C:\\Windows"
}
```

<span style="color:#FF0000">注：此处是反引号（键盘上１左侧那个按键），而不是单引号</span>
------------------------------------------------------------
// AppendQuote 将字符串 s 转换为“双引号”引起来的字符串，
// 并将结果追加到 dst 的尾部，返回追加后的 \[\]byte
// 其中的特殊字符将被转换为“转义字符”
func AppendQuote(dst \[\]byte, s string) \[\]byte
``` go
func main() {
    s := `C:\Windows`
    b := make([]byte, 0)
    b = strconv.AppendQuote(b, s)
    fmt.Printf("%s", b) // "C:\\Windows"
}
```

------------------------------------------------------------
// QuoteToASCII 将字符串 s 转换为“双引号”引起来的 ASCII 字符串
// “非 ASCII 字符”和“特殊字符”将被转换为“转义字符”
func QuoteToASCII(s string) string
``` go
func main() {
    fmt.Println(strconv.QuoteToASCII("Hello 世界！"))
    // "Hello \u4e16\u754c\uff01"
}
```

------------------------------------------------------------
// AppendQuoteToASCII 将字符串 s 转换为“双引号”引起来的 ASCII 字符串，
// 并将结果追加到 dst 的尾部，返回追加后的 \[\]byte
// “非 ASCII 字符”和“特殊字符”将被转换为“转义字符”
func AppendQuoteToASCII(dst \[\]byte, s string) \[\]byte
``` go
func main() {
    s := "Hello 世界！"
    b := make([]byte, 0)
    b = strconv.AppendQuoteToASCII(b, s)
    fmt.Printf("%s", b) // "Hello \u4e16\u754c\uff01"
}
```

------------------------------------------------------------
// QuoteRune 将 Unicode 字符转换为“单引号”引起来的字符串
// “特殊字符”将被转换为“转义字符”
func QuoteRune(r rune) string
func main() {
    fmt.Println(strconv.QuoteRune('好'))
    // '好'
}
<span style="color:#FF0000">注：此处为单引号，而不是反引号，这点要与Quote()使用去分开</span>
------------------------------------------------------------
// AppendQuoteRune 将 Unicode 字符转换为“单引号”引起来的字符串，
// 并将结果追加到 dst 的尾部，返回追加后的 \[\]byte
// “特殊字符”将被转换为“转义字符”
func AppendQuoteRune(dst \[\]byte, r rune) \[\]byte
``` go
func main() {
    b := make([]byte, 0)
    b = strconv.AppendQuoteRune(b, '好')
    fmt.Printf("%s", b) // '好'
}
```

------------------------------------------------------------
// QuoteRuneToASCII 将 Unicode 字符转换为“单引号”引起来的 ASCII 字符串
// “非 ASCII 字符”和“特殊字符”将被转换为“转义字符”
func QuoteRuneToASCII(r rune) string
``` go
func main() {
    fmt.Println(strconv.QuoteRuneToASCII('好'))
    // '\u597d'
}
```

------------------------------------------------------------
// AppendQuoteRune 将 Unicode 字符转换为“单引号”引起来的 ASCII 字符串，
// 并将结果追加到 dst 的尾部，返回追加后的 \[\]byte
// “非 ASCII 字符”和“特殊字符”将被转换为“转义字符”
func AppendQuoteRuneToASCII(dst \[\]byte, r rune) \[\]byte
``` go
func main() {
    b := make([]byte, 0)
    b = strconv.AppendQuoteRuneToASCII(b, '好')
    fmt.Printf("%s", b) // '\u597d'
}
```

------------------------------------------------------------
// CanBackquote 判断字符串 s 是否可以表示为一个单行的“反引号”字符串
// 字符串中不能含有控制字符（除了 \\t）和“反引号”字符，否则返回 false
func CanBackquote(s string) bool
``` go
func main() {
    b := strconv.CanBackquote("C:\\Windows\n")
    fmt.Println(b) // false
    b = strconv.CanBackquote("C:\\Windows\r")
    fmt.Println(b) // false
    b = strconv.CanBackquote("C:\\Windows\f")
    fmt.Println(b) // false
    b = strconv.CanBackquote("C:\\Windows\t")
    fmt.Println(b) // true
    b = strconv.CanBackquote("C:\\`Windows`")
    fmt.Println(b) // false
}
```

------------------------------------------------------------
// UnquoteChar 将 s 中的第一个字符“取消转义”并解码
//
// s：转义后的字符串
// quote：字符串使用的“引号符”（用于对引号符“取消转义”）
//
// value： 解码后的字符
// multibyte：value 是否为多字节字符
// tail： 字符串 s 除去 value 后的剩余部分
// error： 返回 s 中是否存在语法错误
//
// 参数 quote 为“引号符”
// 如果设置为单引号，则 s 中允许出现 \\' 字符，不允许出现单独的 ' 字符
// 如果设置为双引号，则 s 中允许出现 \\" 字符，不允许出现单独的 " 字符
// 如果设置为 0，则不允许出现 \\' 或 \\" 字符，可以出现单独的 ' 或 " 字符
func UnquoteChar(s string, quote byte) (value rune, multibyte bool, tail string, err error)
``` go
func main() {
    s := `\"大\\家\\好！\"`
    c, mb, sr, _ := strconv.UnquoteChar(s, '"')
    fmt.Printf("%-3c %v\n", c, mb)
    for ; len(sr) > 0; c, mb, sr, _ = strconv.UnquoteChar(sr, '"') {
        fmt.Printf("%-3c %v\n", c, mb)
    }
    // " false
    // 大 true
    // \ false
    // 家 true
    // \ false
    // 好 true
    // ！ true
}
```

------------------------------------------------------------
// Unquote 将“带引号的字符串” s 转换为常规的字符串（不带引号和转义字符）
// s 可以是“单引号”、“双引号”或“反引号”引起来的字符串（包括引号本身）
// 如果 s 是单引号引起来的字符串，则返回该该字符串代表的字符
func Unquote(s string) (t string, err error)
``` go
func main() {
    sr, err := strconv.Unquote(`"\"大\t家\t好！\""`)
    fmt.Println(sr, err)
    sr, err = strconv.Unquote(`'大家好！'`)
    fmt.Println(sr, err)
    sr, err = strconv.Unquote(`'好'`)
    fmt.Println(sr, err)
    sr, err = strconv.Unquote("`大\\t家\\t好！`")
    fmt.Println(sr, err)
}
```

------------------------------------------------------------
// IsPrint 判断 Unicode 字符 r 是否是一个可显示的字符
// 可否显示并不是你想象的那样，比如空格可以显示，而\\t则不能显示
// 具体可以参考 Go 语言的源码
func IsPrint(r rune) bool
``` go
func main() {
    fmt.Println(strconv.IsPrint('a'))  // true
    fmt.Println(strconv.IsPrint('好'))  // true
    fmt.Println(strconv.IsPrint(' '))  // true
    fmt.Println(strconv.IsPrint('\t')) // false
    fmt.Println(strconv.IsPrint('\n')) // false
    fmt.Println(strconv.IsPrint(0))    // false
}
```
