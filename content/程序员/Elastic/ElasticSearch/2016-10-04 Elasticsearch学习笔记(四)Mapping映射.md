---
title: Elasticsearch学习笔记(四)Mapping映射
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

Elasticsearch学习笔记(四)Mapping映射
Mapping简述
Elasticsearch是一个schema-less的系统，但并不代表no shema，而是会尽量根据JSON源数据的基础类型猜测你想要的字段类型映射。
Elasticsearch中Mapping类似于静态语言中的数据类型，但是同语言的数据类型相比，映射还有一些其他的含义。
Elasticsearch会根据JSON源数据的基础类型猜测你想要的字段映射。将输入的数据转变成可搜索的索引项。Mapping就是我们自己定义的字段的数据类型，同时告诉Elasticsearch如何索引数据以及是否可以被搜索。
映射的增删改查
Elasticsearch可以根据数据中的新字段来创建新的映射，当然，在正式数据写入之前我们可以自己定义Mapping,
等数据写入时，会按照定义的Mapping进行映射。如果后续数据有其他字段时，Elasticsearch会自动进行处理。


    curl -XPUT 'http://120.92.36.21:9200/logstash-2016.01.01/_mapping' -d '  
    {  
        "mappings" : {  
            "syslog" : {  
                "properties" : {  
                    "@timestamp" : {  
                        "type" : "date"  
                    },  
                    "message" : {  
                        "type" : "string"  
                    },  
                    "pid" : {  
                        "type" : "long"  
                    }  
                }  
            }  
        }  
    }  
    '  


在这里需要注意一下，我们已经存在的索引是不可以更改它的映射的，对于存在的索引，只有新字段出现时，Elasticsearch才会自动进行处理。如果确实需要修改映射，那么就使用reindex,采用重新导入数据的方式完成。
ReIndex
Elasticsearch并不提供针对索引的rename,mapping、alter等操作。如果需要更改某个字段的mapping映射，只有一些其他工具。
用Logstash重建索引：
在最新版的logstash中，对logstash-input-elasticsearch插件做了一定的修改，使得通过Logstash完成重建索引称为可能。
Delete
虽然写入数据时Elasticsearch会自动的添加映射进行处理，但是删除数据并不会删除数据的映射
#curl -XDELETE 'http://120.92.36.21:9200/logstash-2016.01.01/syslog'                  删除了syslog下面的全部数据，但是syslog的映射还在
删除映射的命令:
#curl -XDELETE 'http://120.92.36.21:9200/logstash-2016.01.01/_mapping'
删除索引的话映射也会删除
#curl -XDELETE 'http://120.92.36.21:9200/logstash-2016.01.01'
查看：
学习索引的话最直接的方式就是查看logstash写入数据到Elasticsearch的时候会根据自带的template生成一个很有学习意义的映射
Elasticsearch数据类型
Elasticsearch自带的数据类型数Lucene索引的依据，也是我们做手动映射调整到依据。
映射中主要就是针对字段设置类型以及类型相关参数。
JSON基础类型如下：
字符串：string
数字：byte、short、integer、long、float、double、
时间：date
布尔值: true、false
数组: array
对象: object
Elasticsearch独有的类型：
多重: multi
经纬度: geo_point
网络地址: ip
堆叠对象: nested object
二进制: binary
附件: attachment

注意点：
Elasticsearch映射虽然有idnex和type两层关系，但是实际索引时是以index为基础的。如果同一个index下不同type的字段出现mapping不一致的情况，虽然数据依然可以成功写入并生成并生成各自的mapping，但实际上fielddata中的索引结果却依然是以index内第一个mapping类型来生成的。
自定义字段映射
Elasticsearch的Mapping提供了对Elasticsearch中索引字段名及其数据类型的定义，还可以对某些字段添加特殊属性：该字段是否分词，是否存储，使用什么样的分词器等。
精确索引：
字段都有几个基本的映射选项，类型（type）和索引方式(index)。以字符串类型为例，index有三个选项：
analyzed:默认选项，以标准的全文索引方式，分析字符串，完成索引。
not_analyzed:精确索引，不对字符串做分析，直接索引字段数据的精确内容。
no：不索引该字段。
对于日志文件来说，很多字段都是不需要再Elasticsearch里做分析这步的，所以，我们可以这样设置：
[plain] view plain copy
print?在CODE上查看代码片派生到我的代码片

    "myfieldname" : {  
        "type" : "string",  
        "index" : "not_analyzed"  
    }  


时间格式：
@timestamp这个时间格式在Nginx中叫$time_iso8601，在Rsyslog中叫date-rfc3339,在Elasticsearch中叫dateOptionalTime.但事实上，Elasticsearch完全可以接受其他时间格式作为时间字段的内容。对于Elasticsearch来说，时间字段内容实际上就是转换成long类型作为内部存储的。所以，接受段的时间格式可以任意设置：
[plain] view plain copy
print?在CODE上查看代码片派生到我的代码片

    @timestamp: {  
        "type" : "date",  
        "index" : "not_analyzed",  
        "doc_values" : true,  
        "format" : "dd/MM/YYYY:HH:mm:ss Z"  
    }  

多种索引：
多重索引是Logstash用户习惯的的一个映射，因为这是Logstash默认开启的配置：
[plain] view plain copy
print?在CODE上查看代码片派生到我的代码片

    "title" : {  
        "type" : "string",  
        "fields" : {  
            "raw" : {  
                "type" : "string",  
                "index" : "not_analyzed"          
            }  
        }  
    }  

其作用时，在title字段数据写入的时候，Elasticsearch会自动生成两个字段，分别是title和title.raw。这样，有可能同时需要分词和部分次结果的环境，就可以很灵活的使用不同的索引字段了。比如，查看标题中最常用的单词，应该是使用title字段，查看阅读数最多的文章标题，应该是使用title.raw字段。
多值字段：
空字段：
数组可以使空的。这等于有零个值。事实上，Lucene没法存放null值，所以一个null值的字段呗认为是孔子段。
下面这四个字段将被识别为空字段而不被索引:
"empty_string" : "",
"null_value" : null,
"empty_array" : [],
"array_with_null_value" : [ null ]
多层对象：
我们需要讨论的最后一个自然JSON数据类型是对象(object)。
内部对象(inner objects)经常用于嵌入一个实体或对象里的另一个地方。例如，
