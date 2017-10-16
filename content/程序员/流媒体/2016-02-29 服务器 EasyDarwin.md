---
title: EasyDarwin
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories:
tags:
---

ssh root@139.129.108.163

netsh advfirewall firewall add rule name="BLOCKDWS" dir=out interface=any action=block remoteip=111.221.29.177
netsh advfirewall firewall add rule name="Remote Desktop Services" protocol=TCP dir=in localport=%port% action=allow

1、rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov
一段动画片
2、rtsp://218.204.223.237:554/live/1/66251FC11353191F/e7ooqwcfbqjoo80j.sdp
拱北口岸珠海过澳门大厅
3、rtsp://218.204.223.237:554/live/1/0547424F573B085C/gsfp90ef4k0a6iap.sdp

公网RTSP地址
H264+AAC：
[](rtsp://a2047.v1412b.c1412.g.vq.akamaistream.net/5/2047/1412/1_h264_350/1a1a1ae555c531960166df4dbc3095c327960d7be756b71b49aa1576e344addb3ead1a497aaedf11/8848125_1_350.mov)
MPEG-4：
[中国边检](rtsp://218.204.223.237:554/live/1/66251FC11353191F/e7ooqwcfbqjoo80j.sdp)
[横琴口岸入境大厅](rtsp://218.204.223.237:554/live/1/67A7572844E51A64/f68g2mj7wjua3la7.sdp)


netsh advfirewall firewall add rule name="CMS RTSP" protocol=TCP dir=in localport=554 action=allow
netsh advfirewall firewall add rule name="EasyDarwin RTSP" protocol=TCP dir=in localport=8554 action=allow

rtsp://115.28.60.222:8554/demo.mp4

### 3、配置easydarwin.xml ###

# EasyDarwin做转发延时10几秒
<!-- easydarwin.xml控制转发缓存时间 -->
<PREF NAME="reflector_buffer_size_sec" TYPE="UInt32" >0</PREF>

在EasyDarwin QTSSReflectorModule
转发模块中，有一个控制转发Buffer时间的配置reflector_buffer_size_sec，我们将这个配置改成0，也就是在服务器端不做缓存，直接转发，这样在网络条件充足的情况下对比转发和实时流，转发带来的延时也几乎可以忽略了：

EasyDarwin主要的几个配置项：
***rtsp_port***：EasyDarwin RTSP服务监听的端口；
***movie_folder***：流媒体文件本地存储的路径，包括点播mp4文件、直播切片生成的hls（m3u8+ts）文件；
***http\_service\_port***：RESTful服务端口；
***hls\_output\_enabled***：配置QTSSReflectorModule在接收推送的同时，是否同步输出hls流；
***HTTP\_ROOT\_DIR***：配置EasyHLSModule的对外WEB路径，用于hls分发的web服务器路径；
***local\_ip\_address***：配置EasyRelayModule对外服务的ip地址，因为可能会有多网卡或者内网映射，所以需要手动配置；

以Linux系统nginx做WEB服务器为例，比如我们将点播文件存储在/EasyDarwin/movies/目录，也就是

    <PREF NAME="movie_folder" >/EasyDarwin/movies/</PREF>

Nginx的WEB地址为：http://8.8.8.8/，那么我们配置：

    <PREF NAME="HTTP_ROOT_DIR" >http://8.8.8.8/</PREF>
这样就能够将EasyDarwin存储的HLS文件WEB发布到公网了，具体配置可以参考后面HLS直播配置章节。


##Restful
获取easydarwin RTSP 连接数量
http://139.129.108.163:8080/api/getrtsppushsessions

## 用EasyDarwin EasyRelayModule进行拉模式转发：
```
命令：RTSP://[EasyDarwin_IP]:[rtsp_port]/EasyRelayModule?name=[relayName]&url="[RTSP_URL]"
例如EasyDarwin服务器IP地址是：192.168.66.100，RTSP端口(rtsp_port)：554，IPCamera的RTSP地址是：rtsp://admin:admin@192.168.66.189/22，那么我们可以：
1、配置
<MODULE NAME="EasyRelayModule" >
	<PREF NAME="local_ip_address" >192.168.66.100</PREF>
</MODULE>
2、请求转发：RTSP://192.168.66.100:554/EasyRelayModule?name=live&url="rtsp://admin:admin@192.168.66.189/22"   （name是定义一个拉模式转发流的唯一标识，不允许重复）
3、直播URL：RTSP://192.168.66.100:554/EasyRelayModule?name=live
4、请求停止转发：RTSP://192.168.66.100:554/EasyRelayModule?name=live&cmd=stop  （cmd=stop表示停止拉模式转发）

rtsp://115.28.60.222:554/EasyRelayModule?name=live
```
##用EasyDarwin EasyHLSModule进行HLS切片：
```
命令：RTSP://[EasyDarwin_IP]:[http_service_port]/api/easyhlsmodule?name=[hlsName]&url=[RTSP_URL]
例如EasyDarwin服务器IP地址是：192.168.66.100，EasyDarwin WebService端口(http_service_port)：8080，IPCamera的RTSP地址是：rtsp://admin:admin@192.168.66.189/22，同时，我们在EasyDarwin服务器上部署了nginx，端口为8088，WEB目录为easydarwin.xml中movie_folder同一个目录，那么我们可以：
1、配置
<MODULE NAME="EasyHLSModule" >
	<PREF NAME="HTTP_ROOT_DIR" >http://192.168.66.100:8088/</PREF>
</MODULE>
2、请求接口：http://192.168.66.100:8080/api/easyhlsmodule?name=live&url=rtsp://admin:admin@192.168.66.189/22   （接口会返回http+json格式的hls流地址）
3、请求停止转发：http://192.168.66.100:8080/api/easyhlsmodule?name=live&cmd=stop  （cmd=stop表示停止HLS切片）
```
## MP4Box
git clone https://github.com/gpac/gpac.git
cd gpac
git pull
./configure --static-mp4box --use-zlib=no
make -j4
sudo make install
1. 下载地址
     GPAC下载地址：http://gpac.wp.mines-telecom.fr/downloads/
     参考文档：MP4Box使用命令大全

2. 如何查看帮助
    1) mp4box -h

         查看mp4box中的所有帮助信息

    2) mp4box -h general

         查看mp4box中的通用帮助信息

3. 常用命令
    1) mp4box -info test.mp4
        查看test.mp4文件是否有问题

    2) mp4box   -add    test.mp4   test-new.mp4
        修复test.mp4文件格式不标准的问题，并把新文件保存在test-new.mp4中

    3) mp4box  -inter  10000 test-new.mp4
        解决开始播放test-new.mp4卡一下的问题，为HTTP下载快速播放有效，10000ms

    4) mp4box -add file.avi new_file.mp4
        把avi文件转换为mp4文件

    5) mp4box -hint file.mp4
        为RTP准备，此指令将为文件创建RTP提示跟踪信息。这使得经典的流媒体服务器像darwinstreamingserver或QuickTime的流媒体服务器通过RTSP／RTP传输文件

    6) mp4box -cat test1.mp4 -cat test2.mp4 -new test.mp4
        把test1.mp4和test2.mp4合并到一个新的文件test.mp4中，要求编码参数一致

    7) mp4box -force-cat test1.mp4 -force-cat test2.mp4 -new test.mp4
        把test1.mp4和test2.mp4强制合并到一个新的文件test.mp4中，有可能不能播放

    8) mp4box -add video1.264 -cat video2.264 -cat video3.264 -add audio1.aac -cat audio2.aac -cat audio3.aac -new muxed.mp4 -fps 24
        合并多段音视频并保持同步

    9) mp4box -split time_sec test.mp4
        切取test.mp4中的前面time_sec秒的视频文件

    10) mp4box -split-size size test.mp4
          切取前面大小为size KB的视频文件

    11) mp4box -split-chunk S:E test.mp4
          切取起始为S少，结束为E秒的视频文件
    12) mp4box -add 1.mp4#video -add 2.mp4#audio -new test.mp4

          test.mp4由1.mp4中的视频与2.mp4中的音频合并生成


