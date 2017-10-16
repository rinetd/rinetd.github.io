---
title: GPG, OpenSSH和OpenSSL
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags:
---
[Client Cert Authentication](http://www.integralist.co.uk/posts/clientcertauth.html)
[[译]安全基础：GPG, OpenSSH和OpenSSL](http://unicorn-42.com/2015/12/08/[%E8%AF%91]%E5%AE%89%E5%85%A8%E5%9F%BA%E7%A1%80%EF%BC%9AGPG,%20OpenSSH%E5%92%8COpenSSL/)

GPG是什么？

GPG是一个提供了加密和签名功能的工具。它的全名是“GNU Privacy Guard”。

GPG支持对称加密和非对称加密，另外还提供一个可选的数字签名功能，来保证加密数据的完整性（未被中间人修改过）。

后面，我们将会演示如何使用GPG。

GPG vs PGP

你可能还听说过PGP，PGP是一个协议标准（命名为”Open PGP”），GPG实现了这个协议标准。

创建你自己的密钥

好了，目前为止，我们只讨论了一些理论知识。现在要实践了，我们会用之前提到的三种工具（OpenSSH，OpenSSL和GPG）来生成自己的密钥。

我不会详细地解释每个命令中使用的标志/设置，你可以自己man来了解这些细节。

此外，生成密钥只是一部分。对于OpenSSL和GPG来说，直到加密数据的时候，这些密钥才变得有用。

让我们开始吧！

OpenSSH

在下面的例子中，我们会使用RSA算法和4096位的密钥长度生成一组新的密钥（公钥和私钥）。这是相当安全的设置（在今天这个数字时代，任何低于2048位的密钥会被轻易攻破）：

1
ssh-keygen -t rsa -b 4096 -C "your.email@service.com"
运行这个命令，你会被要求为密钥提供一个名字，还有一个密码（可选）。之后你会发现当前目录下生成了两个文件（假设我们提供的名字是foo_rsa）：

foo_rsa: 私钥
foo_rsa.pub: 公钥
注：你可以通过SSH-keygen -p命令更改与私钥相关联的密码。

现在我们有了这两个密钥，可以把公钥放到外部的服务（如github）或者远程服务器上。这样我们就可以和远程的服务或者服务器进行安全的通信了。

如果你想要连接到远端服务器，你可以让你的运维帮你把公钥加到~/.ssh/文件夹下，或者你也可以自己来（cat foo_rsa.pub | ssh user@123.45.56.78 "mkdir -p ~/.ssh && cat > > ~/.ssh/authorized_keys"）。一旦加入了你的公钥，你就可以在不需要密码的情况下安全访问服务器，因为你的私钥将会作为访问的凭证。

注：默认是SSH密钥是放在~/.ssh/文件夹下的

你还可以进一步设置，限制只能通过SSH密钥登录服务器。为了达成这个目的，你需要登录到服务器，并修改/etc/ssh/sshd_config文件，找到PermitRootLogin那一行，并改成PermitRootLogin without-password。重新启动ssh，修改就会立即生效。

SSH代理

大多数操作系统都有可用的ssh-agent。如果你已经安装了ssh-keygen，那么很有可能你也已经安装了ssh-agent和其他OpenSSH工具。
该代理是用来存储私钥的，它会让SSH的使用更加容易：允许你一次性地设置私钥密码（便利性的代价是安全性能的下降）。

当我设置我的github SSH密钥时，我会运行下面的命令：

1
2
3
4
5
6
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C "my.email@domain.com" #  saved as github_rsa
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/github_rsa
pbcopy < ~/.ssh/github_rsa.pub
ssh -T git@github.com
这里一共做了以下几件事：

cd到存放SSH密钥的目录
生成我自己的SSH密钥（存成github_rsa）
启动SSH代理
使用ssh-add命令将我的私钥添加到代理中
拷贝我的公钥（然后手动把它粘贴到GitHub GUI中）
连接到github，验证设置
Generating SSH keys - User Documentation

OpenSSL

和上一节一样，我们将会使用RSA和4096位的密钥长度生成一组新密钥（公钥和私钥）。区别在于，你需要先生成私钥，然后从中抽取公钥：

1
2
openssl genrsa -out private_key.pem 4096
openssl rsa -pubout -in private_key.pem -out public_key.pem
你还可以通过添加-text标志，打印出包含在pem文件里的额外信息：

1
openssl rsa -text -in private_key.pem
GPG

用GPG生成一对密钥要稍微麻烦些，因为你需要根据提示输入一些内容，首先输入命令：

1
gpg --gen-key
将会显示如下信息：

1
2
3
4
5
6
Please select what kind of key you want:
(1) RSA and RSA (default)
(2) DSA and Elgamal
(3) DSA (sign only)
(4) RSA (sign only)
Your selection?
然后会问你需要的密钥长度（这里我和上面一样，输入了4096）：

1
2
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048)
接着，会要你提供一个过期时间（我选择了一年）：

1
2
3
4
5
6
7
8
Requested keysize is 4096 bits       
Please specify how long the key should be valid.
         0 = key does not expire
      <n>   = key expires in n days
      <n> w = key expires in n weeks
      <n> m = key expires in n months
      <n> y = key expires in n years
Key is valid for? (0)
最后，你需要输入一些个人信息。我不会在这里展示，你可以自己试一试。另外值得注意的是，GPG会使用系统的熵来帮助它生成随机数，所以你会被要求移动一下光标，来协助产生随机数。

注：你也可以通过一个输入文件来提供上述所需要的内容（当你想要产生很多成对密钥时，这个方法很有用），如果你想了解更多的细节，可以参考这里。

当你生成完密钥之后，你可能会问它们在哪儿呢？它们并不在当前的目录下，你需要使用下面的命令来查看生成的密钥：

1
gpg --list-keys
我这里的输出是：

1
2
3
4
5
/Users/M/.gnupg/pubring.gpg
---------------------------
pub   4096R/056C9716 2015-08-14 [expires: 2016-08-13]
uid                  Mark McDonnell (Hi) <my.email@domain.com>
sub   4096R/A1F3D5B6 2015-08-14 [expires: 2016-08-13]
注：对应的，这里有一个命令用于查看私钥：gpg --list-secret-keys。

你可以看到有个pubring.gpg文件，里面包含了我创建密钥时输入的信息，有趣的是这个文件本身是受保护的，如果我尝试cat ~/.gnupg/pubring.gpg，会输出的是加密后的密文。

如果你想要查看自己的公钥，需要使用下面的命令（请注意我指定了名称”Mark McDonnell”，和我们刚才用--list-keys看到的输出一样）：

1
gpg --export -a "Mark McDonnell" | xargs -I {} echo {} >  gpg_public.key
如果你想要得到私钥，你需要使用一个不同的标志：

1
gpg --export-secret-key -a "Mark McDonnell" | xargs -I {} echo {} >  gpg_private.key
如何使用GPG和OpenSSL来加密数据

除了PKI和SSL/TLS，最常见的一个任务就是加密包含敏感信息的特定文件。不同的工具加密数据的接口也不同，让我们来看看GPG和OpenSSL的：

GPG加密

GPG提供了两种加密方式：非对称和对称的……

非对称加密

使用GPG，你需要接受者的公钥来加密文件。所以当你拿到对方的公钥之后，你需要将其导入到GPG中：

1
gpg --import public.key
注：之后如果要删除这些公钥，运行gpg --delete-key "user name"

之后你可以用这个公钥加密文件：

1
gpg -e -u "Sender User Name" -r "Receiver User Name" somefile
要解密一个用你的公钥和GPG加密过的文件，可以使用下面的命令（会自动定位你的私钥，如果你有多个私钥，会向你询问密码）：

1
gpg -d some_encrypted_file.gpg
上面的命令会直接把解密的内容输出到stdout，所以如果你需要将其重定向到一个文件里，可以像下面这样：

1
gpg -o output_file -d some_encrypted_file.gpg
对称加密

如果你不想用一对密钥来加密文件，你可以使用标准的对称加密：

1
gpg --symmetric secrets.txt
gpg会向你请求一个密码，之后会将加密后的文件导出到当前文件夹下。

你还可以通过--sign标志添加一个MAC（我们在讨论PKI的时候说过，就是一个数字签名）：

1
gpg --default-key email@domain.com --symmetric --sign secrets.txt
当你解密gpg文件，并输入了相应密码时，你将会看到以下输出：

1
2
3
gpg: Signature made Mon 17 Aug 17:37:58 2015 BST using RSA key ID BAE1D7F0
gpg: Good signature from "Mark McDonnell (Integralist) <email@domain.com> "
gpg: WARNING: message was not integrity protected
OpenSSL加密

使用OpenSSL加密文件的最简单方法如下（文件的密码是foobar，在命令的最末端，我们还使用了salt以提高安全性）：

1
echo -n 'someTextIWantToEncrypt' | openssl enc -e -salt -out test.txt -aes-256-cbc -pass pass:foobar
要解密这个文件，我们可以使用-d标志（-e标志是加密）：

1
openssl enc -d -salt -in test.txt -out decrypted.txt -aes-256-cbc -pass pass:foobar
如果你不怕麻烦想要通信可以更加安全，可以使用一对密钥。下面的例子中，假设我们是”Alice”，收件人是”Bob”：

1
2
3
4
5
6
7
#  Bob需要把他的RSA密钥用PEM证书的格式发送给我们

#  所以Bob首先要做的事情是生成一个包含他私钥的PEM
openssl rsa -in id_rsa -outform pem >  id_rsa.pem

#  然后生成一个含有Bob公钥的PEM
openssl rsa -in id_rsa -pubout -outform pem >  id_rsa.pub.pem
这时，Alice和Bob需要解决的问题是如何安全地共享彼此的公钥。我会建议直接当面递交，以避免网络嗅探的问题（用浏览器和server交互的情况下，我们有PKI来帮助我们“认证” —— 但是很遗憾我们并没有这样的机制）。

一旦Alice得到了Bob的公钥，她会按照下面的步骤操作：

1
2
3
4
5
6
7
8
#  Alice生成一个256位(32 byte)的random key
openssl rand -base64 32 >  key.bin

#  Alice用Bob的公钥来加密这个random key
openssl rsautl -encrypt -inkey id_rsa.pub.pem -pubin -in key.bin -out key.bin.enc

# Alice用Bob的公钥加密文件
openssl enc -aes-256-cbc -salt -in SECRET_FILE -out SECRET_FILE.enc -pass file:./key.bin
Alice现在可以发送加密后的文件（例如：SECRET_FILE.enc）给Bob。一旦Bob拿到加密文件，他可以follow下面几个步骤：

1
2
3
4
5
#  Bob使用自己的私钥解密得到random key
openssl rsautl -decrypt -inkey id_rsa.pem -in key.bin.enc -out key.bin

#  Bob用自己的私钥和来解密文件
openssl enc -d -aes-256-cbc -in SECRET_FILE.enc -out SECRET_FILE -pass file:./key.bin
我该用哪一个

OpenSSL在今天这个数字时代被认为是不安全的。enc命令的实现是有bug的，所以在安全社区似乎都推荐丢掉OpenSSL，使用GPG（至少在想要分享一个私密文件这种简单的情景下，更推荐GPG）。

创建，签名，发布和吊销证书

好了，下面我准备创建一个新的根CA，然后我们就可以从自己的个人CA来签发私人证书了。如果有个机构它不想付钱给CA来获得证书，那么就可以用这个方法。（有些服务仅允许通过客户端证书的访问，只要使用者信任发放证书的单位，就没有问题）

我不打算详细地说，因为Ivan Ristić（”Bulletproof SSL and TSL”的作者）已经做了这些工作，你可以在他的免费电子书”OpenSSL Cookbook“中找到相应信息。

如果你想快速地看一下主要流程….

你可以生成一个CSR（证书签名请求，你需要发送给CA，等待CA批准）：

1
openssl req -sha256 -new -key my-private-key.pem -out csr.pem
然后你可以对这个证书做自签名：

1
openssl x509 -req -days 365 -in csr.pem -signkey my-private-key.pem -out my-certificate.pem
注：用一行命令同时生成一对密钥+证书 openssl req -nodes -new -x509 -keyout server.key -out server.cert

更新

我把证书有关的操作写在这里了，文章里讨论了如何用Docker来处理客户端证书验证。

结论

希望坚持看完这篇文章的人，可以得到一些有用的知识或者启发。我写这篇文章的主要目的是帮助自己巩固已学的知识，将来需要用到的时候也能有个参考。最后，我真的很享受钻研这个领域的过程，例如，PKI和SSL握手，因为这是困扰我很长时间的一些知识点。

如果有任何的明显的错误（我敢肯定，会有一些疏漏），那么请告诉我，我一定会及时更正的。谢谢！
