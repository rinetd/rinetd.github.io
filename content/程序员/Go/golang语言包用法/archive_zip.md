---
title: golang中archive/zip包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang,glang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
[golang中archive/zip包用法](/chenbaoke/article/details/42782307)

archive/zip包提供了zip归档文件的读写操作。

在对zip包进行介绍之前，先说明一下zip和tar的区别。

二者都是对文件进行归档，不进行压缩。并且二者使用平台不同，对于 Windows 平台而言，最常用的格式是 zip 和 rar，国内大多数是用 rar，国外大多数是用 zip。而对于类 Unix 平台而言，常用的格式是 tar 和 tar.gz，zip 比较少一些，rar 则几乎没有。

zip 格式是开放且免费的，所以广泛使用在 Windows、Linux、MacOS 平台，要说 zip 有什么缺点的话，就是它的压缩率并不是很高，不如 rar及 tar.gz 等格式。

严格的说，tar 只是一种打包格式，并不对文件进行压缩，主要是为了便于文件的管理，所以打包后的文档大小一般远远大于 zip 和 tar.gz，但这种格式也有很明显的优点，例如打包速度非常快，打包时 CPU 占用率也很低，因为不需要压缩嘛。

接下来对zip包进行讲解。

zip包不支持跨硬盘进行操作为了向下兼容，FileHeader同时拥有32位和64位的Size字段。64位字段总是包含正确的值，对普通格式的档案未见它们的值是相同的。对zip64格式的档案文件32位字段将是0xffffffff，必须使用64位字段。
Constants

压缩算法

``` go
const (
        Store   uint16 = 0
        Deflate uint16 = 8
)
```

Variables

错误变量

``` go
var (
    ErrFormat    = errors.New("zip: not a valid zip file")
    ErrAlgorithm = errors.New("zip: unsupported compression algorithm")
    ErrChecksum  = errors.New("zip: checksum error")func_name
)
```

func RegisterCompressor(method uint16, comp Compressor) //使用指定的方法id生成一个Compressor的类型函数。常用的方法Store和Deflate是内建的
func RegisterDecompressor(method uint16, d Decompressor)//使用指定的方法id注册一个Decompressor类型的函数

type Compressor

    type Compressor func(io.Writer) (io.WriteCloser, error)

Compressor函数类型会返回一个io.WriteCloser，该接口会将数据压缩后写入提供的接口。关闭时，应将缓存中的数据写入下层接口中。

type Decompressor

    type Decompressor func(io.Reader) io.ReadCloser

Decompressor函数类型会把一个io.Reader包装成具有decompressing特性的io.Reader.Decompressor函数类型会返回一个io.ReadCloser，该接口的Read方法会将读取自提供的接口的数据提前解压缩。需要在读取结束时关闭该io.ReadCloser。

type File

``` go
type File struct {
    FileHeader
    // contains filtered or unexported fields
}
```

    func (f * File) DataOffset() (offset int64, err error) //DataOffset返回文件的可能存在的压缩数据相对于zip文件起始的偏移量。大多数调用者应使用Open代替，该方法会主动解压缩数据并验证校验和。

func (f \*File) Open() (rc io.ReadCloser, err error) //Open方法返回一个io.ReadCloser接口，提供读取文件内容的方法。可以同时读取多个文件。

type FileHeader

``` go
type FileHeader struct {
    Name string    // Name是文件名，它必须是相对路径， 不能以设备或斜杠开始，只接受'/'作为路径分隔符

    CreatorVersion     uint16
    ReaderVersion      uint16
    Flags              uint16
    Method             uint16
    ModifiedTime       uint16 // MS-DOS time
    ModifiedDate       uint16 // MS-DOS date
    CRC32              uint32
    CompressedSize     uint32 // deprecated; use CompressedSize64
    UncompressedSize   uint32 // deprecated; use UncompressedSize64
    CompressedSize64   uint64
    UncompressedSize64 uint64
    Extra              []byte
    ExternalAttrs      uint32 // Meaning depends on CreatorVersion
    Comment            string
}
```

func FileInfoHeader(fi os.FileInfo) (\*FileHeader, error)//FileInfoHeader返回一个根据fi填写了部分字段的Header。因为os.FileInfo接口的Name方法只返回它描述的文件的无路径名，有可能需要将返回值的Name字段修改为文件的完整路径名。
func (h \*FileHeader) FileInfo() os.FileInfo //FileInfo返回一个根据h的信息生成的os.FileInfo。
func (h \*FileHeader) ModTime() time.Time  //获取最后一次修改时间
func (h \*FileHeader) Mode() (mode os.FileMode)  //Mode返回h的权限和模式位。
func (h \*FileHeader) SetModTime(t time.Time)  //设置更改时间
func (h \*FileHeader) SetMode(mode os.FileMode) //设置mode

