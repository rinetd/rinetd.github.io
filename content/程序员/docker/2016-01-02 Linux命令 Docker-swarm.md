---
title: Linux命令 Docker swarm
date: 2016-03-05T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [swarm]
---
[ElasticSearch cluster using Docker Swarm mode 1.12](http://marceloochoa.blogspot.com/2016/09/elasticsearch-cluster-using-docker.html)
## 基本知识
docker swarm init --advertise-addr 192.168.99.100
--advertise-addr vboxnet0  指定发布ip;绑定监听网卡
--advertise-addr 参数用来标记当前管理节点发布出去后的网络地址，集群中的其他节点应该可以通过这个IP访问到管理节点

（3）开放主机端口
下面的端口必须是开放的：
TCP端口2377，集群管理通信
TCP和UDP端口7946，节点间通信
TCP和UDP端口4789，overlay网络交互
firewall-cmd --permanent --add-port=7946/tcp
firewall-cmd --permanent --add-port=7946/udp
firewall-cmd --permanent --add-port=4789/udp
## swarm集群
1. create dockerd:2376
```
docker-machine create -d generic --engine-registry-mirror=https://fl7aylpq.mirror.aliyuncs.com --generic-ip-address=139.129.234.31 --generic-ssh-user=root --generic-ssh-key=$HOME/.ssh/id_rsa --generic-ssh-port 22 ubuntu
docker-machine create -d generic --engine-registry-mirror=https://amoq5ee6.mirror.aliyuncs.com --generic-ip-address=139.129.108.163  --generic-ssh-user=root --generic-ssh-key=$HOME/.ssh/id_rsa --generic-ssh-port 22 aliyun
  > vi /etc/systemd/system/docker.service $ENGINE_REGISTRY_MIRROR
  > ExecStart=/usr/bin/docker daemon -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --storage-driver devicemapper --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic --registry-mirror https://amoq5ee6.mirror.aliyuncs.com

docker run -d --name mariadb -p 3306:3306 -v /var/lib/mysql:/var/lib/mysql -v /var/run/mysqld:/var/run/mysqld mariadb:5.5
```
```
docker-machine create -d virtualbox swmaster # This will be the master
docker-machine create -d virtualbox swnode

> dockerd -D -g /var/lib/docker -H unix:// -H tcp://0.0.0.0:2376 --label provider=virtualbox --tlsverify --tlscacert=/var/lib/boot2docker/ca.pem --tlscert=/var/lib/boot2docker/server.pem --tlskey=/var/lib/boot2docker/server-key.pem -s aufs
> docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc --debug
```
2. active
  & docker-machine.exe env aliyun | Invoke-Expression
  `eval $(docker-machine env swmaster)`
3. swarm node:2377

  + 一台机器只能创建一个swarm 通过 `docker swarm init --advertise-addr vboxnet0`绑定监听网卡
  + 本机器失效后 `docker swarm leave --froce` 删除本节点
  + 通过 `docker node rm --force ubuntu` 删除无效节点
  + 所有manger节点失效后 集群失效
  - 即使有manager 节点,当leader 节点swarm leave 之后 集群失效
  * leader 通过 `docker node demote self` 可以将控制转移
正确的处理方式:
1. manager->leader: `docker node demote leader`
2. manager->leader: `docker node rm --force leader`
3. leader->work:  `docker leave`

推荐做法:
  1. 保证manager的数量>3
  2. 确保 `docker swarm join-token manager` 在leader上执行
```
docker $(docker-machine config swmaster) swarm init --advertise-addr $(docker-machine ip swmaster)

docker swarm join-token manager

docker $(docker-machine config swnode) swarm join --token SWMTKN-1-26tk5t6vg1h9z4vq3z7e17z2wcvor2kt5ws6433qoqli0xh0os-ccy5d06jj4w3mj6s4twe4vs9m $(docker-machine ip swmaster)

docker node rm swnode --force #删除swarm work
```
4. swarm service
docker run 替换成 docker service create
# 滚动更新我们`worker`, 每次更新2个副本容器, 延迟`5s`
docker service update worker --update-parallelism 2 --update-delay 5s --image localhost:5000/dockercoins_worker:v0.01
docker service update worker --image localhost:5000/dockercoins_worker:v0.1 #回滚
```
docker service create --replicas 5 --name helloworld alpine ping google.com
docker service create alpine ping 8.8.8.8
docker service list
docker logs d6155498b874
docker service ps d6155498b874
watch docker service list
docker service ls -q | xargs docker service rm #删除服务
```
### ELK日志平台
- ElasticSearch 用来存储和索引日志.
- Logstash 用来接收, 发送, 过滤, 分隔日志.
- Kibana 用来搜索, 展示, 分析日志的UI



## swarm集群
1. create dockerd:2376
```
docker-machine create -d generic --engine-registry-mirror=https://fl7aylpq.mirror.aliyuncs.com --generic-ip-address=139.129.234.31 --generic-ssh-user=root --generic-ssh-key=$HOME/.ssh/id_rsa --generic-ssh-port 22 ubuntu
docker-machine create -d generic --engine-registry-mirror=https://amoq5ee6.mirror.aliyuncs.com --generic-ip-address=139.129.108.163  --generic-ssh-user=root --generic-ssh-key=$HOME/.ssh/id_rsa --generic-ssh-port 22 aliyun
  > vi /etc/systemd/system/docker.service $ENGINE_REGISTRY_MIRROR
  > ExecStart=/usr/bin/docker daemon -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --storage-driver devicemapper --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic --registry-mirror https://amoq5ee6.mirror.aliyuncs.com

docker run -d --name mariadb -p 3306:3306 -v /var/lib/mysql:/var/lib/mysql -v /var/run/mysqld:/var/run/mysqld mariadb:5.5
```
```
docker-machine create -d virtualbox swmaster # This will be the master
docker-machine create -d virtualbox swnode

> dockerd -D -g /var/lib/docker -H unix:// -H tcp://0.0.0.0:2376 --label provider=virtualbox --tlsverify --tlscacert=/var/lib/boot2docker/ca.pem --tlscert=/var/lib/boot2docker/server.pem --tlskey=/var/lib/boot2docker/server-key.pem -s aufs
> docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc --debug
```
2. active
  & docker-machine.exe env aliyun | Invoke-Expression
  `eval $(docker-machine env swmaster)`
3. swarm node:2377

  + 一台机器只能创建一个swarm 通过 `docker swarm init --advertise-addr vboxnet0`绑定监听网卡
  + 本机器失效后 `docker swarm leave --froce` 删除本节点
  + 通过 `docker node rm --force ubuntu` 删除无效节点
  + 所有manger节点失效后 集群失效
  - 即使有manager 节点,当leader 节点swarm leave 之后 集群失效
  * leader 通过 `docker node demote self` 可以将控制转移
正确的处理方式:
1. manager->leader: `docker node demote leader`
2. manager->leader: `docker node rm --force leader`
3. leader->work:  `docker leave`

推荐做法:
  1. 保证manager的数量>3
  2. 确保 `docker swarm join-token manager` 在leader上执行
```
docker $(docker-machine config swmaster) swarm init --advertise-addr $(docker-machine ip swmaster)

docker swarm join-token manager

docker $(docker-machine config swnode) swarm join --token SWMTKN-1-26tk5t6vg1h9z4vq3z7e17z2wcvor2kt5ws6433qoqli0xh0os-ccy5d06jj4w3mj6s4twe4vs9m $(docker-machine ip swmaster)

docker node rm swnode --force #删除swarm work
```
4. swarm service
docker run 替换成 docker service create
# 滚动更新我们`worker`, 每次更新2个副本容器, 延迟`5s`
docker service update worker --update-parallelism 2 --update-delay 5s --image localhost:5000/dockercoins_worker:v0.01
docker service update worker --image localhost:5000/dockercoins_worker:v0.1 #回滚
```
docker service create --replicas 5 --name helloworld alpine ping google.com
docker service create alpine ping 8.8.8.8
docker service list
docker logs d6155498b874
docker service ps d6155498b874
watch docker service list
docker service ls -q | xargs docker service rm #删除服务
```
### ELK日志平台
- ElasticSearch 用来存储和索引日志.
- Logstash 用来接收, 发送, 过滤, 分隔日志.
- Kibana 用来搜索, 展示, 分析日志的UI
