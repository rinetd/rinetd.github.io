---
title: Linux命令 resin
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [Linux基础]
tags: [resin]
---
sed -i \
		-e 's|${resin.root}/doc/resin-doc|webapps/resin-doc|' \
		-e 's|${resin.root}/doc/admin|webapps/admin' \

     "${D}/etc/resin/resin.xml" 
