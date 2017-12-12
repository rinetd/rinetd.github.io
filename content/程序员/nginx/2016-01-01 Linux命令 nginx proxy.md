---
title: Linux命令 Nginx proxy
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
[【译】Ngnix实现一个缓存和缩略处理的反向代理服务器 - QueenKing - SegmentFault](https://segmentfault.com/a/1190000004604380)
[Linux 运维 » Nginx 代理 配置详解](http://www.mylinuxer.com/?p=281)

proxy_rediect 用于修改[nginx代理服务器] 发给->[浏览器客户端] Header的 location 和 Refresh

proxy_set_header 用于添加[nginx代理服务器] 发给-> [web应用服务器] 请求数据时Header信息,通过添加Header头信息Host，来指定请求的域名，后端web服务器才能识别该反向代理访问请求由哪个虚拟主机来处理。


## Nginx配置proxy_pass转发的/路径问题

在nginx中配置proxy_pass时，如果是按照^~匹配路径时,要注意proxy_pass后的url最后的/
1. 当加上了/，相当于是绝对根路径，则nginx不会把location中匹配的路径部分代理走;
2. 如果没有/，则会把匹配的路径部分也给代理走。

location ^~ /static_js/
{
proxy_cache js_cache;
proxy_set_header Host js.test.com;
proxy_pass http://js.test.com/;
}

如上面的配置，如果请求的url是http://127.0.0.1/static_js/test.html
会被代理成http://js.test.com/test.html
当然，我们可以用如下的rewrite来实现/的功能

location ^~ /static_js/
{
proxy_cache js_cache;
proxy_set_header Host js.test.com;
rewrite /static_js/(.+)$ /$1 break;
proxy_pass http://js.test.com;

}

而如果这么配置

location ^~ /static_js/
{
proxy_cache js_cache;
proxy_set_header Host js.test.com;
proxy_pass http://js.test.com;
}

则会被代理到http://js.test.com/static_js/test.htm


# nginx proxy_pass 后面的url 加与不加/的区别

注：

1. [是不是带 / ] 是在proxy_pass 指令后面,而不是 location后面，location后面的/对proxy_pass没有影响
2. proxy_pass 后是否有 / 决定代理结果 url是否加上匹配的 location

在nginx中配置proxy_pass时，当在后面的url加上了/，相当于是绝对根路径，则nginx向proxy请求时不会把location中匹配的路径部分代理走;，但是浏览器url中是带location路径的
如果没有/，则会把匹配的路径部分也给代理走。

下面四种情况分别用GET  进行访问。

浏览器请求url都是一致的: http://linyibr.com/proxy/index.html
```
# location后面的/对proxy_pass没有影响 只决定匹配的是文件还是目录
location  /proxy {
      proxy_pass http://127.0.0.1:81;
      #代理url:   http://127.0.0.1:81/proxy/index.html

      # 技巧：在配置子目录做为子站点的时候增加'/'非常好用
      proxy_pass http://127.0.0.1:81/;
      #代理url:   http://127.0.0.1:81/index.html

      proxy_pass http://127.0.0.1:81/ftlynx;
      #代理url:   http://127.0.0.1:81/ftlynxindex.html

      proxy_pass http://127.0.0.1:81/ftlynx/;
      #代理url:   http://127.0.0.1:81/ftlynx/index.html

}
```

上面的结果都是本人结合日志文件测试过的。从结果可以看出，应该说分为两种情况才正确。即http://127.0.0.1:81 (上面的第二种) 这种和 http://127.0.0.1:81/…. （上面的第1，3，4种） 这种。
在以上配置中，192.168.1.202没有“/”，而192.168.1.203有一个“/”,但是由于location 配置的URI为/server/，所以，访问到192.168.1.202正常为/server/，访问192.168.1.203的时候，则直接变成了 / ,也就是说 访问的时候变成了：192.168.1.202/server/index.html     192.168.1.203/index.html

以上就是 "/" 的区别！


1.16
## proxy_rediect 用于修改被代理服务器返回 Header的 location 和 Refresh
proxy_redirect会将应用服务器返回[nginx代理服务器]的响应头中的location字段进行修改后返回给客户端

proxy_redirect http://localhost:8000/two/ http://frontend/one/;
将Location字段重写为http://frontend/one/some/uri/。
在代替的字段中可以不写服务器名：

proxy_redirect http://localhost:8000/two/ /;
这样就使用服务器的基本名称和端口，即使它来自非80端口。
如果使用“default”参数，将根据location和proxy_pass参数的设置来决定。
例如下列两个配置等效：

location /one/ {
    proxy_pass       http://upstream:port/two/;
    proxy_redirect   default;

    #proxy_redirect   http://upstream:port/two/   /one/;
    }
在指令中可以使用一些变量：

proxy_redirect   http://localhost:8000/    http://$host:$server_port/;
这个指令有时可以重复：

proxy_redirect   default;  
proxy_redirect   http://localhost:8000/    /;  
proxy_redirect   ;  /;

利用这个指令可以为被代理服务器发出的相对重定向增加主机名：


用于修改被代理服务器返回的响应头中的location头域和“Rsfresh”头域，与proxy_pass配合使用，该指令可以把代理服务器返回的地址信息更改为需要的地址信息
语法如下三种：
            (1)`proxy_redirect redirect replacement`;
               redirect 匹配location头域值得字符串
               replacement 用于替换redirect 变量内容的字符串
             eg:
                假如被代理服务器返回的响应头中“location”头域为：
                 Location:http://localhost:8081/proxy/some/uri/
                设置为：
                 proxy_redirect http://localhost:8081/proxy/ http://mylinuxer/frontend/;
                Nginx服务器会将Location头域信息更改为
                 Location:http://mylinuxer/frintend//some/uri/  
            (2)`proxy_redirect default`;
             eg:
                location块的uri变量作为replacement,并使用proxy_pass变量作为redirect
                location /server/
                  {
                     proxy_pass http://proxyserver/source/;
                     proxy_redirect default;
                  }
            (3)`proxy_redirect off`;
              使用此方法，可将当前作用域下面的所有的proxy_redirect指令配置全部设置为无效

1.6
proxy_set_header field value;
更改nginx服务器接收到的客户端请求的请求头信息，然后将心的请求头发送给被代理的服务器
field  要更改的信息所在的头域
value  更改的值，支持使用文本、变量或者变量的组合
默认情况下为以下设置：
   proxy_set_header Host $proxy_host;  
   proxy_set_header Connection close;

proxy_set_header Host $http_host;

这句话把我和 nginx 通信的 HTTP 头原封不动的发给了 目的服务器
我以为这句话的意思是： Nginx 向目的服务器请求的时候替换成目的服务器的 Host ，实际没有
真正的做法是 `proxy_set_header Host $proxy_host;`
proxy_set_header Host       $host:$proxy_port;

1.2
proxy_hide_header field;
设置nginx服务器在发送HTTP相应时，隐藏一些头域信息，field为需要隐藏的头域

1.3
proxy_pass_header field;
设置nginx服务器在发送响应报文时候，报文中不包含"Date" "Server" "X-Accel"等来自被代理服务器的头域信息，field为需要发送的头域.

1.4
proxy_pass_request_body on|off;
设置是否将客户端请求的请求体发送给代理服务器，默认设置为开启on

1.5
proxy_pass_request_headers on|off;
设置是否将客户端请求的请求头发送给代理服务器，默认设置为开启on

1.7
proxy_set_body value;
更改nginx服务器接收到的客户端请求的请求体信息，value为更改的信息

1.8
proxy_bind address;
如果我们希望代理连接由指定主机处理，可修改此配置，address为IP地址

1.9
proxy_connect_timeout time;
配置nginx服务器与后端被代理服务器尝试建立连接的超时时间，默认为60s

1.10
proxy_read_timeout time;
配置nginx服务器向后端被代理服务器发出read请求后，等待响应的超时时间，默认为60s

1.11
proxy_send_timeout time;
配置nginx服务器向后端被代理服务器发出write请求后，等待响应的超时时间，默认为60s

1.12
proxy_http_version 1.0|1.1
设置nginx服务器提供代理服务的HTTP协议版本，默认为1.0,1.1版本支持upsteam服务器组设置中的keepalive指令

1.13
proxy_method method;
设置Nginx服务器请求被代理服务器时使用的请求方法，method可设置为POST和GET，不加引号，设置了该指令，客户端的请求方法将被忽略

1.14
proxy_ignore_client_abort on|off;
设置在客户端终端网络请求时，Nginx服务器是否中断对被代理服务器的请求，默认为off中断

1.15
proxy_ignore_headers field ...;
设置一些HTTP的响应头中的头域，field为要设置的HTTP响应头的头域，如"X-Accel-Redirect"、"X-Accel-Expires"、"Expires"、"Cache-Control"、"Set-Cookie"等


1.17
proxy_intercept_errors on|off;
配置一个状态是否开启，在开启时，如果被代理的服务器返回的HTTP状态代码为400或者大于400，则nginx服务器使用自己预定义的错误页（使用error_page指令），如果是关闭状态，则直接将被代理服务器返回的HTTP状态返回给客户端

1.18
proxy_headers_hash_max_size size;
配置存放http报文头的哈希表的容量，默认为512个字符，siez为字符大小

1.19
proxy_headers_hash_bucket_size size;
设置nginx服务器申请存放http报文头的哈希表容量的单位大小，默认为64个字符

1.20
proxy_next_upstream status ....；
可以使用该指令配置在服务器(组)发生哪些异常情况时，将请求顺序交个下一个服务器处理
status设置服务器返回状态，可以是一个或多个
error 连接错误
timeout 超时
invalid_header响应头为空或无效
http_500|http_502|http_504|http_404，被代理服务器返回500 502 504 404状态代码
off 无法将请求发送给被代理服务器

1.21
proxy_ssl_session_reuse on|off;
配置是否基于SSL安全协议的会话连接(https://)，默认为开启状态





URI 在于I(Identifier)是统一资源标示符，可以唯一标识一个资源。URL在于Locater，一般来说（URL）统一资源定位符，可以提供找到该资源的路径，比如http://www.zhihu.com/question/21950864，但URL又是URI，因为它可以标识一个资源，所以URL又是URI的子集。
举个是个URI但不是URL的例子：urn:isbn:0-486-27557-4，这个是一本书的isbn，可以唯一标识这本书，更确切说这个是URN。总的来说，locators are also identifiers, so every URL is also a URI, but there are URIs which are not URLs.

#对 "/" 启用反向代理
location / {
proxy_pass http://127.0.0.1:88;
proxy_redirect off;
proxy_set_header X-Real-IP $remote_addr;
#后端的Web服务器可以通过X-Forwarded-For获取用户真实IP
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

#以下是一些反向代理的配置，可选。
proxy_set_header Host $host;
client_max_body_size 10m; #允许客户端请求的最大单文件字节数
client_body_buffer_size 128k; #缓冲区代理缓冲用户端请求的最大字节数，
proxy_connect_timeout 90; #nginx跟后端服务器连接超时时间(代理连接超时)
proxy_send_timeout 90; #后端服务器数据回传时间(代理发送超时)
proxy_read_timeout 90; #连接成功后，后端服务器响应时间(代理接收超时)
proxy_buffer_size 4k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
proxy_buffers 4 32k; #proxy_buffers缓冲区，网页平均在32k以下的设置
proxy_busy_buffers_size 64k; #高负荷下缓冲大小（proxy_buffers*2）
proxy_temp_file_write_size 64k;
#设定缓存文件夹大小，大于这个值，将从upstream服务器传
}

proxy.conf配置文件：
proxy_redirect off;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
client_max_body_size 50m; # 允许客户端请求的最大单个文件字节数
client_body_buffer_size 256k; # 缓冲区代理缓冲客户端请求的最大字节数
proxy_connect_timeout 30; # 连接后端服务器超时时间
proxy_send_timeout 30; # 后端服务器发送数据超时时间,连接以及建立
proxy_read_timeout 60; # 后端服务器响应请求超时时间,从开始发送到接受完毕
proxy_buffer_size 4k; # 代理请求缓存区大小
proxy_buffers 4 32k;
proxy_busy_buffers_size 64k; #系统繁忙时可申请的proxy_buffers大小
proxy_temp_file_write_size 64k; #proxy缓存临时文件的大小
proxy_next_upstream error timeout invalid_header http_500 http_503 http_404;
# 故障转移
proxy_max_temp_file_size 128m;
proxy_set_header指令用于在向反向代理的后端web服务器发起请求时添加指定Header头信息，当后端web服务器上有多个基于域名的虚拟主机时，要通过添加Header头信息Host，来指定请求的域名，这样后端web服务器才能识别该反向代理访问请求由哪个虚拟主机来处理。



技巧：在配置子目录做为子站点的时候增加'/'非常好用


## nginx大文件下载优化

默认情况下proxy_max_temp_file_size值为1024MB,也就是说后端服务器的文件不大于1G都可以缓存到nginx代理硬盘中，如果超过1G，那么文件不缓存，而是直接中转发送给客户端.如果proxy_max_temp_file_size设置为0，表示不使用临时缓存。

在大文件的环境下，如果想启用临时缓存，那么可以修改配置，值改成你想要的。
修改nginx配置
```
location /
 {
 ...
 proxy_max_temp_file_size 2048m;
 ...
 }
 ```
# nginx proxy buffer 解释

遇到一例 nginx buffer 设置太小，如果 URL 比较长导致 504 错误的故障。可以看看这篇网站502与504错误分析。

下面总结下 nginx buffer 设置：
```
proxy_buffer_size 4k;
proxy_buffering on;
proxy_buffers 4 4k;
proxy_busy_buffers_size 8k;
proxy_max_temp_file_size 1024m;
```

首先，这些参数都是针对每一个http request ，不是全局的。
proxy_buffering

proxy_buffering 开启的时候，proxy_buffers 和proxy_busy_buffers_size 才会起作用，无论proxy_buffering 是否开启，proxy_buffer_size 都起作用。
proxy_buffer_size

proxy_buffer_size 用来接受后端服务器 response 的第一部分，小的response header 通常位于这部分响应内容里边。默认proxy_buffer_size 被设置成 proxy_buffers 里一个buffer 的大小，当然可以设置更小些。

① 如果 proxy_buffers 关闭

Nginx不会尝试获取到后端服务器所有响应数据之后才返回给客户端，Nginx 会尽快把数据传给客户端，在数据传完之前，Nginx 接收到的最大缓存大小不能超过 proxy_buffer_size 。

② 如果 proxy_buffers 打开

Nginx将会尽可能的读取后端服务器的数据到buffer，直到proxy_buffers设置的所有buffer们被写满或者数据被读取完(EOF)，此时Nginx开始向客户端传输数据，会同时传输这一整串buffer们。如果数据很大的话，Nginx会接收并把他们写入到temp_file里去，大小由proxy_max_temp_file_size 控制。「当数据没有完全读完的时候」，Nginx同时向客户端传送的buffer 大小 不能超过 proxy_busy_buffers_size 「此句可能理解有误」。
proxy_busy_buffers_size 的官方解释：

When buffering of responses from the proxied server is enabled, limits the total sizeof buffers that can be busy sending a response to the client while the response is not yet fully read. In the meantime, the rest of the buffers can be used for reading the response and, if needed, buffering part of the response to a temporary file. By default, size is limited by the size of two buffers set by the proxy_buffer_size andproxy_buffers directives.

另外，proxy_buffering 为off 的时候，Nginx 的cache 无效「即 proxy_cache 那一坨命令设置的cache 无效 」 。
