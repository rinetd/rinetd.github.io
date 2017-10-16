---
title: Linux命令 crontab
date: 2016-01-06T16:46:14+08:00
update: 2016-01-01
categories: [linux_base]
tags: [crontab]
---
# 每天早上5点 备份mysql 数据库
`00 5 * * * docker exec -i yimeng_mysql mysqldump -uroot -proot --all-databases>/var/www/yimeng/bakup/`date -I`.sql`
# 时间同步
`*/10 * * * * ntpdate time.asia.apple.com > /dev/null`

00 5 * * * docker exec -i mariadb mysqldump -uroot -pLinyiBR@2017 --all-databases>/docker/backup/`date -I`.sql
00 1 1 * * docker exec -i mariadb mysqldump -uroot -pLinyiBR@2017 --all-databases>/docker/backup/month/`date +%Y-%m`.sql
00 1 1 * * find /docker/backup/ -type f -ctime +30 -exec rm {} \;


在cron里设置,每周一凌晨2点执行(每周一全备份,其余时间增量备份)
```bash
# define  
dayofweek=`date "+%u"`  
today=`date "+%Y%m%d"`  
source=/data/  
backup=/backup/  

# action  
cd $backup  

if [ $dayofweek -eq 1 ]; then  
　　if [ ! -f "full$today.tar.gz" ]; then  
　　　　rm -rf snapshot  
　　　　tar -g snapshot -zcf "full$today.tar.gz" $source --exclude $sourceserver.log  
　　fi  
else  
　　if [ ! -f "inc$today.tar.gz" ]; then  
　　　　tar -g snapshot -zcf "inc$today.tar.gz" $source --exclude $sourceserver.log  
　　fi  
fi
```
前一天学习了 at 命令是针对仅运行一次的任务，循环运行的例行性计划任务，linux系统则是由 cron (crond) 这个系统服务来控制的。Linux 系统上面原本就有非常多的计划性工作，因此这个系统服务是默认启动的。另外, 由于使用者自己也可以设置计划任务，所以， Linux 系统也提供了使用者控制计划任务的命令 :crontab 命令。
一、crond简介
crond是linux下用来周期性的执行某种任务或等待处理某些事件的一个守护进程，与windows下的计划任务类似，当安装完成操作系统后，默认会安装此服务工具，并且会自动启动crond进程，crond进程每分钟会定期检查是否有要执行的任务，如果有要执行的任务，则自动执行该任务。
Linux下的任务调度分为两类，系统任务调度和用户任务调度。
系统任务调度：系统周期性所要执行的工作，比如写缓存数据到硬盘、日志清理等。在/etc目录下有一个crontab文件，这个就是系统任务调度的配置文件。
/etc/crontab文件包括下面几行：
[root@localhost ~]# cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=""HOME=/
# run-parts
51 * * * * root run-parts /etc/cron.hourly
24 7 * * * root run-parts /etc/cron.daily
22 4 * * 0 root run-parts /etc/cron.weekly
42 4 1 * * root run-parts /etc/cron.monthly
[root@localhost ~]#
前四行是用来配置crond任务运行的环境变量，第一行SHELL变量指定了系统要使用哪个shell，这里是bash，第二行PATH变量指定了系统执行命令的路径，第三行MAILTO变量指定了crond的任务执行信息将通过电子邮件发送给root用户，如果MAILTO变量的值为空，则表示不发送任务执行信息给用户，第四行的HOME变量指定了在执行命令或者脚本时使用的主目录。第六至九行表示的含义将在下个小节详细讲述。这里不在多说。
用户任务调度：用户定期要执行的工作，比如用户数据备份、定时邮件提醒等。用户可以使用 crontab 工具来定制自己的计划任务。所有用户定义的crontab 文件都被保存在 /var/spool/cron目录中。其文件名与用户名一致。
使用者权限文件：
文件：
/etc/cron.deny

该文件中所列用户不允许使用crontab命令
文件：
/etc/cron.allow

