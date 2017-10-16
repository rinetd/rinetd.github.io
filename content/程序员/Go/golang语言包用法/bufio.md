---
title: golang中bufio包的用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang,glang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang 中bufio包的用法](/chenbaoke/article/details/40317721)

本文转自GOlove博客：[http://www.cnblogs.com/golove/p/3282667.html ](http://www.cnblogs.com/golove/p/3282667.html)  并在此基础上进行了一些添加修改．     [
](http://www.cnblogs.com/golove/p/3282667.html)

bufio 包中的函数和方法
// bufio 包实现了带缓存的 I/O 操作
// 它封装一个 io.Reader 或 io.Writer 对象
// 使其具有缓存和一些文本读写功能
------------------------------------------------------------
// bufio.go
------------------------------------------------------------

``` go
type Reader struct {
            buf          []byte
            rd           io.Reader // reader provided by the client
            r, w         int       // buf read and write positions
            err          error
            lastByte     int
            lastRuneSize int
        }
```

// NewReaderSize 将 rd 封装成一个拥有 size 大小缓存的 bufio.Reader 对象
// 如果 rd 的基类型就是 bufio.Reader 类型，而且拥有足够的缓存
// 则直接将  rd 转换为基类型并返回
func NewReaderSize(rd io.Reader, size int) \*Reader
// NewReader 相当于 NewReaderSize(rd, 4096)
func NewReader(rd io.Reader) \*Reader
------------------------------------------------------------
// Peek 返回缓存的一个切片，该切片引用缓存中前 n 字节数据
// 该操作不会将数据读出，只是引用
// 引用的数据在下一次读取操作之前是有效的
// 如果引用的数据长度小于 n，则返回一个错误信息
// 如果 n 大于缓存的总大小，则返回 ErrBufferFull
// 通过 Peek 的返回值，可以修改缓存中的数据
// 但是不能修改底层 io.Reader 中的数据
``` go
func main() {
s := strings.NewReader("ABCDEFG")
br := bufio.NewReader(s)

b, _ := br.Peek(5)
fmt.Printf("%s\n", b)
// ABCDE

b[0] = 'a'
b, _ = br.Peek(5)
fmt.Printf("%s\n", b)
// aBCDE
}
```

------------------------------------------------------------
// Read 从 b 中读出数据到 p 中，返回读出的字节数
// 如果 p 的大小 &gt;= 缓存的总大小，而且缓存不为空
// 则只能读出缓存中的数据，不会从底层 io.Reader 中提取数据
// 如果 p 的大小 &gt;= 缓存的总大小，而且缓存为空
// 则直接从底层 io.Reader 向 p 中读出数据，不经过缓存
// 只有当 b 中无可读数据时，才返回 (0, io.EOF)
func (b \*Reader) Read(p \[\]byte) (n int, err error)
``` go
func main() {
s := strings.NewReader("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
br := bufio.NewReader(s)
b := make([]byte, 20)

n, err := br.Read(b)
fmt.Printf("%-20s %-2v %v\n", b[:n], n, err)
// ABCDEFGHIJKLMNOPQRST 20 <nil>

n, err = br.Read(b)
fmt.Printf("%-20s %-2v %v\n", b[:n], n, err)
// UVWXYZ1234567890 16 <nil>

n, err = br.Read(b)
fmt.Printf("%-20s %-2v %v\n", b[:n], n, err)
// 0 EOF
}
```

------------------------------------------------------------
// ReadByte 从 b 中读出一个字节并返回
// 如果 b 中无可读数据，则返回一个错误
func (b \*Reader) ReadByte() (c byte, err error)
// UnreadByte 撤消最后一次读出的字节
// 只有最后读出的字节可以被撤消
// 无论任何操作，只要有内容被读出，就可以用 UnreadByte 撤消一个字节
func (b \*Reader) UnreadByte() error
``` go
func main() {
s := strings.NewReader("ABCDEFG")
br := bufio.NewReader(s)

c, _ := br.ReadByte()
fmt.Printf("%c\n", c)
// A

c, _ = br.ReadByte()
fmt.Printf("%c\n", c)
// B

br.UnreadByte()
c, _ = br.ReadByte()
fmt.Printf("%c\n", c)
// B
}
```

------------------------------------------------------------
// ReadRune 从 b 中读出一个 UTF8 编码的字符并返回
// 同时返回该字符的 UTF8 编码长度
// 如果 UTF8 序列无法解码出一个正确的 Unicode 字符
// 则只读出 b 中的一个字节，并返回 U+FFFD 字符，size 返回 1
func (b \*Reader) ReadRune() (r rune, size int, err error)
// UnreadRune 撤消最后一次读出的 Unicode 字符
// 如果最后一次执行的不是 ReadRune 操作，则返回一个错误
// 因此，UnreadRune 比 UnreadByte 更严格
func (b \*Reader) UnreadRune() error
``` go
func main() {
s := strings.NewReader("你好，世界！")
br := bufio.NewReader(s)

c, size, _ := br.ReadRune()
fmt.Printf("%c %v\n", c, size)
// 你 3

c, size, _ = br.ReadRune()
fmt.Printf("%c %v\n", c, size)
// 好 3

br.UnreadRune()
c, size, _ = br.ReadRune()
fmt.Printf("%c %v\n", c, size)
// 好 3
}
```

------------------------------------------------------------
// Buffered 返回缓存中数据的长度
``` go
func (b *Reader) Buffered() int

func main() {
s := strings.NewReader("你好，世界！")
br := bufio.NewReader(s)

fmt.Println(br.Buffered())
// 0

br.Peek(1)
fmt.Println(br.Buffered())
// 18
}
```

------------------------------------------------------------
// ReadSlice 在 b 中查找 delim 并返回 delim 及其之前的所有数据的切片
// 该操作会读出数据，返回的切片是已读出数据的引用
// 切片中的数据在下一次读取操作之前是有效的
//
// 如果 ReadSlice 在找到 delim 之前遇到错误
// 则读出缓存中的所有数据并返回，同时返回遇到的错误（通常是 io.EOF）
// 如果在整个缓存中都找不到 delim，则 err 返回 ErrBufferFull
// 如果 ReadSlice 能找到 delim，则 err 始终返回 nil
//
// 因为返回的切片中的数据有可能被下一次读写操作修改
// 因此大多数操作应该使用 ReadBytes 或 ReadString，它们返回的不是数据引用
func (b \*Reader) ReadSlice(delim byte) (line \[\]byte, err error)
``` go
func main() {
s := strings.NewReader("ABC DEF GHI JKL")
br := bufio.NewReader(s)

w, _ := br.ReadSlice(' ')
fmt.Printf("%q\n", w)
// "ABC "

w, _ = br.ReadSlice(' ')
fmt.Printf("%q\n", w)
// "DEF "

w, _ = br.ReadSlice(' ')
fmt.Printf("%q\n", w)
// "GHI "
}
```

------------------------------------------------------------
// ReadLine 是一个低级的原始的行读取操作
// 大多数情况下，应该使用 ReadBytes('\\n') 或 ReadString('\\n')
// 或者使用一个 Scanner
//
// ReadLine 通过调用 ReadSlice 方法实现，返回的也是缓存的切片
// ReadLine 尝试返回一个单行数据，不包括行尾标记（\\n 或 \\r\\n）
// 如果在缓存中找不到行尾标记，则设置 isPrefix 为 true，表示查找未完成
// 同时读出缓存中的数据并作为切片返回
// 只有在当前缓存中找到行尾标记，才将 isPrefix 设置为 false，表示查找完成
// 可以多次调用 ReadLine 来读出一行
// 返回的数据在下一次读取操作之前是有效的
// 如果 ReadLine 无法获取任何数据，则返回一个错误信息（通常是 io.EOF）
func (b \*Reader) ReadLine() (line \[\]byte, isPrefix bool, err error)
``` go
func main() {
s := strings.NewReader("ABC\nDEF\r\nGHI\r\nJKL")
br := bufio.NewReader(s)

w, isPrefix, _ := br.ReadLine()
fmt.Printf("%q %v\n", w, isPrefix)
// "ABC" false

w, isPrefix, _ = br.ReadLine()
fmt.Printf("%q %v\n", w, isPrefix)
// "DEF" false

w, isPrefix, _ = br.ReadLine()
fmt.Printf("%q %v\n", w, isPrefix)
// "GHI" false
}
```

------------------------------------------------------------
// ReadBytes 在 b 中查找 delim 并读出 delim 及其之前的所有数据
// 如果 ReadBytes 在找到 delim 之前遇到错误
// 则返回遇到错误之前的所有数据，同时返回遇到的错误（通常是 io.EOF）
// 只有当 ReadBytes 找不到 delim 时，err 才不为 nil
// 对于简单的用途，使用 Scanner 可能更方便
func (b \*Reader) ReadBytes(delim byte) (line \[\]byte, err error)
``` go
func main() {
s := strings.NewReader("ABC DEF GHI JKL")
br := bufio.NewReader(s)

w, _ := br.ReadBytes(' ')
fmt.Printf("%q\n", w)
// "ABC "

w, _ = br.ReadBytes(' ')
fmt.Printf("%q\n", w)
// "DEF "

w, _ = br.ReadBytes(' ')
fmt.Printf("%q\n", w)
// "GHI "
}
```

------------------------------------------------------------
// ReadString 功能同 ReadBytes，只不过返回的是一个字符串
func (b \*Reader) ReadString(delim byte) (line string, err error)
``` go
func main() {
s := strings.NewReader("ABC DEF GHI JKL")
br := bufio.NewReader(s)

w, _ := br.ReadString(' ')
fmt.Printf("%q\n", w)
// "ABC "

w, _ = br.ReadString(' ')
fmt.Printf("%q\n", w)
// "DEF "

w, _ = br.ReadString(' ')
fmt.Printf("%q\n", w)
// "GHI "
}
```

------------------------------------------------------------
// WriteTo 实现了 io.WriterTo 接口
func (b \*Reader) WriteTo(w io.Writer) (n int64, err error)
``` go
func main() {
s := strings.NewReader("ABCEFG")
br := bufio.NewReader(s)
b := bytes.NewBuffer(make([]byte, 0))

br.WriteTo(b)
fmt.Printf("%s\n", b)
// ABCEFG
}
```

------------------------------------------------------------

  `  func (b *Reader) Reset(r io.Reader)`

reset丢弃任何的缓存数据，丛植所有状态并且将缓存读切换到r

``` go
package main

import (
    "bufio"
    "fmt"
    "strings"
)

func main() {
    s := strings.NewReader("ABCEFG")
    str := strings.NewReader("123455")
    br := bufio.NewReader(s)
    b, _ := br.ReadString('\n')
    fmt.Println(b)     //ABCEFG
    br.Reset(str)
    b, _ = br.ReadString('\n')
    fmt.Println(b)     //123455
}
```

------------------------------------------------------------

------------------------------------------------------------
<span style="font-size:18px">// Writer 实现了带缓存的 io.Writer 对象
// 如果在向 Writer 中写入数据的过程中遇到错误
// 则 Writer 不会再接受任何数据
// 而且后续的写入操作都将返回错误信息
type Writer struct {
</span>

       err   error
       buf  []byte
       n     int
       wr   io.Writer

}
// NewWriterSize 将 wr 封装成一个拥有 size 大小缓存的 bufio.Writer 对象
// 如果 wr 的基类型就是 bufio.Writer 类型，而且拥有足够的缓存
// 则直接将 wr 转换为基类型并返回
func NewWriterSize(wr io.Writer, size int) \*Writer
// NewWriter 相当于 NewWriterSize(wr, 4096)
func NewWriter(wr io.Writer) \*Writer
------------------------------------------------------------
// Flush 将缓存中的数据提交到底层的 io.Writer 中
func (b \*Writer) Flush() error
// Available 返回缓存中的可以空间
func (b \*Writer) Available() int
// Buffered 返回缓存中未提交的数据长度
func (b \*Writer) Buffered() int
// Write 将 p 中的数据写入 b 中，返回写入的字节数
// 如果写入的字节数小于 p 的长度，则返回一个错误信息
func (b \*Writer) Write(p \[\]byte) (nn int, err error)
// WriteString 同 Write，只不过写入的是字符串
func (b \*Writer) WriteString(s string) (int, error)
``` go
func main() {
    b := bytes.NewBuffer(make([]byte, 0))
    bw := bufio.NewWriter(b)
    fmt.Println(bw.Available()) // 4096
    fmt.Println(bw.Buffered())  // 0

    bw.WriteString("ABCDEFGH")
    fmt.Println(bw.Available()) // 4088
    fmt.Println(bw.Buffered())  // 8
    fmt.Printf("%q\n", b)       // ""

    bw.Flush()
    fmt.Println(bw.Available()) // 4096
    fmt.Println(bw.Buffered())  // 0
    fmt.Printf("%q\n", b)       // "ABCEFG"
}
```

------------------------------------------------------------
// WriteByte 向 b 中写入一个字节
func (b \*Writer) WriteByte(c byte) error
// WriteRune 向 b 中写入 r 的 UTF8 编码
// 返回 r 的编码长度
func (b \*Writer) WriteRune(r rune) (size int, err error)
``` go
func main() {
    b := bytes.NewBuffer(make([]byte, 0))
    bw := bufio.NewWriter(b)
    bw.WriteByte('H')
    bw.WriteByte('e')
    bw.WriteByte('l')
    bw.WriteByte('l')
    bw.WriteByte('o')
    bw.WriteByte(' ')
    bw.WriteRune('世')
    bw.WriteRune('界')
    bw.WriteRune('！')
    bw.Flush()
    fmt.Println(b) // Hello 世界！

}
```

------------------------------------------------------------
// ReadFrom 实现了 io.ReaderFrom 接口
func (b \*Writer) ReadFrom(r io.Reader) (n int64, err error)
``` go
func main() {
b := bytes.NewBuffer(make([]byte, 0))
s := strings.NewReader("Hello 世界！")
bw := bufio.NewWriter(b)
bw.ReadFrom(s)
//bw.Flush()            //ReadFrom无需使用Flush，其自己已经写入．
fmt.Println(b) // Hello 世界！
}
```

------------------------------------------------------------

    func (b *Writer) Reset(w io.Writer)

Reset丢弃任何没有写入的缓存数据，清除任何错误并且重新将b指定它的输出结果指向w

``` go
package main

import (
    "bufio"
    "bytes"
    "fmt"
)

func main() {
    b := bytes.NewBuffer(make([]byte, 0))
    bw := bufio.NewWriter(b)
    bw.WriteString("123")
    c := bytes.NewBuffer(make([]byte, 0))
    bw.Reset(c)
    bw.WriteString("456")
    bw.Flush()
    fmt.Println(b)       //输出为空
    fmt.Println(c)　　//输出456
}
```

------------------------------------------------------------
// ReadWriter 集成了 bufio.Reader 和 bufio.Writer
// 它实现了 io.ReadWriter 接口

``` go
type ReadWriter struct {
*Reader
*Writer
}
```

// NewReadWriter 封装 r 和 w 为一个 bufio.ReadWriter 对象
func NewReadWriter(r \*Reader, w \*Writer) \*ReadWriter

``` go
package main

import (
    "bufio"
    "bytes"
    "fmt"
    "strings"
)

func main() {
    b := bytes.NewBuffer(make([]byte, 0))
    bw := bufio.NewWriter(b)
    s := strings.NewReader("123")
    br := bufio.NewReader(s)
    rw := bufio.NewReadWriter(br, bw)
    p, _ := rw.ReadString('\n')
    fmt.Println(string(p))              //123
    rw.WriteString("asdf")
    rw.Flush()
    fmt.Println(b)                          //asdf
}
```

------------------------------------------------------------
// scan.go
------------------------------------------------------------
<span style="font-size:18px">// Scanner 提供了一个方便的接口来读取数据，例如读取一个多行文本
// 连续调用 Scan 方法将扫描数据中的“指定部分”，跳过各个“指定部分”之间的数据
// Scanner 使用了缓存，所以“指定部分”的长度不能超出缓存的长度
// Scanner 需要一个 SplitFunc 类型的“切分函数”来确定“指定部分”的格式
// 本包中提供的“切分函数”有<span style="color:#FF0000">“行切分函数”、“字节切分函数”、“UTF8字符编码切分函数”
// 和“单词切分函数”，用户也可以自定义“切分函数”
// 默认的“切分函数”为“行切分函数”，用于获取数据中的一行数据（不包括行尾符）</span>
//
// 扫描在遇到下面的情况时会停止：
// 1、数据扫描完毕，遇到 io.EOF
// 2、遇到读写错误
// 3、“指定部分”的长度超过了缓存的长度
// 如果要对数据进行更多的控制，比如的错误处理或扫描更大的“指定部分”或顺序扫描
// 则应该使用 bufio.Reader
</span>

    type Scanner struct {
        r            io.Reader // The reader provided by the client.
        split        SplitFunc // The function to split the tokens.
        maxTokenSize int       // Maximum size of a token; modified by tests.
        token        []byte    // Last token returned by split.
        buf          []byte    // Buffer used as argument to split.
        start        int       // First non-processed byte in buf.
        end          int       // End of data in buf.
        err          error     // Sticky error.
    }

// SplitFunc 用来定义“切分函数”类型
// data 是要扫描的数据
// atEOF 标记底层 io.Reader 中的数据是否已经读完
// advance 返回 data 中已处理的数据长度
// token 返回找到的“指定部分”
// err 返回错误信息
// 如果在 data 中无法找到一个完整的“指定部分”
// 则 SplitFunc 返回 (0, nil) 来告诉 Scanner
// 向缓存中填充更多数据，然后再次扫描
//
// 如果返回的 err 是非 nil 值，扫描将被终止，并返回错误信息
//
// 如果 data 为空，则“切分函数”将不被调用
// 意思是在 SplitFunc 中不必考虑 data 为空的情况
//
// SplitFunc 的作用很简单，从 data 中找出你感兴趣的数据，然后返回
// 并告诉调用者，data 中有多少数据你已经处理过了
type SplitFunc func(data \[\]byte, atEOF bool) (advance int, token \[\]byte, err error)
// NewScanner 创建一个 Scanner 来扫描 r
// 默认切分函数为 ScanLines
func NewScanner(r io.Reader) \*Scanner
// Err 返回扫描过程中遇到的非 EOF 错误
// 供用户调用，以便获取错误信息
func (s \*Scanner) Err() error
------------------------------------------------------------
// Bytes 将最后一次扫描出的“指定部分”作为一个切片返回（引用传递）
// 下一次的 Scan 操作会覆盖本次返回的结果
func (s \*Scanner) Bytes() \[\]byte
// Text 将最后一次扫描出的“指定部分”作为字符串返回（值传递）
func (s \*Scanner) Text() string
------------------------------------------------------------
// Scan 在 Scanner 的数据中扫描“指定部分”
// 找到后，用户可以通过 Bytes 或 Text 方法来取出“指定部分”
// 如果扫描过程中遇到错误，则终止扫描，并返回 false
func (s \*Scanner) Scan() bool
``` go
func main() {
s := strings.NewReader("ABC\nDEF\r\nGHI\nJKL")
bs := bufio.NewScanner(s)
for bs.Scan() {
fmt.Printf("%s %v\n", bs.Bytes(), bs.Text())
}
// ABC ABC
// DEF DEF
// GHI GHI
// JKL JKL
}
```

------------------------------------------------------------
// Split 用于设置 Scanner 的“切分函数”
// 这个函数必须在调用 Scan 前执行
func (s \*Scanner) Split(split SplitFunc)
``` go
func main() {
s := strings.NewReader("ABC DEF GHI JKL")
bs := bufio.NewScanner(s)
bs.Split(bufio.ScanWords)
for bs.Scan() {
fmt.Println(bs.Text())
}
// ABC
// DEF
// GHI
// JKL
}
```

------------------------------------------------------------
// ScanBytes 是一个“切分函数”
// 用来找出 data 中的单个字节并返回
func ScanBytes(data \[\]byte, atEOF bool) (advance int, token \[\]byte, err error)
``` go
func main() {
s := strings.NewReader("Hello 世界！")
bs := bufio.NewScanner(s)
bs.Split(bufio.ScanBytes)
for bs.Scan() {
fmt.Printf("%s ", bs.Text())
}
}
```

------------------------------------------------------------
// ScanRunes 是一个“切分函数”
// 用来找出 data 中的单个 UTF8 字符的编码并返回
// 如果 UTF8 解码出错，则返回的 U+FFFD 会被做为 "\\xef\\xbf\\xbd" 返回
// 这使得用户无法区分“真正的U+FFFD字符”和“解码错误的返回值”
func ScanRunes(data \[\]byte, atEOF bool) (advance int, token \[\]byte, err error)
``` go
func main() {
s := strings.NewReader("Hello 世界！")
bs := bufio.NewScanner(s)
bs.Split(bufio.ScanRunes)
for bs.Scan() {
fmt.Printf("%s ", bs.Text())
} // H e l l o 世 界 ！
}
```

------------------------------------------------------------
// ScanLines 是一个“切分函数”
// 用来找出 data 中的单行数据并返回（包括空行）
// 行尾标记可能是 \\n 或 \\r\\n（返回值不包括行尾标记）
func ScanLines(data \[\]byte, atEOF bool) (advance int, token \[\]byte, err error)
------------------------------------------------------------
// ScanWords 是一个“切分函数”
// 用来找出 data 中的单词
// 单词以空白字符分隔，空白字符由 unicode.IsSpace 定义
func ScanWords(data \[\]byte, atEOF bool) (advance int, token \[\]byte, err error)
