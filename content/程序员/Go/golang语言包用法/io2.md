---
title: golang中io包用法（二）
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中io包用法（二）](/chenbaoke/article/details/42458915)

本文转自<https://github.com/polaris1119/The-Golang-Standard-Library-by-Example/blob/master/chapter01/01.1.md>，并在此基础上进行修改．

io 包为I/O原语提供了基本的接口。它主要包装了这些原语的已有实现。
由于这些接口和原语以不同的实现包装了低级操作，因此除非另行通知，否则客户端不应假定它们对于并行执行是安全的。
在io包中最重要的是两个接口：Reader和Writer接口。本章所提到的各种IO包，都跟这两个接口有关，也就是说，只要实现了这两个接口，它就有了IO的功能。
<span style="font-size:18px"> Reader接口 </span>
Reader接口的定义如下：

``` go
type Reader interface {
Read(p []byte) (n int, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
// Read 将 len(p) 个字节读取到 p 中。它返回读取的字节数 n（0 <= n <= len(p)） 以及任何遇到的错误。即使 Read 返回的 n < len(p)，它也会在调用过程中使用 p 的全部作为暂存空间。若一些数据可用但不到 len(p) 个字节，Read 会照例返回可用的数据，而不是等待更多数据。

//当 Read 在成功读取 n > 0 个字节后遇到一个错误或EOF（end-of-file），它就会返回读取的字节数。它会从相同的调用中返回（非nil的）错误或从随后的调用中返回错误（同时 n == 0）。 一般情况的一个例子就是 Reader 在输入流结束时会返回一个非零的字节数，同时返回的err不是EOF就是nil。无论如何，下一个 Read 都应当返回 0, EOF。

//调用者应当总在考虑到错误 err 前处理 n > 0 的字节。这样做可以在读取一些字节，以及允许的 EOF 行为后正确地处理I/O错误。
```

也就是说，当Read方法返回错误时，不代表没有读取到任何数据。调用者应该处理返回的任何数据，之后才处理可能的错误。
根据Go语言中关于接口和实现了接口的类型的定义，我们知道Reader接口的方法集只包含一个Read方法，因此，所有实现了Read方法的类型都实现了io.Reader接口，也就是说，在所有需要io.Reader的地方，可以传递实现了Read()方法的类型的实例。
下面，我们通过具体例子来谈谈该接口的用法。
``` go
func ReadFrom(reader io.Reader, num int) ([]byte, error) {
p := make([]byte, num)
n, err := reader.Read(p)
if n > 0 {
return p[:n], nil
}
return p, err
}
```

