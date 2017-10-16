---
title: Linux命令 wireshark
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [wireshark,tshark]
---

//打印http协议流相关信息
tshark -s 512 -i eth0 -n -f 'tcp dst port 80' -R 'http.host and http.request.uri' -T fields -e http.host -e http.request.uri -l | tr -d '\t'
　　注释：
　　　　-s: 只抓取前512字节；
　　　　-i: 捕获eth0网卡；
　　　　-n: 禁止网络对象名称解析;
　　　　-f: 只捕获协议为tcp,目的端口为80;
　　　　-R: 过滤出http.host和http.request.uri;
　　　　-T,-e: 指的是打印这两个字段;
　　　　-I: 输出到命令行界面;
//实时打印当前mysql查询语句
tshark -s 512 -i eth0 -n -f 'tcp dst port 3306' -R 'mysql.query' -T fields -e mysql.query
　　　注释:
　　　　-R: 过滤出mysql的查询语句;
//导出smpp协议header和value的例子
tshark -r test.cap -R '(smpp.command_id==0x80000004) and (smpp.command_status==0x0)' -e smpp.message_id -e frame.time -T fields -E header=y >test.txt
　　　注释:
　　　　-r: 读取本地文件，可以先抓包存下来之后再进行分析;
　　　　-R: smpp...可以在wireshark的过滤表达式里面找到，后面会详细介绍;
　　　　-E: 当-T字段指定时，设置输出选项，header=y意思是头部要打印;
　　　　-e: 当-T字段指定时，设置输出哪些字段;
　　　　 >: 重定向;
//统计http状态
tshark -n -q -z http,stat, -z http,tree
　　　注释:
　　　　-q: 只在结束捕获时输出数据，针对于统计类的命令非常有用;
　　　　-z: 各类统计选项，具体的参考文档，后面会介绍，可以使用tshark -z help命令来查看所有支持的字段;
　　　　　　 http,stat: 计算HTTP统计信息，显示的值是HTTP状态代码和HTTP请求方法。
　　　　　　 http,tree: 计算HTTP包分布。 显示的值是HTTP请求模式和HTTP状态代码。
//抓取500个包提取访问的网址打印出来
tshark -s 0 -i eth0 -n -f 'tcp dst port 80' -R 'http.host and http.request.uri' -T fields -e http.host -e http.request.uri -l -c 500
　　　注释:
　　　　-f: 抓包前过滤；
　　　　-R: 抓包后过滤；
　　　　-l: 在打印结果之前清空缓存;
　　　　-c: 在抓500个包之后结束;
//显示ssl data数据
tshark -n -t a -R ssl -T fields -e "ip.src" -e "ssl.app_data"

//读取指定报文,按照ssl过滤显示内容
tshark -r temp.cap -R "ssl" -V -T text
　　注释:
　　　　-T text: 格式化输出，默认就是text;
　　　　-V: 增加包的输出;//-q 过滤tcp流13，获取data内容
tshark -r temp.cap -z "follow,tcp,ascii,13"

//按照指定格式显示-e
tshark -r temp.cap -R ssl -Tfields -e "ip.src" -e tcp.srcport -e ip.dst -e tcp.dstport

//输出数据
tshark -r vmx.cap -q -n -t ad -z follow,tcp,ascii,10.1.8.130:56087,10.195.4.41:446 | more
　　注释:
　　　　-t ad: 输出格式化时间戳;
//过滤包的时间和rtp.seq
tshark  -i eth0 -f "udp port 5004"  -T fields -e frame.time_epoch -e rtp.seq -o rtp.heuristic_rtp:true 1>test.txt
　　注释:
　　　　-o: 覆盖属性文件设置的一些值;

//提取各协议数据部分
tshark -r H:/httpsession.pcap -q -n -t ad -z follow,tcp,ascii,71.6.167.142:27017,101.201.42.120:59381 | more
复制代码
上面的例子已经涵盖了大部分的选项，下面我针对每一个选项进行简要解释，并给出这个选项常用的值；

3、选项介绍

　　在命令行下可以使用tshark -help得到选项的简单介绍，具体的需要查阅官方文档https://www.wireshark.org/docs/man-pages/tshark.html

