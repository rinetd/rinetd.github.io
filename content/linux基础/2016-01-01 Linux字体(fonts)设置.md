---
title: Linux字体设置
date: 2016-09-27T15:58:27+08:00
update: 2016-09-27 16:03:41
categories: [Linux基础]
tags: [fonts]
---
[](http://www.losttype.com/browse/)  
[](https://www.fontsquirrel.com/)  
[adobe-fonts](https://github.com/adobe-fonts)  

[fonts.conf 中文手册](http://www.jinbuguo.com/gui/fonts.conf.html)  
[Ubuntu Chrome 中文字体发虚](http://www.findspace.name/res/1388)  
[解决LinuxMint/Ubuntu中文字体发虚的根本之道](http://www.mintos.org/skill/tweak-fonts.html)  
[How To Install New Fonts In Ubuntu 14.04 and 14.10](http://itsfoss.com/install-fonts-ubuntu-1404-1410/)  
[](http://forum.ubuntu.org.cn/viewtopic.php?f=8&t=348963&sid=0b91cf911e81ae41561756bd2cfd0dbd)  
[字体下载](https://www.fontsquirrel.com/)  
[字体口袋](http://www.zitikoudai.com/chinese-fonts/weiruan/Microsoft-Yahei-UI-Light.html)  
################################################################################
# 常用命令
fc-list #查看已安装字体
fc-match sans-serif #抓取当前用户sans-serif类字体优先级最高的那款字体
fc-match serif #抓取当前用户serif类字体优先级最高的那款字体
fc-match monospace #抓取当前用户monospace类字体优先级最高的那款字体

# 字体安装 Install
sudo apt-get install ttf-wqy-*

sudo apt-get remove fonts-noto-cjk #思源黑体
sudo apt-get remove fonts-arphic-ukai fonts-arphic-uming

gsettings set org.gnome.desktop.interface font-name 'THE FONT NAME 11'
gsettings set org.gnome.desktop.interface document-font-name 'THE FONT NAME 11'
# setting
sudo fc-cache -f -v
## 字体相关目录
sudo fc-cache -fv
/usr/share/fonts/ 		#系统默认字体目录
/usr/local/share/fonts	#空
~/.local/share/fonts 	#安装字体目录
~/.fonts								#空

``` 常用字体
Source Code Pro
DejaVu Sans Mono
Inconsolata
```

---
Mac OS的一些：


华文细黑：STHeiti Light [STXihei]
华文黑体：STHeiti
华文楷体：STKaiti
华文宋体：STSong
华文仿宋：STFangsong
俪黑 Pro：LiHei Pro Medium
俪宋 Pro：LiSong Pro Light
标楷体：BiauKai
苹果俪中黑：Apple LiGothic Medium
苹果俪细宋：Apple LiSung Light

Windows的一些：

新细明体：PMingLiU
细明体：MingLiU
标楷体：DFKai-SB
黑体：SimHei
宋体：SimSun
新宋体：NSimSun
仿宋：FangSong
楷体：KaiTi
仿宋_GB2312：FangSong_GB2312
楷体_GB2312：KaiTi_GB2312
微软正黑体：Microsoft JhengHei
微软雅黑体：Microsoft YaHei

装Office会生出来的一些：

隶书：LiSu
幼圆：YouYuan
华文细黑：STXihei
华文楷体：STKaiti
华文宋体：STSong
华文中宋：STZhongsong
华文仿宋：STFangsong
方正舒体：FZShuTi
方正姚体：FZYaoti
华文彩云：STCaiyun
华文琥珀：STHupo
华文隶书：STLiti
华文行楷：STXingkai
华文新魏：STXinwei
