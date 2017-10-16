---
title: golang 中io包用法（一）
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang 中io包用法（一）](/chenbaoke/article/details/40318163)

本文转自Golove博客：[http://www.cnblogs.com/golove/p/3276678.html ](http://www.cnblogs.com/golove/p/3276678.html)  ，并在此基础上进行修改．[
](http://www.cnblogs.com/golove/p/3276678.html)

io 包为I/O原语提供了基础的接口.它主要包装了这些原语的已有实现，如 os 包中的那些，抽象成函数性的共享公共接口，加上一些其它相关的原语。

由于这些接口和原语以不同的实现包装了低级操作，因此除非另行通知，否则客户不应假定它们对于并行执行是安全的。

在io包中最重要的是两个接口：Reader和Writer接口，首先来介绍这两个接口．

``` go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

Reader 接口包装了基本的 Read 方法。

Read 将 len(p) 个字节读取到 p 中。它返回读取的字节数 n（0 &lt;= n &lt;= len(p)）以及任何遇到的错误。即使 Read 返回的 n &lt; len(p)，它也会在调用过程中使用 p的全部作为暂存空间。若一些数据可用但不到 len(p) 个字节，Read 会照例返回可用的东西，而不是等待更多。

当 Read 在成功读取 n &gt; 0 个字节后遇到一个错误或 EOF 情况，它就会返回读取的字节数。它会从相同的调用中返回（非nil的）错误或从随后的调用中返回错误（和 n == 0）。这种一般情况的一个例子就是 Reader 在输入流结束时会返回一个非零的字节数，可能的返回不是 err == EOF 就是 err == nil。无论如何，下一个 Read 都应当返回 0, EOF。

调用者应当总在考虑到错误 err 前处理 n &gt; 0 的字节。这样做可以在读取一些字节，以及允许的 EOF 行为后正确地处理I/O错误。

Read 的实现会阻止返回零字节的计数和一个 nil 错误，调用者应将这种情况视作空操作。

    type Writer interface {
        Write(p []byte) (n int, err error)
    }

Writer 接口包装了基本的 Write 方法。

Write 将 len(p) 个字节从 p 中写入到基本数据流中。它返回从 p 中被写入的字节数n（0 &lt;= n &lt;= len(p)）以及任何遇到的引起写入提前停止的错误。若 Write 返回的n &lt; len(p)，它就必须返回一个非nil的错误。Write 不能修改此切片的数据，即便它是临时的。

Io包中的函数（方法）：
func ReadFull(r Reader, buf \[\]byte) (n int, err error)
　　这个函数可以把对象 r 中的数据读出来，然后存入一个缓冲区 buf 中，以便其它代码可以处理 buf 中的数据。
　　这里有个问题，ReadFull 函数究竟可以读取哪些对象的数据？可以读文件中的数据吗？可以读网络中的数据吗？可以读数据库中的数据吗？可以读磁盘中的扇区吗？可以读内存中的数据吗？
　　答案是 ReadFull 可以读取任何对象的数据，但是有个前提，就是这个对象必须符合 Reader 的标准。
　　Reader 的标准是什么呢？下面是 Reader 的定义：

``` go
type Reader interface {
Read(p []byte) (n int, err error)
}
```

　　从上面的定义可以看出，Reader 的标准很简单，只要某个对象实现了 Read 方法，这个对象就符合了 Reader 的标准，就可以被 ReadFull 读取。
　　太简单了，只需要实现 Read 方法，不需要做其它任何事情。下面我们就来定义一个自己的类型，然后实现 Read 方法：
``` go
// 定义一个 Ustr 类型（以 string 为基类型）
type Ustr string

// 实现 Ustr 类型的 Read 方法
func (s Ustr) Read(p []byte) (n int, err error) {
    i, ls, lp := 0, len(s), len(p)
    for ; i < ls && i < lp; i++ {
        // 将小写字母转换为大写字母，然后写入 p 中
        if s[i] >= 'a' && s[i] <= 'z' {
            p[i] = s[i] + 'A' - 'a'
        } else {
            p[i] = s[i]
        }
    }
    // 根据读取的字节数设置返回值
    switch i {
    case lp:
        return i, nil
    case ls:
        return i, io.EOF
    default:
        return i, errors.New("Read Fail")
    }
}
```

　　接下来，我们就可以用 ReadFull 方法读取 Ustr 对象的数据了：
``` go
func main() {
    us := Ustr("Hello World!")     // 创建 Ustr 对象 us
    buf := make([]byte, 32)        // 创建缓冲区 buf
    n, err := io.ReadFull(us, buf) // 将 us 中的数据读取到 buf 中
    fmt.Printf("%s\n", buf)        // 显示 buf 中的内容
    // HELLO WORLD!
    fmt.Println(n, err) // 显示返回值
    // 12 unexpected EOF
}
```

　　我们很快就实现了 Reader 的要求，这个 Reader 就是一个接口，接口就是一个标准，一个要求，一个规定，这个规定就是“要实现接口中的方法”。只要某个对象符合 Reader 接口的要求，那么这个对象就可以当作 Reader 接口来使用，就可以传递给 ReadFull 方法。
　　所以，只要文件对象实现了 Read 方法，那么 ReadFull 就可以读取文件中的数据，只要网络对象实现了 Read 方法，ReadFull 就可以读取网络中的数据，只要数据库实现了 Read 方法，ReadFull 就可以读取数据库中的数据，只要磁盘对象实现了 Read 方法，ReadFull 就可以读磁盘中的数据，只要内存对象实现了 Read 方法，ReadFull 就可以读取内存中的数据，只要任何一个对象实现了 Read 方法，ReadFull 就可以读取该对象的数据。
　　在 io 包中，定义了许多基本的接口类型，Go 语言的标准库中大量使用了这些接口（就像 ReadFull 一样使用它们），下面我们就来看一看都有哪些接口：
------------------------------------------------------------
// Reader 接口封装了基本的 Read 方法
// Read 方法用于将对象的数据流读入到 p 中
// 直到“p 被装满”或者“数据被读完”或者“数据读取出错”为止
// 返回读取的字节数 n (0 &lt;= n &lt;= len(p)) 和读取过程中遇到的任何错误
// 如果“p 被装满”，则 err 应该返回 nil
// 如果“数据被读完”，则 err 应该返回 EOF
// 如果“数据读取出错”，则 err 应该返回相应的错误信息
// Reader 用来输出数据
``` go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

------------------------------------------------------------
// Writer 接口封装了基本的 Write 方法
// Write 方法用于将 p 中的数据写入到对象的数据流中
// 返回写入的字节数 n (0 &lt;= n &lt;= len(p)) 和写入时遇到的任何错误
// 如果 p 中的数据全部被写入，则 err 应该返回 nil
// 如果 p 中的数据无法被全部写入，则 err 应该返回相应的错误信息
// Writer 用来存入数据
``` go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

------------------------------------------------------------
// Closer 接口封装了基本的 Close 方法
// Close 一般用于关闭文件，关闭连接，关闭数据库等
// Close 用来关闭数据
``` go
type Closer interface {
    Close() error
}
```

------------------------------------------------------------
// Seeker 接口封装了基本的 Seek 方法
// Seek 设置下一次读写操作的指针位置，每次的读写操作都是从指针位置开始的
// whence 的含义：
// 如果 whence 为 0：表示从数据的开头开始移动指针
// 如果 whence 为 1：表示从数据的当前指针位置开始移动指针
// 如果 whence 为 2：表示从数据的尾部开始移动指针
// offset 是指针移动的偏移量
// 返回移动后的指针位置和移动过程中遇到的任何错误
// Seeker 用来移动数据的读写指针
``` go
type Seeker interface {
    Seek(offset int64, whence int) (ret int64, err error)
}
```

------------------------------------------------------------
// 下面是这些接口的组合接口
``` go
type ReadWriter interface {
    Reader
    Writer
}

type ReadSeeker interface {
    Reader
    Seeker
}

type WriteSeeker interface {
    Writer
    Seeker
}

type ReadWriteSeeker interface {
    Reader
    Writer
    Seeker
}

type ReadCloser interface {
    Reader
    Closer
}

type WriteCloser interface {
    Writer
    Closer
}

type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

------------------------------------------------------------
// ReaderFrom 接口封装了基本的 ReadFrom 方法
// ReadFrom 从 r 中读取数据到对象的数据流中
// 直到 r 返回 EOF 或 r 出现读取错误为止
// 返回值 n 是读取的字节数
// 返回值 err 就是 r 的返回值 err
// ReadFrom 用来读出 r 中的数据
``` go
type ReaderFrom interface {
    ReadFrom(r Reader) (n int64, err error)
}
```

------------------------------------------------------------
// WriterTo 接口封装了基本的 WriteTo 方法
// WriterTo 将对象的数据流写入到 w 中
// 直到对象的数据流全部写入完毕或遇到写入错误为止
// 返回值 n 是写入的字节数
// 返回值 err 就是 w 的返回值 err
// WriteTo 用来将数据写入 w 中
``` go
type WriterTo interface {
    WriteTo(w Writer) (n int64, err error)
}
```

------------------------------------------------------------
// ReaderAt 接口封装了基本的 ReadAt 方法
// ReadAt 从对象数据流的 off 处读出数据到 p 中
// 忽略数据的读写指针，从数据的起始位置偏移 off 处开始读取
// 如果对象的数据流只有部分可用，不足以填满 p
// 则 ReadAt 将等待所有数据可用之后，继续向 p 中写入
// 直到将 p 填满后再返回
// 在这点上 ReadAt 要比 Read 更严格
// 返回读取的字节数 n 和读取时遇到的错误
// 如果 n &lt; len(p)，则需要返回一个 err 值来说明
// 为什么没有将 p 填满（比如 EOF）
// 如果 n = len(p)，而且对象的数据没有全部读完，则
// err 将返回 nil
// 如果 n = len(p)，而且对象的数据刚好全部读完，则
// err 将返回 EOF 或者 nil（不确定）
``` go
type ReaderAt interface {
    ReadAt(p []byte, off int64) (n int, err error)
}
```

------------------------------------------------------------
// WriterAt 接口封装了基本的 WriteAt 方法
// WriteAt 将 p 中的数据写入到对象数据流的 off 处
// 忽略数据的读写指针，从数据的起始位置偏移 off 处开始写入
// 返回写入的字节数和写入时遇到的错误
// 如果 n &lt; len(p)，则必须返回一个 err 值来说明
// 为什么没有将 p 完全写入
``` go
type WriterAt interface {
    WriteAt(p []byte, off int64) (n int, err error)
}
```

------------------------------------------------------------
// ByteReader 接口封装了基本的 ReadByte 方法
// ReadByte 从对象的数据流中读取一个字节到 c 中
// 如果对象的数据流中没有可读数据，则返回一个错误信息
``` go
type ByteReader interface {
    ReadByte() (c byte, err error)
}
```

------------------------------------------------------------
// ByteScanner 在 ByteReader 的基础上增加了一个 UnreadByte 方法
// UnreadByte 用于撤消最后一次的 ReadByte 操作
// 即将对象的读写指针移到上次 ReadByte 之前的位置
// 如果上一次的操作不是 ReadByte，则 UnreadByte 返回一个错误信息
``` go
type ByteScanner interface {
ByteReader
UnreadByte() error
}
```

------------------------------------------------------------
// ByteWriter 接口封装了基本的 WriteByte 方法
// WriteByte 将一个字节 c 写入到对象的数据流中
// 返回写入过程中遇到的任何错误
``` go
type ByteWriter interface {
    WriteByte(c byte) error
}
```

------------------------------------------------------------
// RuneReader 接口封装了基本的 ReadRune 方法
// ReadRune 从对象的数据流中读取一个字符到 r 中
// 如果对象的数据流中没有可读数据，则返回一个错误信息
``` go
type RuneReader interface {
    ReadRune() (r rune, size int, err error)
}
```

------------------------------------------------------------
// RuneScanner 在 RuneReader 的基础上增加了一个 UnreadRune 方法
// UnreadRune 用于撤消最后一次的 ReadRune 操作
// 即将对象的读写指针移到上次 ReadRune 之前的位置
// 如果上一次的操作不是 ReadRune，则 UnreadRune 返回一个错误信息
``` go
type RuneScanner interface {
    RuneReader
    UnreadRune() error
}
```

------------------------------------------------------------
// bytes.NewBuffer 实现了很多基本的接口，可以通过 bytes 包学习接口的实现
``` go
func main() {
    bb := bytes.NewBuffer([]byte("Hello World!"))
    b := make([]byte, 32)

    bb.Read(b)
    fmt.Printf("%s\n", b) // Hello World!

    bb.WriteString("New Data!\n")
    bb.WriteTo(os.Stdout) // New Data!

    bb.WriteString("Third Data!")
    bb.ReadByte()
    fmt.Println(bb.String()) // hird Data!
    bb.UnreadByte()
    fmt.Println(bb.String()) // Third Data!
}
```

------------------------------------------------------------
// 下面是 io 包中的函数
------------------------------------------------------------
// WriteString 将字符串 s 写入到 w 中
// 返回写入的字节数和写入过程中遇到的任何错误
// 如果 w 实现了 WriteString 方法
// 则调用 w 的 WriteString 方法将 s 写入 w 中
// 否则，将 s 转换为 \[\]byte
// 然后调用 w.Write 方法将数据写入 w 中
func WriteString(w Writer, s string) (n int, err error)
``` go
func main() {
    // os.Stdout 实现了 Writer 接口
    io.WriteString(os.Stdout, "Hello World!")
    // Hello World!
}
```

------------------------------------------------------------
// ReadAtLeast 从 r 中读取数据到 buf 中，要求至少读取 min 个字节
// 返回读取的字节数 n 和读取过程中遇到的任何错误
// 如果 n &lt; min，则 err 返回 ErrUnexpectedEOF
// 如果 r 中无可读数据，则 err 返回 EOF
// 如果 min 大于 len(buf)，则 err 返回 ErrShortBuffer
// 只有当 n &gt;= min 时 err 才返回 nil
func ReadAtLeast(r Reader, buf \[\]byte, min int) (n int, err error)
``` go
func main() {
    r := strings.NewReader("Hello World!")
    b := make([]byte, 32)
    n, err := io.ReadAtLeast(r, b, 20)
    fmt.Printf("%s\n%d, %v", b, n, err)
    // Hello World!
    // 12, unexpected EOF
}
```

------------------------------------------------------------
// ReadFull 的功能和 ReadAtLeast 一样，只不过 min = len(buf)，<span style="color:#FF0000">其中要求最少读取的字节数目是len(buf)，当r中数据少于len(buf)时便会报错</span>
func ReadFull(r Reader, buf \[\]byte) (n int, err error)
``` go
func main() {
    r := strings.NewReader("Hello World!")
    b := make([]byte, 32)
    n, err := io.ReadFull(r, b)
    fmt.Printf("%s\n%d, %v", b, n, err)
    // Hello World!
    // 12, unexpected EOF
}
```

------------------------------------------------------------
// CopyN 从 src 中复制 n 个字节的数据到 dst 中
// 它返回复制的字节数 written 和复制过程中遇到的任何错误
// 只有当 written = n 时，err 才返回 nil
// 如果 dst 实现了 ReadFrom 方法，则调用 ReadFrom 来执行复制操作
func CopyN(dst Writer, src Reader, n int64) (written int64, err error)
``` go
func main() {
    r := strings.NewReader("Hello World!")
    n, err := io.CopyN(os.Stdout, r, 20)
    fmt.Printf("\n%d, %v", n, err)
    // Hello World!
    // 12, EOF
}
```

------------------------------------------------------------
// Copy 从 src 中复制数据到 dst 中，直到所有数据复制完毕
// 返回复制过程中遇到的任何错误
// 如果数据复制完毕，则 err 返回 nil，而不是 EOF
// 如果 dst 实现了 ReadeFrom 方法，则调用 dst.ReadeFrom(src) 复制数据
// 如果 src 实现了 WriteTo 方法，则调用 src.WriteTo(dst) 复制数据
func Copy(dst Writer, src Reader) (written int64, err error)
``` go
func main() {
    r := strings.NewReader("Hello World!")
    n, err := io.Copy(os.Stdout, r)
    fmt.Printf("\n%d, %v", n, err)
    // Hello World!
    // 12, <nil>
}
```

------------------------------------------------------------
// LimitReader 覆盖了 r 的 Read 方法
// 使 r 只能读取 n 个字节的数据，读取完毕后返回 EOF
func LimitReader(r Reader, n int64) Reader
// LimitedReader 结构用来实现 LimitReader 的功能
type LimitedReader struct
``` go
func main() {
    r := strings.NewReader("Hello World!")
    lr := io.LimitReader(r, 5)
    n, err := io.CopyN(os.Stdout, lr, 20)
    fmt.Printf("\n%d, %v", n, err)
    // Hello
    // 5, EOF
}
```

------------------------------------------------------------
// NewSectionReader 封装 r，并返回 SectionReader 类型的对象
// 使 r 只能从 off 的位置读取 n 个字节的数据，读取完毕后返回 EOF
func NewSectionReader(r ReaderAt, off int64, n int64) \*SectionReader
// SectionReader 结构用来实现 NewSectionReader 的功能
// SectionReader 实现了 Read、Seek、ReadAt、Size 方法
type SectionReader struct
// Size 返回 s 中被限制读取的字节数
func (s \*SectionReader) Size()
``` go
func main() {
    r := strings.NewReader("Hello World!")
    sr := io.NewSectionReader(r, 0, 5)
    n, err := io.CopyN(os.Stdout, sr, 20)
    fmt.Printf("\n%d, %v", n, err)
    fmt.Printf("\n%d", sr.Size())
    // World
    // 5, EOF
    // 5
}
```

------------------------------------------------------------
// TeeReader 覆盖了 r 的 Read 方法
// 使 r 在读取数据的同时，自动向 w 中写入数据
// 所有写入时遇到的错误都被作为 err 返回值
func TeeReader(r Reader, w Writer) Reader
``` go
func main() {
    r := strings.NewReader("Hello World!")
    tr := io.TeeReader(r, os.Stdout)
    b := make([]byte, 32)
    tr.Read(b)
    // World World!
}
```
