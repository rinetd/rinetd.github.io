---
title: Elasticsearch集群管理
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

[Elasticsearch集群管理](http://www.cnblogs.com/xing901022/p/4957543.html)

   ES通过设置【节点的名字】和【集群的名字】，就能自动的组织相同集群名字的节点加入到集群中，并使很多的技术对用户透明化。

   如果用户想要管理查看集群的状态，可以通过一些REST API来实现。

   其他的ES文档翻译参考：Elasticsearch文档总结

REST API用途

ES提供了很多全面的API，大致可以分成如下几种：

1 检查集群、节点、索引的健康情况

2 管理集群、节点，索引数据、元数据

3 执行CRUD，创建、读取、更新、删除 以及 查询

4 执行高级的查询操作，比如分页、排序、脚本、聚合等
查看集群状态

可以通过CURL命令发送REST命令，查询集群的健康状态：

`curl 'localhost:9200/_cat/health?v'`

Localhost是主机的地址，9200是监听的端口号，ES默认监听的端口号就是9200.

这里需要注意的是，windows下安装的CURL有可能不支持单引号，如果有报错，还请改成双引号，内部使用转义字符转义。

得到的相应结果：

epoch      timestamp cluster       status node.total node.data shards pri relo init unassign
1394735289 14:28:09  elasticsearch green           1         1      0   0    0    0        0

可以看到集群的名字是默认的"elasticsearch"，集群的状态时"green"。这个颜色之前也有说过：

1 绿色，最健康的状态，代表所有的分片包括备份都可用

2 黄色，基本的分片可用，但是备份不可用（也可能是没有备份）

3 红色，部分的分片可用，表明分片有一部分损坏。此时执行查询部分数据仍然可以查到，遇到这种情况，还是赶快解决比较好。

上面的结果还可以看到，目前有一个节点，但是没有分片，这是因为我们的ES中还没有数据，一次也就没有分片。



当使用elasticsearch作为集群名字时，会使用单播，查询本机上是否还运行着其他的节点。如果有，则组成一个集群。

（如果使用其他的名字作为集群名字，那么就可能采用多播了！这个在工作中，经常会遇到，大家使用的是一个集群名字，分片总是被搞在一起，导致有人的机器下线后，自己的也无法使用）



通过下面的命令，可以查询节点的列表：

`curl 'localhost:9200/_cat/nodes?v'`

得到的结果如下：

curl 'localhost:9200/_cat/nodes?v'
host         ip        heap.percent ram.percent load node.role master name
mwubuntu1    127.0.1.1            8           4 0.00 d         *      New Goblin

查看所有的索引

在ES中索引有两个意思：

1 动词的索引，表示把数据存储到ES中，提供搜索的过程；这期间可能正在执行一个创建搜索的过程。

2 名字的索引，它是ES中的一个存储类型，与数据库类似，内部包含type字段，type中包含各种文档。

通过下面的命令可以查看所有的索引：

curl 'localhost:9200/_cat/indices?v'

得到的结果如下：

curl 'localhost:9200/_cat/indices?v'
health index pri rep docs.count docs.deleted store.size pri.store.size

由于集群中没有任何的数据，上面的结果中也就只包含列的信息了。
创建索引

下面是创建索引，以及查询索引的例子：
复制代码

curl -XPUT 'localhost:9200/customer?pretty'
{
 "acknowledged" : true
}

curl 'localhost:9200/_cat/indices?v'
health index    pri rep docs.count docs.deleted store.size pri.store.size
yellow customer   5   1          0            0       495b           495b

复制代码

上面的结果中，customer索引的状态是yellow,这是因为此时虽然有5个主分片和一个备份。但是由于只是单个节点，我们的分片还在运行中，无法动态的修改。因此当有其他的节点加入到集群中，备份的节点会被拷贝到另一个节点中，状态就会变成green。
索引和搜索文档

之前说过，索引里面还有类型的概念，在索引文档之前要先设置类型type。

执行的命令如下：

curl -XPUT 'localhost:9200/customer/external/1?pretty' -d '
{
 "name": "John Doe"
}'

执行成功后会得到如下的信息：
复制代码

{
 "_index" : "customer",
 "_type" : "external",
 "_id" : "1",
 "_version" : 1,
 "created" : true
}

复制代码

注意2.0版本的ES在同一索引下，不同的类型，相同的字段名字，是不允许字段类型不一致的。

上面的例子中，为我们创建了一个文档，并且id自动设置为1.

ES不需要再索引文档前，不需要明确的创建索引，如果执行上面的命令，索引不存在，也会自动的创建索引。

执行下面的命令查询，返回信息也如下：
复制代码

curl -XGET 'localhost:9200/customer/external/1?pretty'
{
 "_index" : "customer",
 "_type" : "external",
 "_id" : "1",
 "_version" : 1,
 "found" : true, "_source" : { "name": "John Doe" }
}

复制代码

这里会新增两个字段：

1 found 描述了请求信息

2 _source 为之前索引时的数据
删除索引

执行下面的命令就可以删除索引：

curl -XDELETE 'localhost:9200/customer?pretty'

返回结果：

{
   "acknowledged": true
}

总结

总结上面涉及到的命令大致如下：
复制代码

curl -XPUT 'localhost:9200/customer'//创建索引
//插入数据
curl -XPUT 'localhost:9200/customer/external/1'-d '
{
 "name": "John Doe"
}'
curl 'localhost:9200/customer/external/1'//查询数据
curl -XDELETE 'localhost:9200/customer'//删除索引

复制代码
参考

1【Elasticsearch官方文档】：https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
