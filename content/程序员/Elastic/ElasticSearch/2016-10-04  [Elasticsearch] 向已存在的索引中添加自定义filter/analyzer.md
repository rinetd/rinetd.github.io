---
title: 向已存在的索引中添加自定义filter analyzer 
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
问题描述

随着应用的不断升级，索引中的类型也会越来越多，新增加的类型中势必会使用到一些自定义的Analyzer。但是通过_settings端点的更新API不能直接在已经存在的索引上使用。在sense中进行更新时会抛出异常：

PUT /symbol
{
  "settings": {
    "analysis": {
      "filter": {
        "edgengram": {
           "type": "edgeNGram",
           "min_gram": "1",
           "max_gram": "255"
        }
      },
      "analyzer": {
        "symbol_analyzer": {
          "type": "custom",
          "char_filter": [],
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "word_delimiter"
          ]
        },
        "back_edge_ngram_analyzer": {
          "type": "custom",
          "char_filter": [],
          "tokenizer": "whitespace",
          "filter": [
            "reverse",
            "edgengram",
            "reverse"
          ]
        }
      }
    }
  }
}


上例中，我们希望向名为symbol的索引中添加一个filter和两个analyzers。但是会抛出如下的错误信息：

{
   "error": "IndexAlreadyExistsException[[symbol] already exists]",
   "status": 400
}



提示我们该索引已经存在了，无法添加。
解决方案

最直观的解决方案是首先备份该索引中已经存在的数据，然后删除它再重建该索引。这种方式比较暴力，当索引中已经存在相当多的数据时，不建议这样做。

另外一种方案是使用_open和_close这一对端点，首先将目标索引关闭，执行需要的更新操作，然后再打开该索引。

POST /symbol/_close

PUT /symbol/_settings
{
  "settings": {
    ....    
  }
}

POST /symbol/_open


这样就避免了需要重建索引的麻烦。有了新添加的filter和analyzer，就可以根据需要再对types中的mappings进行更新了。
