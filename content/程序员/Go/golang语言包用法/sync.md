---
title: golang中sync.RWMutex和sync.Mutex区别
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[chenbaoke的专栏](http://blog.csdn.net/chenbaoke)
-------------------------------------------------

[golang中sync.RWMutex和sync.Mutex区别](/chenbaoke/article/details/41957725)
===========================================================================================================

版权声明：本文为博主原创文章，未经博主允许不得转载。

golang中sync包实现了两种锁Mutex （互斥锁）和RWMutex（读写锁），其中RWMutex是基于Mutex实现的，只读锁的实现使用类似引用计数器的功能．
```go
type Mutex

    func (m \*Mutex) Lock()
    func (m \*Mutex) Unlock()
type RWMutex
    func (rw \*RWMutex) Lock()
    func (rw \*RWMutex) RLock()
    func (rw \*RWMutex) RLocker() Locker
    func (rw \*RWMutex) RUnlock()
    func (rw \*RWMutex) Unlock()
```
其中Mutex为互斥锁，Lock()加锁，Unlock()解锁，使用Lock()加锁后，便不能再次对其进行加锁，直到利用Unlock()解锁对其解锁后，才能再次加锁．适用于读写不确定场景，即读写次数没有明显的区别，并且只允许只有一个读或者写的场景，所以该锁叶叫做全局锁．

func (m \*Mutex) Unlock()用于解锁m，<span style="color:#FF0000">如果在使用Unlock()前未加锁，就会引起一个运行错误．</span>

已经锁定的Mutex并不与特定的goroutine相关联，这样可以利用一个goroutine对其加锁，再利用其他goroutine对其解锁．

正常运行例子：

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var l *sync.Mutex
    l = new(sync.Mutex)
    l.Lock()
    defer l.Unlock()
    fmt.Println("1")
}
结果输出：１
```

当Unlock()在Lock()之前使用时，便会报错

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var l *sync.Mutex
    l = new(sync.Mutex)
    l.Unlock()
    fmt.Println("1")
    l.Lock()
}
运行结果： panic: sync: unlock of unlocked mutex
```

当在解锁之前再次进行加锁，便会死锁状态

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var l *sync.Mutex
    l = new(sync.Mutex)
    l.Lock()
    fmt.Println("1")
    l.Lock()
}
运行结果：  1
 
  fatal error: all goroutines are asleep - deadlock!
```

RWMutex是一个读写锁，该锁可以加多个读锁或者一个写锁，其经常用于读次数远远多于写次数的场景．

  func (rw \*RWMutex) Lock()　　写锁，如果在添加写锁之前已经有其他的读锁和写锁，则lock就会阻塞直到该锁可用，为确保该锁最终可用，已阻塞的 Lock 调用会从获得的锁中排除新的读取器，<span style="color:#FF0000">即写锁权限高于读锁，有写锁时优先进行写锁定</span>
  func (rw \*RWMutex) Unlock()　<span style="color:#FF0000">写锁解锁，如果没有进行写锁定，则就会引起一个运行时错误</span>．

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var l *sync.RWMutex
    l = new(sync.RWMutex)
    l.Unlock()
    fmt.Println("1")
    l.Lock()
}
运行结果：panic: sync: unlock of unlocked mutex
```

    func (rw \*RWMutex) RLock() 读锁，当有写锁时，无法加载读锁，当只有读锁或者没有锁时，可以加载读锁，读锁可以加载多个，所以适用于＂读多写少＂的场景

func (rw \*RWMutex)RUnlock()　读锁解锁，RUnlock 撤销单次 RLock 调用，它对于其它同时存在的读取器则没有效果。若 rw 并没有为读取而锁定，调用 RUnlock 就会引发一个运行时错误(<span style="color:#FF0000">注：这种说法在go1.3版本中是不对的，例如下面这个例子</span>)。

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var l *sync.RWMutex
    l = new(sync.RWMutex)
    l.RUnlock()　　　　//１个RUnLock
    fmt.Println("1")
    l.RLock()              
}

运行结果：１
但是程序中先尝试 解锁读锁，然后才加读锁，但是没有报错，并且能够正常输出．
```

分析：go1.3版本中出现这种情况的原因分析，通过阅读源码可以很清晰的得到结果

```go
func (rw *RWMutex) RUnlock() {
    if raceenabled {
        _ = rw.w.state
        raceReleaseMerge(unsafe.Pointer(&rw.writerSem))
        raceDisable()
    }<span style="color:#FF0000;">
    if atomic.AddInt32(&rw.readerCount, -1) < 0 {　//readercounter初始值为０,调用RUnLock之后变为-1，继续往下执行
        // A writer is pending.
        if atomic.AddInt32(&rw.readerWait, -1) == 0 {　//此时readerwaiter变为１，1-1之后变为０,可以继续以后的操作．</span>
            // The last reader unblocks the writer.
            runtime_Semrelease(&rw.writerSem)
        }
    }
    if raceenabled {
        raceEnable()
    }
}
```

当RUnlock多于RLock多个时，便会报错，进入死锁．实例如下：

```go
package main

import (
    "fmt"
    "sync"
)

