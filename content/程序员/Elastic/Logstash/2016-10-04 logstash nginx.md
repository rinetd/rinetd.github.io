---
title:  logstash nginx
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
nginx_log_format_access

'$remote_addr [$time_local] $status '
  '"$request" $body_bytes_sent "$http_referer" '
'"$http_user_agent" "$upstream_addr" "$proxy_add_x_forwarded_for" "$request_time"'

```
input {
  file {
      type => "nginx-access"
      path => "/var/log/nginx/*access.log"
  }
  file {
      type => "nginx-error"
      path => "/var/log/nginx/*error.log"
  }
}

filter {
  if [type] == "nginx-access" {
    grok {
        match => { "message" => "(?:%{SYSLOGTIMESTAMP}) ?%{SYSLOGHOST:logsource} %{SYSLOGPROG}: ?%{IPORHOST:clientip} \[%{HTTPDATE:timestamp}\] %{NUMBER:response} \"%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}\" (?:%{NUMBER:bytes}|-) (?:\"(?:%{URI:referrer}|-)\"|%{QS:referrer}) %{QS:agent} %{QS:xforwardedip} %{QS:xforwardedfor} %{QS:respons_time}"}
    }
  }
  if [type] == "nginx-error" {
    grok {
      match => { "message" => "(?:%{SYSLOGTIMESTAMP}) ?%{SYSLOGHOST:logsource} %{SYSLOGPROG}: (?<timestamp>\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) \[%{DATA:severity}\] %{NOTSPACE} %{NOTSPACE} (?<message>(.|\r|\n)*)(?:, client: (?<clientip>%{IP}|%{HOSTNAME}))(?:, server: %{IPORHOST:server})(?:, request: %{QS:request})?(?:, host: %{QS:host})?(?:, referrer: \"%{URI:referrer})?"}
    }
  }
}

output {
  if [type] == "nginx-access"{
    elasticsearch {
      hosts => "120.92.36.21:9200"
      template => "/etc/logstash/templates.d/access.json"
      template_name => "access"
      manage_template => true
      template_overwrite => true
      index => "access-%{+YYYY.MM.dd}"
    }
  }
  if [type] == "nginx-error"{
    elasticsearch {
      hosts => "120.92.36.21:9200"
      template => "/etc/logstash/templates.d/error.json"
      template_name => "error"
      manage_template => true
      template_overwrite => true
      index => "error-%{+YYYY.MM.dd}"
    }
  }
}

=================================================================================================================================================================

input {
  file {
      path => "/var/log/nginx/*access.log"
      start_position => beginning
  }
}
filter {
  grok {
      match => { "message" => "(?:%{SYSLOGTIMESTAMP}) ?%{SYSLOGHOST:logsource} %{SYSLOGPROG}: ?%{IPORHOST:clientip} \[%{HTTPDATE:timestamp}\] %{NUMBER:response} \"%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}\" (?:%{NUMBER:bytes}|-) (?:\"(?:%{URI:referrer}|-)\"|%{QS:referrer}) %{QS:agent} %{QS:xforwardedip} %{QS:xforwardedfor} %{QS:respons_time}"}
  }
}
output {
  elasticsearch {
      hosts => "120.92.36.21:9200"
      manage_template => true
      index=> "access-%{project}-%{+YYYY.MM.dd}"
  }
}

==============================================================================================================================================================

input {
  file {
      path => "/var/log/nginx/sample_access.log"
      start_position => beginning
  }
}

filter {
  grok {
    match => { "message" => "(?:%{SYSLOGTIMESTAMP}) ?%{SYSLOGHOST:logsource} %{SYSLOGPROG}: ?%{IPORHOST:clientip} \[%{HTTPDATE:timestamp}\] %{NUMBER:response} \"%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}\" (?:%{NUMBER:bytes}|-) (?:\"(?:%{URI:referrer}|-)\"|%{QS:referrer}) %{QS:agent} %{QS:xforwardedip} %{QS:xforwardedfor} %{QS:respons_time}"}
   remove_field => ["message"]
  }
  if "_grokparsefailure" in [tags] {
    grok {
      match => {"message" => "%{GREEDYDATA}"}
      remove_tag => ["_grokparsefailure"]
    }
  }
}

output {
        elasticsearch {
                hosts => "192.168.19.35:9200"
                template => "/etc/logstash/templates/access.json"
                template_name => "access"
                manage_template => true
                template_overwrite => true
                index => "access-%{+YYYY.MM.dd}"
        }
}
```
