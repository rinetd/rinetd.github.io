---
title: RethinkDB
date: 2016-05-26T15:30:01+08:00
update: 2016-01-01
categories: [数据库]
tags: [RethinkDB]
---
[install](https://www.rethinkdb.com/docs/install/)
docker run -d -P --name rethink1 rethinkdb
## 1. apt安装
ppa:rethinkdb/unstable
source /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
wget -qO- https://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install rethinkdb

## 2.源码安装
sudo apt-get install build-essential protobuf-compiler python \
                     libprotobuf-dev libcurl4-openssl-dev \
                     libboost-all-dev libncurses5-dev \
                     libjemalloc-dev wget m4
```										 
wget https://download.rethinkdb.com/dist/rethinkdb-latest.tgz										 
tar xf rethinkdb-2.3.4.tgz
./configure --allow-fetch
make && sudo make install
```
