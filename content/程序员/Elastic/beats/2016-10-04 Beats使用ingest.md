---
title: Beats配置详解
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
https://kibana.logstash.es/content/elasticsearch/ingest.html
https://www.elastic.co/guide/en/elasticsearch/reference/5.4/accessing-data-in-pipelines.html

# 1. Elasticsearch开启Ingest功能
Ingest 节点是 Elasticsearch 5.0 新增的节点类型和功能。其开启方式为：在 elasticsearch.yml 中定义：

`node.ingest: true`

`curl -u elastic:changeme 120.92.36.21:9200/_ingest`
`curl -u elastic:changeme 120.92.36.21:9200/_cluster/settings`


数据转换(Ingest Node)

在5.0.0中，新增了一个特性数据转换(Ingest Nodes)。他可以不依赖于Logstash实现常用的过滤能力，比如grok, split, convert, date等。它可以用来执行常见的数据转换和处理。可以使用转换节点在实际索引之前对文档进行预处理。在任何转换节点中，处理索引或者块处理之前进行预处理转换。可以在任何节点开启转换功能，或者建立单独的转换节点。在默认情况下，在任何节点都有开启了转换能力，如果要关闭转换能力，需要在配置文件中添加：

node.ingest: false

在索引文档之前进行预处理，它定义了一个指定一系列处理器的管道。每个处理器以某种方式转换文档。例如，你可能有一个管道，包括一个处理器，从文档中删除字段，然后进入另一个处理器，对文档中的字段进行重命名。
使用一个管道，你只需在一个索引或批量请求后加入管道参数。例如:

PUT my-index/my-type/my-id?pipeline=my_pipeline_id
{
  "foo": "bar"
}

在使用前，需要先定义管道，例如定义上面的管道：
```
PUT _ingest/pipeline/my-pipeline-id
{
  "description" : "describe pipeline",
  "processors" : [
    {
      "set" : {
        "field": "foo",
        "value": "bar"
      }

      "set": {
        "field": "_index"
        "value": "{{geoip.country_iso_code}}"
      }
    }
  ]
}
{{ 引用mapping 变量}}
```
