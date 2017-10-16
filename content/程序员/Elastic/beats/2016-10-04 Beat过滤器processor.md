---
title: filebeat 过滤器
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

数据过滤有两个地方
1. 在 `prospectors`中 通过 `include_lines`, `exclude_lines`, and `exclude_files`.

```yaml
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/myapp/*.log
  include_lines: ["^ERR", "^WARN"]
```
2. 在 `processors` 中通过事件过滤器(管道) 目前支持5种`add_cloud_metadata` `decode_json_fields` `drop_event` `drop_fields` `include_fields`

在数据输出之前可以通过libbeat提供的processor预处理
每一个`processors`其接受一个事件event 处理后返回一个时间event
`event -> processor 1 -> event1 -> processor 2 -> event2 ...`

## add_cloud_metadata

## 1.丢弃信息 drop_event   
```yaml
1. 丢弃 DBG 开头的信息
processors:
 - drop_event:
     when:
        regexp:
           message: "^DBG:"
2. 丢弃 包含test的信息
processors:
- drop_event:
    when:
       contains:
          source: "test"
```           
## 2.解码json decode_json_fields
```yaml
processors:
 - decode_json_fields:
     fields: ["field1", "field2", ...] # 解码字段
     process_array: false              # 数组是否解码 默认:false
     max_depth: 1                      # 解码深度
     target:            
     overwrite_keys: false             # 覆盖字段  默认:false
```


## 3. 丢弃字段 drop_fields
注:@timestamp 和 type 字段 不论添不添加都不会删掉
 ```yaml
 processors:
 - drop_fields:
     when:
        condition
     fields: ["field1", "field2", ...]
 ```
## 4. 包含字段include_fields


Apache2 Fields
Auditd Fields
Beat Fields
Cloud Provider Metadata Fields
Log File Content Fields
MySQL Fields
Nginx Fields
System Fields

# 条件判断 conditions
## 1. 相等
equals:
  http.response.code: 200


## 2. 包含  contains condition checks if a value is part of a field.
  fields 可以是string 或 array ; value必须是sting
```  
contains:
  status: "Specific error"  
```
## 3. 正则匹配
```
    regexp:
      system.process.name: "foo.*"
```
## 4. 范围匹配
range:
    http.response.code:
        gte: 400
range:
    http.response.code.gte: 400
  `0.5 < system.cpu.use < 0.8`
range:
    system.cpu.user.pct.gte: 0.5
    system.cpu.user.pct.lt: 0.8    
## 5. 与
and:
  - equals:
      http.response.code: 200
  - equals:
      status: OK
## 6. 或
or:
  - equals:
      http.response.code: 304
  - equals:
      http.response.code: 404
## 7. 非
not:
  equals:
    status: OK      
