---
title: msyql中子查询IN，EXISTS，ANY，ALL，SOME，UNION关键字介绍
date: 2016-02-26T15:30:01+08:00
update: 2016-01-01
categories: [数据库]
tags: [mysql]
---

msyql中子查询IN，EXISTS，ANY，ALL，SOME，UNION介绍

1. ANY关键字

假设any内部的查询语句返回的结果个数是三个，如:result1,result2,result3,那么，

`select ...from ... where a > any(...);`
-> 等价于
`select ...from ... where a > result1 or a > result2 or a > result3;`

2. ALL关键字

ALL关键字与any关键字类似，只不过上面的or改成and。即:

`select ...from ... where a > all(...);`

-> 等价于

`select ...from ... where a > result1 and a > result2 and a > result3;`
3. SOME关键字

some关键字和any关键字是一样的功能。所以:

`select ...from ... where a > some(...);`
-> 等价于
`select ...from ... where a > result1 or a > result2 or a > result3;`

4. IN关键字 `= ANY`

IN运算符用于WHERE表达式中，以列表项的形式支持多个选择，语法如下：

　　WHERE column IN (value1,value2,...)
　　WHERE column NOT IN (value1,value2,...)
当 IN 前面加上 NOT运算符时，表示与 IN 相反的意思，即不在这些列表项内选择。代码如下:

查询
SELECT ID,NAME FROM A WHERE　ID IN (SELECT AID FROM B)             //查询B表中AID的记录
SELECT ID,NAME FROM A WHERE　ID　NOT IN (SELECT AID FROM B)        //意思和上面相反
删除
delete from articles where id in (1,2,3);                         //删除id=1,id=2,id=3的记录
delete from articles where id not in (1);                         //删除id!=1的记录

词语IN是"＝ANY"的别名。因此，这两个语句是一样的：

SELECT s1 FROM t1 WHERE s1 = ANY (SELECT s1 FROM t2);
SELECT s1 FROM t1 WHERE s1 IN    (SELECT s1 FROM t2);

5. EXISTS关键字
   当EXISTS结果为真时执行查询
MySQL EXISTS 和 NOT EXISTS 子查询语法如下：

　　SELECT ... FROM table WHERE  EXISTS (SUBquery)
该语法可以理解为：将主查询的数据，放到子查询中做条件验证，根据验证结果（TRUE 或 FALSE）来决定主查询的数据结果是否得以保留。

` SELECT * FROM employee  WHERE EXISTS (SELECT d_name FROM department WHERE d_id=1004);`
Empty set (0.00 sec)

此处内层循环并没有查询到满足条件的结果，因此返回false，外层查询不执行。

NOT EXISTS刚好与之相反

当然，EXISTS关键字可以与其他的查询条件一起使用，条件表达式与EXISTS关键字之间用AND或者OR来连接，如下：

` SELECT * FROM employee WHERE age>24 AND EXISTS (SELECT d_name FROM department WHERE d_id=1003);`

提示：
•EXISTS (SUBquery) 只返回 TRUE 或 FALSE，因此子查询中的 SELECT * 也可以是 SELECT 1 或其他，官方说法是实际执行时会忽略 SELECT 清单，因此没有区别。
`SELECT EXISTS (SELECT TRUE FROM follows WHERE follower_id = $1 AND followee_id = $2)`
•EXISTS 子查询的实际执行过程可能经过了优化而不是我们理解上的逐条对比，如果担忧效率问题，可进行实际检验以确定是否有效率问题。
•EXISTS 子查询往往也可以用条件表达式、其他子查询或者 JOIN 来替代，何种最优需要具体问题具体分析

6. UNION关键字

MySQL UNION 用于把来自多个 SELECT 语句的结果组合到一个结果集合中。语法为：

　　SELECT column,... FROM table1
　　UNION [ALL]
　　SELECT column,... FROM table2
　　...

在多个 SELECT 语句中，对应的列应该具有相同的字段属性，且第一个 SELECT 语句中被使用的字段名称也被用于结果的字段名称。
UNION 与 UNION ALL 的区别

当使用 UNION 时，MySQL 会把结果集中重复的记录删掉，而使用 UNION ALL ，MySQL 会把所有的记录返回，且效率高于 UNION。

mysql> SELECT d_id FROM employee
    -> UNION
    -> SELECT d_id FROM department;
+------+
| d_id |
+------+
| 1001 |
| 1002 |
| 1004 |
| 1003 |
+------+

合并比较好理解，也就是将多个查询的结果合并在一起，然后去除其中的重复记录，如果想保存重复记录可以使用UNION ALL语句。
