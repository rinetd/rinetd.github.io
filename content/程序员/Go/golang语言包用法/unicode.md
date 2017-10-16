---
title: golang 中unicode包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang 中unicode包用法](/chenbaoke/article/details/40318215)
本文转自Golove博客：http://www.cnblogs.com/golove/p/3273585.html

unicode 包中的函数和方法
// latters.go
const (
MaxRune = '\\U0010FFFF' // Unicode 码点最大值
ReplacementChar = '\\uFFFD' // 代表无效的 Unicode 码点
MaxASCII = '\\u007F' // ASCII 码点最大值
MaxLatin1 = '\\u00FF' // Latin-1 码点最大值
)
------------------------------------------------------------
// 判断字符 r 是否在 rangtab 表范围内
func Is(rangeTab \*RangeTable, r rune) bool
func main() {
s := "Hello 世界！"
for \_, r := range s {
// 判断字符是否为汉字
if unicode.Is(unicode.Scripts\["Han"\], r) {
fmt.Printf("%c", r) // 世界
}
}
}
------------------------------------------------------------
// 判断字符 r 是否为大写格式
func IsUpper(r rune) bool
func main() {
s := "Hello ＡＢＣ！"
for \_, r := range s {
// 判断字符是否为大写
if unicode.IsUpper(r) {
fmt.Printf("%c", r) // HＡＢＣ
}
}
}
------------------------------------------------------------
// 判断字符 r 是否为小写格式
func IsLower(r rune) bool
func main() {
s := "Hello ａｂｃ！"
for \_, r := range s {
if unicode.IsLower(r) {
fmt.Printf("%c", r) // elloａｂｃ
}
}
}
------------------------------------------------------------
// 判断字符 r 是否为 Unicode 规定的 Title 字符
// 大部分字符的 Title 格式就是其大写格式
// 只有少数字符的 Title 格式是特殊字符
// 这里判断的就是特殊字符
func IsTitle(r rune) bool
func main() {
s := "Hello ᾏᾟᾯ！"
for \_, r := range s {
if unicode.IsTitle(r) {
fmt.Printf("%c", r) // ᾏᾟᾯ
}
}
}
// 输出 Unicode 规定的 Title 字符
func main() {
for \_, cr := range unicode.Lt.R16 {
for i := cr.Lo; i &lt;= cr.Hi; i += cr.Stride {
fmt.Printf("%c", i)
}
fmt.Println("")
}
}
------------------------------------------------------------
// To 将字符 r 转换为指定的格式
// \_case 取值：UpperCase、LowerCase、TitleCase
func To(\_case int, r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.To(unicode.UpperCase, r))
} // HELLO 世界！
for \_, r := range s {
fmt.Printf("%c", unicode.To(unicode.LowerCase, r))
} // hello 世界！
for \_, r := range s {
fmt.Printf("%c", unicode.To(unicode.TitleCase, r))
} // HELLO 世界！
}
------------------------------------------------------------
// ToUpper 将字符 r 转换为大写格式
func ToUpper(r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.ToUpper(r))
} // HELLO 世界！
}
------------------------------------------------------------
// ToLower 将字符 r 转换为小写格式
func ToLower(r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.ToLower(r))
} // hello 世界！
}
------------------------------------------------------------
// ToTitle 将字符 r 转换为 Title 格式
// 大部分字符的 Title 格式就是其大写格式
// 只有少数字符的 Title 格式是特殊字符
func ToTitle(r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.ToTitle(r))
} // HELLO 世界！
}
------------------------------------------------------------
// SpecialCase 是特定语言环境下的映射表，例如“土耳其”
// SpecialCase 的方法集定制了标准的映射
type SpecialCase \[\]CaseRange
------------------------------------------------------------
// ToUpper 将 r 转换为大写格式
// 优先使用指定的映射表 special
func (special SpecialCase) ToUpper(r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.SpecialCase(unicode.CaseRanges).ToUpper(r))
} // HELLO 世界！
}
------------------------------------------------------------
// ToLower 将 r 转换为小写格式
// 优先使用指定的映射表 special
func (special SpecialCase) ToLower(r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.SpecialCase(unicode.CaseRanges).ToLower(r))
} // hello 世界！
}
------------------------------------------------------------
// ToTitle 将 r 转换为 Title 格式
// 优先使用指定的映射表 special
func (special SpecialCase) ToTitle(r rune) rune
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c", unicode.SpecialCase(unicode.CaseRanges).ToTitle(r))
} // HELLO 世界！
}
------------------------------------------------------------
// SimpleFold 遍历 Unicode ，查找“下一个”与 r 相当的字符，
// “下一个”的意思是：码点值比 r 大且最靠近 r 的字符
// 如果没有“下一个”字符，则从头开始找与 r 相当的字符
// “相当”的意思是：同一个字符在不同情况下有不同的写法
// 这些不同写法的字符是相当的。
// 这个函数通过查询 caseOrbit 表实现
//
// 例如：
// SimpleFold('A') = 'a'
// SimpleFold('a') = 'A'
//
// SimpleFold('K') = 'k'
// SimpleFold('k') = '\\u212A' (开尔文符号：K)
// SimpleFold('\\u212A') = 'K'
//
// SimpleFold('1') = '1'
//
func SimpleFold(r rune) rune
func main() {
fmt.Printf("%c\\n", unicode.SimpleFold('Φ')) // φ
fmt.Printf("%c\\n", unicode.SimpleFold('φ')) // ϕ
fmt.Printf("%c\\n", unicode.SimpleFold('ϕ')) // Φ
}
============================================================
// digit.go
------------------------------------------------------------
// IsDigit 判断 r 是否为一个十进制的数字字符
func IsDigit(r rune) bool
func main() {
s := "Hello 123１２３！"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsDigit(r))
} // 123１２３ = true
}
============================================================
// graphic.go
------------------------------------------------------------
// IsGraphic 判断字符 r 是否为一个“图形字符”
// “图形字符”包括字母、标记、数字、标点、符号、空格
// 他们分别对应于 L、M、N、P、S、Zs 类别
// 这些类别是 RangeTable 类型，存储了相应类别的字符范围
func IsGraphic(r rune) bool
func main() {
s := "Hello　世界！\\t"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsGraphic(r))
} // \\t = false
}
------------------------------------------------------------
// IsPrint 判断字符 r 是否为 Go 所定义的“可打印字符”
// “可打印字符”包括字母、标记、数字、标点、符号和 ASCII 空格
// 他们分别对应于 L, M, N, P, S 类别和 ASCII 空格
// “可打印字符”和“图形字符”基本是相同的，不同之处在于
// “可打印字符”只包含 Zs 类别中的 ASCII 空格（U+0020）
func IsPrint(r rune) bool
func main() {
s := "Hello　世界！\\t"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsPrint(r))
} // 全角空格= false \\t = false
}
------------------------------------------------------------
// IsOneOf 判断 r 是否在 set 表范围内
func IsOneOf(set \[\]\*RangeTable, r rune) bool
func main() {
s := "Hello 世界！"
// set 表设置为“汉字、标点符号”
set := \[\]\*unicode.RangeTable{unicode.Han, unicode.P}
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsOneOf(set, r))
} // 世界！ = true
}
------------------------------------------------------------
// IsControl 判断 r 是否为一个控制字符
// Unicode 类别 C 包含更多字符，比如代理字符
// 使用 Is(C, r) 来测试它们
func IsControl(r rune) bool
func main() {
s := "Hello\\n\\t世界！"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsControl(r))
} // \\n\\t = true
}
------------------------------------------------------------
// IsLetter 判断 r 是否为一个字母字符 (类别 L)
// 汉字也是一个字母字符
func IsLetter(r rune) bool
func main() {
s := "Hello\\n\\t世界！"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsLetter(r))
} // Hello世界 = true
}
------------------------------------------------------------
// IsMark 判断 r 是否为一个 mark 字符 (类别 M)
func IsMark(r rune) bool
func main() {
s := "Hello ៉៊់៌៍！"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsMark(r))
} // ៉៊់៌៍ = true
}
// 输出所有 mark 字符
func main() {
for \_, cr := range unicode.M.R16 {
for i := uint16(cr.Lo); i &gt;= cr.Lo && i &lt;= cr.Hi; i += uint16(cr.Stride) {
fmt.Printf("%c = %v\\n", i, unicode.IsMark(rune(i)))
}
fmt.Println("")
}
}
------------------------------------------------------------
// IsNumber 判断 r 是否为一个数字字符 (类别 N)
func IsNumber(r rune) bool
func main() {
s := "Hello 123１２３！"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsNumber(r))
} // 123１２３ = true
}
------------------------------------------------------------
// IsPunct 判断 r 是否为一个标点字符 (类别 P)
func IsPunct(r rune) bool
func main() {
s := "Hello 世界！"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsPunct(r))
} // ！ = true
}
------------------------------------------------------------
// IsSpace 判断 r 是否为一个空白字符
// 在 Latin-1 字符集中，空白字符为：\\t, \\n, \\v, \\f, \\r,
// 空格, U+0085 (NEL), U+00A0 (NBSP)
// 其它空白字符的定义有“类别 Z”和“Pattern\_White\_Space 属性”
func IsSpace(r rune) bool
func main() {
s := "Hello \\t世　界！\\n"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsSpace(r))
} // 空格\\t全角空格\\n = true
}
------------------------------------------------------------
// IsSymbol 判断 r 是否为一个符号字符
func IsSymbol(r rune) bool
func main() {
s := "Hello (&lt;世=界&gt;)"
for \_, r := range s {
fmt.Printf("%c = %v\\n", r, unicode.IsSymbol(r))
} // &lt;=&gt; = true
}