举例说明其用法

``` go
package main

import (
    "archive/zip"
    "fmt"
    "os"
    "time"
)

func main() {
    fileinfo, err := os.Stat("../1.txt")
    if err != nil {
        fmt.Println(err)
    }
    fileheader, err := zip.FileInfoHeader(fileinfo)
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(fileheader.ModTime()) //2015-09-22 15:55:02 +0000 UTC
    fileheader.SetModTime(time.Now().AddDate(1, 1, 1))
    fmt.Println(fileheader.ModTime()) //2016-12-11 06:57:48 +0000 UTC
}
```

type ReadCloser

``` go
type ReadCloser struct {
    Reader
    // contains filtered or unexported fields
}
```

func OpenReader(name string) (\*ReadCloser, error) //打开指定名为name的zip类型的文件，返回一个ReadCloser
func (rc \*ReadCloser) Close() error //关闭ReadCloser
type Reader

``` go
type Reader struct {
    File    []*File
    Comment string
    // contains filtered or unexported fields
}
```

func NewReader(r io.ReaderAt, size int64) (\*Reader, error) //NewReader返回一个从r读取数据的\*Reader，r被假设其大小为size字节。

type Writer  //实现zip文件的写入

``` go
type Writer struct {
            cw     *countWriter
            dir    []*header
            last   *fileWriter
            closed bool
        }
```

func NewWriter(w io.Writer) \*Writer  //NewWriter创建并返回一个将zip文件写入w的\*Writer
func (w \*Writer) Close() error   //关闭writer w
func (w \*Writer) Create(name string) (io.Writer, error)  //使用给出的文件名添加一个文件进zip文件。本方法返回一个io.Writer接口（用于写入新添加文件的内容）。文件名必须是相对路径，不能以设备或斜杠开始，只接受'/'作为路径分隔。新增文件的内容必须在下一次调用CreateHeader、Create或Close方法之前全部写入。
func (w \*Writer) CreateHeader(fh \*FileHeader) (io.Writer, error) //使用给出的\*FileHeader来作为文件的元数据添加一个文件进zip文件。本方法返回一个io.Writer接口（用于写入新添加文件的内容）。新增文件的内容必须在下一次调用CreateHeader、Create或Close方法之前全部写入。
func (w \*Writer) Flush() error  //将缓存中数据写入底层io，通常情况下调用flush是没有必要的，调用close是必要的。
func (w \*Writer) SetOffset(n int64)  //该函数用来设置将zip数据写入底层writer中的开始偏移量，其经常用于将zip文件追加到一个文件的后面，比如将一个数据写入一个二进制数据之后，该函数必须在数据写入之前进行调用。

举例说明zip的reader和writer用法。

``` go
package main

import (
    "archive/zip"
    "fmt"
    "io"
    "io/ioutil"
    "os"
    "time"
)

func main() {
    CompressZip()   //压缩
    DeCompressZip() //解压缩
}

func CompressZip() {
    const dir = "../img-50/"
    //获取源文件列表
    f, err := ioutil.ReadDir(dir)
    if err != nil {
        fmt.Println(err)
    }
    fzip, _ := os.Create("img-50.zip")
    w := zip.NewWriter(fzip)
    defer w.Close()
    for _, file := range f {
        fw, _ := w.Create(file.Name())
        filecontent, err := ioutil.ReadFile(dir + file.Name())
        if err != nil {
            fmt.Println(err)
        }
        n, err := fw.Write(filecontent)
        if err != nil {
            fmt.Println(err)
        }
        fmt.Println(n)
    }
}

func DeCompressZip() {
    const File = "img-50.zip"
    const dir = "img/"
    os.Mkdir(dir, 0777) //创建一个目录

    cf, err := zip.OpenReader(File) //读取zip文件
    if err != nil {
        fmt.Println(err)
    }
    defer cf.Close()
    for _, file := range cf.File {
        rc, err := file.Open()
        if err != nil {
            fmt.Println(err)
        }

        f, err := os.Create(dir + file.Name)
        if err != nil {
            fmt.Println(err)
        }
        defer f.Close()
        n, err := io.Copy(f, rc)
        if err != nil {
            fmt.Println(err)
        }
        fmt.Println(n)
    }

}
```

参考：<https://golang.org/pkg/archive/zip/>
