---
title: mitmproxy
date: 2016-03-29T21:25:45+08:00
update: 2016-01-01
categories: [网络安全]
tags:
---
`sudo pip install mitmproxy`

安装成功后会在生成两个工具`/usr/local/bin/mitmproxy`与`/usr/local/bin/mitmdump`

本人是个开源工具杀手，总会遇到问题

安装问题解决：

如果使用pip安装时，出现pkg_resources.DistributionNotFound:(刚升级了os x Mavericks版本就出现了这个问题)，可以先更新pip

`sudo easy_install --upgrade distributesudo easy_install --upgrade pip`

四、CA证书的安装

要捕获https证书，就得解决证书认证的问题，因此需要在通信发生的客户端安装证书，并且设置为受信任的根证书颁布机构。下面介绍6种客户端的安装方法。

当我们初次运行mitmproxy或mitmdump时，

会在当前目录下生成 ~/.mitmproxy文件夹，其中该文件下包含4个文件，这就是我们要的证书了。
```
mitmproxy-ca.pem 私钥+证书 文本格式
mitmproxy-ca-cert.pem Unix平台使用证书(certificate)格式 文本格式
mitmproxy-ca-cert.cer 与mitmproxy-ca-cert.pem相同，android上使用证书(certificate)格式 文本格式
mitmproxy-ca-cert.p12 windows上使用证书(certificate)格式 文本格式
```
1. Firefox上安装
  preferences-Advanced-Encryption-View Certificates-Import (mitmproxy-ca-cert.pem)-trust this CA to identify web sites

2. chrome上安装
  设置-高级设置-HTTPS/SSL-管理证书-受信任的根证书颁发机构-导入mitmproxy-ca-cert.pem

2. osx上安装
  双击mitmproxy-ca-cert.pem - always trust

3. windows7上安装
  双击mitmproxy-ca-cert.p12-next-next-将所有的证书放入下列存储-受信任的根证书发布机构
4. Android上安装
    将mitmproxy-ca-cert.cer 放到sdcard根目录下 选择设置-安全和隐私-从存储设备安装证书

5. iOS上安装
  将mitmproxy-ca-cert.pem发送到iphone邮箱里，通过浏览器访问/邮件附件

我将证书放在了vps上以供下载

http://tanjiti.com/crt/mitmproxy-ca-cert.pem mitmproxy iOS
http://tanjiti.com/crt/mitmproxy-ca-cert.cer mitmproxy android
http://tanjiti.com/crt/mitmproxy-ca-cert.p12 windows
http://tanjiti.com/crt/PortSwigger.cer BurpSuite (burpsuite的证书，随便附上)

6.iOS模拟器上安装
git clone https://github.com/ADVTOOLS/ADVTrustStore.gitcd ADVTrustStore/
DANI-LEE-2:ADVTrustStore danqingdani$ python iosCertTrustManager.py -a ~/iostools/mitmproxy-ca-cert.pem
subject= CN = mitmproxy, O = mitmproxyImport certificate to iPhone/iPad simulator v5.1 [y/N] y Importing to /Users/danqingdani/Library/Application Support/iPhone Simulator/5.1/Library/Keychains/TrustStore.sqlite3 Certificate added

实际上上面的操作就是给 ~/Library/Application\ Support/iPhone\ Simulator/5.1/Library/Keychains/TrustStore.sqlite3 数据库中表tsettings表中插入证书数据


五、工具使用

在vps上装好了mitmproxy代理，在客户端也装好了CA证书，接下来就可以使用了。

第一步：在vps上启动mitmproxy

`mitmproxy -b xxx.xxx.xxx(指定监听的接口) -p xxx(指定端口)`

果然我是开源工具杀手，运行时又报错了。

运行错误问题解决：

