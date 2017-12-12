---
title: Linux之MariaDB基础详解
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [数据库]
tags: [MariaDB]
---
[Linux之MariaDB基础详解](http://www.jianshu.com/p/e59afa955a2d)
[MariaDB中文手册](http://www.zhdba.com/mysqlops/2013/08/16/mariadb-cn_1001/)
[远程登录 MySQL / MariaDB数据库配置教程](http://www.111cn.net/database/MongoDB/93332.htm)
[Mysql创建及删除用户命令](http://www.bitscn.com/pdb/mysql/201407/226089.html)
[MariaDB/MySQL之用户管理及忘记数据管理员密码解决办法](http://www.it165.net/database/html/201404/6158.html)
[MySQL——修改root密码的4种方法](http://www.jb51.net/article/39454.htm)
[](https://tinpont.com/2017/fix-yum-download-mariadb-slow/)
## 镜像解决方案

    创建并编辑MariaDB的源配置

sudo vi /etc/yum.repos.d/MariaDB.repo

写入配置文件

# MariaDB 10.1 CentOS repository list - created 2016-12-31 08:44 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum/10.1/centos7-amd64
gpgkey = https://mirrors.tuna.tsinghua.edu.cn/mariadb/yum//RPM-GPG-KEY-MariaDB
gpgcheck = 1

执行安装命令

sudo yum install mariadb-server

如果在用阿里云的服务器，可以将上述配置中的域名替换成

    http://mirrors.aliyun.com/

以上yum配置经修改后同样的适用于其他源，详细内容请往下看
sudo apt-get install mariadb-client
yum -y install MariaDB-server MariaDB-client  
sudo apt-get install mariadb-galera-server galera
## 统计
`SELECT ktitle,COUNT(*) FROM `ultrax`.`pre_fx_vote_log` WHERE `kid` = '89' `
## Mysql查询数据表中某字段重复出现的次数，并按照次数排序
`select [name],count(*) from [data] group by [name] order by count(*) DESC limit 10`
`SELECT ktitle,COUNT(*) FROM `ultrax`.`pre_fx_vote_log` group by ktitle order by count(*) DESC limit 15
`
## 开启 mysql 查询日志

| general_log                               | ON                                                                                                           |
| general_log_file                          | /var/log/mysql/mysql.log

mysql>set global general_log_file='/tmp/general.log';

mysql>set global general_log=on;

mysql>set global general_log=off;
```
# 	 && sed -i -e "s/^#general_log_file/general_log_file/" /etc/mysql/my.cnf\
# 	 && sed -i -e "s/^#general_log/general_log/" /etc/mysql/my.cnf\
# 	 && sed -i -e "s/^#log_slow_queries/log_slow_queries/" /etc/mysql/my.cnf\
# 	 && sed -i -e "s/^#long_query_time.*/long_query_time = 1/" /etc/mysql/my.cnf
```
## mysql 配置超时时间
show global variables like '%timeout%';

设置超时时间，临时生效（以秒为单位）：
  msyql> set global wait_timeout=86400;
  msyql> set global interactive_timeout=86400;
修改配置文件/etc/my.cnf.d/server.conf
        在 [mysqld]下添加
            wait_timeout=86400
```
            sed -i 's/^interactive-timeout.*/interactive-timeout = 86400/' /etc/my.cnf
            sed -i 's/^wait-timeout.*/wait-timeout = 86400/' /etc/my.cnf
```
# mysql 编码问题
解决: 保持mariadb 版本一致  mariadb:5.5
如下脚本创建数据库yourdbname，并制定默认的字符集是utf8: `CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;`
COLLATE utf8_general_ci:  数据库校对规则。该三部分分别为数据库字符集、通用、区分大小写。
utf8_unicode_ci比较准确，utf8_general_ci速度比较快。通常情况下 utf8_general_ci的准确性就够我们用的了，在我看过很多程序源码后，发现它们大多数也用的是utf8_general_ci，所以新建数据 库时一般选用utf8_general_ci就可以了。
如果要创建默认gbk字符集的数据库可以用下面的sql:`create database yourdb DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;`
# ERROR 1045 (28000): Access denied for user 'root'@'172.17.0.4' (using password: YES)
解决方法：密码输入错误，仔细检查密码
# 权限问题 Do you already have another mysqld server running on socket: /var/run/mysqld/mysqld.sock ?
```
`id mysql`
`uid=27(mysql) gid=27(mysql) groups=27(mysql)`
`uid=33(www-data) gid=33(www-data) groups=33(www-data)`
```
1. ` sudo userdel mysql `
2. ` sudo groupadd -r -g 999 mysql && sudo useradd -r -u 999  -c mysql -g mysql -d /var/lib/mysql -s /usr/sbin/nologin mysql `
3. ` sudo gpasswd -a ${USER} mysql `
4. ` sudo chown -R mysql:mysql /var/lib/mysql /var/run/mysqld `
5. ` docker run -d --name mysql -v $PWD/database/mysql:/var/lib/mysql -v /var/run/mysqld:/var/run/mysqld -e MYSQL_ROOT_PASSWORD=root mysql `
6. ` docker exec -it mysql bash `
`usermod -u 999 mysql`
`groupmod -g 999 mysql`
 find / -user 1005 -exec chown -h foo {} \;
 find / -group 2000 -exec chgrp -h foo {} \;

# docker
 `sudo chown -R 999:999 /var/run/mysqld`

` docker run -d --restart=always --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=LinyiBR@2017 -v /docker/mysql:/var/lib/mysql rinetd/mariadb `
# MySQL数据库从GBK转换到UTF-8最简单解决方案
--default-character-set=utf8 指定导出sql文件编码utf8格式

1、使用mysqldump导出 [表结构]，如：
      mysqldump -d -u root -p 数据库名 >/root/struct.sql

2、使用mysqldump以[指定utf8编码]导出[表数据]（其中--default-character-set=utf8 为所需编码，可按需修改），如：

      mysqldump --default-character-set=utf8 -t -u root -p 数据库名 >/root/data.sql

3、打开表结构转存（/root/struct.sql），将所有CREATE TABLE中的编码替换为所需编码；
     ` DEFAULT CHARSET=gbk; =>   DEFAULT CHARSET=utf8 ; `

4、进入MySQL控制台，执行：
      source /root/struct.sql
      source /root/data.sql
     即可完成。

导出表时，如果出现1044错误，添加   --skip-lock-tables  可以解决：
mysqldump -d -u root -p 数据库名 --skip-lock-tables >/root/struct.sql
mysqldump --default-character-set=utf8 -t -u root -p 数据库名 --skip-lock-tables >/root/data.sql

## dedecms GBK 转 UTF8
docker exec -i mariadb mysqldump -d -uroot -pLinyiBR@2017 guoan >guoanstuct.sql
docker exec -i mariadb mysqldump -t --default-character-set=utf8 -uroot -pLinyiBR@2017 guoan >guoan.sql

##MySQL 如何设置不区分表名大小写。
一般情况下 Linux 服务器默认安装 MySQL 的数据库表名是区分大小写的，如果 ECS 上安装的 MySQL 不支持表名区分大小下，则按照如下方法操作即可：

用 root 登录，修改 /etc/my.cnf （注意：以实际 my.cnf 配置文件路径为准）
在 [mysqld] 节点下，加入一行： `lower_case_table_names=1`
重启 MySQL 即可；

GRANT SELECT, INSERT, UPDATE, REFERENCES, DELETE, CREATE, DROP, ALTER, INDEX, TRIGGER, CREATE VIEW, SHOW VIEW, EXECUTE, ALTER ROUTINE, CREATE ROUTINE, CREATE TEMPORARY TABLES, LOCK TABLES, EVENT
 ON `wechat`.* TO 'wechat';

GRANT GRANT OPTION ON `wechat`.* TO 'wechat';

grant select, insert, update, delete, create, drop, references, index, alter,
        create temporary tables, lock tables, create view, show view, create routine,
        alter routine, execute, trigger       
on `Sample`.* to 'acme-manager'@'%';

grant create,select,insert,update,create view,show view,event,alter,trigger,index,alter on fgg.* to 'allen2016'@'%' identified by
'allen2016soft*88' with grant option;
flush privileges;


## 执行命令
` docker exec -i mariadb mysql -uroot -pXXXX -e "show databases;" `
` docker exec -i mariadb mysql -uroot -pXXXX -e "show databases; select user,host from mysql.user;" ``
## 创建数据库

`CREATE DATABASE IF NOT EXISTS `tpcms` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci`
`CREATE DATABASE IF NOT EXISTS `guoan` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci`

` docker exec -i mariadb mysql -uroot -pXXXX -e "CREATE DATABASE IF NOT EXISTS ytjxc DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci" `
` docker exec -i mariadb mysql -uroot -pXXXX -e "CREATE DATABASE IF NOT EXISTS ytjxc DEFAULT CHARACTER SET utf8 " `

## 创建并授权用户
` docker exec -i mariadb mysql -uroot -pXXXX -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'XXXX' WITH GRANT OPTION; FLUSH PRIVILEGES;" `
# docker 有个坑 内网ip不一定都是172.0.0.x 还有可能是192.0.0.x 所以 'user'@'1_2.%' 保险起见用 'user'@'%'
` docker exec -i mariadb mysql -uroot -pXXXX -e "GRANT ALL PRIVILEGES  ON *.* TO 'user'@'1_2.%' IDENTIFIED BY 'XXXX'; FLUSH PRIVILEGES;" `
## 备份全部数据库
` docker exec -it mariadb mysqldump -uroot -proot --all-databases >bak.sql `
## 备份指定数据库
` docker exec -it mariadb mysqldump -uroot -proot chengzhi >bak.sql  `      

#恢复指定数据库
` docker exec -i wuye_mysql mysql -uroot -ptoor sanyang <sanyang2016-4-28.sql `




## mariadb 无法启动 [用户 + 权限]
 `sudo chown -R 999:999 mysql`
 `rm -f /var/lib/mysql/aria_log*`
 `rm -f /var/lib/mysql/ib_logfile*`

## mysql 执行shell命令
mysql> `system ifconfig -a`

## 修复mariadb 数据库
`mysql_upgrade -u root -p`

## 初始化数据
`mysql_install_db --defaults-file=/etc/mysql/my.cnf --datadir=/var/data/db/mariadb/ --user=mysql`
## 登录数据库
` mysql -h127.0.0.1 -P3306 -uroot  -proot -e 'show databases;' `
`mysql -S /var/run/mysqld/mysqld.sock -uroot -p`


## mariadb 允许远程访问方式
  `mysql -h 139.129.108.163 -u kyxx -p`
## 创建数据库

CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;

create database yourdb DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
## 创建用户并授权
  //把所有用户的权限授予username@'hostname',密码是your_passwd
  `mysql>grant all on *.* to username@'hostname' indentified by [password]'your_passwd'`

  命令:GRANT privileges ON databasename.tablename TO 'username'@'host'
  privileges - 用户的操作权限,如 SELECT INSERT UPDATE	DELETE 等.如果要授予所的权限则使用ALL.;
                select,insert,update,delete,create,drop,index,alter,grant,references,reload,shutdown,process,file
  databasename - 数据库名,
  tablename-表名,如果要授予该用户对所有数据库和表的相应操作权限则可用*表示, 如*.*

  例子:
  GRANT SELECT, INSERT ON test.user TO 'username'@'%';
  GRANT ALL ON *.* TO 'username'@'%';

  注意:用以上命令授权的用户不能给其它用户授权,如果想让该用户可以授权,用以下命令:
  GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION;
  `GRANT ALL PRIVILEGES ON *.* TO 'kyxx'@'123.132.%.%' IDENTIFIED BY '888888' WITH GRANT OPTION; FLUSH PRIVILEGES;`
  #root可从任何IP登陆，注意修改密码:'888888'
  `GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '888888' WITH GRANT OPTION;`
  #root可从指定IP登陆，注意修改密码:'888888'、IP:'192.168.1.188'
  `GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.188' IDENTIFIED BY '888888' WITH GRANT OPTION;`
  GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER ON *.* TO 'huijin'@'%' IDENTIFIED BY 'Huijin2017@!'; FLUSH PRIVILEGES;
## 数据库备份恢复
  `show databases;`
  `mysqldump -uroot -p database >bak.sql`
  `mysqldump -uroot -p -A >bak.sql`
  `show variables like 'open%';`

  mysql> source /var/lib/mysql/ghost.sql

  关于导入导出docker中的mysql数据库
2.执行导出（备份）数据库命令
由第一步的结果可知，我们的mysql运行在一个叫mysql-online的docker容器中。而我们要备份的数据库就在里面，叫做test_db。mysql的用户名密码均为root，我们将文件备份到/opt/sql_bak文件夹下。
    docker exec -it mysql-online mysqldump -uroot -proot test_db > /opt/sql_bak/test_db.sql
3.执行导入（恢复）数据库命令：
目的：由第二步导出的sql文件，复制一个数据库。
首先我们进去，创建一个空白的数据库：
    docker exec -it mysql-online mysql -uroot -proot
    create database test_db_copy;

然后我们将sql文件导入：
    docker exec -i mysql-online mysql -uroot -proot test_db_copy < /opt/sql_bak/test_db.sql

注意：这里需要将参数 -it 更换为 -i ，否则会报错："cannot enable tty mode on non tty input"
--------------------------------------------------------------------------------  
## 查询用户
    0. ` show databases; `
    1. ` show tables from mysql; `
    2. ` show columns from mysql.user; `
    3. ` select user,host,authentication_string from mysql.user; `
   show grants;
1. show tables或show tables from database_name; -- 显示当前数据库中所有表的名称。
2. show databases; -- 显示mysql中所有数据库的名称。
3. show columns from table_name from database_name; 或show columns from database_name.table_name; -- 显示表中列名称。
4. show grants for user_name; -- 显示一个用户的权限，显示结果类似于grant 命令。
5. show index from table_name; -- 显示表的索引。
6. show status; -- 显示一些系统特定资源的信息，例如，正在运行的线程数量。
7. show variables; -- 显示系统变量的名称和值。
8. show processlist; -- 显示系统中正在运行的所有进程，也就是当前正在执行的查询。大多数用户可以查看他们自己的进程，但是如果他们拥有process权限，就可以查看所有人的进程，包括密码。
9. show table status; -- 显示当前使用或者指定的database中的每个表的信息。信息包括表类型和表的最新更新时间。
10. show privileges; -- 显示服务器所支持的不同权限。
11. show create database database_name; -- 显示create database 语句是否能够创建指定的数据库。
12. show create table table_name; -- 显示create database 语句是否能够创建指定的数据库。
13. show engines; -- 显示安装以后可用的存储引擎和默认引擎。
14. show innodb status; -- 显示innoDB存储引擎的状态。
15. show logs; -- 显示BDB存储引擎的日志。
16. show warnings; -- 显示最后一个执行的语句所产生的错误、警告和通知。
17. show errors; -- 只显示最后一个执行语句所产生的错误。
18. show [storage] engines; --显示安装后的可用存储引擎和默认引擎。

################################################################################
##MySQL——修改root密码的N种方法
1. MySQL忘记管理员密码的解决办法
 /etc/init.d/mysql stop
  mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
mysqld --skip-grant-tables &
mysql -u root mysql
mysql>use mysql
mysql>update user set password=password("toor") where user="root";
mysql>flush privileges;

2. 用SET PASSWORD命令
首先登录MySQL。
格式：mysql> set password for 用户名@localhost = password('新密码');
例子：mysql> set password for root@localhost = password('123');

3. 用mysqladmin
格式：mysqladmin -u用户名 -p旧密码 password 新密码
例子：mysqladmin -uroot -p123456 password 123
修改root密码
`mysqladmin -u root password 'root'`

4. 用UPDATE直接编辑user表
首先登录MySQL。
mysql> use mysql;
mysql> update user set password=password('123') where user='root' and host='localhost';
mysql> flush privileges;


/etc/init.d/mysql restart
mysql -uroot -p
###############################################################################
创建用户
CREATE USER foo;
INSERT INTO user(User, Host, Password) VALUES('foo', '%', Password('hello'));
SELECT User, Host, Password FROM user WHERE User = 'foo';

删除用户
DROP USER A;
drop user 'kyxx'@'123.132.226.%';
DELETE FROM user WHERE User = 'FOO';

创建备份用户
CREATE USER 'backupuser'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT,SHOW VIEW,LOCK TABLES,RELOAD,REPLICATION CLIENT ON *.* TO 'backupuser'@'localhost';
FLUSH PRIVILEGES;

用户设置密码
SET PASSWORD FOR A = Password('hello');

重命名用户
RENAME USER a TO A;
UPDATE user SET User = 'FOO' WHERE User = 'foo';
SELECT User, Host, Password FROM user WHERE User = 'FOO';

查看用户权限
SHOW GRANTS FOR A;

修改用户权限
GRANT SELECT ON crashcourse.* TO A;
grant all on *.* to homestead;
解除用户权限
REVOKE SELECT ON crashcourse.* FROM A;

## 一、用户授权

1、我们可以直接创建用户账：
//使用password关键字的话，可以加密密码
`mysql>create user username@'hostname' [identified by [password]'your_passwd']`

命令:CREATE USER 'username'@'host' IDENTIFIED BY 'password';
说明:
username - 你将创建的用户名, host - 指定该用户在哪个主机上可以登陆,如果是本地用户可用localhost, 如果想让该用户可以从任意远程主机登陆,可以使用通配符%.
password - 该用户的登陆密码,密码可以为空,如果为空则该用户可以不需要密码登陆服务器.
例子:
CREATE USER 'root'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'username'@'192.168.1.10_' IDENDIFIED BY '123456';
CREATE USER 'username'@'%' IDENTIFIED BY '123456';
CREATE USER 'username'@'%' IDENTIFIED BY '';
CREATE USER 'username'@'%';



2、也可以在授权的时候创建用户帐户：
//把所有用户的权限授予username@'hostname',密码是your_passwd
`mysql>grant all on *.* to username@'hostname' indentified by [password]'your_passwd'`

命令:GRANT privileges ON databasename.tablename TO 'username'@'host'
privileges - 用户的操作权限,如 SELECT INSERT UPDATE	DELETE 等.如果要授予所的权限则使用ALL.;
databasename - 数据库名,
tablename-表名,如果要授予该用户对所有数据库和表的相应操作权限则可用*表示, 如*.*

例子:
GRANT SELECT, INSERT ON test.user TO 'username'@'%';
GRANT ALL ON *.* TO 'username'@'%';

注意:用以上命令授权的用户不能给其它用户授权,如果想让该用户可以授权,用以下命令:
GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION;

3、如果需要更改用户名和密码的话：
//更改用户名
`mysql>rename user old_name@'old_host' to new_name@'new_host'`
//修改密码
`mysql>set password for user_name@'host'=password（'new_passwd'）`

命令:
SET PASSWORD FOR 'username'@'host' = PASSWORD('newpassword');
如果是当前登陆用户用SET PASSWORD = PASSWORD("newpassword");
例子: SET PASSWORD FOR 'username'@'%' = PASSWORD("123456");

4.撤销用户权限
命令: REVOKE privilege ON databasename.tablename FROM 'username'@'host';
说明: privilege, databasename, tablename - 同授权部分.
例子: REVOKE SELECT ON *.* FROM 'username'@'%';
注意: 假如你在给用户'username'@'%'授权的时候是这样的(或类似的):GRANT SELECT ON test.user TO 'username'@'%', 则在使用REVOKE SELECT ON *.* FROM 'username'@'%';命令并不能撤销该用户对test数据库中user表的SELECT 操作.相反,如果授权使用的是GRANT SELECT ON *.* TO 'username'@'%';则REVOKE SELECT ON test.user FROM 'username'@'%';命令也不能撤销该用户对test数据库中user表的Select 权限.
具体信息可以用命令SHOW GRANTS FOR 'username'@'%'; 查看.

五.删除用户
命令: DROP USER 'username'@'host';

##SQL测试
```
1.新建用户。
//登录MYSQL
@>mysql -u root -p
@>密码
//创建用户
mysql> mysql> insert into mysql.user(Host,User,Password,ssl_cipher,x509_issuer,x509_sub
ject) values("localhost","phplamp",password("1234"),'','','');
这样就创建了一个名为：phplamp 密码为：1234 的用户。
然后登录一下。
mysql>exit;
@>mysql -u phplamp -p
@>输入密码
mysql>登录成功
2.为用户授权。
//登录MYSQL（有ROOT权限）。我里我以ROOT身份登录.
@>mysql -u root -p
@>密码
//首先为用户创建一个数据库(phplampDB)
mysql>create database phplampDB;
//授权phplamp用户拥有phplamp数据库的所有权限。
>grant all privileges on phplampDB.* to phplamp@localhost identified by '1234';
//刷新系统权限表
mysql>flush privileges;
mysql>其它操作
/*
如果想指定部分权限给一用户，可以这样来写:
mysql>grant select,update on phplampDB.* to phplamp@localhost identified by '1234';
//刷新系统权限表。
mysql>flush privileges;
*/
3.删除用户。
@>mysql -u root -p
@>密码
mysql>Delete FROM user Where User="phplamp" and Host="localhost";
mysql>flush privileges;
//删除用户的数据库
mysql>drop database phplampDB;
4.修改指定用户密码。
@>mysql -u root -p
@>密码
mysql>update mysql.user set password=password('新密码') where User="phplamp" and Host="localhost";
mysql>flush privileges;
5.列出所有数据库
mysql>show database;
6.切换数据库
mysql>use '数据库名';
7.列出所有表
mysql>show tables;
8.显示数据表结构
mysql>describe 表名;
9.删除数据库和数据表
mysql>drop database 数据库名;

```
--------------------------------------------------------------------------------
-- 查看MySQL的状态  
status;  
-- 显示支持的引擎  
show engines;  
-- 显示所有数据库  
show databases;  
-- 切换数据库上下文,即设置当前会话的默认数据库  
use mysql;  
-- 显示本数据库所有的表  
show tables;  
-- 显示表中列名称
show columns from table_name from database_name;
show columns from database_name.table_name;
-- 显示一个用户的权限，显示结果类似于grant 命令
show grants for user_name;
-- 显示表的索引
show index from table_name;
-- 显示变量
show variables;
-- 显示插件
show plugins;

-- 查第一条
select * from table_name limit 1;
-- 查询最后一条
select day from table_name order by id desc limit 1;
-- 查询前30条记录
select * from table_name limit 0,30

-- 简单查询   
select id,userId from t_test  where userId='admin' ;
-- 创建一个表  
CREATE TABLE t_test (  
  id int(11) UNSIGNED NOT NULL AUTO_INCREMENT,  
  userId char(36),  
  lastLoginTime timestamp,  
  PRIMARY KEY (id)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8;  

-- 插入测试数据  
insert into t_test(userId)  
    values  
('admin')  
,('haha')  
;  

##修改数据存放目录
# 停止数据库  
service mysql stop  

# 创建目录,假设没有的话  
mkdir /usr/local/ieternal/mysql_data  

# 拷贝默认数据库到新的位置  
# -a 命令是将文件属性一起拷贝,否则各种问题  
cp -a /var/lib/mysql /usr/local/ieternal/mysql_data  

# 备份原来的数据  
cp -a /etc/my.cnf /etc/my.cnf_original  

# 其实查看 /etc/my.cnf 文件可以发现  
# MariaDB 的此文件之中只有一个包含语句  
# 所以需要修改的配置文件为 /etc/my.cnf.d/server.cnf  
cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf_original  
vim /etc/my.cnf.d/server.cnf  
# 在文件的 mysqld 节下添加内容  
```  
[mysqld]  
datadir=/usr/local/ieternal/mysql_data/mysql  
socket=/var/lib/mysql/mysql.sock  
#default-character-set=utf8  
character_set_server=utf8  
slow_query_log=on  
slow_query_log_file=/usr/local/ieternal/mysql_data/slow_query_log.log  
long_query_time=2  
```
其中,也只有 datadir 和 socket 比较重要; 而 default-character-set 是 mysql 自己认识的,而 mariadb5.5 就不认识,相当于变成了 character_set_server



服务器操作系统：CentOS 7
Web 服务器 IP 地址：192.168.33.61
数据库服务器 IP 地址：192.168.33.63
## 允许外网访问
第一步：编辑 my.cnf
vi /etc/my.cnf
vi /etc/my.cnf.d/server.cnf
在 [mysqld] 这个区域的下面，找到 bind-address ，如果没有，就去添加一行：
[mysqld]
bind-address=192.168.33.63

service mariadb restart
systemctl restart mariadb
sudo /etc/init.d/mysql start
## 第二步：添加远程用户
`CREATE USER 'username'@'host' IDENTIFIED BY 'password';`
现在数据库服务可以接受远程的连接，不过目前还没有用户拥有远程连接的权限，你需要再手工去添加一个远程用户，先用 root 用户登录到数据库服务：
mysql -u root -p
然后去创建一个数据库：
create database drupal;
再创建一个新的用户，注意这个用户是在 Web 服务器上可以使用的用户，所以需要指定一个 Web 服务器的 IP 地址：
`create user 'drupal'@'192.168.33.61' identified by 'drupal'`;
也就是，drupal 这个用户，只能在 192.168.33.61 这个 IP 地址的服务器上连接到数据库服务器。再去给这个用户分配权限：
`grant all privileges on drupal.* to ' drupal'@'192.168.33.61';`
立即生效，再执行：
`flush privileges;`
##第三步：远程连接

在 Web 服务器上，试着去登录一下数据库服务器上的数据库系统：
mysql -u drupal -h 192.168.33.63 -p
这里我们用 -h 选择，指定了一下要登录到的服务器的 IP 地址。这个 IP 地址就是数据库服务器的 IP 地址。
如果你发看到类似下面这样的错误：
ERROR 2003 (HY000): Can't connect to MySQL server on '192.168.33.63' (113 "No route to host")
很有可能是在数据库服务器上的防火墙的配置原因，配置一下 CentOS 7 自带的防火墙 Firewalld ：
firewall-cmd --zone=public --add-port=3306/tcp
完成以后，重新再到 Web 服务器上尝试连接数据库服务器。
补充:## mariaDB 创建用户

 > 我假定你已经做完初始化数据库的操作了（禁掉root的远程访问）,然后在本地用root帐号连接数据库了。

   mysql -u root -p mysql
--------------------------------------------------------------------------------

a. 准备数据目录
    以/mydata/data为例；
b. 配置mariadb
                    # groupadd -r -g 306 mysql
                    # useradd -r -g 306 -u 306 mysql
                    # tar xf mariadb-VERSION.tar.xz -C /usr/local
                    # ln -sv mariadb-version mysql
                    # cd /usr/local/mysql
                    # chown -R root:mysql ./*
                    # scripts/mysql_install_db --datadir=/mydata/data --user=mysql
                    # cp supper-files/mysql.server /etc/rc.d/init.d/mysqld
                    # chkconfig --add mysqld
c. 准备配置文件
    配置格式：类ini格式，为各程序均通过单个配置文件提供配置信息；
    [prog_name]

能用二进制格式安装,配置文件查找次序：
/etc/my.cnf --> /etc/mysql/my.cnf --> --default-extra-file=/PATH/TO/CONF_FILE --> ~/.my.cnf

OS提供的mariadb rpm包安装的配置文件查找次序:
/etc/mysql/my.cnf --> /etc/my.cnf --> --default-extra=/PATH/TO/conf_file --> ~/my.cnf

以上两者越靠后就是最后生效的.

  # mkdir /etc/mysql
  # cp support-files/my-large.cnf /etc/mysql/my.cnf

  添加三个选项：
      [mysqld]
      datadir = /mydata/data
      innodb_file_per_table = on
      skip_name_resolve = on

## MariDB程序的组成
MariaDB-client 	客户端工具像mysql CLI,mysqldump,和其它
MariaDB-common 	符集文件和/etc/my.cnf
MariaDB-compat 	客户端旧共享库,可能老版本的MariaDB或MySQL客户端需要
MariaDB-devel 	开发header和静态库。
MariaDB-server 	服务器和服务器工具,像myisamchk和mysqlhotcopy都在这里
MariaDB-shared 	动态客户端库
MariaDB-test 	mysql-client-test可执行和mysql-test框架进行测试
Client
    mysql : CLI交互式客户端程序
    mysqldump : 备份工具
    mysqladmin: 管理工具
    mysqlbinlog : 查看二进制日志工具
Server
    mysqld: 服务端进程
    mysqld_safe : 服务端进程,默认也是运行的此进程
    mysqld_multi : 服务端进程, 多实例
    mysql_upgrade : 升级工具

              服务端监听的两种socket地址

                  ip socket
                      监听在3306/tcp,支持远程通信
                  unix socket
                      监听在sock文件上(/tmp/mysql.sock, /var/lib/mysql/mysql.sock),仅支持本地通信,通信主机为localhost,127.0.0.1都基于unix socket文件通信

## 命令行交互式客户端程序---mysql工具
`mysql -h127.0.0.1 -uroot  -proot1234569 -e 'show databases;'`
    -uUSERNAME : 用户名,默认为root
    -pPASSWD : 用户的密码
    -hHOST : 服务器主机,默认为localhost
      DB_NAME: 连接到服务端之后,指明默认数据库
    -e 'SCRIPT' : 连接至MYSQL运行某命令后,直接退出,并返回结果


  注意: mysql的用户帐号由两部分组成,'username'@'hostname',其中host用于限制此用户可通过哪些主机连接当前的MSYQL服务器

      支持通配符:
          % : 匹配任意长度的任意字符
          172.16.%.%
          _ : 匹配任意单个字符
      内置命令
          \u DB_NAME : 设定哪个库为默认数据库
          \q : 退出
          \d CHAR : 设定新的语句结束符
          \g : 语句通用结束标记
          \G : 语句结束标记,但以竖排方式显示
          \s : 返回客户端与服务端的连接状态
          \c : 取消命令运行

  通过mysql协议发往服务器执行并取回结果,每个命令都必须有结束符,默认为";",示例如下:

for i in {1..100};
    do AGE=$[$RANDOM%100];
    mysql -uroot -pM8T9cw -e "insert mydb.student(id,name,age) value ($i,\"stu$i\",$AGE);";
done

获取命令帮助
    help



    grant 普通数据用户，查询、插入、更新、删除 数据库中所有表数据的权利。

    grant select on testdb.* to common_user@’%’

    grant insert on testdb.* to common_user@’%’

    grant update on testdb.* to common_user@’%’

    grant delete on testdb.* to common_user@’%’

    或者，用一条 MySQL 命令来替代：

    grant select, insert, update, delete on testdb.* to common_user@’%’

    9>.grant 数据库开发人员，创建表、索引、视图、存储过程、函数。。。等权限。

    grant 创建、修改、删除 MySQL 数据表结构权限。

    grant create on testdb.* to developer@’192.168.0.%’;

    grant alter on testdb.* to developer@’192.168.0.%’;

    grant drop on testdb.* to developer@’192.168.0.%’;

    grant 操作 MySQL 外键权限。

    grant references on testdb.* to developer@’192.168.0.%’;

    grant 操作 MySQL 临时表权限。

    grant create temporary tables on testdb.* to developer@’192.168.0.%’;

    grant 操作 MySQL 索引权限。

    grant index on testdb.* to developer@’192.168.0.%’;

    grant 操作 MySQL 视图、查看视图源代码 权限。

    grant create view on testdb.* to developer@’192.168.0.%’;

    grant show view on testdb.* to developer@’192.168.0.%’;

    grant 操作 MySQL 存储过程、函数 权限。

    grant create routine on testdb.* to developer@’192.168.0.%’; -- now, can show procedure status

    grant alter routine on testdb.* to developer@’192.168.0.%’; -- now, you can drop a procedure

    grant execute on testdb.* to developer@’192.168.0.%’;

    10>.grant 普通 DBA 管理某个 MySQL 数据库的权限。

    grant all privileges on testdb to dba@’localhost’

    其中，关键字 “privileges” 可以省略。

    11>.grant 高级 DBA 管理 MySQL 中所有数据库的权限。

    grant all on *.* to dba@’localhost’

    12>.MySQL grant 权限，分别可以作用在多个层次上。

    1. grant 作用在整个 MySQL 服务器上：

    grant select on *.* to dba@localhost; -- dba 可以查询 MySQL 中所有数据库中的表。

    grant all on *.* to dba@localhost; -- dba 可以管理 MySQL 中的所有数据库

    2. grant 作用在单个数据库上：

    grant select on testdb.* to dba@localhost; -- dba 可以查询 testdb 中的表。

    3. grant 作用在单个数据表上：

    grant select, insert, update, delete on testdb.orders to dba@localhost;

    4. grant 作用在表中的列上：

    grant select(id, se, rank) on testdb.apache_log to dba@localhost;

    5. grant 作用在存储过程、函数上：

    grant execute on procedure testdb.pr_add to ’dba’@’localhost’

    grant execute on function testdb.fn_add to ’dba’@’localhost’
    注意：修改完权限以后 一定要刷新服务，或者重启服务，刷新服务用：FLUSH PRIVILEGES。


    权限表
    权限 	说明
    all 	 
    alter 	 
    alter routine 	使用alter procedure 和drop procedure
    create 	 
    create routine 	使用create  procedure
    create temporary tables 	使用create temporary table
    create  user 	 
    create view 	 
    delete 	 
    drop 	 
    execute 	使用call和存储过程
    file 	使用select into outfile  和load data infile
    grant option 	可以使用grant和revoke
    index 	可以使用create index 和drop index
    insert 	 
    lock tables 	锁表
    process 	使用show full processlist
    reload 	   使用flush
    replication client 	服务器位置访问
    replocation slave 	由复制从属使用
    select 	 
    show databases 	 
    show view 	 
    shutdown 	使用mysqladmin shutdown 来关闭mysql
    super 	 
    update 	 
    usage 	无访问权限



## destoon 修复会员资料未认证
1. destoon 通过edittime 是否大于0 来判断是否完善资料
update destoon_member a inner join destoon_company b on a.userid=b.userid and b.validated=1 and a.edittime=0 set a.edittime='1511576804';

select count(edittime) from destoon_member where edittime>0;
select count(company) from destoon_company where validated = 1;
