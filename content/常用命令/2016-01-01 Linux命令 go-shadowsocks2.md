---
title: Linux命令 go-shadowsocks2
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [go-shadowsocks2]
---



## socks代理
go-shadowsocks2 -s ss://AEAD_CHACHA20_POLY1305:DOXdMOLyDS094XOBMQwlL6wRPn6zVnhyVCVYmqRMImA=@:8488 -verbose
go-shadowsocks2 -c ss://AEAD_CHACHA20_POLY1305:DOXdMOLyDS094XOBMQwlL6wRPn6zVnhyVCVYmqRMImA=@47.91.199.148:8488 -verbose -socks :1088

## 2. socks代理实现tcptun 正向代理
# iperf3 -s
# go-shadowsocks2 -s ss://AEAD_CHACHA20_POLY1305:DOXdMOLyDS094XOBMQwlL6wRPn6zVnhyVCVYmqRMImA=@:8488 -verbose

`-tcptun [client端][local_addr]:[local_port]=[server端][remote_addr]:[remote_port]`
# go-shadowsocks2 -c ss://AEAD_CHACHA20_POLY1305:DOXdMOLyDS094XOBMQwlL6wRPn6zVnhyVCVYmqRMImA=@47.91.199.148:8488 -verbose -socks :1088 -tcptun :1090=localhost:5201

iperf3 -c 127.0.0.1 -p 1090  

本机:1090-->服务器:8488 ->>服务器.localhost:5201


### Server

Start a server listening on port 8488 using `AEAD_CHACHA20_POLY1305` AEAD cipher with password `your-password`.

```sh
go-shadowsocks2 -s ss://AEAD_CHACHA20_POLY1305:your-password@:8488 -verbose
```


### Client

Start a client connecting to the above server. The client listens on port 1080 for incoming SOCKS5
connections, and tunnels both UDP and TCP on port 8053 and port 8054 to 8.8.8.8:53 and 8.8.4.4:53
respectively.

```sh
go-shadowsocks2 -c ss://AEAD_CHACHA20_POLY1305:your-password@[server_address]:8488 \
     -verbose -socks :1080 -udptun :8053=8.8.8.8:53,:8054=8.8.4.4:53 \
                           -tcptun :8053=8.8.8.8:53,:8054=8.8.4.4:53
```

Replace `[server_address]` with the server's public address.


## Advanced Usage


### Use random keys instead of passwords

A random key is almost always better than a password. Generate a base64url-encoded 16-byte random key

```sh
go-shadowsocks2 -keygen 16
```

Start a server listening on port 8848 using `AEAD_AES_128_GCM` AEAD cipher with the key generated above.

```sh
go-shadowsocks2 -s :8488 -cipher AEAD_AES_128_GCM -key k5yEIX5ciUDpkpdtvZm7zQ== -verbose
```

And the corresponding client to connect to it.

```sh
go-shadowsocks2 -c [server_address]:8488 -cipher AEAD_AES_128_GCM -key k5yEIX5ciUDpkpdtvZm7zQ== -verbose
```


### Netfilter TCP redirect (Linux only)

The client offers `-redir` and `-redir6` (for IPv6) options to handle TCP connections
redirected by Netfilter on Linux. The feature works similar to `ss-redir` from `shadowsocks-libev`.


Start a client listening on port 1082 for redirected TCP connections and port 1083 for redirected
TCP IPv6 connections.

```sh
go-shadowsocks2 -c [server_address]:8488 -cipher AEAD_AES_128_GCM -key k5yEIX5ciUDpkpdtvZm7zQ== \
    -redir :1082 -redir6 :1083
```


### TCP tunneling

The client offers `-tcptun [local_addr]:[local_port]=[remote_addr]:[remote_port]` option to tunnel TCP.
For example it can be used to proxy iperf3 for benchmarking.

Start iperf3 on the same machine with the server.

```sh
iperf3 -s
```

By default iperf3 listens on port 5201.

Start a client on the same machine with the server. The client listens on port 1090 for incoming connections
and tunnels to localhost:5201 where iperf3 is listening.

```sh
go-shadowsocks2 -c [server_address]:8488 -cipher AEAD_AES_128_GCM -key k5yEIX5ciUDpkpdtvZm7zQ== \
    -tcptun :1090=localhost:5201
```

Start iperf3 client to connect to the tunneld port instead

```sh
iperf3 -c localhost -p 1090
```
