---
title: 解决filebeat的@timestamp无法被json日志的同名字段覆盖的问题
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

在filebeat.yml配置文件中加上以下两行搞定：

    json.keys_under_root: true
    json.overwrite_keys: true

# filebeat 解析json文件
文档里json共有四个配置节点：
    message_key         指定json日志解析后放到哪个key上，默认是json，你也可以指定为log等。
    keys_under_root     默认这个值是FALSE的，也就是我们的json日志解析后会被放在json键上。设为TRUE，所有的keys就会被放到根节点。
    overwrite_keys      是否要覆盖原有的key，这是关键配置，将keys_under_root设为TRUE后，再将overwrite_keys也设为TRUE，就能把filebeat默认的key值给覆盖了。
    add_error_key       添加json_error key键记录json解析失败错误


{"@timestamp":"2017-03-23T09:48:49.304603+08:00", "outer": "value", "inner": "{\"data\": \"value\"}" }

The following configuration decodes the inner JSON object:
```yaml
filebeat.prospectors:
- paths:
    - input.json
  json.keys_under_root: true
  json.overwrite_keys: true
processors:
  - decode_json_fields:
      fields: ["inner"]

output.console.pretty: true
```
The resulting output looks something like this:
```json
{
  "@timestamp": "2016-12-06T17:38:11.541Z",
  "beat": {
    "hostname": "host.example.com",
    "name": "host.example.com",
    "version": "{version}"
  },
  "inner": {
    "data": "value"
  },
  "prospector": {
    "type": "log",
  },
  "offset": 55,
  "outer": "value",
  "source": "input.json",
  "type": "log"
}
```

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



These options make it possible for Filebeat to decode logs structured as JSON messages. Filebeat processes the logs line by line, so the JSON decoding only works if there is one JSON object per line.

The decoding happens before line filtering and multiline. You can combine JSON decoding with filtering and multiline if you set the message_key option. This can be helpful in situations where the application logs are wrapped in JSON objects, like it happens for example with Docker.

Example configuration:

json.keys_under_root: true
json.add_error_key: true
json.message_key: log

keys_under_root
    By default, the decoded JSON is placed under a "json" key in the output document. If you enable this setting, the keys are copied top level in the output document. The default is false.
overwrite_keys
    If keys_under_root and this setting are enabled, then the values from the decoded JSON object overwrite the fields that Filebeat normally adds (type, source, offset, etc.) in case of conflicts.
add_error_key
    If this setting is enabled, Filebeat adds a "json_error" key in case of JSON unmarshalling errors or when a message_key is defined in the configuration but cannot be used.
message_key
    An optional configuration setting that specifies a JSON key on which to apply the line filtering and multiline settings. If specified the key must be at the top level in the JSON object and the value associated with the key must be a string, otherwise no filtering or multiline aggregation will occur.
