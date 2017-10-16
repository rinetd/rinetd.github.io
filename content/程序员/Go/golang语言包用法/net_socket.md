---
title: golang中net包用法(三)--TCP和UDP以及Unix domain socket
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)

[golang中net包用法(三)--TCP和UDP以及Unix domain socket](/chenbaoke/article/details/42782473)

type TCPAddr  //表示TCP终端地址

    type TCPAddr struct {
        IP   IP
        Port int
        Zone string // IPv6寻址范围
    }

func ResolveTCPAddr(net, addr string) (\*TCPAddr, error)//将一个地址解析成TCP地址形式,形如"host:port"或 "\[ipv6-host%zone\]:port",解析得到网络域名和端口名.其中net必须是"tcp","tcp4"或者"tcp6",IPv6地址字面值/名称必须用方括号包起来，如"\[::1\]:80"、"\[ipv6-host\]:http"或"\[ipv6-host%zone\]:80".

func (a \*TCPAddr) Network() string  //返回地址的网络类型,"tcp"
func (a \*TCPAddr) String() string

type TCPConn//TCPConn是TCP网络连接,其实现了Conn接口,其中方法大部分与IPConn相同,这里不再赘述.
func DialTCP(net string, laddr, raddr \*TCPAddr) (\*TCPConn, error)
func (c \*TCPConn) Close() error
func (c \*TCPConn) CloseRead() error
func (c \*TCPConn) CloseWrite() error
func (c \*TCPConn) File() (f \*os.File, err error)
func (c \*TCPConn) LocalAddr() Addr
func (c \*TCPConn) Read(b \[\]byte) (int, error)
func (c \*TCPConn) ReadFrom(r io.Reader) (int64, error)
func (c \*TCPConn) RemoteAddr() Addr
func (c \*TCPConn) SetDeadline(t time.Time) error
func (c \*TCPConn) SetKeepAlive(keepalive bool) error //设置操作系统是否应该在该连接中发送keepalive信息
func (c \*TCPConn) SetKeepAlivePeriod(d time.Duration) error //设定keepalive的生存周期
func (c \*TCPConn) SetLinger(sec int) error //SetLinger设定一个连接的关闭行为当该连接中仍有数据等待发送或者确认.如果sec&lt;0(默认形式),操作系统将在后台完成发送数据操作;如果sec==0,操作系统将任何未发送或者未确认的数据丢弃;当sec&gt;0,数据将在后台进行发送,这点和sec&lt;0时效果一致.然而,在一些操作系统中,当sec秒之后,系统将任何未发送的数据丢弃.
func (c \*TCPConn) SetNoDelay(noDelay bool) error//控制是否操作系统为了发送更少的数据包(Nagle's算法)而延迟数据包的发送,默认值是true(不延迟),这意味着数据将在写后尽可能快的进行发送,而不是延迟发送.
func (c \*TCPConn) SetReadBuffer(bytes int) error //设定操作系统对于conn连接接受缓存的大小
func (c \*TCPConn) SetReadDeadline(t time.Time) error//设定读超时时间
func (c \*TCPConn) SetWriteBuffer(bytes int) error//设定操作系统对于conn连接发送缓存的大小
func (c \*TCPConn) SetWriteDeadline(t time.Time) error//设定发送超时时间
func (c \*TCPConn) Write(b \[\]byte) (int, error)//实现了write接口方法

type TCPListener//TCP监听器,客户端应该使用不同类型的监听,而不是默认的TCP

func ListenTCP(net string, laddr \*TCPAddr) (\*TCPListener, error)//声明Tcp地址laddr并且返回一个tcp listener,其中net必须是tcp,tcp4或者tcp6,如果laddr端口是0,则ListenTcp将选择一个可用的端口,调用者可以利用TCPListener的addr方法来获取该地址.
func (l \*TCPListener) Accept() (Conn, error)//实现listener接口的accept方法,它等待下次调用并返回一个连接
func (l \*TCPListener) AcceptTCP() (\*TCPConn, error)//接受下一次调用,并返回一个新的连接
func (l \*TCPListener) Addr() Addr//返回listener的网络地址,TCPAddr
func (l \*TCPListener) Close() error  //停止监听TCP地址,已经建立的连接不被关闭
func (l \*TCPListener) File() (f \*os.File, err error)//返回底层os.File的一个副本,设定为阻塞模式,调用者需要关闭文件当完毕后,关闭l不影响文件副本f,并且关闭文件副本f也不影响tcplistener l,返回的文件句柄不同于原来网络连接的文件,通过这个副本来改变原来的文件属性可能起作用也可能不起作用.

