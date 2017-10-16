---
title:  ElasticSearch——跨域访问
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
跨域请求：

ES服务器安装部署成功之后

从另外一个域的浏览器访问ES服务器数据，会出现跨域的问题。

抛出错误：No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'null' is therefore not allowed access. The response had HTTP status code 503.

查看ES相关资料，得知ES默认是不允许跨域的

但是我们可以通过ES的配置文件：elasticsearch.yml中添加如下参数：

```yaml

    #开启跨域访问支持，默认为false  

    http.cors.enabled: true  

    #跨域访问允许的域名地址，(允许所有域名)以上使用正则  

    http.cors.allow-origin: /.*/   
```

通过以上配置，并重新启动ES服务器，就可以自由访问ES服务器

但是允许访问的域名地址为“ * “是高风险的，这说明部署的ES实例允许被任何地方跨域请求。

因此实际使用最好根据需求设定允许访问的域名地址。


ES请求cache：false

修改好配置文件并重启ES，再次查询，却发现又抛出另一个错误。

错误代码如下：

```
    {  
        "error": {  
            "root_cause": [  
                {  
                    "type": "illegal_argument_exception",  
                    "reason": "request [/my_index/my_type/_search] contains unrecognized parameter: [_]"  
                }  
            ],  
            "type": "illegal_argument_exception",  
            "reason": "request [/my_index/my_type/_search] contains unrecognized parameter: [_]"  
        },  
        "status": 400  
    }  
```

JS请求代码如下：


    <script>  
      $.ajax({  
        url: "http://192.18.1.12:9222/my_index/my_type/_search",  
        type: "get",  
        data: { size: 0 },  
        cache: false,  
        success: function (result) {  
          console.log(result);  
        },  
        error: function (err) {  
          console.log(err);  
        }  
      });  

    </script>  

请求的参数中，并没有 _  这个参数。

这是怎么回事呢？

查证之后,原来这是jQuery 的ajax cache选项的处理方式

其处理方式如下：

[javascript] view plain copy
print?

    if ( s.cache === false && s.type.toLowerCase() == "get" )    
        s.data = (s.data ? s.data + "&" : "") + "_=" + (new Date()).getTime();    


如果不缓存的话，就在请求的url的data上添加一个时间戳，这样就不会缓存数据了，因为每次请求的url都不一样。

但是这里是直接请求的ES的resultful API ，其并不会忽略参数"_",而且还验证每个参数是否合法，这里就会报错。

所以去掉对缓存的配置 cache：false，默认的cache配置为true。



    $.ajax({  
       url: "http://192.18.1.12:9222/my_index/my_type/_search",  
       type: "get",  
       data: { size: 0 },  
       success: function (result) {  
         console.log(result);  
       },  
       error: function (err) {  
         console.log(err);  
       }  
     });  


再次执行查询，正确返回预期的结果。

当然也可以直接在浏览器输入地址查询，也能够正确返回。