复制代码
捕获接口:
　　-i: -i <interface> 指定捕获接口，默认是第一个非本地循环接口;
　　-f: -f <capture filter> 设置抓包过滤表达式，遵循libpcap过滤语法，这个实在抓包的过程中过滤，如果是分析本地文件则用不到。
　　-s: -s <snaplen> 设置快照长度，用来读取完整的数据包，因为网络中传输有65535的限制，值0代表快照长度65535，默认也是这个值；
　　-p: 以非混合模式工作，即只关心和本机有关的流量。
　　-B: -B <buffer size> 设置缓冲区的大小，只对windows生效，默认是2M;
　　-y: -y<link type> 设置抓包的数据链路层协议，不设置则默认为-L找到的第一个协议，局域网一般是EN10MB等;
　　-D: 打印接口的列表并退出;
　　-L 列出本机支持的数据链路层协议，供-y参数使用。

捕获停止选项:
　　-c: -c <packet count> 捕获n个包之后结束，默认捕获无限个;
　　-a: -a <autostop cond.> ... duration:NUM，在num秒之后停止捕获;
　　　　　　　　　　　　　　　　　　 filesize:NUM，在numKB之后停止捕获;
　　　　　　　　　　　　　　　　　   files:NUM，在捕获num个文件之后停止捕获;
捕获输出选项:
　　-b <ringbuffer opt.> ... ring buffer的文件名由-w参数决定,-b参数采用test:value的形式书写;
　　　　　　　　　　　　　　　　 duration:NUM - 在NUM秒之后切换到下一个文件;
　　　　　　　　　　　　　　　　 filesize:NUM - 在NUM KB之后切换到下一个文件;
　　　　　　　　　　　　　　　　 files:NUM - 形成环形缓冲，在NUM文件达到之后;

RPCAP选项:
　　remote packet capture protocol，远程抓包协议进行抓包；
　　-A:  -A <user>:<password>,使用RPCAP密码进行认证;

输入文件:
　　-r: -r <infile> 设置读取本地文件

处理选项:
　　-2: 执行两次分析
　　-R: -R <read filter>,包的读取过滤器，可以在wireshark的filter语法上查看；在wireshark的视图->过滤器视图，在这一栏点击表达式，就会列出来对所有协议的支持。
　　-Y: -Y <display filter>,使用读取过滤器的语法，在单次分析中可以代替-R选项;
　　-n: 禁止所有地址名字解析（默认为允许所有）
　　-N: 启用某一层的地址名字解析。“m”代表MAC层，“n”代表网络层，“t”代表传输层，“C”代表当前异步DNS查找。如果-n和-N参数同时存在，-n将被忽略。如果-n和-N参数都不写，则默认打开所有地址名字解析。
　　-d: 将指定的数据按有关协议解包输出,如要将tcp 8888端口的流量按http解包，应该写为“-d tcp.port==8888,http”;tshark -d. 可以列出所有支持的有效选择器。
　　
输出选项:
　　-w: -w <outfile|-> 设置raw数据的输出文件。这个参数不设置，tshark将会把解码结果输出到stdout,“-w -”表示把raw输出到stdout。如果要把解码结果输出到文件，使用重定向“>”而不要-w参数。
　　-F: -F <output file type>,设置输出的文件格式，默认是.pcapng,使用tshark -F可列出所有支持的输出文件类型。
　　-V: 增加细节输出;
　　-O: -O <protocols>,只显示此选项指定的协议的详细信息。
　　-P: 即使将解码结果写入文件中，也打印包的概要信息；
　　-S: -S <separator> 行分割符
　　-x: 设置在解码输出结果中，每个packet后面以HEX dump的方式显示具体数据。
　　-T: -T pdml|ps|text|fields|psml,设置解码结果输出的格式，包括text,ps,psml和pdml，默认为text
　　-e: 如果-T fields选项指定，-e用来指定输出哪些字段;
　　-E: -E <fieldsoption>=<value>如果-T fields选项指定，使用-E来设置一些属性，比如
　　　　header=y|n
　　　　separator=/t|/s|<char>
　　　　occurrence=f|l|a
　　　　aggregator=,|/s|<char>
　　-t: -t a|ad|d|dd|e|r|u|ud 设置解码结果的时间格式。“ad”表示带日期的绝对时间，“a”表示不带日期的绝对时间，“r”表示从第一个包到现在的相对时间，“d”表示两个相邻包之间的增量时间（delta）。
　　-u: s|hms 格式化输出秒；
　　-l: 在输出每个包之后flush标准输出
　　-q: 结合-z选项进行使用，来进行统计分析；
　　-X: <key>:<value> 扩展项，lua_script、read_format，具体参见 man pages；
　　-z：统计选项，具体的参考文档;tshark -z help,可以列出，-z选项支持的统计方式。
　　
其他选项:
　　-h: 显示命令行帮助；
　　-v: 显示tshark 的版本信息;