func (l \*TCPListener) SetDeadline(t time.Time) error//设定监听者的超时时间,如果时间设置为0,则禁用超时设置,即永远不会超时.

type UDPAddr  //代表一个udp端口的地址

``` html
type UDPAddr struct {
        IP   IP
        Port int
        Zone string // IPv6 寻址范围
}
```

func ResolveUDPAddr(net, addr string) (\*UDPAddr, error)  //将addr作为UDP地址解析并返回。参数addr格式为"host:port"或"\[ipv6-host%zone\]:port"，解析得到网络名和端口名；net必须是"udp"、"udp4"或"udp6"。IPv6地址字面值/名称必须用方括号包起来，如"\[::1\]:80"、"\[ipv6-host\]:http"或"\[ipv6-host%zone\]:80"。
func (a \*UDPAddr) Network() string//返回地址的网络名"udp"
func (a \*UDPAddr) String() string//UDPAddr的字符化形式表示

type UDPConn  //实现了udp网络连接,它实现了conn和packetconn的接口
func DialUDP(net string, laddr, raddr \*UDPAddr) (\*UDPConn, error)//连接网络上的远程地址raddr,其中net必须是udp,udp4或者udp6,如果laddr不是空,则使用本地地址用于连接
func ListenMulticastUDP(net string, ifi \*Interface, gaddr \*UDPAddr) (\*UDPConn, error)//监听在ifi的组地址gaddr上的多播udp包,ifi指定了加入的接口,如果ifi是空的话,则使用默认的多播接口
func ListenUDP(net string, laddr \*UDPAddr) (\*UDPConn, error)//监听绑定在本地地址laddr上的udp包,其中net必须是udp,udp4或者udp6,如果laddr是端口0的话,则listenudp将选择一个可用的port端口,使用udpconn的LocalAddr方法能够发现这个port端口,返回的udpconn的ReadFrom和WriteTo方法能够用来接受和发送udp包.
func (c \*UDPConn) Close() error//关闭连接
func (c \*UDPConn) File() (f \*os.File, err error)//与TCPConn中File()方法类似
func (c \*UDPConn) LocalAddr() Addr//返回本地网络地址
func (c \*UDPConn) Read(b \[\]byte) (int, error)
func (c \*UDPConn) ReadFrom(b \[\]byte) (int, Addr, error)
func (c \*UDPConn) ReadFromUDP(b \[\]byte) (n int, addr \*UDPAddr, err error)//从c中读取一个包,将有效负载写入b中返回写入的byte数以及包的地址.ReadFromUdp可以设置为超时.
func (c \*UDPConn) ReadMsgUDP(b, oob \[\]byte) (n, oobn, flags int, addr \*UDPAddr, err error)//ReadMsgUDP从c读取一个数据包，将有效负载拷贝进b，相关的带外数据拷贝进oob，返回拷贝进b的字节数，拷贝进oob的字节数，数据包的flag，数据包来源地址和可能的错误。
func (c \*UDPConn) RemoteAddr() Addr//返回远程的网络地址
func (c \*UDPConn) SetDeadline(t time.Time) error //实现conn的超时方法,设置udpconn的超时
func (c \*UDPConn) SetReadBuffer(bytes int) error
func (c \*UDPConn) SetReadDeadline(t time.Time) error
func (c \*UDPConn) SetWriteBuffer(bytes int) error
func (c \*UDPConn) SetWriteDeadline(t time.Time) error
func (c \*UDPConn) Write(b \[\]byte) (int, error)
func (c \*UDPConn) WriteMsgUDP(b, oob \[\]byte, addr \*UDPAddr) (n, oobn int, err error)//WriteMsgUDP通过c向地址addr发送一个数据包，b和oob分别为包有效负载和对应的带外数据，返回写入的字节数（包数据、带外数据）和可能的错误。
func (c \*UDPConn) WriteTo(b \[\]byte, addr Addr) (int, error)
func (c \*UDPConn) WriteToUDP(b \[\]byte, addr \*UDPAddr) (int, error) //通过c将一个udp包写入addr,其中需要从b中复制有效负载.WriteToUDP也可以设置超时时间

