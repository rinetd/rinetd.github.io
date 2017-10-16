---
title: golang中strings包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中strings包用法](/chenbaoke/article/details/40318423)
本文转自Golove博客：http://www.cnblogs.com/golove/p/3236300.html

strings 包中的函数和方法
// strings.go
------------------------------------------------------------
// Count 计算字符串 sep 在 s 中的非重叠个数
// 如果 sep 为空字符串，则返回 s 中的字符(非字节)个数 + 1
// 使用 Rabin-Karp 算法实现

``` go
func Count(s, sep string) int

func main() {
s := "Hello,世界!!!!!"
n := strings.Count(s, "!")
fmt.Println(n) // 5
n = strings.Count(s, "!!")
fmt.Println(n) // 2
}
```

------------------------------------------------------------
// Contains 判断字符串 s 中是否包含子串 substr
// 如果 substr 为空，则返回 true
func Contains(s, substr string) bool
``` go
func main() {
s := "Hello,世界!!!!!"
b := strings.Contains(s, "!!")
fmt.Println(b) // true
b = strings.Contains(s, "!?")
fmt.Println(b) // false
b = strings.Contains(s, "")
fmt.Println(b) // true
}
```

------------------------------------------------------------
// ContainsAny 判断字符串 s 中是否包含 chars 中的任何一个字符
// 如果 chars 为空，则返回 false
func ContainsAny(s, chars string) bool
``` go
func main() {
s := "Hello,世界!"
b := strings.ContainsAny(s, "abc")
fmt.Println(b) // false
b = strings.ContainsAny(s, "def")
fmt.Println(b) // true
b = strings.Contains(s, "")
fmt.Println(b) // true
}
```

------------------------------------------------------------
// ContainsRune 判断字符串 s 中是否包含字符 r
func ContainsRune(s string, r rune) bool
``` go
func main() {
    s := "Hello,世界!"
    b := strings.ContainsRune(s, '\n')
    fmt.Println(b) // false
    b = strings.ContainsRune(s, '界')
    fmt.Println(b) // true
    b = strings.ContainsRune(s, 0)
    fmt.Println(b) // false
}
```

------------------------------------------------------------
// Index 返回子串 sep 在字符串 s 中第一次出现的位置
// 如果找不到，则返回 -1，如果 sep 为空，则返回 0。
// 使用 Rabin-Karp 算法实现
func Index(s, sep string) int
``` go
func main() {
    s := "Hello,世界!"
    i := strings.Index(s, "h")
    fmt.Println(i) // -1
    i = strings.Index(s, "!")
    fmt.Println(i) // 12
    i = strings.Index(s, "")
    fmt.Println(i) // 0
}
```

------------------------------------------------------------
// LastIndex 返回子串 sep 在字符串 s 中最后一次出现的位置
// 如果找不到，则返回 -1，如果 sep 为空，则返回字符串的长度
// 使用朴素字符串比较算法实现
func LastIndex(s, sep string) int
``` go
func main() {
    s := "Hello,世界! Hello!"
    i := strings.LastIndex(s, "h")
    fmt.Println(i) // -1
    i = strings.LastIndex(s, "H")
    fmt.Println(i) // 14
    i = strings.LastIndex(s, "")
    fmt.Println(i) // 20
}
```

------------------------------------------------------------
// IndexRune 返回字符 r 在字符串 s 中第一次出现的位置
// 如果找不到，则返回 -1
func IndexRune(s string, r rune) int
``` go
func main() {
    s := "Hello,世界! Hello!"
    i := strings.IndexRune(s, '\n')
    fmt.Println(i) // -1
    i = strings.IndexRune(s, '界')
    fmt.Println(i) // 9
    i = strings.IndexRune(s, 0)
    fmt.Println(i) // -1
}
```

------------------------------------------------------------
// IndexAny 返回字符串 chars 中的任何一个字符在字符串 s 中第一次出现的位置
// 如果找不到，则返回 -1，如果 chars 为空，则返回 -1
func IndexAny(s, chars string) int
``` go
func main() {
    s := "Hello,世界! Hello!"
    i := strings.IndexAny(s, "abc")
    fmt.Println(i) // -1
    i = strings.IndexAny(s, "dof")
    fmt.Println(i) // 1
    i = strings.IndexAny(s, "")
    fmt.Println(i) // -1
}
```

