---
title:  on update cascade 和on delete cascade 作用区别？
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [数据库]
tags: [mysql]
---
SQL 约束（Constraints）

在 SQL 中，我们有如下约束：

    NOT NULL - 指示某列不能存储 NULL 值。
    UNIQUE - 保证某列的每行必须有唯一的值。
    PRIMARY KEY - NOT NULL 和 UNIQUE 的结合。确保某列（或两个列多个列的结合）有唯一标识，有助于更容易更快速地找到表中的一个特定的记录。
    FOREIGN KEY - 保证一个表中的数据匹配另一个表中的值的参照完整性。
    CHECK - 保证列中的值符合指定的条件。
    DEFAULT - 规定没有给列赋值时的默认值。


这是数据库外键FOREGIN REFERENCES定义的一个可选项，用来设置当主键表中的被参考列的数据发生变化时，外键表中响应字段的变换规则的。update 则是主键表中被参考字段的值更新，delete是指在主键表中删除一条记录：

on update 和 on delete  后面可以跟的词语有四个[no action  ， set null ，  set default  ，cascade]
    no action 表示 不做任何操作，
    set null    表示在外键表中将相应字段设置为null
    set default 表示设置为默认值
    cascade 表示级联操作，就是说，如果主键表中被参考字段更新，外键表中也更新，主键表中的记录被删除，外键表中改行也相应删除



1.如果linecenter（主表）中的一个lid被删除了，那么引用该id的从表中的所有记录也被删除。

通常称为级联删除

例如：

SQL> create table test (id number(7) not null, name varchar2(20),  constraint pk_test primary key (id));

SQL> create table test1 (id number(7) not null, comments varchar(400), constraint fk_test1 foreign key (id) references test (id));


SQL> create table test2 (id number(7) not null, commects varchar(400), constraint fk_test2 foreign key (id) references test (id) on delete cascade);


SQL> insert into test values (1, 'abc');

已创建 1 行。

SQL> insert into test1 values (1, 'aaaaa');

已创建 1 行。

SQL> delete test;
delete test
*
ERROR 位于第 1 行:
ORA-02292: 违反完整约束条件 (YANGTK.FK_TEST1) - 已找到子记录日志


SQL> delete test1;

已删除 1 行。

SQL> delete test;

已删除 1 行。



关系表的级联更新： on update cascade
on delete cascade 是级联删除的意思
意思是 当你更新或删除主键表时，那么外键表也会跟随一起更新或删除

CREATE TABLE Countries(CountryId INT PRIMARY KEY)
INSERT INTO Countries (CountryId) VALUES (1)
INSERT INTO Countries (CountryId) VALUES (2)
INSERT INTO Countries (CountryId) VALUES (3)
GO
CREATE TABLE Cities( CityId INT PRIMARY KEY ,CountryId INT REFERENCES Countries ON DELETE CASCADE);
INSERT INTO Cities VALUES(1,1)
INSERT INTO Cities VALUES(2,1)
INSERT INTO Cities VALUES(3,2)
GO
CREATE TABLE Buyers(CustomerId INT PRIMARY KEY ,CityId INT REFERENCES Cities ON DELETE CASCADE);
INSERT INTO Buyers  VALUES(1,1),
INSERT INTO Buyers  VALUES(2,1)
INSERT INTO Buyers  VALUES(3,2)
GO

命令：
DELETE FROM Countries WHERE CountryId = 1
结果：
Countries：
CountryId
2
3
Cities：
CityId CountryId
3 2
Buyers：
CustomerId CityId

ON UPDATE CASCADE的用法和ON DELETE CASCADE差不多
