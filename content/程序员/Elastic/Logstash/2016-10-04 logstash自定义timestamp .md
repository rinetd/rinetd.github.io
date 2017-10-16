---
title:  logstash自定义timestamp
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---

I used date filter to solve it, like:
date {
match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
target => "@timestamp"
}
