---
title: 深入理解dronefile
date: 2016-10-04T04:15:26+08:00
update: 2017-03-04 04:15:26
categories:
tags:
---

[深入理解dronefile](http://ryanharter.com/blog/2014/07/02/a-modern-ci-server-for-android/)

对于每个.drone.yml来说，pipeline的每个步骤经过drone解析后就对应一个dockerfile文件

对dronefile 来说只有4个主模式 [workspace pipeline services matrix]:
# I 变量
#变量使用
commands:
  - echo $PLUGIN_KEY      ## 在运行环境时解析 echo $PLUGIN_KEY
  - echo $$PLUGIN_KEY     ## 在运行环境时解析 echo $PLUGIN_KEY
  - echo ${PLUGIN_KEY}    ## ${PLUGIN_KEY}变量 在.drone.yml中解析 echo ''
  - echo $${PLUGIN_KEY}   ## 在运行环境时解析 echo ${PLUGIN_KEY}
script:
  - pwd

================================================================================
## 变量类型 有3种
1. $$DOCKER_PASSWORD # 系统环境变量 通过-e参数传入环境变量
2. $GO_VERSION       # matrix定义变量
3. ${DRONE_xxx}      # dronefile内置变量

## 1. 系统变量
---

## 变量的传递 通过-e参数带入环境变量
`docker run -e DOCKER_PASSWORD=correct-horse-battery-staple busybox`

## 加密变量 image repo

PASSWORD 123456                       # 变量设置
SSH_KEY  ${cat /path/to/.ssh/id_rsa}  # 命令返回值
SSH_KEY  @/path/to/.ssh/id_rsa        # 文件内容

`drone secrets add  --image=busybox --image=busybox:* octocat/hello-world SSH_KEY @/path/to/.ssh/id_rsa`

USAGE:
   drone secret add [command options] [repo] [key] [value]
OPTIONS:
   --event value  inject the secret for these event types (default: "push", "tag", "deployment")
   --image value  inject the secret for these image types
   --input value  input secret value from a file
   --skip-verify  skip verification for the secret
   --conceal      conceal secret in build logs

## 2. MATRIX变量
---

pipeline:
  build:
    image: golang:${GO_VERSION}
services:
  database:
    image: redis:${REDIS_VERSION}
matrix:
  GO_VERSION:
    - 1.4
    - 1.3
  REDIS_VERSION:
    - 2.6
    - 2.8
    - 3.0

仅设置特定组合
matrix:
  include:
    - GO_VERSION: 1.4
      REDIS_VERSION: 2.8
    - GO_VERSION: 1.5
      REDIS_VERSION: 2.8
    - GO_VERSION: 1.6
      REDIS_VERSION: 3.0


## 3. [drone内置变量参考](http://readme.drone.io/0.5/usage/environment-reference/)
通过命令查看内置变量
drone server --help
drone exec --help

---

```
pipeline:
…
s3:
  source: archive.tar.gz
  target: archive_${DRONE_COMMIT}.tar.gz
```
```
"${param}" 	      parameter substitution with escaping
${param:pos} 	    parameter substitution with substring
${param:pos:len} 	parameter substitution with substring
${param=default} 	parameter substitution with default
${param##prefix} 	parameter substitution with prefix removal
${param%%suffix} 	parameter substitution with suffix removal
${param/old/new} 	parameter substitution with find and replace
```

# II 工作目录workspace
================================================================================
```
workspace:
  base: /go     # 绝对路径 默认为 /drone
  path: src/github.com/octocat/hello-world #相对路径 配合base拼接出项目下载的绝对地址
```
等效指令 `git clone --depth=50 --recusive=true https://github.com/octocat/hello-world.git $base/$path`

# III pipeline 流水线
================================================================================
## stage 步骤
drone 不支持本地指令，所以 pipeline 的每一个`step`都是一个docker image镜像
## services 服务
services 是将pipeline中的每一个step抽离出来，因为经过 detach 所以在整个pipeline的生命周期都有效。
等价于 `detach: true`

Docker Configurations

# IV 条件控制 决定pipeline的执行条件
================================================================================
when:
1. branch: [master, develop, release, feature/* ]
2. event: [push, pull_request, tag, deployment]
3. status:  [ failure, changed, success ]
4. platform: [ linux/amd64, windows/amd64, linux/* ]
5. environment: production

全局分支控制 branches: dev

```
branches: dev
pipeline:
  clone:
    image: rinetd/drone-git
    volumes: /drone:/drone
```

branch: [ master, feature/* ]
branch:
  include: [ master, feature/* ]
  exclude: [ develop, feature/* ]
================================================================================
#drone 0.6
workspace:
  base: /go
  path: src/${DRONE_REPO_LINK:7}

matrix:
  include:
    - LOCAL_VOLUME: "/root/docker/linyibr/chirp"
clone:
  git:
    image: plugins/git
    volumes:
      - ${LOCAL_VOLUME}/master:/go/src/${DRONE_REPO_LINK:7}
    when:
      branch: master

clone:
  git:
    image: plugins/git
    volumes:
      - ${LOCAL_VOLUME}/release:/go/src/${DRONE_REPO_LINK:7}
    when:
      branch: release

clone:
  git:
    image: plugins/git
    volumes:
      - ${LOCAL_VOLUME}/develop:/go/src/${DRONE_REPO_LINK:7}
    when:
      branch: [ dev, develop ]
pipeline:
  busybox:
    image: busybox
    volumes:
      - ${LOCAL_VOLUME}/:${LOCAL_VOLUME}
    commands:
      - echo $DRONE_WORKSPACE
      - echo $DRONE_WORKSPACE_PATH
      - echo $DRONE_ARCH
      - echo $DRONE_REPO
      - echo $DRONE_REPO_OWNER
      - echo $DRONE_REPO_NAME
      - echo $DRONE_REPO_LINK
      - echo $DRONE_REPO_BRANCH
      - echo $DRONE_REPO_PRIVATE
      - echo $DRONE_REPO_TRUSTED
      - echo $DRONE_REMOTE_URL
      - echo $DRONE_COMMIT_SHA
      - echo $DRONE_COMMIT_REF
      - echo $DRONE_COMMIT_REFSPEC
      - echo $DRONE_COMMIT_BRANCH
      - echo $DRONE_COMMIT_LINK
      - echo $DRONE_COMMIT_MESSAGE
      - echo $DRONE_COMMIT_AUTHOR
      - echo $DRONE_COMMIT_AUTHOR_EMAIL
      - echo $DRONE_COMMIT_AUTHOR_AVATAR
      - echo $DRONE_BUILD_NUMBER
      - echo $DRONE_BUILD_EVENT
      - echo $DRONE_BUILD_LINK
      - echo $DRONE_BUILD_CREATED
      - echo $DRONE_BUILD_STARTED
      - echo $DRONE_BUILD_FINISHED
      - echo $DRONE_JOB_NUMBER
      - echo $DRONE_JOB_STARTED
      - echo $DRONE_BRANCH
      - echo $DRONE_COMMIT
      - echo $DRONE_VERSION
      - echo $DRONE_DEPLOY_TO
      - echo $DRONE_PREV_BUILD_STATUS
      - echo $DRONE_PREV_BUILD_NUMBER
      - echo $DRONE_PREV_COMMIT_SHA
      # - if [ ${DRONE_BRANCH} == master ]; then chown -R 33:33 ${LOCAL_VOLUME}/master ; fi
      # - if [ ${DRONE_BRANCH} == release ]; then chown -R 33:33 ${LOCAL_VOLUME}/release ; fi
      # - if [ ${DRONE_BRANCH} == develop ]; then chown -R 33:33 ${LOCAL_VOLUME}/develop ; fi

  ssh:
    image: appleboy/drone-ssh
    host: demo.linyibr.com
    # username: root
    # password: ${SSH_PASSWORD}
    # ssh-key: ${SSH_KEY}
    port: 222
    script:
      - echo $SSH_PASSWORD
      - echo ${SSH_PASSWORD}
      - echo $${SSH_PASSWORD}
    secrets: [ ssh_password,SSH_KEY ]
 # drone secret add --repository bianban/chirp --image=appleboy/drone-ssh --name SSH_KEY --value @/home/ubuntu/.ssh/id_rsa


================================================================================
```
  foo:
    image: golang
    build: .
    pull: true
    detach: true
    privileged: true
    environment:
      FOO: BAR
    entrypoint: /bin/sh
    command: "yes"
    commands: whoami
    extra_hosts: foo.com
    volumes: /foo:/bar
    volumes_from: foo
    devices: /dev/tty0
    network_mode: bridge
    dns: 8.8.8.8
    memswap_limit: 1
    mem_limit: 2
    cpu_quota: 3
    cpuset: 1,2
    oom_kill_disable: true

    auth_config:
      username: octocat
      password: password
      email: octocat@github.com

    access_key: 970d28f4dd477bc184fbd10b376de753
    secret_key: 9c5785d3ece6a9cdefa42eb99b58986f9095ff1c
```
``` pipeline
stage:
  name:
	image:
	build:
	pull:
	detach:
	privileged:
	environment:
	labels:
	entrypoint:
#	command:
	commands:
	extra_hosts:
	volumes:
	volumes_from:
	devices:
	network_mode:
	dns:
	dns_search:
	memswap_limit:
	mem_limit:
	shm_size:
	cpu_quota:
	cpu_shares:
	cpuset:
	oom_kill_disable:
  auth_config:
		username:
		password:
		email:
		registry_token:
	when:
```

```
pipeline:
  build:
    image: golang:${GO_VERSION}
    commands:
      - go get
      - go build
      - go test

services:
  database:
    image: ${DATABASE}

matrix:
  GO_VERSION:
    - 1.4
    - 1.3
  DATABASE:
    - mysql:5.5
    - mysql:6.5
    - mariadb:10.1
```

```
workspace:
  base: /go
  path: src/github.com/drone/drone

pipeline:
  test:
    image: golang:1.6
    environment:
      - GO15VENDOREXPERIMENT=1
    commands:
      - make deps gen
      - make test test_postgres test_mysql
  compile:
    image: golang:1.6
    environment:
      - GO15VENDOREXPERIMENT=1
      - GOPATH=/go
    commands:
      - export PATH=$PATH:$GOPATH/bin
      - make build
    when:
      event: push

  publish:
    image: plugins/s3
    acl: public-read
    bucket: downloads.drone.io
    source: release/**/*.*
    when:
      event: push
      branch: master
    privileged: true
  docker:
    image: plugins/docker
    repo: drone/drone
    tag: [ "0.5", "0.5.0", "0.5.0-rc" ]
    when:
      branch: master
      event: push

services:
  postgres:
    image: postgres:9.4.5
    environment:
      - POSTGRES_USER=postgres
  mysql:
    image: mysql:5.6.27
    environment:
      - MYSQL_DATABASE=test
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
```
