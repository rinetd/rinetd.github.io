---
title: Go语言 ip2location
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
github.com/bububa/ip2region-go
###
github.com/fiorix/freegeoip
docker run --restart=always -p 8080:8080 -d fiorix/freegeoip

curl localhost:8080/json/1.2.3.4
###

github.com/ip2location/ip2location-go

	http://download.ip2location.com/lite/

	```
	package main

	import (
		"fmt"
		"github.com/ip2location/ip2location-go"
	)
	func main(){
		ip := "60.213.47.147"
		ip2location.Open("/home/ubuntu/go/IP2LOCATION-LITE-DB1.BIN")
		fmt.Println(ip2location.Get_country_short(ip).Country_short)
	}
```

3. https://github.com/oschwald/geoip2-golang

### 2. Regional Internet Registry (RIR) file parser & CLI in Go
### 根据国家代码查询
go get github.com/simcap/rir
