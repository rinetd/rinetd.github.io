---
title: PostgreSQL详解
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [数据库]
tags: [PostgreSQL]
---

可视化工具 DBeaver 是一个通用的数据库管理工具和 SQL 客户端，支持 MySQL, PostgreSQL, Oracle, DB2, MSSQL, Sybase, Mimer, HSQLDB, Derby, 以及其他兼容 JDBC 的数据库。DBeaver 提供一个图形界面用来查看数据库结构、执行SQL查询和脚本，浏览和导出数据，处理BLOB/CLOB 数据，修改数据库结构等等。


# pgweb `go get github.com/sosedoff/pgweb`

`pgweb --host localhost --port 5432 --user postgres --db partman`



run pgweb    http://127.0.0.1:8081

pgweb 是一个采用 Go 语言开发的基于 Web 的 PostgreSQL 管理系统。

First, start PostgreSQL in the container (using official image):

`docker run -d -p 5432:5432 --name db -e POSTGRES_PASSWORD=postgres postgres`

Then start pgweb container:

docker run -p 8081:8081 --link db:db -e DATABASE_URL=postgres://postgres:postgres@db:5432/


Usage

Start server:

pgweb

You can also provide connection flags:

`pgweb --host localhost --user myuser --db mydb`

Connection URL scheme is also supported:

`pgweb --url postgres://user:password@host:port/database?sslmode=[mode]`

Multiple database sessions

To enable multiple database sessions in pgweb, start the server with:

pgweb --sessions

Or set environment variable:

SESSIONS=1 pgweb