------------------------------------------------------------
// LastIndexAny 返回字符串 chars 中的任何一个字符在字符串 s 中最后一次出现的位置
// 如果找不到，则返回 -1，如果 chars 为空，也返回 -1
func LastIndexAny(s, chars string) int
``` go
func main() {
    s := "Hello,世界! Hello!"
    i := strings.LastIndexAny(s, "abc")
    fmt.Println(i) // -1
    i = strings.LastIndexAny(s, "def")
    fmt.Println(i) // 15
    i = strings.LastIndexAny(s, "")
    fmt.Println(i) // -1
}
```

------------------------------------------------------------
// SplitN 以 sep 为分隔符，将 s 切分成多个子串，结果中不包含 sep 本身
// 如果 sep 为空，则将 s 切分成 Unicode 字符列表。
// 如果 s 中没有 sep 子串，则将整个 s 作为 \[\]string 的第一个元素返回
// 参数 n 表示最多切分出几个子串，超出的部分将不再切分。
// 如果 n 为 0，则返回 nil，如果 n 小于 0，则不限制切分个数，全部切分
func SplitN(s, sep string, n int) \[\]string
``` go
func main() {
    s := "Hello, 世界! Hello!"
    ss := strings.SplitN(s, " ", 2)
    fmt.Printf("%q\n", ss) // ["Hello," "世界! Hello!"]
    ss = strings.SplitN(s, " ", -1)
    fmt.Printf("%q\n", ss) // ["Hello," "世界!" "Hello!"]
    ss = strings.SplitN(s, "", 3)
    fmt.Printf("%q\n", ss) // ["H" "e" "llo, 世界! Hello!"]
}
```

------------------------------------------------------------
// SplitAfterN 以 sep 为分隔符，将 s 切分成多个子串，结果中包含 sep 本身
// 如果 sep 为空，则将 s 切分成 Unicode 字符列表。
// 如果 s 中没有 sep 子串，则将整个 s 作为 \[\]string 的第一个元素返回
// 参数 n 表示最多切分出几个子串，超出的部分将不再切分。
// 如果 n 为 0，则返回 nil，如果 n 小于 0，则不限制切分个数，全部切分
func SplitAfterN(s, sep string, n int) \[\]string
``` go
func main() {
    s := "Hello, 世界! Hello!"
    ss := strings.SplitAfterN(s, " ", 2)
    fmt.Printf("%q\n", ss) // ["Hello, " "世界! Hello!"]
    ss = strings.SplitAfterN(s, " ", -1)
    fmt.Printf("%q\n", ss) // ["Hello, " "世界! " "Hello!"]
    ss = strings.SplitAfterN(s, "", 3)
    fmt.Printf("%q\n", ss) // ["H" "e" "llo, 世界! Hello!"]
}
```

------------------------------------------------------------
// Split 以 sep 为分隔符，将 s 切分成多个子切片，结果中不包含 sep 本身
// 如果 sep 为空，则将 s 切分成 Unicode 字符列表。
// 如果 s 中没有 sep 子串，则将整个 s 作为 \[\]string 的第一个元素返回
func Split(s, sep string) \[\]string
``` go
func main() {
    s := "Hello, 世界! Hello!"
    ss := strings.Split(s, " ")
    fmt.Printf("%q\n", ss) // ["Hello," "世界!" "Hello!"]
    ss = strings.Split(s, ", ")
    fmt.Printf("%q\n", ss) // ["Hello" "世界! Hello!"]
    ss = strings.Split(s, "")
    fmt.Printf("%q\n", ss) // 单个字符列表
}
```

------------------------------------------------------------
// SplitAfter 以 sep 为分隔符，将 s 切分成多个子切片，结果中包含 sep 本身
// 如果 sep 为空，则将 s 切分成 Unicode 字符列表。
// 如果 s 中没有 sep 子串，则将整个 s 作为 \[\]string 的第一个元素返回
func SplitAfter(s, sep string) \[\]string
``` go
func main() {
    s := "Hello, 世界! Hello!"
    ss := strings.SplitAfter(s, " ")
    fmt.Printf("%q\n", ss) // ["Hello, " "世界! " "Hello!"]
    ss = strings.SplitAfter(s, ", ")
    fmt.Printf("%q\n", ss) // ["Hello, " "世界! Hello!"]
    ss = strings.SplitAfter(s, "")
    fmt.Printf("%q\n", ss) // 单个字符列表
}
```