当运行mitmproxy报错：
Error: mitmproxy requires a UTF console environment.
Set your LANG enviroment variable to something like en_US.UTF-8
你可以先运行locale查看当前的语言环境，我的vps就是POSIX环境
root@www:/# locale
LANG=
LANGUAGE=
LC_CTYPE="POSIX"
LC_NUMERIC="POSIX"
LC_TIME="POSIX"
LC_COLLATE="POSIX"
LC_MONETARY="POSIX"
LC_MESSAGES="POSIX"
LC_PAPER="POSIX"
LC_NAME="POSIX"
LC_ADDRESS="POSIX"
LC_TELEPHONE="POSIX"
LC_MEASUREMENT="POSIX"
LC_IDENTIFICATION="POSIX"
LC_ALL=

现在我们需要的是把其修改为en_US.UTF-8

方法参考http://jrs-s.net/2010/11/18/setting-locale-to-utf-8-in-debian/

vim /etc/default/localeLANG=en_US.UTF-8. locale-gen#编辑/etc/profile，与/etc/bash.bashrc,增加 export LANG=en_US.UTF-8echo "export LANG=en_US.UTF-8" > /etc/profileecho "export LANG=en_US.UTF-8" > /etc/bash.bashrc source /etc/profilesource /etc/bash.bashrc

现在再运行locale，可以看到语言修改过来了

root@www:/# locale
LANG=en_US.UTF-8
LANGUAGE=
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=

然后就可以正常的运行了!

## 第二步：在手机或PC或浏览器上选择使用该http代理

## 第三步：使用客户端访问，现在就可以操作通信数据了

六、常见操作

1. mitmproxy

就介绍最常用到的修改请求，并回放请求的方法吧

(1)方向键定位请求
(2)当黄色箭头>>定位到指定请求时，按回车enter进入请求中
(3)按e进入编辑状态，然后按对应的蓝色字体来选择修改的部分
    可以修改query，查询字符串;path，路径;url ;header 请求头;form 表单;raw body 请求正文;method 请求方法。
(4)a 增加一行，tab键切换编辑字段，回车enter开始编辑，esc保存，q返回上一级
(5)修改完后，按r就可以重放请求，然后查看修改结果了

2. mitmdump

别忘了，mitmproxy还有个内向的双胞胎叫mitmdump(很像tcpdump)，它是不交互版的mitmproxy。可以非实时的处理通信包。

我们可以在mitmproxy中按w，将通信数据保存到指定文件中后，然后用mitmdump来操作。接下来简单介绍一个例子，从mitmproxy中捕获到的数据包中，筛选出来自微博的数据包，然后重放这个数据包(其实也可以修改后再重放)

-n 表示不启用代理， -r表示从文件中读取数据包， -w表示将数据包存储到文件中，-c表示重放客户端请求包

`mitmdump -nr all.data -w weibo.data "~u weibo"`

mitmdump -nc weibo.data[replay] POST http://api.weibo.cn/2/client/addlog_batch?s=2edc0cfa7&gsid=4ubed3V0QehBa8KoNp4AA75J&c=android&wm=20005_0002&ua=Xiaomi-MI+2S__weibo__4.0.1__android__android4.1.1&oldwm=9975_0001&from=1040195010&skin=default&i=8764056d2&isgzip=&lang=zh_CN<< 200 OK 32B

3. mitmproxy API

开源精神最赞的是，可以像小时候玩积木一样，用大牛们提供的各种精巧工具，搭建自己合适的武器。
mitmproxy提供了libmproxy以供调用扩展。
我们可以查看一下libmproxy的详细说明，了解主要的API接口调用
`pydoc libmproxy`
官网给了一个自己编写脚本，来操纵数据包的例子，很简单，人人都能看懂
如下所示，就是在响应包中增加一个自定义头
def response(context, flow): flow.response.headers["newheader"] = ["foo"]
我们可以在mitmdump 中使用这个脚本
-s表示从读取自定义脚本来处理数据包
`mitmdump -ns examples/add_header.py -r infile -w outfile`

好了，就介绍到这了。

七、希望交流

我在运行mitmdump重放http响应功能时候

`mitmdump -S outfile`

卡死了，到目前还没有找到原因，希望知道的大牛告之，万分感谢
