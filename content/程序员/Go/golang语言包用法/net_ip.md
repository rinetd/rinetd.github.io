---
title: golang中net包用法(二)--IP
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中net包用法(二)--IP](/chenbaoke/article/details/42782521)

IP地址（<span class="LangWithName"><span lang="en">Internet Protocol Address</span></span>，称为互联网协议地址，简写为IP Address），是一种给主机在Internet上进行编址的方式。

type IP  //IP表示一个简单的IP地址，它是一个byte类型的slice，能够接受4字节（IPV4）或者16字节（IPV6）输入。注意，IP地址是IPv4地址还是IPv6地址是语义上的特性，而不取决于切片的长度：16字节的切片也可以是IPv4地址。

``` html
type IP []byte
```

func IPv4(a, b, c, d byte) IP //ipv4返回一个ipv4地址格式（a.b.c.d)的地址，这是16-byte的

func ParseCIDR(s string) (IP, \*IPNet, error)   //ParseCIDR将字符串s解析成一个ip地址和子网掩码的结构体中，其中字符串格式必须是IP地址和子网掩码的字符串，如："192.168.100.1/24"或"2001:DB8::/48“等。
func ParseIP(s string) IP  //ParseIP将s解析为IP地址，并返回该地址。如果s不是合法的IP地址表示，则ParseIP会返回nil。字符串可以是小数点分隔的IPv4格式（如"74.125.19.99"）或IPv6格式（如"2001:4860:0:2001::68"）格式。

func (ip IP) DefaultMask() IPMask  //返回IP的默认子网掩码，只有ipv4具有默认子网掩码，如果ip不是一个有效的ipv4地址，则默认子网掩码返回nil
func (ip IP) Equal(x IP) bool          //判断两个ip地址是否相等，其中一个ipv4地址以及相同具有ipv6格式的相同的地址认为是相等的，返回true
func (ip IP) IsGlobalUnicast() bool  //判断是否是全局单播地址
func (ip IP) IsInterfaceLocalMulticast() bool  //判断是不是本地组播地址
func (ip IP) IsLinkLocalMulticast() bool  //判断是否是链路本地组播地址
func (ip IP) IsLinkLocalUnicast() bool    //判断是否时链路本地单播地址
func (ip IP) IsLoopback() bool             //判断是否是回环地址
func (ip IP) IsMulticast() bool       //判断是否是组播地址
func (ip IP) IsUnspecified() bool    //判断是否是未指定地址
func (ip IP) MarshalText() (\[\]byte, error)//实现了encoding.TextMarshaler的接口，其编码方式同String()函数的返回值一样。
func (ip IP) Mask(mask IPMask) IP  //将mask作为ip的子网掩码获取其IP地址
func (ip IP) String() string      //获取ip地址的字符串表示，如果ip是IPv4地址，返回值的格式为点分隔的，如"74.125.19.99"；否则表示为IPv6格式，如"2001:4860:0:2001::68"。
func (ip IP) To16() IP     //将一个<span style="color:#ff0000">IP地址</span>转换为16字节表示。如果ip不是一个IP地址（长度错误），To16会返回nil。<span style="background-color:rgb(255,0,0)">To16可对ip地址进行转换，包括IPV4和IPV6，而To4只能对IPV4地址进行转换，这就是To16和To4的区别。</span>
func (ip IP) To4() IP       //将一个<span style="color:#ff0000">IPV4</span>地址转换为4字节表示，如果ip不是一个ipv4地址，则返回nil
func (ip \*IP) UnmarshalText(text \[\]byte) error  //将ip进行反序列化，其实现了encoding.TextUnmarshaler的接口，IP地址字符串应该是ParseIP函数可以接受的格式。
<span style="font-family:Helvetica,Arial,sans-serif; color:#222222"><span style="font-size:16px">
</span></span>type IPAddr   //表示一个IP终端的地址

``` html
type IPAddr struct {
    IP   IP
    Zone string // IPv6 寻址范围
}
```

func ResolveIPAddr(net, addr string) (\*IPAddr, error)  //将ip地址解析成形如"host"或者"ipv6-host%zone"的地址形式,解析域名必须在指定的网络中,指定网络包括ip,ip4或者ip6
func (a \*IPAddr) Network() string //返回地址的网络类型"ip"
func (a \*IPAddr) String() string

