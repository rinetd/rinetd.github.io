---
title: Linux命令 Nginx internal
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [nginx]
---
nginx 上这个功能叫做 X-Accel-Redirect 。

假设下载文件的路径在 /path/to/files，比如有 /path/to/files/test1.txt 可以在 nginx 里配置

location /down {
     internal;
     alias   /path/to/files/;
}

internal 选项是这个路径只能在 nginx 内部访问。

然后可以在 php 里写

header("X-Accel-Redirect: /down/test1.txt");

就可以了。

另外，如果在程序那头如果不想要开头的那个“/”，比如想写成 header("X-Accel-Redirect: down/test1.txt"); ，那么在 nginx 的那条 alias 的最后就要加一个 “/”。



什么是sendfile？
nginx官方只是一句带过，如果你需要了解详细的请参考： http://celebnamer.celebworld.ws/stuff/mod_xsendfile/

为什么要用sendfile？
原因很简单，项目中有个需求是后端程序负责把源文件打包加密生成目标文件，然后程序读取目标文件返回给浏览器；这种做法有个致命的缺陷就是占用大量后端程序资源，如果遇到一些访客下载速度巨慢，就会造成大量资源被长期占用得不到释放，很快后端程序就会因为没有资源可用而无法正常提供服务。通常表现就是nginx报502错误！其次在nginx内部我还想实现“由nginx检查目标文件是否存在，如果存在的话就直接返回给浏览器而无需经过后端程序的处理”，这样一来后端程序只是负责生成目标文件，一单目标文件被生成，基本上就不再提供服务，而nginx则提供全静态的文件浏览服务。可想而知，性能的提升还是大很多的！

怎么启用sendfile？
详细配置步骤就不说了，官方wiki已经说明的比较清楚。只提一下注意点吧：
1，location 必须 被定义为 internal;
2，如果在location中使用alias 一定要注意目录结尾的“/”；
3，要注意location 匹配时尽量只用目录名。 我在测试中遇到抓狂的问题。

先说一下我最终的方案：
1，增加一个location作为目标文件的检查，如果存在 就发给internal的location继续处理，如果不存在就rewrite到后端程序处理；
view source
print?
location ~ ^/vdir/(.*)\.ext$
{
    set $obj_file "$1.ext";
    if (!-f /path/to/obj/dir/$obj_file)
    {
        rewrite ^  /backend/app last;
    }
    rewrite ^ /revdir/$obj_file last;
}

以上代码可实现“由nginx检查目标文件是否存在，如果存在的话就直接返回给浏览器而无需经过后端程序的处理”。
接下来看下sendfile相关的location
view source
print?
location /revdir
{
    internal;
    alias /another/dir/;
    #rewrite (.*) /$1 redirect; # 用于测试匹配到的数据是否正确，也可以使用 add_header  xxx  $1  来代替
}

程序里送出的header是 ：
view source
print?
X-Accel-Redirect: /revdir/a/b/xxx.ext

需要再原本的文件路径前加一个虚拟目录 /revdir/

下面讲一下访客在浏览 http://yourdomain/vdir/d/i/r/xxx.ext时的一些处理过程：
1，nginx会先去检查是否存在目标文件”/path/to/obj/dir/d/i/r/xxx.ext”
2.1，如果文件不存在，就会发起一个rewrite ，将请求发往后端程序处理生成文件，然后后端程序只送出”X-Accel-Redirect”header之后完成处理，nginx接受X-Accel-Redirect会被 location /revdir 匹配到，继而发送该文件；
2.1，如果文件存在，也会发起一个rewrite ，然后会被 location /revdir 匹配到，继而直接发送该文件无需经过后端程序;
3，over.

提醒注意：
如果你在测试中发现nginx报500，首先一个考虑下是不是重复匹配次数达到nginx内部预设的10次上限，然后报500错误。有方法可以验证，适当的location添加：
view source
print?
log_subrequest on;

详细请点击参考官方wiki

最后再提一点，远程文件怎么使用这个功能来转发呢？ 不是proxy喔~~
有兴趣的可以参考这里：Nginx-Fu: X-Accel-Redirect From Remote Servers
