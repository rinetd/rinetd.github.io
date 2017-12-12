---
title: Go语言 proxy
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
package main

import (
	"fmt"

	"github.com/corpix/uarand"
)

func main() {
	fmt.Println(uarand.GetRandom())
}
