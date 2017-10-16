---
title: golang中net/http包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中net/http包用法](/chenbaoke/article/details/42782417)

http包包含http客户端和服务端的实现,利用Get,Head,Post,以及PostForm实现HTTP或者HTTPS的请求.

当客户端使用完response body后必须使用close对其进行关闭.如下所示
```go
    resp, err := http.Get("http://example.com/")
    if err != nil {
        // handle error
    }
    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)
    // ...

变量:

以下错误是http server使用的

    var (
            ErrHeaderTooLong        = &ProtocolError{"header too long"}
            ErrShortBody            = &ProtocolError{"entity body too short"}
            ErrNotSupported         = &ProtocolError{"feature not supported"}
            ErrUnexpectedTrailer    = &ProtocolError{"trailer header without chunked transfer encoding"}
            ErrMissingContentLength = &ProtocolError{"missing ContentLength in HEAD response"}
            ErrNotMultipart         = &ProtocolError{"request Content-Type isn't multipart/form-data"}
            ErrMissingBoundary      = &ProtocolError{"no multipart boundary param in Content-Type"}
    )

    var (
            ErrWriteAfterFlush = errors.New("Conn.Write called after Flush")
            ErrBodyNotAllowed  = errors.New("http: request method or response status code does not allow body")
            ErrHijacked        = errors.New("Conn has been hijacked")
            ErrContentLength   = errors.New("Conn.Write wrote more than the declared Content-Length")
    )

    var DefaultClient = &Client{} //默认客户端,被Get,Head以及Post使用

    var DefaultServeMux = NewServeMux()//Serve使用的默认ServeMux

    var ErrBodyReadAfterClose = errors.New("http: invalid Read on closed Body")//当读取一个request或者response body是在这个body已经关闭之后,便会返回该错误.这种错误主要发生情况是:当http handler调用writeheader或者write关于responsewrite之后进行读操作.

    var ErrHandlerTimeout = errors.New("http: Handler timeout")//超时错误

    var ErrLineTooLong = internal.ErrLineTooLong//当读取格式错误的分块编码时便会出现该错误.

    var ErrMissingFile = errors.New("http: no such file")//当利用FormFile进行文件请求时,如果文件不存在或者请求中没有该文件就会出现该错误.

    var ErrNoCookie = errors.New("http: named cookie not present")

    var ErrNoLocation = errors.New("http: no Location header in response")

函数:
func CanonicalHeaderKey(s string) string//返回header key的规范化形式,规范化形式是以"-"为分隔符,每一部分都是首字母大写,其他字母小写.例如"accept-encoding" 的标准化形式是 "Accept-Encoding".
func DetectContentType(data \[\]byte) string//检查给定数据的内容类型Content-Type,最多检测512byte数据,如果有效的话,该函数返回一个MIME类型,否则的话,返回一个"application/octet-stream"
func Error(w ResponseWriter, error string, code int)//利用指定的错误信息和Http code来响应请求,其中错误信息必须是纯文本.
func NotFound(w ResponseWriter, r \*Request)//返回HTTP404 not found错误
func Handle(pattern string, handler Handler)//将handler按照指定的格式注册到DefaultServeMux,ServeMux解释了模式匹配规则
func HandleFunc(pattern string, handler func(ResponseWriter, \*Request))//同上，<span style="color:#ff0000">主要用来实现动态文件内容的展示，这点与ServerFile()不同的地方。</span>
func ListenAndServe(addr string, handler Handler) error//监听TCP网络地址addr然后调用具有handler的Serve去处理连接请求.通常情况下Handler是nil,使用默认的DefaultServeMux
func ListenAndServeTLS(addr string, certFile string, keyFile string, handler Handler) error//该函数与ListenAndServe功能基本相同,二者不同之处是该函数需要HTTPS连接.也就是说,必须给该服务Serve提供一个包含整数的秘钥的文件,如果证书是由证书机构签署的,那么证书文件必须是服务证书之后跟着CA证书.
func ServeFile(w ResponseWriter, r \*Request, name string)//利用指定的文件或者目录的内容来响应相应的请求.
func SetCookie(w ResponseWriter, cookie \*Cookie)//给w设定cookie
func StatusText(code int) string//对于http状态码返回文本表示,如果这个code未知,则返回空的字符串.
举例说明上述函数使用方法：

    package main

    import (
        "fmt"
        "net/http"
    )

    func Test(w http.ResponseWriter, r *http.Request) {
        // http.NotFound(w, r)//用于设置404问题
        // http.Error(w, "404 page not found", 404) //状态码需和描述相符

        http.ServeFile(w, r, "1.txt") //将1.txt中内容在w中显示.
        cookie := &http.Cookie{
            Name:  http.CanonicalHeaderKey("uid-test"), //Name值为Uid-Test
            Value: "1234",
        }
        r.AddCookie(cookie)
        fmt.Println(r.Cookie("uid-test")) //<nil> http: named cookie not present
        fmt.Println(r.Cookie("Uid-Test")) //Uid-Test=1234 <nil>
        fmt.Println(r.Cookies())          //[Uid-Test=1234]

    }
    func main() {

        stat := http.StatusText(200)
        fmt.Println(stat) //状态码200对应的状态OK

        stringtype := http.DetectContentType([]byte("test"))
        fmt.Println(stringtype) //text/plain; charset=utf-8

        http.HandleFunc("/test", Test)
        err := http.ListenAndServe(":9999", nil)
        if err != nil {
            fmt.Println(err)
        }

    }
func MaxBytesReader(w ResponseWriter, r io.ReadCloser, n int64) io.ReadCloser//该函数类似于io.LimitReader但是该函数是用来限制请求体的大小.与io.LimitReader不同的是,该函数返回一个ReaderCloser,当读超过限制时,返回一个non-EOF,并且当Close方法调用时,关闭底层的reader.该函数组织客户端恶意发送大量请求,浪费服务器资源.
func ParseHTTPVersion(vers string) (major, minor int, ok bool)//解析http字符串版本进行解析,"HTTP/1.0" 返回 (1, 0, true)//<span style="color:#ff0000">注解析的字符串必须以HTTP开始才能够正确解析，HTTP区分大小写，其他诸如http或者Http都不能够正确解析。</span>
func ParseTime(text string) (t time.Time, err error)//解析时间头(例如data:header),解析格式如下面三种(HTTP/1.1中允许的):TimeFormat, time.RFC850, and time.ANSIC
func ProxyFromEnvironment(req \*Request) (\*url.URL, error)//该函数返回一个指定请求的代理URL,这是由环境变量HTTP\_PROXY,HTTPS\_PROXY以及NO\_PROXY决定的,对于https请求,HTTPS\_PROXY优先级高于HTTP\_PROXY,环境值可能是一个URL或者一个host:port,其中这两种类型都是http调度允许的,如果不是这两种类型的数值便会返回错误.如果在环境中没有定义代理或者代理不应该用于该请求(定义为NO\_PROXY),将会返回一个nil URL和一个nil error.作为一个特例,如果请求rul是"localhost",无论有没有port,那么将返回一个nil rul和一个nil error.
func ProxyURL(fixedURL \*url.URL) func(\*Request) (\*url.URL, error)//返回一个用于传输的代理函数,该函数总是返回相同的URL
func Redirect(w ResponseWriter, r \*Request, urlStr string, code int)//返回一个重定向的url给指定的请求,这个重定向url可能是一个相对请求路径的一个相对路径.
func Serve(l net.Listener, handler Handler) error//该函数接受listener l的传入http连接,对于每一个连接创建一个新的服务协程,这个服务协程读取请求然后调用handler来给他们响应.handler一般为nil,这样默认的DefaultServeMux被使用.
func ServeContent(w ResponseWriter, req \*Request, name string, modtime time.Time, content io.ReadSeeker)//该函数使用提供的ReaderSeeker提供的内容来恢复请求,该函数相对于io.Copy的优点是可以处理范围类请求,设定MIME类型,并且处理了If-Modified-Since请求.如果未设定content-type类型,该函数首先通过文件扩展名来判断类型,如果失效的话,读取content的第一块数据并将他传递给DetectContentType进行类型判断.name可以不被使用,更进一步说,他可以为空并且不在respone中返回.如果modtime不是0时间,该时间则体现在response的最后一次修改的header中,如果请求包括一个If-Modified-Since header,该函数利用modtime来决定是否发送该content.该函数利用Seek功能来决定content的大小.
type Client//Client是一个http客户端,默认客户端(DefaultClient)将使用默认的发送机制的客户端.Client的Transport字段一般会含有内部状态(缓存TCP连接),因此Client类型值应尽量被重用而不是创建新的。多个协程并发使用Clients是安全的.
    type Client struct {
        // Transport指定执行独立、单次HTTP请求的机制如果Transport为nil,则使用DefaultTransport。
        Transport RoundTripper
        // CheckRedirect指定处理重定向的策略,如果CheckRedirect非nil,client将会在调用重定向之前调用它。
        // 参数req和via是将要执行的请求和已经执行的请求（时间越久的请求优先执行),如果CheckRedirect返回一个错误,
    　　 //client的GetGet方法不会发送请求req,而是回之前得到的响应和该错误。
        // 如果CheckRedirect为nil，会采用默认策略：在连续10次请求后停止。
        CheckRedirect func(req *Request, via []*Request) error
        // Jar指定cookie管理器,如果Jar为nil,在请求中不会发送cookie,在回复中cookie也会被忽略。
        Jar CookieJar
        // Timeout指定Client请求的时间限制,该超时限制包括连接时间、重定向和读取response body时间。
        // 计时器会在Head,Get,Post或Do方法返回后开始计时并在读到response.body后停止计时。
    　　// Timeout为零值表示不设置超时。
        // Client的Transport字段必须支持CancelRequest方法,否则Client会在尝试用Head,Get,Post或Do方法执行请求时返回错误。
        // Client的Transport字段默认值（DefaultTransport）支持CancelRequest方法。
        Timeout time.Duration
    }

    func (c \*Client) Do(req \*Request) (resp \*Response, err error)//Do发送http请求并且返回一个http响应,遵守client的策略,如重定向,cookies以及auth等.错误经常是由于策略引起的,当err是nil时,resp总会包含一个非nil的resp.body.当调用者读完resp.body之后应该关闭它,如果resp.body没有关闭,则Client底层RoundTripper将无法重用存在的TCP连接去服务接下来的请求,如果resp.body非nil,则必须对其进行关闭.通常来说,经常使用Get,Post,或者PostForm来替代Do.
    func (c \*Client) Get(url string) (resp \*Response, err error)//利用get方法请求指定的url.Get请求指定的页面信息，并返回实体主体。
    func (c \*Client) Head(url string) (resp \*Response, err error)//利用head方法请求指定的url，Head只返回页面的首部。
    func (c \*Client) Post(url string, bodyType string, body io.Reader) (resp \*Response, err error)//利用post方法请求指定的URl,如果body也是一个io.Closer,则在请求之后关闭它
    func (c \*Client) PostForm(url string, data url.Values) (resp \*Response, err error)//利用post方法请求指定的url,利用data的key和value作为请求体.
http中Client客户端的参数设定解析如上面描述所示，Client具有Do，Get，Head，Post以及PostForm等方法。 其中Do方法可以对Request进行一系列的设定，而其他的对request设定较少。如果Client使用默认的Client，则其中的Get，Head，Post以及PostForm方法相当于默认的http.Get,http.Post,http.Head以及http.PostForm函数。举例说明其用法。其中Get，Head，Post以及PostForm用法如下：
    package main

    import (
        "bytes"
        "fmt"
        "io/ioutil"
        "net/http"
        "net/url"
    )

    func main() {

        requestUrl := "http://www.baidu.com"
        // request, err := http.Get(requestUrl)
        // request, err := http.Head(requestUrl)
        postvalue := url.Values{
            "username": {"xiaoming"},
            "address":  {"beijing"},
            "subject":  {"Hello"},
            "from":     {"china"},
        }
        // request, err := http.PostForm(requestUrl, postvalue)

        body := bytes.NewBufferString(postvalue.Encode())
        request, err := http.Post(requestUrl, "text/html", body)  //Post方法
        if err != nil {
            fmt.Println(err)
        }

        defer request.Body.Close()
        fmt.Println(request.StatusCode)
        if request.StatusCode == 200 {
            rb, err := ioutil.ReadAll(request.Body)
            if err != nil {
                fmt.Println(rb)
            }
            fmt.Println(string(rb))
        }

    }

Do方法可以灵活的对request进行配置，然后进行请求。利用http.Client以及http.NewRequest来模拟请求。模拟request中带有cookie的请求。

    package main

    import (
        // "encoding/json"
        "fmt"
        "io/ioutil"
        "net/http"
        "strconv"
    )

    func main() {
        client := &http.Client{}
        request, err := http.NewRequest("GET", "http://www.baidu.com", nil)
        if err != nil {
            fmt.Println(err)
        }
        cookie := &http.Cookie{Name: "userId", Value: strconv.Itoa(12345)}

        request.AddCookie(cookie) //request中添加cookie

        //设置request的header
        request.Header.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
        request.Header.Set("Accept-Charset", "GBK,utf-8;q=0.7,*;q=0.3")
        request.Header.Set("Accept-Encoding", "gzip,deflate,sdch")
        request.Header.Set("Accept-Language", "zh-CN,zh;q=0.8")
        request.Header.Set("Cache-Control", "max-age=0")
        request.Header.Set("Connection", "keep-alive")

        response, err := client.Do(request)
        if err != nil {
            fmt.Println(err)
            return
        }

        defer response.Body.Close()
        fmt.Println(response.StatusCode)
        if response.StatusCode == 200 {
            r, err := ioutil.ReadAll(response.Body)
            if err != nil {
                fmt.Println(err)
            }
            fmt.Println(string(r))
        }
    }

 

type CloseNotifier//该接口被ResponseWriter用来实时检测底层连接是否已经断开.如果客户端已经断开连接,该机制可以在服务端响应之前取消二者之间的长连接.
    type CloseNotifier interface {
            // 当客户端断开连接时,CloseNotifier接受一个通知
            CloseNotify() <-chan bool
    }

 CloseNotifier经常被ResponseWriter用来检测底层连接是否已经断开，举例如下：

    package main

    import (
        "fmt"
        "net/http"
        "time"
    )

    func Test(w http.ResponseWriter, r *http.Request) {
        http.ServeFile(w, r, "test.go")
        var closenotify http.CloseNotifier
        closenotify = w.(http.CloseNotifier)
        select {
        case <-closenotify.CloseNotify():
            fmt.Println("cut")
        case <-time.After(time.Duration(100) * time.Second):
            fmt.Println("timeout")

        }
    }
    func main() {

        http.HandleFunc("/test", Test)
        err := http.ListenAndServe(":9999", nil)
        if err != nil {
            fmt.Println(err)
        }

    }

 

type ConnState //表示客户端连接服务端的状态
    type ConnState int

其中ConnState常用状态变量如下:

    const (
        // StateNew代表一个新的连接，将要立刻发送请求。
        // 连接从这个状态开始，然后转变为StateAlive或StateClosed。
        StateNew ConnState = iota
        // StateActive代表一个已经读取了请求数据1到多个字节的连接。
        // 用于StateAlive的Server.ConnState回调函数在将连接交付给处理器之前被触发，
        // 等到请求被处理完后，Server.ConnState回调函数再次被触发。
        // 在请求被处理后，连接状态改变为StateClosed、StateHijacked或StateIdle。
        StateActive
        // StateIdle代表一个已经处理完了请求、处在闲置状态、等待新请求的连接。
        // 连接状态可以从StateIdle改变为StateActive或StateClosed。
        StateIdle
        // 代表一个被劫持的连接。这是一个终止状态，不会转变为StateClosed。
        StateHijacked
        // StateClosed代表一个关闭的连接。
        // 这是一个终止状态。被劫持的连接不会转变为StateClosed。
        StateClosed
    )

    func (c ConnState) String() string  //状态的字符形式表示
        fmt.Println(http.StateActive)          //active
        fmt.Println(http.StateActive.String()) //active

 

type Cookie//常用SetCooker用来给http的请求或者http的response设置cookie
    type Cookie struct {

            Name       string  //名字
            Value      string  //值
            Path       string   //路径
            Domain     string   
            Expires    time.Time //过期时间
            RawExpires string

            // MaxAge=0 意味着 没有'Max-Age'属性指定.
            // MaxAge<0 意味着 立即删除cookie
            // MaxAge>0 意味着设定了MaxAge属性,并且其单位是秒
            MaxAge   int
            Secure   bool
            HttpOnly bool
            Raw      string
            Unparsed []string // 未解析的属性值对
    }

func (c \*Cookie) String() string//该函数返回cookie的序列化结果。如果只设置了Name和Value字段，序列化结果可用于HTTP请求的Cookie头或者HTTP回复的Set-Cookie头；如果设置了其他字段，序列化结果只能用于HTTP回复的Set-Cookie头。

type CookieJar//在http请求中，CookieJar管理存储和使用cookies.Cookiejar的实现必须被多协程并发使用时是安全的.
    type CookieJar interface {
            // SetCookies 处理从url接收到的cookie,是否存储这个cookies取决于jar的策略和实现
            SetCookies(u *url.URL, cookies []*Cookie)

            // Cookies 返回发送到指定url的cookies
            Cookies(u *url.URL) []*Cookie
    }

type Dir//使用一个局限于指定目录树的本地文件系统实现一个文件系统.一个空目录被当做当前目录"."
    type Dir string

    func (d Dir) Open(name string) (File, error)
type File //File是通过FileSystem的Open方法返回的,并且能够被FileServer实现.该方法与\*os.File行为表现一样.
    type File interface {
            io.Closer
            io.Reader
            Readdir(count int) ([]os.FileInfo, error)
            Seek(offset int64, whence int) (int64, error)
            Stat() (os.FileInfo, error)
    }

type FileSystem//实现了对一系列指定文件的访问,其中文件路径之间通过分隔符进行分割.
    type FileSystem interface {
            Open(name string) (File, error)
    }

 

type Flusher //responsewriters允许http控制器将缓存数据刷新入client.然而如果client是通过http代理连接服务器,这个缓存数据也可能是在整个response结束后才能到达客户端.
    type Flusher interface {
            // Flush将任何缓存数据发送到client
            Flush()
    }

 

type Handler //实现Handler接口的对象可以注册到HTTP服务端，为指定的路径或者子树提供服务。ServeHTTP应该将回复的header和数据写入ResponseWriter接口然后返回。返回意味着该请求已经结束，HTTP服务端可以转移向该连接上的下一个请求。
//如果ServeHTTP崩溃panic,那么ServeHTTP的调用者假定这个panic的影响与活动请求是隔离的,二者互不影响.调用者恢复panic,将stack trace记录到错误日志中,然后挂起这个连接.
    type Handler interface {
            ServeHTTP(ResponseWriter, *Request)
    }

　func FileServer(root FileSystem) Handler // FileServer返回一个使用FileSystem接口提供文件访问服务的HTTP处理器。可以使用httpDir来使用操作系统的FileSystem接口实现。<span style="color:#ff0000">其主要用来实现静态文件的展示。</span>
    func NotFoundHandler() Handler //返回一个简单的请求处理器,该处理器对任何请求都会返回"404 page not found"
    func RedirectHandler(url string, code int) Handler//使用给定的状态码将它接受到的任何请求都重定向到给定的url
    func StripPrefix(prefix string, h Handler) Handler//将请求url.path中移出指定的前缀,然后将省下的请求交给handler h来处理,对于那些不是以指定前缀开始的路径请求,该函数返回一个http 404 not found 的错误.
    func TimeoutHandler(h Handler, dt time.Duration, msg string) Handler //具有超时限制的handler,该函数返回的新Handler调用h中的ServerHTTP来处理每次请求,但是如果一次调用超出时间限制,那么就会返回给请求者一个503服务请求不可达的消息,并且在ResponseWriter返回超时错误.
其中FileServer经常和StripPrefix一起连用，用来实现静态文件展示，举例如下：
    package main

    import (
        "fmt"
        "net/http"
    )

    func main() {
        http.Handle("/test/", http.FileServer(http.Dir("/home/work/"))) ///home/work/test/中必须有内容
        http.Handle("/download/", http.StripPrefix("/download/", http.FileServer(http.Dir("/home/work/"))))
        http.Handle("/tmpfiles/", http.StripPrefix("/tmpfiles/", http.FileServer(http.Dir("/tmp")))) //127.0.0.1:9999/tmpfiles/访问的本地文件/tmp中的内容
        http.ListenAndServe(":9999", nil)
    }

 

type HandlerFunc//HandlerFunc type是一个适配器，通过类型转换我们可以将普通的函数作为HTTP处理器使用。如果f是一个具有适当签名的函数，HandlerFunc(f)通过调用f实现了Handler接口。
    type HandlerFunc func(ResponseWriter, *Request)

    func (f HandlerFunc) ServeHTTP(w ResponseWriter, r \*Request) //ServeHttp调用f(w,r)
type Header//代表在http header中的key-value对
    type Header map[string][]string

    func (h Header) Add(key, value string)//将key,value组成键值对添加到header中
    func (h Header) Del(key string)  //header中删除对应的key-value对
    func (h Header) Get(key string) string //获取指定key的第一个value,如果key没有对应的value,则返回"",为了获取一个key的多个值,用CanonicalHeaderKey来获取标准规范格式.
    func (h Header) Set(key, value string) //给一个key设定为相应的value.
    func (h Header) Write(w io.Writer) error//利用线格式来写header
    func (h Header) WriteSubset(w io.Writer, exclude map\[string\]bool) error//利用线模式写header,如果exclude不为nil,则在exclude中包含的exclude\[key\] == true不被写入.
type Hijacker
    type Hijacker interface {
            // Hijack让调用者接管连接,在调用Hijack()后,http server库将不再对该连接进行处理,对于该连接的管理和关闭责任将由调用者接管.
            Hijack() (net.Conn, *bufio.ReadWriter, error) //conn表示连接对象，bufrw代表该连接的读写缓存对象。
    }

 Hijacker用法如下所示：

    package main

    import (
        "fmt"
        "net/http"
    )

    func HiJack(w http.ResponseWriter, r *http.Request) {
        hj, ok := w.(http.Hijacker)
        if !ok {
            http.Error(w, "webserver doesn't support hijacking", http.StatusInternalServerError)
            return
        }
        conn, bufrw, err := hj.Hijack()
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }
        defer conn.Close()
        bufrw.WriteString("Now we're speaking raw TCP. Say hi: \n")
        bufrw.Flush()

        fmt.Fprintf(bufrw, "You said: %s Bye.\n", "Good")
        bufrw.Flush()
    }
    func main() {
        http.HandleFunc("/hijack", HiJack)
        err := http.ListenAndServe(":9999", nil)
        if err != nil {
            fmt.Println(err)
        }
    }

 

type ProtocolError //http请求解析错误
    func (err \*ProtocolError) Error() string
type Request//代表客户端给服务器端发送的一个请求.该字段在服务器端和客户端使用时区别很大.
    type Request struct {
        // Method指定HTTP方法(GET,POST,PUT等)默认使用GET方法。
        Method string
        // URL在服务端表示被请求的URI(uniform resource identifier,统一资源标识符)，在客户端表示要访问的URL。
        // 在服务端,URL字段是解析请求行的URI（保存在RequestURI字段）得到的,对大多数请求来说,除了Path和RawQuery之外的字段都是空字符串。
        // 在客户端,URL的Host字段指定了要连接的服务器,而Request的Host字段指定要发送的HTTP请求的Host头的值。
        URL *url.URL
        // 接收到的请求的协议版本。client的Request总是使用HTTP/1.1
        Proto      string // "HTTP/1.0"
        ProtoMajor int    // 1
        ProtoMinor int    // 0
        // Header字段用来表示HTTP请求的头域。如果header（多行键值对格式）为：
        //    accept-encoding: gzip, deflate
        //    Accept-Language: en-us
        //    Connection: keep-alive
        // 则：
        //    Header = map[string][]string{
        //        "Accept-Encoding": {"gzip, deflate"},
        //        "Accept-Language": {"en-us"},
        //        "Connection": {"keep-alive"},
        //    }
        // HTTP规定header的键名（头名）是区分大小写的，请求的解析器通过规范化头域的键名来实现这点,即首字母大写,其他字母小写,通过"-"进行分割。
        // 在客户端的请求，可能会被自动添加或重写Header中的特定的头，参见Request.Write方法。
        Header Header
        // Body是请求的主体.对于客户端请求来说,一个nil body意味着没有body,http Client的Transport字段负责调用Body的Close方法。
        // 在服务端，Body字段总是非nil的；但在没有主体时，读取Body会立刻返回EOF.Server会关闭请求主体，而ServeHTTP处理器不需要关闭Body字段。
        Body io.ReadCloser
        // ContentLength记录相关内容的长度.如果为-1,表示长度未知,如果values>=0，表示可以从Body字段读取ContentLength字节数据。
        // 在客户端,如果Body非nil而该字段为0,表示不知道Body的长度。
        ContentLength int64
        // TransferEncoding按从最外到最里的顺序列出传输编码，空切片表示"identity"编码。
        // 本字段一般会被忽略。当发送或接受请求时，会自动添加或移除"chunked"传输编码。
        TransferEncoding []string
        // Close在服务端指定是否在回复请求后关闭连接，在客户端指定是否在发送请求后关闭连接。
        Close bool
        // 对于服务器端请求,Host指定URL指向的主机,可能的格式是host:port.对于客户请求,Host用来重写请求的Host头,如过该字段为""，Request.Write方法会使用URL.Host来进行赋值。
        Host string
        // Form是解析好的表单数据，包括URL字段的query参数和POST或PUT的表单数据.本字段只有在调用ParseForm后才有效。在客户端，会忽略请求中的本字段而使用Body替代。
        Form url.Values
        // PostForm是解析好的POST或PUT的表单数据.本字段只有在调用ParseForm后才有效。在客户端，会忽略请求中的本字段而使用Body替代。
        PostForm url.Values
        // MultipartForm是解析好的多部件表单，包括上传的文件.本字段只有在调用ParseMultipartForm后才有效。http客户端中会忽略MultipartForm并且使用Body替代
        MultipartForm *multipart.Form
        // Trailer指定了在发送请求体之后额外的headers,在服务端，Trailer字段必须初始化为只有trailer键，所有键都对应nil值。
        // （客户端会声明哪些trailer会发送）在处理器从Body读取时，不能使用本字段.在从Body的读取返回EOF后，Trailer字段会被更新完毕并包含非nil的值。
        // （如果客户端发送了这些键值对），此时才可以访问本字段。
        // 在客户端，Trail必须初始化为一个包含将要发送的键值对的映射.(值可以是nil或其终值),ContentLength字段必须是0或-1，以启用"chunked"传输编码发送请求。
        // 在开始发送请求后,Trailer可以在读取请求主体期间被修改，一旦请求主体返回EOF，调用者就不可再修改Trailer。
        // 几乎没有HTTP客户端、服务端或代理支持HTTP trailer。
        Trailer Header
        // RemoteAddr允许HTTP服务器和其他软件记录该请求的来源地址,该字段经常用于日志.本字段不是ReadRequest函数填写的，也没有定义格式。
        // 本包的HTTP服务器会在调用处理器之前设置RemoteAddr为"IP:port"格式的地址.客户端会忽略请求中的RemoteAddr字段。
        RemoteAddr string
        // RequestURI是客户端发送到服务端的请求中未修改的URI(参见RFC 2616,Section 5.1),如果在http请求中设置该字段便会报错.
        RequestURI string
        // TLS字段允许HTTP服务器和其他软件记录接收到该请求的TLS连接的信息,本字段不是ReadRequest函数填写的。
        // 对启用了TLS的连接，本包的HTTP服务器会在调用处理器之前设置TLS字段，否则将设TLS为nil。
        // 客户端会忽略请求中的TLS字段。
        TLS *tls.ConnectionState
    }

     func NewRequest(method, urlStr string, body io.Reader) (\*Request, error) //利用指定的method,url以及可选的body返回一个新的请求.如果body参数实现了io.Closer接口，Request返回值的Body 字段会被设置为body，并会被Client类型的Do、Post和PostForm方法以及Transport.RoundTrip方法关闭。

    func ReadRequest(b \*bufio.Reader) (req \*Request, err error)//从b中读取和解析一个请求.
    func (r \*Request) AddCookie(c \*Cookie) //给request添加cookie,AddCookie向请求中添加一个cookie.按照RFC 6265 section 5.4的规则,AddCookie不会添加超过一个Cookie头字段.这表示所有的cookie都写在同一行,用分号分隔（cookie内部用逗号分隔属性）
    func (r \*Request) Cookie(name string) (\*Cookie, error)//返回request中指定名name的cookie，如果没有发现，返回ErrNoCookie
    func (r \*Request) Cookies() \[\]\*Cookie//返回该请求的所有cookies
    func (r \*Request) SetBasicAuth(username, password string)//利用提供的用户名和密码给http基本权限提供具有一定权限的header。当使用http基本授权时，用户名和密码是不加密的
    func (r \*Request) UserAgent() string//如果在request中发送，该函数返回客户端的user-Agent
　举例说明其用法
　
    package main

    import (
        "fmt"
        "io/ioutil"
        "net/http"
    )

    func Test() {
        req, err := http.NewRequest("GET", "http://www.baidu.com", nil)
        if err != nil {
            fmt.Println(err)
            return
        }

        req.SetBasicAuth("test", "123456")
        fmt.Println(req.Proto)
        cookie := &http.Cookie{
            Name:  "test",
            Value: "12",
        }
        req.AddCookie(cookie)                     //添加cookie
        fmt.Println(req.Cookie("test"))           //获取cookie
        fmt.Println(req.Cookies())                //获取cookies
        req.Header.Set("User-Agent", "useragent") //设定ua
        fmt.Println(req.UserAgent())

        client := &http.Client{}
        resp, err := client.Do(req)
        if err != nil {
            fmt.Println(err)
            return
        }
        defer resp.Body.Close()
        if resp.StatusCode == 200 {
            content, _ := ioutil.ReadAll(resp.Body)
            fmt.Println(string(content))
        }

    }
    func main() {
        Test()
    }

 

    func (r \*Request) FormFile(key string) (multipart.File, \*multipart.FileHeader, error)//对于指定格式的key，FormFile返回符合条件的第一个文件，如果有必要的话，该函数会调用ParseMultipartForm和ParseForm。
    func (r \*Request) FormValue(key string) string//返回key获取的队列中第一个值。在查询过程中post和put中的主题参数优先级高于url中的value。为了访问相同key的多个值，调用ParseForm然后直接检查RequestForm。
    func (r \*Request) MultipartReader() (\*multipart.Reader, error)//如果这是一个有多部分组成的post请求，该函数将会返回一个MIME 多部分reader，否则的话将会返回一个nil和error。使用本函数代替ParseMultipartForm可以将请求body当做流stream来处理。
    func (r \*Request) ParseForm() error//解析URL中的查询字符串，并将解析结果更新到r.Form字段。对于POST或PUT请求，ParseForm还会将body当作表单解析，并将结果既更新到r.PostForm也更新到r.Form。解析结果中，POST或PUT请求主体要优先于URL查询字符串（同名变量，主体的值在查询字符串的值前面）。如果请求的主体的大小没有被MaxBytesReader函数设定限制，其大小默认限制为开头10MB。ParseMultipartForm会自动调用ParseForm。重复调用本方法是无意义的。
    func (r \*Request) ParseMultipartForm(maxMemory int64) error //ParseMultipartForm将请求的主体作为multipart/form-data解析。请求的整个主体都会被解析，得到的文件记录最多 maxMemery字节保存在内存，其余部分保存在硬盘的temp文件里。如果必要，ParseMultipartForm会自行调用 ParseForm。重复调用本方法是无意义的。
    func (r \*Request) PostFormValue(key string) string//返回post或者put请求body指定元素的第一个值，其中url中的参数被忽略。
    func (r \*Request) ProtoAtLeast(major, minor int) bool//检测在request中使用的http协议是否至少是major.minor
    func (r \*Request) Referer() string//如果request中有refer，那么refer返回相应的url。Referer在request中是拼错的，这个错误从http初期就已经存在了。该值也可以从Headermap中利用Header\["Referer"\]获取；在使用过程中利用Referer这个方法而不是map的形式的好处是在编译过程中可以检查方法的错误，而无法检查map中key的错误。
    func (r \*Request) Write(w io.Writer) error//Write方法以有线格式将HTTP/1.1请求写入w（用于将请求写入下层TCPConn等）。本方法会考虑请求的如下字段：Host URL Method (defaults to "GET") Header ContentLength TransferEncoding Body
　如果存在Body，ContentLength字段&lt;= 0且TransferEncoding字段未显式设置为\["identity"\]，Write方法会显式添加"Transfer-Encoding: chunked"到请求的头域。Body字段会在发送完请求后关闭。

    func (r \*Request) WriteProxy(w io.Writer) error//该函数与Write方法类似，但是该方法写的request是按照http代理的格式去写。尤其是，按照RFC 2616 Section 5.1.2，WriteProxy会使用绝对URI（包括协议和主机名）来初始化请求的第1行（Request-URI行）。无论何种情况，WriteProxy都会使用r.Host或r.URL.Host设置Host头。
type Response//指对于一个http请求的响应response
    type Response struct {
        Status     string // 例如"200 OK"
        StatusCode int    // 例如200
        Proto      string // 例如"HTTP/1.0"
        ProtoMajor int    // 主协议号：例如1
        ProtoMinor int    // 副协议号：例如0
        // Header保管header的key values，如果response中有多个header中具有相同的key，那么Header中保存为该键对应用逗号分隔串联起来的这些头的值// 被本结构体中的其他字段复制保管的头（如ContentLength）会从Header中删掉。Header中的键都是规范化的，参见CanonicalHeaderKey函数
        Header Header
        // Body代表response的主体。http的client和Transport确保这个body永远非nil，即使response没有body或body长度为0。调用者也需要关闭这个body// 如果服务端采用"chunked"传输编码发送的回复，Body字段会自动进行解码。
        Body io.ReadCloser
        // ContentLength记录相关内容的长度。
        // 其值为-1表示长度未知（采用chunked传输编码）
        // 除非对应的Request.Method是"HEAD"，其值>=0表示可以从Body读取的字节数
        ContentLength int64
        // TransferEncoding按从最外到最里的顺序列出传输编码，空切片表示"identity"编码。
        TransferEncoding []string
        // Close记录头域是否指定应在读取完主体后关闭连接。（即Connection头）
        // 该值是给客户端的建议，Response.Write方法的ReadResponse函数都不会关闭连接。
        Close bool
        // Trailer字段保存和头域相同格式的trailer键值对，和Header字段相同类型
        Trailer Header
        // Request是用来获取此回复的请求，Request的Body字段是nil（因为已经被用掉了）这个字段是被Client类型发出请求并获得回复后填充的
        Request *Request
        // TLS包含接收到该回复的TLS连接的信息。 对未加密的回复，本字段为nil。返回的指针是被（同一TLS连接接收到的）回复共享的，不应被修改。
        TLS *tls.ConnectionState
    }

 

    func Get(url string) (resp \*Response, err error)//利用GET方法对一个指定的URL进行请求，如果response是如下重定向中的一个代码，则Get之后将会调用重定向内容，最多10次重定向。
    301 (永久重定向，告诉客户端以后应该从新地址访问)
    302 (暂时性重定向，作为HTTP1.0的标准，以前叫做Moved Temporarily，现在叫做Found。现在使用只是为了兼容性处理，包括PHP的默认Location重定向用到也是302)，注：303和307其实是对302的细化。
    303 (对于Post请求，它表示请求已经被处理，客户端可以接着使用GET方法去请求Location里的URl)
    307 (临时重定向，对于Post请求，表示请求还没有被处理，客户端应该向Location里的URL重新发起Post请求)

//如果有太多次重定向或者有一个http协议错误将会导致错误。当err为nil时，resp总是包含一个非nil的resp.body，Get是对DefaultClient.Get的一个包装。

    func Head(url string) (resp \*Response, err error)//该函数功能见net中Head方法功能。该方法与默认的defaultClient中Head方法一致。
    func Post(url string, bodyType string, body io.Reader) (resp \*Response, err error)//该方法与默认的defaultClient中Post方法一致。
    func PostForm(url string, data url.Values) (resp \*Response, err error)//该方法与默认的defaultClient中PostForm方法一致。
    func ReadResponse(r \*bufio.Reader, req \*Request) (\*Response, error)//ReadResponse从r读取并返回一个HTTP 回复。req参数是可选的，指定该回复对应的请求（即是对该请求的回复）。如果是nil，将假设请 求是GET请求。客户端必须在结束resp.Body的读取后关闭它。读取完毕并关闭后，客户端可以检查resp.Trailer字段获取回复的 trailer的键值对。（本函数主要用在客户端从下层获取回复）
    func (r \*Response) Cookies() \[\]\*Cookie//解析cookie并返回在header中利用set-Cookie设定的cookie值。
    func (r \*Response) Location() (\*url.URL, error)//返回response中Location的header值的url。如果该值存在的话，则对于请求问题可以解决相对重定向的问题，如果该值为nil，则返回ErrNOLocation的错误。
    func (r \*Response) ProtoAtLeast(major, minor int) bool//判定在response中使用的http协议是否至少是major.minor的形式。
    func (r \*Response) Write(w io.Writer) error//将response中信息按照线性格式写入w中。
type ResponseWriter//该接口被http handler用来构建一个http response
    type ResponseWriter interface {
        // Header返回一个Header类型值，该值会被WriteHeader方法发送.在调用WriteHeader或Write方法后再改变header值是不起作用的。
        Header() Header
        // WriteHeader该方法发送HTTP回复的头域和状态码。如果没有被显式调用，第一次调用Write时会触发隐式调用WriteHeader(http.StatusOK)
        // 因此，显示调用WriterHeader主要用于发送错误状态码。
        WriteHeader(int)
        // Write向连接中写入数据，该数据作为HTTP response的一部分。如果被调用时还没有调用WriteHeader，本方法会先调用WriteHeader(http.StatusOK)
        // 如果Header中没有"Content-Type"键，本方法会使用包函数DetectContentType检查数据的前512字节，将返回值作为该键的值。
        Write([]byte) (int, error)
    }

 

type RoundTripper//该函数是一个执行简单http事务的接口，该接口在被多协程并发使用时必须是安全的。
    type RoundTripper interface {
        // RoundTrip执行单次HTTP事务，返回request的response，RoundTrip不应试图解析该回复。
        // 尤其要注意，只要RoundTrip获得了一个回复，不管该回复的HTTP状态码如何，它必须将返回值err设置为nil。
        // 非nil的返回值err应该留给获取回复失败的情况。类似的，RoundTrip不能试图管理高层协议，如重定向、认证或者cookie。
        // RoundTrip除了从请求的主体读取并关闭主体之外，不能够对请求做任何修改，包括（请求的）错误。
        // RoundTrip函数接收的请求的URL和Header字段必须保证是初始化了的。
        RoundTrip(*Request) (*Response, error)
    }

    func NewFileTransport(fs FileSystem) RoundTripper //该函数返回一个RoundTripper接口，服务指定的文件系统。 返回的RoundTripper接口会忽略接收的请求中的URL主机及其他绝大多数属性。该函数的典型应用是给Transport类型的值注册"file"协议。如下所示：
    t := &http.Transport{}
    t.RegisterProtocol("file", http.NewFileTransport(http.Dir("/")))
    c := &http.Client{Transport: t}
    res, err := c.Get("file:///etc/passwd")
    ...

type ServeMux //该函数是一个http请求多路复用器，它将每一个请求的URL和一个注册模式的列表进行匹配，然后调用和URL最匹配的模式的处理器进行后续操作。模式是固定的、由根开始的路径，如"/favicon.ico"，或由根开始的子树，如"/images/" （注意结尾的斜杠）。较长的模式优先于较短的模式，因此如果模式"/images/"和"/images/thumbnails/"都注册了处理器，后一 个处理器会用于路径以"/images/thumbnails/"开始的请求，前一个处理器会接收到其余的路径在"/images/"子树下的请求。
注意，因为以斜杠结尾的模式代表一个由根开始的子树，模式"/"会匹配所有的未被其他注册的模式匹配的路径，而不仅仅是路径"/"。

模式也能（可选地）以主机名开始，表示只匹配该主机上的路径。指定主机的模式优先于一般的模式，因此一个注册了两个模式"/codesearch"和"codesearch.google.com/"的处理器不会接管目标为"http://www.google.com/"的请求。

ServeMux还会负责对URL路径的过滤，将任何路径中包含"."或".."元素的请求重定向到等价的没有这两种元素的URL。（参见path.Clean函数）

    func NewServeMux() \*ServeMux //初始化一个新的ServeMux
    func (mux \*ServeMux) Handle(pattern string, handler Handler) //将handler注册为指定的模式，如果该模式已经有了handler，则会出错panic。
　 func (mux \*ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, \*Request))//将handler注册为指定的模式
    func (mux \*ServeMux) Handler(r \*Request) (h Handler, pattern string) //根据指定的r.Method,r.Host以及r.RUL.Path返回一个用来处理给定请求的handler。该函数总是返回一个非nil的 handler，如果path不是一个规范格式，则handler会重定向到其规范path。Handler总是返回匹配该请求的的已注册模式；在内建重 定向处理器的情况下，pattern会在重定向后进行匹配。如果没有已注册模式可以应用于该请求，本方法将返回一个内建的"404 page not found"处理器和一个空字符串模式。
    func (mux \*ServeMux) ServeHTTP(w ResponseWriter, r \*Request)  //该函数用于将最接近请求url模式的handler分配给指定的请求。
举例说明servemux的用法。
    package main

    import (
        "fmt"
        "net/http"
    )

    func Test(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintln(w, "just for test!")
    }
    func main() {
        mux := http.NewServeMux()
        mux.Handle("/", http.FileServer(http.Dir("/home")))
        mux.HandleFunc("/test", Test)
        err := http.ListenAndServe(":9999", mux)
        if err != nil {
            fmt.Println(err)
        }
    }

type Server //该结构体定义一些用来运行HTTP Server的参数，如果Server默认为0的话，那么这也是一个有效的配置。
    type Server struct {
        Addr           string        // 监听的TCP地址，如果为空字符串会使用":http"
        Handler        Handler       // 调用的处理器，如为nil会调用http.DefaultServeMux
        ReadTimeout    time.Duration // 请求的读取操作在超时前的最大持续时间
        WriteTimeout   time.Duration // 回复的写入操作在超时前的最大持续时间
        MaxHeaderBytes int           // 请求的头域最大长度，如为0则用DefaultMaxHeaderBytes
        TLSConfig      *tls.Config   // 可选的TLS配置，用于ListenAndServeTLS方法
        // TLSNextProto（可选地）指定一个函数来在一个NPN型协议升级出现时接管TLS连接的所有权。
        // 映射的键为商谈的协议名；映射的值为函数，该函数的Handler参数应处理HTTP请求，
        // 并且初始化Handler.ServeHTTP的*Request参数的TLS和RemoteAddr字段（如果未设置）。
        // 连接在函数返回时会自动关闭。
        TLSNextProto map[string]func(*Server, *tls.Conn, Handler)
        // ConnState字段指定一个可选的回调函数，该函数会在一个与客户端的连接改变状态时被调用。
        // 参见ConnState类型和相关常数获取细节。
        ConnState func(net.Conn, ConnState)
        // ErrorLog指定一个可选的日志记录器，用于记录接收连接时的错误和处理器不正常的行为。
        // 如果本字段为nil，日志会通过log包的标准日志记录器写入os.Stderr。
        ErrorLog *log.Logger
        // 内含隐藏或非导出字段
    }

     func (srv \*Server) ListenAndServe() error//监听TCP网络地址srv.Addr然后调用Serve来处理接下来连接的请求。如果srv.Addr是空的话，则使用“:http”。

    func (srv \*Server) ListenAndServeTLS(certFile, keyFile string) error//ListenAndServeTLS监听srv.Addr确定的TCP地址，并且会调用Serve方法处理接收到的连接。必须提供证书文件和对应的私钥文 件。如果证书是由权威机构签发的，certFile参数必须是顺序串联的服务端证书和CA证书。如果srv.Addr为空字符串，会使 用":https"。
    func (srv \*Server) Serve(l net.Listener) error//接受Listener l的连接，创建一个新的服务协程。该服务协程读取请求然后调用srv.Handler来应答。实际上就是实现了对某个端口进行监听，然后创建相应的连接。
    func (s \*Server) SetKeepAlivesEnabled(v bool)//该函数控制是否http的keep-alives能够使用，默认情况下，keep-alives总是可用的。只有资源非常紧张的环境或者服务端在关闭进程中时，才应该关闭该功能。
举例说明Server的用法。
    package main

    import (
        "fmt"
        "net/http"
    )

    func Test(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintln(w, "just for test!")
    }
    func main() {
        newserver := http.Server{
            Addr:         ":9992",
            ReadTimeout:  0,
            WriteTimeout: 0,
        }

        mux := http.NewServeMux()
        mux.Handle("/", http.FileServer(http.Dir("/home")))
        mux.HandleFunc("/test", Test)

        newserver.Handler = mux
        err := newserver.ListenAndServe()
        if err != nil {
            fmt.Println(err)
        }
        fmt.Println(err)
        // err := http.ListenAndServe(":9999", mux)
        // if err != nil {
        //     fmt.Println(err)
        // }
    }

 

type Transport  //该结构体实现了RoundTripper接口，支持HTTP，HTTPS以及HTTP代理，TranSport也能缓存连接供将来使用。
    type Transport struct {
        // Proxy指定一个对给定请求返回代理的函数。如果该函数返回了非nil的错误值，请求的执行就会中断并返回该错误。
        // 如果Proxy为nil或返回nil的*URL值，将不使用代理。
        Proxy func(*Request) (*url.URL, error)
        // Dial指定创建未加密TCP连接的dial函数。如果Dial为nil，会使用net.Dial。
        Dial func(network, addr string) (net.Conn, error)
    　　// DialTls利用一个可选的dial函数来为非代理的https请求创建一个TLS连接。如果DialTLS为nil的话，那么使用Dial和TLSClientConfig。
    　　//如果DialTLS被设定，那么Dial钩子不被用于HTTPS请求和TLSClientConfig并且TLSHandshakeTimeout被忽略。返回的net.conn默认已经经过了TLS握手协议。
    　　DialTLS func(network, addr string) (net.Conn, error)
        // TLSClientConfig指定用于tls.Client的TLS配置信息。如果该字段为nil，会使用默认的配置信息。
        TLSClientConfig *tls.Config
        // TLSHandshakeTimeout指定等待TLS握手完成的最长时间。零值表示不设置超时。
        TLSHandshakeTimeout time.Duration
        // 如果DisableKeepAlives为真，不同HTTP请求之间TCP连接的重用将被阻止。
        DisableKeepAlives bool
        // 如果DisableCompression为真，会禁止Transport在请求中没有Accept-Encoding头时，
        // 主动添加"Accept-Encoding: gzip"头，以获取压缩数据。
        // 如果Transport自己请求gzip并得到了压缩后的回复，它会主动解压缩回复的主体。
        // 但如果用户显式的请求gzip压缩数据，Transport是不会主动解压缩的。
        DisableCompression bool
        // 如果MaxIdleConnsPerHost不为0，会控制每个主机下的最大闲置连接数目。
        // 如果MaxIdleConnsPerHost为0，会使用DefaultMaxIdleConnsPerHost。
        MaxIdleConnsPerHost int
        // ResponseHeaderTimeout指定在发送完请求（包括其可能的主体）之后，
        // 等待接收服务端的回复的头域的最大时间。零值表示不设置超时。
        // 该时间不包括读取回复主体的时间。
        ResponseHeaderTimeout time.Duration
    }

    func (t \*Transport) CancelRequest(req \*Request)//通过关闭连接来取消传送中的请求。
    func (t \*Transport) CloseIdleConnections()//关闭所有之前请求但目前处于空闲状态的连接。该方法并不中断任何正在使用的连接。
    func (t \*Transport) RegisterProtocol(scheme string, rt RoundTripper)//RegisterProtocol注册一个新的名为scheme的协议。t会将使用scheme协议的请求转交给rt。rt有责任模拟HTTP请求的语义。RegisterProtocol可以被其他包用于提供"ftp"或"file"等协议的实现。
    func (t \*Transport) RoundTrip(req \*Request) (resp \*Response, err error)//该函数实现了RoundTripper接口，对于高层http客户端支持，例如处理cookies以及重定向，查看Get，Post以及Client类型。
 
```
参考：<http://golang.org/pkg/net/http/>