ReadFrom函数将io.Reader作为参数，也就是说，ReadFrom可以从任意的地方读取数据，只要来源实现了io.Reader接口。比如，我们可以从标准输入、文件、字符串等读取数据，示例代码如下：
// 从标准输入读取
data, err = ReadFrom(os.Stdin, 11)
// 从普通文件读取，其中file是os.File的实例
data, err = ReadFrom(file, 9)
// 从字符串读取
data, err = ReadFrom(strings.NewReader("from string"), 12)
\*\*小贴士\*\*
io.EOF 变量的定义：\`var EOF = errors.New("EOF")\`，是error类型。根据reader接口的说明，在 n &gt; 0 且数据被读完了的情况下，返回的error有可能是EOF也有可能是nil。

<span style="font-size:18px">
Writer接口 </span>
Writer接口的定义如下：

``` go
type Writer interface {
Write(p []byte) (n int, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
//Write 将 len(p) 个字节从 p 中写入到基本数据流中。它返回从 p 中被写入的字节数 n（0 <= n <= len(p)）以及任何遇到的引起写入提前停止的错误。若 Write 返回的 n < len(p)，它就必须返回一个非nil的错误。
```

同样的，所有实现了Write方法的类型都实现了io.Writer接口。
在上个例子中，我们是自己实现一个函数接收一个io.Reader类型的参数。这里，我们通过标准库的例子来学习。
在fmt标准库中，有一组函数：Fprint/Fprintf/Fprintln，它们接收一个io.Wrtier类型参数（第一个参数），也就是说它们将数据格式化输出到io.Writer中。那么，调用这组函数时，该如何传递这个参数呢？
我们以fmt.Fprintln为例，同时看一下fmt.Println函数的源码。
``` go
func Println(a ...interface{}) (n int, err error) {
      return Fprintln(os.Stdout, a...)
}
```

<span style="font-size:18px; color:#FF0000">
实现了io.Reader接口或io.Writer接口的类型 </span>
初学者看到函数参数是一个接口类型，很多时候有些束手无策，不知道该怎么传递参数。还有人问：标准库中有哪些类型实现了io.Reader或io.Writer接口？
通过本节上面的例子，我们可以知道，os.File同时实现了这两个接口。我们还看到 os.Stdin/Stdout这样的代码，它们似乎分别实现了 io.Reader/io.Writer接口。没错，实际上在os包中有这样的代码：
``` go
var (
    Stdin  = NewFile(uintptr(syscall.Stdin), "/dev/stdin")
    Stdout = NewFile(uintptr(syscall.Stdout), "/dev/stdout")
    Stderr = NewFile(uintptr(syscall.Stderr), "/dev/stderr")
)
```

也就是说，Stdin/Stdout/Stderr 只是三个特殊的文件（即都是os.File的实例），自然也实现了io.Reader和io.Writer。
目前，Go文档中还没法直接列出实现了某个接口的所有类型。不过，我们可以通过查看标准库文档，<span style="color:#FF0000">列出实现了io.Reader或io.Writer接口的类型（导出的类型）</span>：
``` go
- os.File 同时实现了io.Reader和io.Writer
- strings.Reader 实现了io.Reader
- bufio.Reader/Writer 分别实现了io.Reader和io.Writer
- bytes.Buffer 同时实现了io.Reader和io.Writer
- bytes.Reader 实现了io.Reader
- compress/gzip.Reader/Writer 分别实现了io.Reader和io.Writer
- crypto/cipher.StreamReader/StreamWriter 分别实现了io.Reader和io.Writer
- crypto/tls.Conn 同时实现了io.Reader和io.Writer
- encoding/csv.Reader/Writer 分别实现了io.Reader和io.Writer
- mime/multipart.Part 实现了io.Reader</span>
```

除此之外，io包本身也有这两个接口的实现类型。如：
实现了Reader的类型：LimitedReader、PipeReader、SectionReader
实现了Writer的类型：PipeWriter
<span style="color:#FF0000">
以上类型中，常用的类型有：os.File、strings.Reader、bufio.Reader/Writer、bytes.Buffer、bytes.Reader</span>
\*\*小贴士\*\*
从接口名称很容易猜到，一般地，Go中接口的命名约定：接口名以er结尾。注意，这里并非强行要求，你完全可以不以 er 结尾。标准库中有些接口也不是以 er 结尾的。

<span style="font-size:18px">
</span>

<span style="font-size:18px">ReaderAt和WriterAt接口 </span>
\*\*ReaderAt接口\*\*的定义如下：

``` go
type ReaderAt interface {
    ReadAt(p []byte, off int64) (n int, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
> ReadAt 从基本输入源的偏移量 off 处开始，将 len(p) 个字节读取到 p 中。它返回读取的字节数 n（0 <= n <= len(p)）以及任何遇到的错误。

> 当 ReadAt 返回的 n < len(p) 时，它就会返回一个非nil的错误来解释 为什么没有返回更多的字节。在这一点上，ReadAt 比 Read 更严格。

> 即使 ReadAt 返回的 n < len(p)，它也会在调用过程中使用 p 的全部作为暂存空间。若一些数据可用但不到 len(p) 字节，ReadAt 就会阻塞直到所有数据都可用或产生一个错误。 在这一点上 ReadAt 不同于 Read。

> 若 n = len(p) 个字节在输入源的的结尾处由 ReadAt 返回，那么这时 err == EOF 或者 err == nil。

> 若 ReadAt 按查找偏移量从输入源读取，ReadAt 应当既不影响基本查找偏移量也不被它所影响。

> ReadAt 的客户端可对相同的输入源并行执行 ReadAt 调用。
```

可见，ReaderAt接口使得可以从指定偏移量处开始读取数据。
简单示例代码如下：
``` go
package main

import (
    "fmt"
    "strings"
)

func main() {
    reader := strings.NewReader("Go语言学习园地")
    p := make([]byte, 6)
    n, err := reader.ReadAt(p, 2)
    if err != nil {
        panic(err)
    }
    fmt.Printf("%s, %d\n", p, n)
}
运行结果： 语言, 6
```

\*\*WriterAt接口\*\*的定义如下：
``` go
type WriterAt interface {
    WriteAt(p []byte, off int64) (n int, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
> WriteAt 从 p 中将 len(p) 个字节写入到偏移量 off 处的基本数据流中。它返回从 p 中被写入的字节数 n（0 <= n <= len(p)）以及任何遇到的引起写入提前停止的错误。若 WriteAt 返回的 n < len(p)，它就必须返回一个非nil的错误。

> 若 WriteAt 按查找偏移量写入到目标中，WriteAt 应当既不影响基本查找偏移量也不被它所影响。

> 若区域没有重叠，WriteAt 的客户端可对相同的目标并行执行 WriteAt 调用。
```

我们可以通过该接口将数据写入数据流的特定偏移量之后。
通过简单示例来演示WriteAt方法的使用（os.File实现了WriterAt接口）：
``` go
package main

import (
    "fmt"
    "os"
)

func main() {
    file, err := os.Create("writeAt.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()
    file.WriteString("Golang中文社区——这里是多余的")
    n, err := file.WriteAt([]byte("Go语言学习园地"), 24)
    if err != nil {
        panic(err)
    }
    fmt.Println(n)
}
```

打开文件WriteAt.txt，内容是：\`Golang中文社区——Go语言学习园地\`。
分析：
\`file.WriteString("Golang中文社区——这里是多余的")\` 往文件中写入\`Golang中文社区——这里是多余的\`，之后 \`file.WriteAt(\[\]byte("Go语言学习园地"), 24)\` 在文件流的offset=24处写入\`Go语言学习园地\`（会覆盖该位置的内容）。
<span style="font-size:18px">ReaderFrom 和 WriterTo 接口 </span>
\*\*ReaderFrom\*\*的定义如下：
``` go
type ReaderFrom interface {
    ReadFrom(r Reader) (n int64, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
> ReadFrom 从 r 中读取数据，直到 EOF 或发生错误。其返回值 n 为读取的字节数。除 io.EOF 之外，在读取过程中遇到的任何错误也将被返回。

> 如果 ReaderFrom 可用，Copy 函数就会使用它。
```

注意：ReadFrom方法不会返回err == EOF。
下面的例子简单的实现将文件中的数据全部读取（显示在标准输出）：
``` go
package main

import (
    "bufio"
    "os"
)

func main() {

    file, err := os.Open("writeAt.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()
    writer := bufio.NewWriter(os.Stdout)
    writer.ReadFrom(file)
    writer.Flush()
}
```

当然，我们可以通过ioutil包的ReadFile函数获取文件全部内容。其实，跟踪一下ioutil.ReadFile的源码，会发现其实也是通过ReadFrom方法实现（用的是bytes.Buffer，它实现了ReaderFrom接口）。
如果不通过ReadFrom接口来做这件事，而是使用io.Reader接口，我们有两种思路：
1. 先获取文件的大小（File的Stat方法），之后定义一个该大小的\[\]byte，通过Read一次性读取
2. 定义一个小的\[\]byte，不断的调用Read方法直到遇到EOF，将所有读取到的\[\]byte连接到一起
代码实现如下：

``` go
方法１：
package main

import (
    "fmt"
    "os"
)

func main() {

    file, err := os.Open("writeAt.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()
    stat, err := file.Stat()
    if err != nil {
        fmt.Println(err)
    }
    size := stat.Size()

    a := make([]byte, size)
    file.Read(a)
    fmt.Println(string(a))
}
运行结果： Golang中文社区——Go语言学习园地

方法２：
package main

import (
    "fmt"
    "os"
)

func main() {

    file, err := os.Open("writeAt.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()
    a := make([]byte, 5)
    var b []byte
    for n, err := file.Read(a); err == nil; n, err = file.Read(a) {
        b = append(b, a[:n]...)
    }
    fmt.Println(string(b))
}
运行结果： Golang中文社区——Go语言学习园地
```

\*\*提示\*\*通过查看 bufio.Writer或strings.Buffer 类型的ReadFrom方法实现，会发现，其实它们的实现和上面说的第2种思路类似。\*\*WriterTo\*\*的定义如下：
``` go
type WriterTo interface {
    WriteTo(w Writer) (n int64, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
> WriteTo 将数据写入 w 中，直到没有数据可写或发生错误。其返回值 n 为写入的字节数。 在写入过程中遇到的任何错误也将被返回。

> 如果 WriterTo 可用，Copy 函数就会使用它。
```

读者是否发现，其实ReaderFrom和WriterTo接口的方法接收的参数是io.Reader和io.Writer类型。根据io.Reader和io.Writer接口的讲解，对该接口的使用应该可以很好的掌握。
这里只提供简单的一个示例代码：将一段文本输出到标准输出
reader := bytes.NewReader(\[\]byte("Go语言学习园地"))
reader.WriteTo(os.Stdout)
通过io.ReaderFrom和io.WriterTo的学习，我们知道，如果这样的需求，可以考虑使用这两个接口：“一次性从某个地方读或写到某个地方去。”
\#\# Seeker接口 \#\#
接口定义如下：
``` go
type Seeker interface {
    Seek(offset int64, whence int) (ret int64, err error)
}
```

官方文档中关于该接口方法的说明：
``` go
> Seek 设置下一次 Read 或 Write 的偏移量为 offset，它的解释取决于 whence： 0 表示相对于文件的起始处，1 表示相对于当前的偏移，而 2 表示相对于其结尾处。 Seek 返回新的偏移量和一个错误，如果有的话。
```

也就是说，Seek方法用于设置偏移量的，这样可以从某个特定位置开始操作数据流。听起来和ReaderAt/WriteAt接口有些类似，不过Seeker接口更灵活，可以更好的控制读写数据流的位置。
简单的示例代码：获取倒数第二个字符（需要考虑UTF-8编码，这里的代码只是一个示例）
``` go
package main

import (
    "fmt"
    "strings"
)

func main() {

    reader := strings.NewReader("Go语言学习园地")
    reader.Seek(-6, 2)
    r, _, _ := reader.ReadRune()
    fmt.Printf("%c\n", r)
}
运行结果：园
```

\*\*小贴士\*\*
whence的值，在os包中定义了相应的常量，应该使用这些常量
const (
SEEK\_SET int = 0 // seek relative to the origin of the file
SEEK\_CUR int = 1 // seek relative to the current offset
SEEK\_END int = 2 // seek relative to the end
)
\#\# Closer接口 \#\#
接口定义如下：
``` go
type Closer interface {
    Close() error
}
```

该接口比较简单，只有一个Close()方法，用于关闭数据流。
<span style="color:#FF0000">文件(os.File)、归档（压缩包）、数据库连接、Socket等需要手动关闭的资源都实现了Closer接口。
实际编程中，经常将Close方法的调用放在defer语句中。</span>
\*\*小提示\*\*
初学者容易写出这样的代码：
file, err := os.Open("studygolang.txt")
defer file.Close()
if err != nil {
...
}
当文件 studygolang.txt 不存在或找不到时，file.Close()会panic，因为file是nil。因此，应该将defer file.Close()放在错误检查之后。
<span style="font-size:18px">其他接口 </span>
 ByteReader和ByteWriter
通过名称大概也能猜出这组接口的用途：读或写一个字节。接口定义如下：
``` go
type ByteReader interface {
    ReadByte() (c byte, err error)
}

type ByteWriter interface {
    WriteByte(c byte) error
}
```

<span style="color:#FF0000">
在标准库中，有如下类型实现了io.ByteReader或io.ByteWriter:</span>
``` go
- bufio.Reader/Writer 分别实现了io.ByteReader和io.ByteWriter
- bytes.Buffer 同时实现了io.ByteReader和io.ByteWriter
- bytes.Reader 实现了io.ByteReader
- strings.Reader 实现了io.ByteReader</span>
```

接下来的示例中，我们通过bytes.Buffer来一次读取或写入一个字节（主要代码）：
``` go
package main

import (
    "bytes"
    "fmt"
)

func main() {
    var ch byte
    fmt.Scanf("%c\n", &ch)

    buffer := new(bytes.Buffer)
    err := buffer.WriteByte(ch)
    if err == nil {
        fmt.Println("写入一个字节成功！准备读取该字节……")
        newCh, _ := buffer.ReadByte()
        fmt.Printf("读取的字节：%c\n", newCh)
    } else {
        fmt.Println("写入错误")
    }

}
```

程序从标准输入接收一个字节（ASCII字符），调用buffer的WriteByte将该字节写入buffer中，之后通过ReadByte读取该字节。
一般地，我们不会使用bytes.Buffer来一次读取或写入一个字节。那么，这两个接口有哪些用处呢？
在标准库encoding/binary中，实现Varints读取，就需要一个io.ByteReader类型的参数，也就是说，它需要一个字节一个字节的读取。关于encoding/binary包在后面会详细介绍。
在标准库image/jpeg中，Encode函数的内部实现使用了ByteWriter写入一个字节。
\*\*小贴士\*\*
可以通过在Go语言源码src/pkg中搜索"<span style="color:#FF0000">io.ByteReader"或"io.ByteWiter"，获得哪些地方用到了这两个接口。你会发现，这两个接口在二进制数据或归档压缩时用的比较多。</span>

ByteScanner、RuneReader和RuneScanner
将这三个接口放在一起，是考虑到与ByteReader相关或相应。
ByteScanner接口的定义如下：

``` go
type ByteScanner interface {
    ByteReader
    UnreadByte() error
}
```

可见，它内嵌了ByteReader接口（可以理解为继承了ByteReader接口），UnreadByte方法的意思是：将上一次ReadByte的字节还原，使得再次调用ReadByte返回的结果和上一次调用相同，也就是说，UnreadByte是重置上一次的ReadByte。注意，UnreadByte调用之前必须调用了ReadByte，且不能连续调用UnreadByte。即：
buffer := bytes.NewBuffer(\[\]byte{'a', 'b'})
err := buffer.UnreadByte()
和
``` go
package main

import (
    "bytes"
    "fmt"
)

func main() {

    buffer := bytes.NewBuffer([]byte{'a', 'b'})
    buffer.ReadByte()
    buffer.ReadByte()

    err := buffer.UnreadByte()
    fmt.Println(err) //<nil>
    err = buffer.UnreadByte()
    fmt.Println(err) //  bytes.Buffer: UnreadByte: previous operation was not a read

}
```

err都非nil，错误为：\`bytes.Buffer: UnreadByte: previous operation was not a read\`
RuneReader接口和ByteReader类似，只是ReadRune方法读取单个UTF-8字符，返回其rune和该字符占用的字节数。该接口在regexp包有用到。
RuneScanner接口和ByteScanner类似，就不赘述了。

<span style="font-size:18px">
ReadCloser、ReadSeeker、ReadWriteCloser、ReadWriteSeeker、ReadWriter、WriteCloser和WriteSeeker接口</span>
这些接口是上面介绍的接口的两个或三个组合而成的新接口。例如ReadWriter接口：

``` go
type ReadWriter interface {
    Reader
    Writer
}
```

这是Reader接口和Writer接口的简单组合（内嵌）。
这些接口的作用是：有些时候同时需要某两个接口的所有功能，即必须同时实现了某两个接口的类型才能够被传入使用。可见，io包中有大量的"小接口"，这样方便组合为"大接口"。
\#\# SectionReader 类型 \#\#
SectionReader是一个struct（没有任何导出的字段），实现了 Read, Seek 和 ReadAt，同时，内嵌了 ReaderAt 接口。结构定义如下：
``` go
type SectionReader struct {
    r     ReaderAt // 该类型最终的 Read/ReadAt 最终都是通过 r 的 ReadAt 实现
    base  int64    // NewSectionReader 会将 base 设置为 off
    off   int64    // 从 r 中的 off 偏移处开始读取数据
    limit int64    // limit - off = SectionReader 流的长度
}
```

从名称我们可以猜到，该类型读取数据流中部分数据。看一下
\`func NewSectionReader(r ReaderAt, off int64, n int64) \*SectionReader\`
的文档说明就知道了：
NewSectionReader 返回一个 SectionReader，它从 r 中的偏移量 off 处读取 n 个字节后以 EOF 停止。
也就是说，SectionReader 只是内部（内嵌）ReaderAt表示的数据流的一部分：从 off 开始后的n个字节。
这个类型的作用是：方便重复操作某一段(section)数据流；或者同时需要ReadAt和Seek的功能。
由于该类型所支持的操作，前面都有介绍，因此提供示例代码了。
关于该类型在标准库中的使用，我们在 \[archive/zip — zip归档访问\]() 会讲到。
\#\# LimitedReader 类型 \#\#
LimitedReader 类型定义如下：
``` go
type LimitedReader struct {
    R Reader // underlying reader，最终的读取操作通过 R.Read 完成
    N int64  // max bytes remaining
}
```

文档说明如下：
``` go
> 从 R 读取但将返回的数据量限制为 N 字节。每调用一次 Read 都将更新 N 来反应新的剩余数量。

也就是说，最多只能返回 N 字节数据。
```

LimitedReader只实现了Read方法（Reader接口）。
使用示例如下：
``` go
package main

import (
    "fmt"
    "io"
    "strings"
)

func main() {

    content := "This Is LimitReader Example"
    reader := strings.NewReader(content)
    limitReader := &io.LimitedReader{R: reader, N: 20}
    for limitReader.N > 0 {
        tmp := make([]byte, 2)
        limitReader.Read(tmp)
        fmt.Printf("%s", tmp)
    }

}
运行结果：This Is LimitReader
```

可见，通过该类型可以达到 \*只允许读取一定长度数据\* 的目的。
在io包中，LimitReader 函数的实现其实就是调用 LimitedReader：
func LimitReader(r Reader, n int64) Reader { return &LimitedReader{r, n} }

<span style="font-size:18px">PipReader 和 PipWriter 类型 </span>
PipReader（一个没有任何导出字段的struct）是管道的读取端。它实现了io.Reader和io.Closer接口。
\*\*关于 Read 方法的说明\*\*：从管道中读取数据。该方法会堵塞，直到管道写入端开始写入数据或写入端关闭了。如果写入端关闭时带上了error（即调用CloseWithError关闭），该方法返回的err就是写入端传递的error；否则err为EOF。
PipWriter（一个没有任何导出字段的struct）是管道的写入端。它实现了io.Writer和io.Closer接口。
\*\*关于 Write 方法的说明\*\*：写数据到管道中。该方法会堵塞，直到管道读取端读完所有数据或读取端关闭了。如果读取端关闭时带上了error（即调用CloseWithError关闭），该方法返回的err就是读取端传递的error；否则err为 ErrClosedPipe。
其他方法的使用通过例子一起讲解：

``` go
package main

import (
    "errors"
    "fmt"
    "io"
    "time"
)

func main() {
    Pipe()
}

func Pipe() {
    pipeReader, pipeWriter := io.Pipe()
    go PipeRead(pipeReader)
    PipeWrite(pipeWriter)
    time.Sleep(1e7)
}

func PipeWrite(pipeWriter *io.PipeWriter) {
    var (
        i   = 0
        err error
        n   int
    )
    data := []byte("Go语言学习园地")
    for _, err = pipeWriter.Write(data); err == nil; n, err = pipeWriter.Write(data) {
        i++
        if i == 3 {
            pipeWriter.CloseWithError(errors.New("输出3次后结束"))
        }
    }
    fmt.Println("close 后输出的字节数：", n, " error：", err)
}

func PipeRead(pipeReader *io.PipeReader) {
    var (
        err error
        n   int
    )
    data := make([]byte, 1024)
    for n, err = pipeReader.Read(data); err == nil; n, err = pipeReader.Read(data) {
        fmt.Printf("%s\n", data[:n])
    }
    fmt.Println("writer 端 closewitherror后：", err)
}
```

运行结果：
 Go语言学习园地
  Go语言学习园地
  Go语言学习园地
  close 后输出的字节数： 0  error： io: read/write on closed pipe
  writer 端 closewitherror后： 输出3次后结束
代码分析：
io.Pipe()用于创建创建一个同步的内存管道（synchronous in-memory pipe），函数签名：
``` go
func Pipe() (*PipeReader, *PipeWriter)
```

<span style="color:#FF0000">它将 io.Reader 连接到 io.Writer。一端的读取匹配另一端的写入，直接在这两端之间复制数据；它没有内部缓存。它对于并行调用 Read 和 Write 以及其它函数或 Close 来说都是安全的。 一旦等待的I/O结束，Close 就会完成。并行调用 Read 或并行调用 Write 也同样安全： 同种类的调用将按顺序进行控制。稍候我们会分析管道相关的源码。</span>
正因为是同步的（其原理和无缓存channel类似），因此不能在一个goroutine中进行读和写。
<span style="font-size:18px">Copy 和 CopyN 函数 </span>
\*\*Copy 函数\*\*的：
``` go
func Copy(dst Writer, src Reader) (written int64, err error)
```

函数文档：
``` go
> Copy 将 src 复制到 dst，直到在 src 上到达 EOF 或发生错误。它返回复制的字节数，如果有的话，还会返回在复制时遇到的第一个错误。

> 成功的 Copy 返回 err == nil，而非 err == EOF。由于 Copy 被定义为从 src 读取直到 EOF 为止，因此它不会将来自 Read 的 EOF 当做错误来报告。

> 若 dst 实现了 ReaderFrom 接口，其复制操作可通过调用 dst.ReadFrom(src) 实现。此外，若 dst 实现了 WriterTo 接口，其复制操作可通过调用 src.WriteTo(dst) 实现。
```

代码：
io.Copy(os.Stdout, strings.NewReader("Go语言学习园地"))
直接将内容输出（写入Stdout中）。
我们甚至可以这么做：
``` go
package main

import (
    "fmt"
    "io"
    "os"
)

func main() {
    io.Copy(os.Stdout, os.Stdin)
    fmt.Println("Got EOF -- bye")
}
```

执行：\`echo "Hello, World" | go run main.go\`
\*\*CopyN 函数\*\*的签名：
``` go
func CopyN(dst Writer, src Reader, n int64) (written int64, err error)
```

函数文档：
``` go
> CopyN 将 n 个字节从 src 复制到 dst。 它返回复制的字节数以及在复制时遇到的最早的错误。由于 Read 可以返回要求的全部数量及一个错误（包括 EOF），因此 CopyN 也能如此。

> 若 dst 实现了 ReaderFrom 接口，复制操作也就会使用它来实现。
<span style="color:#FF0000;">注：只有当written＝n时，返回的err才为nil,否则都不为nil</span>
```

代码：
io.CopyN(os.Stdout, strings.NewReader("Go语言学习园地"), 8)
会输出：
Go语言

<span style="font-size:18px">
ReadAtLeast 和 ReadFull 函数 </span>
\*\*ReadAtLeast 函数\*\*的签名：

``` go
func ReadAtLeast(r Reader, buf []byte, min int) (n int, err error)
```

函数文档：
``` go
> ReadAtLeast 将 r 读取到 buf 中，直到读了最少 min 个字节为止。它返回复制的字节数，如果读取的字节较少，还会返回一个错误。若没有读取到字节，错误就只是 EOF。如果一个 EOF 发生在读取了少于 min 个字节之后，ReadAtLeast 就会返回 ErrUnexpectedEOF。若 min 大于 buf 的长度，ReadAtLeast 就会返回 ErrShortBuffer。对于返回值，当且仅当 err == nil 时，才有 n >= min。
```

一般可能不太会用到这个函数。使用时需要注意返回的error判断。
\*\*ReadFull 函数\*\*的签名：
``` go
func ReadFull(r Reader, buf []byte) (n int, err error)
```

函数文档：
``` go
> ReadFull 精确地从 r 中将 len(buf) 个字节读取到 buf 中。它返回复制的字节数，如果读取的字节较少，还会返回一个错误。若没有读取到字节，错误就只是 EOF。如果一个 EOF 发生在读取了一些但不是所有的字节后，ReadFull 就会返回 ErrUnexpectedEOF。对于返回值，当且仅当 err == nil 时，才有 n == len(buf)。
```

<span style="background-color:rgb(255,0,0)">
注意该函数和ReadAtLeast的区别：ReadFull 将buf读满；而ReadAtLeast是最少读取min个字节。</span>

WriteString 函数
这是为了方便写入string类型提供的函数，函数签名：
func WriteString(w Writer, s string) (n int, err error)
当 w 实现了 WriteString 方法时，直接调用该方法，否则执行w.Write(\[\]byte(s))。

 MultiReader 和 MultiWriter 函数
这两个函数的定义分别是：
func MultiReader(readers ...Reader) Reader
func MultiWriter(writers ...Writer) Writer
它们接收多个Reader或Writer，返回一个Reader或Writer。我们可以猜想到这两个函数就是操作多个Reader或Writer就像操作一个。
事实上，在io包中定义了两个非导出类型：mutilReader和multiWriter，它们分别实现了io.Reader和io.Writer接口。类型定义为：

``` go
type multiReader struct {
    readers []Reader
}

type multiWriter struct {
    writers []Writer
}
```

对于这两种类型对应的实现方法（Read和Write方法）的使用，我们通过例子来演示。
\*\*MultiReader的使用\*\*：
``` go
package main

import (
    "bytes"
    "fmt"
    "io"
    "strings"
)

func main() {

    readers := []io.Reader{
        strings.NewReader("from strings reader"),
        bytes.NewBufferString("from bytes buffer"),
    }
    reader := io.MultiReader(readers...)
    data := make([]byte, 0, 1024)
    var (
        err error
        n   int
    )
    for err != io.EOF {
        tmp := make([]byte, 512)
        n, err = reader.Read(tmp)
        if err == nil {
            data = append(data, tmp[:n]...)
        } else {
            if err != io.EOF {
                panic(err)
            }
        }
    }
    fmt.Printf("%s\n", data)
}

运行结果：
from strings readerfrom bytes buffer
```

代码中首先构造了一个io.Reader的slice，由 strings.Reader 和 bytes.Buffer 两个实例组成，然后通过MultiReader得到新的Reader，循环读取新Reader中的内容。从输出结果可以看到，<span style="color:#FF0000">第一次调用Reader的Read方法获取到的是slice中第一个元素的内容……也就是说，MultiReader只是逻辑上将多个Reader组合起来，并不能通过调用一次Read方法获取所有Reader的内容。在所有的Reader内容都被读完后，Reader会返回EOF。</span>
\*\*MultiWriter的使用\*\*：
``` go
package main

import (
    "io"
    "os"
)

func main() {

    file, err := os.Create("tmp.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()
    writers := []io.Writer{
        os.Stdout,
        file,
    }
    writer := io.MultiWriter(writers...)
    writer.Write([]byte("hello,world"))
}
```

这段程序执行后在生成tmp.txt文件，同时在文件和屏幕中都输出：hello world。
 TeeReader函数
函数签名如下：
func TeeReader(r Reader, w Writer) Reader
TeeReader 返回一个 Reader，它将从 r 中读到的数据写入 w 中。所有经由它处理的从 r 的读取都匹配于对应的对 w 的写入。它没有内部缓存，即写入必须在读取完成前完成。任何在写入时遇到的错误都将作为读取错误返回。
也就是说，我们通过Reader读取内容后，会自动写入到Writer中去。例子代码如下：
``` go
package main

import (
    "fmt"
    "io"
    "os"
    "strings"
)

func main() {
    reader := io.TeeReader(strings.NewReader("Go语言学习园地"), os.Stdout)
    p := make([]byte, 20)
    n, err := reader.Read(p)
    fmt.Println(string(p), n, err)
}
```

输出结果：
 Go语言学习园地Go语言学习园地 20 &lt;nil&gt;
这种功能的实现其实挺简单，无非是在Read完后执行Write。
至此，io所有接口、类型和函数都讲解完成。
