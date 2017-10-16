---
title:  Kibana 5.x 加强安全
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
【入门篇】Elasticsearch、Kibana权限控制 (http://blog.csdn.net/pistolove/article/details/53838138)
[x-pack 安全审计](http://www.2cto.com/os/201611/561466.html)


elasticsearch logstash随着kibana的命名升级直接从2.4跳跃到了5.0，5.x版本的elk在版本对应上要求相对较高，不再支持5.x和2.x的混搭，同时elastic做了一个package，对原本的watch，alert做了一个封装，形成了x-pack

安装 x-pack
elasticsearch ---> bin/elasticsearch-plugin install x-pack (监控以前版本使用bin/plugin -i elasticsearch/marvel/latest)
kibana ---> bin/kibana-plugin install x-pack

bin/elasticsearch
bin/kibana

http://192.168.233.132:9200
输入用户名elastic密码changeme
http://192.168.233.132:5601
输入用户名elastic密码changeme

http://192.168.233.132:9200/_search?pretty=true
查看当前库里所有的索引
```
修改elastic用户的密码
curl -XPUT -u elastic '192.168.233.132:9200/_xpack/security/user/elastic/_password' -d '{"password" : "123456"}'
修改kibana用户的密码
curl -XPUT -u elastic '192.168.233.132:9200/_xpack/security/user/kibana/_password' -d '{"password" : "123456"}'

创建用户组和角色 创建所属用户
创建beats_admin用户组 该用户组对filebeat*有all权限 对.kibana*有manage read index权限
curl -XPOST -u elastic '192.168.233.132:9200/_xpack/security/role/beats_admin' -d '{"indices" : {{"names" : [ "filebeat*" ],"privileges" : ["all"]}, {"names" : [".kibana*"], "privileges" : ["manage", "read", "index"]}}}'
创建jackbeat用户 密码是jackbeat
curl -XPOST -u elastic '192.168.233.132:9200/_xpack/security/user/jackbeat' -d '{"password" : "jackbeat", "full_name" : "jack beat", "email" : "john.doe@anony.nous", "roles" : { "beats_admin" }}'

xpack 的 elk 之间的数据传递保护
kibana --- elasticsearch
vim kibana.yml
elasticsearch.username: "elastic"
elasticsearch.password: "changeme"
logstash --- elasticsearch
input {
	stdin {
	    beats {
	        port => 5044
	    }
	}
}
output {
	elasticsearch {
	    hosts => ["http://192.168.233.132:9200"]
	    user => elastic
	    password => changeme
	}
	stdout {
	    codec => rubydebug
	}
}

```





1、 添加用户
`bin/x-pack/users useradd admin -p kbsonlong -r superuser `
2、查看用户
`bin/x-pack/users list  `
    kbson          : monitoring_user  
    admin          : superuser  

3、测试用户是否成功登录
`curl http://120.92.36.21:9200/_xpack/ --user admin:kbsonlong  `

4、删除用户
`elasticsearch/bin/x-pack/users userdel kbson`  
`elasticsearch/bin/x-pack/users list`  
    admin          :superuser  

----

[安装xpack](https://www.elastic.co/guide/en/x-pack/current/installing-xpack.html)

Run bin/elasticsearch-plugin install from `ES_HOME` on each node in your cluster:

`RUN elasticsearch-plugin install x-pack`
`bin/elasticsearch-plugin install x-pack` # 安装 x-pack
`bin/elasticsearch-plugin remove x-pack`  # 移除 x-pack
`bin/kibana-plugin install x-pack`
`bin/logstash-plugin install x-pack`

[修改密码 x-pack ](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html)

```sh
curl -XPUT -u elastic '120.92.36.21:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d '{
  "password" : "elasticpassword"
}'

curl -XPUT -u elastic '120.92.36.21:9200/_xpack/security/user/kibana/_password' -H "Content-Type: application/json" -d '{
  "password" : "kibanapassword"
}'

curl -XPUT -u elastic '120.92.36.21:9200/_xpack/security/user/logstash_system/_password' -H "Content-Type: application/json" -d '{
  "password" : "logstashpassword"
}'
```
================================================================================
```sh
#== Change Elastic and Kibana Default Password ==#

curl -XPUT -u elastic '120.92.36.21:9200/_xpack/security/user/elastic/_password' -d '{
  "password" : "P@ssw0rd"
}'

curl -XPUT -u elastic '120.92.36.21:9200/_xpack/security/user/kibana/_password' -d '{
  "password" : "P@ssw0rd"
}'

#== Create Role ==#

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/role/events_admin' -d '{
  "indices" : [
    {
      "names" : [ "events*" ],
      "privileges" : [ "all" ]
    },
    {
      "names" : [ ".kibana*" ],
      "privileges" : [ "manage", "read", "index" ]
    }
  ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/role/infra' -d '{
  "indices" : [
    {
      "names" : [ "*" ],
      "privileges" : [ "all" ]
    }
  ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/role/platform' -d '{
  "indices" : [
    {
      "names" : [ "*" ],
      "privileges" : [ "read" ]
    },
    {
      "names" : [ ".kibana*" ],
      "privileges" : [ "manage", "read", "index" ]
    }
  ]
}'

#== Flash and Create User Role ==#
/
curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/kibana_user' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Kibana User",
  "email" : "kibana_user@elk-server2",
  "roles" : [ "kibana_user" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/events_admin' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Events Admin",
  "email" : "events_admin@anony.mous",
  "roles" : [ "events_admin" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/transport_client' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Transport Client",
  "email" : "transport_client@elk-server2",
  "roles" : [ "transport_client" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/monitoring_user' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Monitoring User",
  "email" : "monitoring_user@elk-server2",
  "roles" : [ "monitoring_user" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/remote_monitoring_agent' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Remote Monitoring Agent",
  "email" : "remote_monitoring_agent@elk-server2",
  "roles" : [ "remote_monitoring_agent" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/ingest_admin' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Ingest Admin",
  "email" : "ingest_admin@elk-server2",
  "roles" : [ "ingest_admin" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/reporting_user' -d '{
  "password" : "P@ssw0rd",
  "full_name" : "Reporting User",
  "email" : "reporting_user@elk-server2",
  "roles" : [ "reporting_user" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/infra' -d '{
  "password" : "infra123",
  "full_name" : "Infra User",
  "email" : "infra@elk-server2",
  "roles" : [ "infra" ]
}'

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/platform' -d '{
  "password" : "platform123",
  "full_name" : "platform User",
  "email" : "platform@elk-server2",
  "roles" : [ "platform" ]
}'
```
================================================================================

[创建用户 角色]
```sh
curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/johndoe' -H "Content-Type: application/json" -d '{
  "password" : "userpassword",
  "full_name" : "John Doe",
  "email" : "john.doe@anony.mous",
  "roles" : [ "events_admin" ]
}'

 full access to all indices that match the pattern `events*`
 create visualizations and dashboards for those indices in Kibana
curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/role/events_admin' -H "Content-Type: application/json" -d '{
  "indices" : [
    {
      "names" : [ "events*" ],
      "privileges" : [ "all" ]
    },
    {
      "names" : [ ".kibana*" ],
      "privileges" : [ "manage", "read", "index" ]
    }
  ]
}'


创建一个用户拥有write, delete, and create_index的权限。

    先创建一个role：logstash_writer

POST _xpack/security/role/logstash_writer
{
  "cluster": ["manage_index_templates", "monitor"],
  "indices": [
    {
      "names": [ "logstash-*","business-index-*"],
      "privileges": ["write","delete","create_index"]
    }
  ]
}

    再创建一个用户：logstash_internal拥有Role：logstash_writer

POST /_xpack/security/user/logstash_internal
{
  "password" : "changeme",
  "roles" : [ "logstash_writer"],
  "full_name" : "Internal Logstash User"
}


    上面的操作也可以通过Kibana的Management UI来操作


    创建用户组和角色，创建所属用户
    eg：创建beats_admin用户组，该用户组对filebeat*有all权限，对.kibana*有manage，read，index权限

    curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/role/beats_admin' -d '{
      "indices" : [
        {
          "names" : [ "filebeat*" ],
          "privileges" : [ "all" ]
        },
        {
          "names" : [ ".kibana*" ],
          "privileges" : [ "manage", "read", "index" ]
        }
      ]
    }'

    创建jockbeat用户，密码是jockbeat

    curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/jockbeat' -d '{
      "password" : "jockbeat",
      "full_name" : "jock beat",
      "email" : "john.doe@anony.mous",
      "roles" : [ "beats_admin" ]
    }'
```


========
Users控制(命令行)
（1）查询所有User：

curl -XGET -u elastic '120.92.36.21:9200/_xpack/security/user'


（2）增加User：

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/user/demo' -d '{   "password" : "123456",   "full_name" : " demo",   "email" : “demo@163.com",  "roles" : [ "clicks_admin" ] }'

（3）查询具体User：

curl -XGET -u elastic '120.92.36.21:9200/_xpack/security/user/demo'

（4）删除具体User：

curl -XDELETE -u elastic '120.92.36.21:9200/_xpack/security/user/demo'


13、Roles控制(命令行)
（1）查询所有Roles：

curl -XGET -u elastic '120.92.36.21:9200/_xpack/security/role'


（2）增加Roles：

curl -XPOST -u elastic '120.92.36.21:9200/_xpack/security/role/clicks_admin' -d '{   "indices" : [     {       "names" : [ "events*" ],       "privileges" : [ "all" ]     },     {       "names" : [ ".kibana*" ],       "privileges" : [ "manage", "read", "index" ]     }   ] }’


（3）查询具体Roles：

curl -XGET -u elastic '120.92.36.21:9200/_xpack/security/role/clicks_admin'


（4）删除具体Roles：

curl -XDELETE -u elastic '120.92.36.21:9200/_xpack/security/role/clicks_admin'