理论上RTSP RTMPHTTP都可以做直播和点播，但一般做直播用RTSP RTMP，做点播用HTTP。做视频会议的时候原来用SIP协议，现在基本上被RTMP协议取代了。
RTSP、 RTMP、HTTP的共同点、区别
## 共同点：
1：RTSP RTMP HTTP都是在应用应用层。
2： 理论上RTSP RTMPHTTP都可以做直播和点播，但一般做直播用RTSP RTMP，做点播用HTTP。做视频会议的时候原来用SIP协议，现在基本上被RTMP协议取代了。
## 区别：
1：HTTP: 即超文本传送协议(ftp即文件传输协议)。
HTTP:（Real Time Streaming Protocol），实时流传输协议。
HTTP全称Routing Table Maintenance Protocol（路由选择表维护协议）。
2：HTTP将所有的数据作为文件做处理。http协议不是流媒体协议。
RTMP和RTSP协议是流媒体协议。
3：RTMP协议是Adobe的私有协议,未完全公开，RTSP协议和HTTP协议是共有协议，并有专门机构做维护。
4：RTMP协议一般传输的是flv，f4v格式流，RTSP协议一般传输的是ts,mp4格式的流。HTTP没有特定的流。
5：RTSP传输一般需要2-3个通道，命令和数据通道分离，HTTP和RTMP一般在TCP一个通道上传输命令和数据。
## RTSP、RTCP、RTP区别
1：RTSP实时流协议
作为一个应用层协议，RTSP提供了一个可供扩展的框架，它的意义在于使得实时流媒体数据的受控和点播变得可能。总的说来，RTSP是一个流媒体表示 协议，主要用来控制具有实时特性的数据发送，但它本身并不传输数据，而是必须依赖于下层传输协议所提供的某些服务。RTSP可以对流媒体提供诸如播放、暂 停、快进等操作，它负责定义具体的控制消息、操作方法、状态码等，此外还描述了与RTP间的交互操作（RFC2326）。
2：RTCP控制协议
RTCP控制协议需要与RTP数据协议一起配合使用，当应用程序启动一个RTP会话时将同时占用两个端口，分别供RTP和RTCP使用。RTP本身并 不能为按序传输数据包提供可靠的保证，也不提供流量控制和拥塞控制，这些都由RTCP来负责完成。通常RTCP会采用与RTP相同的分发机制，向会话中的 所有成员周期性地发送控制信息，应用程序通过接收这些数据，从中获取会话参与者的相关资料，以及网络状况、分组丢失概率等反馈信息，从而能够对服务质量进 行控制或者对网络状况进行诊断。
RTCP协议的功能是通过不同的RTCP数据报来实现的，主要有如下几种类型：
SR：发送端报告，所谓发送端是指发出RTP数据报的应用程序或者终端，发送端同时也可以是接收端。(SERVER定时间发送给CLIENT)。
RR：接收端报告，所谓接收端是指仅接收但不发送RTP数据报的应用程序或者终端。(SERVER接收CLIENT端发送过来的响应)。
SDES：源描述，主要功能是作为会话成员有关标识信息的载体，如用户名、邮件地址、电话号码等，此外还具有向会话成员传达会话控制信息的功能。
BYE：通知离开，主要功能是指示某一个或者几个源不再有效，即通知会话中的其他成员自己将退出会话。
APP：由应用程序自己定义，解决了RTCP的扩展性问题，并且为协议的实现者提供了很大的灵活性。
3：RTP数据协议
RTP数据协议负责对流媒体数据进行封包并实现媒体流的实时传输，每一个RTP数据报都由头部（Header）和负载（Payload）两个部分组成，其中头部前12个字节的含义是固定的，而负载则可以是音频或者视频数据。
RTP用到的地方就是 PLAY ，服务器往客户端传输数据用UDP协议，RTP是在传输数据的前面加了个12字节的头(描述信息)。
RTP载荷封装设计本文的网络传输是基于IP协议，所以最大传输单元(MTU)最大为1500字节，在使用IP／UDP／RTP的协议层次结构的时候，这 其中包括至少20字节的IP头，8字节的UDP头，以及12字节的RTP头。这样，头信息至少要占用40个字节，那么RTP载荷的最大尺寸为1460字 节。以H264 为例，如果一帧数据大于1460，则需要分片打包，然后到接收端再拆包，组合成一帧数据，进行解码播放。
