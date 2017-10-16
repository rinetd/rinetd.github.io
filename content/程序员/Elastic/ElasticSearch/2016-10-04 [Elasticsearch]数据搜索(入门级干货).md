---
title: Elasticsearch 数据搜索篇·【入门级干货】
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

Elasticsearch 数据搜索篇·【入门级干货】

   ES即简单又复杂，你可以快速的实现全文检索，又需要了解复杂的REST API。本篇就通过一些简单的搜索命令，帮助你理解ES的相关应用。虽然不能让你理解ES的原理设计，但是可以帮助你理解ES，探寻更多的特性。

   其他相关的内容参考：Elasticsearch官方文档翻译

样例数据

为了更好的使用和理解ES，没有点样例数据还是不好模拟的。这里提供了一份官网上的数据，accounts.json。如果需要的话，也可以去这个网址玩玩，它可以帮助你自定义写随机的JSON数据。

首先开启你的ES，然后执行下面的命令，windows下需要自己安装curl、也可以使用cygwin模拟curl命令:

`curl -XPOST 'localhost:9200/bank/account/_bulk?pretty' --data-binary  @accounts.json`

注意：

1 需要在accounts.json所在的目录运行curl命令。

2 localhost:9200是ES得访问地址和端口

3 bank是索引的名称

4 account是类型的名称

5 索引和类型的名称在文件中如果有定义，可以省略；如果没有则必须要指定

6 _bulk是rest得命令，可以批量执行多个操作（操作是在json文件中定义的，原理可以参考之前的翻译）

7 pretty是将返回的信息以可读的JSON形式返回。

执行完上述的命令后，可以通过下面的命令查询：

curl 'localhost:9200/_cat/indices?v'
health index pri rep docs.count docs.deleted store.size pri.store.size
yellow bank    5   1       1000            0    424.4kb        424.4kb

搜索API

ES提供了两种搜索的方式：请求参数方式 和 请求体方式。

请求参数方式

curl 'localhost:9200/bank/_search?q=*&pretty'

其中bank是查询的索引名称，q后面跟着搜索的条件：q=*表示查询所有的内容

请求体方式（推荐这种方式）

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match_all": {} }
}'

这种方式会把查询的内容放入body中，会造成一定的开销，但是易于理解。在平时的练习中，推荐这种方式。



返回的内容
复制代码

{
 "took" : 26,
 "timed_out" : false,
 "_shards" : {
   "total" : 5,
   "successful" : 5,
   "failed" : 0
 },
 "hits" : {
   "total" : 1000,
   "max_score" : 1.0,
   "hits" : [ {
     "_index" : "bank",
     "_type" : "account",
     "_id" : "1",
     "_score" : 1.0, "_source" : {"account_number":1,"balance":39225,"firstname":"Amber","lastname":"Duke","age":32,"gender":"M","address":"880 Holmes Lane","employer":"Pyrami","email":"amberduke@pyrami.com","city":"Brogan","state":"IL"}
   }, {
     "_index" : "bank",
     "_type" : "account",
     "_id" : "6",
     "_score" : 1.0, "_source" : {"account_number":6,"balance":5686,"firstname":"Hattie","lastname":"Bond","age":36,"gender":"M","address":"671 Bristol Street","employer":"Netagy","email":"hattiebond@netagy.com","city":"Dante","state":"TN"}
   }, {
     "_index" : "bank",
     "_type" : "account",
     "_id" : "13",

复制代码

返回的内容大致可以如下讲解：

took：是查询花费的时间，毫秒单位

time_out：标识查询是否超时

_shards：描述了查询分片的信息，查询了多少个分片、成功的分片数量、失败的分片数量等

hits：搜索的结果，total是全部的满足的文档数目，hits是返回的实际数目（默认是10）

_score是文档的分数信息，与排名相关度有关，参考各大搜索引擎的搜索结果，就容易理解。

由于ES是一次性返回所有的数据，因此理解返回的内容是很必要的。它不像传统的SQL是先返回数据的一个子集，再通过数据库端的游标不断的返回数据（由于对传统的数据库理解的不深，这里有错还望指正）。
查询语言DSL

ES支持一种JSON格式的查询，叫做DSL，domain specific language。这门语言刚开始比较难理解，因此通过几个简单的例子开始：

下面的命令，可以搜索全部的文档：

{
 "query": { "match_all": {} }
}

query定义了查询，match_all声明了查询的类型。还有其他的参数可以控制返回的结果：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match_all": {} },
 "size": 1
}'

上面的命令返回了所有文档数据中的第一条文档。如果size不指定，那么默认返回10条。



下面的命令请求了第10-20的文档。
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match_all": {} },
 "from": 10,
 "size": 10
}'

复制代码



下面的命令指定了文档返回的排序方式：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match_all": {} },
 "sort": { "balance": { "order": "desc" } }
}'


执行搜索

上面了解了基本的搜索语句，下面就开始深入一些常用的DSL了。

之前的返回数据都是返回文档的所有内容，这种对于网络的开销肯定是有影响的，下面的例子就指定了返回特定的字段：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match_all": {} },
 "_source": ["account_number", "balance"]
}'

