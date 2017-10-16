---
title: Linux命令 pandoc
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [pandoc]
---
[pandoc源码](https://github.com/jgm/pandoc.git)
[MMD语法参考](https://rawgit.com/fletcher/human-markdown-reference/master/index.html)
[官方参考文档](http://pandoc.org/MANUAL.html)
[Pandoc Markdown](http://rmarkdown.rstudio.com/authoring_pandoc_markdown.html)
[Pandoc中的Markdown语法](http://www.cnblogs.com/baiyangcao/p/pandoc_markdown.html)
#####################################
[](https://github.com/jgm/pandoc-templates.git)
[](https://github.com/jgm/pandocfilters.git)
[](https://github.com/kjhealy/pandoc-templates.git)
#linux_base

eval "$(pandoc --bash-completion)" #  

pandoc --list-extensions # 查看支持的Extension
pandoc --list-highlight-styles # 查看支持的语法高亮样式
pandoc --list-input-formats
pandoc --list-output-formats


`pandoc -t markdown_github+pipe_tables url -o file.md`                 #增加markdown +表格转换

`pandoc -t markdown+implicit_figures+link_attributes url -o file.md`   #增加图片解析 + 表格解析

`pandoc -t markdown-markdown_in_html_blocks url -o file.md`            #移除多余的html标识<div>等 +表格解析

`find ./posts -name '*.md' -exec pandoc {} -s -S --toc -o {}.html \;`  # markdown 转 html

`curl -s http://www.xker.com/page/e2012/0926/120758.html | iconv -f gb2312 -t utf-8 | pandoc -f html -o iptables常用规则.md -t markdown_github+auto_identifiers` #中文编码gb2312
`curl -s http://freeloda.blog.51cto.com/2033581/1241545 | iconv -f gbk -t utf-8 | pandoc -f html -o iptables详解及7层过滤.md -t markdown_github+auto_identifiers` #gbk编码
pandoc -f html -t markdown http://www.fsf.org
    -f参数用于指定源文件格式
    -t参数用于指定输出文件格式
    -o参数用于指定输出文件    
    -s, --standalone  #不输出header and footer 信息  
[](https://xuanwo.org/2015/11/14/pandoc/?utm_source=tuicool&utm_medium=referral)
docker run jagregory/pandoc
#参数 Markdown
http://www.bagualu.net/wordpress/archives/5284#pandoc-%E6%89%A9%E5%B1%95%E6%A0%87%E9%A2%98%E5%89%8D%E7%A9%BA%E8%A1%8C-blank_before_header
Markdown variants
-----------------
`Markdown` (pandoc's extended Markdown)
:   [footnotes],[tables], flexible [ordered lists], [definition lists], [fenced code blocks],
[superscripts and subscripts], [strikeout], [metadata blocks], automatic tables of
contents, embedded LaTeX [math], [citations], and [Markdown inside HTML block
elements][Extension: `markdown_in_html_blocks`]
`markdown_phpextra` (PHP Markdown Extra)
:   `footnotes`, `pipe_tables`, `raw_html`, `markdown_attribute`,
    `fenced_code_blocks`, `definition_lists`, `intraword_underscores`,
    `header_attributes`, `link_attributes`, `abbreviations`,
    `shortcut_reference_links`.
`markdown_github` (GitHub-Flavored Markdown)
:   `pipe_tables`, `raw_html`, `fenced_code_blocks`, `auto_identifiers`,
    `ascii_identifiers`, `backtick_code_blocks`, `autolink_bare_uris`,
    `intraword_underscores`, `strikeout`, `hard_line_breaks`, `emoji`,
    `shortcut_reference_links`, `angle_brackets_escapable`.
`markdown_mmd` (MultiMarkdown)
:   `pipe_tables`, `raw_html`, `markdown_attribute`, `mmd_link_attributes`,
    `tex_math_double_backslash`, `intraword_underscores`,
    `mmd_title_block`, `footnotes`, `definition_lists`,
    `all_symbols_escapable`, `implicit_header_references`,
    `auto_identifiers`, `mmd_header_identifiers`,
    `shortcut_reference_links`.
`markdown_strict` (Markdown.pl)
:   `raw_html`
## Extension:
### 段落
Extension: escaped_line_breaks
### Definition lists 列表
  Extension: definition_lists
    Term 1
    :   Definition 1
  Extension: example_lists
### Tables 表格
Extension: table_captions
  Extension: simple_tables
  Extension: multiline_tables
  Extension: grid_tables
  Extension: pipe_tables
### Metadata blocks
Extension: pandoc_title_block
  % title
  % author(s) (separated by semicolons)
  % date
Extension: yaml_metadata_block
  title:  'This is the title: colon'
  author:
  - Author One
  - Author Two
  tags: [nothing, nothingness]
  abstract: |
    This is the abstract.
### Backslash escapes 特殊字符
Extension: all_symbols_escapable
  ```
  Markdown provides backslash escapes for the following characters:
  \   backslash
  `   backtick
  *   asterisk
  _   underscore
  {}  curly braces
  []  square brackets
  ()  parentheses
  #   hash mark
  +   plus sign
  -   minus sign (hyphen)
  .   dot
  !   exclamation mark
  ```
### Emphasis 强调<strong>
  **strong emphasis** and __with underscores__
Extension: intraword_underscores 斜体<em>
 _用_ *替换*
Extension: strikeout 删除线
 ~~删除线~~
Extension: superscript, subscript 上标 下标
`2^10`  `2^10,1^`
`H~2~O` `H~2n`
Verbatim
## html 嵌入html 元素
Extension: raw_html
  Extension: `markdown_in_html_blocks`
  Extension: native_divs
  Extension: native_spans
## Images 图像
  1.Extension: implicit_figures # 添加图片解析 ![]()
  2.Extension: link_attributes #添加图像属性(若转换失败添加此项)
  ![](file.jpg){ width=50% }
## Spans
Extension: bracketed_spans
## Footnotes 脚注
Extension: footnotes
  Here is a footnote reference,[^1] and another.[^longnote]
  [^1]: Here is the footnote.
  [^longnote]: Here's one with multiple blocks.
Extension: inline_notes
  Here is an inline note.^[Inlines notes]
## Citations 引用
Extension: citations
### 未启用插件
Extension: angle_brackets_escapable
            all_symbols_escapable
Extension: lists_without_preceding_blankline
Extension: hard_line_breaks
Extension: ignore_line_breaks
Extension: east_asian_line_breaks
Extension: emoji
Extension: tex_math_single_backslash
Extension: tex_math_double_backslash
Extension: markdown_attribute
Extension: mmd_title_block
Extension: abbreviations
Extension: autolink_bare_uris
Extension: ascii_identifiers
Extension: mmd_link_attributes
Extension: mmd_header_identifiers
Extension: compact_definition_lists
################################################################################
HTML [](http://www.cnblogs.com/xuxinkun/p/5368809.html)
====

写成HTML，也就是网页形式是最普遍的。有很多工具可以直接生成HTML。常用的工具比如[python-Markdown](https://pythonhosted.org/Markdown/),[pandoc](http://pandoc.org/)。

这里比较推荐的是pandoc。其支持众多的格式转化，如下图：

![pandoc](http://pandoc.org/diagram.jpg)

使用pandoc可以轻松的生成HTML，pdf等等诸多格式，还可以制作ppt(下文将详述)。pandoc支持多个平台，包括windows。下载安装即可，环境搭建极其简单。

制作HTML
--------

下面，我们可以使用一条命令就能够生成HTML。

    pandoc.exe -t html -s .\xxx.markdown -o .\xxx.html

该命令含义为将`xxx.markdown`文件转化为html，并输出到`xxx.html`中。

打开`xxx.html`可以看到markdown已经被对应转化为了HTML。比如一级标题被转为`<h1></h1>`，代码被转为`<code></code>`。

但是这样的HTML虽然可读性很强，但是不够美观。因此我们需要给他加上一些样式。pandoc提供了一个[样例样式](http://pandoc.org/demo/pandoc.css)。在生成html时将CSS样式引入，即可。这里看一个[样例](http://pandoc.org/demos.html)。

    pandoc -s -S --toc -c pandoc.css -A footer.html README -o example3.html

这里说明一下`--toc`是让pandoc为该文档自动生成目录索引。`-c`即引入pandoc.css作为生成页面的css。最后生成出来的[页面](http://pandoc.org/demo/example3.html)效果就会美观很多。当然也可以使用自己定义CSS样式。

制作PPT
-------

使用[reveal.js](https://github.com/hakimel/reveal.js)做ppt，炫酷的3D切换效果绝对惊艳。不信可以看看[在线demo](http://lab.hakim.se/reveal-js/)。reveal.js本身支持使用markdown编写ppt内容。但是你需要修改在一个HTML中嵌入markdown语句，无论是易读和维护性上，都不如直接使用markdown的纯文本来的直观。如果使用pandoc，则可以将markdown的纯文本转换为reveal.js的PPT页面。你只需要执行下面的语句：

    git clone https://github.com/hakimel/reveal.js.git
    pandoc.exe -t revealjs -s xxx.md -V theme=sky -V transition=convex -o .\xxx.html

`-V theme=sky`可以指定使用reveal.js的样式，`-V transition=convex`可以指定其切换效果。最后生成的效果可以参看[这里](http://pandoc.org/demo/example16d.html)。



# Pandoc Docker container with XeLaTeX
[![License][license]][license_link]
[![Docker Stars][docker_starts]][docker_repo]
[![Docker Pulls][docker_pulls]][docker_repo]
Provides a Docker container with [`Pandoc`](http://pandoc.org/) and [`LaTeX`](https://www.latex-project.org) installed.
```
$ docker run --rm -v `pwd`:/data jpbernius/pandoc
```
```
pandoc [OPTIONS] [FILES]
Input formats:  commonmark, docbook, docx, epub, haddock, html, json*, latex,
               markdown, markdown_github, markdown_mmd, markdown_phpextra,
               markdown_strict, mediawiki, native, odt, opml, org, rst, t2t,
               textile, twiki
               [ *only Pandoc's JSON version of native AST]
Output formats: asciidoc, beamer, commonmark, context, docbook, docx, dokuwiki,
               dzslides, epub, epub3, fb2, haddock, html, html5, icml, json*,
               latex, man, markdown, markdown_github, markdown_mmd,
               markdown_phpextra, markdown_strict, mediawiki, native, odt,
               opendocument, opml, org, pdf**, plain, revealjs, rst, rtf, s5,
               slideous, slidy, tei, texinfo, textile
               [**for pdf output, use latex or beamer and -o FILENAME.pdf]
```
---
## Example
Generate HTML from Markdown
```
$ docker run --rm -v `pwd`:/data jpbernius/pandoc -o example.html example.md
```
---
Generate PDF from Markdown
```
$ docker run --rm -v `pwd`:/data jpbernius/pandoc -o example.html example.md
```
---
## Packages
| LaTeX                         | Pandoc                     |
| ----------------------------- | -------------------------- |
| `lmodern`                     | `pandoc`                   |
| `texlive-latex-base`          | `pandoc-citeproc`          |
| `texlive-fonts-recommended`   | `pandoc-citeproc-preamble` |
| `texlive-generic-recommended` | `pandoc-crossref`          |
| `texlive-lang-english`        |                            |
| `texlive-lang-german`         |                            |
| `latex-xcolor`                |                            |
| `texlive-math-extra`          |                            |
| `texlive-latex-extra`         |                            |
| `texlive-bibtex-extra`        |                            |
| `biber`                       |                            |
| `fontconfig`                  |                            |
| `texlive-xetex`               |                            |

[license]: https://img.shields.io/github/license/jpbernius/docker-pandoc.svg?maxAge=2592000
[license_link]: https://github.com/jpbernius/docker-pandoc/blob/master/LICENSE
[docker_repo]: https://hub.docker.com/r/jpbernius/pandoc/
[docker_starts]: https://img.shields.io/docker/stars/jpbernius/pandoc.svg
[docker_pulls]: https://img.shields.io/docker/pulls/jpbernius/pandoc.svg

2 .Pandoc的用法
2.1 Web版Pandoc
首先我们可以看下Pandoc的官网  http://johnmacfarlane.net/pandoc/
在介绍中我们知道Pandoc支持linux,Mac OS,Win多平台，还有简易的web版提供我们在线转换格式。打开web版  http://johnmacfarlane.net/pandoc/try ,便可以进行简单的格式转换了。不过网页版的反应速度不是很快，不适合大型文件的格式转换，一两篇文章还是可以的。
2.2 Linux版Pandoc
就我自己用的ubuntu下安装Pandoc,还算是非常简单的。以下是ubuntu下的使用步骤:
sudo apt-get install pandoc
如果apt-get安装的pandoc功能不齐全，可以如官网上一样先安装cable,再安装pandoc:
sudo apt-get install cabal-install
cabal update
cabal install pandoc
然后就可以尝试着用一下了：
pandoc demo.md -o demo.html
这样便可以简单的将demo的markdown文件转换成html文档了。另外还可以强制格式转换如下：
pandoc demo.txt -o demo.html -f markdown -t html
上面的代码便是将demo.txt中的文档以markdown的格式转换成html并存入demo.html中了。
最关键的  PDF文件  到了，PDF文档能在不同平台保持一致的表现，是许多文档传输的首选。在转换PDF之前,还需要安装一个texlive的包：
 sodu apt-get install texlive
然后便可以自如的转换PDF文件了：
pandoc demo.md -o demo.pdf
英文文件转换状况良好，中文字体问题请参考 Pandoc 用命令行转换标记语言
Markdown与Pandoc的用法也就说到这了，无疑它们搭配起来会让写作变得更加简单专注，这也就是我们的初衷。另外在写作中多结合Git,将文档推到GitHub上会是很好的尝试。
文本转换神器——Pandoc
介绍
Pandoc是一个用haskell编写的文本转换工具，小巧迅速且支持格式广泛，堪称文本转换应用的瑞士军刀。
支持格式
输入
    markdown
    reStructuredText
    textile
    HTML
    DocBook
    LaTeX
    MediaWiki markup
    TWiki markup
    OPML
    Emacs Org-Mode
    Txt2Tags
    Microsoft Word docx
    LibreOffice ODT
    EPUB
    Haddock markup
输出
    HTML格式: XHTML, HTML5, 和 HTML slide shows using
    Slidy,
    reveal.js,
    Slideous,
    S5, 或
    DZSlides.
    字处理格式: Microsoft Word
    docx,
    OpenOffice/LibreOffice
    ODT, OpenDocument
    XML
    电子书: EPUB version 2或3,
    FictionBook2
    文档格式: DocBook, GNU
    TexInfo, Groff
    man pages, Haddock
    markup
    页面布局格式: InDesign
    ICML
    大纲格式: OPML
    TeX 格式: LaTeX,
    ConTeXt, LaTeX Beamer slides
    PDF via
    LaTeX
    轻量级标记格式:
    Markdown (including
    CommonMark),
    reStructuredText,
    AsciiDoc, MediaWiki
    markup, DokuWiki
    markup, Emacs
    Org-Mode,
    Textile
    自定义格式: custom writers can be written in
    lua.
安装
安装Pandoc
在此页面上寻找对应平台的二进制安装包
Windows平台需要将Pandoc加入Path目录才能在cmd环境中调用
安装Tex支持（可选，用于编译Tex并输出PDF）
    Windows平台建议MiKTeX
    MacOS平台建议BasicTeX并使用tlmgr工具安装需要的包
    Linux平台建议Tex Live
使用
你可以使用在线的DEMO
pandoc x.html -o x.md
pandoc -f html -t markdown http://www.fsf.org
    -f参数用于指定源文件格式
    -t参数用于指定输出文件格式
    -o参数用于指定输出文件
如果不使用-f和-t参数，pandoc将会根据输入文件以及-o指定的输出文件格式来确定转换的格式类型
注意事项
    Pandoc不支持.doc格式，如果需要进行转换，则需要先将.doc转换为.docx
引用资源
    Pandoc官网 需要梯子
    Pandoc User Guide
    黑魔法利器pandoc
    Markdown写作进阶：Pandoc入门浅谈
Examples [原文](http://pandoc.org/demos.html)
========
To see the output created by each of the commands below, click on the
name of the output file:
1.  HTML fragment:
        pandoc MANUAL.txt -o example1.html
2.  Standalone HTML file:
        pandoc -s MANUAL.txt -o example2.html
3.  HTML with smart quotes, table of contents, CSS, and custom footer:
        pandoc -s -S --toc -c pandoc.css -A footer.html MANUAL.txt -o example3.html
4.  LaTeX:
        pandoc -s MANUAL.txt -o example4.tex
5.  From LaTeX to markdown:
        pandoc -s example4.tex -o example5.text
6.  reStructuredText:
        pandoc -s -t rst --toc MANUAL.txt -o example6.text
7.  Rich text format (RTF):
        pandoc -s MANUAL.txt -o example7.rtf
8.  Beamer slide show:
        pandoc -t beamer SLIDES -o example8.pdf
9.  DocBook XML:
        pandoc -s -S -t docbook MANUAL.txt -o example9.db
10. Man page:
        pandoc -s -t man pandoc.1.md -o example10.1
11. ConTeXt:
        pandoc -s -t context MANUAL.txt -o example11.tex
12. Converting a web page to markdown:
        pandoc -s -r html http://www.gnu.org/software/make/ -o example12.text
13. From markdown to PDF:
        pandoc MANUAL.txt --latex-engine=xelatex -o example13.pdf
14. PDF with numbered sections and a custom LaTeX header:
        pandoc -N --template=mytemplate.tex --variable mainfont="Palatino" --variable sansfont="Helvetica" --variable monofont="Menlo" --variable fontsize=12pt --variable version=1.17.2 MANUAL.txt --latex-engine=xelatex --toc -o example14.pdf
15. A wiki program using [Happstack](http://happstack.com) and pandoc:
    [gitit](http://gitit.net)
16. HTML slide shows:
        pandoc -s --mathml -i -t dzslides SLIDES -o example16a.html
        pandoc -s --webtex -i -t slidy SLIDES -o example16b.html
        pandoc -s --mathjax -i -t revealjs SLIDES -o example16d.html
17. TeX math in HTML:
        pandoc math.text -s -o mathDefault.html
        pandoc math.text -s --mathml -o mathMathML.html
        pandoc math.text -s --webtex -o mathWebTeX.html
        pandoc math.text -s --mathjax -o mathMathJax.html
        pandoc math.text -s --latexmathml -o mathLaTeXMathML.html
18. Syntax highlighting of delimited code blocks:
        pandoc code.text -s --highlight-style pygments -o example18a.html
        pandoc code.text -s --highlight-style kate -o example18b.html
        pandoc code.text -s --highlight-style monochrome -o example18c.html
        pandoc code.text -s --highlight-style espresso -o example18d.html
        pandoc code.text -s --highlight-style haddock -o example18e.html
        pandoc code.text -s --highlight-style tango -o example18f.html
        pandoc code.text -s --highlight-style zenburn -o example18g.html
19. GNU Texinfo, converted to info, HTML, and PDF formats:
        pandoc MANUAL.txt -s -o example19.texi
        makeinfo --no-validate --force example19.texi -o example19.info
        makeinfo --no-validate --force example19.texi --html -o example19
        texi2pdf example19.texi  # produces example19.pdf
20. OpenDocument XML:
        pandoc MANUAL.txt -s -t opendocument -o example20.xml
21. ODT (OpenDocument Text, readable by OpenOffice):
        pandoc MANUAL.txt -o example21.odt
22. MediaWiki markup:
        pandoc -s -S -t mediawiki --toc MANUAL.txt -o example22.wiki
23. EPUB ebook:
        pandoc -S MANUAL.txt -o MANUAL.epub
24. Markdown citations:
        pandoc -s -S --bibliography biblio.bib --filter pandoc-citeproc CITATIONS -o example24a.html
        pandoc -s -S --bibliography biblio.json --filter pandoc-citeproc --csl chicago-fullnote-bibliography.csl CITATIONS -o example24b.html
        pandoc -s -S --bibliography biblio.yaml --filter pandoc-citeproc --csl ieee.csl CITATIONS -t man -o example24c.1
25. Textile writer:
        pandoc -s -S MANUAL.txt -t textile -o example25.textile
26. Textile reader:
        pandoc -s -S example25.textile -f textile -t html -o example26.html
27. Org-mode:
        pandoc -s -S MANUAL.txt -o example27.org
28. AsciiDoc:
        pandoc -s -S MANUAL.txt -t asciidoc -o example28.txt
29. Word docx:
        pandoc -s -S MANUAL.txt -o example29.docx
30. LaTeX math to docx:
        pandoc -s math.tex -o example30.docx
31. DocBook to markdown:
        pandoc -f docbook -t markdown -s howto.xml -o example31.text
32. MediaWiki to html5:
        pandoc -f mediawiki -t html5 -s haskell.wiki -o example32.html
33. Custom writer:
        pandoc -t sample.lua example33.text -o example33.html
34. Docx with a reference docx:
        pandoc -S --reference-docx twocolumns.docx -o UsersGuide.docx MANUAL.txt
35. Docx to markdown, including math:
        pandoc -s example30.docx -t markdown -o example35.md
36. EPUB to plain text:
        pandoc MANUAL.epub -t plain -o example36.text
