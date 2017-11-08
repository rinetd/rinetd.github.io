---
title: 使用openssl制作证书
date: 2016-01-06T16:46:14+08:00
update: 2017-01-01
categories: [linux_base]
tags: [nmap]
---
非对称加密算法：RSA，DSA/DSS
对称加密算法：AES，RC4，3DES
HASH算法：MD5，SHA1，SHA256
[Chapter 7 OpenSSL](http://netkiller.github.io/cryptography/openssl/)
[OpenSSL生成根证书CA及签发子证书](https://yq.aliyun.com/articles/40398)
# 那些证书相关的玩意儿(SSL,X.509,PEM,DER,CRT,CER,KEY,CSR,P12等)
[数字证书及 CA 的扫盲介绍 @ 编程随想的博客](https://program-think.blogspot.com/2010/02/introduce-digital-certificate-and-ca.html)
[数字签名与数字证书 - oscar999的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/oscar999/article/details/9364101)
[数字签名原理简介（附数字证书） - kingsleylam - 博客园](http://www.cnblogs.com/SirSmith/p/4985571.html)
## 无密码加密传输  [公钥加密]
![公钥加密](http://images2015.cnblogs.com/blog/452847/201511/452847-20151122114059983-1639010659.png)
## 解决源文件被修改的问题  [数字签名]
![非对称加密](http://images2015.cnblogs.com/blog/452847/201511/452847-20151122120233593-605577968.png)
## 解决公钥加密速度慢的问题 [数字签名+对称加密]
  1. B的公钥加密对称密钥  （加密密码）                      B的私钥解密 对称密钥（解密密码）
  2. 对称密钥加密原文    （密码）                          （解密）
  3. A的私钥加密 摘要   （数字签名）                       A的公钥解密HASH
![对称加密](http://images2015.cnblogs.com/blog/452847/201511/452847-20151122122115358-1810987945.png)
## 解决信任问题 [证书+数字签名+对称加密]
 用CA的公钥解开数字证书，就可以拿到B真实的公钥了，然后就能证明"数字签名"是否真的是鲍勃签的
 ![](http://files.jb51.net/file_images/article/201212/2012121714270132.png)



 一些概念

 KEY : 私钥文件，决定ssl安全的基础
 CSR : Certificate Signing Request 证书请求文件，包含公钥和证书信息
 CA : 中级证书颁发机构，一般是可信的第三方，CA证书会验证公钥是否被认证
 root CA：通过它的私钥对中级机构提交的CSR进行了签名

 申请ssl证书需要用到openssl，linux系统中默认会安装，手动安装openssl：

 yum install -y openssl openssl-devel
 一.生成私钥

 私钥是SSL安全性的基础，使用RSA算法生成，只有证书申请者持有，即使CA也没有对私钥的访问权限，应妥善保管。私钥长度决定其安全性，2009年768位RSA已被破解，1024位RSA短期内是安全的，但随着计算机越来越快，已不足以抵御攻击，为了安全起见应尽量使用2048位RSA，生成2048位私钥：

 openssl genrsa -out 52os.net.key 2048
 如果对安全性要求较高，可以用密码加密密钥文件，每次读取密钥都需输入密码：

 openssl genrsa -des3 -out 52os.net.key 2048
 二.生成CSR

 证书签名请求文件（CSR）中包含了公钥和证书的详细信息，将CSR发送给CA认证后就会得到数字证书或证书链，生成CSR文件：

 openssl req -new -sha256 -key 52os.net.key -out 52os.net.csr
 按照提示输入：国家、省份、城市、组织名、部门、公共名称、邮件地址等，最后的extra信息不要填写，个人用户也可以使用默认或留空，只需注意‘Common Name’是要使用ssl证书的域名，根据实际情况，可以写单域名，多个域名，或使用*通配域名
 验证CSR文件信息：


 openssl req -noout -text -in  52os.net.csr
 确认信息正确就可以提交给ca进行认证，CA会根据你的CSR文件进行签名，之后颁发数字证书，该数字证书和私钥就可以部署到服务器了；通常ca认证需付费，普通ssl证书不贵，也有一些提供免费的证书的ca，如startssl、Let's Encrypt等

 三.自签名

 在某些情况下，如内网https的应用，不需要付费使用第三方签名，此时就可以使用自签名证书。自签名分两种：

 使用自己的私钥签发自己的csr生成证书，也可以直接生成私钥和证书

 生成ca，使用ca签发

 生成ca的好处是：客户只要手动信任该ca一次，即可信任该ca签发的所有证书，不需要为每个证书添加信任

 3.1 使用自签名

 使用上面生成的私钥签发证书：


 openssl x509 -req -days 365 -in 52os.net.csr -extensions v3_ca -signkey  52os.net.key  -out 52os.net365.crt
 或者直接生成私钥和证书：

 openssl  req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout 52os.net.key -out 52os.net.crt
 可以使用chrome浏览器导出证书并安装到windows信任证书中，安装后浏览器地址栏的https就会变成绿色。导出方法：访问https网站，点击地址栏上有红色叉的锁型图标，点击详细信息，点击查看证书，在弹出的证书窗口中点击详细信息选项卡，点击复制到文件，之后按证书导出向导的提示即可导出

 3.2 使用ca签名

 生成 CA:


 openssl genrsa -out CA.key 2048
 openssl req -new -x509 -key CA.key -out CA.cer -days 36500 -subj /CN='52os CA'
 使用ca签发证书：

 openssl x509 -req -in 52os.net.csr -extensions v3_usr -CA CA.cer  -CAkey CA.key  -CAcreateserial -out 52os.net.crt
 为了更好的兼容浏览器，还需：

 cat CA.cer >> 52os.net.crt
 客户端手动信任CA.cer即可，windows下可以双击安装

 参考文章：
 http://www.51ean.com/interaction/safety_information_details.html?postId=585
 http://blog.csdn.net/tenfyguo/article/details/40922813
 http://www.wosign.com/Basic/index.htm
 http://www.cnblogs.com/kyrios/p/tls-and-certificates.html







HTTPS:
  1.                                                  server 生成crt.pub
  2. client 生成 random key                            server 生成对称密钥
  3. 通过对称密钥加密

之前没接触过证书加密的话,对证书相关的这些概念真是感觉挺棘手的,因为一下子来了一大堆新名词,看起来像是另一个领域的东西,而不是我们所熟悉的编程领域的那些东西,起码我个人感觉如此,且很长时间都没怎么搞懂.写这篇文章的目的就是为了理理清这些概念,搞清楚它们的含义及关联,还有一些基本操作.
SSL

SSL - Secure Sockets Layer,现在应该叫"TLS",但由于习惯问题,我们还是叫"SSL"比较多.http协议默认情况下是不加密内容的,这样就很可能在内容传播的时候被别人监听到,对于安全性要求较高的场合,必须要加密,https就是带加密的http协议,而https的加密是基于SSL的,它执行的是一个比较下层的加密,也就是说,在加密前,你的服务器程序在干嘛,加密后也一样在干嘛,不用动,这个加密对用户和开发者来说都是透明的.More:[维基百科]

OpenSSL - 简单地说,OpenSSL是SSL的一个实现,SSL只是一种规范.理论上来说,SSL这种规范是安全的,目前的技术水平很难破解,但SSL的实现就可能有些漏洞,如著名的"心脏出血".OpenSSL还提供了一大堆强大的工具软件,强大到90%我们都用不到.
证书标准

X.509 - 这是一种证书标准,主要定义了证书中应该包含哪些内容.其详情可以参考RFC5280,SSL使用的就是这种证书标准.
编码格式

同样的X.509证书,可能有不同的编码格式,目前有以下两种编码格式.

PEM - Privacy Enhanced Mail,打开看文本格式,以"-----BEGIN..."开头, "-----END..."结尾,内容是BASE64编码.
查看PEM格式证书的信息:openssl x509 -in certificate.pem -text -noout
Apache和*NIX服务器偏向于使用这种编码格式.

DER - Distinguished Encoding Rules,打开看是二进制格式,不可读.
查看DER格式证书的信息:openssl x509 -in certificate.der -inform der -text -noout
Java和Windows服务器偏向于使用这种编码格式.
相关的文件扩展名

这是比较误导人的地方,虽然我们已经知道有PEM和DER这两种编码格式,但文件扩展名并不一定就叫"PEM"或者"DER",常见的扩展名除了PEM和DER还有以下这些,它们除了编码格式可能不同之外,内容也有差别,但大多数都能相互转换编码格式.

CRT - CRT应该是certificate的三个字母,其实还是证书的意思,常见于*NIX系统,有可能是PEM编码,也有可能是DER编码,大多数应该是PEM编码,相信你已经知道怎么辨别.

CER - 还是certificate,还是证书,常见于Windows系统,同样的,可能是PEM编码,也可能是DER编码,大多数应该是DER编码.

KEY - 通常用来存放一个公钥或者私钥,并非X.509证书,编码同样的,可能是PEM,也可能是DER.
查看KEY的办法:openssl rsa -in mykey.key -text -noout
如果是DER格式的话,同理应该这样了:openssl rsa -in mykey.key -text -noout -inform der

CSR - Certificate Signing Request,即证书签名请求,这个并不是证书,而是向权威证书颁发机构获得签名证书的申请,其核心内容是一个公钥(当然还附带了一些别的信息),在生成这个申请的时候,同时也会生成一个私钥,私钥要自己保管好.做过iOS APP的朋友都应该知道是怎么向苹果申请开发者证书的吧.
查看的办法:openssl req -noout -text -in my.csr (如果是DER格式的话照旧加上-inform der,这里不写了)

PFX/P12 - predecessor of PKCS#12,对*nix服务器来说,一般CRT和KEY是分开存放在不同文件中的,但Windows的IIS则将它们存在一个PFX文件中,(因此这个文件包含了证书及私钥)这样会不会不安全？应该不会,PFX通常会有一个"提取密码",你想把里面的东西读取出来的话,它就要求你提供提取密码,PFX使用的时DER编码,如何把PFX转换为PEM编码？
openssl pkcs12 -in for-iis.pfx -out for-iis.pem -nodes
这个时候会提示你输入提取代码. for-iis.pem就是可读的文本.
生成pfx的命令类似这样:openssl pkcs12 -export -in certificate.crt -inkey privateKey.key -out certificate.pfx -certfile CACert.crt

其中CACert.crt是CA(权威证书颁发机构)的根证书,有的话也通过-certfile参数一起带进去.这么看来,PFX其实是个证书密钥库.

JKS - 即Java Key Storage,这是Java的专利,跟OpenSSL关系不大,利用Java的一个叫"keytool"的工具,可以将PFX转为JKS,当然了,keytool也能直接生成JKS,不过在此就不多表了.
证书编码的转换

PEM转为DER openssl x509 -in cert.crt -outform der -out cert.der

DER转为PEM openssl x509 -in cert.crt o pinform der -outform pem -out cert.pem

(提示:要转换KEY文件也类似,只不过把x509换成rsa,要转CSR的话,把x509换成req...)
获得证书

向CA权威证书颁发机构申请证书 CSR

用这命令生成一个csr: openssl req -newkey rsa:2048 -new -nodes -keyout my.key -out my.csr
把csr交给权威证书颁发机构,权威证书颁发机构对此进行签名,完成.保留好csr,当权威证书颁发机构颁发的证书过期的时候,你还可以用同样的csr来申请新的证书,key保持不变.

或者生成自签名的证书
openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
在生成证书的过程中会要你填一堆的东西,其实真正要填的只有Common Name,通常填写你服务器的域名,如"yourcompany.com",或者你服务器的IP地址,其它都可以留空的.
生产环境中还是不要使用自签的证书,否则浏览器会不认,或者如果你是企业应用的话能够强制让用户的浏览器接受你的自签证书也行.向权威机构要证书通常是要钱的,但现在也有免费的,仅仅需要一个简单的域名验证即可.有兴趣的话查查"沃通数字证书".
#####################
## 生成证书请求文件
2.1生成csr请求文件 首先下载openssl软件，可以去openssl官网下载：http://www.openssl.org/related/binaries.html下载后安装到本地计算机。
2.1.1查看openssl在终端输入openssl version查看openssl当前版本。图1
2.1.2生成key私钥文件
  使用以下命令来生成私钥：`openssl genrsa -des3 -out www.deedbeef.com.key 2048`，生成的私钥保存在当期目录。
2.1.3生成[根证书]csr文件
  使用以下命令来生成私钥：`openssl req -new -key www.mydomain.com.key -out www.mydomain.com.csr`
Country Name (2 letter code) [GB]: 输入国家地区代码，如中国的CN
State or Province Name (full name) [Berkshire]: 地区省份
Locality Name (eg, city) [Newbury]: 城市名称
Organization Name (eg, company) [My Company Ltd]: 公司名称
Organizational Unit Name (eg, section) []: 部门名称
Common Name (eg, your name or your server’s hostname) []: 申请证书域名
Email Address []: 电子邮箱
随后可能会提示输入密码，一般无需输入，直接回车即可
---
之前申请的StartSSL免费一年的证书到期了，考虑到我对SSL一般仅用于博客登录和后台管理上面，所以不打算续申请，自己创建一个就足够了。
本来想使用Windows下的makecert实用工具创建的，结果折腾了很久导入到Linux服务器上，服务器没有正确识别，遂放弃，转而使用OpenSSL，收集了网上的一些材料，通过下面的方法创建成功：


数字证书：
    证书是持有者的详细信息，证书有公钥。包括名称、公钥信息等;针对证书的防伪信息叫做签名。
数字签名 就是使用个人私密和加密算法加密的摘要和报文，是私人性的。而数字证书是由CA中心派发的.
1）CA：签证机构 （签发证书的机构）          功用：保证公钥信息安全分发；
2）数字证书的格式(x.509 v3)：  
       版本号（version）  
       序列号(serial number)：CA用于惟一标识此证书；  
       签名算法标志(Signature algorithm identifier)  
       发行者的名称：即CA自己的名称；  
       有效期：两个日期，起始日期和终止日期；  
       证书主体名称：证书拥有者自己的名字  
       证书主体公钥信息：证书拥有者自己的公钥；  
        发行商的惟一标识：  CA标识号     
        证书主体的惟一标识：  
        扩展信息：  
        签名：CA对此证书的数字签名；（防伪信息）
4. 签发机构名(Issuer)
此域用来标识签发证书的CA的X.500 DN(DN-Distinguished Name)名字。包括:
    1) 国家(C)
    2) 省市(ST)
    3) 地区(L)
    4) 组织机构(O)
    5) 单位部门(OU)
    6) 通用名(CN)
    7) 邮箱地址
```
mitmproxy-ca.pem 私钥+证书 文本格式
mitmproxy-ca-cert.pem Unix平台使用证书(certificate)格式 文本格式
mitmproxy-ca-cert.cer 与mitmproxy-ca-cert.pem相同，android上使用证书(certificate)格式 文本格式
mitmproxy-ca-cert.p12 windows上使用证书(certificate)格式 文本格式
```
为了安全起见，修改cakey.pem私钥文件权限为600或400，也可以使用子shell生成( umask 077;

1. 创建根证书的私匙CA.key：
`openssl genrsa -out ca.key 2048`
网上很多是使用了1024，我这里强度加强到了2048。
2. 利用ca.key私钥创建根证书ca.crt：
`openssl req -new -x509 -days 36500 -key ca.key -out ca.crt -subj \
"/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=Your Root CA"
`
      -new: 生成新的证书签署请求；  
      -key：私钥文件路径，用于提取公钥；  
      -days N: 证书有效时长，单位为“天”；  
      -out：输出文件保存位置；  
      -x509：直接输出自签署的证书文件，通常只有构建CA时才这么用；
这里/C表示国家(Country)，只能是国家字母缩写，如CN、US等；/ST表示州或者省(State/Provice)；/L表示城市或者地区(Locality)；/O表示组织名(Organization Name)；/OU其他显示内容，一般会显示在颁发者这栏。

到这里根证书就已经创建完毕了，

下面介绍建立网站SSL证书的步骤：
3. 创建SSL证书私匙，这里加密强度仍然选择2048：
`openssl genrsa -out server.key 2048`位
4. 利用刚才的私匙建立SSL证书：
`openssl req -new -key server.key -out server.csr -subj \
"/C=CN/ST=Jiangsu/L=Yangzhou/O=Your Company Name/OU=wangye.org/CN=wangye.org"`


这里需要注意的是后三项，/O字段内容必须与刚才的CA根证书相同；/CN字段为公用名称(Common Name)，必须为网站的域名(不带www)；/OU字段最好也与为网站域名，当然选择其他名字也没关系。

备注: CSR（证书签名请求，你需要发送给CA，等待CA批准） `openssl req -sha256 -new -key server.pem -out csr.pem`

`openssl x509 -req -days 365 -in csr.pem -signkey server.pem -out my-certificate.pem`
注：用一行命令同时生成一对密钥+证书 `openssl req -nodes -new -x509 -keyout server.key -out server.cert`
5. 做些准备工作：
mkdir demoCA
cd demoCA
mkdir newcerts
touch index.txt
echo '01' > serial
cd ..
注意cd ..，利用ls命令检查一下是不是有个demoCA的目录。
6. 用CA根证书签署SSL自建证书：
`openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key`
接下来有一段提示，找到Sign the certificate? [y/n]这句，打入y并回车，然后出现out of 1 certificate requests certified, commit? [y/n]，同样y回车。
好了，现在目录下有两个服务器需要的SSL证书及相关文件了，分别是server.crt和server.key，接下来就可以利用它们配置你的服务器软件了。
需要注意的是由于是自签名证书，所以客户端需要安装根证书，将刚才第2步创建的根证书ca.crt下载到客户端，然后双击导入，否则会提示不受信任的证书发布商问题。
通常情况下私人或者内部用的话，自建证书已经绰绰有余了，但是如果你的产品面向的是大众，那就花点银子去买正规的SSL证书吧，可不能学某售票系统强制要求安装自建的根证书哦。
```
ca.key      CA私钥
ca.crt      CA私钥 -> CA证书                 [客户端安装ca.crt]
server.key  网站私钥                         [服务端 ssl_certificate_key  /etc/nginx/server.key;]
server.csr  网站SSL私钥 -> SSL证书            [用于生成server.crt]
server.crt  SSL证书+CA证书+CA私钥 -> 网站证书  [服务端 ssl_certificate      /etc/nginx/server.crt;]
```
################################################################################

7.1. openssl 命令参数
7.1.1. 测试加密算法的速度

$ openssl speed
$ openssl speed rsa
$ openssl speed aes

7.1.2. req

openssl req -new -x509 -days 7300 -key ca.key -out ca.crt

7.1.3. x509

openssl x509 -req -in client-req.csr -out client.crt -signkey client-key.pem -CA ca.crt -CAkey ca.key -days 365 -CAserial serial
验证一下我们生成的文件。
openssl x509 -in cacert.pem -text -noout
-extfile
openssl x509 -req -in careq.pem -extfile openssl.cnf -extensions v3_ca -signkey key.pem -out cacert.pem

7.1.4. ca

# 生成CRL列表
$ openssl ca -gencrl -out exampleca.crl

7.1.5. crl
# 查看CRL列表信息
$ openssl crl -in exampleca.crl -text -noout
# 验证CRL列表签名信息
$ openssl crl -in exampleca.crl -noout -CAfile cacert.pem


7.1.6. pkcs12

-clcerts 表示仅导出客户证书。
openssl pkcs12 -export -clcerts -in 324.cer -inkey ca.pem -out 324.p12 -name "Email SMIME"
转换PEM证书文件和私钥到PKCS#12文件
openssl pkcs12 -export -out certificate.pfx -inkey privateKey.key -in certificate.crt -certfile CACert.crt


7.1.7. passwd

MD5-based password algorithm
# openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'
$1$random-p$AOw9RDIWQm6tfUo9Ediu/0

-crypt standard Unix password algorithm (default)
# openssl passwd -crypt -salt 'sa' 'password'
sa3tHJ3/KuYvI

--------------------------------------------------------------------------------
7.1.8. digest

如何创建一个文件的 MD5 或 SHA1 摘要?

摘要创建使用 dgst 选项.
7.1.8.1. list-message-digest-commands

列出可用摘要

$ openssl list-message-digest-commands
md2
md4
md5
mdc2
rmd160
sha
sha1


7.1.8.2. md5

# MD5 digest
openssl dgst -md5 filename
$ openssl dgst -md5 message.txt
MD5(message.txt)= d9226d4bd8779baa69db272f89a2e05c



7.1.8.3. sha1

# SHA1 digest
openssl dgst -sha1 filename
$ openssl dgst -sha1 /etc/passwd
SHA1(/etc/passwd)= 9d883a9d35fd9a6dc81e6a1717a8e2ecfc49cdd8

--------------------------------------------------------------------------------
7.1.9. enc

使用方法：

$ openssl enc 加密算法 -k 密码 -in 输入明文文件 -out 输出密文文件
$ openssl enc 加密算法 -k 密码 -in 输出密文文件 -out 输入明文文件
7.1.9.1. list-cipher-commands

可用的编码/解码方案

# or get a long list, one cipher per line
openssl list-cipher-commands

# openssl list-cipher-commands
aes-128-cbc
aes-128-ecb
aes-192-cbc
aes-192-ecb
aes-256-cbc
aes-256-ecb
base64
bf
bf-cbc
bf-cfb
bf-ecb
bf-ofb
cast
cast-cbc
cast5-cbc
cast5-cfb
cast5-ecb
cast5-ofb
des
des-cbc
des-cfb
des-ecb
des-ede
des-ede-cbc
des-ede-cfb
des-ede-ofb
des-ede3
des-ede3-cbc
des-ede3-cfb
des-ede3-ofb
des-ofb
des3
desx
idea
idea-cbc
idea-cfb
idea-ecb
idea-ofb
rc2
rc2-40-cbc
rc2-64-cbc
rc2-cbc
rc2-cfb
rc2-ecb
rc2-ofb
rc4
rc4-40
rc5
rc5-cbc
rc5-cfb
rc5-ecb
rc5-ofb


7.1.9.2. base64

使用 base64-encode 编码/解码

使用 enc -base64 选项

通过管道操作
`echo "encode me" | openssl enc -base64`
ImVuY29kZSBtZSIgDQo=
`echo -n "encode me" | openssl enc -base64`
LW4gImVuY29kZSBtZSIgDQo=

编码
openssl enc -base64 -in file.txt
openssl enc -base64 -in file.txt -out file.txt.enc

使用 -d (解码) 选项来反转操作

`openssl enc -base64 -d -in file.txt.enc`
Hello World!
`openssl enc -base64 -d -in file.txt.enc -out file.txt`
`echo SGVsbG8gV29ybGQhDQo= | openssl enc -base64 -d`
Hello World!


7.1.9.3. des

对称加密与解密

加密
# openssl enc -des -e -a -in file.txt -out file.txt.des
解密
# openssl enc -des -d -a -in file.txt.des -out file.txt.tmp

7.1.9.4. aes

加密
openssl enc -aes-128-cbc -in filename -out filename.out
解密
openssl enc -d -aes-128-cbc -in filename.out -out filename


7.1.10. rsa

产生密钥对:

生成私钥
openssl genrsa -out private.key 1024
根据私钥产生公钥
openssl rsa -in private.key -pubout > public.key

用公钥加密明文
$ openssl rsautl -encrypt -pubin -inkey public.key -in filename -out filename.out
用私钥解密
$ openssl rsautl -decrypt -inkey private.key -in filename.out -out filename


7.1.11. dsa

Example 7.1. dsaparam & gendsa

# create parameters in dsaparam.pem
openssl dsaparam -out dsaparam.pem 1024
# create first key
openssl gendsa -out key1.pem dsaparam.pem
# and second ...
openssl gendsa -out key2.pem dsaparam.pem

生成私钥
openssl dsaparam -out dsaparam.pem 1024
openssl gendsa -out private.key dsaparam.pem
根据私钥产生公钥
openssl dsa -in private.key -pubout -out public.key

$ ls
dsaparam.pem  private.key  public.key

7.1.12. rc4

# rc4文件加密解密
`openssl enc -e -rc4 -in in.txt -out out.txt`   #加密
`openssl enc -d -rc4 -in out.txt -out test.txt` #解密
使用 -k 指定密钥
`openssl enc -e -rc4 -k passwd -in in.txt -out out.txt`
`openssl enc -d -rc4 -k passwd -in out.txt -out test.txt`


7.1.13. -config 指定配置文件

# openssl req -new -newkey rsa:2048 -config openssl.cfg -keyout server.key -nodes -out certreq.csr


7.1.14. -subj 指定参数

# openssl req -new -newkey rsa:2048 -keyout server.key -nodes -subj /C=CN/O=example.com/OU=IT/CN=Neo/ST=GD/L=Shenzhen -out certreq.csr

生成随机数
`openssl rand 12 -base64`
#SSLsplit
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 1826 -key ca.key -out ca.crt

修改OpenSSL的配置
安装好之后，定位一下OpenSSL的配置文件openssl.cnf：
locate openssl.cnf
  /etc/ssl/openssl.cnf
  /usr/lib/ssl/openssl.cnf
certs——存放已颁发的证书
newcerts——存放CA指令生成的新证书
private——存放私钥
crl——存放已吊销的整数
index.txt——OpenSSL定义的已签发证书的文本数据库文件，这个文件通常在初始化的时候是空的
serial——证书签发时使用的序列号参考文件，该文件的序列号是以16进制格式进行存放的，该文件必须提供并且包含一个有效的序列号
# 生成证书之前，需要先生成一个随机数：
`openssl rand -out private/.rand 1000`
rand——生成随机数
-out——指定输出文件
1000——指定随机数长度
# 生成根证书
## a).生成根证书私钥(pem文件)
OpenSSL通常使用PEM（Privacy Enbanced Mail）格式来保存私钥，构建私钥的命令如下：
`openssl genrsa -aes256 -out private/cakey.pem 1024`
该命含义如下：
genrsa——使用RSA算法产生私钥
-aes256——使用256位密钥的AES算法对私钥进行加密
-out——输出文件的路径
1024——指定私钥长度

## b).生成根证书签发申请文件(csr文件)
使用上一步生成的私钥(pem文件)，生成证书请求文件(csr文件)：
`openssl req -new -key private/cakey.pem -out private/ca.csr -subj "/C=CN/ST=myprovince/L=mycity/O=myorganization/OU=mygroup/CN=myname"
`
该命令含义如下：
req——执行证书签发命令
-new——新证书签发请求
-key——指定私钥路径
-out——输出的csr文件的路径
-subj——证书相关的用户信息(subject的缩写)

## c).自签发根证书(cer文件)
csr文件生成以后，可以将其发送给CA认证机构进行签发，当然，这里我们使用OpenSSL对该证书进行自签发：
`openssl x509 -req -days 365 -sha1 -extensions v3_ca -signkey \
private/cakey.pem -in private/ca.csr -out certs/ca.cer`
152740_yYK9_1434710.png
该命令的含义如下：
x509——生成x509格式证书
-req——输入csr文件
-days——证书的有效期（天）
-sha1——证书摘要采用sha1算法
-extensions——按照openssl.cnf文件中配置的v3_ca项添加扩展
-signkey——签发证书的私钥
-in——要输入的csr文件
-out——输出的cer证书文件
之后看一下certs文件夹里生成的ca.cer证书文件：
152922_iD3K_1434710.png

# 用根证书签发server端证书
和生成根证书的步骤类似，这里就不再介绍相同的参数了。
## a).生成服务端私钥
`openssl genrsa -aes256 -out private/server-key.pem 1024`
## b).生成证书请求文件
`openssl req -new -key private/server-key.pem -out private/server.csr -subj \
"/C=CN/ST=myprovince/L=mycity/O=myorganization/OU=mygroup/CN=myname"`
## c).使用根证书签发服务端证书
`openssl x509 -req -days 365 -sha1 -extensions v3_req -CA certs/ca.cer -CAkey private/cakey.pem \
-CAserial ca.srl -CAcreateserial -in private/server.csr -out certs/server.cer`
这里有必要解释一下这几个参数：
-CA——指定CA证书的路径
-CAkey——指定CA证书的私钥路径
-CAserial——指定证书序列号文件的路径
-CAcreateserial——表示创建证书序列号文件(即上方提到的serial文件)，创建的序列号文件默认名称为-CA，指定的证书名称后加上.srl后缀
注意：这里指定的-extensions的值为v3_req，在OpenSSL的配置中，v3_req配置的basicConstraints的值为CA:FALSE，如图：
145405_I71X_1434710.png
而前面生成根证书时，使用的-extensions值为v3_ca，v3_ca中指定的basicConstraints的值为CA:TRUE，表示该证书是颁发给CA机构的证书，如图：
145718_5CsH_1434710.png
在x509指令中，有多重方式可以指定一个将要生成证书的序列号，可以使用set_serial选项来直接指定证书的序列号，也可以使用-CAserial选项来指定一个包含序列号的文件。所谓的序列号是一个包含一个十六进制正整数的文件，在默认情况下，该文件的名称为输入的证书名称加上.srl后缀，比如输入的证书文件为ca.cer，那么指令会试图从ca.srl文件中获取序列号，可以自己创建一个ca.srl文件，也可以通过-CAcreateserial选项来生成一个序列号文件。

# 用根证书签发client端证书
和签发server端的证书的过程类似，只是稍微改下参数而已。
## a).生成客户端私钥
`openssl genrsa -aes256 -out private/client-key.pem 1024`
## b).生成证书请求文件
`openssl req -new -key private/client-key.pem -out private/client.csr -subj \
"/C=CN/ST=myprovince/L=mycity/O=myorganization/OU=mygroup/CN=myname"`
## c).使用根证书签发客户端证书
`openssl x509 -req -days 365 -sha1 -extensions v3_req -CA certs/ca.cer -CAkey private/cakey.pem \
-CAserial ca.srl -in private/client.csr -out certs/client.cer`
需要注意的是，上方签发服务端证书时已经使用-CAcreateserial生成过ca.srl文件，因此这里不需要带上这个参数了。

至此，我们已经使用OpenSSL自签发了一个CA证书ca.cer，并用这个CA证书签发了server.cer和client.cer两个子证书了：
153323_S39o_1434710.png
#导出证书
## a).导出客户端证书

openssl pkcs12 -export -clcerts -name myclient -inkey \
private/client-key.pem -in certs/client.cer -out certs/client.keystore
参数含义如下：
pkcs12——用来处理pkcs#12格式的证书
-export——执行的是导出操作
-clcerts——导出的是客户端证书，-cacerts则表示导出的是ca证书
-name——导出的证书别名
-inkey——证书的私钥路径
-in——要导出的证书的路径
-out——输出的密钥库文件的路径
## b).导出服务端证书
openssl pkcs12 -export -clcerts -name myserver -inkey \
private/server-key.pem -in certs/server.cer -out certs/server.keystore
## c).信任证书的导出
keytool -importcert -trustcacerts -alias www.mydomain.com \
-file certs/ca.cer -keystore certs/ca-trust.keystore


#####################################################################
[Netkiller Cryptography 手札 信息安全与加密](http://netkiller.github.io/cryptography/)
7.6. Outlook smime x509 证书
7.6.1. 快速创建自签名证书

以下适合个人使用

openssl genrsa -out ca.pem 1024
openssl req -new -out neo.csr -key ca.pem
openssl x509 -req -in neo.csr -out neo.cer -signkey ca.pem -days 365
openssl pkcs12 -export -clcerts -in neo.cer -inkey ca.pem -out neo.p12


安装cer与p12两个证书，然后打开outlook测试

Example 7.3. 快速创建自签名证书


[root@localhost smime]# openssl genrsa -out ca/ca.pem 1024
Generating RSA private key, 1024 bit long modulus
...............++++++
...................++++++
e is 65537 (0x10001)

[root@localhost smime]# openssl req -new -out ca/ca.csr -key ca/ca.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:GD
Locality Name (eg, city) [Default City]:SZ
Organization Name (eg, company) [Default Company Ltd]:XXX Ltd
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:neo
Email Address []:neo.chan@live.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

[root@localhost smime]# openssl x509 -req -in ca/ca.csr -out ca/ca-cert.cer -signkey ca/ca.pem -days 365
Signature ok
subject=/C=CN/ST=GD/L=SZ/O=XXX Ltd/CN=neo/emailAddress=neo.chan@live.com
Getting Private key

[root@localhost smime]# openssl pkcs12 -export -clcerts -in ca/ca-cert.cer -inkey ca/ca.pem -out ca/ca.p12
Enter Export Password:
Verifying - Enter Export Password:



更便捷的方法

openssl genrsa -out ca.pem 1024
openssl req -new -out neo.csr -key ca.pem -subj  "/C=CN/ST=GD/L=SZ/O=Internet Widgits Pty Ltd/OU=IT/CN=neo/emailAddress=neo@668x.net"
openssl x509 -req -in neo.csr -out neo.cer -signkey ca.pem -days 365
openssl pkcs12 -export -in neo.cer -inkey ca.pem -out neo.p12 -name "neo"



7.6.2. 企业或集团方案
7.6.2.1. 证书环境

% mkdir keys
% cd keys/


建立空文件 index.txt 用来保存以后的证书信息，这是OpenSSL的证书数据库：

touch  index.txt


建立一个文件 serial 在文件中输入一个数字，做为以后颁发证书的序列号，颁发证书序列号就从你输入的数字开始递增：

echo 01 > serial


7.6.2.2. 颁发CA证书

首先创建CA根证书私钥文件，使用RSA格式，1024位：

% openssl genrsa -des3 -out ca.key 1024


Example 7.4. 创建CA根证书

% openssl genrsa -des3 -out ca.key 1024
Generating RSA private key, 1024 bit long modulus
...........................++++++
...........................................++++++
e is 65537 (0x10001)
Enter pass phrase for ca.key:
Verifying - Enter pass phrase for ca.key:



私钥在建立时需要输入一个密码用来保护私钥文件，私钥文件使用3DES加密; 也可以不进行加密，这样不安全，因为一旦ca证书遗失，别人就可以随意颁发用户证书：

openssl genrsa -out ca.key 1024


利用建立RSA私钥，为CA自己建立一个自签名的证书文件：

openssl req -new -x509 -days 365 -key ca.key -out ca.crt


生成证书的过程中需要输入证书的信息，

Example 7.5. 创建自签名的证书

% openssl req -new -x509 -days 365 -key ca.key -out ca.crt
Enter pass phrase for ca.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:GD
Locality Name (eg, city) []:Shenzhen
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Your Company Ltd
Organizational Unit Name (eg, section) []:IT
Common Name (e.g. server FQDN or YOUR name) []:Neo Chan
Email Address []:neo.chan@live.com



7.6.2.3. 颁发客户证书

生成客户证书的私钥文件，与生成CA根证书文件的方法一样，

openssl genrsa -des3 -out client.key 1024


OpenSSL生成客户端证书的时候，不能直接生成证书，而是必须通过证书请求文件来生成，因此现在我们来建立客户端的证书请求文件，生成的过程中一样要输入客户端的信息：

openssl req -new -key client.key -out client.csr


有了证书请求文件之后，就可以使用CA的根证书、根私钥来对请求文件进行签名，生成客户端证书 client.pem 了：

openssl x509 -req -in client.csr -out client.crt -signkey client.key -CA ca.crt -CAkey ca.key -days 365 -CAserial serial


openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12


[Note]	Note
到这里为止，根CA为客户端签发证书的过程就结束了。
7.6.2.4. 吊销已签发的证书

使用ca中的 -revoke 命令：

openssl ca -revoke client.pem -keyfile ca.key -cert ca.crt


证书被吊销之后，还需要发布新的CRL文件：

openssl ca -gencrl  -out ca.crl -keyfile ca.key -cert ca.crt

7.7. 证书转换


PKCS 全称是 Public-Key Cryptography Standards ，是由 RSA 实验室与其它安全系统开发商为促进公钥密码的发展而制订的一系列标准，PKCS 目前共发布过 15 个标准。 常用的有：
PKCS#7 Cryptographic Message Syntax Standard
PKCS#10 Certification Request Standard
PKCS#12 Personal Information Exchange Syntax Standard
X.509是常见通用的证书格式。所有的证书都符合为Public Key Infrastructure (PKI) 制定的 ITU-T X509 国际标准。
PKCS#7 常用的后缀是： .P7B .P7C .SPC
PKCS#12 常用的后缀有： .P12 .PFX
X.509 DER 编码(ASCII)的后缀是： .DER .CER .CRT
X.509 PAM 编码(Base64)的后缀是： .PEM .CER .CRT
.cer/.crt是用于存放证书，它是2进制形式存放的，不含私钥。
.pem跟crt/cer的区别是它以Ascii来表示。
pfx/p12用于存放个人证书/私钥，他通常包含保护密码，2进制方式
p10是证书请求
p7r是CA对证书请求的回复，只用于导入
p7b以树状展示证书链(certificate chain)，同时也支持单个证书，不含私钥。
7.7.1. CA证书

用openssl创建CA证书的RSA密钥(PEM格式)：

openssl genrsa -des3 -out ca.key 1024


7.7.2. 创建CA证书有效期为一年

用openssl创建CA证书(PEM格式,假如有效期为一年)：

openssl req -new -x509 -days 365 -key ca.key -out ca.crt -config openssl.cnf


openssl是可以生成DER格式的CA证书的，最好用IE将PEM格式的CA证书转换成DER格式的CA证书。
7.7.3. x509转换为pfx

openssl pkcs12 -export -out server.pfx -inkey server.key -in server.crt


7.7.4. PEM格式的ca.key转换为Microsoft可以识别的pvk格式

pvk -in ca.key -out ca.pvk -nocrypt -topvk


7.7.5. PKCS#12 到 PEM 的转换

openssl pkcs12 -nocerts -nodes -in cert.p12 -out private.pem
验证
openssl pkcs12 -clcerts -nokeys -in cert.p12 -out cert.pem


7.7.6. 从 PFX 格式文件中提取私钥格式文件 (.key)

openssl pkcs12 -in mycert.pfx -nocerts -nodes -out mycert.key


7.7.7. 转换 pem 到到 spc

openssl crl2pkcs7 -nocrl -certfile venus.pem  -outform DER -out venus.spc


用 -outform -inform 指定 DER 还是 PAM 格式。例如：

openssl x509 -in Cert.pem -inform PEM -out cert.der -outform DER


7.7.8. PEM 到 PKCS#12 的转换

openssl pkcs12 -export -in Cert.pem -out Cert.p12 -inkey key.pem


IIS 证书

cd c:\openssl
set OPENSSL_CONF=openssl.cnf
openssl pkcs12 -export -out server.pfx -inkey server.key -in server.crt


server.key和server.crt文件是Apache的证书文件，生成的server.pfx用于导入IIS
7.7.9. How to Convert PFX Certificate to PEM Format for SOAP

$ openssl pkcs12 -in test.pfx -out client.pem
Enter Import Password:
MAC verified OK
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:


7.7.10. DER文件（.crt .cer .der）转为PEM格式文件

转换DER文件(一般后缀名是.crt .cer .der的文件)到PEM文件
openssl x509 -inform der -in certificate.cer -out certificate.pem
转换PEM文件到DER文件
openssl x509 -outform der -in certificate.pem -out certificate.der
