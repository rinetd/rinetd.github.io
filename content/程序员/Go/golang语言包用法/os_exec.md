---
title: golang中os/exec包用法
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------
[golang中os/exec包用法](/chenbaoke/article/details/42556949)

exec包执行外部命令，它将os.StartProcess进行包装使得它更容易映射到stdin和stdout，并且利用pipe连接i/o．

func LookPath(file string) (string, error) //LookPath在环境变量中查找科执行二进制文件，如果file中包含一个斜杠，则直接根据绝对路径或者相对本目录的相对路径去查找

``` go
func main() {
    f, err := exec.LookPath("ls")
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(f) //  /bin/ls
}
```

type Cmd　　　//表示一个正在准备或者正在运行的外部命令

``` go
type Cmd struct {
    Path         string　　　//运行命令的路径，绝对路径或者相对路径
    Args         []string　　 // 命令参数
    Env          []string         //进程环境，如果环境为空，则使用当前进程的环境
    Dir          string　　　//指定command的工作目录，如果dir为空，则comman在调用进程所在当前目录中运行
    Stdin        io.Reader　　//标准输入，如果stdin是nil的话，进程从null device中读取（os.DevNull），stdin也可以时一个文件，否则的话则在运行过程中再开一个goroutine去
　　　　　　　　　　　　　//读取标准输入
    Stdout       io.Writer       //标准输出
    Stderr       io.Writer　　//错误输出，如果这两个（Stdout和Stderr）为空的话，则command运行时将响应的文件描述符连接到os.DevNull
    ExtraFiles   []*os.File 　　
    SysProcAttr  *syscall.SysProcAttr
    Process      *os.Process    //Process是底层进程，只启动一次
    ProcessState *os.ProcessState　　//ProcessState包含一个退出进程的信息，当进程调用Wait或者Run时便会产生该信息．
}
```

func Command(name string, arg ...string) \*Cmd　　　　//command返回cmd结构来执行带有相关参数的命令，它仅仅设定cmd结构中的Path和Args参数，如果name参数中不包含路径分隔符，command使用LookPath来解决路径问题，否则的话就直接使用name；Args直接跟在command命令之后，所以在Args中不许要添加命令．

``` go
func main() {
    cmd := exec.Command("tr", "a-z", "A-Z")
    cmd.Stdin = strings.NewReader("some input")
    var out bytes.Buffer
    cmd.Stdout = &out
    err := cmd.Run()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("in all caps: %q\n", out.String())　　//in all caps: "SOME INPUT"
}
```

func (c \*Cmd) CombinedOutput() (\[\]byte, error)　//运行命令，并返回标准输出和标准错误

``` go
func main() {
    cmd := exec.Command("ls") 　//查看当前目录下文件
    out, err := cmd.CombinedOutput()
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(string(out))
}
```

func (c \*Cmd) Output() (\[\]byte, error)　　　　　//运行命令并返回其标准输出

``` go
func main() {
    cmd := exec.Command("ls") ///查看当前目录下文件
    out, err := cmd.Output()
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(string(out))
}
```

<span style="color:#FF0000">注意：Output()和CombinedOutput()不能够同时使用，因为command的标准输出只能有一个，同时使用的话便会定义了两个，便会报错</span>
func (c \*Cmd) Run() error　　　　　　　　　　//<span style="color:#FF0000">开始指定命令并且等待他执行结束</span>，如果命令能够成功执行完毕，则返回nil，否则的话边会产生错误
func (c \*Cmd) Start() error　　　　　　　　　　//<span style="color:#FF0000">使某个命令开始执行，但是并不等到他执行结束，</span>这点和Run命令有区别．然后使用Wait方法等待命令执行完毕并且释放响应的资源

``` go
func main() {
    cmd := exec.Command("ls")
    cmd.Stdout = os.Stdout //
    cmd.Run()
    fmt.Println(cmd.Start()) //exec: already started
}
```

<span style="color:#FF0000">注：一个command只能使用Start()或者Run()中的一个启动命令，不能两个同时使用．</span>
func (c \*Cmd) StderrPipe() (io.ReadCloser, error)　　//StderrPipe返回一个pipe，这个管道连接到command的标准错误，当command命令退出时，Wait将关闭这些pipe
func (c \*Cmd) StdinPipe() (io.WriteCloser, error)　　　//StdinPipe返回一个连接到command标准输入的管道pipe

``` go
package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {
    cmd := exec.Command("cat")
    stdin, err := cmd.StdinPipe()
    if err != nil {
        fmt.Println(err)
    }
    _, err = stdin.Write([]byte("tmp.txt"))
    if err != nil {
        fmt.Println(err)
    }
    stdin.Close()
    cmd.Stdout = os.Stdout     //终端标准输出tmp.txt
    cmd.Start()
}
```

func (c \*Cmd) StdoutPipe() (io.ReadCloser, error)        //StdoutPipe返回一个连接到command标准输出的管道pipe

``` go
func main() {
    cmd := exec.Command("ls")
    stdout, err := cmd.StdoutPipe()　　//指向cmd命令的stdout
    cmd.Start()
    content, err := ioutil.ReadAll(stdout)
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(string(content))     //输出ls命令查看到的内容
}
```

func (c \*Cmd) Wait() error　　　　　　　　　　　　　//Wait等待command退出，他必须和Start一起使用，如果命令能够顺利执行完并顺利退出则返回nil，否则的话便会返回error，其中Wait会是放掉所有与cmd命令相关的资源

type Error    //Error返回科执行二进制文件名字不能够执行的原因的错误

``` go
type Error struct {
    Name string
    Err  error
}
```

func (e \*Error) Error() string

type ExitError　　//一个command不能够正常退出的error

``` go
type ExitError struct {
    *os.ProcessState
}
```

func (e \*ExitError) Error() string

参考：<http://golang.org/pkg/os/exec/#pkg-variables>
