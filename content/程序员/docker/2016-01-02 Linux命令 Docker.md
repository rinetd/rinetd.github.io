---
title: Linux命令 Docker
date: 2016-03-05T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [Docker]
---
![](https://yeasy.gitbooks.io/docker_practice/content/docker_primer.png)
[docker 操作命令详解](http://www.simapple.com/docker-commandline)
[Docker —— 从入门到实践](https://yeasy.gitbooks.io/docker_practice/content/)
[Docker 知识库](http://lib.csdn.net/base/4)
[Docker 中文指南](http://www.widuu.com/chinese_docker/)
[Docker中文网站：](http://www.docker.org.cn)
[一小时Docker教程](https://blog.csphere.cn/archives/22)
[Docker学习笔记之一，搭建一个JAVA Tomcat运行环境](http://www.blogjava.net/yongboy/archive/2013/12/12/407498.html)
[](http://yuedu.baidu.com/ebook/d817967416fc700abb68fca1?fr=aladdin&key=docker&f=read###)
[Docker入门教程（一）介绍](http://dockone.io/article/101)
[Docker入门教程（二）命令](http://dockone.io/article/102)
[docker专题(2)：docker常用管理命令（上）](https://segmentfault.com/a/1190000000751601)
[常用docker命令，及一些坑](http://blog.csdn.net/wsscy2004/article/details/25878363)
[可执行镜像——开发环境的Docker化之路](http://www.lxway.com/4091096922.htm)
[docker ps --filter](https://docs.docker.com/engine/reference/commandline/ps/)
## docker日志清理
```logs=$(find /var/lib/docker/containers/ -name *-json.log)  

for log in $logs  
        do  
                echo "clean logs : $log"  
                cat /dev/null > $log  
        done  
  ```

# 修复docker0网桥
方法1： ip
`service docker stop`           //关闭docker服务  
`ip link set dev docker0 down`  //关闭docker0网桥   
`ip link del dev docker0`       //删除docker0网桥
方法2：brctl
`yum install bridge-utils`
`ifconfig docker0 down`
`brctl delbr docker0`

########################################################
1. 如何从通过docker container ID 获取Container name
2. docker强制批量删除none的image镜像
  docker images | awk '/^<none>/ { print $3 }'

  docker ps -a | grep "Exited" | awk '{print $1 }'|xargs docker stop
  docker ps -a | grep "Exited" | awk '{print $1 }'|xargs docker rm
  docker images|grep none|awk '{print $3 }'|xargs docker rmi


  docker ps -a -q --filter=name=zookeeper-node-* | xargs -n 1 -I {} docker rm -f --volumes {}

# dockerd
1. 修改镜像和容器的存放路径：
   -g, --graph=/var/lib/docker

2. dockerd配置文件
### default
/usr/bin/dockerd -H fd://
docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc
### docker-machine
dockerd -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --storage-driver aufs --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic --registry-mirror https://fl7aylpq.mirror.aliyuncs.com
docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc
# 免 sudo 使用 docker
5.1 把普通用户加入 docker 用户组
    如果还没有 docker group 就添加一个：
          $ sudo groupadd docker
    将用户加入该 group 内。然后退出并重新登录就生效啦。
          $ sudo gpasswd -a ${USER} docker
    重启 docker 服务
          $ sudo service docker restart
5.2 原因
    因为 /var/run/docker.sock 所属 docker 组具有 setuid 权限
        $ sudo ls -l /var/run/docker.sock
        srw-rw---- 1 root docker 0 May  1 21:35 /var/run/docker.sock

# DOCKER 给运行中的容器添加映射端口

1、获得容器IP    将container_name 换成实际环境中的容器名

`docker inspect mariadb | grep IPAddress`
`sudo iptables -t nat --list-rules`
`sudo iptables -t filter --list-rules`
`docker inspect -f '{{.NetworkSettings.IPAddress}}' mariadb`
1. DNAT主机30006 => 指定容器3306端口实现转发
  `iptables -t nat -A DOCKER ! -i docker0 -p tcp --dport 30006 -j DNAT --to-destination 192.168.0.2:3306`

2. filter 容器端口 3306
  `iptables -A DOCKER -d 192.168.0.2/32 ! -i docker0 -o docker0 -p tcp --dport 3306 -j ACCEPT`
  `iptables -t nat -A POSTROUTING -s 192.168.0.4/32 -d 192.168.0.4/32 -p tcp -m tcp --dport 3306 -j MASQUERADE`


方法2
1.提交一个运行中的容器为镜像
docker commit containerid foo/live
2.运行镜像并添加端口
docker run -d -p 8000:80  foo/live /bin/bash

# 配置代理


    Obtain a crt from the https://dseasb33srnrn.cloudfront.net with openssl
    Copy the crt to /etc/share/ca-certificates (Ubuntu)
    Restart docker

    I was able to work around this issue by trusting the certificates from cdn-registry-1.docker.io and registry-1.docker.io:

`cd /usr/local/share/ca-certificates`
openssl s_client -connect registry-1.docker.io:443 -showcerts
openssl s_client -connect cdn-registry-1.docker.io:443 -showcerts

openssl s_client -showcerts -verify 32 -CApath . -connect index.docker.io:443
Copied and pasted` ---BEGIN--- && ---END---` sections for the certificates in to a `registry-1.crt `file.

`sudo update-ca-certificates`
 `sudo systemctl restart docker`

-----

但是我明明已经为ubuntu设置了http_proxy了。

查了试了半天，才知道还需要给docker单独设代理，一下是步骤。

First, create a systemd drop-in directory for the docker service:

`mkdir /etc/systemd/system/docker.service.d`
`vi  /lib/systemd/system/docker.socket` /etc/systemd/system/sockets.target.wants/docker.socket ->
Now create a file called `/etc/systemd/system/docker.service.d/http-proxy.conf` that adds the HTTP_PROXY environment variable:

`/etc/systemd/system/docker.service.d/http-proxy.conf`
```
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8087/" "HTTPS_PROXY=http://127.0.0.1:8087/"
Environment="NO_PROXY=localhost,127.0.0.0/8,daocloud.io"
```

$ `sudo systemctl daemon-reload`
$ `sudo systemctl show docker --property Environment`
$ `sudo systemctl restart docker`
################################
[install](https://docs.docker.com/engine/installation/)
[Docker registry仓库](https://hub.docker.com/explore/)
Dockerfile中的EXPOSE、docker run --expose、docker run -p之间的区别
Dockerfile的EXPOSE相当于docker run --expose，提供container之间的端口访问。docker run -p允许container外部主机访问container的端口
---
根据格式删除所有镜像
docker rm $(docker ps -qf status=exited)
# 删除所有不活动的容器
docker rm $(docker ps -aq)
# 删除所有未打标签的镜像.
alias dockercleani='docker rmi $(docker images -q -f dangling=true)'stop all containers
docker rmi $(docker images -q | awk '/^<none>/ { print $3 }')
$ sudo docker stop $(docker ps -q)
# ip address of the first docker instance
$ sudo docker inspect $(docker ps -q) | grep "IPAddress"
# test rtmp on host
$ rtmpdump -r "rtmp://172.17.0.140/vod/sheephead_mountain.mp4

记录日志到stdout

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
# docker 网路链接
```
docker network ls
docker network inspect bridge
docker network inspect host
docker network inspect none
ip addr
```

# docker Volume
Volume只有在下列情况下才能被删除：
    该容器是用docker rm -v 命令来删除的（-v是必不可少的）。
    docker run中使用了--rm参数

# docker aliyun镜像
http://mirrors.aliyun.com/docker-toolbox/
# docker-engine

https://download.docker.com/win/beta/InstallDocker.msi
## windows-installer [Install Boot2Docker cli, msys-git and VirtualBox ]
curl -Lkx 127.0.0.1:8087 -O https://github.com/boot2docker/windows-installer/releases/download/v1.8.0/docker-install.exe

## linux
[阿里云 Docker镜像仓库](https://cr.console.aliyun.com)
hub.daocloud.io
[Install Docker](https://www.docker.com/products/overview)
1. 自动安装docker
`curl -sSL https://get.docker.com/ | sh`
 #wget -N https://get.docker.com/ | sh
1. 官网安装
curl -fsSL -kx 127.0.0.1:8087 https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

curl -sSL https://get.daocloud.io/docker/ | sh
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
[阿里内网](curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/intranet | sh -)

################### 配置docker mirrors 加速器 ###################################
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://1d909c65.m.daocloud.io
若使用阿里云服务器，将源的域名从`mirrors.aliyun.com`改为`mirrors.aliyuncs.com`,不占用公网流量。


Docker Hub 加速器 ：` curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://1d909c65.m.daocloud.io `
                    curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s https://9gz5jk6x.mirror.aliyuncs.com


# docker配置
`groupmod -g 99 docker && groupadd -r -g 999 mysql && useradd -r -u 999 -g mysql -c mysql -d /var/lib/mysql -s /sbin/nologin mysql`
# Cannot connect to the Docker daemon. Is the docker daemon running on this host?
sudo groupadd docker
sudo gpasswd -a ${USER} docker   #-d 将用户从组中删除
 #`sudo usermod -aG docker ${USERNAME}`
sudo systemctl restart docker
sudo chmod a+rw /var/run/docker.sock

 2. 手动安装 docker-engine
 sudo apt-get update
 sudo apt-get install apt-transport-https ca-certificates
 `sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D`
 `sudo vim /etc/apt/sources.list.d/docker.list`
   deb https://apt.dockerproject.org/repo ubuntu-xenial main
   #deb-src https://apt.dockerproject.org/repo ubuntu-xenial main
 `sudo apt-get update`
 sudo apt-get purge lxc-docker
 apt-cache policy docker-engine
 sudo apt-get install linux-image-extra-$(uname -r)
 `sudo apt-get install docker-engine`
 sudo service docker start
 sudo docker run hello-world
##添加自启动
sudo systemctl enable docker
#升级docker
sudo apt-get upgrade docker-engine
#清理docker
sudo apt-get purge docker-engine
sudo apt-get autoremove --purge docker-engine
sudo rm -rf /var/lib/docker

## Install boot2docker
`curl  -Lkx 127.0.0.1:8087 -O https://github.com/boot2docker/boot2docker/releases/download/v1.12.1/boot2docker.iso`


# 在docker中管理主机进程
`docker run --rm -it --privileged --pid=host busybox sh`

>在docker中，可以透過"--pid"參數來將host的pid namespace帶入到container中，這樣就可以在docker instance中直接看到host的process了。
docker run -it --pid=host debian bash
執行起來後，在instance內部透過ps可以看到host系統的process，並且可以進行操作...





## network

创建容器接入指定网络

#docker run -itd --name=testcontainer --net=overlayname  nginx

将容器从指定网络中退出
#docker network disconnect overlayname testcontainer
重新连入指定网络
#docker network connect overlayname testcontainer

################################################################################
sudo docker login
docker login daocloud.io
sudo docker login hub.ghostcloud.cn
#sudo docker pull node
#sudo docker pull ubuntu:latest
sudo docker pull centos:latest

sudo docker images
#docker run -it -p 80:4000 -v /media/ubuntu/software/rinetd:/blog emitting/hexo /bin/bash
sudo docker run --rm -ti -p:2200:22 -v /tmp:/web ubuntu /bin/bash
--rm：告诉Docker一旦运行的进程退出就删除容器。这在进行测试时非常有用，可免除杂乱
-ti：告诉Docker分配一个伪终端并进入交互模式。这将进入到容器内，对于快速原型开发或尝试很有用，但不要在生产容器中打开这些标志
-H: 参数指定了Docker后台地址（使用TCP与后台通讯）；DOCKER_OPTS="-H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock
-p: 本机地址:虚拟主机端口22
-v: 本机目录:虚拟主机目录
-w: 表示将-v映射的/webapp目录设置为work directory，将覆盖Dockfiie中的设置：/Data。
-P: 通知 Docker 将容器内部使用的网络端口映射到我们使用的主机上
-P –publish-all=true|false 默认false
    如果容器里没有运行sshd，可以登录宿主机后执行
    `docker exec -it CONTAINER_NAME_OR_ID /bin/sh`
    可以在容器里运行个sshd，通过SSH客户端登录。 但由于是用的host网络，所以容器里的sshd进程无法使用默认端口，需要修改其配置文件把端口改成非22端口
    -p 127.0.0.1:80:5000/udp
    -p 127.0.0.1::5000 bind port 5000 of the container to a dynamic port but only on the localhost
    -p 8000-9000:5000  bind port 5000 in the container to a randomly available port between 8000 and 9000 on the host.
--link <name or id>:alias
################################################################################
# docker ps
  -f, --filter=[]       Filter output based on these conditions:
                        - exited=<int> an exit code of <int>
                        - label=<key> or label=<key>=<value>
                        - status=(created|restarting|running|paused|exited)
                        - name=<string> a container's name
                        - id=<ID> a container's ID
                        - before=(<container-name>|<container-id>)
                        - since=(<container-name>|<container-id>)
                        - ancestor=(<image-name>[:tag]|<image-id>|<image@digest>) - containers created from an image or a descendant.
                        - volume=(<volume-name>|<mount-point>)

     --format           Pretty-print containers using a Go template
                        .ID 	Container ID
                        .Image 	Image ID
                        .Command 	Quoted command
                        .CreatedAt 	Time when the container was created.
                        .RunningFor 	Elapsed time since the container was started.
                        .Ports 	Exposed ports.
                        .Status 	Container status.
                        .Size 	Container disk size.
                        .Names 	Container names.
                        .Labels 	All labels assigned to the container.
                        .Label 	Value of a specific label for this container. For example {{.Label "com.docker.swarm.cpu"}}
                        .Mounts 	Names of the volumes mounted in this container.
```
$ docker ps --format "{{.ID}}: {{.Command}}"
a87ecb4f327c: /bin/sh -c #(nop) MA
docker ps --format "table {{.ID}}\t{{.Labels}}"
CONTAINER ID        LABELS
a87ecb4f327c        com.docker.swarm.node=ubuntu,com.docker.swarm.storage=ssd
```
##############Dockerfile#########################
docker run
-a, --attach 挂载标准数据流，可指定标准输入输出和错误，不指定会默认挂载所有数据流；
-d, --detach 后台运行容器，并打印容器ID；
-i, --interactive 以交互模式运行容器，通常与 -t 同时使用；
-t, --tty 为容器分配一个虚拟终端，通常与 -i 同时使用；
-e, --env 设置容器的环境变量；
--env-file 从文件读取容器的环境变量；
--read-only 以只读模式挂载容器的根目录；
--restart 退出容器时重启之；
--rm 退出容器时销毁之；
--name= 给容器起个名字；
--cidfile 将容器id写入文件；
-u, --user 容器用户，格式如 [:]；
-h, --hostname 设置容器的主机名『hostname』；
--ulimit 设置容器ulimit值；
-w, --workdir 设置容器的工作目录；
-l, --label 设置容器的元数据；
--label-file 从文件中读取容器的元数据，行分隔文件；
--group-add 为容器增加额外的用户组；
--cpu-shares CPU周期频率相对权重，默认是1024，可根据需要在[2-1024]间浮动；
--cpuset-cpus 指定容器在CPU运行，支持『1-3』或者『1,4』形式；
--cpuset-mems 指定容器在指定MEM运行，支持『1-2』或者『1,3』形式；
-m, --memory 设置容器物理内存大小；
--memory-reservation= 设置内存保留限制；
--memory-swap 总内存『memory+swap』，设为-1禁用swap内存；
--memory-swappiness 设置容器内存可交换比例，可取[1-100]值；
--kernel-memory 设置内核空间，形如 [] 单位是『k,b,m,g』；
-v, --volume 挂载一块空间；
--volume-driver 可选的空间驱动；
--volumes-from 挂载指定某个（些）容器的空间；
--blkio-weight IO相对权重，默认是500，可根据需要在[10-1000]间浮动；
--device 允许在容器内运行的宿主设备
--network 设置容器网络；
--expose 暴露一个或多个端口；
--link 通过网络连接其他容器；
--add-host 在 /etc/hosts 中增加一条『host-to-ip』映射；
--mac-address 设置容器mac地址，形如『92:d0:c6:0a:29:33』；
--dns 8.8.8.8 自定义容器的DNS服务器，默认和宿主一致；
--dns-opt 自定义容器的DNS选项，默认和宿主一致；
--dns-search example.com 自定义容器的DNS搜索域名，默认和宿主一致；
-P, --publish-all 暴露容器的所有开放端口到随机端口；
-p, --publish 暴露容器的一个或多个端口到宿主端口；
--entrypoint 改写镜像默认的『ENTRYPOINT』值；
--disable-content-trust 跳过镜像签名
--cap-add 增加Linux能力，参考Linux能力列表；
--cap-drop 减少Linux能力，参考Linux能力列表；
--cgroup-parent 自定义容器的父亲cgroup；
--log-driver 自定义容器的log系统；
--log-opt 自定义容器的log选项；
--lxc-conf 增加自定义lxc选项；
--ipc 设置IPC命名空间；
--pid 重设容器进程命名空间；
--uts 设置uts命名空间；
--privileged 给予容器更多的特权；
--security-opt 更多容器安全选项；
--stop-signal 停止容器的信号，默认为『SIGTERM』；
--sig-proxy 将收到的信号转给当前进程；
--oom-kill-disable 禁用OOM Killer；
################################################################################
## docker 搭建Android开发环境
docker pull ubuntu:10.04
docker run -it -p 8080:80 -v /media/ubuntu/sdb2/Android:/mnt -w /mnt ubuntu:10.04 /bin/bash

docker ps -a
docker start 8c055f32bd33
docker attach 8c055f32bd33
sudo vi /etc/apt/source.list
sed -i 's/httpredir.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

sudo sed -i 's/archive.ubuntu.com/mirrors.sohu.com/g' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
sudo sed -i 's/archive.ubuntu.com/mirrors.aliyuncs.com/g' /etc/apt/sources.list #内网使用
```
#网易
deb http://mirrors.163.com/ubuntu/ lucid main universe restricted multiverse
deb-src http://mirrors.163.com/ubuntu/ lucid main universe restricted multiverse
deb http://mirrors.163.com/ubuntu/ lucid-security universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ lucid-security universe main multiverse restricted
deb http://mirrors.163.com/ubuntu/ lucid-updates universe main multiverse restricted
deb http://mirrors.163.com/ubuntu/ lucid-proposed universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ lucid-proposed universe main multiverse restricted
deb http://mirrors.163.com/ubuntu/ lucid-backports universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ lucid-backports universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ lucid-updates universe main multiverse restricted
```
sudo apt-get update

sudo apt-get install gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
  x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
  libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
  libxml2-utils xsltproc

`sudo apt-get install software-properties-common`
`sudo apt-get install python-software-properties`
  sudo add-apt-repository ppa:webupd8team/java    #添加PPA
  sudo apt-get update
  sudo apt-get install oracle-java6-installer     #java-6u45

sudo docker commit -m="Android source Complie" -a="rinetd" ab044db61af2 rinetd/ubuntu:v1
docker tag 5db5f8471261 rinetd/ubuntu:devel
docker push rinetd/ubuntu

###
Docker命令参考
使用方法: docker [OPTIONS] COMMAND [arg...]

一个自给自足的运行时linux容器。

选项:
  --api-enable-cors=false              在远程的API中启用CORS 头。
  -b, --bridge=""                      附加容器到一个已经存在的网桥上。如果将该选项的值设置为 'none'，则表示不使用用网桥。
  --bip=""                             设置网桥的IP地址，使用CIIDR标记方式的地址，不兼容 -b选项。
  -D, --debug=false                    启用debug 模式。
  -d, --daemon=false                   启用daemon 模式。
  --dns=[]                             强制Docker使用特定的DNS 服务器。
  --dns-search=[]                      强制 Docker使用特定的DNS 搜索域。
  -e, --exec-driver="native"           强制Docker运行时使用特定的exec驱动。
  --fixed-cidr=""                      IPv4子网设置掩码(ex: 10.20.0.0/16)，这个子网必须嵌套于网桥子网内(由-b 或者-bip定义)。
  -G, --group="docker"                 在使用-H运行为守护进程的情况下，设定分配给运行unix套接字的组，如果设置为'' (空字符)，那么将不会设置组。
  -g, --graph="/var/lib/docker"        设定Docker运行时作为根目录的目录路径。
  -H, --host=[]                        设置用于在守护进程模式下或者是在客户端模式下连接的套接字，可以是tcp://host:port, unix:///path/to/socket, fd://* or fd://socketfd中的一个或者多。
  --icc=true                           启用容器间通信。
  --insecure-registry=[]               对于特定注册启用非安全通信(对于HTTPS没有证书校验，启用HTTP启用fallback) (例如, localhost:5000 or 10.20.0.0/16)。
  --ip=0.0.0.0                         在容器绑定端口时使用的默认IP地址。
  --ip-forward=true                    启用net.ipv4.ip_forward，也就是开启路由转发功能。
  --ip-masq=true                       对于网桥的IP段启用ip伪装。
  --iptables=true                      启用Docker增加的iptables规则。
  --mtu=0                              设置容器网络的MTU。如果没有提供设置的值：默认将它的值设置为路由器的MTU，如果默认的路由器无效那么就设置为1500。
  -p, --pidfile="/var/run/docker.pid"  设置守护进程PID文件的路径。
  --registry-mirror=[]                 指定优先使用的Docker registry镜像。
  -s, --storage-driver=""              强制Docker运行时使用特定的存储驱动器。
  --selinux-enabled=false              启用对selinux机制的支持。SELinux目前不支持BTRFS存储驱动器。
  --storage-opt=[]                     设置存储驱动器选项。
  --tls=false                          使用TLS，暗示使用tls-verify标志。
  --tlscacert="/root/.docker/ca.pem"   设置ca证书的路径。远程访问仅信任使用由CA签名的证书。
  --tlscert="/root/.docker/cert.pem"   设置TLS 证书的路径。
  --tlskey="/root/.docker/key.pem"     设置TLS key 文件的路径。
  --tlsverify=false                    使用TLS校验远程登录(daemon:校验客户端, client: 校验守护进程)
  -v, --version=false                  显示版本信息并退出。

命令:
attach    附加到一个运行的容器上。
build     从Dockerfile构建镜像。
commit    从改变后的容器创建一个新的镜像
cp        从容器文件系统拷贝文件/目录到宿主机路径。
create    创建一个新的容器。
diff      检查容器文件系统的改变。
events    从Get real time events from the server
exec      在已经存在的容器上运行一个命令。
export    Stream the contents of a container as a tar archive
history   显示镜像的历史。
images    列举镜像。
import    从一个tar包的内容创建一个新的文件系统镜像。
info      显示系统层面的信息。
inspect   查看容器的底层信息。
kill      杀掉一个正在运行中的容器。
load      从tar文件中载入一个镜像。
login     注册或者登录到Docker registry 服务器。
logout    从Docker registry 服务器退出。
logs      获取容器的日志信息。
port      Lookup the public-facing port that is NAT-ed to PRIVATE_PORT
pause     停止容器内所有的进程。
ps        列出容器。
pull      从Docker registry 服务器拉回一个镜像或者一个仓库。
push      将一个镜像或者一个仓库推向Docker registry 服务器。
restart   重新启动一个运行中的容器。
rm        移除一个或者多个容器。
rmi       移除一个或者多个镜像。
run       在新的容器中运行一个命令。
save      将镜像保存为一个tar文档。
search    在Docker Hub上搜索一个镜像。
start     启动一个停止的容器。
stop      S停止一个运行中的容器。
tag       Tag an image into a repository
top       查看容器中运行的进程。
unpause   取消暂停的容器。
version   显示Docker 的版本信息。
wait      Block until a container stops, then print its exit code

docker attach

使用方法: docker attach [OPTIONS] CONTAINER

附加到一个正在运行的容器上。

  --no-stdin=false    不附加STDIN。
  --sig-proxy=true    代理所有接收到的信号到进程(即使是非TTY模式)。SIGCHLD, SIGKILL, 或者 SIGSTOP 不会被代理。

docker build     

使用方法: docker build [OPTIONS] PATH | URL | -

在指定的PATH源代码下构建新的镜像。

  --force-rm=false     总是立即移除容器，即使是在成功创建之后。
  --no-cache=false     在构建镜像时不使用缓存。
  -q, --quiet=false    抑制由容器生成详细输出。
  --rm=true            成功创建容器之后就立即删除。
  -t, --tag=""         指定仓库名字(和一个可选的标签)，在构建成功的镜像结果中应用。


docker commit

使用方法: docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

从有改变的容器上创建一个新的镜像。

  -a, --author=""     作者 (例如 "John Hannibal Smith <hannibal@a-team.com>"
  -m, --message=""    提交信息。
  -p, --pause=true    在提交的过程中暂停容器。



docker cp   

使用方法: docker cp CONTAINERATH HOSTPATH

从PATH 拷贝文件/目录到 HOSTPATH。

docker create   
使用方法: docker create [OPTIONS] IMAGE [COMMAND] [ARG...]

创建一个新容器。

  -a, --attach=[]            附加到STDIN, STDOUT 或者STDERR。
  --add-host=[]              自定义一个主机到IP的映射(host:ip)。
  -c, --cpu-shares=0         设定CPU共享(相对权重)。
  --cap-add=[]               添加Linux capabilities。
  --cap-drop=[]              移除 Linux capabilities。
  --cidfile=""               写容器ID的文件。
  --cpuset=""                设置使用CPU的数量(0-3, 0,1)。
  --device=[]                添加一个主机设备到容器(例如
--device=/dev/sdc:/dev/xvdc)
  --dns=[]                   设置自定义DNS 服务器。
  --dns-search=[]            设置自定义DNS 搜索域。
  -e, --env=[]               设置环境变量。
  --entrypoint=""            覆盖掉镜像中默认的ENTRYPOINT。
  --env-file=[]              读以逗号分隔的环境变量文件(文件中的行以逗号分隔，每一行都是环境变量)。
  --expose=[]                将一个没有发布的端口暴露给宿主机。
  -h, --hostname=""          容器主机名字。
  -i, --interactive=false    保持 STDIN 打开，即使没有被附加。
  --link=[]                  以name:alias格式添加连接到其它容器上。
  --lxc-conf=[]              (lxc exec-driver only) 添加自定义lxc 选项
--lxc-conf="lxc.cgroup.cpuset.cpus = 0,1"
  -m, --memory=""            内存限制 (格式: <number><optional unit>,
unit = b, k, m or g)
  --name=""                  指定容器的名字。
  --net="bridge"             为容器设置网络模式，
                               'bridge': 在docker bridge桥上创建一个新的网络栈。
                                 'none': 该容器没有网络。
                  'container:<name|id>': 重新使用其它容器的网络栈。
                                 'host': 在该容器内使用host网络堆栈。注意：host模式对宿主机上的本地文件系统给定了容器全部的访问权限，包括D-bus，因此容器被认为是不安全的。

  -P, --publish-all=false    发布所有的暴露端口到宿主机接口上。
  -p, --publish=[]           发布容器的一个端口到宿主机接口上。
                             格式：
ip:hostPort:containerPort
ip::containerPort
hostPort:containerPort
containerPort
                               (使用 'docker port'查看实际的映射)
  --privileged=false         给这个容器扩展权限。
  --restart=""               当容器退出时重启策略将会被应用，选项值有：
(no, on-failure[:max-retry], always)
  --security-opt=[]          安全选项。
  -t, --tty=false            分配伪终端。
  -u, --user=""              用户名或者UID。
  -v, --volume=[]             绑定挂载卷(例如，从宿主机挂接：-v /host:/container，从Docker挂接：-v /container)
  --volumes-from=[]          从指定的容器挂载卷。
  -w, --workdir=""           指定容器内的工作目录。

docker diff


使用方法: docker diff CONTAINER

查看容器内文件系统的变化。


docker events     

使用方法: docker events [OPTIONS]

从服务器上获得实时事件。
  --since=""         从指定的时间戳后显示所有事件。
  --until=""         流水时间显示到指定的时间为止。

docker exec   

使用方法: docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

在已经存在的容器内运行一个命令。

  -d, --detach=false         分离模式: 在后台运行
  -i, --interactive=false    即使没有附加也保持STDIN 打开
  -t, --tty=false            分配一个伪终端

docker export   

使用方法: docker export CONTAINER

将文件系统作为一个tar归档文件导出到STDOUT。

docker info

使用方法: docker info

显示系统级别的信息。

docker history      

使用方法: docker history [OPTIONS] IMAGE

显示镜像的历史。

  --no-trunc=false     不要截断输出。
  -q, --quiet=false    只显示数字ID。

docker images

使用方法: docker images [OPTIONS] [NAME]

列出镜像。

  -a, --all=false      显示所有镜像(默认情况下过滤掉中间层镜像)。
  -f, --filter=[]      提供过滤值 (例如. 'dangling=true')
  --no-trunc=false     不要截断输出。
  -q, --quiet=false    只显示数字ID。

docker import

使用方法: docker import URL|- [REPOSITORY[:TAG]]

创建一个空的文件系统镜像，并且将压缩包(.tar, .tar.gz, .tgz, .bzip, .tar.xz, .txz)内容输入到其中。

docker inspect

使用方法: docker inspect [OPTIONS] CONTAINER|IMAGE [CONTAINER|IMAGE...]

查看容器或者镜像的低级信息。

  -f, --format=""    使用给定的模板格式化输出。

docker kill

使用方法: docker kill [OPTIONS] CONTAINER [CONTAINER...]

使用SIGKILL杀掉指定的容器。

  -s, --signal="KILL"    向容器发送的信号。

docker load


使用方法: docker load [OPTIONS]

从STDIN上载入tar包作为镜像。

  -i, --input=""     从tar文件，而不是STDIN读取。

docker login


使用方法: docker login [OPTIONS] [SERVER]

注册或者登录到一个Docker服务器，如果没有指定服务器，那么https://index.docker.io/v1/将会作为默认值。

  -e, --email=""       邮件
  -p, --password=""    密码
  -u, --username=""    用户名

docker logout

使用方法: docker logout [SERVER]


从一个Docker registry退出，如果没有指定服务器，那么https://index.docker.io/v1/将会作为默认值。


docker logs  

使用方法: docker logs [OPTIONS] CONTAINER

从容器获取日志。

  -f, --follow=false        跟踪日志输出。
  -t, --timestamps=false    显示时间戳。
  --tail="all"              输出日志尾部特定行(默认是所有)。
docker port

使用方法: docker port CONTAINER [PRIVATE_PORT[/PROTO]]

列出指定的容器的端口映射，或者查找将PRIVATE_PORT NAT到面向公众的端口。

docker pause     
使用方法: docker pause CONTAINER

暂停容器内所有的进程。

docker ps   

使用方法: docker ps [OPTIONS]

列出容器。

  -a, --all=false       显示所有的容器。默认情况下仅显示正在运行的容器。
  --before=""           仅显示在ID或者名字之前的容器，包括没有运行的容器。
  -f, --filter=[]       提供过滤值. 有效的过滤器:
                          exited=<int> - 容器退出的代码 <int>
                          status=(restarting|running|paused|exited)
  -l, --latest=false    仅显示最后一个创建的容器，包括没有运行的。
  -n=-1                 显示n个最后创建的容器，包括没有运行的。
  --no-trunc=false      不要截断输出。
  -q, --quiet=false     仅显示数值ID。
  -s, --size=false      显示大小。
  --since=""            仅显示从Id 或者 Name以来的容器，包括没有运行的。

docker pull      

使用方法: docker pull [OPTIONS] NAME[:TAG]

从registry上拉回一个镜像或者一个容器。

  -a, --all-tags=false    在指定的仓库下载所有标记的镜像。

docker push     

使用方法: docker push NAME[:TAG]

将一个镜像或者仓库推送到指定的仓库。

docker restart   


使用方法: docker restart [OPTIONS] CONTAINER [CONTAINER...]

重新启动一个运行中的容器。

  -t, --time=10      在杀掉指定容器之前停动的时间，一旦杀掉容器，那么就会重新启动。默认时间为10秒。


docker rm            

使用方法: docker rm [OPTIONS] CONTAINER [CONTAINER...]

删除一个或者多个容器。

  -f, --force=false      强制移除一个正在运行的容器(使用 SIGKILL)
  -l, --link=false       移除指定的连接，而不是潜在的容器。
  -v, --volumes=false    移除与容器相关的卷。

docker rmi      

使用方法: docker rmi [OPTIONS] IMAGE [IMAGE...]

移除一个或者多个镜像。

  -f, --force=false    强制移除一个镜像。
  --no-prune=false     不要删除未标记的父镜像。

docker run   


使用方法: docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

在新的容器中运行一个命令。

  -a, --attach=[]            附加到STDIN, STDOUT 或者 STDERR。
  --add-host=[]              添加一个自定义的host-to-IP 映射(host:ip)。
  -c, --cpu-shares=0         CPU shares (相对权重)。
  --cap-add=[]               添加Linux capabilities。
  --cap-drop=[]              放弃 Linux capabilities。
  --cidfile=""               将容器 ID写入文件。
  --cpuset=""                允许使用的CPU数量(0-3, 0,1)
  -d, --detach=false         分离模式：在后台运行容器，并且显示出新容器的ID。
  --device=[]                向容器添加一个宿主机设备。
(例如， --device=/dev/sdc:/dev/xvdc)
  --dns=[]                   设置自定义的DNS 服务器。
  --dns-search=[]            设置自定义DNS 搜索域。
  -e, --env=[]               设置环境变量。
  --entrypoint=""            覆盖掉镜像中默认的ENTRYPOINT。
  --env-file=[]              读以逗号分隔的环境变量文件(文件中的行以逗号分隔，每一行都是环境变量)。
  --expose=[]                将一个没有发布的端口暴露给宿主机。
  -h, --hostname=""          容器主机名字。
  -i, --interactive=false    保持 STDIN 打开，即使没有被附加。
  --link=[]                  以name:alias格式添加连接到其它容器上。
  --lxc-conf=[]              (lxc exec-driver only) 添加自定义lxc 选项
--lxc-conf="lxc.cgroup.cpuset.cpus = 0,1"
  -m, --memory=""            内存限制 (格式: <number><optional unit>,
unit = b, k, m or g)
  --name=""                  指定容器的名字。
  --net="bridge"             为容器设置网络模式，
                               'bridge': 在docker bridge桥上创建一个新的网络栈。
                                 'none': 该容器没有网络。
                  'container:<name|id>': 重新使用其它容器的网络栈。
                                 'host': 在该容器内使用host网络堆栈。注意：host模式对宿主机上的本地文件系统给定了容器全部的访问权限，包括D-bus，因此容器被认为是不安全的。

  -P, --publish-all=false    发布所有的暴露端口到宿主机接口上。
  -p, --publish=[]           发布容器的一个端口到宿主机接口上。
                             格式：
ip:hostPort:containerPort
ip::containerPort
hostPort:containerPort
containerPort
                               (使用 'docker port'查看实际的映射)
  --privileged=false         给这个容器扩展权限。
  --restart=""               当容器退出时重启策略将会被应用，选项值有：
(no, on-failure[:max-retry], always)
  --security-opt=[]          安全选项。
  -t, --tty=false            分配伪终端。
  -u, --user=""              用户名或者UID。
  -v, --volume=[]             绑定挂载卷(例如，从宿主机挂接：-v /host:/container，从Docker挂接：-v /container)
  --volumes-from=[]          从指定的容器挂载卷。
  -w, --workdir=""           指定容器内的工作目录。


docker save         

使用方法: docker save [OPTIONS] IMAGE [IMAGE...]

将镜像保存到一个归档文件(默认为STDOUT)

  -o, --output=""    输出到一个文件而不是STDOUT。

docker search     

使用方法: docker search [OPTIONS] TERM

从Docker Hub 上搜索镜像。

  --automated=false    仅显示自动构建。
  --no-trunc=false     不要截断输出。
  -s, --stars=0        仅显示至少x 星级的镜像。



docker start           

使用方法: docker start [OPTIONS] CONTAINER [CONTAINER...]

重新启动一个停止的容器。

  -a, --attach=false         附加容器的STDOUT 和 STDERR，并且所有的信号到进程。
  -i, --interactive=false    附加容器的STDIN。

docker stop      

使用方法: docker stop [OPTIONS] CONTAINER [CONTAINER...]

通过发送SIGTERM 信号，在一个优雅的时间断后然后是SIGKILL停止运行的容器。

  -t, --time=10      在杀掉容器之前等待容器停止的时间数。

docker tag      

使用方法: docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]

标记一个进入仓库的镜像。

  -f, --force=false    强制。

docker top      

使用方法: docker top CONTAINER [ps OPTIONS]

显示容器中运行的进程。

docker unpause              
使用方法: docker unpause CONTAINER

取消暂停容器内的所有进程。

docker version           

使用方法: docker version

显示Docker的版本信息。

docker wait            

使用方法: docker wait CONTAINER [CONTAINER...]

Block until a container stops, then print its exit code.
阻塞运行直到容器停止，然后打印出它的退出代码。
