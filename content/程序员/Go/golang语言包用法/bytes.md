---
title: golang中bytes包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中bytes包用法](/chenbaoke/article/details/40317553)

本文转自　Golove的博客http://www.cnblogs.com/golove/p/3287729.html

bytes 包中的函数和方法
// bytes 包实现了用于操作 \[\]byte 的函数，类似于 strings 包中的函数
// bytes.go
------------------------------------------------------------
// Compare 用于比较两个 \[\]byte，并返回 int 型结果
// a == b 返回 0
// a &lt; b 返回 -1
// a &gt; b 返回 1
// 如果参数为 nil 则相当于传入一个空 \[\]byte
func Compare(a, b \[\]byte) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Count 计算 sep 在 s 中的非重叠个数
// 如果 sep 为空，则返回 s 中的字符个数 + 1
func Count(s, sep \[\]byte) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Contains 判断 b 中是否包含 subslice
// 如果 subslice 为空，则返回 true
func Contains(b, subslice \[\]byte) bool
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Index 返回 sep 在 s 中第一次出现的位置
// 如果找不到，则返回 -1，如果 sep 为空，则返回 0
func Index(s, sep \[\]byte) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// LastIndex 返回 sep 在 s 中最后一次出现的字节位置
// 如果找不到，则返回 -1，如果 sep 为空，则返回 s 的长度
func LastIndex(s, sep \[\]byte) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// IndexRune 返回 r 的编码在 s 中第一次出现的位置
// 如果找不到，则返回 -1
func IndexRune(s \[\]byte, r rune) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// IndexAny 返回 chars 中的任何一个字符在 s 中第一次出现的位置
// 如果找不到，则返回 -1，如果 chars 为空，则返回 -1
func IndexAny(s \[\]byte, chars string) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// LastIndexAny 返回 chars 中的任何一个字符在 s 中最后一次出现的位置
// 如果找不到，则返回 -1，如果 chars 为空，也返回 -1
func LastIndexAny(s \[\]byte, chars string) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// SplitN 以 sep 为分隔符，将 s 切分成多个子串，结果中不包含 sep 本身
// 如果 sep 为空，则将 s 切分成 Unicode 字符列表
// 如果 s 中没有 sep，则将整个 s 作为 \[\]\[\]byte 的第一个元素返回
// 参数 n 表示最多切分出几个子串，超出的部分将不再切分
// 如果 n 为 0，则返回 nil，如果 n 小于 0，则不限制切分个数，全部切分
func SplitN(s, sep \[\]byte, n int) \[\]\[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// SplitAfterN 和 SplitN 的功能一样，只不过结果中包含 sep
func SplitAfterN(s, sep \[\]byte, n int) \[\]\[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Split 以 sep 为分隔符，将 s 切分成多个子串，结果中不包含 sep 本身
// 如果 sep 为空，则将 s 切分成 Unicode 字符列表。
// 如果 s 中没有 sep 子串，则将整个 s 作为 \[\]string 的第一个元素返回
func Split(s, sep \[\]byte) \[\]\[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// SplitAfter 和 Split 的功能一样，只不过结果中包含 sep
func SplitAfter(s, sep \[\]byte) \[\]\[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Fields 以连续的空白字符为分隔符，将 s 切分成多个子串，结果中不包含空白字符本身
// 空白字符有：\\t, \\n, \\v, \\f, \\r, ' ', U+0085 (NEL), U+00A0 (NBSP)
// 如果 s 中只包含空白字符，则返回一个空列表
func Fields(s \[\]byte) \[\]\[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// FieldsFunc 以一个或多个连续的满足 f(rune) 的字符为分隔符，
// 将 s 切分成多个子串，结果中不包含分隔符本身
// 如果 s 中没有满足 f(rune) 的字符，则返回一个空列表
func FieldsFunc(s \[\]byte, f func(rune) bool) \[\]\[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Join 将 s 中的子串连接成一个单独的 \[\]byte，子串之间用 sep 分隔
func Join(s \[\]\[\]byte, sep \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// HasPrefix 判断 s 是否以 prefix 开头
// 如果 prefix 为空，也返回 true
func HasPrefix(s, prefix \[\]byte) bool
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// HasPrefix 判断 s 是否以 prefix 结尾
// 如果 suffix 为空，也返回 true
func HasSuffix(s, suffix \[\]byte) bool
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Map 将 s 中满足 mapping(rune) 的字符替换为 mapping(rune) 的返回值
// 如果 mapping(rune) 返回负数，则相应的字符将被删除
func Map(mapping func(r rune) rune, s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Repeat 将 count 个 b 连接成一个新的 \[\]byte
func Repeat(b \[\]byte, count int) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// ToUpper 将 s 中的所有字符修改为其大写格式
// 对于非 ASCII 字符，它的大写格式需要查表转换
func ToUpper(s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// ToLower 将 s 中的所有字符修改为其小写格式
// 对于非 ASCII 字符，它的小写格式需要查表转换
func ToLower(s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// ToTitle 将 s 中的所有字符修改为其 Title 格式
// 大部分字符的 Title 格式就是其 Upper 格式
// 只有少数字符的 Title 格式是特殊字符
// 这里的 ToTitle 主要给 Title 函数调用
func ToTitle(s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// ToUpperSpecial 将 s 中的所有字符修改为其大写格式
// 优先使用 \_case 中的规则进行转换
func ToUpperSpecial(\_case unicode.SpecialCase, s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// ToLowerSpecial 将 s 中的所有字符修改为其小写格式
// 优先使用 \_case 中的规则进行转换
func ToLowerSpecial(\_case unicode.SpecialCase, s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// ToTitleSpecial 将 s 中的所有字符修改为其 Title 格式
// 优先使用 \_case 中的规则进行转换
func ToTitleSpecial(\_case unicode.SpecialCase, s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Title 将 s 中的所有单词的首字母修改为其 Title 格式
// BUG: Title 规则不能正确处理 Unicode 标点符号
func Title(s \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimLeftFunc 将删除 s 头部连续的满足 f(rune) 的字符
func TrimLeftFunc(s \[\]byte, f func(r rune) bool) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimRightFunc 将删除 s 尾部连续的满足 f(rune) 的字符
func TrimRightFunc(s \[\]byte, f func(r rune) bool) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimFunc 将删除 s 首尾连续的满足 f(rune) 的字符
func TrimFunc(s \[\]byte, f func(r rune) bool) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimPrefix 删除 s 头部的 prefix 字符串
// 如果 s 不是以 prefix 开头，则返回原始 s
func TrimPrefix(s, prefix \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimSuffix 删除 s 尾部的 suffix 字符串
// 如果 s 不是以 suffix 结尾，则返回原始 s
func TrimSuffix(s, suffix \[\]byte) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// IndexFunc 返回 s 中第一个满足 f(rune) 的字符的字节位置
// 如果没有满足 f(rune) 的字符，则返回 -1
func IndexFunc(s \[\]byte, f func(r rune) bool) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// LastIndexFunc 返回 s 中最后一个满足 f(rune) 的字符的字节位置
// 如果没有满足 f(rune) 的字符，则返回 -1
func LastIndexFunc(s \[\]byte, f func(r rune) bool) int
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Trim 将删除 s 首尾连续的包含在 cutset 中的字符
func Trim(s \[\]byte, cutset string) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimLeft 将删除 s 头部连续的包含在 cutset 中的字符
func TrimLeft(s \[\]byte, cutset string) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimRight 将删除 s 尾部连续的包含在 cutset 中的字符
func TrimRight(s \[\]byte, cutset string) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// TrimSpace 将删除 s 首尾连续的的空白字符
func TrimSpace(s \[\]byte) \[\]byte
------------------------------------------------------------
// Runes 将 s 切分为 Unicode 码点列表
func Runes(s \[\]byte) \[\]rune
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// Replace 将 s 中的 old 子串替换为 new 子串并返回
// 替换次数为 n 次，如果 n 为 -1，则全部替换
// 如果 old 为空，则在每个字符之间都插入一个 new
func Replace(s, old, new \[\]byte, n int) \[\]byte
------------------------------------------------------------
// 功能类似于 strings 包中的同名函数
// EqualFold 判断 s 和 t 是否相等。忽略大小写，同时它还会对特殊字符进行转换
// 比如将“ϕ”转换为“Φ”、将“Ǆ”转换为“ǅ”等，然后再进行比较
func EqualFold(s, t \[\]byte) bool
============================================================
// bytes\_decl.go
------------------------------------------------------------
// IndexByte 返回 c 在 s 中第一次出现的位置
// 如果找不到，则返回 -1
func IndexByte(s \[\]byte, c byte) int
------------------------------------------------------------
// Equal 判断 a 和 b 是否相等
// 如果参数为 nil，则被视为空 \[\]byte
func Equal(a, b \[\]byte) bool
============================================================
// reader.go
------------------------------------------------------------
type Reader struct {
// 私有字段
}
// 通过 \[\]byte 创建一个 bytes.Reader 对象
func NewReader(b \[\]byte) \*Reader
------------------------------------------------------------
// 返回 r 中未读取的数据的长度
func (r \*Reader) Len() int
------------------------------------------------------------
// 实现 io.Reader 接口
func (r \*Reader) Read(b \[\]byte) (n int, err error)
------------------------------------------------------------
// 实现 io.ReaderAt 接口
func (r \*Reader) ReadAt(b \[\]byte, off int64) (n int, err error)
------------------------------------------------------------
// 实现 io.ByteScanner 接口
func (r \*Reader) ReadByte() (b byte, err error)
func (r \*Reader) UnreadByte() error
------------------------------------------------------------
// 实现 io.RuneScanner 接口
func (r \*Reader) ReadRune() (ch rune, size int, err error)
func (r \*Reader) UnreadRune() error
------------------------------------------------------------
// 实现 io.Seeker 接口
func (r \*Reader) Seek(offset int64, whence int) (int64, error)
------------------------------------------------------------
// 实现 io.WriterTo 接口
func (r \*Reader) WriteTo(w io.Writer) (n int64, err error)
============================================================
// buffer.go
------------------------------------------------------------
// Buffer 实现了带缓存的输入输出操作
// 缓存的容量会根据需要自动扩展
// 如果缓存太大，无法继续扩展，则会引发 panic(ErrTooLarge)
type Buffer struct {
// 私有字段
}
// 通过 \[\]byte 或 string 创建 bytes.Buffer 对象
func NewBuffer(buf \[\]byte) \*Buffer
func NewBufferString(s string) \*Buffer
------------------------------------------------------------
// 返回 b 中数据的切片
func (b \*Buffer) Bytes() \[\]byte
------------------------------------------------------------
// 返回 b 中取数据的副本
func (b \*Buffer) String() string
------------------------------------------------------------
// 返回 b 中数据的长度
func (b \*Buffer) Len() int
------------------------------------------------------------
// Truncate 将缓冲区中的数据截短为前 n 字节，截掉的部分将被丢弃
// 如果 n 是负数或 n 超出了缓冲区总长度，则会引发 panic
func (b \*Buffer) Truncate(n int)
------------------------------------------------------------
// Reset 方法用于重置缓存，即清空缓存中的数据
// b.Reset() 相当于 b.Truncate(0)。
func (b \*Buffer) Reset()
------------------------------------------------------------
// Grow 将缓存长度向后扩展 n 个字节，不返回任何数据。
// 如果 n 是复数，将引发 panic，如果无法扩展缓存长度，则会引发 panic(ErrTooLarge)
func (b \*Buffer) Grow(n int)
------------------------------------------------------------
// 实现了 io.Writer 接口
func (b \*Buffer) Write(p \[\]byte) (n int, err error)
------------------------------------------------------------
// 功能同 Write，只不过参数为字符串类型
func (b \*Buffer) WriteString(s string) (n int, err error)
------------------------------------------------------------
// 实现 io.ReaderFrom 接口
func (b \*Buffer) ReadFrom(r io.Reader) (n int64, err error)
------------------------------------------------------------
// 实现了 io.WriterTo 接口
func (b \*Buffer) WriteTo(w io.Writer) (n int64, err error)
------------------------------------------------------------
// 实现了 io.ByteWriter 接口
func (b \*Buffer) WriteByte(c byte) error
------------------------------------------------------------
// WriteRune 将一个字符 r 写入到对象的数据流中
// 返回写入过程中遇到的任何错误
func (b \*Buffer) WriteRune(r rune) (n int, err error)
------------------------------------------------------------
// 实现了 io.Reader 接口
func (b \*Buffer) Read(p \[\]byte) (n int, err error)
------------------------------------------------------------
// Next 读出缓存中前 n 个字节的数据，并返回其引用
// 如果 n 大于缓存中数据的长度，则读出所有数据
// 被读出的数据在下一次读写操作之前是有效的
// 下一次读写操作时，所引用的数据可能会被覆盖
func (b \*Buffer) Next(n int) \[\]byte
------------------------------------------------------------
// 实现 io.ByteScanner 接口
func (b \*Buffer) ReadByte() (c byte, err error)
func (b \*Buffer) UnreadByte() error
------------------------------------------------------------
// 实现 io.RuneScanner 接口
func (b \*Buffer) ReadRune() (r rune, size int, err error)
func (b \*Buffer) UnreadRune() error
------------------------------------------------------------
// 类似于 bufio 包中的 Reader.ReadBytes 和 Reader.ReadString 方法
// ReadBytes 在 b 中查找 delim 并读出 delim 及其之前的所有数据
// ReadString 功能同 ReadBytes，只不过返回的是一个字符串
func (b \*Buffer) ReadBytes(delim byte) (line \[\]byte, err error)
func (b \*Buffer) ReadString(delim byte) (line string, err error)