------------------------------------------------------------
// Fields 以连续的空白字符为分隔符，将 s 切分成多个子串，结果中不包含空白字符本身
// 空白字符有：\\t, \\n, \\v, \\f, \\r, ' ', U+0085 (NEL), U+00A0 (NBSP)
// 如果 s 中只包含空白字符，则返回一个空列表
func Fields(s string) \[\]string
``` go
func main() {
    s := "Hello, 世界! Hello!"
    ss := strings.Fields(s)
    fmt.Printf("%q\n", ss) // ["Hello," "世界!" "Hello!"]
}
```

------------------------------------------------------------
// FieldsFunc 以一个或多个满足 f(rune) 的字符为分隔符，
// 将 s 切分成多个子串，结果中不包含分隔符本身。
// 如果 s 中没有满足 f(rune) 的字符，则返回一个空列表。
func FieldsFunc(s string, f func(rune) bool) \[\]string
``` go
func isSlash(r rune) bool {
    return r == '\\' || r == '/'
}

func main() {
    s := "C:\\Windows\\System32\\FileName"
    ss := strings.FieldsFunc(s, isSlash)
    fmt.Printf("%q\n", ss) // ["C:" "Windows" "System32" "FileName"]
}
```

------------------------------------------------------------
// Join 将 a 中的子串连接成一个单独的字符串，子串之间用 sep 分隔
func Join(a \[\]string, sep string) string
``` go
func main() {
    ss := []string{"Monday", "Tuesday", "Wednesday"}
    s := strings.Join(ss, "|")
    fmt.Println(s)
}
```

------------------------------------------------------------
// HasPrefix 判断字符串 s 是否以 prefix 开头
func HasPrefix(s, prefix string) bool
``` go
func main() {
    s := "Hello 世界!"
    b := strings.HasPrefix(s, "hello")
    fmt.Println(b) // false
    b = strings.HasPrefix(s, "Hello")
    fmt.Println(b) // true
}
```

------------------------------------------------------------
// HasSuffix 判断字符串 s 是否以 prefix 结尾
func HasSuffix(s, suffix string) bool
``` go
func main() {
    s := "Hello 世界!"
    b := strings.HasSuffix(s, "世界")
    fmt.Println(b) // false
    b = strings.HasSuffix(s, "世界!")
    fmt.Println(b) // true
}
```

------------------------------------------------------------
// Map 将 s 中满足 mapping(rune) 的字符替换为 mapping(rune) 的返回值。
// 如果 mapping(rune) 返回负数，则相应的字符将被删除。
func Map(mapping func(rune) rune, s string) string
``` go
func Slash(r rune) rune {
    if r == '\\' {
        return '/'
    }
    return r
}
func main() {

    s := "C:\\Windows\\System32\\FileName"
    ms := strings.Map(Slash, s)
    fmt.Printf("%q\n", ms) // "C:/Windows/System32/FileName"
}
```

------------------------------------------------------------
// Repeat 将 count 个字符串 s 连接成一个新的字符串
func Repeat(s string, count int) string
``` go
func main() {
    s := "Hello!"
    rs := strings.Repeat(s, 3)
    fmt.Printf("%q\n", rs) // "Hello!Hello!Hello!"
}
```

------------------------------------------------------------
// ToUpper 将 s 中的所有字符修改为其大写格式
// 对于非 ASCII 字符，它的大写格式需要查表转换
func ToUpper(s string) string
// ToLower 将 s 中的所有字符修改为其小写格式
// 对于非 ASCII 字符，它的小写格式需要查表转换
func ToLower(s string) string
// ToTitle 将 s 中的所有字符修改为其 Title 格式
// 大部分字符的 Title 格式就是其 Upper 格式
// 只有少数字符的 Title 格式是特殊字符
// 这里的 ToTitle 主要给 Title 函数调用
func ToTitle(s string) string
``` go
func main() {
    s := "heLLo worLd Ａｂｃ"
    us := strings.ToUpper(s)
    ls := strings.ToLower(s)
    ts := strings.ToTitle(s)
    fmt.Printf("%q\n", us) // "HELLO WORLD ＡＢＣ"
    fmt.Printf("%q\n", ls) // "hello world ａｂｃ"
    fmt.Printf("%q\n", ts) // "HELLO WORLD ＡＢＣ"
}
```

