---
title: Linux命令 ffmpeg
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [linux_base]
tags: [ffmpeg]
---

[FFmpeg基础](http://wenku.baidu.com/view/296eefcaf90f76c661371af1.html)
[FFmpeg基本用法](http://blog.csdn.net/doublefi123/article/details/24325159)
[FFmpeg常用基本命令](http://www.cnblogs.com/dwdxdy/p/3240167.html)
[ffmpeg 使用小记](http://blog.csdn.net/hsg1040175759/article/details/18715249)
[ffmpeg常用转换命令，支持WAV转AMR](http://www.cnblogs.com/xiaofengfeng/p/3573025.html)
[用ffmpeg+nginx服务器实现类似酒店视频直播系统](http://www.easydarwin.org/article/Streaming/62.html)
[ffmpeg推送,EasyDarwin转发,vlc播放 实现整个RTSP直播](http://www.easydarwin.org/article/EasyDarwin/30.html)
[ffmpeg处理RTMP流媒体的命令大全](http://blog.csdn.net/leixiaohua1020/article/details/12029543)
[ffmpeg RTMP](http://blog.csdn.net/dongdong_java/article/details/19604975?utm_source=tuicool&utm_medium=referral)
[FFmpeg获取DirectShow设备数据（摄像头，录屏）](http://blog.csdn.net/leixiaohua1020/article/details/38284961)
[基于Nginx搭建mp4/flv流媒体服务器](http://hdu104.com/294)
[M3U8 的简单实现 nginx+ffmpeg](http://www.mamicode.com/info-detail-1164079.html)
[使用FFmpeg生成HLS视频](http://www.cnblogs.com/kuoxin/p/4623642.html)
##############################
 ffmpeg强制使用TCP方式读取rtsp流
 “ffmpeg *-rtsp_transport* tcp -i rtsp://admin.......”
#######

##############################
# 内存虚拟硬盘
sudo mkdir /mnt/ramdisk

sudo mount -t tmpfs tmpfs /mnt/ramdisk  -o size=2G,defaults,noatime,mode=777
sudo mkdir -p /mnt/ramdisk/hls/mystream/
# ffmpeg -loglevel verbose -re -i Android.mp4  -vcodec libx264 -vprofile baseline -acodec libmp3lame -ar 44100 -ac 1    -f flv rtmp://localhost:1935/hls/movie
ffmpeg -loglevel verbose -re -i demo.mp4  -vcodec libx264 -vprofile baseline -acodec libmp3lame -ar 44100 -ac 1    -f flv rtmp://localhost:1935/hls/mystream
## 推送HLS直播
ffmpeg -re -i demo.mp4 -c:v libx264 -c:a aac -f hls -hls_list_size 5 -hls_wrap 5 /mnt/ramdisk/hls/mystream/index.m3u8
sudo ffmpeg -re -i demo.mp4 -c:v libx264 -c:a copy -f hls -hls_list_size 5 -hls_wrap 5 /mnt/ramdisk/hls/mystream/index.m3u8
sudo ffmpeg -re -i demo.mp4 -c:v libx264 -c:a copy -f hls -hls_list_size 5 -hls_wrap 5 /home/ubuntu/EasyDarwin/EasyDarwin/x64/Movies/hls/mystream/index.m3u8

sudo ffmpeg -re -i demo.mp4 -c:v copy -acodec copy  -f rtsp rtsp://139.129.108.163:6554/test.sdp
sudo ffmpeg -re -i demo.mp4 -vcodec copy -acodec copy  -rtsp_transport tcp -f rtsp rtsp://139.129.108.163:6554/test.sdp

sudo ffmpeg -re -i demo.mp4 -vcodec copy -acodec copy  -rtsp_transport tcp -f rtsp rtsp://121.40.50.44:554/test.sdp
1.点播
在对应路径下直接可以播放
2.rtsp直播
ffmpeg -re -i localFile.mp4 -c copy -f flv rtmp://server/live/streamName  
3.实现hls直播
rtmp{
    server {
        listen 1935;

        application myapp {
            live on;
            exec ffmpeg -i rtmp://localhost/myapp/$name -c:a copy  -c:v libx264 -b:v 512K -g 30 -f flv rtmp://localhost/hls/$name_low;
        }

        application hls {
            live on;
            hls on;
            hls_path /mnt/ramdisk/hls;
            hls_nested on;
            hls_fragment 2s;
            hls_playlist_length 6s;
            hls_variant_hi  BANDWIDTH=640000;
        }
    }
}
http{
    server {
        location /hls {
            types {
                application/x-mpegURL m3u8;
                application/vnd.apple.mpegusr m3u8;
                video/mp2t ts;
            }
            root /mnt/ramdisk;
            # alias /usr/local/nginx/html/hls/;
            add_header Cache-Control no-cache;
        }   
    }
}

ffmpeg -loglevel verbose -re -i demo.mp4  -vcodec libx264 -vprofile baseline -acodec libmp3lame -ar 44100 -ac 1    -f flv rtmp://localhost:1935/hls/mystream
[测试地址](http://www.cutv.com/demo/live_test.swf)
http://127.0.0.1:8080/hls/mystream.m3u8

http://192.168.1.108/hls/mystream/index.m3u8

## Nginx RTMP

实现rtmp 转播
ffmpeg -i rtsp://218.204.223.237:554/live/1/67A7572844E51A64/f68g2mj7wjua3la7.sdp -vcodec copy -acodec copy  -f flv rtmp://localhost:1935/myapp/mystream
实现hls转播
ffmpeg -i rtsp://218.204.223.237:554/live/1/67A7572844E51A64/f68g2mj7wjua3la7.sdp -vcodec copy -acodec copy  -f flv rtmp://localhost:1935/hls/mystream

#######easyDarwin###############
[ffmpeg推送,EasyDarwin转发,vlc播放 实现整个RTSP直播]
2、例如，我们的摄像机地址是 rtsp://admin:admin@192.168.66.119/，ffmpeg命令如下：
ffmpeg -i rtsp://218.204.223.237:554/live/1/67A7572844E51A64/f68g2mj7wjua3la7.sdp -vcodec copy -acodec copy  -rtsp_transport tcp -f rtsp rtsp://127.0.0.1/test.sdp

也可以进行音视频转码后推送：
ffmpeg -i rtsp://218.204.223.237:554/live/1/67A7572844E51A64/f68g2mj7wjua3la7.sdp -vcodec libx264 -an  -rtsp_transport tcp -f rtsp rtsp://127.0.0.1/test.sdp


第一步：用ffmpeg将网络直播源拉取到内网，切片成m3u8+ts（这里我们假设直播源为：http://111.1.62.218/gitv_live/CCTV-1-HD/CCTV-1-HD.m3u8）

执行命令：ffmpeg -i http://111.1.62.218/gitv_live/CCTV-1-HD/CCTV-1-HD.m3u8 -f hls -hls_list_size 5 -hls_time 10 -hls_wrap 10 ./live/live.m3u8
###################
1.分离视频音频流

ffmpeg -i input_file -vcodec copy -an output_file_video　　//分离视频流
ffmpeg -i input_file -acodec copy -vn output_file_audio　　//分离音频流
2.视频解复用

ffmpeg –i test.mp4 –vcodec copy –an –f m4v test.264
ffmpeg –i test.avi –vcodec copy –an –f m4v test.264
3.视频转码

ffmpeg –i test.mp4 –vcodec h264 –s 352*278 –an –f m4v test.264              //转码为码流原始文件
ffmpeg –i test.mp4 –vcodec h264 –bf 0 –g 25 –s 352*278 –an –f m4v test.264  //转码为码流原始文件
ffmpeg –i test.avi -vcodec mpeg4 –vtag xvid –qsame test_xvid.avi            //转码为封装文件
//-bf B帧数目控制，-g 关键帧间隔控制，-s 分辨率控制
4.视频封装

ffmpeg –i video_file –i audio_file –vcodec copy –acodec copy output_file
5.视频剪切

ffmpeg –i test.avi –r 1 –f image2 image-%3d.jpeg        //提取图片
ffmpeg -ss 0:1:30 -t 0:0:20 -i input.avi -vcodec copy -acodec copy output.avi    //剪切视频
//-r 提取图像的频率，-ss 开始时间，-t 持续时间
6.视频录制

ffmpeg –i rtsp://192.168.3.205:5555/test –vcodec copy out.avi
7.YUV序列播放

ffplay -f rawvideo -video_size 1920x1080 input.yuv
8.YUV序列转AVI

ffmpeg –s w*h –pix_fmt yuv420p –i input.yuv –vcodec mpeg4 output.avi

常用参数说明：

主要参数：
-i 设置输入流
-f 设置输出格式
-ss 开始时间
-re 按照帧率发送

视频参数：
-b 设定视频流量，默认为200Kbit/s
-b:v  设置码率-b bitrate          video bitrate (please use -b:v)
-r 设定帧速率，默认为25
-s 设定画面的分辨率 -s 640x480
-aspect 设定画面的比例
-vn 不处理视频
-vcodec 设定视频编解码器，未设定时则使用与输入流相同的编解码器
-c:v  设置视频编码器

音频参数：
-ar 设定采样率
-ac 设定声音的Channel数
-acodec 设定声音编解码器，未设定时则使用与输入流相同的编解码器
-an 不处理音频
-c:a  设置音频编码器

ffmpeg -formats       #查看所有支持的容器格式
ffmpeg -codecs        #查看所有编解码器
ffmpeg -filters       #查看所有可用的filter
                    -vf 视频过滤器 -vf filter_graph    set video filters
                    -vf setpts=PTS/3 3倍视频

                    -af 音频过滤器
                    -af atempo=2
ffmpeg -pix_fmts      #查看所有支持的图片格式
ffmpeg -sample_fmts   #查看所有支持的像素格式
ffprobe -i money.mp4  #查看媒体信息

-buildconf          show build configuration
-formats            show available formats
-devices            show available devices
-codecs             show available codecs
                   D..... = Decoding supported
                   .E.... = Encoding supported
                   ..V... = Video codec
                   ..A... = Audio codec
                   ..S... = Subtitle codec
                   ...I.. = Intra frame-only codec
                   ....L. = Lossy compression
                   .....S = Lossless compression
                   -c:v  libx264 设置视频编码器
                   -c:a  设置音频编码器

-decoders           show available decoders
-encoders           show available encoders
-protocols          show available protocols


格式转换
ffmpeg -i money.mp4 -c:v mpeg2video -b:v 500k -c:a libmp3lame -f mpegts money.ts
ffmpeg -i money.mp4 -c:v libx264 -minrate:v 500k -maxrate:v 500k -bufsize:v 125k -c:a libmp3lame -f mpegts money.ts
ffmpeg -i money.mp4 -c:v libx264 -x264opts bitrate=500:vbv-maxrate=500:vbv-bufsize=166:nal_hrd=cbr  -c:a libmp3lame -f mpegts money_cbr_500k.ts
-i    输入文件名
-f    设置文件输出格式（容器）
-c:v  设置视频编码器
-c:a  设置音频编码器
-b:v  设置码率-b bitrate          video bitrate (please use -b:v)
-minrate:v 500k -maxrate:v 500k -bufsize:v 125k  设置CBR（不太好用）
-x264opts bitrate=500:vbv-maxrate=500:vbv-bufsize=166:nal_hrd=cbr  设置CBR（好用）

选择其中第一个视频流输出，设置码率
ffmpeg -i money.mp4 -map 0:v:0 -c:v libx264 -b:v 500k money_500k.mp4
ffmpeg -i money.mp4 -map 0:v:0 -c:v libx264 -b:v 300k money_300k.mp4
ffmpeg -i money.mp4 -map 0:v:0 -c:v libx264 -b:v 100k -s 336x188 money_100k.mp4
选择其中第一个音频流输出
ffmpeg -i money.mp4 -map 0:a:0 money_audio.mp4

####

[ffmpeg RTMP]
1、ffmpeg 推送视频文件，音视频的编码格式只能为H264、AAC。
    ffmpeg -re -i "E:\片源\复仇者联盟720p.mov" -vcodec copy -acodec copy -f flv rtmp://192.168.11.75/live/test1  
    ffmpeg -re -i "E:\片源\复仇者联盟720p.mov" -vcodec copy -acodec copy -f flv rtmpt://192.168.11.75:8080/live/test1

2、网络摄像机 rtsp流转推rtmp直播(不过有丢包情况，还请大家多给指点)
	ffmpeg -i rtsp://ip address/original -crf 30 -preset ultrafast -acodec aac -strict experimental -ar 44100 -ac 2 -b:a 96k -vcodec libx264 -r 25 -b:v 500k -s 640*480 -f flv rtmp://ip address/live/stram

转换为flv:
    ffmpeg -i test.mp3 -ab 56 -ar 22050 -b 500 -r 15 -s 320x240 test.flv
    ffmpeg -i test.wmv -ab 56 -ar 22050 -b 500 -r 15 -s 320x240 test.flv

 转换文件格式的同时抓缩微图：
    ffmpeg -i "test.avi" -y -f image2 -ss 8 -t 0.001 -s 350x240 'test.jpg'

  对已有flv抓图：
    ffmpeg -i "test.flv" -y -f image2 -ss 8 -t 0.001 -s 350x240 'test.jpg'

  转换为3gp:
    ffmpeg -y -i test.mpeg -bitexact -vcodec h263 -b 128 -r 15 -s 176x144 -acodec aac -ac 2 -ar 22500 -ab 24 -f 3gp test.3gp
    ffmpeg -y -i test.mpeg -ac 1 -acodec amr_nb -ar 8000 -s 176x144 -b 128 -r 15 test.3gp


###################
先把ts流中的格式转换对，可以用以下命令试试：
ffmpeg -i your.ts -acodec copy -vcodec libx264 new.h264.ts
利用ffmepg把ts文件转m3u8并切片
ffmpeg -i 12生肖.ts -c copy -map 0 -f segment -segment_list playlist.m3u8 -segment_time 10 output%03d.ts

ffmpeg -i test456.mp4 -f  segment -segment_time 10  -segment_format mpegts -segment_listlist_file.m3u8 -codec copy -bsf:v h264_mp4toannexb -map 0 output_file-%d.ts

音频转换：

1.转换amr到mp3：

ffmpeg -i shenhuxi.amr amr2mp3.mp3
2.转换amr到wav：

ffmpeg -acodec libamr_nb -i shenhuxi.amr amr2wav.wav
3.转换mp3到wav：

ffmpeg -i DING.mp3 -f wav test.wav
4.转换wav到amr：

ffmpeg -i test.wav -acodec libamr_nb -ab 12.2k -ar 8000 -ac 1 wav2amr.amr

ffmpeg.exe -i PA003.wav -ar 8000 -ab 12.2k -ac 1 target.amr  此方法验证通过
文章来自http://blog.csdn.net/tylz04/article/details/9041739
测试程序下载：http://files.cnblogs.com/xiaofengfeng/WavConvertAmr.zip 已测试过将WAV转AMR格式。
下载地址http://ftp.pconline.com.cn/d56bb83a0a66440d54ef5473f548e4b9/pub/download/201010/ffmpeg-20131021.zip
5.转换wav到mp3：

ffmpeg -i test.wav -f mp3 -acodec libmp3lame -y wav2mp3.mp3
视频转换：

1.转换wmv到mp4：

ffmpeg -i sample.wmv -vcodec libx264 -acodec aac out.mp4
2.抓取H264视频流：

ffmpeg -i sample.flv -vcodec copy -vbsf h264_mp4toannexb -an out.h264
 2.1 vbsf为过滤方法，即将flv规定的H264组织方式转换回H264协议书规定的字节流格式  2.2 -an 禁掉源文件中的音频，因为出来的码流不需要音频  2.3 vcodec copy这个是必然的

3.将H264视频流转为mp4:

ffmpeg -i sample.h264 -f mp4 haha.mp4
4.接收rtsp并存为视频文件：

ffmpeg -rtsp_transport tcp -i rtsp://streaming1.osu.edu/media2/ufsap/ufsap.mov -vcodec copy -acodec copy -t 30 -f mp4 rtsp-out.mp4
4.1 -rtsp_transport tcp:指明传输方式是tcp方式(也可以是udp)

4.2 -t 30：指明我录制30秒


ffmpeg将音频或视频编码为AMR格式音频

Android编码的MP4音频格式可能为AMR，这时候用以下命令可以从MP4中直接提取AMR音频：
ffmpeg -i test.mp4 -c:a copy test.amr
将其他格式的音频或视频转成AMR的命令：
新写法：
ffmpeg -i test.mp4 -c:a libopencore_amrnb -ac 1 -ar 8000 -b:a 12.20k -y test.amr
旧写法：
ffmpeg -i test.mp4 -acodec libopencore_amrnb -ac 1 -ar 8000 -ab 12.20k -y test.amr
#####################################
 FFmpeg发送流媒体的命令（UDP，RTP，RTMP）
 这两天研究了FFmpeg发送流媒体的命令，在此简单记录一下以作备忘。
1.      UDP
1.1. 发送H.264裸流至组播地址
注：组播地址指的范围是224.0.0.0—239.255.255.255
下面命令实现了发送H.264裸流“chunwan.h264”至地址udp://233.233.233.223:6666

ffmpeg -re -i chunwan.h264 -vcodec copy -f h264 udp://233.233.233.223:6666  
注1：-re一定要加，代表按照帧率发送，否则ffmpeg会一股脑地按最高的效率发送数据。
注2：-vcodec copy要加，否则ffmpeg会重新编码输入的H.264裸流。
1.2. 播放承载H.264裸流的UDP

ffplay -f h264 udp://233.233.233.223:6666  
注：需要使用-f说明数据类型是H.264
播放的时候可以加一些参数，比如-max_delay，下面命令将-max_delay设置为100ms：

ffplay -max_delay 100000 -f h264 udp://233.233.233.223:6666  
1.3. 发送MPEG2裸流至组播地址
下面的命令实现了读取本地摄像头的数据，编码为MPEG2，发送至地址udp://233.233.233.223:6666。

ffmpeg -re -i chunwan.h264 -vcodec mpeg2video -f mpeg2video udp://233.233.233.223:6666  
1.4.  播放MPEG2裸流
指定-vcodec为mpeg2video即可。

ffplay -vcodec mpeg2video udp://233.233.233.223:6666  
2.      RTP
2.1. 发送H.264裸流至组播地址。
下面命令实现了发送H.264裸流“chunwan.h264”至地址rtp://233.233.233.223:6666

ffmpeg -re -i chunwan.h264 -vcodec copy -f rtp rtp://233.233.233.223:6666>test.sdp  
注1：-re一定要加，代表按照帧率发送，否则ffmpeg会一股脑地按最高的效率发送数据。
注2：-vcodec copy要加，否则ffmpeg会重新编码输入的H.264裸流。
注3：最右边的“>test.sdp”用于将ffmpeg的输出信息存储下来形成一个sdp文件。该文件用于RTP的接收。当不加“>test.sdp”的时候，ffmpeg会直接把sdp信息输出到控制台。将该信息复制出来保存成一个后缀是.sdp文本文件，也是可以用来接收该RTP流的。加上“>test.sdp”后，可以直接把这些sdp信息保存成文本。

2.2. 播放承载H.264裸流的RTP。

ffplay test.sdp  
3.      RTMP
3.1. 发送H.264裸流至RTMP服务器（FlashMedia Server，Red5等）
面命令实现了发送H.264裸流“chunwan.h264”至主机为localhost，Application为oflaDemo，Path为livestream的RTMP URL。

ffmpeg -re -i chunwan.h264 -vcodec copy -f flv rtmp://localhost/oflaDemo/livestream  
3.2. 播放RTMP

ffplay “rtmp://localhost/oflaDemo/livestream live=1”  
注：ffplay播放的RTMP URL最好使用双引号括起来，并在后面添加live=1参数，代表实时流。实际上这个参数是传给了ffmpeg的libRTMP的。
有关RTMP的处理，可以参考文章：ffmpeg处理RTMP流媒体的命令大全

4.     测延时
4.1.测延时
测延时有一种方式，即一路播放发送端视频，另一路播放流媒体接收下来的流。播放发送端的流有2种方式：FFmpeg和FFplay。
通过FFplay播放是一种众所周知的方法，例如：

ffplay -f dshow -i video="Integrated Camera"  
即可播放本地名称为“Integrated Camera”的摄像头。
此外通过FFmpeg也可以进行播放，通过指定参数“-f sdl”即可。例如：

ffmpeg -re -i chunwan.h264 -pix_fmt yuv420p –f sdl xxxx.yuv -vcodec copy -f flv rtmp://localhost/oflaDemo/livestream  
就可以一边通过SDL播放视频，一边发送视频流至RTMP服务器。
注1：sdl后面指定的xxxx.yuv并不会输出出来。
注2：FFmpeg本身是可以指定多个输出的。本命令相当于指定了两个输出。
###############################
[ffmpeg处理RTMP流媒体的命令大全]
最近浏览国外网站时候发现，翻译不准确的敬请谅解。

1、将文件当做直播送至live
[plain] view plain copy
ffmpeg -re -i localFile.mp4 -c copy -f flv rtmp://server/live/streamName  
2、将直播媒体保存至本地文件
[plain] view plain copy
ffmpeg -i rtmp://server/live/streamName -c copy dump.flv  
3、将其中一个直播流，视频改用h264压缩，音频不变，送至另外一个直播服务流
[plain] view plain copy
ffmpeg -i rtmp://server/live/originalStream -c:a copy -c:v libx264 -vpre slow -f flv rtmp://server/live/h264Stream  
4、将其中一个直播流，视频改用h264压缩，音频改用faac压缩，送至另外一个直播服务流
[plain] view plain copy
ffmpeg -i rtmp://server/live/originalStream -c:a libfaac -ar 44100 -ab 48k -c:v libx264 -vpre slow -vpre baseline -f flv rtmp://server/live/h264Stream  
5、将其中一个直播流，视频不变，音频改用faac压缩，送至另外一个直播服务流
[plain] view plain copy
ffmpeg -i rtmp://server/live/originalStream -acodec libfaac -ar 44100 -ab 48k -vcodec copy -f flv rtmp://server/live/h264_AAC_Stream  
6、将一个高清流，复制为几个不同视频清晰度的流重新发布，其中音频不变
[plain] view plain copy
ffmpeg -re -i rtmp://server/live/high_FMLE_stream -acodec copy -vcodec x264lib -s 640×360 -b 500k -vpre medium -vpre baseline rtmp://server/live/baseline_500k -acodec copy -vcodec x264lib -s 480×272 -b 300k -vpre medium -vpre baseline rtmp://server/live/baseline_300k -acodec copy -vcodec x264lib -s 320×200 -b 150k -vpre medium -vpre baseline rtmp://server/live/baseline_150k -acodec libfaac -vn -ab 48k rtmp://server/live/audio_only_AAC_48k  
7、功能一样，只是采用-x264opts选项
[plain] view plain copy
ffmpeg -re -i rtmp://server/live/high_FMLE_stream -c:a copy -c:v x264lib -s 640×360 -x264opts bitrate=500:profile=baseline:preset=slow rtmp://server/live/baseline_500k -c:a copy -c:v x264lib -s 480×272 -x264opts bitrate=300:profile=baseline:preset=slow rtmp://server/live/baseline_300k -c:a copy -c:v x264lib -s 320×200 -x264opts bitrate=150:profile=baseline:preset=slow rtmp://server/live/baseline_150k -c:a libfaac -vn -b:a 48k rtmp://server/live/audio_only_AAC_48k  
8、将当前摄像头及音频通过DSSHOW采集，视频h264、音频faac压缩后发布
[plain] view plain copy
ffmpeg -r 25 -f dshow -s 640×480 -i video=”video source name”:audio=”audio source name” -vcodec libx264 -b 600k -vpre slow -acodec libfaac -ab 128k -f flv rtmp://server/application/stream_name  
9、将一个JPG图片经过h264压缩循环输出为mp4视频
[plain] view plain copy
ffmpeg.exe -i INPUT.jpg -an -vcodec libx264 -coder 1 -flags +loop -cmp +chroma -subq 10 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -flags2 +dct8x8 -trellis 2 -partitions +parti8x8+parti4x4 -crf 24 -threads 0 -r 25 -g 25 -y OUTPUT.mp4  
10、将普通流视频改用h264压缩，音频不变，送至高清流服务(新版本FMS live=1)
[plain] view plain copy
ffmpeg -i rtmp://server/live/originalStream -c:a copy -c:v libx264 -vpre slow -f flv “rtmp://server/live/h264Stream live=1″  
