---
title: golang中net包用法（一）
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中net包用法（一）](/chenbaoke/article/details/42782571)

net包对于网络I/O提供了便携式接口，包括TCP/IP,UDP，域名解析以及Unix Socket。尽管net包提供了大量访问底层的接口，但是大多数情况下，客户端仅仅只需要最基本的接口，例如Dial，LIsten，Accepte以及分配的conn连接和listener接口。 crypto/tls包使用相同的接口以及类似的Dial和Listen函数。下面对net包进行具体分析。

首先介绍其中常量：

    const (
        IPv4len = 4
        IPv6len = 16
    )

很容易看出这表示ip地址的长度（bytes），其中ipv4长度是4，ipv6地址长度是16

<span style="font-size:18px">变量：</span>

常用的ipv4地址：

    var (
        IPv4bcast     = IPv4(255, 255, 255, 255) // 广播地址
        IPv4allsys    = IPv4(224, 0, 0, 1)       // 所有系统，包括主机和路由器，这是一个组播地址
        IPv4allrouter = IPv4(224, 0, 0, 2)       // 所有组播路由器
        IPv4zero      = IPv4(0, 0, 0, 0)         // 本地网络，只能作为本地源地址其才是合法的
    ）

常用的IPV6地址：

``` go
var (
    IPv6zero                   = IP{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}     
    IPv6unspecified            = IP{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    IPv6loopback               = IP{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
    IPv6interfacelocalallnodes = IP{0xff, 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x01}
    IPv6linklocalallnodes      = IP{0xff, 0x02, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x01}
    IPv6linklocalallrouters    = IP{0xff, 0x02, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x02}
)
```

接下来讲一下IPV4和IPV6相关知识，了解的请直接跳过。

IP地址（<span class="LangWithName"><span lang="en">Internet Protocol Address</span></span>，称为互联网协议地址，简写为IP Address），是一种给主机在Internet上进行编址的方式。常见的IP地址，分为IPV4和IPV6地址两类。

IPV4是由32位二进制数表示，其表示为XXX.XXX.XXX.XXX，每组XXX代表小于或等于255的10进制数，IPV4地址总数为2<sup>32</sup>，不过，一些地址是为特殊用途所保留的，如专用网络（约18百万个地址）和多播地址（约270百万个地址）。其中IPV4分为ABCDE五类地址，分别进行介绍：

A类地址<span style="white-space:pre"> </span>第一位为0，注意是位<span style="white-space:pre"></span>1、第1字节为网络地址，其它3个字节为主机地址

2、地址范围：1.0.0.1—126.255.255.254

3、10.X.X.X是私有地址，范围从10.0.0.0-10.255.255.255

4、127.X.X.X是保留地址，用做环回测试。

B类地址<span style="white-space:pre"> </span>前两位为10，注意是位<span style="white-space:pre"></span>1、 第1字节和第2字节为网络地址，后2个字节为主机地址

2、地址范围：128.0.0.1—191.255.255.254

3、私有地址范围：172.16.0.0—172.31.255.255

4、保留地址：169.254.X.X   

C类地址<span style="white-space:pre"> </span>前三位为110，注意是位<span style="white-space:pre"></span>1、前三个字节为网络地址，最后字节为主机地址

2、地址范围：192.0.0.1—223.255.255.254

3、私有地址：192.168.X.X，范围从192.168.0.0-192.168.255.255

D类地址<span style="white-space:pre"> </span>前四位为1110，注意三位<span style="white-space:pre"></span>1、不分网络地址和主机地址。

2、地址范围：224.0.0.1—239.255.255.254

E类地址<span style="white-space:pre"> </span>前五位为11110，注意四位<span style="white-space:pre"></span>1、不分网络地址和主机地址

2、地址范围：240.0.0.1—255.255.255.254

此外还有几个特殊IP地址：

1、0.0.0.0只能做源地址

2、255.255.255.255是广播地址

3、127.x.x.x为环回地址，本机使用

4、专用地址：

10/8 地址范围：10.0.0.0——10.255.255.255，

172.16/12 地址范围：172.16.0.0——172.31.255.255，

192.168/16地址范围：192.168.0.0——192.168.255.255。

 

224.0.0.1

     组播地址，注意它和广播的区别。从224.0.0.0到239.255.255.255都是这样的地址。224.0.0.1特指所有主机和路由器，224.0.0.2特指所有<span class="keylink">路由器</span>。这样的地址多用于一些特定的程序以及多媒体程序。如果你的主机开启了IRDP(Internet路由发现，使用组播功能)功能，那么你的主机路由表中应该有这样一条路由。

169.254.x.x

     如果你的主机使用了DHCP功能自动获得一个IP地址，那么当你的DHCP服务器发生故障，或响应时间太长而超出了一个<span class="keylink">系统</span>规定的时间，Wingdows系统会为你分配这样一个地址。如果你发现你的主机IP地址是一个诸如此类的地址，很不幸，十有八九是你的网络不能正常运行了。

至于单播广播和组播介绍及优缺点，请看这篇文章：<http://www.h3c.com.cn/products___technology/technology/group_management/other_technology/technology_recommend/200805/605846_30003_0.htm>

由于IPV4地址共有2<sup>32</sup>个地址，约为43亿，导致其不够使用，从而诞生了IPV6，IPV6地址长度为128位，其地址总数为2<sup>128</sup>个，IPV6解决了IPV4地址不够用的问题，IPV6更加详细介绍请参考<http://zh.wikipedia.org/wiki/IPv6>

func InterfaceAddrs() (\[\]Addr, error)  //InterfaceAddrs返回该系统的网络接口的地址列表。

func Interfaces() (\[\]Interface, error)   //Interfaces返回该系统的网络接口列表。
func JoinHostPort(host, port string) string   //JoinHostPort将host和port合并为一个网络地址。一般格式为"host:port"；如果host含有冒号或百分号，格式为"\[host\]:port"。
func LookupAddr(addr string) (name \[\]string, err error)  //对于给定的地址进行反向查找，并返回映射到那个地址的一个list列表
func LookupCNAME(name string) (cname string, err error)  //返回给定名字的规范的DNS主机名称，如果调用者不关心这个name是否规范，可以直接调用LookupHost 或者 LookupIP，这两个函数都会在查询时考虑到name的规范性。
func LookupHost(host string) (addrs \[\]string, err error)     //通过利用本地解析器对给定的host进行查找，返回主机地址的数组
func LookupIP(host string) (addrs \[\]IP, err error)                //通过利用本地解析器查找host，返回主机ipv4和ipv6地址的一个数组

举例说明其用法:

``` go
package main

import (
    "fmt"
    "net"
)

func main() {
    addr, _ := net.InterfaceAddrs()
    fmt.Println(addr) //[127.0.0.1/8 10.236.15.24/24 ::1/128 fe80::3617:ebff:febe:f123/64],本地地址,ipv4和ipv6地址,这些信息可通过ifconfig命令看到
    interfaces, _ := net.Interfaces()
    fmt.Println(interfaces) //[{1 65536 lo  up|loopback} {2 1500 eth0 34:17:eb:be:f1:23 up|broadcast|multicast}] 类型:MTU(最大传输单元),网络接口名,支持状态
    hp := net.JoinHostPort("127.0.0.1", "8080")
    fmt.Println(hp) //127.0.0.1:8080,根据ip和端口组成一个addr字符串表示
    lt, _ := net.LookupAddr("127.0.0.1")
    fmt.Println(lt) //[localhost],根据地址查找到改地址的一个映射列表
    cname, _ := net.LookupCNAME("www.baidu.com")
    fmt.Println(cname) //www.a.shifen.com,查找规范的dns主机名字
    host, _ := net.LookupHost("www.baidu.com")
    fmt.Println(host) //[111.13.100.92 111.13.100.91],查找给定域名的host名称
    ip, _ := net.LookupIP("www.baidu.com")
    fmt.Println(ip) //[111.13.100.92 111.13.100.91],查找给定域名的ip地址,可通过nslookup www.baidu.com进行查找操作.
}
```

在讲解下面函数用法之前,先说明几个名词含义(参考如下连接:<http://blog.sina.com.cn/s/blog_7ff492150101kqbh.html>):

域名解析记录A、CNAME、MX、NS、TXT、AAAA、SRV、显性URL、隐形URL含义
------------------------------------------------------------------

1. A记录（IP指向）：把域名（www.xxx.com）解析到某一个指定IP。用户可以将该域名解析到自己的web server上，同时也可以设置该域名的二级域名。
2. CNAME记录（Canonical Name 别名指向）：相当于用子域名代替IP地址。（优点：如果IP地址改变，只需要更改子域名的解析即可。）
3. MX记录：指向一个邮件服务器，用于电子邮件系统发邮件时根据收信人的地址后缀来定位邮件服务器。
4. NS记录：1. 解析服务器记录。用来表明由哪台服务器对该域名进行解析，这里的NS记录只对子域名生效。例如用户希望由15.54.66.88这台服务器解析coco.mydomain.com，则需要设置coco.mydomain.com的NS记录。
说明：
·“优先级”中的数字越小表示级别越高；
·“IP地址/主机名”中既可以填写IP地址，也可以填写像ns.mydomain.com这样的主机地址，但必须保证该主机地址有效。如，将coco.mydomain.com的NS记录指向到ns.mydomain.com，在设置NS记录的同时还需要设置ns.mydomain.com的指向，否则NS记录将无法正常解析；
·优先级：NS记录优先于A记录。即，如果一个主机地址同时存在NS记录和A记录，则A记录不生效。这里的NS记录只对子域名生效。
5. TXT记录：为某个主机名或域名设置联系信息，如：
admin IN TXT "管理员, 电话： 13901234567"
mail IN TXT "邮件主机, 存放在xxx , 管理人：AAA"
Jim IN TXT "contact: abc@mailserver.com"
也就是您可以设置 TXT ，以便使别人联系到您。
6. AAAA记录1. (AAAA record)：是用来将域名解析到IPv6地址的DNS记录。用户可以将一个域名解析到IPv6地址上，也可以将子域名解析到IPv6地址上。（设置AAAA记录：
i. 主机记录处填子域名。若添加泛解析，则填写\*。若将主域名直接进行解析，则留空或填写@。
ii. 记录类型为AAAA。记录值为ip地址，只可以填写IPv6地址(比如::1)。
iii. MX优先级不需要填写。
iv. TTL添加时系统会自动生成，默认为600秒。）
7. SRV记录：一般是为Microsoft的活动目录设置时的应用。DNS可以独立于活动目录，但是活动目录必须有DNS的帮助才能工作。为了活动目录能够正常的工作，DNS服务器必须支持服务定位（SRV）资源记录，资源记录把服务名字映射为提供服务的服务器名字。活动目录客户和域控制器使用SRV资源记录决定域控制器的IP地址。
此技术细节请参考相应网站（看过的见论坛帖http://bbs.28tui.com/forum.php?mod=viewthread&tid=2321129）
8. 显性URL记录：访问域名时，会自动跳转到所指的另一个网络地址（URL），此时在浏览器地址栏中显示的是跳转的地址。
9. 隐形URL记录：访问域名时，会自动跳转到所指的另一个网络地址（URL），此时在浏览器地址栏中显示的是原域名地址。

func LookupMX(name string) (mx \[\]\*MX, err error)  //查找指定域名的DNS MX邮件交换记录，并按照优先顺序进行返回。
func LookupNS(name string) (ns \[\]\*NS, err error)    //返回指定域名的DNS NS记录
func LookupPort(network, service string) (port int, err error)           //返回指定network和service的端口
func LookupSRV(service, proto, name string) (cname string, addrs \[\]\*SRV, err error)    //对指定的service服务，protocol协议以及name域名进行srv查询，其中proto协议表示tcp或者udp，返回的record记录按照优先级进行排序，同一优先级下的按照weight权重进行随机排序。LookupSRV函数按照RFC 2782标准来构建用于查询的DNS。也就是说，它查询\_service.\_proto.name。当service和proto参数都是空字符串时，LookupSRV将会直接查找name。
func LookupTXT(name string) (txt \[\]string, err error)  //查找指定域名的DNS TXT记录
func SplitHostPort(hostport string) (host, port string, err error)  //SplitHostPort将如下形式的网络地址拆分成host和port形式，其中拆分前的格式如下："host:port","\[host\]:port" or "\[ipv6-host%zone\]:port"，其中ipv6的地址或者主机名必须用方括号括起来，如"\[::1\]:80"、"\[ipv6-host\]:http"、"\[ipv6-host%zone\]:80"

<span style="font-size:18px">接下来讲述一下net包中存在的error：</span>

type Error  //表示网络错误

``` go
type Error interface {
    error      //错误
    Timeout() bool   // Is the error a timeout? 该错误是时间超时错误吗？
    Temporary() bool // Is the error temporary? 这个错误是一个临时错误吗？
}
```

任何实现了error接口中方法的结构体都实现了网络error

其主要有以下集中错误：

type AddrError //网络地址错误

``` go
type AddrError struct {
    Err  string  //错误
    Addr string //地址字符串表示
}
```

func (e \*AddrError) Error() string          //错误
func (e \*AddrError) Temporary() bool   //该错误是否是一个临时错误
func (e \*AddrError) Timeout() bool       //该错误是否是超时错误

type DNSConfigError //DNS配置错误，表示在读取机器DNS配置过程中出现的错误

``` go
type DNSConfigError struct {
    Err error
}
```

func (e \*DNSConfigError) Error() string
func (e \*DNSConfigError) Temporary() bool
func (e \*DNSConfigError) Timeout() bool

type DNSError   //DNS错误，表示DNS查询错误

``` go
type DNSError struct {
    Err       string // description of the error，错误描述
    Name      string // name looked for，查询 名称
    Server    string // server used，服务
    IsTimeout bool，是否超时
}
```

func (e \*DNSError) Error() string
func (e \*DNSError) Temporary() bool
func (e \*DNSError) Timeout() bool

以DNSError为例,举例说明net保重Error的用法

``` go
package main

import (
    "fmt"
    "net"
)

func main() {
    dnserror := net.DNSError{
        Err:       "dns error",
        Name:      "dnserr",
        Server:    "dns search",
        IsTimeout: true,
    }
    fmt.Println(dnserror.Error())     //lookup dnserr on dns search: dns error
    fmt.Println(dnserror.Temporary()) //true
    fmt.Println(dnserror.Timeout())   //true
    fmt.Println(dnserror.Server)      //dns search
    fmt.Println(dnserror.Err)         //dns error
    fmt.Println(dnserror.Name)        //dnserr
    fmt.Println(dnserror.IsTimeout)   //true
}
```

type InvalidAddrError  //无效地址错误

``` go
type InvalidAddrError string
```

func (e InvalidAddrError) Error() string
func (e InvalidAddrError) Temporary() bool
func (e InvalidAddrError) Timeout() bool

type OpError        //操作错误，OpError是在net包中经常背用刀的一个函数，它描述一个错误的操作，网络类型以及地址。

``` go
type OpError struct {

    Op string   //Op是引起错误的操作，如"read"或"write"

    Net string      //Net表示错误出现的网络类型，如tcp或者udp6

    Addr Addr    //Addr表示错误出现的网络抵制

    Err error    //Err表示错误
}
```

func (e \*OpError) Error() string
func (e \*OpError) Temporary() bool
func (e \*OpError) Timeout() bool

在OpError错误中大部分错误会包含如下错误：

    var (
        ErrWriteToConnected = errors.New("use of WriteTo with pre-connected connection")
    )

type ParseError   //解析错误，ParseError表示一个格式错误的字符串，其中Type表示期望的格式。

``` go
type ParseError struct {
    Type string
    Text string
}
```

func (e \*ParseError) Error() string    //将错误表示为字符串形式

type UnknownNetworkError  //未知网络错误

``` go
type UnknownNetworkError string
```

func (e UnknownNetworkError) Error() string
func (e UnknownNetworkError) Temporary() bool
func (e UnknownNetworkError) Timeout() bool

type Addr   //网络终端地址

``` go
type Addr interface {
    Network() string // 网络名称
    String() string  // 地址字符串表示
}
```

type Conn    //conn是一个通用的面向流的网络连接，多个goroutine可以同时调用conn中的方法。

``` go
type Conn interface {
    // Read从连接中读取数据，Read方法会在超过某个固定时间限制后返回一个表示超时的错误，该错误的TImeout()==True
    Read(b []byte) (n int, err error)
    // Write向conn中写入数据，与Read类似， Write方法也会在超过某个固定时间后返回超时错误，该错误的Timeout()==True
    Write(b []byte) (n int, err error)
    // Close方法关闭该连接，同时任何阻塞的Read或Write方法将不再阻塞，并且返回错误。
    Close() error
    // 返回本地网络地址
    LocalAddr() Addr
    // 返回远端网络地址
    RemoteAddr() Addr
    // 设定连接的读写deadline，它等价于调用SetReadDeadline和SetWriteDeadline进行conn连接的读写deadline设定。其中deadline是一个绝对时间，
        //在deadline时间之后，任何的读写操作都不再阻塞，而是直接失败，deadline对之后的所有I/O操作都起效，而不仅仅是下一次的读或写操作，
    // ：一：空闲超时，这种方法实现其中有两类超时比较特殊是在每次成功读或者写操作后都延长超时期限，当没有读写操作空闲时便会超时；二：参数t为零值表示不设置
        //超时期限，即不会超时timeout
    SetDeadline(t time.Time) error
    // 设定连接的读操作deadline，参数t为零值表示不设置期限
    SetReadDeadline(t time.Time) error
    // 设定连接的写操作deadline，参数t为零值表示不设置期限
    // 即使写超时，也有可能出现写入字数n>0，说明成功写入了部分数据，但是没有将数据全部写入。
    SetWriteDeadline(t time.Time) error
}
```

func Dial(network, address string) (Conn, error)    //Dial 连接到指定address和name的网络，其中network包含如下几种："tcp", "tcp4" (IPv4-only), "tcp6" (IPv6-only),"udp", "udp4" (IPv4-only), "udp6" (IPv6-only), "ip", "ip4"(IPv4-only), "ip6" (IPv6-only), "unix", "unixgram" and"unixpacket". 对于TCP和UDP网络来说，addresses的形式如下host：port，其行使和JoinHostPort以及SplitHostPort函数中的addresses形式一致。举例如下所示：

    Dial("tcp", "12.34.56.78:80")
    Dial("tcp", "google.com:http")
    Dial("tcp", "[2001:db8::1]:http")
    Dial("tcp", "[fe80::1%lo0]:80")

对于IP网络，network必须是ip，ipv4或者ipv6，并且他们后面必须跟着冒号和协议数字协议名字，并且这个地址必须是一个ip地址，举例如下：

    Dial("ip4:1", "127.0.0.1")
    Dial("ip6:ospf", "::1")

对于Unix网络来说，address必须是一个文件系统的路径。

func DialTimeout(network, address string, timeout time.Duration) (Conn, error) //该函数与Dial函数类似，但是多一个超时设置timeout，如果需要的话，timeout中包含域名解析
func FileConn(f \*os.File) (c Conn, err error)     //FileConn返回一个对文件f的网络连接的复制copy，当调用完毕后，用户需要自己关闭文件f，由于是复制关系，所以关闭c和关闭f二者互不影响。
func Pipe() (Conn, Conn)      //Pipe在内存中创建一个同步全双工的网络连接。连接的两端都实现了Conn接口。一端的读取对应另一端的写入，在这个过程中复制数据是直接在两端之间进行复制，而没有内部缓存。
type Dialer  //包含连接到一个地址的选项，//在Dialer结构体中的每个参数的零值相当于没有那个值，因此调用零值的Dialer中的Dial函数相当于直接调用Dial函数

``` go
type Dialer struct {
    // Timeout是dial操作等待连接建立的最大时长，默认值代表没有超时。如果Deadline字段也被设置了，dial操作也可能更早失败。
    // 不管有没有设置超时，操作系统都可能强制执行它的超时设置。例如，TCP（系统）超时一般在3分钟左右。Timeout是一个相对时间，是时间段，而Deadline是一个绝
        //对时间，是时间点，这是二者的区别
    Timeout time.Duration

       // Deadline是一个具体的时间点期限，超过该期限后，dial操作就会失败。如果Timeout字段也被设置了，dial操作也可能更早失败。零值表示没有期限。
    Deadline time.Time

       // LocalAddr是dial一个地址时使用的本地地址。
    // 该地址必须是与dial的网络相容的类型。
    // 如果为nil，将会自动选择一个本地地址。
    LocalAddr Addr

        // 当网络类型是tcp并且一个主机名字具有多个dns记录地址时，DualStack允许一个dial创建多个ipv4和ipv6的连接，并且返回第一个创建的连接
    DualStack bool

        // KeepAlive指定一个网络连接的保持声明的时间段；如果为0，会禁止keep-alive。当网络协议不支持keep-alives时便会忽略掉这个值。
    // 不支持keep-alive的网络连接会忽略本字段。
    KeepAlive time.Duration
}
```

func (d \*Dialer) Dial(network, address string) (Conn, error)   //Dial在指定的网络上连接指定的地址。详细用法参见Dial函数获取网络和地址参数的描述

type Flags

``` go
type Flags uint
```

``` go
const (
    FlagUp           Flags = 1 << iota // 接口处于互动状态
    FlagBroadcast                      // 接口支持广播
    FlagLoopback                       // 接口是回环接口
    FlagPointToPoint                   // 接口属于点到点
    FlagMulticast                      // 接口支持组播
)
```

func (f Flags) String() string   //将f用字符串表示

type HardwareAddr  //硬件地址，HardwareAddr表示一个物理硬件地址

``` go
type HardwareAddr []byte
```

func ParseMAC(s string) (hw HardwareAddr, err error) //将字符串解析成硬件物理地址，其中ParseMAC函数使用如下格式解析一个IEEE 802 MAC-48、EUI-48或EUI-64硬件地址：

``` go
01:23:45:67:89:ab
01:23:45:67:89:ab:cd:ef
01-23-45-67-89-ab
01-23-45-67-89-ab-cd-ef
0123.4567.89ab
0123.4567.89ab.cdef
```

func (a HardwareAddr) String() string  //硬件地址的字符串表示

type Interface   //Interface表示一个在网络接口名和索引之间的映射，他也包含网络借口设备信息。

``` go
type Interface struct {
    Index        int          // 索引，必须为正整数
    MTU          int          // 最大传输单元
    Name         string       // 名字，例如： "en0", "lo0", "eth0.100"
    HardwareAddr HardwareAddr //硬件地址，例如： IEEE MAC-48, EUI-48 and EUI-64 form
    Flags        Flags        // flags标记,例如： FlagUp, FlagLoopback, FlagMulticast
}
```

func InterfaceByIndex(index int) (\*Interface, error)    //通过指定的索引index返回相应的接口
func InterfaceByName(name string) (\*Interface, error) //通过指定的名字Name返回相应的接口
func (ifi \*Interface) Addrs() (\[\]Addr, error)          //返回指定接口的address
func (ifi \*Interface) MulticastAddrs() (\[\]Addr, error)   //MulticastAddrs返回网络接口ifi加入的多播组地址。
type Listener  //Listener是一个用于面向流的网络协议的公用的网络监听器接口。多个线程可能会同时调用一个Listener的方法。

``` go
type Listener interface {

    Accept() (c Conn, err error)//等待并返回下一个连接到该连接的连接

    Close() error   //关闭listener，关闭后，任何阻塞accept的操作都不再阻塞，并且返回error

    Addr() Addr   //返回该接口的网络地址
}
```

func FileListener(f \*os.File) (l Listener, err error)   //返回对于文件f的网络listener的复制。
func Listen(net, laddr string) (Listener, error)  //返回在一个本地网络地址laddr上监听的Listener。网络类型参数net必须是面向流的网络："tcp"、"tcp4"、"tcp6"、"unix"或"unixpacket"。具体参见Dial函数获取laddr的语法。
type PacketConn
func FilePacketConn(f \*os.File) (c PacketConn, err error)
func ListenPacket(net, laddr string) (PacketConn, error)

type MX  //MX代表一条DNS MX记录（邮件交换记录），根据收信人的地址后缀来定位邮件服务器。

``` go
type MX struct {
    Host string
    Pref uint16
}
```

type NS  //NS代表一条DNS NS记录（域名服务器记录），指定该域名由哪个DNS服务器来进行解析。

``` go
type NS struct {
    Host string
}
```

type SRV  //SRV代表一条DNS SRV记录（资源记录），记录某个服务由哪台计算机提供。

``` go
type SRV struct {
    Target   string
    Port     uint16
    Priority uint16
    Weight   uint16
}
```

参考：

[http://docscn.studygolang.com/pkg/net/\#pkg-constants
](http://zh.wikipedia.org/wiki/IPv6)
