---
title: Linux命令 alpie
date: 2016-03-05T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [Docker]
---


ENV TIMEZONE Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
RUN echo $TIMEZONE > /etc/timezone


RUN sed -i '$a \
    * soft nproc 65536 \
    * hard nproc 65536  \
    * soft nofile 65536  \
    * hard nofile 65536  \
    '  \
    /etc/security/limits.conf

  #RUN sed -i '$a \
  #        fs.file-max = 767246   \
  #        fs.aio-max-nr = 1048576  \
  #        ' /etc/sysctl.conf

  RUN sed -i '$a \
              ulimit -s 4096   \
              ulimit -m 15728640  \
          ' /etc/profile
