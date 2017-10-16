---
title: drone支持Rsync
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
[Drone plugin for deploying code using rsync](https://github.com/Drillster/drone-rsync)


Use the Rsync plugin to synchronize files to remote hosts, and execute arbitrary commands on those hosts.

## Config
The following parameters are used to configure the plugin:
- **user** - user to log in as on the remote machines, defaults to `root` `PLUGIN_USER RSYNC_USER`
- **key** - private SSH key for the remote machines
- **hosts** - hostnames or ip-addresses of the remote machines
- **port** - port to connect to on the remote machines, defaults to `22`
- **source** - source folder to synchronize from, defaults to `./`
- **target** - target folder on remote machines to synchronize to
- **include** - rsync include filter
- **exclude** - rsync exclude filter
- **recursive** - recursively synchronize, defaults to `false`
- **delete** - delete target folder contents, defaults to `false`
- **script** - list of commands to execute on remote machines

It is highly recommended to put your **key** into a secret so it is not exposed to users. This can be done using the drone-cli.

```sh
drone secret add octocat/hello-world RSYNC_KEY @path/to/.ssh/id_rsa
```

Add the secret to your `.drone.yml`:
```yaml
pipeline:
  rsync:
    image: drillster/drone-rsync
    user: some-user
    key: ${PLUGIN_KEY}
    hosts:
      - remote1
    source: ./dist
    target: ~/packages
```


See the [Secret Guide](http://readme.drone.io/usage/secret-guide/) for additional information on secrets.

## Examples
```yaml
pipeline:
  rsync:
    image: drillster/drone-rsync
    user: some-user
    key: ${RSYNC_KEY}
    hosts:
      - remote1
      - remote2
    source: ./dist
    target: ~/packages
    include:
      - "app.tar.gz"
      - "app.tar.gz.md5"
    exclude:
      - "**.*"
    script:
      - cd ~/packages
      - md5sum -c app.tar.gz.md5
      - tar -xf app.tar.gz -C ~/app
```

The example above illustrates a situation where an app package (`app.tar.gz`) will be deployed to 2 remote hosts (`remote1` and `remote2`). An md5 checksum will be deployed as well. After deploying, the md5 checksum is used to check the deployed package. If successful the package is extracted.

## Important
The script passed to **script** will be executed on remote machines directly after rsync completes to deploy the files. It will be executed step by step until a command returns a non-zero exit-code. If this happens, the entire plugin will exit and fail the build.


## drone0.5





Secrets

Sensitive plugin attributes can be replaced with the below secret environment variables. Please see the Drone documentation to learn more about secrets.

RSYNC_USER
    corresponds to user
RSYNC_KEY
    corresponds to key

hosts    list of hosts (remote machines)
port    port to connect to on the remote machines, defaults to 22
user    user to log in as on the remote machines, defaults to root
key    private SSH key for the remote machines
source    source folder to copy from, defaults to ./
target    target folder on remote machines to copy to
include    rsync include filter
exclude    rsync exclude filter
recursive    instruct plugin to recursively copy, can be true or false, defaults to false
delete    instruct plugin to delete the target folder before copying, can be true or false, defaults to false
script    list of commands to execute on remote machines over SSH


```
pipeline:
  build:
    image: maven:alpine
    commands:
      - mvn -B clean package
      - md5sum target/app.jar > app.jar.md5
  deploy:
    image: drillster/drone-rsync
    hosts: [ "server-prod1", "server-prod2" ]
    source: ./target
    target: ~/packages
    include: [ "app.jar", "app.jar.md5" ]
    exclude: [ "**.*" ]
    script:
      - cd ~/packages
      - md5sum -c app.jar.md5
```

export DRONE_SERVER=http://kbook.org
export DRONE_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXh0IjoicmluZXRkIiwidHlwZSI6InVzZXIifQ.0ZFhdVjrBHert1yuWBk3QFO9sKVm4iPzjTkr1l024c8
`drone secret add --image=drillster/drone-rsync rinetd/drone-with-go RSYNC_KEY @/home/ubuntu/.ssh/id_rsa`
`drone sign rinetd/drone-with-go`

$ drone secret ls rinetd/drone-with-go          #查看
$ drone secret rm rinetd/drone-with-go SSH_KEY  #移除
