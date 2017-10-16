---
title: etterfilter
date: 2016-03-29T21:25:45+08:00
update: 2016-01-01
categories: [网络安全]
tags:
---


收集的一些Etterfilter

Below is a filter that Zaps the encoding to force plain-text communication:

if (ip.proto == TCP && tcp.dst == 80) {
if (search(DATA.data, “gzip”)) {
replace(“gzip”, ” “); # note: four spaces in the replacement string
msg(“whited out gzip\n”);
}
}

if (ip.proto == TCP && tcp.dst == 80) {
if (search(DATA.data, “deflate”)) {
replace(“deflate”, ” “); # note: seven spaces in the replacement string
msg(“whited out deflate\n”);
}
}

Replacing text in a packet:
if (ip.proto == TCP && search(DATA.data, “lol”)){
replace(“lol”, “smh”);
msg(“filter ran”);

}

Display a message if the tcp port is 22:
if (ip.proto == TCP) {
if (tcp.src == 22 || tcp.dst == 22) {
msg(“SSH packet\n”);
}
}

Log all telnet traffic, also execute ./program on every packet:
if (ip.proto == TCP) {
if (tcp.src == 23 || tcp.dst == 23) {
log(DATA.data, “./logfile.log”);
exec(“./program”);
}
}

Log all traffic except http:
if (ip.proto == TCP && tcp.src != 80 && tcp.dst != 80) {
log(DATA.data, “./logfile.log”);
}

Some operation on the payload of the packet:
if ( DATA.data + 20 == 0x4142 ) {
DATA.data + 20 = 0x4243;
} else {
DATA.data = “modified”;
DATA.data + 20 = 0x4445;
}

Drop any packet containing “ettercap”:
if (search(DECODED.data, “ettercap”)) {
msg(“some one is talking about us…\n”);
drop();
kill();
}

Log ssh decrypted packets matching the regexp
if (ip.proto == TCP) {
if (tcp.src == 22 || tcp.dst == 22) {
if (regex(DECODED.data, “.*login.*”)) {
log(DECODED.data, “./decrypted_log”);
}
}
}

Dying packets:
if (ip.ttl <>
msg(“The packet will die soon\n”);
}

String comparison at a given offset:
if (DATA.data + 40 == “ette”) {
log(DATA.data, “./logfile”);
}

Inject a file after a specific packet:
if (tcp.src == 21 && search(DATA.data, “root”)) {
inject(“./fake_response”);
}

Replace the entire packet with another:
if (tcp.src == 23 && search(DATA.data, “microsoft”)) {
drop();
inject(“./fake_telnet”);
}

Filter only a specific ip address:
if (ip.src == ‘192.168.0.2’) {
drop();
}

Translate the port of the tcp packet from 80 to 81:
if (tcp.dst == 80) {
tcp.dst -= 1;
tcp.dst += 2;
}

参考
more-on-ettercap-plus-filter-examples.
http://aerokid240.blogspot.com/2009/11/more-on-ettercap-plus-filter-examples.html

Xssf Inject with ettercap and Arp PoisoningClsHack
http://m.blog.csdn.net/article/details?id=7494769

中间人攻击之ettercap嗅探
http://www.s0nnet.com/archives/mitm-ettercap