// 获取非 ASCII 字符的 Title 格式列表
``` go
func main() {
    for _, cr := range unicode.CaseRanges {
        // u := uint32(cr.Delta[unicode.UpperCase]) // 大写格式
        // l := uint32(cr.Delta[unicode.LowerCase]) // 小写格式
        t := uint32(cr.Delta[unicode.TitleCase]) // Title 格式
        // if t != 0 && t != u {
        if t != 0 {
            for i := cr.Lo; i <= cr.Hi; i++ {
                fmt.Printf("%c -> %c\n", i, i+t)
            }
        }
    }
}
```

------------------------------------------------------------
// ToUpperSpecial 将 s 中的所有字符修改为其大写格式。
// 优先使用 \_case 中的规则进行转换
func ToUpperSpecial(\_case unicode.SpecialCase, s string) string
// ToLowerSpecial 将 s 中的所有字符修改为其小写格式。
// 优先使用 \_case 中的规则进行转换
func ToLowerSpecial(\_case unicode.SpecialCase, s string) string
// ToTitleSpecial 将 s 中的所有字符修改为其 Title 格式。
// 优先使用 \_case 中的规则进行转换
func ToTitleSpecial(\_case unicode.SpecialCase, s string) string
\_case 规则说明，以下列语句为例：
unicode.CaseRange{'A', 'Z', \[unicode.MaxCase\]rune{3, -3, 0}}
·其中 'A', 'Z' 表示此规则只影响 'A' 到 'Z' 之间的字符。
·其中 \[unicode.MaxCase\]rune 数组表示：
当使用 ToUpperSpecial 转换时，将字符的 Unicode 编码与第一个元素值（3）相加
当使用 ToLowerSpecial 转换时，将字符的 Unicode 编码与第二个元素值（-3）相加
当使用 ToTitleSpecial 转换时，将字符的 Unicode 编码与第三个元素值（0）相加
``` go
func main() {
    // 定义转换规则
    var _MyCase = unicode.SpecialCase{
        // 将半角逗号替换为全角逗号，ToTitle 不处理
        unicode.CaseRange{',', ',',
            [unicode.MaxCase]rune{'，' - ',', '，' - ',', 0}},
        // 将半角句号替换为全角句号，ToTitle 不处理
        unicode.CaseRange{'.', '.',
            [unicode.MaxCase]rune{'。' - '.', '。' - '.', 0}},
        // 将 ABC 分别替换为全角的 ＡＢＣ、ａｂｃ，ToTitle 不处理
        unicode.CaseRange{'A', 'C',
            [unicode.MaxCase]rune{'Ａ' - 'A', 'ａ' - 'A', 0}},
    }
    s := "ABCDEF,abcdef."
    us := strings.ToUpperSpecial(_MyCase, s)
    fmt.Printf("%q\n", us) // "ＡＢＣDEF，ABCDEF。"
    ls := strings.ToLowerSpecial(_MyCase, s)
    fmt.Printf("%q\n", ls) // "ａｂｃdef，abcdef。"
    ts := strings.ToTitleSpecial(_MyCase, s)
    fmt.Printf("%q\n", ts) // "ABCDEF,ABCDEF."
}
```

------------------------------------------------------------
// Title 将 s 中的所有单词的首字母修改为其 Title 格式
// BUG: Title 规则不能正确处理 Unicode 标点符号
func Title(s string) string
``` go
func main() {
    s := "heLLo worLd"
    ts := strings.Title(s)
    fmt.Printf("%q\n", ts) // "HeLLo WorLd"
}
```

------------------------------------------------------------
// TrimLeftFunc 将删除 s 头部连续的满足 f(rune) 的字符
func TrimLeftFunc(s string, f func(rune) bool) string
------------------------------------------------------------
// TrimRightFunc 将删除 s 尾部连续的满足 f(rune) 的字符
func TrimRightFunc(s string, f func(rune) bool) string
``` go
func isSlash(r rune) bool {
    return r == '\\' || r == '/'
}

func main() {
    s := "\\\\HostName\\C\\Windows\\"
    ts := strings.TrimRightFunc(s, isSlash)
    fmt.Printf("%q\n", ts) // "\\\\HostName\\C\\Windows"
}
```

