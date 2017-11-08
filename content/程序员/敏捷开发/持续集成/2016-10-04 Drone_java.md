---
title: drone_java
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
```yaml
matrix:
  include:
    - WORK_DIR: work
      SSH_HOST: b1.linyicn.com
      SSH_PORT: 22
      DB_HOST: 123.56.199.52
      DB_PORT: 3306
      DB_DATABASE: notes
      DB_USER: notes
      DB_PASSWORD: tz3MW8AfCvj14aZ
      HTTP_PORT: 10000
      TARGET_DIR: /docker/tomcat/webapps/

workspace:
  base: /go
  path: src/${DRONE_REPO_LINK:6}

clone:
  git:
    image: plugins/git
    volumes:
      - /docker/src:/go/src

pipeline:
  maven:
    image: maven
    group: ${DRONE_BRANCH}
    volumes:
      - /root/.m2:/root/.m2
      - /docker/src:/go/src
    commands:
      - mvn clean package -P${DRONE_BRANCH}

  rsync:
    image: drillster/drone-rsync
    volumes:
      - /docker/src:/go/src
    hosts: ${SSH_HOST}
    port:  ${SSH_PORT}
    user:  root
    # key: ${PLUGIN_KEY}
    source: target/${DRONE_REPO_NAME}/
    # target: /docker/${DRONE_REPO}/${DRONE_BRANCH}/
    # target: /docker/tomcat/webapps/${DRONE_REPO_NAME}/
    target: ${TARGET_DIR}/${WORK_DIR}
    args: --rsync-path="mkdir -p ${TARGET_DIR}/${WORK_DIR}/ && rsync"
    # include:
    #   - "app.tar.gz"
    #   - "app.tar.gz.md5"
    exclude:
      # - "**.*"
      - "upload"
      - "uploads"
    recursive: true
    delete: true
    script:
      # 这里脚本是在远程机器/root目录上执行
      # - sed -i -e "s|^jdbc.url=jdbc:mysql.*|jdbc.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}?useUnicode=true\&characterEncoding=UTF-8|g"
      #          -e "s|^jdbc.username=.*|jdbc.username=${DB_USER}|g"
      #          -e "s|^jdbc.password=.*|jdbc.password=${DB_PASSWORD}|g" ${TARGET_DIR}/${WORK_DIR}/WEB-INF/classes/jeesite.properties
      # - if [ -f /docker/tomcat/webapps/upgrade.sh ] ;then bash /docker/tomcat/webapps/upgrade.sh; fi
      # - mkdir -p ${TARGET_DIR}/ROOT/; echo '<script language="javascript"> window.location = "/${WORK_DIR}/"; </script>' > ${TARGET_DIR}/ROOT/index.html
      - true; docker rm -f tomcat ; docker run --restart=always -d --name tomcat -p ${HTTP_PORT}:8080 --link mariadb:mysql --add-host="docker0:${DB_HOST}"
               -v /docker/tomcat/webapps/:/usr/local/tomcat/webapps/ -v /docker/tomcat/logs:/usr/local/tomcat/logs  rinetd/tomcat:8.5
    secrets: [ RSYNC_KEY,PLUGIN_KEY ]

  # upgrade_mysql_lybb:
  #   image: rinetd/drone-mysql
  #   group: ${DRONE_BRANCH}
  #   volumes:
  #     - /docker/src:/go/src
  #   hosts:
  #     - ${DB_HOST}
  #   port:  ${DB_PORT}
  #   user:  ${DB_USER}
  #   password: ${DB_PASSWORD}
  #   database: ${DB_DATABASE}

  # ssh:
  #   image: appleboy/drone-ssh
  #   group: ${DRONE_BRANCH}
  #   volumes:
  #     - /docker/src:/go/src
  #   host: ${SSH_HOST}
  #   port: ${SSH_PORT}
  #   # username: root
  #   # password: ${SSH_PASSWORD}
  #   # ssh-key: ${SSH_KEY}
  #   script:
  #     - mkdir -p ${TARGET_DIR}/ROOT/; echo '<script language="javascript"> window.location = "/${WORK_DIR}/"; </script>' > ${TARGET_DIR}/ROOT//index.html
  #   secrets: [ SSH_KEY,PLUGIN_KEY ]


 # drone secret add --repository bianban/lybb --name PLUGIN_KEY --value @/home/ubuntu/.ssh/id_rsa

# branches: ${BRANCH_NAME}
```
