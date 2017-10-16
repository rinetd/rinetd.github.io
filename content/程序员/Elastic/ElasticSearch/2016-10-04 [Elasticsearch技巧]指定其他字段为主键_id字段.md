---
title: elasticsearch指定其他字段为主键_id字段
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
[The Great Mapping Refactoring](https://www.elastic.co/blog/great-mapping-refactoring#meta-fields)
用了这么久的elasticsearch,一直以为es只有对_id字段进行赋值的方法来使用主键进行去重,今天才发现原来_id也可以指定为其他字段,

es会自动将指定字段的值,赋值给_id字段,这样就比较方便了.这里记录一下:


这里直接索引库和mapping一起创建:
```
curl -XPOST localhost:9200/test -d '{
 "settings" : {
     "number_of_shards" : 1,
     "number_of_replicas":0
 },
 "mappings" : {
     "test1" : {
         "_id":{"path":"mainkey"},
         "_source" : { "enabled" : false },
         "properties" : {
             "mainkey" : { "type" : "string", "index" : "not_analyzed" }
         }
     }
 }
}'
```
然后看一下mapping如下:

然后插入一条数据:
curl -XPOST localhost:9200/test/test1 -d'
{
"mainkey":"aaa"
}'
然后查询:


这样,就完成了.
