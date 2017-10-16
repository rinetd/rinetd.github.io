# Hugo

Hugo是一个用Go语言编写的静态网站生成器，它使用起来非常简单，相对于Jekyll复杂的安装设置来说，Hugo仅需要一个二进制文件hugo(hugo.exe)即可轻松用于本地调试和生成静态页面。

Hugo生成静态页面的效率很高，我的260多篇博客文章生成几乎是瞬间完成的，而之前用Jekyll需要等待10秒左右。


参考文章：[使用hugo搭建个人博客站点](http://blog.coderzh.com/2015/08/29/hugo/)

# Usage

Demo：[http://blog.coderzh.com/](http://blog.coderzh.com/)

界面参考 [http://cyrillschumacher.com/](http://cyrillschumacher.com/) 做了一些修改，并做了一个皮肤：[rapid](https://github.com/coderzh/hugo-rapid-theme)。 

需要该皮肤的朋友请单独 clone 这个皮肤：[https://github.com/coderzh/hugo-rapid-theme](https://github.com/coderzh/hugo-rapid-theme)

我的博客使用 git submodule 的方式引用的 rapid 皮肤，所以，clone 本 repo 后，记得执行：

```
git submodule init
git submodule update
```

### 启动调试

```
$ hugo server
```

打开浏览器：http://localhost:1313

### 部署

参考 `deploy.py`

参考文章：[通过webhook将Hugo自动部署至GitHub Pages和GitCafe Pages](http://blog.coderzh.com/2015/09/13/use-webhook-automated-deploy-hugo/)
