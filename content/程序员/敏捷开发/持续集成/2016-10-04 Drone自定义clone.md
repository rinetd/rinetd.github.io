---
title: drone自定义clone
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
http://readme.drone.io/questions/how-to-customize-the-clone-stage/
http://readme.drone.io/0.5/usage/customize-clone/
https://github.com/drone-plugins/drone-git/blob/master/DOCS.md

```yaml
matrix:
  include:
    - REPO_URL: "git.yimengapp.com"
      LOCAL_VOLUME: "/var/www/yimeng"
pipeline:
  clone:
    image: plugins/git
    volumes:
      - ${LOCAL_VOLUME}/master:/drone/src/${REPO_URL}/${DRONE_REPO}
    when:
      branch: master

  clone:
    image: plugins/git
    volumes:
      - ${LOCAL_VOLUME}/release:/drone/src/${REPO_URL}/${DRONE_REPO}
    when:
      branch: release

  clone:
    image: plugins/git
    volumes:
      - ${LOCAL_VOLUME}/develop:/drone/src/${REPO_URL}/${DRONE_REPO}
    when:
      branch: [ dev, develop ]

  busybox:
    image: busybox
    volumes:
      - ${LOCAL_VOLUME}/:${LOCAL_VOLUME}
    commands:
      - if [ ${DRONE_BRANCH} == master ]; then chown -R 33:33 ${LOCAL_VOLUME}/master ; fi
      - if [ ${DRONE_BRANCH} == release ]; then chown -R 33:33 ${LOCAL_VOLUME}/release ; fi
      - if [ ${DRONE_BRANCH} == develop ]; then chown -R 33:33 ${LOCAL_VOLUME}/develop ; fi
```
volumes:必须加 否则依然挂载主机工作目录默认为 /drone，
workspace:
  base: /go     # 绝对路径 默认为 /drone
  path: src/github.com/octocat/hello-world #相对路径 配合base拼接出项目下载的绝对地址
  因为 workspace为docker创建的目录，所以必须手动挂载volume去覆盖内部的，才能做到目录共享
工作原理:

1. drone 根据workspace在docker中创建volume 工作目录，其他stage共享此volume 结束后销毁
2. 在clone 阶段 手工指定volumes 覆盖 系统创建的工作目录
3. 因为其他stage共享系统创建的volume 因此手工指定的volumes并不共享，因此如果想要使用的话依然需要显示volumes：

clone 阶段是pipeline 第一个阶段
# 跳过clone
跳过clone 有两种解决方案：
1. 全局跳过 这种方式解决的比较彻底，但还是会带来一次构建
```
pipeline:
  clone:
    image: busybox
    commands: ls /
    volumes: /tmp:/tmp
```
2. 将你需要执行的stage 添加到clone：下即可，但是如果添加条件支持的话 需要添加多个`step` clone:标签
注意: step标签名必须为clone:
```
pipeline:
  clone:
    image: plugins/ssh
    host: [ qubuluo.com ]
    user: root
    port: 22
    script:
      - echo master >master.txt
      - echo master
    when:
      branch: master
  clone:
    image: plugins/ssh
    host: [ qubuluo.com ]
    user: root
    port: 22
    script:
      - echo dev >dev.txt
      - echo dev
    when:
      branch: dev
```

# 为clone 增加缓存
1. 开启Trusted  # drone exec --repo.trusted
2. 创建自定义Dockerfile 镜像
```
FROM plugins/git
VOLUME /drone
# docker build -t rinetd/drone-git && docker push rinetd/drone-git
```

3. 创建自定义 clone stage
 volumes：/drone:/drone
```  
pipeline:
  clone:
    image: rinetd/drone-git
    volumes: /drone:/drone

```
4. drone agent 以 root 权限运行 否则没有文件写入权限
  或者 /drone 目录必须权限必须更改为agent运行用户

Drone automatically prepends a clone step to your Yaml file if one does not already exist. You can manually configure the clone step in your pipeline for customization:

pipeline:
+ clone:
+   image: plugins/git

Example configuration to override depth:

pipeline:
  clone:
    image: plugins/git
+   depth: 50

Example configuration to use a custom clone plugin:

pipeline:
  clone:
+   image: octocat/custom-git-plugin
