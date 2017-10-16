---
title: Go语言 sql
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---

[Golang操作数据库 - 纵酒挥刀斩人头 - 博客园](http://www.cnblogs.com/hupengcool/p/4143238.html)
基本概念

    Open() – creates a DB
    Close() - closes the DB
    Query() - 查询
    QueryRow() -查询行
    Exec() -执行操作，update，insert，delete
    Row - A row is not a hash map, but an abstraction of a cursor
    Next()
    Scan()

注意：DB并不是指的一个connection
连接到数据库

我们以mysql为例，使用github.com/go-sql-driver/mysql，首先我们需要导入我们需要的包

import (
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
)

注意我们导入github.com/go-sql-driver/mysql 前面用了一个"_",_操作其实是引入该包，而不直接使用包里面的函数，而是调用了该包里面的init函数,import的时候其实是执行了该包里面的init函数，初始化了里面的变量，_操作只是说该包引入了，我只初始化里面的 init函数和一些变量，但是往往这些init函数里面是注册自己包里面的引擎，让外部可以方便的使用，就很多实现database/sql的包，在 init函数里面都是调用了sql.Register(name string, driver driver.Driver)注册自己，然后外部就可以使用了。
我们用Open()函数来打开一个database handle

db, err := sql.Open("mysql", "user:password@tcp(ip:port)/database")

写一个完整的：

import (
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
    "log"
)
func main() {
    db, err := sql.Open("mysql", "user:password@tcp(ip:port)/database")
    if err != nil {
        log.Println(err)
    }

    //在这里进行一些数据库操作

    defer db.Close()
}

我们在执行Open函数的时候，并不会去获得数据库连接有效性，当执行数据库操作的时候才会去连接，当我们需要在Open之后就知道连接的有效性的时候，可以通过Ping()来进行

err = db.Ping()
if err != nil {
    log.Println(err)
}

我们通常习惯使用Close来关闭数据库连接，但是sql.DB是被设计成长期有效的类型，我们不应该频繁的Open和Close，相反，我们应该建立一个sql.DB，在程序需要进行数据库操作的时候一直使用它，不要在一个方法里面进行Open和Close，应该把sql.DB作为参数传递给方法
进行数据库操作
增删改操作

Exec()方法一般用于增删改操作，这里以增加为例:

stmt, err := db.Prepare("insert into user(name,age)values(?,?)")
if err != nil {
    log.Println(err)
}

rs, err := stmt.Exec("go-test", 12)
if err != nil {
    log.Println(err)
}
//我们可以获得插入的id
id, err := rs.LastInsertId()
//可以获得影响行数
affect, err := rs.RowsAffected()

查询操作
一般的查询

    var name string
    var age int
    rows, err := db.Query("select name,age from user where id = ? ", 1)
    if err != nil {
        fmt.Println(err)
    }
    defer rows.Close()

    for rows.Next() {
        err := rows.Scan(&name, &age)
        if err != nil {
            fmt.Println(err)
        }
    }

    err = rows.Err()
    if err != nil {
        fmt.Println(err)
    }

    fmt.Println("name:", url, "age:", description)

我们应该养成关闭rows的习惯，在任何时候，都不要忘记rows.Close().哪怕这个rows在确实循环完之后，已经自动关闭掉了，我们定义rows.Close()也是对我们没有坏处的，因为我们无法保证，rows是否会正常的循环完。
查询单条记录，

我们使用db.QueryRow()

    var name string
    err = db.QueryRow("select name from user where id = ?", 222).Scan(&name)

没有结果的时候会返回err
处理空值

我们用一个name字段为空的记录来举例

var name NullString
err := db.QueryRow("SELECT name FROM names WHERE id = ?", id).Scan(&name)
...
if name.Valid {
        // use name.String
} else {
        // value is NULL
}

在这种情况下我们通常使用NullString，但是有时候我们并不关心值是不是Null,我们只需要吧他当一个空字符串来对待就行。这时候我们可以使用[]byte（null byte[]可以转化为空string） 或者 sql.RawBytes,

var col1, col2 []byte

for rows.Next() {
    // Scan the value to []byte
    err = rows.Scan(&col1, &col2)

    if err != nil {
        panic(err.Error()) // Just for example purpose. You should use proper error handling instead of panic
    }

    // Use the string value
    fmt.Println(string(col1), string(col2))
}

使用*sql.RawBytes

package main

import (
    "database/sql"
    "fmt"
    _ "github.com/go-sql-driver/mysql"
)

func main() {
    // Open database connection
    db, err := sql.Open("mysql", "user:password@/dbname")
    if err != nil {
        panic(err.Error())  // Just for example purpose. You should use proper error handling instead of panic
    }
    defer db.Close()

    // Execute the query
    rows, err := db.Query("SELECT * FROM table")
    if err != nil {
        panic(err.Error()) // proper error handling instead of panic in your app
    }

    // Get column names
    columns, err := rows.Columns()
    if err != nil {
        panic(err.Error()) // proper error handling instead of panic in your app
    }

    // Make a slice for the values
    values := make([]sql.RawBytes, len(columns))

    // rows.Scan wants '[]interface{}' as an argument, so we must copy the
    // references into such a slice
    // See http://code.google.com/p/go-wiki/wiki/InterfaceSlice for details
    scanArgs := make([]interface{}, len(values))
    for i := range values {
        scanArgs[i] = &values[i]
    }

    // Fetch rows
    for rows.Next() {
        // get RawBytes from data
        err = rows.Scan(scanArgs...)
        if err != nil {
            panic(err.Error()) // proper error handling instead of panic in your app
        }

        // Now do something with the data.
        // Here we just print each column as a string.
        var value string
        for i, col := range values {
            // Here we can check if the value is nil (NULL value)
            if col == nil {
                value = "NULL"
            } else {
                value = string(col)
            }
            fmt.Println(columns[i], ": ", value)
        }
        fmt.Println("-----------------------------------")
    }
    if err = rows.Err(); err != nil {
        panic(err.Error()) // proper error handling instead of panic in your app
    }
}

事务

使用db.Begin()来开启一个事务, 通过Commit()和Rollback()方法来关闭。

    tx := db.Begin()
    tx.Rollback()
    tx.Commit()

Exec, Query, QueryRow and Prepare 方法已经全部可以在tx上面使用。使用方法和在*sql.DB是一样的，事务必须以Commit()或者Rollback()结束
The Connection Pool

在database/sql中有一个很基本的连接池，你并没有多大的控制权，仅仅可以设置SetMaxIdleConns和SetMaxOpenConns，也就是最大空闲连接和最大连接数。

    db.SetMaxIdleConns(n)
    db.SetMaxOpenConns(n)
