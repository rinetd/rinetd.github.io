---
title: Linux命令 Ansible
date: 2016-03-05T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [Ansible]
---
[Ansible中文权威指南](http://www.ansible.com.cn/)

github.com/mrlesmithjr

## 安装最新的ansible
$ sudo easy_install pip
$ sudo pip install ansible


# Tower替代软件
## docker run -d --name=semaphore -p 80:3000 -v /docker/ansible/semaphore:/data playniuniu/ansible-semaphore
```sh
#!/bin/sh
SEMAPHORE_DB_HOST="127.0.0.1"
SEMAPHORE_DB_PORT="3306"
SEMAPHORE_DB_USER="root"
SEMAPHORE_DB_PASS="root"
SEMAPHORE_DB="semaphore"
SEMAPHORE_PLAYBOOK_PATH="/data/"
SEMAPHORE_ADMIN="root"
SEMAPHORE_ADMIN_EMAIL="root@example.com"
SEMAPHORE_ADMIN_NAME="root"
SEMAPHORE_ADMIN_PASSWORD="root"
```

some_host         ansible_ssh_port=2222     ansible_ssh_user=manager


## [pam_limits](http://docs.ansible.com/ansible/latest/pam_limits_module.html)
ansible all -m shell -a "ulimit -HSn 65535"
ansible all -m pam_limits -a "domain=* limit_type=- limit_item=nofile value=65536"
ansible all -m pam_limits -a "domain=* limit_type=hard limit_item=nofile value=65536"

## 时间同步chrony
 ansible-galaxy install influxdata.chrony

## mariadb 集群
1. ansible-galaxy install mrlesmithjr.mariadb-galera-cluster mrlesmithjr.etc-hosts
2. /etc/ansible/roles/mrlesmithjr.mariadb-galera-cluster