type IPConn  //IPConn类型代表IP网络连接，实现了Conn和PacketConn接口
func DialIP(netProto string, laddr, raddr \*IPAddr) (\*IPConn, error)//DialIP在网络协议netProto上连接本地地址laddr和远端地址raddr，netProto必须是"ip"、"ip4"或"ip6"后跟冒号和协议名或协议号。
func ListenIP(netProto string, laddr \*IPAddr) (\*IPConn, error)//监听传输到本地ip地址的数据包,返回的ReadFrom和WriteTo方法能够用来发送和接受IP数据包
func (c \*IPConn) Close() error//关闭连接
func (c \*IPConn) File() (f \*os.File, err error)//File设定底层的os.File为阻塞模式并返回一个copy副本,当结束时,调用者需要关闭文件,其中原文件和副本之间相互不影响,返回的os.file的文件描述符与网络连接中的文件是不同的,使用该副本修改本体的属性可能会也可能不会得到期望的效果.
func (c \*IPConn) LocalAddr() Addr  //返回本地的网络地址
func (c \*IPConn) Read(b \[\]byte) (int, error)  //实现conn接口的读方法,将数据读入b中
func (c \*IPConn) ReadFrom(b \[\]byte) (int, Addr, error)//实现了conn的readfrom方法
func (c \*IPConn) ReadFromIP(b \[\]byte) (int, \*IPAddr, error)//从c中读取一个ip包,将有效信息拷贝到b,返回拷贝的字节数和数据包的来源地址.可以通过timeout()使得该函数超时并且返回一个错误.
func (c \*IPConn) ReadMsgIP(b, oob \[\]byte) (n, oobn, flags int, addr \*IPAddr, err error)//从c中读取一个ip包,将有效数据拷贝b,相关的额外信息拷贝进oob,返回拷贝进b和oob的字节数,数据包的flag,数据包来源地址以及可能出现的错误.
func (c \*IPConn) RemoteAddr() Addr //返回远端网络地址
func (c \*IPConn) SetDeadline(t time.Time) error//设定读写操作的绝对过期时间,是一个时间点
func (c \*IPConn) SetReadBuffer(bytes int) error//设定该连接的接受缓存的大小
func (c \*IPConn) SetReadDeadline(t time.Time) error//设定读操作的绝对过期时间
func (c \*IPConn) SetWriteBuffer(bytes int) error//设定该连接的发送缓存大小
func (c \*IPConn) SetWriteDeadline(t time.Time) error//设定写操作的绝对过期时间
func (c \*IPConn) Write(b \[\]byte) (int, error)//将b中数据写入c中,并返回写入的字节数
func (c \*IPConn) WriteMsgIP(b, oob \[\]byte, addr \*IPAddr) (n, oobn int, err error)//将b和oob中的有效信息写入c中的地址,返回写入的字节数目
func (c \*IPConn) WriteTo(b \[\]byte, addr Addr) (int, error)//WriteTo实现PacketConn接口WriteTo方法
func (c \*IPConn) WriteToIP(b \[\]byte, addr \*IPAddr) (int, error)//通过c向add写一个ip包,并从b中复制有效信息.可以通过设定timeout值使其过期.

type IPMask  //IpMask代表一个ip地址

``` html
type IPMask []byte
```

func CIDRMask(ones, bits int) IPMask //返回一个CIDRMask,其中CIDRMask总bit数目是bits,钱ones位是1,其余位是0.
func IPv4Mask(a, b, c, d byte) IPMask//返回ip掩码,其中ip掩码形式是ipv4掩码(4 byte模式)a.b.c.d
func (m IPMask) Size() (ones, bits int)//返回掩码的前面1的数目以及总数目,如果m不是规范的子网掩码(前面为1后面为0),则返回0,0
func (m IPMask) String() string//返回掩码m的16机制表示,没有标点符号

type IPNet  //表示一个ip网络

``` html
type IPNet struct {
    IP   IP     //网络地址
    Mask IPMask // 子网掩码
}
```

func (n \*IPNet) Contains(ip IP) bool//判定是否n中包含ip
func (n \*IPNet) Network() string//返回地址的网络名,形式是ip+net
func (n \*IPNet) String() string//返回ipnet n的cidr模式,形如RFC 4632 和RFC 4291中定义的 "192.168.100.1/24"or "2001:DB8::/48",如果掩码不是规范模式,将会返回一个如下形式的字符串:ip地址/一个由16进制字符组成不含标点的一个字符串,例如"192.168.100.1/c000ff00".

参考：

<http://docscn.studygolang.com/pkg/net/#pkg-constants>
