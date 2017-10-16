---
title: golang 中regexp包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
[golang 中regexp包用法](/chenbaoke/article/details/40318287)
本文转自Golove博客：http://www.cnblogs.com/golove/p/3270918.html
```
regexp 包中的函数和方法
// regexp.go
------------------------------------------------------------
// 判断在 b 中能否找到正则表达式 pattern 所匹配的子串
// pattern：要查找的正则表达式
// b：要在其中进行查找的 \[\]byte
// matched：返回是否找到匹配项
// err：返回查找过程中遇到的任何错误
// 此函数通过调用 Regexp 的方法实现
func Match(pattern string, b \[\]byte) (matched bool, err error)
func main() {
fmt.Println(regexp.Match("H.\* ", \[\]byte("Hello World!")))
// true
}
------------------------------------------------------------
// 判断在 r 中能否找到正则表达式 pattern 所匹配的子串
// pattern：要查找的正则表达式
// r：要在其中进行查找的 RuneReader 接口
// matched：返回是否找到匹配项
// err：返回查找过程中遇到的任何错误
// 此函数通过调用 Regexp 的方法实现
func MatchReader(pattern string, r io.RuneReader) (matched bool, err error)
func main() {
r := bytes.NewReader(\[\]byte("Hello World!"))
fmt.Println(regexp.MatchReader("H.\* ", r))
// true
}
------------------------------------------------------------
// 判断在 s 中能否找到正则表达式 pattern 所匹配的子串
// pattern：要查找的正则表达式
// r：要在其中进行查找的字符串
// matched：返回是否找到匹配项
// err：返回查找过程中遇到的任何错误
// 此函数通过调用 Regexp 的方法实现
func MatchString(pattern string, s string) (matched bool, err error)
func main() {
fmt.Println(regexp.Match("H.\* ", "Hello World!"))
// true
}
------------------------------------------------------------
// QuoteMeta 将字符串 s 中的“特殊字符”转换为其“转义格式”
// 例如，QuoteMeta（\`\[foo\]\`）返回\`\\\[foo\\\]\`。
// 特殊字符有：\\.+\*?()|\[\]{}^$
// 这些字符用于实现正则语法，所以当作普通字符使用时需要转换
func QuoteMeta(s string) string
func main() {
fmt.Println(regexp.QuoteMeta("(?P:Hello) \[a-z\]"))
// \\(\\?P:Hello\\) \\\[a-z\\\]
}
------------------------------------------------------------
// Regexp 结构表示一个编译后的正则表达式
// Regexp 的公开接口都是通过方法实现的
// 多个 goroutine 并发使用一个 RegExp 是安全的
type Regexp struct {
// 私有字段
}
// 通过 Complite、CompilePOSIX、MustCompile、MustCompilePOSIX
// 四个函数可以创建一个 Regexp 对象
------------------------------------------------------------
// Compile 用来解析正则表达式 expr 是否合法，如果合法，则返回一个 Regexp 对象
// Regexp 对象可以在任意文本上执行需要的操作
func Compile(expr string) (\*Regexp, error)
func main() {
reg, err := regexp.Compile(\`\\w+\`)
fmt.Printf("%q,%v\\n", reg.FindString("Hello World!"), err)
// "Hello",
}
------------------------------------------------------------
// CompilePOSIX 的作用和 Compile 一样
// 不同的是，CompilePOSIX 使用 POSIX 语法，
// 同时，它采用最左最长方式搜索，
// 而 Compile 采用最左最短方式搜索
// POSIX 语法不支持 Perl 的语法格式：\\d、\\D、\\s、\\S、\\w、\\W
func CompilePOSIX(expr string) (\*Regexp, error)
func main() {
reg, err := regexp.CompilePOSIX(\`\[\[:word:\]\]+\`)
fmt.Printf("%q,%v\\n", reg.FindString("Hello World!"), err)
// "Hello"
}
------------------------------------------------------------
// MustCompile 的作用和 Compile 一样
// 不同的是，当正则表达式 str 不合法时，MustCompile 会抛出异常
// 而 Compile 仅返回一个 error 值
func MustCompile(str string) \*Regexp
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindString("Hello World!"))
// Hello
}
------------------------------------------------------------
// MustCompilePOSIX 的作用和 CompilePOSIX 一样
// 不同的是，当正则表达式 str 不合法时，MustCompilePOSIX 会抛出异常
// 而 CompilePOSIX 仅返回一个 error 值
func MustCompilePOSIX(str string) \*Regexp
func main() {
reg := regexp.MustCompilePOSIX(\`\[\[:word:\]\].+ \`)
fmt.Printf("%q\\n", reg.FindString("Hello World!"))
// "Hello "
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回第一个匹配的内容
func (re \*Regexp) Find(b \[\]byte) \[\]byte
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Printf("%q", reg.Find(\[\]byte("Hello World!")))
// "Hello"
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回第一个匹配的内容
func (re \*Regexp) FindString(s string) string
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindString("Hello World!"))
// "Hello"
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回所有匹配的内容
// {{匹配项}, {匹配项}, ...}
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAll(b \[\]byte, n int) \[\]\[\]byte
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Printf("%q", reg.FindAll(\[\]byte("Hello World!"), -1))
// \["Hello" "World"\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回所有匹配的内容
// {匹配项, 匹配项, ...}
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAllString(s string, n int) \[\]string
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Printf("%q", reg.FindAllString("Hello World!", -1))
// \["Hello" "World"\]
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回第一个匹配的位置
// {起始位置, 结束位置}
func (re \*Regexp) FindIndex(b \[\]byte) (loc \[\]int)
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindIndex(\[\]byte("Hello World!")))
// \[0 5\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回第一个匹配的位置
// {起始位置, 结束位置}
func (re \*Regexp) FindStringIndex(s string) (loc \[\]int)
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindStringIndex("Hello World!"))
// \[0 5\]
}
------------------------------------------------------------
// 在 r 中查找 re 中编译好的正则表达式，并返回第一个匹配的位置
// {起始位置, 结束位置}
func (re \*Regexp) FindReaderIndex(r io.RuneReader) (loc \[\]int)
func main() {
r := bytes.NewReader(\[\]byte("Hello World!"))
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindReaderIndex(r))
// \[0 5\]
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回所有匹配的位置
// {{起始位置, 结束位置}, {起始位置, 结束位置}, ...}
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAllIndex(b \[\]byte, n int) \[\]\[\]int
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindAllIndex(\[\]byte("Hello World!"), -1))
// \[\[0 5\] \[6 11\]\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回所有匹配的位置
// {{起始位置, 结束位置}, {起始位置, 结束位置}, ...}
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAllStringIndex(s string, n int) \[\]\[\]int
func main() {
reg := regexp.MustCompile(\`\\w+\`)
fmt.Println(reg.FindAllStringIndex("Hello World!", -1))
// \[\[0 5\] \[6 11\]\]
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回第一个匹配的内容
// 同时返回子表达式匹配的内容
// {{完整匹配项}, {子匹配项}, {子匹配项}, ...}
func (re \*Regexp) FindSubmatch(b \[\]byte) \[\]\[\]byte
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Printf("%q", reg.FindSubmatch(\[\]byte("Hello World!")))
// \["Hello" "H" "o"\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回第一个匹配的内容
// 同时返回子表达式匹配的内容
// {完整匹配项, 子匹配项, 子匹配项, ...}
func (re \*Regexp) FindStringSubmatch(s string) \[\]string
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Printf("%q", reg.FindStringSubmatch("Hello World!"))
// \["Hello" "H" "o"\]
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回所有匹配的内容
// 同时返回子表达式匹配的内容
// {
// {{完整匹配项}, {子匹配项}, {子匹配项}, ...},
// {{完整匹配项}, {子匹配项}, {子匹配项}, ...},
// ...
// }
func (re \*Regexp) FindAllSubmatch(b \[\]byte, n int) \[\]\[\]\[\]byte
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Printf("%q", reg.FindAllSubmatch(\[\]byte("Hello World!"), -1))
// \[\["Hello" "H" "o"\] \["World" "W" "d"\]\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回所有匹配的内容
// 同时返回子表达式匹配的内容
// {
// {完整匹配项, 子匹配项, 子匹配项, ...},
// {完整匹配项, 子匹配项, 子匹配项, ...},
// ...
// }
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAllStringSubmatch(s string, n int) \[\]\[\]string
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Printf("%q", reg.FindAllStringSubmatch("Hello World!", -1))
// \[\["Hello" "H" "o"\] \["World" "W" "d"\]\]
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回第一个匹配的位置
// 同时返回子表达式匹配的位置
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...}
func (re \*Regexp) FindSubmatchIndex(b \[\]byte) \[\]int
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Println(reg.FindSubmatchIndex(\[\]byte("Hello World!")))
// \[0 5 0 1 4 5\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回第一个匹配的位置
// 同时返回子表达式匹配的位置
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...}
func (re \*Regexp) FindStringSubmatchIndex(s string) \[\]int
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Println(reg.FindStringSubmatchIndex("Hello World!"))
// \[0 5 0 1 4 5\]
}
------------------------------------------------------------
// 在 r 中查找 re 中编译好的正则表达式，并返回第一个匹配的位置
// 同时返回子表达式匹配的位置
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...}
func (re \*Regexp) FindReaderSubmatchIndex(r io.RuneReader) \[\]int
func main() {
r := bytes.NewReader(\[\]byte("Hello World!"))
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Println(reg.FindReaderSubmatchIndex(r))
// \[0 5 0 1 4 5\]
}
------------------------------------------------------------
// 在 b 中查找 re 中编译好的正则表达式，并返回所有匹配的位置
// 同时返回子表达式匹配的位置
// {
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...},
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...},
// ...
// }
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAllSubmatchIndex(b \[\]byte, n int) \[\]\[\]int
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Println(reg.FindAllSubmatchIndex(\[\]byte("Hello World!"), -1))
// \[\[0 5 0 1 4 5\] \[6 11 6 7 10 11\]\]
}
------------------------------------------------------------
// 在 s 中查找 re 中编译好的正则表达式，并返回所有匹配的位置
// 同时返回子表达式匹配的位置
// {
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...},
// {完整项起始, 完整项结束, 子项起始, 子项结束, 子项起始, 子项结束, ...},
// ...
// }
// 只查找前 n 个匹配项，如果 n &lt; 0，则查找所有匹配项
func (re \*Regexp) FindAllStringSubmatchIndex(s string, n int) \[\]\[\]int
func main() {
reg := regexp.MustCompile(\`(\\w)(\\w)+\`)
fmt.Println(reg.FindAllStringSubmatchIndex("Hello World!", -1))
// \[\[0 5 0 1 4 5\] \[6 11 6 7 10 11\]\]
}
------------------------------------------------------------
// 将 template 的内容经过处理后，追加到 dst 的尾部。
// template 中要有 $1、$2、${name1}、${name2} 这样的“分组引用符”
// match 是由 FindSubmatchIndex 方法返回的结果，里面存放了各个分组的位置信息
// 如果 template 中有“分组引用符”，则以 match 为标准，
// 在 src 中取出相应的子串，替换掉 template 中的 $1、$2 等引用符号。
func (re \*Regexp) Expand(dst \[\]byte, template \[\]byte, src \[\]byte, match \[\]int) \[\]byte
func main() {
reg := regexp.MustCompile(\`(\\w+),(\\w+)\`)
src := \[\]byte("Golang,World!") // 源文本
dst := \[\]byte("Say: ") // 目标文本
template := \[\]byte("Hello $1, Hello $2") // 模板
match := reg.FindSubmatchIndex(src) // 解析源文本
// 填写模板，并将模板追加到目标文本中
fmt.Printf("%q", reg.Expand(dst, template, src, match))
// "Say: Hello Golang, Hello World"
}
------------------------------------------------------------
// 功能同 Expand 一样，只不过参数换成了 string 类型
func (re \*Regexp) ExpandString(dst \[\]byte, template string, src string, match \[\]int) \[\]byte
func main() {
reg := regexp.MustCompile(\`(\\w+),(\\w+)\`)
src := "Golang,World!" // 源文本
dst := \[\]byte("Say: ") // 目标文本（可写）
template := "Hello $1, Hello $2" // 模板
match := reg.FindStringSubmatchIndex(src) // 解析源文本
// 填写模板，并将模板追加到目标文本中
fmt.Printf("%q", reg.ExpandString(dst, template, src, match))
// "Say: Hello Golang, Hello World"
}
------------------------------------------------------------
// LiteralPrefix 返回所有匹配项都共同拥有的前缀（去除可变元素）
// prefix：共同拥有的前缀
// complete：如果 prefix 就是正则表达式本身，则返回 true，否则返回 false
func (re \*Regexp) LiteralPrefix() (prefix string, complete bool)
func main() {
reg := regexp.MustCompile(\`Hello\[\\w\\s\]+\`)
fmt.Println(reg.LiteralPrefix())
// Hello false
reg = regexp.MustCompile(\`Hello\`)
fmt.Println(reg.LiteralPrefix())
// Hello true
}
------------------------------------------------------------
// 切换到“贪婪模式”
func (re \*Regexp) Longest()
func main() {
text := \`Hello World, 123 Go!\`
pattern := \`(?U)H\[\\w\\s\]+o\` // 正则标记“非贪婪模式”(?U)
reg := regexp.MustCompile(pattern)
fmt.Printf("%q\\n", reg.FindString(text))
// Hello
reg.Longest() // 切换到“贪婪模式”
fmt.Printf("%q\\n", reg.FindString(text))
// Hello Wo
}
------------------------------------------------------------
// 判断在 b 中能否找到匹配项
func (re \*Regexp) Match(b \[\]byte) bool
func main() {
b := \[\]byte(\`Hello World\`)
reg := regexp.MustCompile(\`Hello\\w+\`)
fmt.Println(reg.Match(b))
// false
reg = regexp.MustCompile(\`Hello\[\\w\\s\]+\`)
fmt.Println(reg.Match(b))
// true
}
------------------------------------------------------------
// 判断在 r 中能否找到匹配项
func (re \*Regexp) MatchReader(r io.RuneReader) bool
func main() {
r := bytes.NewReader(\[\]byte(\`Hello World\`))
reg := regexp.MustCompile(\`Hello\\w+\`)
fmt.Println(reg.MatchReader(r))
// false
r.Seek(0, 0)
reg = regexp.MustCompile(\`Hello\[\\w\\s\]+\`)
fmt.Println(reg.MatchReader(r))
// true
}
------------------------------------------------------------
// 判断在 s 中能否找到匹配项
func (re \*Regexp) MatchString(s string) bool
func main() {
s := \`Hello World\`
reg := regexp.MustCompile(\`Hello\\w+\`)
fmt.Println(reg.MatchString(s))
// false
reg = regexp.MustCompile(\`Hello\[\\w\\s\]+\`)
fmt.Println(reg.MatchString(s))
// true
}
------------------------------------------------------------
// 统计正则表达式中的分组个数（不包括“非捕获的分组”）
func (re \*Regexp) NumSubexp() int
func main() {
reg := regexp.MustCompile(\`(?U)(?:Hello)(\\s+)(\\w+)\`)
fmt.Println(reg.NumSubexp())
// 2
}
------------------------------------------------------------
// 在 src 中搜索匹配项，并替换为 repl 指定的内容
// 全部替换，并返回替换后的结果
func (re \*Regexp) ReplaceAll(src, repl \[\]byte) \[\]byte
func main() {
b := \[\]byte("Hello World, 123 Go!")
reg := regexp.MustCompile(\`(Hell|G)o\`)
rep := \[\]byte("${1}ooo")
fmt.Printf("%q\\n", reg.ReplaceAll(b, rep))
// "Hellooo World, 123 Gooo!"
}
------------------------------------------------------------
// 在 src 中搜索匹配项，并替换为 repl 指定的内容
// 全部替换，并返回替换后的结果
func (re \*Regexp) ReplaceAllString(src, repl string) string
func main() {
s := "Hello World, 123 Go!"
reg := regexp.MustCompile(\`(Hell|G)o\`)
rep := "${1}ooo"
fmt.Printf("%q\\n", reg.ReplaceAllString(s, rep))
// "Hellooo World, 123 Gooo!"
}
------------------------------------------------------------
// 在 src 中搜索匹配项，并替换为 repl 指定的内容
// 如果 repl 中有“分组引用符”（$1、$name），则将“分组引用符”当普通字符处理
// 全部替换，并返回替换后的结果
func (re \*Regexp) ReplaceAllLiteral(src, repl \[\]byte) \[\]byte
func main() {
b := \[\]byte("Hello World, 123 Go!")
reg := regexp.MustCompile(\`(Hell|G)o\`)
rep := \[\]byte("${1}ooo")
fmt.Printf("%q\\n", reg.ReplaceAllLiteral(b, rep))
// "${1}ooo World, 123 ${1}ooo!"
}
------------------------------------------------------------
// 在 src 中搜索匹配项，并替换为 repl 指定的内容
// 如果 repl 中有“分组引用符”（$1、$name），则将“分组引用符”当普通字符处理
// 全部替换，并返回替换后的结果
func (re \*Regexp) ReplaceAllLiteralString(src, repl string) string
func main() {
s := "Hello World, 123 Go!"
reg := regexp.MustCompile(\`(Hell|G)o\`)
rep := "${1}ooo"
fmt.Printf("%q\\n", reg.ReplaceAllLiteralString(s, rep))
// "${1}ooo World, 123 ${1}ooo!"
}
------------------------------------------------------------
// 在 src 中搜索匹配项，然后将匹配的内容经过 repl 处理后，替换 src 中的匹配项
// 如果 repl 的返回值中有“分组引用符”（$1、$name），则将“分组引用符”当普通字符处理
// 全部替换，并返回替换后的结果
func (re \*Regexp) ReplaceAllFunc(src \[\]byte, repl func(\[\]byte) \[\]byte) \[\]byte
func main() {
s := \[\]byte("Hello World!")
reg := regexp.MustCompile("(H)ello")
rep := \[\]byte("$0$1")
fmt.Printf("%s\\n", reg.ReplaceAll(s, rep))
// HelloH World!
fmt.Printf("%s\\n", reg.ReplaceAllFunc(s,
func(b \[\]byte) \[\]byte {
rst := \[\]byte{}
rst = append(rst, b...)
rst = append(rst, "$1"...)
return rst
}))
// Hello$1 World!
}
k
------------------------------------------------------------
// 在 src 中搜索匹配项，然后将匹配的内容经过 repl 处理后，替换 src 中的匹配项
// 如果 repl 的返回值中有“分组引用符”（$1、$name），则将“分组引用符”当普通字符处理
// 全部替换，并返回替换后的结果
func (re \*Regexp) ReplaceAllStringFunc(src string, repl func(string) string) string
func main() {
s := "Hello World!"
reg := regexp.MustCompile("(H)ello")
rep := "$0$1"
fmt.Printf("%s\\n", reg.ReplaceAllString(s, rep))
// HelloH World!
fmt.Printf("%s\\n", reg.ReplaceAllStringFunc(s,
func(b string) string {
return b + "$1"
}))
// Hello$1 World!
}
------------------------------------------------------------
// 在 s 中搜索匹配项，并以匹配项为分割符，将 s 分割成多个子串
// 最多分割出 n 个子串，第 n 个子串不再进行分割
// 如果 n &lt; 0，则分割所有子串
// 返回分割后的子串列表
func (re \*Regexp) Split(s string, n int) \[\]string
func main() {
s := "Hello World\\tHello\\nGolang"
reg := regexp.MustCompile(\`\\s\`)
fmt.Printf("%q\\n", reg.Split(s, -1))
// \["Hello" "World" "Hello" "Golang"\]
}
------------------------------------------------------------
// 返回 re 中的“正则表达式”字符串
func (re \*Regexp) String() string
func main() {
re := regexp.MustCompile("Hello.\*$")
fmt.Printf("%s\\n", re.String())
// Hello.\*$
}
------------------------------------------------------------
// 返回 re 中的分组名称列表，未命名的分组返回空字符串
// 返回值\[0\] 为整个正则表达式的名称
// 返回值\[1\] 是分组 1 的名称
// 返回值\[2\] 是分组 2 的名称
// ……
func (re \*Regexp) SubexpNames() \[\]string
func main() {
re := regexp.MustCompile("(?PHello) (World)")
fmt.Printf("%q\\n", re.SubexpNames())
// \["" "Name1" ""\]
}
```