type UnixAddr  //代表一个Unix域名的socket终端地址

``` html
type UnixAddr struct {
        Name string
        Net  string
}
```

func ResolveUnixAddr(net, addr string) (\*UnixAddr, error) //将addr解析成UnixAddr,net指的是网络名称,为unix,unixgram或者unixpacket
func (a \*UnixAddr) Network() string  //返回网络名称,unix,unixgram或者unixpacket
func (a \*UnixAddr) String() string  //UnixAddr的字符形式表示

type UnixConn//UnixConn是Unix域名socket的网络连接
func DialUnix(net string, laddr, raddr \*UnixAddr) (\*UnixConn, error)//在网络协议net上连接本地地址laddr和远端地址raddr.其中net是"unix"、"unixgram"、"unixpacket"，如果laddr不是nil将使用它作为本地地址。
func ListenUnixgram(net string, laddr \*UnixAddr) (\*UnixConn, error)//监听绑定到本地地址laddr的数据包,<span style="color:#FF0000">其中net必须是unixgram</span>,返回连接的ReadFrom和WriteTo方法能够用来接受和发送地址包
func (c \*UnixConn) Close() error//关闭连接
func (c \*UnixConn) CloseRead() error//关闭连接的读操作,大多数情况下使用Close
func (c \*UnixConn) CloseWrite() error//关闭连接的写操作,大多数情况下使用Close
func (c \*UnixConn) File() (f \*os.File, err error)//
func (c \*UnixConn) LocalAddr() Addr
func (c \*UnixConn) Read(b \[\]byte) (int, error)
func (c \*UnixConn) ReadFrom(b \[\]byte) (int, Addr, error)
func (c \*UnixConn) ReadFromUnix(b \[\]byte) (n int, addr \*UnixAddr, err error)
func (c \*UnixConn) ReadMsgUnix(b, oob \[\]byte) (n, oobn, flags int, addr \*UnixAddr, err error)
func (c \*UnixConn) RemoteAddr() Addr
func (c \*UnixConn) SetDeadline(t time.Time) error
func (c \*UnixConn) SetReadBuffer(bytes int) error
func (c \*UnixConn) SetReadDeadline(t time.Time) error
func (c \*UnixConn) SetWriteBuffer(bytes int) error
func (c \*UnixConn) SetWriteDeadline(t time.Time) error
func (c \*UnixConn) Write(b \[\]byte) (int, error)
func (c \*UnixConn) WriteMsgUnix(b, oob \[\]byte, addr \*UnixAddr) (n, oobn int, err error)
func (c \*UnixConn) WriteTo(b \[\]byte, addr Addr) (n int, err error)
func (c \*UnixConn) WriteToUnix(b \[\]byte, addr \*UnixAddr) (n int, err error)

type UnixListener//表示一个Unix域名socket监听者,客户端应该使用指定的不同类型的listener而不是使用默认的unix domain socket
func ListenUnix(net string, laddr \*UnixAddr) (\*UnixListener, error) //利用Unix domain socket的laddr创建一个unix监听者,这个网络必须是unix或者unixpacket
func (l \*UnixListener) Accept() (c Conn, err error)//
func (l \*UnixListener) AcceptUnix() (\*UnixConn, error)
func (l \*UnixListener) Addr() Addr
func (l \*UnixListener) Close() error
func (l \*UnixListener) File() (f \*os.File, err error)
func (l \*UnixListener) SetDeadline(t time.Time) (err error)
Bugs

在任何POSIX平台上，使用ReadFrom或ReadFromIP方法从"ip4"网络读取数据时，即使有足够的空间，都可能不会返回完整的IPv4数据包，包括数据包的头域。即使Read或ReadMsgIP方法可以返回完整的数据包，也有可能出现这种情况。因为对go 1的兼容性要求，这个情况无法被修正。因此，如果必须获取完整数据包时，建议不要使用这两个方法，请使用Read或ReadMsgIP代替。

在OpenBSD系统中，在"tcp"网络监听时不会同时监听IPv4和IPv6连接。 因为该系统中IPv4通信不会导入IPv6套接字中。如果有必要的话,请使用两个独立的监听。

参考：

<http://docscn.studygolang.com/pkg/net/#pkg-constants>
