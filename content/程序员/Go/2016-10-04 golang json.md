---
title: golang json
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
## 1. Decode 和 Unmarshal 区别
如果对Read的I/O性能比较敏感，可以考虑先把数据读出到[]byte再解析；如果对内存占用比较敏感，就直接使用decoder接口。
具体的要根据你的应用的需求和你的数据的规模而定。如果没有特别的需求，就直接用decoder简洁的写法就可以。
用json.Encoder会有一个全局的缓存池给不同的Encoder复用。如果要解析大量的json的话用json.Encoder或许会更好。
```go
data, err := ioutil.ReadAll(resp.Body)
if err == nil && data != nil {
    err = json.Unmarshal(data, value)
}
```
or using json.NewDecoder.Decode

`err = json.NewDecoder(resp.Body).Decode(value)`



It really depends on what your input is. If you look at the implementation of the Decode method of `json.Decoder`, it buffers the entire JSON value in memory before unmarshalling it into a Go value. So in most cases it won't be any more memory efficient (although this could easily change in a future version of the language).

So a better rule of thumb is this:

    Use `json.Decoder` if your data is coming from an `io.Reader` stream, or you need to decode multiple values from a stream of data.
    Use `json.Unmarshal` if you already have the JSON data in memory.

For the case of reading from an HTTP request, I'd pick json.Decoder since you're obviously reading from a stream.


## json tags
{
  "web": ":50052",
  "rpc":":50051",
  "cpu":  "1",
  "cache": [{"host": "192.168.0.2", "port": 3000},{"host": "192.168.0.1", "port": 3000}],
  "ns" : "visitor",
}

```go
type Config struct {
	Cpu    int    `json:"cpu,string"`   // 结构体中是int 但是json中是string类型
	Web    string `json:"web"`          // 绑定json字段
	Rpc    string `json:"-"`            // 忽略字段解析 双向
	Ns     string                       // 等价 `json:"ns"`
	Set    string  
	Cache  []ServerCache `json:"caches,omitempty"` //有就解析没有就不解析
	Logger GrayLog
}
c := new(Config)
file, _ := os.Open("conf.json")
err = json.NewDecoder(file).Decode(&c)
```