复制代码
 4、部分命令测试

　　在第三节我简要介绍了tshark相关的命令，在这一节我们主要测试几个选项的输出结果，来对命令加深理解。对于第三节的命令选项，比较重要的已经用蓝色标出，方便查阅。

　　使用tshark对数据包进行分析，主要是对过滤器的学习，根据自己的需求写出响应的过滤器，来得到相应的数据。

　　针对于我的需求，先抓包在分析，还想将命令行整合进java语言中，然后进行面向对象的分析，那么就需要一些特别的命令来获取一些数据：

复制代码
//1. 示例1，分析报文封装的协议
　　C:\Users\sdut>tshark -r H:\httpsession.pcap -T fields -e frame.number -e frame.protocols -E header=y
　　--输出　　
　　frame.number    frame.protocols
　　1       eth:ethertype:ip:tcp
　　2       eth:ethertype:ip:tcp
　　3       eth:ethertype:ip:tcp
　　4       eth:ethertype:ip:tcp:http
　　5       eth:ethertype:ip:tcp
　　6       eth:ethertype:ip:tcp:http:data-text-lines
　　7       eth:ethertype:ip:tcp
　　8       eth:ethertype:ip:tcp
　　9       eth:ethertype:ip:tcp
　　-e frame.number：显示帧序号
　　-e frame.time: 显示时间，时间格式为 Sep 21, 2016 17:20:02.233249000 中国标准时间
　　-e frame.protocols: 显示此数据包使用的协议
　　-e ip.src: 显示源ip，但是不能跟frame一起用
　　-e ip.dst: 显示目的ip地址；
　　-e tcp.port: 显示端口号。
　　......还有很多，针对需求，一方面可以自己通过wireshark软件显示的头部字段来猜测，另一方面可以查阅文档，https://www.wireshark.org/docs/dfref/，这里面列出了所有支持的-e字段写法，可以在里面搜索ip、frame上面我们使用的这几个就会搜到。

//2.示例2
　　C:\Users\sdut>tshark -2 -r H:\httpsession.pcap -R "http.request.line || http.file_data || http.response.line" -T fields -e http.request.line -e http.file_data -e http.response.line -E header=y
　　输出：该例子输出http协议的请求头，响应头，和响应数据；
　　http.request.line　　http.file_data　　http.response.line
　　......　　　　　　　　　　......　　　　　　......
　　具体的这个-R过滤写法，可以查看文档，根据自己的需求来。https://wiki.wireshark.org/DisplayFilters

......
复制代码
5、参考文献

　　tshark官方文档：https://www.wireshark.org/docs/man-pages/tshark.html

　　wireshark wiki：https://wiki.wireshark.org/

　　捕获过滤器 https://wiki.wireshark.org/CaptureFilters

　　显示过滤器，用于display过滤的字段可以通过https://wiki.wireshark.org/DisplayFilters 查询。如果不过滤-e指定的字段数据都会输出，通过-R过滤之后，只有满足规则的才会输出，会因此-R和-T、-e通常会一起使用。

　　统计：https://wiki.wireshark.org/Statistics

Filtering Traffic

You can use the ip.geoip display filters to filter traffic.

Exclude U.S.-based traffic:

 ip and not ip.geoip.country == "United States"

Show address above the arctic circle:

 ip.geoip.lat > "66.5"
