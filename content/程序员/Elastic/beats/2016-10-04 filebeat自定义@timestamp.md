---
title: 解决filebeat的@timestamp无法被json日志的同名字段覆盖的问题
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
默认@timestamp是filebeat读取日志时的时间戳，但是我们在读取日志的时候希望根据日志生成时间来展示，以便根据日志生成时间点来定位问题。

这是我生成json日志的格式：
```json
    {"@timestamp":"2017-03-23T09:48:49.304603+08:00","@source":"vagrant-ubuntu-trusty-64","@fields":{"channel":"xhh.mq.push","level":200,"ctxt_queue":"job_queue2","ctxt_exchange":"","ctxt_confirm_selected":true,"ctxt_confirm_published":true,"ctxt_properties":{"confirm":true,"transaction":false,"exchange":[],"queue":[],"message":[],"consume":[],"binding_keys":[],"exchange2":{"type":"direct"}}},"@message":"904572:58d31d7ddc790:msg_param1~","@tags":["xhh.mq.push"],"@type":"xhh.mq.push"}
```
日志中包含了@timestamp，但是用filebeat收集日志后，@timestamp被filebeat自动生成的时间给覆盖了：
```
    {
            "offset" => 413806671,
           "@source" => "vagrant-ubuntu-trusty-64",
             "@tags" => [
            [0] "xhh.mq.push"
        ],
             "@type" => "xhh.mq.push",
        "input_type" => "log",
            "source" => "/tmp/xhh_mq_20170323.log",
              "type" => "rabbitmq",
           "@fields" => {
                     "ctxt_exchange" => "",
             "ctxt_confirm_selected" => true,
                             "level" => 200,
                           "channel" => "xhh.mq.push",
                   "ctxt_properties" => {
                     "confirm" => true,
                   "exchange2" => {
                    "type" => "direct"
                },
                    "exchange" => nil,
                     "consume" => nil,
                     "message" => nil,
                 "transaction" => false,
                       "queue" => nil,
                "binding_keys" => nil
            },
                        "ctxt_queue" => "job_queue0",
            "ctxt_confirm_published" => true
        },
              "tags" => [
            [0] "beats_input_raw_event"
        ],
          "@message" => "995428:58d31d7ddc790:msg_param1~",
        "@timestamp" => 2017-03-24T01:00:00.930Z,
              "beat" => {
            "hostname" => "vagrant-ubuntu-trusty-64",
                "name" => "vagrant-ubuntu-trusty-64",
             "version" => "5.2.1"
        },
          "@version" => "1",
              "host" => "vagrant-ubuntu-trusty-64"
    }
```
时间变成了filebeat读取日志时的时间，这完全不是我想要的，没办法网上找解决方式，发现GitHub官网也有人在问同个问题，链接地址：https://github.com/logstash-plugins/logstash-input-beats/issues/33

话说好像是bug？评论里说可以用grok进行转换，即在日志里先定义一个messageTimestamp字段，然后filebeat推到logstash后再通过filter配置将其转换为logstash的timestamp，貌似这也可以，不过应该会有更简便的解决方式的才对。在万能的谷哥引导下，原来filebeat最新版已经解决了这个问题了~ So就是这里了：https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html#config-json

在filebeat.yml配置文件中加上以下两行搞定：

    json.keys_under_root: true
    json.overwrite_keys: true

文档里json共有四个配置节点：

    keys_under_root

        默认这个值是FALSE的，也就是我们的json日志解析后会被放在json键上。设为TRUE，所有的keys就会被放到根节点。

    overwrite_keys

        是否要覆盖原有的key，这是关键配置，将keys_under_root设为TRUE后，再将overwrite_keys也设为TRUE，就能把filebeat默认的key值给覆盖了。

    add_error_key

        添加json_error key键记录json解析失败错误

    message_key

        指定json日志解析后放到哪个key上，默认是json，你也可以指定为log等。