------------------------------------------------------------
// TrimFunc 将删除 s 首尾连续的满足 f(rune) 的字符
func TrimFunc(s string, f func(rune) bool) string
``` go
func isSlash(r rune) bool {
    return r == '\\' || r == '/'
}
func main() {
    s := "\\\\HostName\\C\\Windows\\"
    ts := strings.TrimFunc(s, isSlash)
    fmt.Printf("%q\n", ts) // "HostName\\C\\Windows"
}
```

------------------------------------------------------------
// 返回 s 中第一个满足 f(rune) 的字符的字节位置。
// 如果没有满足 f(rune) 的字符，则返回 -1
func IndexFunc(s string, f func(rune) bool) int
``` go
func isSlash(r rune) bool {
    return r == '\\' || r == '/'
}

func main() {
    s := "C:\\Windows\\System32"
    i := strings.IndexFunc(s, isSlash)
    fmt.Printf("%v\n", i) // 2
}
```

------------------------------------------------------------
// 返回 s 中最后一个满足 f(rune) 的字符的字节位置。
// 如果没有满足 f(rune) 的字符，则返回 -1
func LastIndexFunc(s string, f func(rune) bool) int
``` go
func isSlash(r rune) bool {
    return r == '\\' || r == '/'
}

func main() {
    s := "C:\\Windows\\System32"
    i := strings.LastIndexFunc(s, isSlash)
    fmt.Printf("%v\n", i) // 10
}
```

------------------------------------------------------------
// Trim 将删除 s 首尾连续的包含在 cutset 中的字符
func Trim(s string, cutset string) string
``` go
func main() {
    s := " Hello 世界! "
    ts := strings.Trim(s, " Helo!")
    fmt.Printf("%q\n", ts) // "世界"
}
```

------------------------------------------------------------
// TrimLeft 将删除 s 头部连续的包含在 cutset 中的字符
func TrimLeft(s string, cutset string) string
``` go
func main() {
    s := " Hello 世界! "
    ts := strings.TrimLeft(s, " Helo")
    fmt.Printf("%q\n", ts) // "世界! "
}
```

------------------------------------------------------------
// TrimRight 将删除 s 尾部连续的包含在 cutset 中的字符
func TrimRight(s string, cutset string) string
``` go
func main() {
    s := " Hello 世界! "
    ts := strings.TrimRight(s, " 世界!")
    fmt.Printf("%q\n", ts) // " Hello"
}
```

------------------------------------------------------------
// TrimSpace 将删除 s 首尾连续的的空白字符
func TrimSpace(s string) string
``` go
func main() {
    s := " Hello 世界! "
    ts := strings.TrimSpace(s)
    fmt.Printf("%q\n", ts) // "Hello 世界!"
}
```

------------------------------------------------------------
// TrimPrefix 删除 s 头部的 prefix 字符串
// 如果 s 不是以 prefix 开头，则返回原始 s
func TrimPrefix(s, prefix string) string
``` go
func main() {
    s := "Hello 世界!"
    ts := strings.TrimPrefix(s, "Hello")
    fmt.Printf("%q\n", ts) // " 世界"
}
```

------------------------------------------------------------
// TrimSuffix 删除 s 尾部的 suffix 字符串
// 如果 s 不是以 suffix 结尾，则返回原始 s
func TrimSuffix(s, suffix string) string
``` go
func main() {
    s := "Hello 世界!!!!!"
    ts := strings.TrimSuffix(s, "!!!!")
    fmt.Printf("%q\n", ts) // " 世界"
}
```

<span style="color:#FF0000">注：TrimSuffix只是去掉s字符串结尾的suffix字符串，只是去掉１次，而TrimRight是一直去掉s字符串右边的字符串，只要有响应的字符串就去掉，是一个多次的过程，这也是二者的本质区别．</span>
------------------------------------------------------------
// Replace 返回 s 的副本，并将副本中的 old 字符串替换为 new 字符串
// 替换次数为 n 次，如果 n 为 -1，则全部替换
// 如果 old 为空，则在副本的每个字符之间都插入一个 new
func Replace(s, old, new string, n int) string

``` go
func main() {
    s := "Hello 世界！"
    s = strings.Replace(s, " ", ",", -1)
    fmt.Println(s)
    s = strings.Replace(s, "", "|", -1)
    fmt.Println(s)
}
```

