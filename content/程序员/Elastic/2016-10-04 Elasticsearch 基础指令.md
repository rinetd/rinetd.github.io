---
title:  Elasticsearch
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

http://elasticsearch-cheatsheet.jolicode.com/

# 1.集群健康(cluster health)
`curl -u elastic:changeme 120.92.36.21:9200/_cluster/health?pretty`
# 2. `_mget`允许我们一次性检索多个文档一样
# 3. `_bulk` API允许我们使用一个请求来实现多个文档的create[当文档不存在时创建]、index[创建新文档或替换已有文档]、update[局部更新文档]或delete

# 4. `_search` 空搜索只有10个文档在hits数组中。
## 分页 看到其他文档

和SQL使用LIMIT关键字返回只有一页的结果一样，Elasticsearch接受from和size参数：

from: 跳过开始的结果数，默认0
size: 结果数，默认10
`curl -u elastic:changeme 120.92.36.21:9200/_search?from=10&size=5`

`curl -u elastic:changeme 120.92.36.21:9200/_search?search_type=count&size=0`
## match查询子句用来找寻在title字段中找寻包含dns的成员：
```
curl -u elastic:changeme 120.92.36.21:9200/_search?pretty -d '
{
    "query": {
      "match": {
          "title": "dns"
      }
    }
}
'
```

# `_mapping` 映射
`curl -u elastic:changeme '120.92.36.21:9200/_mapping?from=10&size=5'`

如果是按日期索引的日志，那么最好定期清除旧索引：
` curl -XDELETE -u <USER>:<PASSWORD> http://<HOST>:9200/logstash-$(date -d '-10days' +'%Y.%m.%d')`


a、导入模版
`curl -XPUT -u elastic:changeme  'http://120.92.36.21:9200/_template/filebeat?pretty' -d@/etc/filebeat/filebeat.template.json`

b、查看模版
`curl -u elastic:changeme  'http://120.92.36.21:9200/_template/filebeat?pretty'`

c、清理旧的 index（如果是新配置的服务，没有生成任何 index 因此也不需要清理，可略过这一步）
先查看现有的 index
`curl -u elastic:changeme  '120.92.36.21:9200/_cat/indices?v'`
删除 filebeat-* 匹配的所有 index
`curl -XDELETE 'http://120.92.36.21:9200/filebeat-*?pretty'`
再次查看，确认一下结果是否符合预期：
`curl -u elastic:changeme '120.92.36.21:9200/_cat/indices?v'`


#################################
#KIBANA
#################################

url_elasticsearch = 'http://120.92.36.21:9200'
kibana_element_dir = '/vagrant/cookbooks/elk-reflex/files/default/kibana'
#
# Commands to export Kibana element :
#   - curl http://120.92.36.21:9200/.kibana/dashboard/DASHBOARD_NAME/_source?pretty=1 > DASHBOARD_FILE.json
#		- curl http://120.92.36.21:9200/.kibana/visualization/VISUALIZATION_NAME/_source?pretty=1 > VISUALIZATION_FILE.json
#		- curl http://120.92.36.21:9200/.kibana/search/SEARCH_NAME/_source?pretty=1 > SEARCH_FILE.json
#

bash 'kibana creating index' do
  code <<-EOH
curl -XDELETE #{url_elasticsearch}/logstash-*
curl -XPOST #{url_elasticsearch}/_template/reflex --data "@#{kibana_element_dir}/template_reflex.json"
curl -XPOST #{url_elasticsearch}/.kibana/index-pattern/logstash-* -d '{"title" : "logstash-*",  "timeFieldName": "@timestamp"}'
curl -XPUT #{url_elasticsearch}/.kibana/config/4.6.1 -d '{"defaultIndex" : "logstash-*"}'
    EOH
  retries 3
  retry_delay 5
end

bash 'kibana creating searches' do
  code <<-EOH
curl -XPOST #{url_elasticsearch}/.kibana/search/Error-List --data "@#{kibana_element_dir}/search_Error-List.json"
curl -XPOST #{url_elasticsearch}/.kibana/search/Traces --data "@#{kibana_element_dir}/search_Traces.json"
curl -XPOST #{url_elasticsearch}/.kibana/search/SQL-Dump-List --data "@#{kibana_element_dir}/search_SQL-Dump-List.json"
    EOH
end


bash 'kibana creating visualizations' do
  code <<-EOH
curl -XPOST #{url_elasticsearch}/.kibana/visualization/Activity --data "@#{kibana_element_dir}/visualization_Activity.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/Top-10-Errors --data "@#{kibana_element_dir}/visualization_Top-10-Errors.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/Error-Number --data "@#{kibana_element_dir}/visualization_Error-Number.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/Users --data "@#{kibana_element_dir}/visualization_Users.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/Server-Role --data "@#{kibana_element_dir}/visualization_Server-Role.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/Programs --data "@#{kibana_element_dir}/visualization_Programs.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/SQL-Cursor --data "@#{kibana_element_dir}/visualization_SQL-Cursor.json"
curl -XPOST #{url_elasticsearch}/.kibana/visualization/SQL-Dump-Repartition --data "@#{kibana_element_dir}/visualization_SQL-Dump-Repartition.json"
    EOH
end


bash 'kibana creating dashboard' do
  code <<-EOH
curl -XPOST #{url_elasticsearch}/.kibana/dashboard/Main-Reflex --data "@#{kibana_element_dir}/dashboard_Main-Reflex.json"
curl -XPOST #{url_elasticsearch}/.kibana/dashboard/SQL-Dump-Reflex --data "@#{kibana_element_dir}/dashboard_SQL-Dump-Reflex.json"
    EOH
end
