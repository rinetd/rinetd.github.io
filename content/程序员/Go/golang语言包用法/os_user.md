---
title: golang中os/user包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中os/user包用法](/chenbaoke/article/details/42555095)

os/user包允许用户账号通过用户名或者用户id查找用户

type UnknownUserError

``` go
type UnknownUserError string
```

func (e UnknownUserError) Error() string　　//当通过lookup无法查找到某个用户时，便会返回该错误．type UnknownUserIdError

``` go
type UnknownUserIdError int
```

func (e UnknownUserIdError) Error() string　　　////当通过lookup无法查找到某个用户id时，便会返回该错误．

type User

``` go
type User struct {
    Uid      string // user id
    Gid      string // primary group id
    Username string  
    Name     string
    HomeDir  string      //用户主目录
}
```

func Current() (\*User, error)　　　　//获取当前用户信息
func Lookup(username string) (\*User, error)　//根据用户名查找用户信息
func LookupId(uid string) (\*User, error)　　　//根据用户id查找用户信息．
``` go
func main() {
    usr, err := user.Current()
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(usr.Gid)
    fmt.Println(usr.HomeDir)
    fmt.Println(usr.Name)
    fmt.Println(usr.Uid)
    fmt.Println(usr.Username)
    usr, _ = user.Lookup("root") //根据user name查找用户
    fmt.Println(usr)
    usr, err = user.LookupId("1100") //根据userid查找用户
    fmt.Println(usr, err)
}
```