该文件中所列用户允许使用crontab命令
文件：
/var/spool/cron/

所有用户crontab文件存放的目录,以用户名命名
crontab文件的含义：
用户所建立的crontab文件中，每一行都代表一项任务，每行的每个字段代表一项设置，它的格式共分为六个字段，前五段是时间设定段，第六段是要执行的命令段，格式如下：
minute   hour   day   month   week   command
其中：
minute： 表示分钟，可以是从0到59之间的任何整数。
hour：表示小时，可以是从0到23之间的任何整数。
day：表示日期，可以是从1到31之间的任何整数。
month：表示月份，可以是从1到12之间的任何整数。
week：表示星期几，可以是从0到7之间的任何整数，这里的0或7代表星期日。
command：要执行的命令，可以是系统命令，也可以是自己编写的脚本文件。
![](http://images.cnitblog.com/blog/34483/201301/08090352-4e0aa3fe4f404b3491df384758229be1.png)
在以上各个字段中，还可以使用以下特殊字符：
星号 * ：代表所有可能的值，例如month字段如果是星号，则表示在满足其它字段的制约条件后每月都执行该命令操作。
逗号 , ：可以用逗号隔开的值指定一个列表范围，例如，“1,2,5,7,8,9”
中杠 - ：可以用整数之间的中杠表示一个整数范围，例如“2-6”表示“2,3,4,5,6”
正斜线 / ：可以用正斜线指定时间的间隔频率，例如“0-23/2”表示每两小时执行一次。同时正斜线可以和星号一起使用，例如*/10，如果用在minute字段，表示每十分钟执行一次。

5．使用实例
每分钟
`* * * * * command`
`* */1 * * * /etc/init.d/smb restart`

每小时
0 * * * * command

每小时执行/etc/cron.hourly目录内的脚本
01   *   *   *   *     root run-parts /etc/cron.hourly

每晚的21:30重启smb
30 21 * * * /etc/init.d/smb restart

实例2：每小时的第3和第15分钟执行
3,15 * * * * command

实例3：在上午8点到11点的第3和第15分钟执行
3,15 8-11 * * * command

实例4：每隔两天的上午8点到11点的第3和第15分钟执行
3,15 8-11 * /2 * * command

实例5：每个星期一的上午8点到11点的第3和第15分钟执行
3,15 8-11 * * 1 command


实例7：每月1、10、22日的4 : 45重启smb
45 4 1,10,22 * * /etc/init.d/smb restart

实例8：每周六、周日的1 : 10重启smb
10 1 * * 6,0 /etc/init.d/smb restart

实例9：每天18 : 00至23 : 00之间每隔30分钟重启smb
0,30 18-23 * * * /etc/init.d/smb restart

实例10：每星期六的晚上11 : 00 pm重启smb
0 23 * * 6 /etc/init.d/smb restart

实例12：晚上11点到早上7点之间，每隔一小时重启smb
命令：
* 23-7/1 * * * /etc/init.d/smb restart

实例13：每月的4号与每周一到周三的11点重启smb
命令：
0 11 4 * mon-wed /etc/init.d/smb restart

实例14：一月一号的4点重启smb
命令：
0 4 1 jan * /etc/init.d/smb restart

run-parts这个参数了，如果去掉这个参数的话，后面就可以写要运行的某个脚本名，而不是目录名了
四、使用注意事项
1. 注意环境变量问题
有时我们创建了一个crontab，但是这个任务却无法自动执行，而手动执行这个任务却没有问题，这种情况一般是由于在crontab文件中没有配置环境变量引起的。
在crontab文件中定义多个调度任务时，需要特别注意的一个问题就是环境变量的设置，因为我们手动执行某个任务时，是在当前shell环境下进行的，程序当然能找到环境变量，而系统自动执行任务调度时，是不会加载任何环境变量的，因此，就需要在crontab文件中指定任务运行所需的所有环境变量，这样，系统执行任务调度时就没有问题了。
不要假定cron知道所需要的特殊环境，它其实并不知道。所以你要保证在shelll脚本中提供所有必要的路径和环境变量，除了一些自动设置的全局变量。所以注意如下3点：
1）脚本中涉及文件路径时写全局路径；
2）脚本执行要用到java或其他环境变量时，通过source命令引入环境变量，如：
cat start_cbp.sh
#!/bin/sh
source /etc/profile
export RUN_CONF=/home/d139/conf/platform/cbp/cbp_jboss.conf
/usr/local/jboss-4.0.5/bin/run.sh -c mev &
3）当手动执行脚本OK，但是crontab死活不执行时。这时必须大胆怀疑是环境变量惹的祸，并可以尝试在crontab中直接引入环境变量解决问题。如：
0 * * * * . /etc/profile;/bin/sh /var/www/java/audit_no_count/bin/restart_audit.sh
2. 注意清理系统用户的邮件日志
每条任务调度执行完毕，系统都会将任务输出信息通过电子邮件的形式发送给当前系统用户，这样日积月累，日志信息会非常大，可能会影响系统的正常运行，因此，将每条任务进行重定向处理非常重要。
例如，可以在crontab文件中设置如下形式，忽略日志输出：
`0 */3 * * * /usr/local/apache2/apachectl restart >/dev/null 2>&1`
“/dev/null 2>&1”表示先将标准输出重定向到/dev/null，然后将标准错误重定向到标准输出，由于标准输出已经重定向到了/dev/null，因此标准错误也会重定向到/dev/null，这样日志输出问题就解决了。
3. 系统级任务调度与用户级任务调度
系统级任务调度主要完成系统的一些维护操作，用户级任务调度主要完成用户自定义的一些任务，可以将用户级任务调度放到系统级任务调度来完成（不建议这么做），但是反过来却不行，root用户的任务调度操作可以通过“crontab –uroot –e”来设置，也可以将调度任务直接写入/etc/crontab文件，需要注意的是，如果要定义一个定时重启系统的任务，就必须将任务放到/etc/crontab文件，即使在root用户下创建一个定时重启系统的任务也是无效的。
4. 其他注意事项
新创建的cron job，不会马上执行，至少要过2分钟才执行。如果重启cron则马上执行。
当crontab突然失效时，可以尝试/etc/init.d/crond restart解决问题。或者查看日志看某个job有没有执行/报错tail -f /var/log/cron。
千万别乱运行crontab -r。它从Crontab目录（/var/spool/cron）中删除用户的Crontab文件。删除了该用户的所有crontab都没了。
在crontab中%是有特殊含义的，表示换行的意思。如果要用的话必须进行转义\%，如经常用的date ‘+%Y%m%d’在crontab里是不会执行的，应该换成date ‘+\%Y\%m\%d’。
43 21 * * * 21:43 执行

15 05 * * * 　　 05:15 执行

0 17 * * * 17:00 执行

0 17 * * 1 每周一的 17:00 执行

0,10 17 * * 0,2,3 每周日,周二,周三的 17:00和 17:10 执行

0-10 17 1 * * 毎月1日从 17:00到7:10 毎隔1分钟 执行

0 0 1,15 * 1 毎月1日和 15日和 一日的 0:00 执行

42 4 1 * * 　 　 毎月1日的 4:42分 执行

0 21 * * 1-6　　 周一到周六 21:00 执行

0,10,20,30,40,50 * * * *　每隔10分 执行

`*/10 * * * *` 　　　　　　 每隔10分 执行

* 1 * * *　　　　　　　　 从1:0到1:59 每隔1分钟 执行

0 1 * * *　　　　　　　　 1:00 执行

`0 */1 * * *`　　　　　　　 毎时0分 每隔1小时 执行

0 * * * *　　　　　　　　 毎时0分 每隔1小时 执行
2 8-20/3 * * *　　　　　　8:02,11:02,14:02,17:02,20:02 执行

30 5 1,15 * *　　　　　　 1日 和 15日的 5:30 执行



#让linux每天定时备份MySQL数据库并删除五天前的备份文件
MYSQL定期备份是一项重要的工作，但人工操作太繁琐，也难避免有所疏漏，使用下面的方法即可让系统定期备份数据。利用系统crontab来定时执行备份文件，按日期对备份结果进行保存，达到备份的目的。

1、创建备份文件夹
#cd /bak
#mkdir mysqldata  

2、编写运行脚本
#nano -w /usr/sbin/bakmysql.sh
注：如使用nano编辑此代码需在每行尾添加'&&'或';'连接符，否则生成的文件名末尾字符为乱码
``` bash
#!/bin/bash
# Name:bakmysql.sh
# This is a ShellScript For Auto DB Backup and Delete old Backup
#
backupdir=/bak/mysqlbak
time=` date +%Y%m%d%H `
mysql_bin_dir/mysqldump -u user -ppassword dataname1 | gzip > $backupdir/name1$time.sql.gz
mysql_bin_dir/mysqldump -u user -ppassword dataname2 | gzip > $backupdir/name2$time.sql.gz
#
find $backupdir -name "name_*.sql.gz" -type f -mtime +5 -exec rm {} \; > /dev/null 2>&1
rm -rf `find $backupdir -name '*.sql.gz' -mtime 10`  #删除10天前的备份文件
```
``` bash
#!/bin/sh

mysqldump -uuser -ppassword dbname | gzip > /var/lib/mysqlbackup/dbname`date +%Y-%m-%d_%H%M%S`.sql.gz

cd  /var/lib/mysqlbackup
rm -rf `find . -name '*.sql.gz' -mtime 10`  #删除10天前的备份文件
```
保存退出

说明：
代码中time=` date +%Y%m%d%H `也可以写为time="$(date +"%Y%m%d$H")"
其中`符号是TAB键上面的符号，不是ENTER左边的'符号，还有date后要有一个空格。
mysql_bin_dir：mysql的bin路径；
dataname：数据库名；
user：数据库用户名；
password：用户密码；
name：自定义备份文件前缀标识。
-type f    表示查找普通类型的文件，f表示普通文件。
-mtime +5   按照文件的更改时间来查找文件，+5表示文件更改时间距现在5天以前；如果是 -mmin +5 表示文件更改时间距现在5分钟以前。
-exec rm {} \;   表示执行一段shell命令，exec选项后面跟随着所要执行的命令或脚本，然后是一对儿{ }，一个空格和一个\，最后是一个分号。
/dev/null 2>&1  把标准出错重定向到标准输出，然后扔到/DEV/NULL下面去。通俗的说，就是把所有标准输出和标准出错都扔到垃圾桶里面；其中的& 表示让该命令在后台执行。

3、为脚本添加执行权限
# chmod +x /usr/sbin/bakmysql.sh

4、修改/etc/crontab（在centOS5中测试可行）
#nano -w /etc/crontab  
在最后一行中加入：  
00 3 * * * root /usr/sbin/bakmysql.sh
表示每天3点00分执行备份

注：crontab配置文件格式如下：
分　时　日　月　周　 命令

Redhat方法：
Redhat的crontab采用按时间调用4个目录（/etc/cron.hourly：每小时；/etc/cron.daily：每天；/etc/cron.weekly：每周；/etc/cron.monthly：每月）中脚本出来运行的方式。
Redhat中只需要将刚才编辑的脚本复制到相应的目录即可。

5、重启crontab
# /etc/rc.d/init.d/crond restart  
完成。  

6、恢复数据备份文件：

非压缩备份文件恢复：
   #mysql -u root -p dataname < name2008010103.sql

从压缩文件直接恢复：
   #gzip < name2008010103.sql.gz | mysql -u root -p dataname
或：
# zcat name2008010103.sql.gz  | mysql -u root -p
