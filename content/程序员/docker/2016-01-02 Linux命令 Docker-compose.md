---
title: Linux命令 docker-compose
date: 2016-03-05T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [Docker,yaml]
---
https://github.com/docker/compose
https://github.com/docker/compose/releases
[Docker Compose文件详解 V2 ](http://blog.csdn.net/wanghailong041/article/details/52162275)
[官方参考文档 Compose file version 3 reference - Docker Documentation](https://docs.docker.com/compose/compose-file/)

[](https://yq.aliyun.com/articles/69444)


# Install docker-compose
sudo curl -L https://get.daocloud.io/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

```
curl -Lkx 127.0.0.1:8087 https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m`|sudo tee /usr/local/bin/docker-compose
sudo curl -Lkx 127.0.0.1:8087 https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

uname -s linux
uname -m x86_64
curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
curl -Lkx 127.0.0.1:8087 https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
curl -L https://github.com/docker/compose/releases/download/1.8.1/run.sh > /usr/local/bin/docker-compose


2. pip
apt-get install python-pip python-dev
sudo pip install --upgrade pip
pip install -U docker-compose
```

## 常用库
[docker-library](https://github.com/docker-library)
[Repositories](https://hub.docker.com/)

# dockerfiles
git remote add seapy https://github.com/seapy/dockerfiles
git subtree add -P Subtree/seapy seapy master
git clone --depth 1 https://github.com/vimagick/dockerfiles subclone/vimagick


# docker-compose常用命令

--verbose：输出详细信息
-f 制定一个非docker-compose.yml命名的yaml文件
-p 设置一个项目名称（默认是directory名）
docker-compose的动作包括：
build：构建服务
kill -s SIGINT：给服务发送特定的信号。
logs：输出日志
port：输出绑定的端口
ps：输出运行的容器
pull：pull服务的image
rm：删除停止的容器
run: 运行某个服务，例如docker-compose run web python manage.py shell
start：运行某个服务中存在的容器。
stop:停止某个服务中存在的容器。
up：create + run + attach容器到服务。
scale：设置服务运行的容器数量。例如：docker-compose scale web=2 worker=3

# Dockerfile
```
RUN groupadd -g 1000 user && \
    useradd -m -g user -u 1000 user
USER user
WORKDIR /app
```
# docker-compose.Yaml文件参考
```
在上面的yaml文件中，我们可以看到compose文件的基本结构。首先是定义一个服务名，下面是yaml服务中的一些选项条目：
image:镜像的ID
build:直接从pwd的Dockerfile来build，而非通过image选项来pull
links：连接到那些容器。每个占一行，格式为SERVICE[:ALIAS],例如 – db[:database]
external_links：连接到该compose.yaml文件之外的容器中，比如是提供共享或者通用服务的容器服务。格式同links
command：替换默认的command命令
ports: 导出端口。格式可以是：

ports:-"3000"-"8000:8000"-"127.0.0.1:8001:8001"

expose：导出端口，但不映射到宿主机的端口上。它仅对links的容器开放。格式直接指定端口号即可。
volumes：加载路径作为卷，可以指定只读模式：

volumes:-/var/lib/mysql
 - cache/:/tmp/cache
 -~/configs:/etc/configs/:ro

volumes_from：加载其他容器或者服务的所有卷

environment:- RACK_ENV=development
  - SESSION_SECRET

env_file：从一个文件中导入环境变量，文件的格式为RACK_ENV=development
extends:扩展另一个服务，可以覆盖其中的一些选项。一个sample如下：

common.yml
webapp:
  build:./webapp
  environment:- DEBUG=false- SEND_EMAILS=false
development.yml
web:extends:
    file: common.yml
    service: webapp
  ports:-"8000:8000"
  links:- db
  environment:- DEBUG=true
db:
  image: postgres

net：容器的网络模式，可以为”bridge”, “none”, “container:[name or id]”, “host”中的一个。
dns：可以设置一个或多个自定义的DNS地址。
dns_search:可以设置一个或多个DNS的扫描域。
其他的working_dir, entrypoint, user, hostname, domainname, mem_limit, privileged, restart, stdin_open, tty, cpu_shares，和docker run命令是一样的，这些命令都是单行的命令。例如：

cpu_shares:73
working_dir:/code
entrypoint: /code/entrypoint.sh
user: postgresql
hostname: foo
domainname: foo.com
mem_limit:1000000000
privileged:true
restart: always
stdin_open:true
tty:true
```





# 编译
docker-compose -f docker-compose.yml build
说明 编译后的镜像名称 以docker-compose.yml 所在的文件夹目录名为前缀_加上服务名


## YAML 模板文件
### compose file 变量的使用
有两种方式：
1. 通过系统环境变量进行传递
    $ export EXTERNAL_PORT=7000
    $ docker-compose up          # EXTERNAL_PORT will be 7000
2. 通过执行`docker-compose up` 的目录(即工作目录)创建`.env` 文件传递
    $ unset EXTERNAL_PORT
    $ echo "EXTERNAL_PORT=6000" > .env
    $ docker-compose up          # EXTERNAL_PORT will be 6000

web:
  build: .
  ports:
    - "${EXTERNAL_PORT:-default}:5000"

    ${VARIABLE:-default} will evaluate to default if VARIABLE is unset or empty in the environment.
    ${VARIABLE-default} will evaluate to default only if VARIABLE is unset in the environment.

3. 当想忽略掉带$的字符串时 可以使用两个 $$字符

web:
  build: .
  command: "$$VAR_NOT_INTERPOLATED_BY_COMPOSE"



默认的模板文件是 `docker-compose.yml`，其中定义的每个服务都必须通过 `image` 指令指定镜像或 `build` 指令（需要 Dockerfile）来自动构建。

其它大部分指令都跟 `docker run` 中的类似。

如果使用 `build` 指令，在 `Dockerfile` 中设置的选项(例如：`CMD`, `EXPOSE`, `VOLUME`, `ENV` 等) 将会自动被获取，无需在 `docker-compose.yml` 中再次设置。

### `image`

指定为镜像名称或镜像 ID。如果镜像在本地不存在，`Compose` 将会尝试拉去这个镜像。

例如：
```sh
image: ubuntu
image: orchardup/postgresql
image: a4bc65fd
```

### `build`

指定 `Dockerfile` 所在文件夹的路径。 `Compose` 将会利用它自动构建这个镜像，然后使用这个镜像。

```
build: /path/to/build/dir
```

### `command`

覆盖容器启动后默认执行的命令。

```sh
command: bundle exec thin -p 3000
```

### `links`

链接到其它服务中的容器。使用服务名称（同时作为别名）或服务名称：服务别名 `（SERVICE:ALIAS）` 格式都可以。

```sh
links:
 - db
 - db:database
 - redis
```

使用的别名将会自动在服务容器中的 `/etc/hosts` 里创建。例如：

```sh
172.17.2.186  db
172.17.2.186  database
172.17.2.187  redis
```

相应的环境变量也将被创建。

### `external_links`
链接到 docker-compose.yml 外部的容器，甚至 并非 `Compose` 管理的容器。参数格式跟 `links` 类似。

```
external_links:
 - redis_1
 - project_db_1:mysql
 - project_db_1:postgresql
```


### `ports`

暴露端口信息。

使用宿主：容器 `（HOST:CONTAINER）`格式或者仅仅指定容器的端口（宿主将会随机选择端口）都可以。

```
ports:
 - "3000"
 - "8000:8000"
 - "49100:22"
 - "127.0.0.1:8001:8001"
```

*注：当使用 `HOST:CONTAINER` 格式来映射端口时，如果你使用的容器端口小于 60 你可能会得到错误得结果，因为 `YAML` 将会解析 `xx:yy` 这种数字格式为 60 进制。所以建议采用字符串格式。*


### `expose`

暴露端口，但不映射到宿主机，只被连接的服务访问。

仅可以指定内部端口为参数

```sh
expose:
 - "3000"
 - "8000"
```

### `volumes`

卷挂载路径设置。可以设置宿主机路径 （`HOST:CONTAINER`） 或加上访问模式 （`HOST:CONTAINER:ro`）。

```sh
volumes:
 - /var/lib/mysql
 - cache/:/tmp/cache
 - ~/configs:/etc/configs/:ro
```

### `volumes_from`

从另一个服务或容器挂载它的所有卷。

```sh
volumes_from:
 - service_name
 - container_name
```

### `environment`

设置环境变量。你可以使用数组或字典两种格式。

只给定名称的变量会自动获取它在 Compose 主机上的值，可以用来防止泄露不必要的数据。

```
environment:
  RACK_ENV: development
  SESSION_SECRET:

environment:
  - RACK_ENV=development
  - SESSION_SECRET
```

### `env_file`
从文件中获取环境变量，可以为单独的文件路径或列表。

如果通过 `docker-compose -f FILE` 指定了模板文件，则 `env_file` 中路径会基于模板文件路径。

如果有变量名称与 `environment` 指令冲突，则以后者为准。

```sh
env_file: .env

env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

环境变量文件中每一行必须符合格式，支持 `#` 开头的注释行。

```sh
# common.env: Set Rails/Rack environment
RACK_ENV=development
```

### `extends`
基于已有的服务进行扩展。例如我们已经有了一个 webapp 服务，模板文件为 `common.yml`。
```sh
# common.yml
webapp:
  build: ./webapp
  environment:
    - DEBUG=false
    - SEND_EMAILS=false
```

编写一个新的 `development.yml` 文件，使用 `common.yml` 中的 webapp 服务进行扩展。
```sh
# development.yml
web:
  extends:
    file: common.yml
    service: webapp
  ports:
    - "8000:8000"
  links:
    - db
  environment:
    - DEBUG=true
db:
  image: postgres
```
后者会自动继承 common.yml 中的 webapp 服务及相关环节变量。


### `net`

设置网络模式。使用和 `docker client` 的 `--net` 参数一样的值。

```sh
net: "bridge"
net: "none"
net: "container:[name or id]"
net: "host"
```
### `net`
Version 1 file format only. In version 2, use network_mode.
为容器指定网络类型，version 1专用，version 2使用network_mode.
net: "bridge"
net: "host"
net: "none"
net: "container:[service name or container name/id]"
### `network_mode`
Version 2 file format only. In version 1, use net.
为容器指定网络类型.
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"
### `networks`

    Version 2 file format only. In version 1, use net.

Networks to join, referencing entries under the top-level networks key.
services:
  some-service:
    networks:
     - some-network
     - other-network


### `pid`
跟主机系统共享进程命名空间。打开该选项的容器可以相互通过进程 ID 来访问和操作。

```sh
pid: "host"
```

### `dns`

配置 DNS 服务器。可以是一个值，也可以是一个列表。

```sh
dns: 8.8.8.8
dns:
  - 8.8.8.8
  - 9.9.9.9
```

### `cap_add, cap_drop`
添加或放弃容器的 Linux 能力（Capabiliity）。
```sh
cap_add:
  - ALL

cap_drop:
  - NET_ADMIN
  - SYS_ADMIN
```

### `dns_search`

配置 DNS 搜索域。可以是一个值，也可以是一个列表。

```sh
dns_search: example.com
dns_search:
  - domain1.example.com
  - domain2.example.com
```

### `working_dir, entrypoint, user, hostname, domainname, mem_limit, privileged, restart, stdin_open, tty, cpu_shares`

这些都是和 `docker run` 支持的选项类似。

```
cpu_shares: 73

working_dir: /code
entrypoint: /code/entrypoint.sh
user: postgresql

hostname: foo
domainname: foo.com

mem_limit: 1000000000
privileged: true

restart: always

stdin_open: true
tty: true
```