------------------------------------------------------------
// EqualFold 判断 s 和 t 是否相等。忽略大小写，同时它还会对特殊字符进行转换
// 比如将“ϕ”转换为“Φ”、将“Ǆ”转换为“ǅ”等，然后再进行比较
func EqualFold(s, t string) bool
``` go
func main() {
    s1 := "Hello 世界! ϕ Ǆ"
    s2 := "hello 世界! Φ ǅ"
    b := strings.EqualFold(s1, s2)
    fmt.Printf("%v\n", b) // true
}
```

============================================================
// reader.go
------------------------------------------------------------
// Reader 结构通过读取字符串，实现了 io.Reader，io.ReaderAt，
// io.Seeker，io.WriterTo，io.ByteScanner，io.RuneScanner 接口
type Reader struct {
s string // 要读取的字符串
i int // 当前读取的索引位置，从 i 处开始读取数据
prevRune int // 读取的前一个字符的索引位置，小于 0 表示之前未读取字符
}
// 通过字符串 s 创建 strings.Reader 对象
// 这个函数类似于 bytes.NewBufferString
// 但比 bytes.NewBufferString 更有效率，而且只读
func NewReader(s string) \*Reader { return &Reader{s, 0, -1} }
------------------------------------------------------------
// Len 返回 r.i 之后的所有数据的字节长度
func (r \*Reader) Len() int
``` go
func main() {
    s := "Hello 世界!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 获取字符串的编码长度
    fmt.Println(r.Len()) // 13
}
```

------------------------------------------------------------
// Read 将 r.i 之后的所有数据写入到 b 中（如果 b 的容量足够大）
// 返回读取的字节数和读取过程中遇到的错误
// 如果无可读数据，则返回 io.EOF
func (r \*Reader) Read(b \[\]byte) (n int, err error)
``` go
func main() {
    s := "Hello World!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 创建长度为 5 个字节的缓冲区
    b := make([]byte, 5)
    // 循环读取 r 中的字符串
    for n, _ := r.Read(b); n > 0; n, _ = r.Read(b) {
        fmt.Printf("%q, ", b[:n]) // "Hello", " Worl", "d!"
    }
}
```

------------------------------------------------------------
// ReadAt 将 off 之后的所有数据写入到 b 中（如果 b 的容量足够大）
// 返回读取的字节数和读取过程中遇到的错误
// 如果无可读数据，则返回 io.EOF
// 如果数据被一次性读取完毕，则返回 io.EOF
func (r \*Reader) ReadAt(b \[\]byte, off int64) (n int, err error)
``` go
func main() {
    s := "Hello World!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 创建长度为 5 个字节的缓冲区
    b := make([]byte, 5)
    // 读取 r 中指定位置的字符串
    n, _ := r.ReadAt(b, 0)
    fmt.Printf("%q\n", b[:n]) // "Hello"
    // 读取 r 中指定位置的字符串
    n, _ = r.ReadAt(b, 6)
    fmt.Printf("%q\n", b[:n]) // "World"
}
```

------------------------------------------------------------
// ReadByte 将 r.i 之后的一个字节写入到返回值 b 中
// 返回读取的字节和读取过程中遇到的错误
// 如果无可读数据，则返回 io.EOF
func (r \*Reader) ReadByte() (b byte, err error)
``` go
func main() {
    s := "Hello World!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 读取 r 中的一个字节
    for i := 0; i < 3; i++ {
        b, _ := r.ReadByte()
        fmt.Printf("%q, ", b) // 'H', 'e', 'l',
    }
}
```

------------------------------------------------------------
// UnreadByte 撤消前一次的 ReadByte 操作，即 r.i--
func (r \*Reader) UnreadByte() error
``` go
func main() {
    s := "Hello World!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 读取 r 中的一个字节
    for i := 0; i < 3; i++ {
        b, _ := r.ReadByte()
        fmt.Printf("%q, ", b) // 'H', 'H', 'H',
        r.UnreadByte()        // 撤消前一次的字节读取操作
    }
}
```

------------------------------------------------------------
// ReadRune 将 r.i 之后的一个字符写入到返回值 ch 中
// ch： 读取的字符
// size：ch 的编码长度
// err： 读取过程中遇到的错误
// 如果无可读数据，则返回 io.EOF
// 如果 r.i 之后不是一个合法的 UTF-8 字符编码，则返回 utf8.RuneError 字符
func (r \*Reader) ReadRune() (ch rune, size int, err error)
``` go
func main() {
    s := "你好 世界！"
    // 创建 Reader
    r := strings.NewReader(s)
    // 读取 r 中的一个字符
    for i := 0; i < 5; i++ {
        b, n, _ := r.ReadRune()
        fmt.Printf(`"%c:%v", `, b, n)
        // "你:3", "好:3", " :1", "世:3", "界:3",
    }
}
```