再回到query，之前的查询都是查询所有的文档，并不能称之为搜索引擎。下面就通过match方式查询特定字段的特定内容，比如查询余额为20的账户信息：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match": { "account_number": 20 } }
}'

查询地址为mill的信息：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match": { "address": "mill" } }
}'

查询地址为mill或者lane的信息：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match": { "address": "mill lane" } }
}'

如果我们想要返回同时包含mill和lane的，可以通过match_phrase查询：

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": { "match_phrase": { "address": "mill lane" } }
}'

ES提供了bool查询，可以把很多小的查询组成一个更为复杂的查询，比如查询同时包含mill和lane的文档：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": {
   "bool": {
     "must": [
       { "match": { "address": "mill" } },
       { "match": { "address": "lane" } }
     ]
   }
 }
}'

复制代码

修改bool参数，可以改为查询包含mill或者lane的文档：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": {
   "bool": {
     "should": [
       { "match": { "address": "mill" } },
       { "match": { "address": "lane" } }
     ]
   }
 }
}'

复制代码

也可以改写为must_not，排除包含mill和lane的文档：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": {
   "bool": {
     "must_not": [
       { "match": { "address": "mill" } },
       { "match": { "address": "lane" } }
     ]
   }
 }
}'

复制代码

bool查询可以同时使用must, should, must_not组成一个复杂的查询：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": {
   "bool": {
     "must": [
       { "match": { "age": "40" } }
     ],
     "must_not": [
       { "match": { "state": "ID" } }
     ]
   }
 }
}'

复制代码
过滤查询

之前说过score字段指定了文档的分数，使用查询会计算文档的分数，最后通过分数确定哪些文档更相关，返回哪些文档。

有的时候我们可能对分数不感兴趣，就可以使用filter进行过滤，它不会去计算分值，因此效率也就更高一些。

filter过滤可以嵌套在bool查询内部使用，比如想要查询在2000-3000范围内的所有文档，可以执行下面的命令：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "query": {
   "bool": {
     "must": { "match_all": {} },
     "filter": {
       "range": {
         "balance": {
           "gte": 20000,
           "lte": 30000
         }
       }
     }
   }
 }
}'

复制代码

ES除了上面介绍过的范围查询range、match_all、match、bool、filter还有很多其他的查询方式，这里就先不一一说明了。
聚合

聚合提供了用户进行分组和数理统计的能力，可以把聚合理解成SQL中的GROUP BY和分组函数。在ES中，你可以在一次搜索查询的时间内，即完成搜索操作也完成聚合操作，这样就降低了多次使用REST API造成的网络开销。

下面就是通过terms聚合的简单样例：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "size": 0,
 "aggs": {
   "group_by_state": {
     "terms": {
       "field": "state"
     }
   }
 }
}'

复制代码

它类似于SQL中的下面的语句：

SELECT state, COUNT(*) FROM bank GROUP BY state ORDER BY COUNT(*) DESC

返回的数据：
复制代码

"hits" : {
   "total" : 1000,
   "max_score" : 0.0,
   "hits" : [ ]
 },
 "aggregations" : {
   "group_by_state" : {
     "buckets" : [ {
       "key" : "al",
       "doc_count" : 21
     }, {
       "key" : "tx",
       "doc_count" : 17
     }, {
       "key" : "id",
       "doc_count" : 15
     }, {
       "key" : "ma",
       "doc_count" : 15
     }, {
       "key" : "md",
       "doc_count" : 15
     }, {
       "key" : "pa",
       "doc_count" : 15
     }, {
       "key" : "dc",
       "doc_count" : 14
     }, {
       "key" : "me",
       "doc_count" : 14
     }, {
       "key" : "mo",
       "doc_count" : 14
     }, {
       "key" : "nd",
       "doc_count" : 14
     } ]
   }
 }
}

复制代码

由于size设置为0，它并没有返回文档的信息，只是返回了聚合的结果。

比如统计不同账户状态下的平均余额：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "size": 0,
 "aggs": {
   "group_by_state": {
     "terms": {
       "field": "state"
     },
     "aggs": {
       "average_balance": {
         "avg": {
           "field": "balance"
         }
       }
     }
   }
 }
}'

复制代码

聚合支持嵌套，举个例子，先按范围分组，在统计不同性别的账户余额：
复制代码

curl -XPOST 'localhost:9200/bank/_search?pretty' -d '
{
 "size": 0,
 "aggs": {
   "group_by_age": {
     "range": {
       "field": "age",
       "ranges": [
         {
           "from": 20,
           "to": 30
         },
         {
           "from": 30,
           "to": 40
         },
         {
           "from": 40,
           "to": 50
         }
       ]
     },
     "aggs": {
       "group_by_gender": {
         "terms": {
           "field": "gender"
         },
         "aggs": {
           "average_balance": {
             "avg": {
               "field": "balance"
             }
           }
         }
       }
     }
   }
 }
}'

复制代码

聚合可以实现很多复杂的功能，而且ES也提供了很多复杂的聚合，这里作为引导篇，也不过多介绍了。



对于基本的数据搜索大致就是上面讲述的样子，熟悉了一些常用的API，入门还是很简单的，倒是要熟练使用ES，还是需要掌握各种搜索查询的命令，以及ES内部的原理。
