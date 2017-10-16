---
title: elk日志分析filebeat配置（filebeat + logstash）
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
日志格式：

nginx_access:

{ "@timestamp":"2017-01-23T15:16:48+08:00","client": "192.168.0.151","@version":"1","host":"192.168.0.147","size":160,"responsetime":0.000,"domain":"mv.bjfxr.com","url":"/index.html","status":"200","ua":"curl/7.19.7 (x86_64-neokylin-linux-gnu) libcurl/7.19.7 NSS/3.12.9.0 zlib/1.2.3 libidn/1.18 libssh2/1.2.2"}
{ "@timestamp":"2017-01-23T15:16:48+08:00","client": "192.168.0.151","@version":"1","host":"192.168.0.147","size":30027,"responsetime":0.001,"domain":"mv.bjfxr.com","url":"/aaaaa/index.html","status":"200","ua":"curl/7.19.7 (x86_64-neokylin-linux-gnu) libcurl/7.19.7 NSS/3.12.9.0 zlib/1.2.3 libidn/1.18 libssh2/1.2.2"}


nginx_error:

2017/01/19 08:42:53 [crit] 5621#0: *6428 connect() to unix:/tmp/php-cgi.sock failed (2: No such file or directory) while connecting to upstream, client: 192.168.0.151, server: mv.bjfxr.com, request: "GET /dts/index/cat/cat/notice.html HTTP/1.0", upstream: "fastcgi://unix:/tmp/php-cgi.sock:", host: "mv.bjfxr.com.com"
2017/01/19 12:42:53 [crit] 5621#0: *6428 connect() to unix:/tmp/php-cgi.sock failed (2: No such file or directory) while connecting to upstream, client: 192.168.0.151, server: mv.bjfxr.com, request: "GET /dts/index/cat/cat/notice.html HTTP/1.0", upstream: "fastcgi://unix:/tmp/php-cgi.sock:", host: "mv.bjfxr.com.com"


tomcat:

 INFO 2017-01-23 15:18:51 com.newland.bi.webservice.trans.fromsub.dao.DtsDao.queryCnt ==>  Preparing: select count(1) from CTMPMART.TB_WS_VEG_IN_INFO where trunc(in_date) = to_date('20170121','yyyymmdd') and ( BATCH_ID = '1101008031275728')
 DEBUG 2017-01-23 15:18:51 com.newland.bi.webservice.trans.fromsub.dao.DtsDao.queryCnt ==> Parameters:
__________________________________________________________________________________________________________________________________

filebeat配置文件

filebeat.prospectors:
- input_type: log
  paths:
    - /home/wwwlogs/nginx_access.log
  document_type: nginx_access

- input_type: log
  paths:
    - /home/wwwlogs/nginx_error.log    ##nginx错误日志位置
  document_type: nginx_error               ##nginx错误日志注明类型（以后logstash不同类型创建不同索引）

- input_type: log
  paths:
    - /dts1/ctmpweb/logs/dts_svc.log
    - /dts1/ctmpweb/logs/dts_web.log
  document_type: tomcat_ctmpweb
  multiline.pattern: '^\sINFO|^\sERROR|^\sDEBUG|^\sWARN'      ##将日志info，error,debug,warn开头的作为一行（用于java日志多行合并，也可以用时间为开头）
  multiline.negate: true
  multiline.match: after

  exclude_lines: ['^ INFO','^ DEBUG']                        ##排除info,debug开头的行

  include_lines: ["^ ERROR", "^ WARN"]                        ##将error，warn开头的行传给logstash

- input_type: log
  paths:
    - /dts1/intf1/logs/dts_if.log
  document_type: tomcat_intf1
  multiline.pattern: '^\sINFO|^\sERROR|^\sDEBUG|^\sWARN'
  multiline.negate: true
  multiline.match: after

  exclude_lines: ['^ INFO','^ DEBUG']

  include_lines: ["^ ERROR", "^ WARN"]


output.logstash:
  # The Logstash hosts
   hosts: ["10.0.1.1:5044"]

____________________________________________________________________________________________________________________________________

input {
       beats  {
              port => 5044
      }
}

filter {
        if [type]  == "nginx_access"  {
            json {
                source => "message"
            }

}

output {
     if [type] == "tomcat_ctmpweb" {            ##按照type类型创建多个索引
        elasticsearch {
                       hosts => ["192.168.0.148:9200"]
                       index => "tomcat_ctmpweb_%{+YYYY.MM.dd}"
                                 }

          }


     if [type] == "nginx_access" {            ##按照type类型创建多个索引
        elasticsearch {
                       hosts => ["192.168.0.148:9200"]
                       index => "nginx_access_%{+YYYY.MM.dd}"
                                 }

          }


     if [type] == "nginx_error" {            ##按照type类型创建多个索引
        elasticsearch {
                       hosts => ["192.168.0.148:9200"]
                       index => "nginx_error_%{+YYYY.MM.dd}"
                                 }

          }

}