type s struct {
    readerCount int32
}

func main() {
    l := new(sync.RWMutex)
    l.RUnlock()
    l.RUnlock()　　　　　　　　//此处出现死锁
    fmt.Println("1")
    l.RLock()
}
运行结果：
1
 
  fatal error: all goroutines are asleep - deadlock!
```

总结：

所以在go1.3版本中，运行过程中允许RUnLock早于RLock一个，也只能早于１个（注：虽然代码允许，但是强烈不推荐使用），并且在早于之后必须利用RLock进行加锁才可以继续使用．

<a href="#" class="bds_more"></a> <a href="#" class="bds_qzone" title="分享到QQ空间"></a> <a href="#" class="bds_tsina" title="分享到新浪微博"></a> <a href="#" class="bds_tqq" title="分享到腾讯微博"></a> <a href="#" class="bds_renren" title="分享到人人网"></a> <a href="#" class="bds_weixin" title="分享到微信"></a>

顶  
1

<!-- -->

踩  
0

[ ](javascript:void(0);)

[ ](javascript:void(0);)

-   <span onclick="_gaq.push(['_trackEvent','function', 'onclick', 'blog_articles_shangyipian']);location.href='/chenbaoke/article/details/41846753';">上一篇</span>[golang 中map并发读写操作](/chenbaoke/article/details/41846753)
-   <span onclick="_gaq.push(['_trackEvent','function', 'onclick', 'blog_articles_xiayipian']);location.href='/chenbaoke/article/details/41966827';">下一篇</span>[golang中recover和panic用法](/chenbaoke/article/details/41966827)

#### 我的同类文章

<span style="cursor:pointer" onclick="GetCategoryArticles('2511389','chenbaoke','foot','41957725');">go配置及开发*（52）*</span>

<http://blog.csdn.net>

<!-- -->

### <span>参考知识库</span>

<span class="embody_t">更多资料请参考：</span>

<span>猜你在找</span>

<span class="see_comment">查看评论</span>[]()

\* 以上用户言论只代表其个人观点，不代表CSDN网站的观点或立场[]()[]()

<a href="" id="quick-reply" class="btn btn-top q-reply" title="快速回复"><img src="http://static.blog.csdn.net/images/blog-icon-reply.png" alt="快速回复" /></a> <a href="" id="d-top-a" class="btn btn-top backtop" title="返回顶部"><img src="http://static.blog.csdn.net/images/top.png" alt="TOP" /></a>

[![](http://avatar.csdn.net/1/6/A/1_chenbaoke.jpg "访问我的空间")](http://my.csdn.net/chenbaoke)
<span><a href="http://my.csdn.net/chenbaoke" class="user_name">chenbaoke</a></span>

<a href="javascript:void(0);" id="span_add_follow" class="attent" title="[加关注]"></a> <a href="javascript:void(0);" class="letter" title="[发私信]"></a>

[![2](http://c.csdnimg.cn/jifen/images/xunzhang/xunzhang/zhuanlandaren.png)]() [![4](http://c.csdnimg.cn/jifen/images/xunzhang/xunzhang/chizhiyiheng.png)]()

-   访问：<span>84087次</span>
-   积分：<span>1262</span>
-   等级： <span style="position:relative;display:inline-block;z-index:1"> <img src="http://c.csdnimg.cn/jifen/images/xunzhang/jianzhang/blog4.png" id="leveImg" /> </span>

    积分：1262

-   排名：<span>千里之外</span>

<!-- -->

-   原创：<span>39篇</span>
-   转载：<span>29篇</span>
-   译文：<span>0篇</span>
-   评论：<span>6条</span>

<!-- -->

<!-- -->

<!-- -->

-   [python配置及开发](/chenbaoke/article/category/2441901)<span>(7)</span>
-   [go配置及开发](/chenbaoke/article/category/2511389)<span>(53)</span>
-   [linux](/chenbaoke/article/category/2557487)<span>(3)</span>
-   [zookeeper配置及开发](/chenbaoke/article/category/2641703)<span>(3)</span>
-   [git](/chenbaoke/article/category/2760631)<span>(3)</span>
-   [redis](/chenbaoke/article/category/6128238)<span>(1)</span>

<!-- -->

-   [2016年05月](/chenbaoke/article/month/2016/05)<span>(1)</span>
-   [2016年03月](/chenbaoke/article/month/2016/03)<span>(1)</span>
-   [2015年11月](/chenbaoke/article/month/2015/11)<span>(5)</span>
-   [2015年03月](/chenbaoke/article/month/2015/03)<span>(1)</span>
-   [2015年01月](/chenbaoke/article/month/2015/01)<span>(20)</span>
-   [2014年12月](/chenbaoke/article/month/2014/12)<span>(12)</span>
-   [2014年11月](/chenbaoke/article/month/2014/11)<span>(3)</span>
-   [2014年10月](/chenbaoke/article/month/2014/10)<span>(14)</span>
-   [2014年09月](/chenbaoke/article/month/2014/09)<span>(4)</span>
-   [2014年08月](/chenbaoke/article/month/2014/08)<span>(7)</span>

<!-- -->

-   [golang中sync.RWMutex和sync.Mutex区别](/chenbaoke/article/details/41957725 "golang中sync.RWMutex和sync.Mutex区别")<span>(5098)</span>
-   [golang中time包用法](/chenbaoke/article/details/41519193 "golang中time包用法")<span>(4470)</span>
-   [golang中os/exec包用法](/chenbaoke/article/details/42556949 "golang中os/exec包用法")<span>(4403)</span>
-   [go配置sublime text时使用MarGo报错及解决方法](/chenbaoke/article/details/38843449 "go配置sublime text时使用MarGo报错及解决方法")<span>(3368)</span>
-   [golang中net包用法（一）](/chenbaoke/article/details/42782571 "golang中net包用法（一）")<span>(3291)</span>
-   [golang中net/http包用法](/chenbaoke/article/details/42782417 "golang中net/http包用法")<span>(3013)</span>
-   [golang中net包用法(二)--IP](/chenbaoke/article/details/42782521 "golang中net包用法(二)--IP")<span>(2802)</span>
-   [golang中os包用法](/chenbaoke/article/details/42494851 "golang中os包用法")<span>(2714)</span>
-   [golang 中fmt用法](/chenbaoke/article/details/39932845 "golang 中fmt用法")<span>(2526)</span>
-   [golang中sort包用法](/chenbaoke/article/details/42340301 "golang中sort包用法")<span>(2517)</span>

<!-- -->

-   [golang中并发sync和channel](/chenbaoke/article/details/41647865 "golang中并发sync和channel")<span>(4)</span>
-   [go中利用hmset替换hset来提高redis的存取效率及并发goroutine可能遇到的问题](/chenbaoke/article/details/39899177 "go中利用hmset替换hset来提高redis的存取效率及并发goroutine可能遇到的问题")<span>(1)</span>
-   [十条有用的 Go 技术](/chenbaoke/article/details/44177001 "十条有用的 Go 技术")<span>(1)</span>
-   [linux sysctl 网络性能优化](/chenbaoke/article/details/39298911 "linux sysctl 网络性能优化")<span>(0)</span>
-   [linux top 命令行详解](/chenbaoke/article/details/39289091 "linux top 命令行详解")<span>(0)</span>
-   [Redis常用命令](/chenbaoke/article/details/50848303 "Redis常用命令")<span>(0)</span>
-   [go 编程小tips](/chenbaoke/article/details/38894669 "go 编程小tips")<span>(0)</span>
-   [go语言资料整理](/chenbaoke/article/details/38843831 "go语言资料整理")<span>(0)</span>
-   [go配置sublime text时使用MarGo报错及解决方法](/chenbaoke/article/details/38843449 "go配置sublime text时使用MarGo报错及解决方法")<span>(0)</span>
-   [python编码规范](/chenbaoke/article/details/38685315 "python编码规范")<span>(0)</span>

<!-- -->

-   [\* 程序员10月书讯，评论得书](http://blog.csdn.net/turingbooks/article/details/52522830)
-   [\* Android中Xposed框架篇---修改系统位置信息实现自身隐藏功能](http://blog.csdn.net/jiangwei0910410003/article/details/52836241)
-   [\* Chromium插件（Plugin）模块（Module）加载过程分析](http://blog.csdn.net/luoshengyang/article/details/52773402)
-   [\* Android TV开发总结--构建一个TV app的直播节目实例](http://blog.csdn.net/hejjunlin/article/details/52966319)
-   [\* 架构设计：系统存储--MySQL简单主从方案及暴露的问题](http://blog.csdn.net/yinwenjie/article/details/52935140)

<!-- -->

-   [十条有用的 Go 技术](/chenbaoke/article/details/44177001#comments)

    <a href="/alvine008" class="user_name">alvine008</a>: 这篇文章很不错。

-   [go中利用hmset替换hset来提高redis的存取效率及并发goroutine可能遇到的问题](/chenbaoke/article/details/39899177#comments)

    <a href="/u010238002" class="user_name">u010238002</a>: 不要共用conn就可以了，每次从pool获取

-   [golang中并发sync和channel](/chenbaoke/article/details/41647865#comments)

    <a href="/paladinosment" class="user_name">paladinosment</a>: @chenbaoke:我赞同你的观点。如果你稍微改改这段代码for i := 0; i &lt; 1000...

-   [golang中并发sync和channel](/chenbaoke/article/details/41647865#comments)

    <a href="/chenbaoke" class="user_name">chenbaoke</a>: @paladinosment:谢谢你的指正，已经更正．对于单cpu来说，确实是先运行主gorouti...

-   [golang中并发sync和channel](/chenbaoke/article/details/41647865#comments)

    <a href="/paladinosment" class="user_name">paladinosment</a>: 第二段程序"// 死锁，无结果"我是这么理解的。 其他协程必须在主协遇到阻塞才可以依次进入，协程和...

-   [golang中并发sync和channel](/chenbaoke/article/details/41647865#comments)

    <a href="/paladinosment" class="user_name">paladinosment</a>: 无缓存channel: 这一段你分析的不对。你自己多用几个fmt输出看看运行顺序。
