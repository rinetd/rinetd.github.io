---
title: Linux命令 curl
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [curl]
---
curl like tools
- httpie [pyton](https://github.com/jakubroztocil/httpie)
- bat    [go](https://github.com/astaxie/bat)

# 无参
-L, --location      Follow redirects (H)                         [重定向]
-C, --continue-at OFFSET  Resumed transfer OFFSET                [断点续传]
-I, --head          Show document info only                      [显示返回数据(response)头信息 -X HEAD  Response_Header]
-i, --include       Include protocol headers in the output (H/F) [返回数据(response) 的header          Response_Header + body]
-v, --verbose       Make the operation more talkative            [请求/返回数据头信息                   Request ]
-s, --silent        Silent mode (don't output anything)
# 参数设定
-X, --request [GET|POST|HEAD|PUT|DELETE|OPTIONS|PATCH]           [请求类型 ]
-x, --proxy [PROTOCOL://]HOST[:PORT]  Use proxy on given port    [使用代理]


## 头信息设置
-H, --header                           設定request裡的header
-H, --header LINE   Pass custom header LINE to server (H)
    [http Content-Type](http://tool.oschina.net/commons)
-A, --user-agent STRING  Send User-Agent STRING to server (H) [ -A curl/7.47.1 ]
    [-H "User-Agent: curl/7.47.1"]
-e, --referer       Referer URL (H)                           [ -e www.baidu.com ]
    [-H "Referer: www.baidu.com"]
-u, --user USER[:PASSWORD]  Server user and password          [  -u user:passwd ]
  [-H "Authorization: Basic dXNlcjpwYXNzd2Q="]  
  `echo -n user:passwd|base64` dXNlcjpwYXNzd2Q=

## 主体设置
-d, --data DATA     HTTP POST data (H)  [http POST parameters]
    [-d "param1=value1&param2=value2" == -d "param1=value1" -d "param2=value2"]
    [-d @filename]                上传文件
-b, --cookie STRING/FILE  Read cookies from STRING/FILE (H) [使用cookie 与 -D -c 配合使用]
-F, --form CONTENT  Specify HTTP multipart POST data (H)
 [ -F "fileupload=@filename.txt"] form表单
# 输出
-D, --dump-header FILE  Write the headers to FILE 【head输出】
-c, --cookie-jar FILE  Write cookies to FILE after operation (H) 【仅cookie输出】
-o, --output FILE   Write to FILE instead of stdout  【内容输出】
-O, --remote-name   Write output to a file named as the remote file 【内容输出 自动命名】


curl -O -L -x localhost:8087 -k https://github.com/git-for-windows/git/releases/download/v2.8.2.windows.1/Git-2.8.2-64-bit.exe
curl -O -sSL -x localhost:8087 -k https://dl.google.com/dl/android/studio/ide-zips/2.2.0.1/android-studio-ide-145.2915834-windows.zip
curl -O -sSL -x localhost:8087 -k https://portswigger.net/DownloadUpdate.ashx?Product=Free

## 网络测试
1. curl -I www.baidu.com          # -I 只显示头信息
2. curl -d "value=1" ""           # -d 请求方式POST
3. curl -X DELETE ""              # -X 选项指定其它协议

## 文件下载
1. curl -O "url/install.sh"       # -O  下载并保存文件
2. curl -C- -O "url/install.sh"   # -C- 断点续传
3. curl -x proxy:sever "http://"  # -x  代理访问http 网站
4. curl -x ip:port -k "https://"  # -x -k 代理访问https网站
5. curl -L "http://"              # -L  强制重定向(HTTP Location headers)
5. curl -T "img.png" "http://"    # -T  文件上传 -T "{file1,file2}"
6. curl -k
7. curl -H "Content-Type: application/json" # -H 设定header信息
---
## oss
curl --insecure -X PUT  oss-example.oss-cn-hangzhou.aliyuncs.com/?acl -H "Authorization: OSS qn6qrrqxo2oawuk53otfjbyc:KU5h8YMUC78M30dXqf3JxrTZHiA=" -H "Date: Fri, 24 Feb 2012 03:21:12 GMT" -H "x-oss-acl: public-read" -H "Host: oss-example.oss-cn-hangzhou.aliyuncs.com"
## JPUSH
curl --insecure -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "7d431e42dfa6a6d693ac2d04:5e987ac6d2e04d95a9d8f0d1" -d '{"platform":"all","audience":"all","notification":{"alert":"Hi,JPush !","android":{"extras":{"android-key1":"android-value1"}},"ios":{"sound":"sound.caf","badge":"+1","extras":{"ios-key1":"ios-value1"}}}}'


curl  -H"Content-Type:text/plain" -H"appid:com.geili.koudai" -d '{"proxy_timestamp":"1441785630661","key":[]}' "http://localhost:8080/appconf/get_config"
##RESTFUL JSON
curl http://www.example.com?modifier=kent -X PUT -i -H "Content-Type:application/json" -H "Accept:application/json" -d '{"boolean" : false, "foo" : "bar"}'

# 不加"Accept:application/json"也可以
`curl http://www.example.com?modifier=kent -X PUT -i -H "Content-Type:application/json" -d '{"boolean" : false, "foo" : "bar"}'`

## curl 测试网站响应时间
`curl -o /dev/null -s -w '%{time_connect}:%{time_starttransfer}:%{time_total}\n' 'http://kisspeach.com'`
  time_connect 	建立到服务器的 TCP 连接所用的时间
  time_starttransfer 	在发出请求之后,Web 服务器返回数据的第一个字节所用的时间
  time_total 	完成请求所用的时间
  time_namelookup 	DNS解析时间,从请求开始到DNS解析完毕所用时间(记得关掉 Linux 的 nscd 的服务测试)
  speed_download 	下载速度，单位-字节每秒。


curl -v
-H --header "X-Requested-With: XMLHttpRequest"
-b --cookie "nforum-left=xxx; nforum[UTMPUSERID]=xxx; nforum[PASSWORD]=xxxxxxxxxxxx; nforum[UTMPKEY]=xxxxxx; nforum[UTMPNUM]=xxxxx; nforum[XWJOKE]=xxxxxx;"
-d --data "content=by curl"
-d "id=xxxx"
-d "subject=Re%3A+test"
http://bbs.byr.cn/article/SoftDesign/ajax_post.json   

curl -v
-i

-H --header "X-Requested-With: XMLHttpRequest"
-b --cookie "JSESSIONID=7A54ED5A7C7817C1C2A5CEF049288E7B"
-d --data "content=by curl"

http://bbs.byr.cn/article/SoftDesign/ajax_post.json   

-------------

curl --cookie "JSESSIONID=D4F6F85BBB4B0BADDE63EF140FE28FBA" http://www.51dszc.com/code/code>1.png
---
[curl命令详解 ](http://blog.csdn.net/wangjunji34478/article/details/35988223)
[使用curl指令測試REST服務](http://ju.outofmemory.cn/entry/84875)
[ curl http调试restful接口 ](http://blog.csdn.net/huyangyamin/article/details/50248795)
[CURLlinux_base](http://www.cnblogs.com/gbyukg/p/3326825.html)
[linux curl 命令详解，以及实例](http://www.aikaiyuan.com/7114.html)
下载单个文件，默认将输出打印到标准输出中(STDOUT)中
curl http://www.centos.org
通过-o/-O选项保存下载的文件到指定的文件中：
-o：将文件保存为命令行中指定的文件名的文件中
-O：使用URL中默认的文件名保存文件到本地

1 # 将文件下载到本地并命名为mygettext.html
2 curl -o mygettext.html http://www.gnu.org/software/gettext/manual/gettext.html
3
4 # 将文件保存到本地并命名为gettext.html
5 curl -O http://www.gnu.org/software/gettext/manual/gettext.html

同样可以使用转向字符">"对输出进行转向输出

同时获取多个文件

1 curl -O URL1 -O URL2

若同时从同一站点下载多个文件时，curl会尝试重用链接(connection)。

通过-L选项进行重定向
默认情况下CURL不会发送HTTP Location headers(重定向).当一个被请求页面移动到另一个站点时，会发送一个HTTP Loaction header作为请求，然后将请求重定向到新的地址上。
例如：访问google.com时，会自动将地址重定向到google.com.hk上。

2 curl -L http://www.google.com

断点续传

通过使用-C选项可对大文件使用断点续传功能，如：


1 # 当文件在下载完成之前结束该进程
2 $ curl -O http://www.gnu.org/software/gettext/manual/gettext.html
3 ##############             20.1%
4
5 # 通过添加-C选项继续对该文件进行下载，已经下载过的文件不会被重新下载
6 curl -C - -O http://www.gnu.org/software/gettext/manual/gettext.html
7 ###############            21.1%



对CURL使用网络限速
通过--limit-rate选项对CURL的最大网络使用进行限制

1 # 下载速度最大不会超过1000B/second
2
3 curl --limit-rate 1000B -O http://www.gnu.org/software/gettext/manual/gettext.html

下载指定时间内修改过的文件

当下载一个文件时，可对该文件的最后修改日期进行判断，如果该文件在指定日期内修改过，就进行下载，否则不下载。
该功能可通过使用-z选项来实现：

1 # 若yy.html文件在2011/12/21之后有过更新才会进行下载
2 curl -z 21-Dec-11 http://www.example.com/yy.html

CURL授权

在访问需要授权的页面时，可通过-u选项提供用户名和密码进行授权

1 curl -u username:password URL
2
3 # 通常的做法是在命令行只输入用户名，之后会提示输入密码，这样可以保证在查看历史记录时不会将密码泄露
4 curl -u username URL

从FTP服务器下载文件

CURL同样支持FTP下载，若在url中指定的是某个文件路径而非具体的某个要下载的文件名，CURL则会列出该目录下的所有文件名而并非下载该目录下的所有文件

1 # 列出public_html下的所有文件夹和文件
2 curl -u ftpuser:ftppass -O ftp://ftp_server/public_html/
3
4 # 下载xss.php文件
5 curl -u ftpuser:ftppass -O ftp://ftp_server/public_html/xss.php

上传文件到FTP服务器

通过 -T 选项可将指定的本地文件上传到FTP服务器上


# 将myfile.txt文件上传到服务器
curl -u ftpuser:ftppass -T myfile.txt ftp://ftp.testserver.com

# 同时上传多个文件
curl -u ftpuser:ftppass -T "{file1,file2}" ftp://ftp.testserver.com

# 从标准输入获取内容保存到服务器指定的文件中
curl -u ftpuser:ftppass -T - ftp://ftp.testserver.com/myfile_1.txt



获取更多信息

通过使用 -v 和 -trace获取更多的链接信息

通过字典查询单词


1 # 查询bash单词的含义
2 curl dict://dict.org/d:bash
3
4 # 列出所有可用词典
5 curl dict://dict.org/show:db
6
7 # 在foldoc词典中查询bash单词的含义
8 curl dict://dict.org/d:bash:foldoc



为CURL设置代理

-x 选项可以为CURL添加代理功能

1 # 指定代理主机和端口
2 curl -x proxysever.test.com:3128 http://google.co.in



其他网站整理

保存与使用网站cookie信息

1 # 将网站的cookies信息保存到sugarcookies文件中
2 curl -D sugarcookies http://localhost/sugarcrm/index.php
3
4 # 使用上次保存的cookie信息
5 curl -b sugarcookies http://localhost/sugarcrm/index.php

传递请求数据

默认curl使用GET方式请求数据，这种方式下直接通过URL传递数据
可以通过 --data/-d 方式指定使用POST方式传递数据


1 # GET
2 curl -u username https://api.github.com/user?access_token=XXXXXXXXXX
3
4 # POST
5 curl -u username --data "param1=value1&param2=value" https://api.github.com
6
7 # 也可以指定一个文件，将该文件中的内容当作数据传递给服务器端
8 curl --data @filename https://github.api.com/authorizations



注：默认情况下，通过POST方式传递过去的数据中若有特殊字符，首先需要将特殊字符转义在传递给服务器端，如value值中包含有空格，则需要先将空格转换成%20，如：

1 curl -d "value%201" http://hostname.com

在新版本的CURL中，提供了新的选项 --data-urlencode，通过该选项提供的参数会自动转义特殊字符。

1 curl --data-urlencode "value 1" http://hostname.com

除了使用GET和POST协议外，还可以通过 -X 选项指定其它协议，如：

1 curl -I -X DELETE https://api.github.cim

上传文件

1 curl --form "fileupload=@filename.txt" http://hostname/resource
