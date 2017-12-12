---
title: Linux命令 Nginx
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
[Server names](http://nginx.org/en/docs/http/server_names.html)
[nginx 的 server names - 简书](http://www.jianshu.com/p/1430e4046fd9)
目录：

    通配符主机名
    正则表达式主机名
    混杂主机名
    对主机名的优化
    兼容性

nginx 的 server names 由 server_name 指令定义，server name 是 nginx 用于选择以哪个 server 区块处理访问请求的依据参数。可参考 《nginx 是如何处理请求的》 的描述。

server name 可以用三种方式定义：

    定义准确的名字
    定义通配符名字
    定义正则表达式名字

例如：

server {
    listen       80;
    server_name  example.org  www.example.org;
    ...
}

server {
    listen       80;
    server_name  *.example.org;
    ...
}

server {
    listen       80;
    server_name  mail.*;
    ...
}

server {
    listen       80;
    server_name  ~^(?<user>.+)\.example\.net$;
    ...
}

当 nginx 以请求的 server name 查找匹配的虚拟主机时，如果匹配的 server 区块不止一个，nginx 按照如下的优先顺序选择 server 区块：

    准确的主机名
    以 “*” 起始的最长的通配主机名
    以 “*” 结尾的最长的通配主机名
    第一个匹配的正则表达式（按照配置文件中的顺序）

所以，如果同时有一个通配主机名和正则表达式主机名与访问请求的 server name 匹配，nginx 会选择通配主机名的 server 区块处理请求。
通配主机名

通配主机名只能在起始和末尾使用 “*” 字符，而且必须以 “.” 分隔。形如 “www.*.example.org” 或者 “w*.example.org” 的通配主机名是无效的。要达到这个匹配效果，只有使用正则表达式：

“www.*.example.org” ->     “~^www\..+\.example\.org$”
“w*.example.org”    ->     “~^w.*\.example\.org$”

“*” 号可以匹配多个名字区域，“*.example.org” 不仅可以匹配 www.example.org，也能够匹配 www.sub.example.org。
正则表达式主机名

nginx 使用的正则表达式与 Perl 语言的正则表达式（PCRE）兼容。使用正则表达式主机名，server name 必须以 “~” 字符为起始字符。

server_name  ~^www\d+\.example\.net$;

如果不以 “~” 字符为起始字符，该 server name 将被视为 “准确的主机名” 或者当 server name 包含 “*” 时被视为 “通配主机名” (多数情况是非法通配主机名，因为只有当 “*” 在 server name 的起始或结尾时才合法)。

不要忘记设置 “^” 和 “$” 锚定符对主机名进行界定，这不是 nginx 的配置语法要求，而是为了使正则表达式能正确匹配。

同时也要注意，域名的分隔符 “.” 在正则表达式中应该以 “\” 引用。如果在正则表达式中使用了 “{” 和 “}” 字符，应该将整个正则表达式引用起来，因为花括弧在 nginx 配置中也有特殊意义，引用起来以避免被 nginx 错误解析。例如：

server_name  "~^(?<name>\w\d{1,3}+)\.example\.net$";

如果不引用起来，nginx 会启动失败，并显示如下错误信息：

directive "server_name" is not terminated by ";" in ...

正则表达式的 named capture （使用一个名字对匹配的字符串进行引用）可被视为一个变量，在后面的配置中使用：

server {
    server_name   ~^(www\.)?(?<domain>.+)$;

    location / {
        root   /sites/$domain;
    }
}

PCRE 库支持 named capture，有如下几种语法：

?<name>        Perl 5.10 compatible syntax, supported since PCRE-7.0
?'name'        Perl 5.10 compatible syntax, supported since PCRE-7.0
?P<name>    Python compatible syntax, supported since PCRE-4.0

可参考：pcre2pattern：

 \d     any decimal digit
 \D     any character that is not a decimal digit
 \h     any horizontal white space character
 \H     any character that is not a horizontal white space character
 \s     any white space character
 \S     any character that is not a white space character
 \v     any vertical white space character
 \V     any character that is not a vertical white space character
 \w     any "word" character
 \W     any "non-word" character

如果 nginx 启动失败，并显示如下信息：

pcre_compile() failed: unrecognized character after (?< in ...

这表示 PCRE 库太老旧，可尝试使用 “?P<name>” 替代 “?<name>”。

named capture 也能以数字形式使用：

server {
    server_name   ~^(www\.)?(.+)$;

    location / {
        root   /sites/$2;
    }
}

无论如何，数字形式的使用应尽量简单，因为数字是只是顺序标识，而不是被匹配的字符串的标识，这导致数字引用很容易被覆盖。
混杂主机名

有一些主机名是被特殊对待的。

对于未定义 “Host” 请求首部的请求，如果希望在某个 server 区块中处理这样的请求，应在 server_name 指令的参数中添加 "" 空字符串参数：

server {
    listen       80;
    server_name  example.org  www.example.org  "";
    ...
}

在《nginx 是如何处理访问请求的》一文中曾经介绍过，如果 server 区块中没有定义 server_name 指令，便如同定义了 server_name ""。

Note:
在 0.8.48 版以前，遇到 server 区块中没有定义 server_name 指令的情况，
会将系统的主机名设置为 server 区块的 server name，而不是自动设置 "" 为
server name。

在 0.9.4 版本，如果设置：server_name $hostname，会将系统的主机名设置为 server name。

如果某个访问使用了 IP 地址 而不是 server name，“Host” 请求首部会包含 IP 地址。对于这样的请求，可使用如下的配置：

server {
    listen       80;
    server_name  example.org
                 www.example.org
                 ""
                 192.168.1.1
                 ;
    ...
}

下面是一个 catch-all server 区块的配置，使用了 “_” 作为 server name:

server {
    listen       80  default_server;
    server_name  _;
    return       444;
}

这个 server name 并没有什么特殊之处，它仅是一个无效的域名而已，也可以使用其他类似的名字，如 “--” and “!@#” 。

0.6.25 版以前的 nginx 曾经支持一个特殊的 server name: “*”，这个特殊主机名被错误的解释成一个 catch-all 主机名。但它从未以一个 catch-all 或者 通配主机名工作，它的功能实际上与现在的 server_name_in_redirect 指令的功能相同：server_name_in_redirect

特殊的 server name “*” 现在已经被弃用，应使用 server_name_in_redirect 指令。

要注意的是，使用 server_name 指令无法指定 defalt server 或是 catch-all name，这是 listen 指令的属性，不是 server_name 指令的属性。可参考《nginx 是如何处理访问请求的》。

我们可以定义两个 server，它们都同时监听于 *:80 端口 和 *:8080 端口，将其中一个设置为 *:80 端口的默认 server，将另一个设置为 *:8080 端口的默认 server：

server {
    listen       80;
    listen       8080  default_server;
    server_name  example.net;
    ...
}

server {
    listen       80  default_server;
    listen       8080;
    server_name  example.org;
    ...
}

对主机名的优化

准确的主机名、以 “*” 起始的通配主机名、以 “*” 结尾的通配主机名，这三种主机名被存放在三个 hash table 中。这三个 hash table 是与监听端口绑定的。hash table 的大小在配置阶段被优化，优化的目的是努力降低这些名字在 CPU 缓存中命中失败的几率。关于设置 hash table 的详细讨论请参考：hash

在匹配主机名时，首先查找“准确主机名”的 hash table，如果没有找到，会查找以 “*” 起始的“通配主机名”的 hash table，如果没有仍未找到，会查找以 “*” 结尾的“通配主机名”的 hash table。

对于“通配主机名”的 hash table 的检索会更慢，因为是以主机名的域名部分去检索的。

注意，对于特殊的通配主机名，形如 “.example.org”，这样的主机名是存放在“通配主机名”的 hash table 中，而不是存放在“准确主机名”的 hash table 中。

如果前面都未找到，正则表达式会按写在配置文件中的顺序被测试，因此正则表达式是最慢的方法，并且没有可扩展性。

因为以上这些原因，在可能的情况下最好使用 “准确的主机名”。例如，如果对于 example.org 和 www.example.org 的请求最为频繁，对他们进行显式的定义会更有效率：

server {
    listen       80;
    server_name  example.org  www.example.org  *.example.org;
    ...
}

下面的定义方法不如上面的配置有效率：

server {
    listen       80;
    server_name  .example.org;
    ...
}

如果定义了大量的主机名，或者使用了很长的主机名，应在配置文件的 http context 中调整这个两个参数：

    server_names_hash_max_size
    server_names_hash_bucket_size

server_names_hash_bucket_size 指令的默认值可能为 32 或 64 或 其他数字，这是根据 CPU 缓存线大小而定的。如果默认值为 32，而且定义了一个 server name 为：“too.long.server.name.example.org” 这时 nginx 就不能启动，而且显示如下的错误信息：

could not build the server_names_hash,
you should increase server_names_hash_bucket_size: 32

遇到这种情况，应将默认值设置为原来的两倍：

http {
    server_names_hash_bucket_size  64;
    ...

如果定义了大量的主机名，可能显示如下的错误信息：

could not build the server_names_hash,
you should increase either server_names_hash_max_size: 512
or server_names_hash_bucket_size: 32

遇到这种情况，首先尝试调整 server_names_hash_max_size 的值，设置为大于 server name 总数的值。如果这样设置仍不能让 nginx 正常启动，或者 nginx 启动的时间变得过长，再尝试增加 server_names_hash_bucket_size 的值。

如果一个 server 是某个监听端口唯一的 server，这时 nginx 根本不会去测试 server name，同时也不会为该监听端口构建 hash table。但其中又有一个例外，如果 server name 是正则表达式，而且正则表达式中包含了 captures，这时 nginx 不得不执行该正则表达式以获取 captures。（正则表达式的 capture 是指被圆括号引用的表达式部分，它们所匹配的字符串，可通过名字或数字引用）
兼容性

从 0.9.4 开始支持特殊主机名 “$hostname”

从 0.8.48 开始，如果 server 区块中未定义 server_name 指令，nginx 默认设定空字符串为主机名，如同定义了 server_name ""

从 0.8.25 开始支持在“正则表达式主机名”中使用 named capture 特性

从 0.7.40 开始支持在“正则表达式主机名”中使用 capture 特性

从 0.7.12 开始支持 "" 空字符串主机名

从 0.6.25 开始，支持使用“正则表达式主机名”或者“通配主机名”作为第一个主机名。

从 0.6.7 开始支持“正则表达式主机名”

从 0.6.0 开始支持形如 example.* 的“通配主机名”

从 0.3.18 开始支持形如 .example.org 的特殊“通配主机名”

从 0.1.13 开始支持形如 *.example.org 的“通配主机名”

written by Igor Sysoev
edited by Brian Mercer
