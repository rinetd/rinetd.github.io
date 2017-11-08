---
title: Linux命令 date
date: 2016-01-06T16:46:14+08:00
update: 2016-09-27 16:03:53
categories: [linux_base]
tags: [date]

---
CST=UTC+8=GMT+8
CST:中国标准时间（China Standard Time)  等价于
UTC:世界标准时间(Universal Time/Temps Cordonn&eacute) + 8
GMT：格林尼治标准时间(Greenwich Mean Time) 等于UTC时间
PST是太平洋标准时间（西八区），与北京时间（东八区）时差-16个小时，也就是北京时间减去16就是PST时间。而PDT比PST早1个小时，就是说PDT与北京时间时差为-15小时

##  输出UTC时间
date --iso-8601=s -u
2017-09-27T10:19:07+00:00

`date  --iso-8601=s `等价 `date +%FT%T%z`
2017-09-27T18:01:25+08:00

date --rfc-3339=s
2017-09-27 18:01:40+08:00

date --rfc-2822
Wed, 27 Sep 2017 18:01:55 +0800

```
  ANSIC       = "Mon Jan _2 15:04:05 2006"
   UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
   RubyDate    = "Mon Jan 02 15:04:05 -0700 2006"
   RFC822      = "02 Jan 06 15:04 MST"
   RFC822Z     = "02 Jan 06 15:04 -0700" // 使用数字表示时区的RFC822
   RFC850      = "Monday, 02-Jan-06 15:04:05 MST"
   RFC1123     = "Mon, 02 Jan 2006 15:04:05 MST"
   RFC1123Z    = "Mon, 02 Jan 2006 15:04:05 -0700" // 使用数字表示时区的RFC1123
   RFC3339     = "2006-01-02T15:04:05Z07:00"
   RFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
   Kitchen     = "3:04PM"
   // 方便的时间戳
   Stamp      = "Jan _2 15:04:05"
   StampMilli = "Jan _2 15:04:05.000"
   StampMicro = "Jan _2 15:04:05.000000"
   StampNano  = "Jan _2 15:04:05.000000000"
```  

TIME_START="$(date +%s)" 1509691531     #现实unix时间戳
DOWEEK="$(date +'%u')"   5              #显示星期
HOSTNAME="$(hostname)"

#date //显示当前日期
#date -s //设置当前时间，只有root权限才能设置，其他只能查看。
#date -s 20061010 //设置成20061010，这样会把具体时间设置成空00:00:00
# date -s 12:23:23 //设置具体时间，不会对日期做更改
#date -s “12:12:23 2006-10-10″ //这样可以设置全部时间
#
# date -d next-day +%Y%m%d
20060328
# date -d last-day +%Y%m%d
20060326
# date -d yesterday +%Y%m%d
20060326
# date -d tomorrow +%Y%m%d
20060328
# date -d last-month +%Y%m
200602
# date -d next-month +%Y%m
200604
# date -d next-year +%Y
2007


%F   full date; same as %Y-%m-%d
%T   time; same as %H:%M:%S


date "+%Y%m%d_%H%M"
20170102_1145

date "+%Y-%m-%d %H:%M:%S" [2016-01-06 16:46:14]

(date +'%Y-%m-%d %H:%M')" # 2016-06-25 23:59
[root@root ~]# date "+%Y-%m-%d"  
2013-02-19  
[root@root ~]# date "+%H:%M:%S"  
13:13:59  
[root@root ~]# date "+%Y-%m-%d %H:%M:%S"  
2013-02-19 13:14:19  
[root@root ~]# date "+%Y_%m_%d %H:%M:%S"    
2013_02_19 13:14:58  
[root@root ~]# date -d today   
Tue Feb 19 13:10:38 CST 2013  
[root@root ~]# date -d now  
Tue Feb 19 13:10:43 CST 2013  
[root@root ~]# date -d tomorrow  
Wed Feb 20 13:11:06 CST 2013  
[root@root ~]# date -d yesterday  
Mon Feb 18 13:11:58 CST 2013  



%H 小时(以00-23来表示)。
%I 小时(以01-12来表示)。
%K 小时(以0-23来表示)。
%l 小时(以0-12来表示)。
%M 分钟(以00-59来表示)。
%P AM或PM。
%r 时间(含时分秒，小时以12小时AM/PM来表示)。
%s 总秒数。起算时间为1970-01-01 00:00:00 UTC。
%S 秒(以本地的惯用法来表示)。
%T 时间(含时分秒，小时以24小时制来表示)。 %H:%M:%S
%X 时间(以本地的惯用法来表示)。
%Z 市区。
%a 星期的缩写。
%A 星期的完整名称。
%b 月份英文名的缩写。
%B 月份的完整英文名称。
%c 日期与时间。只输入date指令也会显示同样的结果。
%d 日期(以01-31来表示)。
%D 日期(含年月日)。
%j 该年中的第几天。
%m 月份(以01-12来表示)。
%U 该年中的周数。
%w 该周的天数，0代表周日，1代表周一，异词类推。
%x 日期(以本地的惯用法来表示)。
%y 年份(以00-99来表示)。
%Y 年份(以四位数来表示)。
%n 在显示时，插入新的一行。
%t 在显示时，插入tab。
MM 月份(必要)
DD 日期(必要)
hh 小时(必要)
mm 分钟(必要)
ss 秒(选择性)
选择参数:
-d<字符串> 　显示字符串所指的日期与时间。字符串前后必须加上双引号。
-s<字符串> 　根据字符串来设置日期与时间。字符串前后必须加上双引号。
-u 　显示GMT。