------------------------------------------------------------
// 撤消前一次的 ReadRune 操作
func (r \*Reader) UnreadRune() error
``` go
func main() {
    s := "你好 世界！"
    // 创建 Reader
    r := strings.NewReader(s)
    // 读取 r 中的一个字符
    for i := 0; i < 5; i++ {
        b, _, _ := r.ReadRune()
        fmt.Printf("%q, ", b)
        // '你', '你', '你', '你', '你',
        r.UnreadRune() // 撤消前一次的字符读取操作
    }
}
```

------------------------------------------------------------
// Seek 用来移动 r 中的索引位置
// offset：要移动的偏移量，负数表示反向移动
// whence：从那里开始移动，0：起始位置，1：当前位置，2：结尾位置
// 如果 whence 不是 0、1、2，则返回错误信息
// 如果目标索引位置超出字符串范围，则返回错误信息
// 目标索引位置不能超出 1 &lt;&lt; 31，否则返回错误信息
func (r \*Reader) Seek(offset int64, whence int) (int64, error)
``` go
func main() {
    s := "Hello World!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 创建读取缓冲区
    b := make([]byte, 5)
    // 读取 r 中指定位置的内容
    r.Seek(6, 0) // 移动索引位置到第 7 个字节
    r.Read(b)    // 开始读取
    fmt.Printf("%q\n", b)
    r.Seek(-5, 1) // 将索引位置移回去
    r.Read(b)     // 继续读取
    fmt.Printf("%q\n", b)
}
```

------------------------------------------------------------
// WriteTo 将 r.i 之后的数据写入接口 w 中
func (r \*Reader) WriteTo(w io.Writer) (n int64, err error)
``` go
func main() {
    s := "Hello World!"
    // 创建 Reader
    r := strings.NewReader(s)
    // 创建 bytes.Buffer 对象，它实现了 io.Writer 接口
    buf := bytes.NewBuffer(nil)
    // 将 r 中的数据写入 buf 中
    r.WriteTo(buf)
    fmt.Printf("%q\n", buf) // "Hello World!"
}
```

============================================================
// replace.go
------------------------------------------------------------
// Replacer 根据一个替换列表执行替换操作
type Replacer struct {
Replace(s string) string
WriteString(w io.Writer, s string) (n int, err error)
}
------------------------------------------------------------
// NewReplacer 通过“替换列表”创建一个 Replacer 对象。
// 按照“替换列表”中的顺序进行替换，只替换非重叠部分。
// 如果参数的个数不是偶数，则抛出异常。
// 如果在“替换列表”中有相同的“查找项”，则后面重复的“查找项”会被忽略
func NewReplacer(oldnew ...string) \*Replacer
------------------------------------------------------------
// Replace 返回对 s 进行“查找和替换”后的结果
// Replace 使用的是 Boyer-Moore 算法，速度很快
func (r \*Replacer) Replace(s string) string
``` go
func main() {
    srp := strings.NewReplacer("Hello", "你好", "World", "世界", "!", "！")
    s := "Hello World!Hello World!hello world!"
    rst := srp.Replace(s)
    fmt.Print(rst) // 你好 世界！你好 世界！hello world！
}
<span style="color:#FF0000;">注：这两种写法均可．</span>
func main() {

    wl := []string{"Hello", "Hi", "Hello", "你好"}
    srp := strings.NewReplacer(wl...)
    s := "Hello World! Hello World! hello world!"
    rst := srp.Replace(s)
    fmt.Print(rst) // Hi World! Hi World! hello world!
}
```

------------------------------------------------------------
// WriteString 对 s 进行“查找和替换”，然后将结果写入 w 中
func (r \*Replacer) WriteString(w io.Writer, s string) (n int, err error)
``` go
func main() {
    wl := []string{"Hello", "你好", "World", "世界", "!", "！"}
    srp := strings.NewReplacer(wl...)
    s := "Hello World!Hello World!hello world!"
    srp.WriteString(os.Stdout, s)
    // 你好 世界！你好 世界！hello world！
}
```
