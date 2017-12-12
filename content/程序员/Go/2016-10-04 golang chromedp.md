---
title: Go语言 chromedp
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
[](https://peter.sh/experiments/chromium-command-line-switches/)

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install google-chrome-stable

sudo add-apt-repository ppa:chromium-daily/stable
sudo apt-get update
sudo apt-get install chromium-browser


`google-chrome --headless --remote-debugging-port=9222  --disable-gpu http://baidu.com`
ubuntu上大多没有gpu，所以--disable-gpu
测试 curl http://localhost:9222 能够看到调试信息应该就是装好了。
` docker run -it -p 9222:9222 --rm --name chrome-headless knqz/chrome-headless`

 /usr/bin/google-chrome -> /etc/alternatives/google-chrome*
 /etc/alternatives/google-chrome -> /usr/bin/google-chrome-stable*
 /usr/bin/google-chrome-stable -> /opt/google/chrome/google-chrome*

## 注意事项
1. Pool 只能工作在 `headless_shell` 下,linux 默认是没有的，所以需要在docker headless模式下执行
2. `SendKeys` is for `input` elements 不能对 div 元素使用
## 创建新实例 和 连接到已有的实例
Starting a new instance of Chrome by invoking cdp.WithRunnerOptions resolves both of the issues detailed above:

c, err := cdp.New(ctxt, cdp.WithRunnerOptions(
	   runner.Flag("headless", true),
	   runner.Flag("disable-gpu", true)))

Previously, I was using cdp.WithTargets to connect to an existing instance of Chrome:

c, err := cdp.New(ctxt, cdp.WithTargets(client.New().WatchPageTargets(ctxt)))

## docker
 `docker run -it --rm -p=0.0.0.0:9222:9222 --name=chrome-headless -e "CHROME_OPTS=--proxy-server=localhost:8080" -v /tmp/chromedata/:/data norsknettarkiv/chrome-headless`

 `docker run -d -p 9222:9222 --rm --name chrome-headless knqz/chrome-headless`

## 启动 handless模式

c, err := cdp.New(ctxt, cdp.WithTargets(client.New().WatchPageTargets(ctxt)), cdp.WithLog(log.Printf))

## 执行js脚本
chromedp.Evaluate()
use the chromedp.Evaluate() action in conjuction with the chromedp/runner/Runner.
 Or use chromedp/cdp/runtime.Evaluate() with the frame handler.
## 最大化窗口
```go
c, err := cdp.New(ctxt, cdp.WithLog(log.Printf), cdp.WithRunnerOptions(
		runner.Flag("start-maximized", true),
	))
```

## 创建新的tab
```go
client := cdpclient.New()
t, err := client.NewPageTarget(ctx)
if err != nil {
    return err
}

h, err := cdp.NewTargetHandler(t, log.Printf, log.Printf, log.Printf)
if err != nil {
    return err
}

if err := h.Run(ctx); err != nil {
    return err
}
```
# 自定义chrome 路径
ctxt, cancel := context.WithCancel(context.Background())
defer cancel()
c, err := chromedp.New(ctxt, chromedp.WithRunnerOptions(
    runner.Path("/path/to/chrome"),
))



##
```go
ctxt, cancel := context.WithCancel(context.Background())
 defer cancel()

 start_load := time.Now()
 path := "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
 if runtime.GOOS != "windows" {
   path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
 }   

 c, err := cdp.New(ctxt, cdp.WithRunnerOptions(
  //  runner.Headless("/usr/bin/google-chrome", port),
   runner.Headless(path, 9222),
   runner.Flag("headless", true),
   runner.Flag("disable-gpu", true),
   runner.Flag("no-first-run", true),
   runner.Flag("no-default-browser-check", true),
   runner.Flag("window-size", "800,420"),
   runner.Flag("hide-scrollbars", "true"),
   runner.Flag("start-maximized", true),
   runner.Flag("disable-web-security", true),
  //  runner.Flag("headless", true),
 ))
 //
 if err != nil {
   log.Fatal(err)
 }

elapsed_load := time.Since(start_load)
```

## 开启代理
```go
// create chrome instance
	c, err := cdp.New(ctxt, cdp.WithRunnerOptions(runner.Proxy("127.0.0.1:1080")))
	if err != nil {
		log.Fatal(err)
}
c, err := chromedp.New(ctxt, chromedp.WithRunnerOptions(
    runner.Proxy(`http://localhost:8000/`),
))
```
```go
func NewBrowser(agent string, country string) *Client {
    var err error
    var proxy Proxy
    var chrome *cdp.CDP

    if country != "" {
        proxy = ByCountry(country)
    }

    // Create Context
    client := new(Client)
    ctxt, cancel := context.WithCancel(context.Background())

    // Create chrome instance
    var proxyOption = runner.Proxy(fmt.Sprintf("%s://%s:%s@%s:%s", proxy.Protocol, proxy.Credentials.User, proxy.Credentials.Password, proxy.Host, proxy.Port))
    var agentOption = runner.UserAgent(agent)

    if country == "" {
        chrome, err = cdp.New(ctxt, cdp.WithLog(log.Printf), cdp.WithRunnerOptions(agentOption))  // For headless use cdp.WithRunnerOptions(runner.Flag("headless", true) as third parameter
    } else {
        chrome, err = cdp.New(ctxt, cdp.WithRunnerOptions(agentOption, proxyOption))  // For headless use cdp.WithRunnerOptions(runner.Flag("headless", true) as third parameter
    }

    if err != nil {
        log.Fatal(err)
    }

    network.Enable()
    network.SetRequestInterceptionEnabled(true)

    client.Context = ctxt
    client.Client = chrome
    client.Cancel = cancel

    return client
}
```


## 获取节点
1. 所有事件作用在第一个找到的元素
```
var nodes []*cdptypes.Node
t := chromedp.Tasks{
	chromedp.Navigate(`https://godoc.org`),
	chromedp.Sleep(time.Second * 2),
	chromedp.Nodes(`ul[class="list-unstyled"] > li > a`, &nodes, chromedp.ByQueryAll),
}

err = c.Run(ctx, t)
if err != nil {
	log.Fatal(err)
}

for _, n := range nodes {
	fmt.Printf("got package: %s \n", n.AttributeValue("href"))
}
```
