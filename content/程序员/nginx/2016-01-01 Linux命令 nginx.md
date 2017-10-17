---
title: Linux命令 Nginx
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
[Nginx怎样部署SSL证书](http://www.2zzt.com/dome.php?id=7591)
[nginx运维与架构](http://www.nginx.cn/)
[nginx服务器安装及配置文件详解](https://segmentfault.com/a/1190000002797601)
[Nginx 配置文件详解](http://my.oschina.net/duxuefeng/blog/34880)
[Nginx RTMP 模块 nginx-rtmp-module 指令详解](http://blog.csdn.net/defonds/article/details/9274479)
[使用Nginx+FFMPEG搭建HLS直播转码服务器](http://blog.csdn.net/wutong_login/article/details/42292787)
[nginx搭建支持http和rtmp协议的流媒体服务器](http://blog.chinaunix.net/uid-26000296-id-4335063.html)
[RTMP流媒体播放过程](http://blog.csdn.net/leixiaohua1020/article/details/11704355)
[m3u8-segmenter](https://github.com/johnf/m3u8-segmenter)
[Nginx安装](http://www.nginx.cn/install)
[root与alias的区别](http://www.linuxidc.com/Linux/2013-10/92147.htm)
[nginx配置location总结及rewrite规则写法](https://segmentfault.com/a/1190000002797606)
[nginx应用总结（1）--基础认识和应用配置 - 散尽浮华 - 博客园](http://www.cnblogs.com/kevingrace/p/6095027.html)
[nginx服务器安装及配置文件详解 - Sean's Notes - SegmentFault](https://segmentfault.com/a/1190000002797601)
[Nginx.org 文档 - 文集 - 简书](http://www.jianshu.com/nb/3981534)
[翻译 nginx 的 server names ](http://www.jianshu.com/p/1430e4046fd9)

[Web服务器Nginx多方位优化策略 - 运维生存时间](http://www.ttlsa.com/nginx/web-server-nginx-optimization/)
######
nginx 仅通过检查请求首部中的 “HOST” 字段来决定让哪个虚拟主机处理访问请求


https://regexper.com
. ： 匹配除换行符以外的任意字符
\d ：匹配数字

? ： 重复0次或1次
+ ： 重复1次或更多次
* ： 重复0次或更多次

^ ： 匹配字符串的开始
$ ： 匹配字符串的介绍
{n} ： 重复n次
{n,} ： 重复n次或更多次
[c] ： 匹配单个字符c
[a-z] ： 匹配a-z小写字母的任意一个

# location匹配规则
优先级
`(=) > (^~) > (~,~*) > ( ) > (/)`

    =     精确匹配
    ^~    url路径匹配 一般用来匹配目录,nginx不对url做编码，因此请求为/static/20%/aa，可以被规则^~ /static/ /aa匹配到（注意是空格）
    ~,~*  正则匹配
          ~    区分大小写    ~*   不区分大小写
    ' '   普通匹配
    @     命名的 location，使用在内部定向时，例如 error_page, try_files
    /  通用匹配，任何请求都会匹配到。

# Nginx下的rewrite规则

一．正则表达式匹配，其中：
 ~ 为区分大小写匹配
 ~* 为不区分大小写匹配
 !~和!~* 分别为区分大小写不匹配及不区分大小写不匹配

二．文件及目录匹配，其中：
 -f和!-f用来判断是否存在文件
 -d和!-d用来判断是否存在目录
 -e和!-e用来判断是否存在文件或目录
 -x和!-x用来判断文件是否可执行

rewrite regex replacement [flag];

三．rewrite指令的最后一项参数为flag标记，四种flag标记：
注: 这里的地址栏url不变，只是针对站内的url地址而言，只要是url重写必定改变地址栏
1. 为空 - 地址栏url不变，但是内容已经变化，也是永久性的重定向。地址栏url不变
2. last - url重写后，停止处理后续rewrite指令集马上发起一个新的请求，再次进入server块，重试location匹配，超过10次匹配不到报500错误，地址栏url不变 ;内部跳转,只对站内url重写有效
3. break - url重写后，停止处理后续rewrite指令集，并不在重新查找,直接使用当前资源，不再执行location里余下的语句，完成本次请求，地址栏url不变
4. redirect - 返回302临时重定向，url会跳转，爬虫不会更新url。 地址栏url重写
5. permanent - 返回301永久重定向。url会跳转。爬虫会更新url。 地址栏url重写

1.last        相当于apache里面的[L]标记，表示rewrite。
2.break       本条规则匹配完成后，终止匹配，不再匹配后面的规则。
3.redirect    返回302临时重定向，浏览器地址会显示跳转后的URL地址。
4.permanent   返回301永久重定向，浏览器地址会显示跳转后的URL地址。

```
location /download/ {
    rewrite ^(/download/.*)/media/(.*)..*$ $1/mp3/$2.mp3 break;
    rewrite ^(/download/.*)/audio/(.*)..*$ $1/mp3/$2.ra break;
    return 403;
}
```


上面的正则表达式的一部分可以用圆括号，方便之后按照顺序用$1-$9来引用。
小括号()之间匹配的内容，可以在后面通过$1来引用，$2表示的是前面第二个()里的内容。正则里面容易让人困惑的是\转义特殊字符。

如果我们将类似URL/photo/123456 重定向到/path/to/photo/12/1234/123456.png
rewrite "/photo/([0-9]{2})([0-9]{2})([0-9]{2})"/path/to/photo/$1/$1$2/$1$2$3.png ;

如果一个URI匹配指定的正则表达式regex，URI就按照replacement重写。
rewrite按配置文件中出现的顺序执行。flags标志可以停止继续处理。
如果replacement以"http://"或"https://"开始，将不再继续处理，这个重定向将返回给客户端。
flag可以是如下参数
last 停止处理后续rewrite指令集，然后对当前重写的新URI在rewrite指令集上重新查找。
break 停止处理后续rewrite指令集，并不在重新查找,但是当前location内剩余非rewrite语句和location外的的非rewrite语句可以执行。
redirect 如果replacement不是以http:// 或https://开始，返回302临时重定向
permant 返回301永久重定向
最终完整的重定向URL包括请求scheme(http://,https://等),请求的server_name_in_redirect和 port_in_redirec三部分 ，说白了也就是http协议 域名 端口三部分组成。

nginx的全局变量 ngx_http_core_module模块提供的变量
--------------------------------------------------------------------------------
```
remote_addr               客户端ip,如：192.168.4.2
binary_remote_addr        客户端ip（二进制)
remote_port               客户端port，如：50472
remote_user               已经经过Auth Basic Module验证的用户名
host                       请求主机头字段，否则为服务器名称，如:dwz.stamhe.com
request                    用户请求信息，如：GET /?_a=index&_m=show&count=10 HTTP/1.1
request_filename         当前请求的文件的路径名，由root或alias和URI request组合而成，如：/webserver/htdocs/dwz/index.php
status                        请求的响应状态码,如:200
body_bytes_sent         响应时送出的body字节数数量。即使连接中断，这个数据也是精确的,如：40
content_length            请求头中的Content-length字段
content_type               请求头中的Content-Type字段
http_referer                 引用地址
http_user_agent           客户端agent信息,如：Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11
args                            如：_a=index&_m=show&count=10
document_uri               与$uri相同,如：/index.php
document_root             针对当前请求的根路径设置值,如：/webserver/htdocs/dwz
hostname                     如：centos53.localdomain
http_cookie                  客户端cookie信息
cookie_COOKIE             cookie   COOKIE变量的值
is_args                         如果有$args参数，这个变量等于”?”，否则等于”"，空值，如?
limit_rate                      这个变量可以限制连接速率，0表示不限速
query_string                 与$args相同,如：_a=index&_m=show&count=10
realpath_root                如：/webserver/htdocs/dwz
request_body                记录POST过来的数据信息
request_body_file          客户端请求主体信息的临时文件名
request_method            客户端请求的动作，通常为GET或POST,如：GET
request_uri                   包含请求参数的原始URI，不包含主机名，如：”/foo/bar.php?arg=baz”。不能修改。如：/index.php?_a=index&_m=show&count=10
scheme                         HTTP方法（如http，https）,如：http
uri                                如：/index.php
request_completion        如果请求结束，设置为OK. 当请求未结束或如果该请求不是请求链串的最后一个时，为空(Empty)，如：OK
server_protocol              请求使用的协议，通常是HTTP/1.0或HTTP/1.1，如：HTTP/1.1
server_addr                   服务器地址，在完成一次系统调用后可以确定这个值，如：192.168.4.129
server_name                  服务器名称，如：dwz.stamhe.com
server_port                   请求到达服务器的端口号,如：80
```
```
$arg_PARAMETER HTTP 请求中某个参数的值，如/index.php?site=www.ttlsa.com，可以用$arg_site取得www.ttlsa.com这个值.
$args HTTP 请求中的完整参数。例如，在请求/index.php?width=400&height=200 中，$args表示字符串width=400&height=200.
$binary_remote_addr 二进制格式的客户端地址。例如：\x0A\xE0B\x0E
$body_bytes_sent 表示在向客户端发送的http响应中，包体部分的字节数
$content_length 表示客户端请求头部中的Content-Length 字段
$content_type 表示客户端请求头部中的Content-Type 字段
$cookie_COOKIE 表示在客户端请求头部中的cookie 字段
$document_root 表示当前请求所使用的root 配置项的值
$uri 表示当前请求的URI，不带任何参数
$document_uri 与$uri 含义相同
$request_uri 表示客户端发来的原始请求URI，带完整的参数。$uri和$document_uri未必是用户的原始请求，在内部重定向后可能是重定向后的URI，而$request_uri 永远不会改变，始终是客户端的原始URI.
$host 表示客户端请求头部中的Host字段。如果Host字段不存在，则以实际处理的server（虚拟主机）名称代替。如果Host字段中带有端口，如IP:PORT，那么$host是去掉端口的，它的值为IP。$host 是全小写的。这些特性与http_HEADER中的http_host不同，http_host只取出Host头部对应的值。
$hostname 表示 Nginx所在机器的名称，与 gethostbyname调用返回的值相同
$http_HEADER 表示当前 HTTP请求中相应头部的值。HEADER名称全小写。例如，示请求中 Host头部对应的值 用 $http_host表
$sent_http_HEADER 表示返回客户端的 HTTP响应中相应头部的值。HEADER名称全小写。例如，用 $sent_ http_content_type表示响应中 Content-Type头部对应的值
$is_args 表示请求中的 URI是否带参数，如果带参数，$is_args值为 ?，如果不带参数，则是空字符串
$limit_rate 表示当前连接的限速是多少，0表示无限速
$nginx_version 表示当前 Nginx的版本号
$query_string 请求 URI中的参数，与 $args相同，然而 $query_string是只读的不会改变
$remote_addr 表示客户端的地址
$remote_port 表示客户端连接使用的端口
$remote_user 表示使用 Auth Basic Module时定义的用户名
$request_filename 表示用户请求中的 URI经过 root或 alias转换后的文件路径
$request_body 表示 HTTP请求中的包体，该参数只在 proxy_pass或 fastcgi_pass中有意义
$request_body_file 表示 HTTP请求中的包体存储的临时文件名
$request_completion 当请求已经全部完成时，其值为 “ok”。若没有完成，就要返回客户端，则其值为空字符串；或者在断点续传等情况下使用 HTTP range访问的并不是文件的最后一块，那么其值也是空字符串。
$request_method 表示 HTTP请求的方法名，如 GET、PUT、POST等
$scheme 表示 HTTP scheme，如在请求 https://nginx.com/中表示 https
$server_addr 表示服务器地址
$server_name 表示服务器名称
$server_port 表示服务器端口
$server_protocol 表示服务器向客户端发送响应的协议，如 HTTP/1.1或 HTTP/1.0
```
upstram 模块

upstream 模块负债负载均衡模块，通过一个简单的调度算法来实现客户端IP到后端服务器的负载均衡。我先学习怎么用，具体的使用实例以后再说。

    upstream iyangyi.com{
        ip_hash;
        server 192.168.12.1:80;
        server 192.168.12.2:80 down;
        server 192.168.12.3:8080  max_fails=3  fail_timeout=20s;
        server 192.168.12.4:8080;
    }

在上面的例子中，通过upstream指令指定了一个负载均衡器的名称iyangyi.com。这个名称可以任意指定，在后面需要的地方直接调用即可。

里面是ip_hash这是其中的一种负载均衡调度算法，下面会着重介绍。紧接着就是各种服务器了。用server关键字表识，后面接ip。

Nginx的负载均衡模块目前支持4种调度算法:

    weight 轮询（默认）。每个请求按时间顺序逐一分配到不同的后端服务器，如果后端某台服务器宕机，故障系统被自动剔除，使用户访问不受影响。weight。指定轮询权值，weight值越大，分配到的访问机率越高，主要用于后端每个服务器性能不均的情况下。
    ip_hash。每个请求按访问IP的hash结果分配，这样来自同一个IP的访客固定访问一个后端服务器，有效解决了动态网页存在的session共享问题。
    fair。比上面两个更加智能的负载均衡算法。此种算法可以依据页面大小和加载时间长短智能地进行负载均衡，也就是根据后端服务器的响应时间来分配请求，响应时间短的优先分配。Nginx本身是不支持fair的，如果需要使用这种调度算法，必须下载Nginx的upstream_fair模块。
    url_hash。按访问url的hash结果来分配请求，使每个url定向到同一个后端服务器，可以进一步提高后端缓存服务器的效率。Nginx本身是不支持url_hash的，如果需要使用这种调度算法，必须安装Nginx 的hash软件包。

在HTTP Upstream模块中，可以通过server指令指定后端服务器的IP地址和端口，同时还可以设定每个后端服务器在负载均衡调度中的状态。常用的状态有：

    down，表示当前的server暂时不参与负载均衡。
    backup，预留的备份机器。当其他所有的非backup机器出现故障或者忙的时候，才会请求backup机器，因此这台机器的压力最轻。
    max_fails，允许请求失败的次数，默认为1。当超过最大次数时，返回proxy_next_upstream 模块定义的错误。
    fail_timeout，在经历了max_fails次失败后，暂停服务的时间。max_fails可以和fail_timeout一起使用。

注意 当负载调度算法为ip_hash时，后端服务器在负载均衡调度中的状态不能是weight和backup。

################################################################################
1.卸载Nginx
apt-get remove nginx*

## 准备工作
mkdir Nginx && cd ~/Nginx/

[Nginx官网](http://nginx.org/)
  wget http://nginx.org/download/nginx-1.9.12.tar.gz
  tar zxvf nginx-1.9.12.tar.gz

  `git clone git@github.com:nginx/nginx.git`
###############################################################################

sudo apt-get -y install autoconf automake build-essential libass-dev libgpac-dev libsdl1.2-dev libtheora-dev libtool libvdpau-dev libvorbis-dev libx11-dev libxext-dev libxfixes-dev pkg-config texi2html zlib1g-dev libssl-dev

### 编译环境gcc g++ 开发库之类
ubuntu/debian：
```
sudo apt-get install build-essential
sudo apt-get install libtool
```
centos/redhat：
```
安装make：
yum -y install gcc automake autoconf libtool make
安装g++:
yum install gcc gcc-c++
```

### 添加依赖: install zlib zlib-devel openssl openssl-devel pcre-devel
zlib:nginx提供gzip模块，需要zlib库支持
openssl:nginx提供ssl功能
pcre:支持地址重写rewrite功能

### 1.pcre 需要安装libpcre
--with-pcre=/usr/local/src/pcre-8.34

ubuntu/debian：
sudo apt-get install libpcre3 libpcre3-dev

centos/redhat：
yum install pcre-devel

```
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.34.tar.gz
tar -zxvf pcre-8.34.tar.gz
cd pcre-8.34
./configure
make
make install
```

### 2.SSL modules require the OpenSSL library
--with-http_ssl_module
--with-openssl=/usr/local/src/openssl-1.0.1c

ubuntu/debian：
sudo apt-get install openssl
sudo apt-get install libssl-dev

centos/redhat：
yum -y install openssl openssl-devel

```
wget http://www.openssl.org/source/openssl-1.0.1c.tar.gz
tar -zxvf openssl-1.0.1c.tar.gz
```

### 3.zlib
--with-zlib=/usr/local/src/zlib-1.2.8
安装zlib库
http://zlib.net/zlib-1.2.8.tar.gz 下载最新的 zlib 源码包，使用下面命令下载编译和安装 zlib包：
cd /usr/local/src
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure
make
make install
################################################################################
## 模块:

## 编译安装ffmpeg及其依赖包
https://trac.ffmpeg.org/
`git clone git@github.com:FFmpeg/FFmpeg.git`
`cd ffmpeg`
#./configure
--prefix=/opt/ffmpeg/ \
--enable-version3 \
--enable-libvpx \
--enable-libfaac \
--enable-libmp3lame \
--enable-libvorbis \
--enable-libx264 \
--enable-libxvid \
--enable-shared \
--enable-gpl \
--enable-postproc \
--enable-nonfree \
--enable-avfilter \
--enable-pthreads
--prefix=/usr --extra-version=0ubuntu0.15.10.1 --build-suffix=-ffmpeg --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --enable-gpl --enable-shared --disable-stripping --enable-avresample --enable-avisynth --enable-frei0r --enable-gnutls --enable-ladspa --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libmodplug --enable-libmp3lame --enable-libopenjpeg --enable-openal --enable-libopus --enable-libpulse --enable-librtmp --enable-libschroedinger --enable-libshine --enable-libspeex --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libxvid --enable-libzvbi --enable-opengl --enable-x11grab --enable-libdc1394 --enable-libiec61883 --enable-libzmq --enable-libssh --enable-libsoxr --enable-libx264 --enable-libopencv --enable-libx265
#make && make install
vim objs/Makefile (修改objs/Makefile文件, 去掉其中的"-Werror"), 然后就能够正常编译了.


[nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)
  ` git clone git@github.com:arut/nginx-rtmp-module.git `
  ./configure --add-module=/path/to/nginx-rtmp-module
  ./configure --add-module=/path/to/nginx-rtmp-module --with-http_ssl_module
  ./configure --add-module=/path/to-nginx/rtmp-module --with-debug

#编译错误
./nginx-rtmp-module/ngx_rtmp_core_module.c
```
@@ -557,7 +557,11 @@ ngx_rtmp_core_listen(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
             break;
         }

+#if (nginx_version >= 1011000)
+        if (ngx_memcmp(ls[i].sockaddr + off, &u.sockaddr + off, len) != 0) {
+#else
         if (ngx_memcmp(ls[i].sockaddr + off, u.sockaddr + off, len) != 0) {
+#endif
             continue;
         }

@@ -577,7 +581,11 @@ ngx_rtmp_core_listen(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)

     ngx_memzero(ls, sizeof(ngx_rtmp_listen_t));

+#if (nginx_version >= 1011000)
+    ngx_memcpy(ls->sockaddr, &u.sockaddr, u.socklen);
+#else
     ngx_memcpy(ls->sockaddr, u.sockaddr, u.socklen);
+#endif

     ls->socklen = u.socklen;
     ls->wildcard = u.wildcard;
```

[nginx_mod_h264_streaming(支持h264编码的视频)](http://h264.code-shop.com/trac/wiki/Mod-H264-Streaming-Nginx-Version2#Download)
wget http://h264.code-shop.com/download/nginx_mod_h264_streaming-2.2.7.tar.gz
tar -zxvf nginx_mod_h264_streaming-2.2.7.tar.gz

`git clone git@github.com:vivus-ignis/nginx_mod_h264_streaming.git`

./configure --add-module=$HOME/nginx_mod_h264_streaming --sbin-path=/usr/local/sbin --with-debug

1. 将 ./nginx_mod_h264_streaming/src/ngx_http_streaming_module.c 文件中以下代码删除或者是注释掉就可以了：
```
/* TODO: Win32 */

// if (r->zero_in_uri)
// {
//    return NGX_DECLINED;
// }
```

################################################################################
cp auto/configure .
#配置nginx
./configure \
--prefix=/usr/local/nginx \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_ssl_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-pcre \
--user=nginx \
--group=nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--add-module=../nginx-rtmp-module \
--add-module=../nginx_mod_h264_streaming \
#--with-cc-opt=-I/opt/ffmpeg/include \
--with-ld-opt=’-L/opt/ffmpeg/lib -Wl,-rpath=/opt/ffmpeg/lib’\

#--pid-path=/usr/local/nginx/logs/nginx.pid \
#--error-log-path=/usr/local/nginx/logs/error.log \
#--http-log-path=/usr/local/nginx/logs/access.log \
##编译错误解决
1. mp4_reader.
```
# vim objs/Makefile (修改objs/Makefile文件, 去掉其中的"-Werror"), 然后就能够正常编译了.
```

make -j4 && sudo make install
##
make -f objs/Makefile install
```
 mv '/usr/sbin/nginx' '/usr/sbin/nginx.old'
cp objs/nginx '/usr/sbin/nginx'

mkdir -p '/etc/nginx'
cp conf/mime.types '/etc/nginx/mime.types.default'
cp conf/nginx.conf '/etc/nginx/nginx.conf'
cp conf/nginx.conf '/etc/nginx/nginx.conf.default'

mkdir -p '/usr/local/nginx/logs'
cp -R docs/html '/usr/local/nginx'
```
##添加类型支持
vim /usr/local/nginx/conf/mime.types
```
application/vnd.apple.mpegurl m3u8;
application/x-mpegURL                 m3u8;  

video/MP2T                             ts;
```
###################################################
sudo vim /etc/nginx/nginx.conf
` + include /etc/nginx/conf.d/*.conf; `

1.建立nginx
sudo groupadd -r nginx
sudo useradd -s /sbin/nologin -g nginx -r nginx
id nginx　

2.验证配置文件
sudo nginx -t
sudo nginx -t -c /usr/local/nginx/conf/nginx.conf

3.启动nginx
sudo nginx
ps -ef | grep nginx

4.更改配置重启nginx　　
nginx -s reload
kill -HUP 主进程号或进程号文件路径

5.查询nginx主进程号
　　ps -ef | grep nginx
　　从容停止   kill -QUIT 主进程号
　　快速停止   kill -TERM 主进程号
　　强制停止   kill -9 nginx
　　若nginx.conf配置了pid文件路径，如果没有，则在logs目录下
　　kill -信号类型 '/usr/local/nginx/logs/nginx.pid'

403解决办法：chown -R nginx:nginx /htdocs
6. 添加 crossdomain.xml 解决m3u8播放问题
sudo cp ./EasyDarwin/EasyDarwin/WinNTSupport/Movies/crossdomain.xml /usr/local/nginx/html/

###################################################
cp auto/configure .
# centos 默认配置
 --prefix=/etc/nginx
 --sbin-path=/usr/sbin/nginx
 --conf-path=/etc/nginx/nginx.conf
 --error-log-path=/var/log/nginx/error.log
 --http-log-path=/var/log/nginx/access.log
 --pid-path=/var/run/nginx.pid
 --lock-path=/var/run/nginx.lock
 --http-client-body-temp-path=/var/cache/nginx/client_temp
 --http-proxy-temp-path=/var/cache/nginx/proxy_temp
 --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp
 --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp
 --http-scgi-temp-path=/var/cache/nginx/scgi_temp
 --user=nginx
 --group=nginx
 --with-http_ssl_module
 --with-http_realip_module
 --with-http_addition_module
 --with-http_sub_module
 --with-http_dav_module
 --with-http_flv_module
 --with-http_mp4_module
 --with-http_gunzip_module
 --with-http_gzip_static_module
 --with-http_random_index_module
 --with-http_secure_link_module
 --with-http_stub_status_module
 --with-http_auth_request_module
 --with-mail
 --with-mail_ssl_module
 --with-file-aio
 --with-ipv6
 --with-http_spdy_module
 --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic'

 configure arguments: ubuntu 16
 --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2'
 --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now'
 --prefix=/usr/share/nginx
 --conf-path=/etc/nginx/nginx.conf
 --http-log-path=/var/log/nginx/access.log
 --error-log-path=/var/log/nginx/error.log
 --lock-path=/var/lock/nginx.lock
 --pid-path=/run/nginx.pid
 --http-client-body-temp-path=/var/lib/nginx/body
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi
 --http-proxy-temp-path=/var/lib/nginx/proxy
 --http-scgi-temp-path=/var/lib/nginx/scgi
 --http-uwsgi-temp-path=/var/lib/nginx/uwsgi
 --with-debug
 --with-pcre-jit
 --with-ipv6
 --with-http_ssl_module
 --with-http_stub_status_module
 --with-http_realip_module
 --with-http_auth_request_module
 --with-http_addition_module
 --with-http_dav_module
 --with-http_geoip_module
 --with-http_gunzip_module
 --with-http_gzip_static_module
 --with-http_image_filter_module
 --with-http_v2_module
 --with-http_sub_module
 --with-http_xslt_module
 --with-stream
 --with-stream_ssl_module
 --with-mail
 --with-mail_ssl_module
 --with-threads

////////////////////////////////////////////////////////////////////
[Nginx编译参数详细介绍](http://blog.csdn.net/eric1012/article/details/6052154)
--prefix= 指向安装目录
--sbin-path 指向（执行）程序文件（nginx）
--conf-path= 指向配置文件（nginx.conf）
--error-log-path= 指向错误日志目录
--pid-path= 指向pid文件（nginx.pid）
--lock-path= 指向lock文件（nginx.lock）（安装文件锁定，防止安装文件被别人利用，或自己误操作。）
--user= 指定程序运行时的非特权用户
--group= 指定程序运行时的非特权用户组
--builddir= 指向编译目录
--with-rtsig_module 启用rtsig模块支持（实时信号）
--with-select_module 启用select模块支持（一种轮询模式,不推荐在高载环境下使用）禁用：--without-select_module
--with-poll_module 启用poll模块支持（功能与select相同，与select特性相同，为一种轮询模式,不推荐在高载环境下使用）
--with-file-aio 启用file aio支持（一种APL文件传输格式）
--with-ipv6 启用ipv6支持
--with-http_ssl_module 启用ngx_http_ssl_module支持（使支持https请求，需已安装openssl）
--with-http_realip_module 启用ngx_http_realip_module支持（这个模块允许从请求标头更改客户端的IP地址值，默认为关）
--with-http_addition_module 启用ngx_http_addition_module支持（作为一个输出过滤器，支持不完全缓冲，分部分响应请求）
--with-http_xslt_module 启用ngx_http_xslt_module支持（过滤转换XML请求）
--with-http_image_filter_module 启用ngx_http_image_filter_module支持（传输JPEG/GIF/PNG 图片的一个过滤器）（默认为不启用。gd库要用到）
--with-http_geoip_module 启用ngx_http_geoip_module支持（该模块创建基于与MaxMind GeoIP二进制文件相配的客户端IP地址的ngx_http_geoip_module变量）
--with-http_sub_module 启用ngx_http_sub_module支持（允许用一些其他文本替换nginx响应中的一些文本）
--with-http_dav_module 启用ngx_http_dav_module支持（增加PUT,DELETE,MKCOL：创建集合,COPY和MOVE方法）默认情况下为关闭，需编译开启
--with-http_flv_module 启用ngx_http_flv_module支持（提供寻求内存使用基于时间的偏移量文件）
--with-http_gzip_static_module 启用ngx_http_gzip_static_module支持（在线实时压缩输出数据流）
--with-http_random_index_module 启用ngx_http_random_index_module支持（从目录中随机挑选一个目录索引）
--with-http_secure_link_module 启用ngx_http_secure_link_module支持（计算和检查要求所需的安全链接网址）
--with-http_degradation_module  启用ngx_http_degradation_module支持（允许在内存不足的情况下返回204或444码）
--with-http_stub_status_module 启用ngx_http_stub_status_module支持（获取nginx自上次启动以来的工作状态）
--without-http_charset_module 禁用ngx_http_charset_module支持（重新编码web页面，但只能是一个方向--服务器端到客户端，并且只有一个字节的编码可以被重新编码）
--without-http_gzip_module 禁用ngx_http_gzip_module支持（该模块同-with-http_gzip_static_module功能一样）
--without-http_ssi_module 禁用ngx_http_ssi_module支持（该模块提供了一个在输入端处理处理服务器包含文件（SSI）的过滤器，目前支持SSI命令的列表是不完整的）
--without-http_userid_module 禁用ngx_http_userid_module支持（该模块用来处理用来确定客户端后续请求的cookies）
--without-http_access_module 禁用ngx_http_access_module支持（该模块提供了一个简单的基于主机的访问控制。允许/拒绝基于ip地址）
--without-http_auth_basic_module禁用ngx_http_auth_basic_module（该模块是可以使用用户名和密码基于http基本认证方法来保护你的站点或其部分内容）
--without-http_autoindex_module 禁用disable ngx_http_autoindex_module支持（该模块用于自动生成目录列表，只在ngx_http_index_module模块未找到索引文件时发出请求。）
--without-http_geo_module 禁用ngx_http_geo_module支持（创建一些变量，其值依赖于客户端的IP地址）
--without-http_map_module 禁用ngx_http_map_module支持（使用任意的键/值对设置配置变量）
--without-http_split_clients_module 禁用ngx_http_split_clients_module支持（该模块用来基于某些条件划分用户。条件如：ip地址、报头、cookies等等）
--without-http_referer_module 禁用disable ngx_http_referer_module支持（该模块用来过滤请求，拒绝报头中Referer值不正确的请求）
--without-http_rewrite_module 禁用ngx_http_rewrite_module支持（该模块允许使用正则表达式改变URI，并且根据变量来转向以及选择配置。如果在server级别设置该选项，那么他们将在 location之前生效。如果在location还有更进一步的重写规则，location部分的规则依然会被执行。如果这个URI重写是因为location部分的规则造成的，那么 location部分会再次被执行作为新的URI。 这个循环会执行10次，然后Nginx会返回一个500错误。）
--without-http_proxy_module 禁用ngx_http_proxy_module支持（有关代理服务器）
--without-http_fastcgi_module 禁用ngx_http_fastcgi_module支持（该模块允许Nginx 与FastCGI 进程交互，并通过传递参数来控制FastCGI 进程工作。 ）FastCGI一个常驻型的公共网关接口。
--without-http_uwsgi_module 禁用ngx_http_uwsgi_module支持（该模块用来医用uwsgi协议，uWSGI服务器相关）
--without-http_scgi_module 禁用ngx_http_scgi_module支持（该模块用来启用SCGI协议支持，SCGI协议是CGI协议的替代。它是一种应用程序与HTTP服务接口标准。它有些像FastCGI但他的设计 更容易实现。）
--without-http_memcached_module 禁用ngx_http_memcached_module支持（该模块用来提供简单的缓存，以提高系统效率）
-without-http_limit_zone_module 禁用ngx_http_limit_zone_module支持（该模块可以针对条件，进行会话的并发连接数控制）
--without-http_limit_req_module 禁用ngx_http_limit_req_module支持（该模块允许你对于一个地址进行请求数量的限制用一个给定的session或一个特定的事件）
--without-http_empty_gif_module 禁用ngx_http_empty_gif_module支持（该模块在内存中常驻了一个1*1的透明GIF图像，可以被非常快速的调用）
--without-http_browser_module 禁用ngx_http_browser_module支持（该模块用来创建依赖于请求报头的值。如果浏览器为modern ，则$modern_browser等于modern_browser_value指令分配的值；如 果浏览器为old，则$ancient_browser等于 ancient_browser_value指令分配的值；如果浏览器为 MSIE中的任意版本，则 $msie等于1）
--without-http_upstream_ip_hash_module 禁用ngx_http_upstream_ip_hash_module支持（该模块用于简单的负载均衡）
--with-http_perl_module 启用ngx_http_perl_module支持（该模块使nginx可以直接使用perl或通过ssi调用perl）
--with-perl_modules_path= 设定perl模块路径
--with-perl= 设定perl库文件路径
--http-log-path= 设定access log路径
--http-client-body-temp-path= 设定http客户端请求临时文件路径
--http-proxy-temp-path= 设定http代理临时文件路径
--http-fastcgi-temp-path= 设定http fastcgi临时文件路径
--http-uwsgi-temp-path= 设定http uwsgi临时文件路径
--http-scgi-temp-path= 设定http scgi临时文件路径
-without-http 禁用http server功能
--without-http-cache 禁用http cache功能
--with-mail 启用POP3/IMAP4/SMTP代理模块支持
--with-mail_ssl_module 启用ngx_mail_ssl_module支持
--without-mail_pop3_module 禁用pop3协议（POP3即邮局协议的第3个版本,它是规定个人计算机如何连接到互联网上的邮件服务器进行收发邮件的协议。是因特网电子邮件的第一个离线协议标 准,POP3协议允许用户从服务器上把邮件存储到本地主机上,同时根据客户端的操作删除或保存在邮件服务器上的邮件。POP3协议是TCP/IP协议族中的一员，主要用于 支持使用客户端远程管理在服务器上的电子邮件）
--without-mail_imap_module 禁用imap协议（一种邮件获取协议。它的主要作用是邮件客户端可以通过这种协议从邮件服务器上获取邮件的信息，下载邮件等。IMAP协议运行在TCP/IP协议之上， 使用的端口是143。它与POP3协议的主要区别是用户可以不用把所有的邮件全部下载，可以通过客户端直接对服务器上的邮件进行操作。）
--without-mail_smtp_module 禁用smtp协议（SMTP即简单邮件传输协议,它是一组用于由源地址到目的地址传送邮件的规则，由它来控制信件的中转方式。SMTP协议属于TCP/IP协议族，它帮助每台计算机在发送或中转信件时找到下一个目的地。）
--with-google_perftools_module 启用ngx_google_perftools_module支持（调试用，剖析程序性能瓶颈）
--with-cpp_test_module 启用ngx_cpp_test_module支持
--add-module= 启用外部模块支持
--with-cc= 指向C编译器路径
--with-cpp= 指向C预处理路径
--with-cc-opt= 设置C编译器参数（PCRE库，需要指定--with-cc-opt=”-I /usr/local/include”，如果使用select()函数则需要同时增加文件描述符数量，可以通过--with-cc- opt=”-D FD_SETSIZE=2048”指定。）
--with-ld-opt= 设置连接文件参数。（PCRE库，需要指定--with-ld-opt=”-L /usr/local/lib”。）
--with-cpu-opt= 指定编译的CPU，可用的值为: pentium, pentiumpro, pentium3, pentium4, athlon, opteron, amd64, sparc32, sparc64, ppc64
--without-pcre 禁用pcre库
--with-pcre 启用pcre库
--with-pcre= 指向pcre库文件目录
--with-pcre-opt= 在编译时为pcre库设置附加参数
--with-md5= 指向md5库文件目录（消息摘要算法第五版，用以提供消息的完整性保护）
--with-md5-opt= 在编译时为md5库设置附加参数
--with-md5-asm 使用md5汇编源
--with-sha1= 指向sha1库目录（数字签名算法，主要用于数字签名）
--with-sha1-opt= 在编译时为sha1库设置附加参数
--with-sha1-asm 使用sha1汇编源
--with-zlib= 指向zlib库目录
--with-zlib-opt= 在编译时为zlib设置附加参数
--with-zlib-asm= 为指定的CPU使用zlib汇编源进行优化，CPU类型为pentium, pentiumpro
--with-libatomic 为原子内存的更新操作的实现提供一个架构
--with-libatomic= 指向libatomic_ops安装目录
--with-openssl= 指向openssl安装目录
--with-openssl-opt 在编译时为openssl设置附加参数
--with-debug 启用debug日志
